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
	<cfparam name="attributes.valueKey" type="string"
		default="value" />
	<cfparam name="attributes.labelKey" type="string"
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
		<cfif attributes.items.getDimension() EQ 1>
			<!--- need to check to see if this may be an array of structs --->
			<cfif IsSimpleValue(attributes.items[1])>
				<!--- this is an array of simple values, proceed as needed --->
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<form:option value="#Trim(attributes.items[i])#" 
						output="true" 
						outputBuffer="#variables.outputBuffer#" />
				</cfloop>
			<cfelseif IsStruct(attributes.items[1])>
				<!--- each array node contains a struct of elements, determine if the proper struct keys exist --->
				<cfif StructKeyExists(attributes.items[1], attributes.valueKey) AND StructKeyExists(attributes.items[1], attributes.labelKey)>
					<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
						<form:option value="#attributes.items[i][attributes.valueKey]#" 
							label="#attributes.items[i][attributes.labelKey]#" 
							output="true" 
							outputBuffer="#variables.outputBuffer#" />
					</cfloop>
				<cfelse>
					<!--- either the valueCol or lableCol attributes were not found in the structure, throw an error --->
					<cfthrow type="MachII.customtags.form.options" 
							message="Missing struct key values" 
							detail="The options form tag supports an array of struct elements, however the valueKey and labelKey attributes do not match the struct keys contained in the first array element." />
				</cfif>
			<cfelse>
				<cfthrow type="MachII.customtags.form.options" 
						message="Unsupported Data Type in Array" 
						detail="The options form tag only supports simple values or structs as array elements." />
			</cfif>
		<cfelse>
			<!--- only single dimension arrays are support, throw an exception for the multi-dimensional array passed --->
			<cfthrow type="MachII.customtags.form.options" 
					message="Unsupported Number of Array Dimensions in Options Tag" 
					detail="The options form tag only supports arrays of 1 dimension. Array values may be either simple values or structs. The array you passed to the tag as the items attribute is #attributes.items.getDimension()# dimensions." />
		</cfif>
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