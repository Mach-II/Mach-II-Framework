<cfsetting enablecfoutputonly="true" />
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
--->
<cfif thisTag.ExecutionMode IS "start">
	<cfsilent>
		<!--- Check for required attributes --->
		<cfif NOT StructKeyExists(variables.attributes, "path") AND NOT StructKeyExists(attributes, "name")>
			<cfthrow type="MachII.FormLib.input.noPath"
				message="This tag must have an attribute named 'path' if you do not specify a 'name'." />
		</cfif>

		<!--- Set defaults --->
		<cfparam name="attributes.value" type="string" default="" />
		
		<!--- Resolve path --->
		<cfif StructKeyExists(attributes, "path")>
			<cfset variables.bindResolver = CreateObject("component", "cfcs.BindResolver").init() />
			<cfparam name="attributes.name" type="string" default="#variables.bindResolver.getNameFromPath(attributes.path)#" />
		</cfif>
		
		<!--- Create a tag writer and set atrributes--->
		<cfset variables.tagWriter = CreateObject("component", "cfcs.TagWriter").init("textarea", false) />
		<cfset variables.tagWriter.setAttribute("name", attributes.name) />

		<cfif StructKeyExists(attributes, "id")>
			<cfset variables.tagWriter.setAttribute("id", attributes.id) />
		<cfelse>
			<cfset variables.tagWriter.setAttribute("id", attributes.name) />
		</cfif>
		<cfif StructKeyExists(attributes, "rows")>
			<cfset variables.tagWriter.setAttribute("rows", attributes.rows) />
		</cfif>
		<cfif StructKeyExists(attributes, "cols")>
			<cfset variables.tagWriter.setAttribute("cols", attributes.cols) />
		</cfif>
		<cfif StructKeyExists(attributes, "onKeyUp")>
			<cfset variables.tagWriter.setAttribute("onKeyUp", attributes.onKeyUp) />
		</cfif>
		<cfif StructKeyExists(attributes, "onKeyDown")>
			<cfset variables.tagWriter.setAttribute("onKeyDown", attributes.onKeyDown) />
		</cfif>
		<cfif StructKeyExists(attributes, "style")>
			<cfset variables.tagWriter.setAttribute("style", attributes.style) />
		</cfif>
		<cfif StructKeyExists(attributes, "class")>
			<cfset variables.tagWriter.setAttribute("class", attributes.class) />
		</cfif>s
	</cfsilent>
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
<cfelse>

	<!--- Resolve path --->
	<cfif StructKeyExists(attributes, "path")>
		<cfset thisTag.GeneratedContent = variables.bindResolver.resolvePath(attributes.path) />
	</cfif>
	
	<cfset variables.tagWriter.setContent(thisTag.GeneratedContent) />
	<cfoutput>#variables.tagWriter.doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />