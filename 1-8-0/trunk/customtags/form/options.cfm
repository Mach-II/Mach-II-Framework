<cfsetting enablecfoutputonly="true" /><cfsilent>
<!---
License:
Copyright 2009 GreatBizTools, LLC

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
- REQUIRED ATTRIBUTES
	items		= [list]|[struct]|[query]|[array]
--->
<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("options", true) />
	
	<!--- Set optional attributes --->
	<cfparam name="attributes.delimiter" type="string"
		default="," />
	<cfparam name="attributes.valueCol" type="string"
		default="value" />
	<cfparam name="attributes.labelCol" type="string"
		default="label" />

<cfelse>
	<!---
		In order to keep whitespace down to a minimum, all cfsavecontent  
		must stay on a single line 
	--->
	
	<!--- Create a crazy outbuffer struct  so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />
	
	<cfif IsSimpleValue(attributes.items)>
		<cfloop list="#attributes.items#" index="i" delimiters="#attributes.delimiter#">
			<form:option value="#Trim(i)#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
		</cfloop>
	<cfelseif IsStruct(attributes.items)>
		<cfset variables.itemOrder = StructSort(attributes.items, "text") />
		<cfloop from="1" to="#ArrayLen(variables.itemOrder)#" index="i">
			<form:option value="#LCase(variables.itemOrder[i])#" 
				label="#attributes.items[variables.itemOrder[i]]#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
			<form:option value="#Trim(attributes.items[i])#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
		</cfloop>
	<cfelseif IsQuery(attributes.items)>
		<cfloop query="attributes.items">
			<form:option value="#attributes.items[attributes.valueCol][attributes.items.currentRow]#" 
				label="#attributes.items[attributes.labelCol][attributes.items.currentRow]#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
		</cfloop>
	<cfelse>
		<cfthrow type="MachII.customtags.form.#getTagType()#"
			message="The 'items' attribute for #getTagType()# custom tag does not support the passed datatype."
			detail="The 'items' attribute only supports lists, structs, queries and arrays." />
	</cfif>
	
	<cfif attributes.output>
		<cfset thisTag.GeneratedContent = "" />
		<cfset appendGeneratedContentToBuffer(variables.outputBuffer.content, attributes.outputBuffer) />
	<cfelse>
		<cfset thisTag.GeneratedContent = variables.outputBuffer.content />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />