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
		<cfparam name="attributes.showPassword" type="boolean" default="false" />
	
		<!--- Resolve path --->
		<cfif StructKeyExists(attributes, "path")>
			<cfset variables.bindResolver = CreateObject("component", "cfcs.BindResolver").init() />
			<cfif attributes.showPassword>
				<cfset attributes.value = variables.bindResolver.resolvePath(attributes.path) />
			</cfif>
			<cfparam name="attributes.name" type="string" default="#variables.bindResolver.getNameFromPath(attributes.path)#" />
		</cfif>
		
		<!--- Create a tag writer and set atrributes--->
		<cfset variables.tagWriter = CreateObject("component", "cfcs.TagWriter").init("input", true) />
		<cfset variables.tagWriter.setAttribute("type", "password") />
		<cfset variables.tagWriter.setAttribute("name", attributes.name) />
		<cfset variables.tagWriter.setAttribute("value", attributes.value) />
		<cfif StructKeyExists(attributes, "id")>
			<cfset variables.tagWriter.setAttribute("id", attributes.id) />
		<cfelse>
			<cfset variables.tagWriter.setAttribute("id", attributes.name) />
		</cfif>
		<cfif StructKeyExists(attributes, "size")>
			<cfset variables.tagWriter.setAttribute("size", attributes.size) />
		</cfif>
		<cfif StructKeyExists(attributes, "maxLength")>
			<cfset variables.tagWriter.setAttribute("maxLength", attributes.maxLength) />
		</cfif>
		<cfif StructKeyExists(attributes, "tabIndex")>
			<cfset variables.tagWriter.setAttribute("tabIndex", attributes.tabIndex) />
		</cfif>
		<cfif StructKeyExists(attributes, "onKeyUp")>
			<cfset variables.tagWriter.setAttribute("onKeyUp", attributes.onKeyUp) />
		</cfif>
		<cfif StructKeyExists(attributes, "rel")>
			<cfset variables.tagWriter.setAttribute("rel", attributes.rel) />
		</cfif>
		<cfif StructKeyExists(attributes, "style")>
			<cfset variables.tagWriter.setAttribute("style", attributes.style) />
		</cfif>
		<cfif StructKeyExists(attributes, "class")>
			<cfset variables.tagWriter.setAttribute("class", attributes.class) />
		</cfif>s
	</cfsilent>
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />