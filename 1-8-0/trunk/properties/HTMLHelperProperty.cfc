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
HTML related tags faster and less hassle to output. This includes
output doctypes, css and javascript links and HTML metadata.

Simple Configuration Usage:
<property name="html" type="MachII.properties.HTMLHelperProperty" />

Customized Configuration Usage:
<property name="html" type="MachII.properties.HTMLHelperProperty">
	<parameters>
		<parameter name="metaTitleSuffix" value=" - Mach-II" />
	</parameters>
</property>

The [metaTitleSuffix] parameter optionally and automatically appends 
the value of the parameter on the end value addMeta() method when setting 
a title. For example, calling addMeta("title", "Home") with the above example 
value of this parameter would result in '<title>Home - Mach-II</title>'. 
Useful to append a company or application name on to the end of every HTML title. 
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
	<cfset variables.mimeShortcutMap = StructNew() />
	<cfset variables.httpEquivReferenceMap = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<!--- Assert and set parameters --->
		<cfif isParameterDefined("metaTitleSuffix")>
			<cfset setMetaTitleSuffix(getParameter("metaTitleSuffix")) />
		</cfif>
		
		<!--- Build data --->
		<cfset buildMimeShortcutMap() />
		<cfset buildHttpEquivReferenceMap() />
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

		<cfset setHttpEquivReferenceMap(mimeShortcutMap) />
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
				<cfreturn '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"' />
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
	
	<cffunction name="addJavascript" access="public" returntype="string" output="false"
		hint="Return javascript files script code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="urls" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible paths to .js files.">
		<cfargument name="inline" type="boolean" required="false" default="true"
			hint="Indicates to output the HTML code inline (true) or place in HTML head (false).">
		
		<cfset var code = "" />
		<cfset var i = 0 />
		<cfset var log = getLog() />
		
		<!--- Explode the list to an array --->
		<cfif NOT IsArray(arguments.urls)>
 			<cfset arguments.urls = ListToArray(getUtils().trimList(arguments.urls)) />
		</cfif>

		<cfloop from="1" to="#ArrayLen(arguments.urls)#" index="i">
			<cfif arguments.inline OR
				(NOT arguments.inline AND appendHTMLHeadElementPathToWatchList("js", arguments.urls[i]))>
				<cfset code = code & '<script type="text/javascript" src="' & arguments.urls[i] & '"></script>' />
				<cfif ArrayLen(arguments.urls) NEQ i>
					<cfset code = code & Chr(13) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.inline) />
	</cffunction>
	
	<cffunction name="addCss" access="public" returntype="string" output="false"
		hint="Return css script code for inline use or in the HTML head. Does not duplicate file paths when adding to the HTML head.">
		<cfargument name="urls" type="any" required="true"
			hint="A single string, comma-delimited list or array of web accessible paths to .css files.">
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="inline" type="boolean" required="false" default="true"
			hint="Indicates to output the HTML code inline (true) or place in HTML head (false).">
		
		<cfset var code = "" />
		<cfset var attributesCode = "" />
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var log = getLog() />
		
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
			<cfif arguments.inline OR
				(NOT arguments.inline AND appendHTMLHeadElementPathToWatchList("css", arguments.urls[i]))>
				<cfset code = code & '<link type="text/css" href="' & arguments.urls[i] & '" rel="stylesheet"' & attributesCode />
				<cfif ArrayLen(arguments.urls) NEQ i>
					<cfset code = code & Chr(13) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn renderOrAppendToHead(code, arguments.inline) />
	</cffunction>
	
	<cffunction name="addLink" access="public" returntype="string" output="false"
		hint="Returns code for a link tag for inline use or in the HTML head.">
		<cfargument name="type" type="string" required="true"
			hint="The type of link. Supports type shortcuts 'icon', 'rss', 'atom' and 'html', otherwise a complete MIME type is required." />
		<cfargument name="url" type="any" required="true"
			hint="A the path to a web accessible location of the link file." />
		<cfargument name="attributes" type="any" required="false" default="#StructNew()#"
			hint="A struct or string (param1=value1|param2=value2) of attributes." />
		<cfargument name="inline" type="boolean" required="false" default="true"
			hint="Indicates to output the HTML code inline (true) or place in HTML head (false).">
		
		<cfset var mimeTypeData = resolveMimeTypeAndGetData(arguments.type) />
		<cfset var code = '<link href="' & arguments.url & '"' />
		<cfset var key = "" />
		
		<cfset StructAppend(getUtils().parseAttributesIntoStruct(arguments.attributes), resolveMimeTypeAndGetData(arguments.type)) />
		
		<cfloop collection="#arguments.attributes#" item="key">
			<cfset code = code & ' ' & LCase(key) & '="' & arguments.attributes[key] & '"' />
		</cfloop>
		
		<cfset code = code & ' />' & Chr(13) />
		
		<cfreturn renderOrAppendToHead(code, arguments.inline) />
	</cffunction>
	
	<cffunction name="addMeta" access="public" returntype="string" output="false"
		hint="Return meta tag code for inline use or in the HTML head.">
		<cfargument name="type" type="string" required="true"
			hint="The type of the meta tag (this method auto-selects if value is a meta type of 'http-equiv' or 'name')." />
		<cfargument name="content" type="string" required="true"
			hint="The content of the meta tag." />
		<cfargument name="inline" type="boolean" required="false" default="true"
			hint="Indicates to output the HTML code inline (true) or place in HTML head (false).">			
		
		<cfset var code = "" />
		<cfset var key = "" />
		
		<cfif arguments.type EQ "title">
			<cfset code = '<title>' & arguments.content & getMetaTitleSuffix() & '</title>' & Chr(13) />
		<cfelse>
			<cfif isHttpEquivMetaType(arguments.type)>
				<cfset code = '<meta http-equiv="' & arguments.type & '" content="' & arguments.content & '" />' & Chr(13) />
			<cfelse>
				<cfset code = '<meta name="' & arguments.type & '" content="' & arguments.content & '" />' & Chr(13) />
			</cfif>
		</cfif>
		
		<cfreturn renderOrAppendToHead(code, arguments.inline) />
	</cffunction>

	<!---
	PRIVATE FUNCTIONS
	--->
	<cffunction name="renderOrAppendToHead" access="private" returntype="string" output="false"
		hint="Renders the code or append to head.">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="inline" type="boolean" required="true" />

		<!--- Output the code inline or append to HTML head --->
		<cfif arguments.inline>
			<cfreturn arguments.code />
		<cfelse>
			<cfset getRequestHandler().getEventContext().addHTMLHeadElement(arguments.code) />
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="appendHTMLHeadElementPathToWatchList" access="private" returntype="boolean" output="false"
		hint="Appends a HTML head element to the watch list. Returns true if already on watch list and false if not currently on list">
		<cfargument name="type" type="string" required="true"
			hint="Type of HTML head element path (css or js)." />
		<cfargument name="path" type="string" required="true"
-			hint="Path to element." />
		
		<cfset var elementPathHash = Hash(UCase(arguments.type & "_" & arguments.path)) />
		<cfset var htmlHeadElementPaths = "" />
		
		<cfif NOT IsDefined("request._MachIIHTMLHelper_HTMLHeadElementPaths")>
			<cfset request["_MachIICacheHandler_MachIIHTMLHelper_HTMLHeadElementPaths"] = StructNew() />
		</cfif>
		
		<cfset htmlHeadElementPaths = request["_MachIICacheHandler_MachIIHTMLHelper_HTMLHeadElementPaths"] />
		
		<cfif StructKeyExists(htmlHeadElementPaths, "elementPathHash")>
			<cfreturn true />
		<cfelse>
			<cfset htmlHeadElementPaths[elementPathHash] = arguments />
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
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setMetaTitleSuffix" access="private" returntype="void" output="false">
		<cfargument name="metaTitleSuffix" type="string" required="true" />
		<cfset getAssert().hasText(getParameter("metaTitleSuffix")
				, "The value of 'metaTitleSuffix' must contain some text.") />
		<cfset variables.metaTitleSuffix = arguments.metaTitleSuffix />
	</cffunction>
	<cffunction name="getMetaTitleSuffix" access="public" returntype="string" output="false">
		<cfreturn variables.metaTitleSuffix />
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

</cfcomponent>