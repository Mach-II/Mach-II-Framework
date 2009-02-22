<!---
License:
Copyright 2008 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Provides HTML helper functionality and enables you to easily make
HTML related tags faster and less hassle to output such as 
outputting doctypes, css and javascript links and HTML metadata.

All javascript and css files get a timestamp appended for easy
webserver caching.

Configuration Usage:
<property name="html" type="MachII.properties.HtmlHelperProperty">
	<parameters>
		<parameter name="metaTitleSuffix" value=" - Mach-II" />
		<parameter name="cacheAssetPaths" value="false" />
		<!-- OR using environments -->
		<parameter name="cacheAssetPaths">
			<struct>
				<key name="development" value="false" />
				<key name="staging" value="false" />
				<key name="qualityAssurance" value="false" />
				<key name="production" value="true" />
			</struct>
		</parameter>
		<!-- Defaults to ExpandPath(".") -->
		<parameter name="webrootBasePath" value="/path/to/webroot" />
		<!-- Defaults to webroot base path + "/js" -->
		<parameter name="jsBasePath" value="/path/to/webroot" />
		<!-- Defaults to webroot base path + "/css" -->
		<parameter name="cssBasePath" value="/path/to/webroot" />
		<parameter name="assetPackages">
			<struct>
				<key name="lightwindow">
					<array>
						<element value="/js/prototype.js,/js/effects.js,/js/lightwindow.js" />
						<!-- SIMPLE -->
						<element value="/css/lightwindow.css">
						<!-- VERBOSE-->
						<element>
							<struct>
								<key name="paths" value="/css/lightwindow.cfm" />
								<key name="type" value="css" />
								<key name="attributes" value="media=screen,projection" />
							</struct>
						</element>
					</array>
				</key>
			</struct>
		</parameter>
	</parameters>
</property>

Developer Notes:
Because of the hierarchical nature of Mach-II applications that utilitze modules,
we store packages in the property manager so HTML helpers in modules can inherit
from the parent application.
--->
<cfcomponent 
	displayname="HTMLHelperProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Provider HTML helper functionality.">

	<!---
	PROPERTIES
	--->
	<cfset variables.metaTitleSuffix = "" />
	<cfset variables.cacheAssetPaths = false />
	<cfset variables.webrootBasePath = ExpandPath(".") />
	<cfset variables.jsBasePath = "/js" />
	<cfset variables.cssBasePath = "/css" />

	<cfset variables.mimeShortcutMap = StructNew() />
	<cfset variables.httpEquivReferenceMap = StructNew() />
	<cfset variables.assetPackagesPropertyName = "_HTMLHelper.assetPackages" />
	<cfset variables.assetPathsCache = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var cacheAssetPaths = StructNew() />
		
		<!--- Assert and set parameters --->
		<cfset setMetaTitleSuffix(getParameter("metaTitleSuffix")) />
		
		<cfif IsStruct(getParameter("cacheAssetPaths"))>
			<cfset cacheAssetPaths = getParameter("cacheAssetPaths") />
			
			<cfif StructKeyExists(cacheAssetPaths, getAppManager().getEnvironmentName())>
				<cfset setCacheAssetPaths(cacheAssetPaths[getAppManager().getEnvironmentName()]) />
			<cfelse>
				<cfset setCacheAssetPaths("false") />
			</cfif>
		<cfelse>
			<cfset setCacheAssetPaths(getParameter("cacheAssetPaths", "false")) />
		</cfif>
		
		<cfif isParameterDefined("webrootBasePath")>
			<cfset setWebrootBasePath(ExpandPath(getParameter("webrootBasePath"))) />
		</cfif>
		<cfif isParameterDefined("jsBasePath")>
			<cfset setJsBasePath(getParameter("jsBasePath")) />
		</cfif>
		<cfif isParameterDefined("cssBasePath")>
			<cfset setCssBasePath(getParameter("cssBasePath")) />
		</cfif>
		
		<cfset setAssetPackages(configureAssetPackages(getParameter("assetPackages", StructNew()))) />
		
		<!--- Build data --->
		<cfset buildMimeShortcutMap() />
		<cfset buildHttpEquivReferenceMap() />
	</cffunction>
	
	<cffunction name="configureAssetPackages" access="private" returntype="struct" output="false"
		hint="Configures asset packages from the 'package' parameter.">
		<cfargument name="rawPackages" type="struct" required="true" />
		
		<cfset var packages = StructNew() />
		<cfset var packageElements = ArrayNew(1) />
		<cfset var temp = "" />
		<cfset var element = "" />
		<cfset var key = "" />
		<cfset var i = 0 />
		
		<cfloop collection="#arguments.rawPackages#" item="key">
			<cfset packageData = ArrayNew(1) />
			
			<cfloop from="1" to="#ArrayLen(arguments.rawPackages[key])#" index="i">
				<cfset temp = arguments.rawPackages[key][i] />
				<cfset element = StructNew() />
				
				<cfif IsSimpleValue(temp)>
					<cfset element.paths = Trim(temp) />
					<cfset element.type = ListLast(element.paths, ".") />
					<cfset element.attributes = "" />
				<cfelseif IsStruct(temp)>
					<cfset getAssert().isTrue(StructKeyExists(temp, "paths")
						, "A key named 'paths' must exist for an element in position '#i#' of a package named '#key#' in module '#getAppManager().getModuleName()#'.") />
				
					<cfset element.paths = Trim(temp.paths) />
					
					<cfif NOT StructKeyExists(temp,  "type")>
						<cfset element.type = ListLast(element.paths, ".") />
					<cfelse>
						<cfset element.type = temp.type />
					</cfif>
					
					<cfif NOT StructKeyExists(temp, "attributes")>
						<cfset element.attributes = "" />
					<cfelse>
						<cfset element.attributes = temp.attributes />
					</cfif>
				</cfif>
				
				<!--- Assert that type is supported --->
				<cfset getAssert().isTrue(ListFindNoCase("js,css", element.type)
						, "The type for path '#element.paths#' in package '#key#' in module '#getAppManager().getModuleName()#' is not supported."
						, "Valid types are 'js' or 'css'. It could be that it was not possible to auto-resolve the type by the file extension.") />
				
				<cfset ArrayAppend(packageElements, element) />
			</cfloop>
			
			<cfset packages[key] = packageElements />
		</cfloop>
		
		<cfreturn packages />
	</cffunction>
	
	<cffunction name="buildMimeShortcutMap" access="private" returntype="void" output="false"
		hint="Builds the MIME shortcut map.">
		
		<cfset var mimeShortcutMap = StructNew() />
		<cfset var temp = StructNew() />
		
		<cfset temp = StructNew() />
		<cfset temp.type = "image/x-icon" />
		<cfset temp.rel = "shortcut icon" />
		<cfset mimeShortcutMap.icon = temp />
		
		<cfset temp = StructNew() />
		<cfset temp.type = "application/atom+xml" />
		<cfset temp.rel = "alternate" />
		<cfset mimeShortcutMap.atom = temp />
		
		<cfset temp = StructNew() />
		<cfset temp.type = "application/rss+xml" />
		<cfset temp.rel = "alternate" />
		<cfset mimeShortcutMap.rss = "application/rss+xml" />
		
		<cfset temp = StructNew() />
		<cfset temp.type = "text/html" />
		<cfset temp.rel = "alternate" />
		<cfset mimeShortcutMap.html = "text/html" />	
		
		<cfset setMimeShortcutMap(mimeShortcutMap) />
	</cffunction>
	
	<cffunction name="buildHttpEquivReferenceMap" access="private" returntype="void" output="false"
		hint="Builds the meta tag's http-equiv reference map.">
		
		<cfset var httpEquivReferenceMap = StructNew() />
		
			<cfset httpEquivReferenceMap["allow"] = "" />
			<cfset httpEquivReferenceMap["content-encoding"] = "" />
			<cfset httpEquivReferenceMap["content-length"] = "" />
			<cfset httpEquivReferenceMap["content-type"] = "" />
			<cfset httpEquivReferenceMap["date"] = "" />
			<cfset httpEquivReferenceMap["expires"] = "" />
			<cfset httpEquivReferenceMap["last-modified"] = "" />
			<cfset httpEquivReferenceMap["location"] = "" />
			<cfset httpEquivReferenceMap["refresh"] = "" />
			<cfset httpEquivReferenceMap["set-cookie"] = "" />
			<cfset httpEquivReferenceMap["www-authenticate"] = "" />

		<cfset setHttpEquivReferenceMap(httpEquivReferenceMap) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCharset" access="public" returntype="string" output="false"
		hint="Adds an HTML meta element with passed charset.">
		<cfargument name="charset" type="string" required="false" default="utf-8"
			hint="Sets the document charset. Defaults to utf-8." />
		<cfreturn '<meta http-equiv="Content-Type" content="text/html; charset=' & arguments.charset & '" />' & Chr(13) />
	</cffunction>
	
	<cffunction name="addDocType" access="public" returntype="string" output="false"
		hint="Adds an HTML document type.">
		<cfargument name="type" type="string" required="false" default="xhtml-1.0-strict" 
			hint="The doc type to render. (xhtml-1.0-strict, xhtml-1.0-trans, xhtml-1.0-frame, xhtml-1.1, html-4.0-strict, html-4.0-trans, html-4.0-frame)" />
		
		<cfswitch expression="#arguments.type#">
			<cfcase value="xhtml-1.0-strict">
				<cfreturn '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' />
			</cfcase>
			<cfcase value="xhtml-1.0-trans">
				<cfreturn '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' />
			</cfcase>
			<cfcase value="xhtml-1.0-frame">
				<cfreturn '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">' />
			</cfcase>
			<cfcase value="xhtml-1.1">
				<cfreturn '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">' />
			</cfcase>
			<cfcase value="html-4.0-strict">
				<cfreturn '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">' />
			</cfcase>
			<cfcase value="html-4.0-trans">
				<cfreturn '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' />
			</cfcase>
			<cfcase value="html-4.0-frame">
				<cfreturn '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">' />
			</cfcase>
			<cfdefaultcase>
				<cfthrow type="MachII.properties.HTMLHelperProperty.InvalidArgument"
					message="The renderDocType method does not accept the type of '#arguments.type#'."
						detail="Allowed values for 'type' are xhtml-1.0-strict, xhtml-1.0-trans, xhtml-1.0-frame, xhtml-1.1, html-4.0-strict, html-4.0-trans, html-4.0-frame." />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="addAssetPackage" access="public" returntype="string" output="false"
		hint="Adds files that are defined as an asset package.">
		<cfargument name="assetPackageName" type="string" required="true"
			hint="The name of the asset package to add." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code (head, inline).">
		
		<cfset var package = getAssetPackageByName(arguments.assetPackageName) />
		<cfset var code = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(package)#" index="i">
			<cfif package[i].type EQ "js">
				<cfset code = code & addJavascript(package[i].paths, "inline") />
			<cfelseif package[i].type EQ "css">
				<cfset code = code & addCss(package[i].paths, "inline") />
			</cfif>
			<cfif i NEQ ArrayLen(package)>
				<cfset code = code & Chr(13) />
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addJavascript" access="public" returntype="string" output="false"
		hint="Adds javascript files script code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="urls" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible paths to .js files.">
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code (head, inline).">
		
		<cfset var code = "" />
		<cfset var i = 0 />
		<cfset var log = getLog() />
		<cfset var assetPath = "" />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.urls)>
 			<cfset arguments.urls = ListToArray(getUtils().trimList(arguments.urls)) />
		</cfif>

		<cfloop from="1" to="#ArrayLen(arguments.urls)#" index="i">
			<cfset assetPath = computeAssetPath("js", arguments.urls[i]) />
			<cfif arguments.outputType EQ "inline" OR
				(arguments.outputType EQ "head" AND NOT isAssetPathInWatchList(assetPath))>
				<cfset code = code & '<script type="text/javascript" src="' & assetPath & '"></script>' />
				<cfif ArrayLen(arguments.urls) NEQ i>
					<cfset code = code & Chr(13) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addCss" access="public" returntype="string" output="false"
		hint="Adds css script code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="urls" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible paths to .css files.">
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code (head, inline).">
		
		<cfset var code = "" />
		<cfset var attributesCode = "" />
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var assetPath = "" />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.urls)>
 			<cfset arguments.urls = ListToArray(getUtils().trimList(arguments.urls)) />
		</cfif>
		
		<!--- Explode attributes to struct --->
		<cfset arguments.attributes = getUtils().parseAttributesIntoStruct(arguments.attributes) />
		
		<!--- Build attributes code section --->
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset attributesCode = attributesCode & ' ' & LCase(key) & '="' & arguments.attributes[key] & '"' />
		</cfloop>
		
		<cfset attributesCode = attributesCode & ' />' />

		<cfloop from="1" to="#ArrayLen(arguments.urls)#" index="i">
			<cfset assetPath = computeAssetPath("css", arguments.urls[i]) />
			<cfif arguments.outputType EQ "inline" OR
				(arguments.outputType EQ "head" AND NOT isAssetPathInWatchList(assetPath))>
				<cfset code = code & '<link type="text/css" href="' & assetPath & '" rel="stylesheet"' & attributesCode />
				<cfif ArrayLen(arguments.urls) NEQ i>
					<cfset code = code & Chr(13) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addLink" access="public" returntype="string" output="false"
		hint="Adds code for a link tag for inline use or in the HTML head.">
		<cfargument name="type" type="string" required="true"
				hint="The type of link. Supports type shortcuts 'icon', 'rss', 'atom' and 'html', otherwise a complete MIME type is required." />
		<cfargument name="url" type="any" required="true"
			hint="A the path to a web accessible location of the link file." />
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code (head, inline).">
		
		<cfset var mimeTypeData = resolveMimeTypeAndGetData(arguments.type) />
		<cfset var code = '<link href="' & arguments.url & '"' />
		<cfset var key = "" />
		
		<cfset StructAppend(getUtils().parseAttributesIntoStruct(arguments.attributes), resolveMimeTypeAndGetData(arguments.type)) />
		
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset code = code & ' ' & LCase(key) & '="' & HTMLEditFormat(arguments.attributes[key]) & '"' />
		</cfloop>
		
		<cfset code = code & ' />' & Chr(13) />
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addMeta" access="public" returntype="string" output="false"
		hint="Adds meta tag code for inline use or in the HTML head.">
		<cfargument name="type" type="string" required="true"
			hint="The type of the meta tag (this method auto-selects if value is a meta type of 'http-equiv' or 'name')." />
		<cfargument name="content" type="string" required="true"
			hint="The content of the meta tag." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code (head, inline).">			
		
		<cfset var code = "" />
		<cfset var key = "" />
		
		<cfif arguments.type EQ "title">
			<cfset code = '<title>' & HTMLEditFormat(arguments.content & getMetaTitleSuffix()) & '</title>' & Chr(13) />
		<cfelse>
			<cfif isHttpEquivMetaType(arguments.type)>
				<cfset code = '<meta http-equiv="' & arguments.type & '" content="' & HTMLEditFormat(arguments.content) & '" />' & Chr(13) />
			<cfelse>
				<cfset code = '<meta name="' & arguments.type & '" content="' & HTMLEditFormat(arguments.content) & '" />' & Chr(13) />
			</cfif>
		</cfif>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="renderOrAppendToHead" access="private" returntype="string" output="false"
		hint="Renders the code or append to head.">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="outputType" type="string" required="true" />

		<!--- Output the code inline or append to HTML head --->
		<cfif arguments.outputType EQ "inline">
			<cfreturn arguments.code />
		<cfelse>
			<cfset getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTMLHeadElement(arguments.code) />
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="isAssetPathInWatchList" access="private" returntype="boolean" output="false"
		hint="Checks if an asset path is in the watch list. Returns true if the asset is already on watch list and false if it is not on list.">
		<cfargument name="assetPath" type="string" required="true"
			hint="Path to element." />
		
		<cfset var assetPathHash = Hash(UCase(arguments.assetPath)) />
		
		<cfif NOT StructKeyExists(request, "_MachIIHTMLHelper_HTMLHeadElementPaths")>
			<cfset request["_MachIIHTMLHelper_HTMLHeadElementPaths"] = StructNew() />
		</cfif>
		
		<cfif StructKeyExists(request._MachIIHTMLHelper_HTMLHeadElementPaths, assetPathHash)>
			<cfreturn true />
		<cfelse>
			<cfset request._MachIIHTMLHelper_HTMLHeadElementPaths[assetPathHash] = "" />
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="resolveMimeTypeAndGetData" access="private" returntype="struct" output="false"
		hint="Resolves if the passed MIME type is a shortcut and defaults the passed mime type if not.">
		<cfargument name="type" type="string" required="true" />
		
		<cfset var mimeShortcutMap = getMimeShortcutMap() />
		<cfset var result = StructNew() />
		
		<cfif StructKeyExists(mimeShortcutMap, arguments.type)>
			<cfset result = mimeShortcutMap[arguments.type] />
		<cfelse>
			<cfset result.type = argments.type />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="isHttpEquivMetaType" access="private" returntype="boolean" output="false"
		hint="Checks if the passed type of the meta tag is an http-equiv.">
		<cfargument name="type" type="string" required="true" />
		<cfreturn StructKeyExists(getHttpEquivReferenceMap(), arguments.type) />
	</cffunction>
	
	<cffunction name="getAssetPackageByName" access="private" returntype="array" output="false"
		hint="Gets a asset package by name. Checks parent if defined.">
		<cfargument name="assetPackageName" type="string" required="true" />
		
		<cfset var packages = getAssetPackages() />
		<cfset var parentPackages = getAssetParentPackages() />
		
		<cfif StructKeyExists(packages, arguments.assetPackageName)>
			<cfreturn packages[arguments.assetPackageName] />
		<cfelseif StructKeyExists(parentPackages, arguments.assetPackageName)>
			<cfreturn parentPackages[arguments.assetPackageName] />
		<cfelse>
			<cfthrow type="MachII.properties.HTMLHelperProperty.assetPackageDoesNotExist"
				message="A asset package named '#arguments.assetPackageName#' cannot be found."
				detail="Asset Packages: #StructKeyList(packages)# Parent Asset Packages: #StructKeyList(parentPackages)#" />
		</cfif>
	</cffunction>
	
	<cffunction name="computeAssetPath" access="private" returntype="string" output="false"
		hint="Checks if the raw asset path and type is already in the asset path cache.">
		<cfargument name="assetType" type="string" required="true" />
		<cfargument name="assetPath" type="string" required="true" />
		
		<cfset var assetPathHash = "" />
		<cfset var path = "" />
		
		<!--- Check if we are caching asset paths --->
		<cfif getCacheAssetPaths()>
			<cfset assetPathHash = Hash(UCase(arguments.assetType & "_" & arguments.assetPath)) />
			<cfif StructKeyExists(variables.assetPathsCache, assetPathHash)>
				<cfset path = variables.assetPathsCache[assetPathHash] />
			<cfelse>
				<cfset path = buildAssetPath(arguments.assetType, arguments.assetPath) />
				<cfset variables.assetPathsCache[assetPathHash] = path />
			</cfif>
		<cfelse>
			<cfset path = buildAssetPath(arguments.assetType, arguments.assetPath) />
		</cfif>
		
		<cfreturn path />
	</cffunction>
	
	<cffunction name="buildAssetPath" access="private" returntype="string" output="false"
		hint="Builds the asset path for a raw path and type.">
		<cfargument name="assetType" type="string" required="true" />
		<cfargument name="assetPath" type="string" required="true" />
		
		<cfset var path = arguments.assetPath />
		
		<!--- Get path if the asset path is not a full path from webroot --->
		<cfif NOT path.startsWith("/")>
			<cfif arguments.assetType EQ "js">
				<cfset path = getJsBasePath() & "/" & path />
			<cfelseif arguments.assetType EQ "css">
				<cfset path = getCssBasePath() & "/" & path />
			</cfif>
		</cfif>
		
		<!--- Append the file extension if not defined --->
		<cfif arguments.assetType EQ "js" AND NOT path.endsWith(".js")>
			<cfset path = path & ".js" />
		<cfelseif arguments.assetType EQ "css" AND NOT path.endsWith(".css")>
			<cfset path = path & ".css" />
		</cfif>
		
		<!--- Append the timestamp --->
		<cfset path = path & "?" & fetchAssetTimestamp(path) />
		
		<cfreturn path />
	</cffunction>
		
	<cffunction name="fetchAssetTimestamp" access="private" returntype="numeric" output="false"
		hint="Fetches the asset timestamp (seconds from epoch) from the passed target asset path.">
		<cfargument name="assetPath" type="string" required="true"
			hint="This is the full asset path from the webroot." />
		
		<cfset var path = getWebrootBasePath() & "/" & arguments.assetPath />
		<cfset var directoryResults = "" />
		
		<cfdirectory action="LIST" directory="#GetDirectoryFromPath(path)#" 
			name="directoryResults" filter="#GetFileFromPath(path)#" />

		<!--- Assert the file was found --->
		<cfset getAssert().isTrue(directoryResults.recordcount EQ 1
				, "Cannot fetch a timestamp for an asset because it cannot be located. Check for your asset paths."
				, "Asset path: '#path#'") />
		
		<cfreturn DateDiff("s", CreateDate(1970, 1, 1), directoryResults.dateLastModified) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setMetaTitleSuffix" access="private" returntype="void" output="false">
		<cfargument name="metaTitleSuffix" type="string" required="true" />
		<cfset variables.metaTitleSuffix = arguments.metaTitleSuffix />
	</cffunction>
	<cffunction name="getMetaTitleSuffix" access="public" returntype="string" output="false">
		<cfreturn variables.metaTitleSuffix />
	</cffunction>
	
	<cffunction name="setCacheAssetPaths" access="private" returntype="void" output="false">
		<cfargument name="cacheAssetPaths" type="boolean" required="true" />
		<cfset variables.cacheAssetPaths = arguments.cacheAssetPaths />
	</cffunction>
	<cffunction name="getCacheAssetPaths" access="public" returntype="boolean" output="false">
		<cfreturn variables.cacheAssetPaths />
	</cffunction>

	<cffunction name="setWebrootBasePath" access="private" returntype="void" output="false">
		<cfargument name="webrootBasePath" type="string" required="true" />
		<cfset variables.webrootBasePath = arguments.webrootBasePath />
	</cffunction>
	<cffunction name="getWebrootBasePath" access="public" returntype="string" output="false">
		<cfreturn variables.webrootBasePath />
	</cffunction>

	<cffunction name="setJsBasePath" access="private" returntype="void" output="false">
		<cfargument name="jsBasePath" type="string" required="true" />
		<cfset variables.jsBasePath = arguments.jsBasePath />
	</cffunction>
	<cffunction name="getJsBasePath" access="public" returntype="string" output="false">
		<cfreturn variables.jsBasePath />
	</cffunction>

	<cffunction name="setCssBasePath" access="private" returntype="void" output="false">
		<cfargument name="cssBasePath" type="string" required="true" />
		<cfset variables.cssBasePath = arguments.cssBasePath />
	</cffunction>
	<cffunction name="getCssBasePath" access="public" returntype="string" output="false">
		<cfreturn variables.cssBasePath />
	</cffunction>
	
	<cffunction name="setMimeShortcutMap" access="private" returntype="void" output="false">
		<cfargument name="mimeShortcutMap" type="struct" required="true" />
		<cfset variables.mimeShortcutMap = arguments.mimeShortcutMap />
	</cffunction>
	<cffunction name="getMimeShortcutMap" access="public" returntype="struct" output="false">
		<cfreturn variables.mimeShortcutMap />
	</cffunction>
	
	<cffunction name="setHttpEquivReferenceMap" access="private" returntype="void" output="false">
		<cfargument name="httpEquivReferenceMap" type="struct" required="true" />
		<cfset variables.httpEquivReferenceMap = arguments.httpEquivReferenceMap />
	</cffunction>
	<cffunction name="getHttpEquivReferenceMap" access="public" returntype="struct" output="false">
		<cfreturn variables.httpEquivReferenceMap />
	</cffunction>
	
	<cffunction name="setAssetPackages" access="private" returntype="void" output="false"
		hint="Sets the asset packages into the property manager.">
		<cfargument name="assetPackages" type="struct" required="true" />
		<cfset setProperty(variables.assetPackagesPropertyName, arguments.assetPackages) />
	</cffunction>
	<cffunction name="getAssetPackages" access="public" returntype="struct" output="false"
		hint="Gets the asset pacakages from the property manager.">
		<cfreturn getProperty(variables.assetPackagesPropertyName) />
	</cffunction>
	<cffunction name="getAssetParentPackages" access="public" returntype="struct" output="false"
		hint="Gets the asset pacakages from the parent property manager.">
		<cfif getAppManager().inModule()>
			<cfreturn getPropertyManager().getParent().getProperty(variables.assetPackagesPropertyName, StructNew()) />
		<cfelse>
			<cfreturn StructNew() />
		</cfif>
	</cffunction>

</cfcomponent>