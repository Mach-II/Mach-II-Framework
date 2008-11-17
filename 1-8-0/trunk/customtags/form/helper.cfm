<cfsilent>
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
$Id: checkbox.cfm 1159 2008-11-16 01:53:16Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Helper functions for the Mach-II form tag library.

STANDARD FORM ATTRIBUTES
id			= AUTOMATIC|[string]
class		= [string]
style		= [string]
dir			= ltr|rtl (Sets the text direction)
lang		= [string] (Sets the language code)

EVENT ATTRIBUTES
tabIndex	= [numeric]
accessKey	= [string]
onFocus		= [string]
onBlur		= [string]
onSelect	= [string]
onChange	= [string]
onClick		= [string]
onDblClick	= [string]
onMouseDown	= [string]
onMouseUp	= [string]
onMouseOver	= [string]
onMouseMove	= [string]
onMouseOut	= [string]
onKeyPress	= [string]
onKeyDown	= [string]
onKeyUp		= [string]
--->
</cfsilent>

<cffunction name="setupFormTag" access="public" returntype="void" output="false"
	hint="Sets up the form tag for use.">
	
	<cfset variables.tagData.tagName = "form" />
	<cfset variables.tagData.hasEndTag = true />
	
	<cfset request._MachIIFormLib.bind = request.event />
	
	<cfset variables.tagWriter = CreateObject("component", "MachII.customtags.form.cfcs.TagWriter").init(variables.tagData.tagName, variables.tagData.hasEndTag) />
	<cfset attributes.bindResolver = CreateObject("component", "MachII.customtags.form.cfcs.BindResolver").init() />
	
	<!--- Check for required attributes --->
	<cfif NOT StructKeyExists(attributes, "actionEvent")>
		<cfthrow type="MachII.customtags.form.form.noActionEvent"
			message="The form tag must have an attribute named 'actionEvent'." />
	</cfif>
	
	<cfif StructKeyExists(attributes, "bind") AND IsSimpleValue(attributes.bind)>
		<cfif request.event.isArgDefined(ListFirst(attributes.bind, "."))>
			<cfset request._MachIIFormLib.bind = attributes.bindResolver.resolvePath(attributes.bind) />
		<cfelse>
			<cfthrow type="MachII.customtags.form.form.noBindInEvent"
				message="A bind named '#attributes.bind#' is not available the current event object." />
		</cfif>
	</cfif>
	
	<cfif NOT thisTag.hasEndTag>
		<cfthrow type="MachII.customtags.form.#arguments.tagName#"
			message="The #arguments.tagName# must have an end tag." />
	</cfif>
</cffunction>

<cffunction name="setupTag" access="public" returntype="void" output="false"
	hint="Sets up a form element tag for use.">
	<cfargument name="tagName" type="string" required="true" />
	<cfargument name="hasEndTag" type="boolean" required="true" />
	
	<cfset variables.tagData.tagName = arguments.tagName />
	<cfset variables.tagData.hasEndTag = arguments.hasEndTag />
	
	<cfset variables.tagWriter = CreateObject("component", "MachII.customtags.form.cfcs.TagWriter").init(variables.tagData.tagName, variables.tagData.hasEndTag) />
	<cfset variables.bindResolver = getBaseTagData("cf_form").attributes.bindResolver />
	
	<cfif arguments.hasEndTag AND NOT thisTag.hasEndTag>
		<cfthrow type="MachII.customtags.form.#variables.tagData.tagName#.endTag"
			message="The #variables.tagData.tagName# must have an end tag." />
	</cfif>
</cffunction>

<cffunction name="ensurePathOrName" acces="public" returntype="void" output="false"
	hint="Ensures a path or name is available in the attributes.">
	<cfif NOT StructKeyExists(attributes, "path") 
		AND NOT StructKeyExists(attributes, "name")>
		<cfthrow type="MachII.customtags.form.#variables.tagData.tagName#.noPath"
			message="This tag must have an attribute named 'path' or 'name' or both." />
	</cfif>
</cffunction>

<cffunction name="setAttribute" access="public" returntype="void" output="false"
	hint="Adds an attribute by name if defined.">
	<cfargument name="attributeName" type="string" required="true" />
	<cfargument name="value" type="string" required="false" />
	
	<cfif NOT StructKeyExists(arguments, "value")>
		<cfset arguments.value = attributes[arguments.attributeName] />
	</cfif>

	<cfset variables.tagWriter.setAttribute(arguments.attributeName, arguments.value) />
</cffunction>

<cffunction name="setAttributeIfDefined" access="public" returntype="void" output="false"
	hint="Adds an attribute by name if defined.">
	<cfargument name="attributeName" type="string" required="true" />
	<cfargument name="specialValue" type="string" required="false" />
	
	<cfif StructKeyExists(attributes, arguments.attributeName)>
		<cfif NOT StructKeyExists(arguments, "specialValue")>
			<cfset variables.tagWriter.setAttribute(arguments.attributeName, attributes[arguments.attributeName]) />
		<cfelse>
			<cfset variables.tagWriter.setAttribute(arguments.attributeName, arguments.specialValue) />
		</cfif>
	</cfif>
</cffunction>

<cffunction name="setStandardAttributes" access="public" returntype="void" output="false"
	hint="Adds standard attributes to the tag writer if defined.">

	<cfif StructKeyExists(attributes, "id")>
		<cfset variables.tagWriter.setAttribute("id", attributes.id) />
	</cfif>
	<cfif StructKeyExists(attributes, "class")>
		<cfset variables.tagWriter.setAttribute("class", attributes.class) />
	</cfif>
	<cfif StructKeyExists(attributes, "style")>
		<cfset variables.tagWriter.setAttribute("style", attributes.style) />
	</cfif>
	<cfif StructKeyExists(attributes, "dir")>
		<cfset variables.tagWriter.setAttribute("dir", attributes.dir) />
	</cfif>
	<cfif StructKeyExists(attributes, "lang")>
		<cfset variables.tagWriter.setAttribute("lang", attributes.lang) />
	</cfif>
</cffunction>

<cffunction name="setEventAttributes" access="public" returntype="void" output="false"
	hint="Adds event attributes to the tag writer if defined.">

	<cfif StructKeyExists(attributes, "tabIndex")>
		<cfset variables.tagWriter.setAttribute("tabIndex", attributes.tabIndex) />
	</cfif>
	<cfif StructKeyExists(attributes, "accessKey")>
		<cfset variables.tagWriter.setAttribute("accessKey", attributes.accessKey) />
	</cfif>
	<cfif StructKeyExists(attributes, "onFocus")>
		<cfset variables.tagWriter.setAttribute("onFocus", attributes.onFocus) />
	</cfif>
	<cfif StructKeyExists(attributes, "onBlur")>
		<cfset variables.tagWriter.setAttribute("onBlur", attributes.onBlur) />
	</cfif>
	<cfif StructKeyExists(attributes, "onSelect")>
		<cfset variables.tagWriter.setAttribute("onSelect", attributes.onSelect) />
	</cfif>
	<cfif StructKeyExists(attributes, "onChange")>
		<cfset variables.tagWriter.setAttribute("onChange", attributes.onChange) />
	</cfif>
	<cfif StructKeyExists(attributes, "onChange")>
		<cfset variables.tagWriter.setAttribute("onChange", attributes.onChange) />
	</cfif>
	<cfif StructKeyExists(attributes, "onDblClick")>
		<cfset variables.tagWriter.setAttribute("onDblClick", attributes.onDblClick) />
	</cfif>
	<cfif StructKeyExists(attributes, "onMouseDown")>
		<cfset variables.tagWriter.setAttribute("onMouseDown", attributes.onMouseDown) />
	</cfif>
	<cfif StructKeyExists(attributes, "onMouseUp")>
		<cfset variables.tagWriter.setAttribute("onMouseUp", attributes.onMouseUp) />
	</cfif>
	<cfif StructKeyExists(attributes, "onMouseOver")>
		<cfset variables.tagWriter.setAttribute("onMouseOver", attributes.onMouseOver) />
	</cfif>
	<cfif StructKeyExists(attributes, "onMouseMove")>
		<cfset variables.tagWriter.setAttribute("onMouseMove", attributes.onMouseMove) />
	</cfif>
	<cfif StructKeyExists(attributes, "onMouseOut")>
		<cfset variables.tagWriter.setAttribute("onMouseOut", attributes.onMouseOut) />
	</cfif>
	<cfif StructKeyExists(attributes, "onKeyPress")>
		<cfset variables.tagWriter.setAttribute("onKeyPress", attributes.onKeyPress) />
	</cfif>
	<cfif StructKeyExists(attributes, "onKeyDown")>
		<cfset variables.tagWriter.setAttribute("onKeyDown", attributes.onKeyDown) />
	</cfif>
	<cfif StructKeyExists(attributes, "onKeyUp")>
		<cfset variables.tagWriter.setAttribute("onKeyUp", attributes.onKeyUp) />
	</cfif>
</cffunction>