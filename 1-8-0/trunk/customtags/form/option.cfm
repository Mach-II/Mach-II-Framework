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
<!--- This tag requires an end tag --->
<cfif NOT thisTag.hasEndTag>
	<cfthrow type="MachII.FormLib.option.noEndTag"
		message="This tag must have an end tag or be self closing." />
</cfif>

<cfif thisTag.ExecutionMode IS "end">
	<!--- Check for required attributes --->
	<cfif NOT StructKeyExists(attributes, "value") AND NOT StructKeyExists(attributes, "items")>
		<cfthrow type="MachII.FormLib.checkbox.invalidAttributes"
			message="This tag must have an attribute named 'value' or 'items'." />
	</cfif>

	<!--- Set defaults --->
	<cfif StructKeyExists(attributes, "value")>
		<cfparam name="attributes.label" type="string" default="#attributes.value#" />
		<cfset attributes.items[attributes.value] = attributes.label />
	</cfif>

	<!--- Set data --->
	<cfset variables.checkValue = request._MachIIFormLib.selectCheckValue />

	<cfif IsStruct(attributes.items)>
		<cfset variables.itemOrder = StructSort(attributes.items, "text") />
		
		<cfloop from="1" to="#ArrayLen(variables.itemOrder)#" index="i">
			<!--- Create a tag writer and set atrributes--->
			<cfset variables.tagWriter = CreateObject("component", "helper.TagWriter").init("option", false) />
			<cfif StructKeyExists(attributes, "onClick")>
				<cfset variables.tagWriter.setAttribute("onclick", attributes.onClick) />
			</cfif>
			<cfif StructKeyExists(attributes, "style")>
				<cfset variables.tagWriter.setAttribute("style", attributes.style) />
			</cfif>
			<cfset variables.tagWriter.setAttribute("value", variables.itemOrder[i]) />
	
			<cfif variables.checkValue EQ variables.itemOrder[i]>
				<cfset variables.tagWriter.setAttribute("selected", "selected") />
			</cfif>
	
			<cfif NOT Len(thisTag.GeneratedContent)>
				<cfset variables.tagWriter.setContent(attributes.items[variables.itemOrder[i]]) />
			<cfelse>
				<cfset variables.tagWriter.setContent(thisTag.GeneratedContent) />
				<cfset thisTag.GeneratedContent = "" />
			</cfif>
			
			<cfoutput>#variables.tagWriter.doStartTag()##variables.tagWriter.doEndTag()#</cfoutput>
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
			<!--- Create a tag writer and set atrributes--->
			<cfset variables.tagWriter = CreateObject("component", "helper.TagWriter").init("option", false) />
			<cfif StructKeyExists(attributes, "onClick")>
				<cfset variables.tagWriter.setAttribute("onclick", attributes.onClick) />
			</cfif>
			<cfif StructKeyExists(attributes, "style")>
				<cfset variables.tagWriter.setAttribute("style", attributes.style) />
			</cfif>
			<cfset variables.tagWriter.setAttribute("value", i) />
	
			<cfif variables.checkValue EQ attributes.items[i]>
				<cfset variables.tagWriter.setAttribute("selected", "selected") />
			</cfif>
	
			<cfif NOT Len(thisTag.GeneratedContent)>
				<cfset variables.tagWriter.setContent(attributes.items[i]) />
			<cfelse>
				<cfset variables.tagWriter.setContent(thisTag.GeneratedContent) />
				<cfset thisTag.GeneratedContent = "" />
			</cfif>
			
			<cfoutput>#variables.tagWriter.doStartTag()##variables.tagWriter.doEndTag()#</cfoutput>
		</cfloop>		
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />