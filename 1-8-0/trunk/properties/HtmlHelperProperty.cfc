<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Provides HTML helper functionality and enables you to easily make
HTML related tags faster and less hassle to output such as 
outputting doctypes, css and javascript links and HTML metadata.

All javascript, css and image files get a timestamp appended for easy
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
		<parameter name="jsBasePath" value="/path/from/webroot/js" />
		<!-- Defaults to webroot base path + "/css" -->
		<parameter name="cssBasePath" value="/path/from/webroot/css" />
		<!-- Defaults to webroot base path + "/img" -->
		<parameter name="imgBasePath" value="/path/from/webroot/img" />
		<parameter name="assetPackages">
			<struct>
				<key name="lightwindow">
					<array>
						<element value="prototype.js,effects.js,otherDirectory/lightwindow.js" />
						<!-- SIMPLE -->
						<element value="lightwindow.css">
						<!-- VERBOSE-->
						<element>
							<struct>
								<key name="paths" value="/css/lightwindow.cfm" />
								<key name="type" value="css" />
								<key name="attributes" value="media=screen,projection" />
								<key name="forIEVersion" value="gte 7" />
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
	<cfset variables.imgBasePath = "/img" />

	<cfset variables.mimeShortcutMap = StructNew() />
	<cfset variables.httpEquivReferenceMap = StructNew() />
	<cfset variables.assetPathsCache = StructNew() />
	
	<!--- Some hosts (such as GAE) do not support java.awt.* package --->
	<cfset variables.AWT_TOOLKIT = "" />

	<!--- Do not use these locators as they may change in future versions --->
	<cfset variables.HTML_HELPER_PROPERTY_NAME = "_HTMLHelper" />
	<cfset variables.ASSET_PACKAGES_PROPERTY_NAME = "_HTMLHelper.assetPackages" />

	<!--- Tabs, line feeds and carriage returns --->
	<cfset variables.CLEANUP_CONTROL_CHARACTERS_REGEX =  Chr(9) & '|' & Chr(10) & '|' & Chr(13) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var cacheAssetPaths = StructNew() />
		<cfset var webrootBasePath  = "" />
		
		<!--- Configure auto-dimensions for addImage() --->
		<cftry>
			<cfset variables.AWT_TOOLKIT = CreateObject("java", "java.awt.Toolkit").getDefaultToolkit() />
			<cfcatch type="any">
				<!--- Some hosts (such as GAE) do not support java.awt.* package so replace with mock function --->
				<cfset variables.getImageDimensions = variables.mock_getImageDimensions />
				<cfset this.getImageDimensions = this.mock_getImageDimensions />
			</cfcatch>
		</cftry>
		
		<!--- Assert and set parameters --->
		<cfset setMetaTitleSuffix(getParameter("metaTitleSuffix")) />
		
		<cfset setCacheAssetPaths(getParameter("cacheAssetPaths", "false")) />
		<cfset setWebrootBasePath(ExpandPath(getParameter("webrootBasePath", "."))) />
		
		<!--- These paths are defaulted in the pseudo-constructor area --->
		<cfif isParameterDefined("jsBasePath")>
			<cfset setJsBasePath(getParameter("jsBasePath")) />
		</cfif>
		<cfif isParameterDefined("cssBasePath")>
			<cfset setCssBasePath(getParameter("cssBasePath")) />
		</cfif>
		<cfif isParameterDefined("imgBasePath")>
			<cfset setImgBasePath(getParameter("imgBasePath")) />
		</cfif>
		
		<cfset setAssetPackages(configureAssetPackages(getParameter("assetPackages", StructNew()))) />
		
		<!--- Build reference data --->
		<cfset buildMimeShortcutMap() />
		<cfset buildHttpEquivReferenceMap() />
		<cfset buildDocTypeReferenceMap() />
		
		<!--- Add a reference of the helper in a known property location --->
		<cfset setProperty(variables.HTML_HELPER_PROPERTY_NAME, this) />
	</cffunction>
		
	<cffunction name="configureAssetPackages" access="private" returntype="struct" output="false"
		hint="Configures asset packages from the 'package' parameter.">
		<cfargument name="rawPackages" type="struct" required="true"
			hint="The raw data from the 'assetPackages' parameter." />
		
		<cfset var packages = StructNew() />
		<cfset var packageElements = ArrayNew(1) />
		<cfset var temp = "" />
		<cfset var element = "" />
		<cfset var key = "" />
		<cfset var i = 0 />
		<cfset var k = 0 />
		
		<cfloop collection="#arguments.rawPackages#" item="key">
			<cfset packageElements = ArrayNew(1) />
			
			<cfloop from="1" to="#ArrayLen(arguments.rawPackages[key])#" index="i">
				<cfset temp = arguments.rawPackages[key][i] />
				<cfset element = StructNew() />				
				
				<cfif IsSimpleValue(temp)>
					<cfif NOT IsArray(temp)>
						<cfset element.paths = ListToArray(getUtils().trimList(temp)) />
					<cfelse>
						<cfset element.paths = temp />
					</cfif>
					<cfset element.type = ensureAndDetectAssetPackageType(element.paths) />
					
					<cfif element.type EQ "">
						<cfthrow type="MachII.properties.HtmlHelperProperty.MixedAssetTypes"
							message="Unable to determine asset types for asset package named '#key#' due to mixed asset types or ambigous file extensions. You need to use verbose syntax if using simple syntax when defining these assets or explicitly define an asset 'type'."
							detail="Asset paths: '#ArrayToList(element.paths)#" />
					</cfif>

					<cfset element.attributes = "" />
					<cfset element.forIEVersion = "" />
				<cfelseif IsStruct(temp)>
					<cfset getAssert().isTrue(StructKeyExists(temp, "paths")
						, "A key named 'paths' must exist for an element in position '#i#' of a package named '#key#' in module '#getAppManager().getModuleName()#'.") />
				
					<!--- Explode the list to an array --->
					<cfif NOT IsArray(temp.paths)>
			 			<cfset element.paths = ListToArray(getUtils().trimList(temp.paths)) />
			 		<cfelse>
						<cfset element.paths = temp.paths />
					</cfif>
					
					<cfif NOT StructKeyExists(temp,  "type")>
						<cfset element.type = ensureAndDetectAssetPackageType(temp.paths) />
						
						<cfif element.type EQ "">
							<cfthrow type="MachII.properties.HtmlHelperProperty.MixedAssetTypes"
							message="Unable to determine asset types for asset package named '#key#' due to mixed asset types or ambigous file extensions. You need to use verbose syntax if using simple syntax when defining these assets or explicitly define an asset 'type'."
							detail="Asset paths: '#ArrayToList(element.paths)#" />
						</cfif>
					<cfelse>
						<cfset element.type = temp.type />
					</cfif>
					
					<cfif NOT StructKeyExists(temp, "attributes")>
						<cfset element.attributes = "" />
					<cfelse>
						<cfset element.attributes = temp.attributes />
					</cfif>
					
					<cfif NOT StructKeyExists(temp, "forIEVersion")>
						<cfset element.forIEVersion = "" />
					<cfelse>
						<cfset element.forIEVersion = temp.forIEVersion />
					</cfif>
				</cfif>
				
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
		<cfset mimeShortcutMap.rss = temp />
		
		<cfset temp = StructNew() />
		<cfset temp.type = "text/html" />
		<cfset temp.rel = "alternate" />
		<cfset mimeShortcutMap.html = temp />

		<!--- Canonical link do not have a "type" attribute --->
		<cfset temp = StructNew() />
		<cfset temp.rel = "canonical" />
		<cfset mimeShortcutMap.html = temp />
		
		<cfset setMimeShortcutMap(mimeShortcutMap) />
	</cffunction>
	
	<cffunction name="buildHttpEquivReferenceMap" access="private" returntype="void" output="false"
		hint="Builds the meta tag's http-equiv reference map.">
		
		<cfset var httpEquivReferenceMap = StructNew() />
		
		<cfset httpEquivReferenceMap["allow"] = "" />
		<cfset httpEquivReferenceMap["content-language"] = "" />
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
	
	<cffunction name="buildDocTypeReferenceMap" access="private" returntype="void" output="false"
		hint="Build the available HTML doctype reference map.">
		
		<cfset var docTypeReferenceMap = StructNew() />
		
		<cfset docTypeReferenceMap["xhtml-1.0-strict"] 	= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' />
		<cfset docTypeReferenceMap["xhtml-1.0-trans"] 	= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' />
		<cfset docTypeReferenceMap["xhtml-1.0-frame"] 	= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">' />
		<cfset docTypeReferenceMap["xhtml-1.1"] 		= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">' />
		<cfset docTypeReferenceMap["html-4.0-strict"] 	= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">' />
		<cfset docTypeReferenceMap["html-4.0-trans"] 	= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' />
		<cfset docTypeReferenceMap["html-4.0-frame"] 	= '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">' />
		<cfset docTypeReferenceMap["html-5.0"] 			= '<!DOCTYPE HTML>' />
		
		<cfset setDocTypeReferenceMap(docTypeReferenceMap) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCharset" access="public" returntype="string" output="false"
		hint="Adds an HTML meta element with passed charset.">
		<cfargument name="charset" type="string" required="false" default="utf-8"
			hint="Sets the document charset. Defaults to utf-8." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates tthe output type for the generated HTML code (head, inline)." />

		<cfset var code = '<meta http-equiv="content-type" content="text/html; charset=' & arguments.charset & '" />' & Chr(13) />

		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addDocType" access="public" returntype="string" output="false"
		hint="Returns a full HTML document type. Returns a string to output and does not added to head because the document type is outside of the HTML head section.">
		<cfargument name="type" type="string" required="false" default="xhtml-1.0-strict" 
			hint="The doc type to render. Accepted values are 'xhtml-1.0-strict', 'xhtml-1.0-trans', 'xhtml-1.0-frame', 'xhtml-1.1', 'html-4.0-strict', 'html-4.0-trans', 'html-4.0-frame' and 'html-5.0'." />
		
		<cfset var docTypes = getDocTypeReferenceMap() />
		
		<cfif NOT StructKeyExists(docTypes, arguments.type)>
			<cfthrow type="MachII.properties.HTMLHelperProperty.InvalidArgument"
				message="The 'addDocType' method in the 'HtmlHelperProperty' does not accept the type of '#arguments.type#'."
				detail="Allowed values for 'type' are 'xhtml-1.0-strict', 'xhtml-1.0-trans', 'xhtml-1.0-frame', 'xhtml-1.1', 'html-4.0-strict', 'html-4.0-trans', 'html-4.0-frame' and 'html-5.0'." />
		</cfif>

		<cfreturn docTypes[arguments.type] />
	</cffunction>
	
	<cffunction name="addAssetPackage" access="public" returntype="string" output="false"
		hint="Adds files that are defined as an asset packages.">
		<cfargument name="package" type="any" required="true"
			hint="A list or array of the asset packages names to add." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates tthe output type for the generated HTML code ('head', 'inline')." />
		
		<cfset var p = "" />
		<cfset var code = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.package)>
 			<cfset arguments.package = ListToArray(getUtils().trimList(arguments.package)) />
		</cfif>
		
		<cfloop from="1" to="#ArrayLen(arguments.package)#" index="i">
			
			<cfset p = getAssetPackageByName(arguments.package[i]) />	
		
			<cfloop from="1" to="#ArrayLen(p)#" index="j">
				<cfif p[j].type EQ "js">
					<cfset code = code & addJavascript(p[j].paths, arguments.outputType) & Chr(13) />
				<cfelseif p[j].type EQ "css">
					<cfset code = code & addStylesheet(p[j].paths, p[j].attributes, arguments.outputType, p[j].forIEVersion) & Chr(13) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfset code = code & Chr(13) />
		
		<cfreturn code />
	</cffunction>
	
	<cffunction name="addJavascript" access="public" returntype="string" output="false"
		hint="Adds javascript files script code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="src" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible hrefs to .js files." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates the output type for the generated HTML code (head, inline)." />
		
		<cfset var code = "" />
		<cfset var i = 0 />
		<cfset var assetPath = "" />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.src)>
 			<cfset arguments.src = ListToArray(getUtils().trimList(arguments.src)) />
		</cfif>

		<cfloop from="1" to="#ArrayLen(arguments.src)#" index="i">
			<cfset assetPath = computeAssetPath("js", arguments.src[i]) />
			<cfif arguments.outputType EQ "inline" OR
				(arguments.outputType EQ "head" AND NOT isAssetPathInWatchList(assetPath))>
				<cfset code = code & '<script type="text/javascript" src="' & assetPath & '"></script>' & Chr(13) />
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addStylesheet" access="public" returntype="string" output="false"
		hint="Adds css stylesheet code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="href" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible hrefs to .css files." />
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates the output type for the generated HTML code ('head', 'inline')." />
		<cfargument name="forIEVersion" type="string" required="false"
			hint="Indicates if the stylesheet should be enclosed in IE conditional comment (ex. 'lt 7')." />
		
		<cfset var code = "" />
		<cfset var attributesCode = "" />
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var assetPath = "" />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.href)>
 			<cfset arguments.href = ListToArray(getUtils().trimList(arguments.href)) />
		</cfif>
		
		<!--- Explode attributes to struct --->
		<cfset arguments.attributes = getUtils().parseAttributesIntoStruct(arguments.attributes) />
		
		<!--- Build attributes code section --->
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset attributesCode = attributesCode & ' ' & LCase(key) & '="' & arguments.attributes[key] & '"' />
		</cfloop>

		<cfloop from="1" to="#ArrayLen(arguments.href)#" index="i">
			<cfset assetPath = computeAssetPath("css", arguments.href[i]) />
			<cfif arguments.outputType EQ "inline" OR
				(arguments.outputType EQ "head" AND NOT isAssetPathInWatchList(assetPath))>
				<cfset code = code & '<link type="text/css" href="' & assetPath & '" rel="stylesheet"' & attributesCode & ' />' & Chr(13) />
			</cfif>
		</cfloop>
		
		<!--- Enclose in an IE conditional comment if available --->
		<cfif StructKeyExists(arguments, "forIEVersion") AND Len(arguments.forIEVersion)>
			<cfset code = wrapIEConditionalComment(arguments.forIEVersion, code) />
		</cfif>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<cffunction name="addImage" access="public" returntype="string" output="false"
		hint="Adds code for an img tag for inline use.">
		<cfargument name="src" type="string" required="true"
			hint="The src path to a web accessible image file. Shortcut paths are allowed, however file name extensions cannot be omitted and must be specified." />
		<cfargument name="width" type="string" required="false" default=""
			hint="The width of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used." />
		<cfargument name="height" type="string" required="false" default=""
			hint="The height of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used." />
		<cfargument name="alt" type="string" required="false"
			hint="The text for the 'alt' attribute and automatically html escapes the value. If not defined, the value of 'alt=""' will be used as this attribute is required by the W3C specification." />
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		
		<cfset var code = '<img src="' & computeAssetPath("img", arguments.src) & '"' />
		<cfset var dimensions = "" />
		<cfset var key = "" />
	
		<!--- Set auto dimensions --->
		<cfif NOT Len(arguments.width) OR NOT Len(arguments.height)>
			<cfset dimensions = getImageDimensions(arguments.src) />
			
			<cfif NOT Len(arguments.height)>
				<cfset arguments.height = dimensions.height />
			</cfif>
			<cfif NOT Len(arguments.width)>
				<cfset arguments.width = dimensions.width />
			</cfif>
		</cfif>

		<cfif arguments.height NEQ -1>
			<cfset code = code & ' height="' & arguments.height  & '"' />
		</cfif>
		<cfif arguments.width NEQ -1>
			<cfset code = code & ' width="' & arguments.width  & '"' />
		</cfif>
		
		<!--- The 'alt' attribute is required by the W3C specification --->
		<cfif StructKeyExists(arguments, "alt") AND Len(arguments.alt)>
			<cfset code = code & ' alt="' & getUtils().escapeHtml(arguments.alt)  & '"' />
		<cfelse>
			<cfset code = code & ' alt="' & '"' />
		</cfif>
		
		<!--- Explode attributes to struct --->
		<cfset arguments.attributes = getUtils().parseAttributesIntoStruct(arguments.attributes) />
		
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset code = code & ' ' & LCase(key) & '="' & arguments.attributes[key] & '"' />
		</cfloop>
		
		<cfset code = code & ' />' />
		
		<cfreturn code />
	</cffunction>
	
	<cffunction name="addLink" access="public" returntype="string" output="false"
		hint="Adds code for a link tag for inline use or in the HTML head.">
		<cfargument name="type" type="string" required="true"
				hint="The type of link. Supports type shortcuts 'icon', 'rss', 'atom', 'html' and 'canonical', otherwise a complete MIME type is required." />
		<cfargument name="href" type="string" required="true"
			hint="The href path to a web accessible location of the link file." />
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="outputType" type="string" required="false" default="head"
			hint="Indicates to output type for the generated HTML code ('head', 'inline'). Link tags must be in the HTML head section according to W3C specification. Use the value of inline with caution." />
		
		<cfset var mimeTypeData = resolveMimeTypeAndGetData(arguments.type) />
		<cfset var code = '<link href="' & arguments.href & '"' />
		<cfset var key = "" />
		
		<cfset arguments.attributes = getUtils().parseAttributesIntoStruct(arguments.attributes) />
		<cfset StructAppend(arguments.attributes, mimeTypeData, false) />
		
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset code = code & ' ' & LCase(key) & '="' & getUtils().escapeHtml(arguments.attributes[key]) & '"' />
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
			hint="Indicates the output type for the generated HTML code ('head', 'inline'). Meta tags must be in the HTML head section according to W3C specification. Use the value of inline with caution." />
		
		<cfset var code = "" />
		<cfset var key = "" />
		
		<cfif arguments.type EQ "title">
			<cfset code = '<title>' & getUtils().escapeHtml(cleanupContent(arguments.content) & getMetaTitleSuffix()) & '</title>' & Chr(13) />
		<cfelse>
			<cfif StructKeyExists(getHttpEquivReferenceMap(), arguments.type)>
				<cfset code = '<meta http-equiv="' & arguments.type & '" content="' & getUtils().escapeHtml(cleanupContent(arguments.content)) & '" />' & Chr(13) />
			<cfelse>
				<cfset code = '<meta name="' & arguments.type & '" content="' & getUtils().escapeHtml(cleanupContent(arguments.content)) & '" />' & Chr(13) />
			</cfif>
		</cfif>
		
		<cfreturn renderOrAppendToHead(code, arguments.outputType) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="flushAssetPathCache" access="public" returntype="void" output="false"
		hint="Flushes the entire asset path cache. Does not clear a parent HtmlHelperProperty asset path cache.">
		<cfset variables.assetPathsCache = StructNew() />
	</cffunction>
	
	<cffunction name="clearAssetPathCacheByPath" access="public" returntype="boolean" output="false"
		hint="Clears an asset path cache element by type and path. Returns true if removed and false if not existing.">
		<cfargument name="assetType" type="string" required="true"
			hint="The type of asset ('img', 'js' and 'css')." />
		<cfargument name="assetPath" type="string" required="true"
			hint="The asset path which will be resolved to a full path as necessary." />

		<cfset var resolvedPath = buildAssetPath(arguments.assetType, arguments.assetPath) />		
		<cfset var assetPathHash = createAssetPathHash(resolvedPath) />
		
		<!---
		StructDelete returns 'true'  if key is not existing so we have to flip 
		the value for the correct return value for this method
		--->
		<cfreturn NOT StructDelete(variables.assetPathsCache, assetPathHash, true) />
	</cffunction>
	
	<cffunction name="computeAssetPath" access="public" returntype="string" output="false"
		hint="Checks if the raw asset path and type is already in the asset path cache.">
		<cfargument name="assetType" type="string" required="true"
			hint="The type of asset ('img', 'js' and 'css')." />
		<cfargument name="assetPath" type="string" required="true"
			hint="The asset path which will be resolved to a full path as necessary." />
		
		<cfset var assetPathHash = "" />
		<cfset var assetPathTimestamp = "" />
		<cfset var resolvedPath = "" />
		
		<!--- Check for external path --->
		<cfif arguments.assetPath.toLowercase().startsWith("http://") 
			OR arguments.assetPath.toLowercase().startsWith("https://")>
			<cfreturn arguments.assetPath />
		<!--- Resolve local path --->
		<cfelse>
			<cfset resolvedPath = buildAssetPath(arguments.assetType, arguments.assetPath) />
			
			<!--- Check if we are caching asset paths --->
			<cfif getCacheAssetPaths()>
				<cfset assetPathHash = createAssetPathHash(resolvedPath) />
	
				<cfif StructKeyExists(variables.assetPathsCache, assetPathHash)>
					<cfset assetPathTimestamp = variables.assetPathsCache[assetPathHash] />
				<cfelse>
					<cfset assetPathTimestamp = fetchAssetTimestamp(resolvedPath) />
					<cfset variables.assetPathsCache[assetPathHash] = assetPathTimestamp />
				</cfif>
				
				<cfreturn resolvedPath & "?" & assetPathTimestamp />
			<cfelse>
				<cfreturn resolvedPath />
			</cfif>
		</cfif>	
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="renderOrAppendToHead" access="private" returntype="string" output="false"
		hint="Renders the code or append to head.">
		<cfargument name="code" type="string" required="true"
			hint="The code to append to head or return to output inline." />
		<cfargument name="outputType" type="string" required="true"
			hint="The output type ('inline', 'head')." />

		<!--- Output the code inline or append to HTML head --->
		<cfif arguments.outputType EQ "inline">
			<cfreturn arguments.code />
		<cfelse>
			<cfset getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTMLHeadElement(arguments.code) />
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="wrapIEConditionalComment" access="private" returntype="string" output="false"
		hint="Wraps an IE conditional comment around the incoming code.">
		<cfargument name="forIEVersion" type="string" required="true"
			hint="The control code use 'all' for IE versions, a version number like '7' to indicate a specific IE version or operator plus version number like 'lt 7'." />
		<cfargument name="code" type="string" required="true"
			hint="The code to wrap the conditional comment around." />
		
		<cfset var conditional = Trim(arguments.forIEVersion) />
		<cfset var comment = Chr(13) />
		
		<!--- "all" in the version means all versions of IE --->
		<cfif conditional EQ "all">
			<cfset comment = comment & "<!--[if IE]>" & Chr(13) />
		<!--- No operator (just version number) means EQ for version --->
		<cfelseif IsNumeric(conditional)>
			<cfset comment = comment & "<!--[if IE " & conditional &  "]>" & Chr(13)  />
		<!--- Use operator ('lt', 'gte') and version number--->
		<cfelseif ListLen(conditional, " ") EQ 2>
			<cfset comment = comment & "<!--[if " & ListFirst(conditional, " ") & " IE " & ListLast(conditional, " ") &  "]>" & Chr(13)  />
		<!--- Throw an exception because of no match for conditional --->
		<cfelse>
			<cfthrow type="MachII.properties.HTMLHelperProperty.invalidIEConditional"
				message="An IE conditional of '#conditional#' is invalid."
				detail="The conditional value must be 'all', IE version number (numeric) or operator ('lt', 'gte') plus IE version number." />
		</cfif>
		
		<!--- Append the code --->
		<cfset comment = comment & arguments.code & Chr(13) & "<![endif]-->" & Chr(13) />

		<cfreturn comment />
	</cffunction>
	
	<cffunction name="isAssetPathInWatchList" access="private" returntype="boolean" output="false"
		hint="Checks if a resolved asset path is in the watch list. Returns true if the asset is already on watch list and false if it is not on list.">
		<cfargument name="resolvedPath" type="string" required="true"
			hint="Resolved path to the asset." />
		
		<!--- Most file systems are case sensitive so the path should not be UCase first --->
		<cfset var assetPathHash = Hash(arguments.resolvedPath) />
		
		<cfif NOT StructKeyExists(request, "_MachIIHTMLHelper_HTMLHeadElementPaths")>
			<cfset request._MachIIHTMLHelper_HTMLHeadElementPaths = StructNew() />
		</cfif>
		
		<cfif StructKeyExists(request._MachIIHTMLHelper_HTMLHeadElementPaths, assetPathHash)>
			<cfreturn true />
		<cfelse>
			<cfset request._MachIIHTMLHelper_HTMLHeadElementPaths[assetPathHash] = arguments.resolvedPath />
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="resolveMimeTypeAndGetData" access="private" returntype="struct" output="false"
		hint="Resolves if the passed MIME type is a shortcut and defaults the passed MIME type if not.">
		<cfargument name="type" type="string" required="true"
			hint="The MIME type shortcut or full MIME type." />
		
		<cfset var mimeShortcutMap = getMimeShortcutMap() />
		<cfset var result = StructNew() />
		
		<cfif StructKeyExists(mimeShortcutMap, arguments.type)>
			<cfset result = mimeShortcutMap[arguments.type] />
		<cfelse>
			<cfset result.type = arguments.type />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getAssetPackageByName" access="private" returntype="array" output="false"
		hint="Gets a asset package by name. Checks parent if available.">
		<cfargument name="assetPackageName" type="string" required="true"
			hint="The asset package name to get. Checks parent if parent is available." />
		
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
	
	<cffunction name="createAssetPathHash" access="private" returntype="string" output="false"
		hint="Creates an asset path hash which can be used as a struct key.">
		<cfargument name="resolvedPath" type="string" required="true"
			hint="A full web-root resolved asset path." />
		<cfreturn Hash(arguments.resolvedPath) />
	</cffunction>
	
	<cffunction name="buildAssetPath" access="private" returntype="string" output="false"
		hint="Builds a fully resolved asset path from a raw path and type.">
		<cfargument name="assetType" type="string" required="true"
			hint="The asset type for passed asset path. Takes 'img', 'css' or 'js'." />
		<cfargument name="assetPath" type="string" required="true"
			hint="An unresolved asset path to resolve to a full web-root path." />
		
		<cfset var path = arguments.assetPath />
		
		<!--- Don't do resolution on assets that are dynamically served --->
		<cfif NOT path.startsWith(getProperty("urlBase"))>
			<!--- Get path if the asset path is not a full path from webroot --->
			<cfif NOT path.startsWith("/")>
				<cfif arguments.assetType EQ "js">
					<cfset path = getJsBasePath() & "/" & path />
				<cfelseif arguments.assetType EQ "css">
					<cfset path = getCssBasePath() & "/" & path />
				<cfelseif arguments.assetType EQ "img">
					<cfset path = getImgBasePath() & "/" & path />
				</cfif>
			</cfif>
			
			<!--- Append the file extension if not defined --->
			<cfif arguments.assetType NEQ "img">
				<cfset path = appendFileExtension(arguments.assetType, path) />
			</cfif>
		</cfif>
		
		<cfreturn path />
	</cffunction>
	
	<cffunction name="appendFileExtension" access="public" returntype="string" output="false"
		hint="Appends the default file extension if no file extension is present and is safe for paths with '.' in the file name.">
		<cfargument name="assetType" type="string" required="true"
			hint="The asset type ('js', 'css')." />
		<cfargument name="assetPath" type="string" required="true"
			hint="The asset path to append the file extension to." />
		
		<cfset var file = ListLast(arguments.assetPath, "/") />
		<cfset var fileExt = ListLast(arguments.assetPath, ".") />
		
		<cfif fileExt NEQ arguments.assetType AND fileExt NEQ "cfm">
			<cfreturn arguments.assetPath & "." & arguments.assetType />
		<cfelse>
			<cfreturn arguments.assetPath />
		</cfif>
	</cffunction>
		
	<cffunction name="fetchAssetTimestamp" access="private" returntype="numeric" output="false"
		hint="Fetches the asset timestamp (seconds from epoch) from the passed target asset path.">
		<cfargument name="resolvedPath" type="string" required="true"
			hint="This is the full resolved asset path from the webroot." />
		
		<cfset var fullPath = getWebrootBasePath() & "/" & arguments.resolvedPath />
		<cfset var directoryResults = "" />
		
		<cfdirectory name="directoryResults"
			action="list" 
			directory="#GetDirectoryFromPath(fullPath)#" 
			filter="#GetFileFromPath(fullPath)#" />

		<!--- Assert the file was found --->
		<cfset getAssert().isTrue(directoryResults.recordcount EQ 1
				, "Cannot fetch a timestamp for an asset because it cannot be located. Check for your asset path."
				, "Asset path: '#fullPath#'") />
		
		<!--- Conver current time to UTC because epoch is essentially UTC --->
		<cfreturn DateDiff("s", DateConvert("local2Utc", CreateDatetime(1970, 1, 1, 0, 0, 0)), DateConvert("local2Utc", directoryResults.dateLastModified)) />
	</cffunction>
	
	<cffunction name="getImageDimensions" access="private" returntype="struct" output="false"
		hint="Gets image dimensions for GIF, PNG and JPG file types.">
		<cfargument name="path" type="string" required="true"
			hint="A unresolved path to a web accessible image file. Shortcut paths are allowed, however file name extensions cannot be omitted and must be specified." />
		
		<cfset var fullPath = Replace(getWebrootBasePath() & "/" & buildAssetPath("img", arguments.path), "//", "/", "all") />
		<cfset var image = "" />
		<cfset var dimensions = StructNew() />
		
		<cftry>
			<cfset image = variables.AWT_TOOLKIT.getImage(fullPath) />

			<!--- Flush the image metadata --->
			<cfset image.flush() />
		
			<cfset dimensions.width = image.getWidth() />
			<cfset dimensions.height = image.getHeight() />
			
			<cfcatch type="any">
				<cfthrow type="MachII.properties.HtmlHelperProperty.ImageDimensionException"
					message="Unable to read image dimensions on asset path '#fullPath#'. Ensure image is of type GIF, PNG or JPG."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>
		
		<cfreturn dimensions />
	</cffunction>
	
	<cffunction name="mock_getImageDimensions" access="private" returntype="struct" output="false"
		hint="This mock function returns a struct with no image dimensions. This is used to dynamically replace getImageDimension() when the java.awt.* package is not supported by the host syste.">
		
		<cfset var dimensions = StructNew() />
		
		<cfset dimensions.width = "" />
		<cfset dimensions.height = "" />
		
		<cfreturn dimensions />	
	</cffunction>
	
	<cffunction name="cleanupContent" access="private" returntype="string" output="false"
		hint="Cleans up content text by removing undesireable control characters.">
		<cfargument name="content" type="string" required="true"
			hint="The content to clean up." />
		<cfreturn REReplaceNoCase(arguments.content, variables.CLEANUP_CONTROL_CHARACTERS_REGEX, "", "ALL") />
	</cffunction>

	<cffunction name="decidedCacheAssetPathsEnabled" access="private" returntype="boolean" output="false"
		hint="Decides if the asset path caching is enabled.">
		<cfargument name="cacheAssetPathsEnabled" type="any" required="true"
			hint="This argument must be boolean or a struct of environment names / groups." />
		
		<cfset var result = false />
		
		<cfset getAssert().isTrue(IsBoolean(arguments.cacheAssetPathsEnabled) OR IsStruct(arguments.cacheAssetPathsEnabled)
				, "The 'cacheAssetPathsEnabled' parameter for 'HtmlHelperProperty' must be boolean or a struct of environment names / groups.") />
		
		<!--- Load cache asset paths enabled since this is a simple value (no environment names / groups) --->
		<cfif IsBoolean(arguments.cacheAssetPathsEnabled)>
			<cfset result = arguments.cacheAssetPathsEnabled />
		<!--- Load cache asset paths enabled enabled by environment names / groups --->
		<cfelse>
			<cfset result = resolveValueByEnvironment(arguments.cacheAssetPathsEnabled, false) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="ensureAndDetectAssetPackageType" access="private" returntype="string" output="false"
		hint="Ensures all paths in a list are of the same type (either JS or CSS) and returns the asset type or "" if no match.">
		<cfargument name="paths" type="any" required="true"
			hint="A list or array assets paths to ensure and detect asset types for." />
		
		<cfset var fileName = "" />
		<cfset var assetType = "" />
		<cfset var currentAssetType = "" />
		<cfset var i = 0 />
		
		<cfif NOT IsArray(arguments.paths)>
			<cfset arguments.paths = ListToArray(getUtils().trimList(arguments.paths)) />
		</cfif>
		
		<!--- Check the paths for asset type --->
		<cfloop from="1" to="#ArrayLen(arguments.paths)#" index="i">
			<!--- We need the file name only and strip out any query string (however it's get confused by SES paths) --->
			<cfset fileName = GetFileFromPath(arguments.paths[i]) />
			<cfset fileName = ListFirst(fileName, "?") />
			<cfset currentAssetType = ListLast(fileName, ".") />

			<!--- We have nothing to match against yet on the first interation --->
			<cfif assetType EQ "">
				<cfset assetType = currentAssetType />
			<!---
				If the asset type differs from the previous or if the asset 
				type is ambigous such as .cfm then break by returning "" for no match
			--->
			<cfelseif assetType NEQ currentAssetType 
				OR NOT ListFindNoCase("js,css", currentAssetType)>
				<cfreturn "" />
			</cfif>
		</cfloop>
		
		<cfreturn assetType />
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

	<cffunction name="setCacheAssetPaths" access="private" returntype="void" output="false"
		hint="Sets if cache asset paths is enabled. Accepts boolean or an environemnt struct of booleans.">
		<cfargument name="cacheAssetPaths" type="any" required="true" />
		
		<cftry>
			<cfset variables.cacheAssetPaths = decidedCacheAssetPathsEnabled(arguments.cacheAssetPaths) />
			<cfcatch type="MachII.util.IllegalArgument">
				<cfthrow type="MachII.properties.HtmlHelperProperty.InvalidEnvironmentConfiguration"
					message="This misconfiguration error is defined in the property-wide 'cacheAssetPaths' parameter in the HTML Helper property in module '#getAppManager().getModuleName()#'."
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>			
		</cftry>
	</cffunction>
	<cffunction name="getCacheAssetPaths" access="public" returntype="boolean" output="false">
		<cfreturn variables.cacheAssetPaths />
	</cffunction>

	<cffunction name="setWebrootBasePath" access="private" returntype="void" output="false">
		<cfargument name="webrootBasePath" type="string" required="true" />
		
		<!--- Convert all "\" to "/" (Windows) --->
		<cfset arguments.webrootBasePath = Replace(arguments.webrootBasePath, "\", "/", "all") />
		
		<!--- Some CFML engines append a trailing "/" so remove--->
		<cfif arguments.webrootBasePath.endsWith("/")>
			<cfset arguments.webrootBasePath = Left(arguments.webrootBasePath, Len(arguments.webrootBasePath) - 1) />
		</cfif>
		
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
	
	<cffunction name="setImgBasePath" access="private" returntype="void" output="false">
		<cfargument name="imgBasePath" type="string" required="true" />
		<cfset variables.imgBasePath = arguments.imgBasePath />
	</cffunction>
	<cffunction name="getImgBasePath" access="public" returntype="string" output="false">
		<cfreturn variables.imgBasePath />
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
	
	<cffunction name="setDocTypeReferenceMap" access="private" returntype="void" output="false">
		<cfargument name="docTypeReferenceMap" type="struct" required="true" />
		<cfset variables.docTypeReferenceMap = arguments.docTypeReferenceMap />
	</cffunction>
	<cffunction name="getDocTypeReferenceMap" access="public" returntype="struct" output="false">
		<cfreturn variables.docTypeReferenceMap />
	</cffunction>
	
	<cffunction name="setAssetPackages" access="private" returntype="void" output="false"
		hint="Sets the asset packages into the property manager.">
		<cfargument name="assetPackages" type="struct" required="true" />
		<cfset setProperty(variables.ASSET_PACKAGES_PROPERTY_NAME, arguments.assetPackages) />
	</cffunction>
	<cffunction name="getAssetPackages" access="public" returntype="struct" output="false"
		hint="Gets the asset pacakages from the property manager.">
		<cfreturn getProperty(variables.ASSET_PACKAGES_PROPERTY_NAME) />
	</cffunction>
	<cffunction name="getAssetParentPackages" access="public" returntype="struct" output="false"
		hint="Gets the asset pacakages from the parent property manager.">
		<cfif getAppManager().inModule()>
			<cfreturn getPropertyManager().getParent().getProperty(variables.ASSET_PACKAGES_PROPERTY_NAME, StructNew()) />
		<cfelse>
			<cfreturn StructNew() />
		</cfif>
	</cffunction>

</cfcomponent>