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
		<cfif NOT (NOT StructKeyExists(attributes, "name") AND NOT StructKeyExists(attributes, "value")) XOR NOT StructKeyExists(variables.attributes, "path")>
			<cfthrow type="MachII.FormLib.input.invalidAttributes"
				message="This tag must have an attribute named 'path' or the 'name and 'value' pair." />
		</cfif>

		<!--- Set defaults --->
		<cfparam name="attributes.name" type="string" default="" />
		<cfparam name="attributes.value" type="string" default="" />
	
		<!--- Resolve path --->
		<cfif StructKeyExists(attributes, "path")>
			<cfset variables.bindResolver = CreateObject("component", "cfcs.BindResolver").init() />
			<cfset attributes.value = variables.bindResolver.resolvePath(attributes.path) />
			<cfparam name="attributes.name" type="string" default="#variables.bindResolver.getNameFromPath(attributes.path)#" />
		</cfif>
		
		<!--- Create a tag writer and set atrributes--->
		<cfset variables.tagWriter = CreateObject("component", "cfcs.TagWriter").init("input", true) />
		<cfset variables.tagWriter.setAttribute("type", "hidden") />
		<cfset variables.tagWriter.setAttribute("name", attributes.name) />
		<cfset variables.tagWriter.setAttribute("value", attributes.value) />
	</cfsilent>
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />