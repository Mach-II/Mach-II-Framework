<cfsetting enablecfoutputonly="true" />
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
Author: Matt Woodward (matt@mach-ii.com)
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
	<cfset setupTag("checkboxgroup", true) />

	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />

	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.checkValue" type="string" 
			default="#resolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
		<!--- setting this to type="any" because on OpenBD at least, 
				if you do pass in a checkValue attribute and it isn't a 
				string, this blows up with an "attributes.checkValue is 
				not of type String" error --->
		<cfparam name="attributes.checkValue" type="any" 
			default="" />
	</cfif>
	
	<!--- Set optional attributes --->
	<cfparam name="attributes.name" type="string" 
		default="#attributes.path#" />
	<cfparam name="attributes.delimiter" type="string"
		default="," />
	<cfparam name="attributes.valueCol" type="string"
		default="value" />
	<cfparam name="attributes.labelCol" type="string"
		default="label" />

<cfelse>
	<cfset originalGeneratedContent = thisTag.GeneratedContent />
	<cfset thisTag.GeneratedContent = "" />

	<!--- Create a crazy outbuffer struct  so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />
	
	<cfif not StructKeyExists(attributes, "items")>
		<cfthrow type="MachII.customtags.form.checkboxgroup" 
					message="Items Attribute Required" 
					detail="The checkbox group form tag requires an 'items' attribute." />
	</cfif>
	
	<cfif not StructKeyExists(attributes, "labels") 
			and (IsSimpleValue(attributes.items) 
				or (IsArray(attributes.items) 
					and IsSimpleValue(attributes.items[1])))>
		<cfset attributes.labels = attributes.items />
	</cfif>
	
	<!--- checkValue can be a list, array, or struct, but ultimately 
			we'll use a list to do the comparisons as we build the output --->
	<cfset checkValues = "" />
	
	<cfif StructKeyExists(attributes, "checkValue")>
		<cfif IsSimpleValue(attributes.checkValue)>
			<cfset checkValues = attributes.checkValue />
		<cfelseif IsArray(attributes.checkValue)>
			<cfif attributes.checkValue.getDimension() eq 1>
				<cfif IsSimpleValue(attributes.checkValue[1])>
					<cfloop index="i" from="1" to="#ArrayLen(attributes.checkValue)#">
						<cfset checkValues = ListAppend(checkValues, attributes.checkValue[i]) />
					</cfloop>
				<cfelseif IsStruct(attributes.checkValue[1])>
					<cfloop index="i" from="1" to="#ArrayLen(attributes.checkValue)#">
						<cfset checkValues = ListAppend(checkValues, attributes.checkValue[i].value) />
					</cfloop>
				<cfelse>
					<cfthrow type="MachII.customtags.form.checkboxgroup" 
							message="Unsupported Data Type in Array" 
							detail="The checkbox group form tag only supports simple values or structs as array elements." />
				</cfif>
			<cfelse>
				<cfthrow type="MachII.customtags.form.checkboxgroup" 
						message="Unsupported Number of Array Dimensions in Checkbox Group Tag" 
						detail="The checkbox group form tag only supports arrays of 1 dimension. Array values may be either simple values or structs. The array you passed to the tag as the checkValue attribute is #attributes.items.getDimension()# dimensions." />
			</cfif>
		<cfelseif IsStruct(attributes.checkValue)>
			<cfloop collection="#attributes.checkValue#" item="item">
				<cfif StructFind(attributes.checkValue, item)>
					<cfset checkValues = ListAppend(checkValues, item) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfthrow type="MachII.customtags.form.checkboxgroup" 
					message="Unsupported Data Type for Check Value Attribute" 
					detail="The checkbox group form tag only supports lists, one-dimensional arrays, and structs for the check value attribute." />
		</cfif>
	</cfif>
	
	<!--- doing this here so we can add checked to the attributes 
			being passed to the checkbox custom tag as needed instead 
			of having to repeat the entire tag in conditionals --->
	<cfset checkboxAttributes = StructCopy(attributes) />
	<cfset checkboxAttributes.checkValue = checkValues />
	
	<cfif IsSimpleValue(attributes.items)>
		<cfloop index="i" from="1" to="#ListLen(attributes.items, attributes.delimiter)#">
			<cfset checkboxAttributes.value = ListGetAt(attributes.items, i, attributes.delimiter) />
			
			<form:checkbox attributeCollection="#checkboxAttributes#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
			
			<cfset finalOutput = Replace(originalGeneratedContent, "${output.checkbox}", variables.outputBuffer.content) />
			<cfset finalOutput = Replace(finalOutput, "${output.label}", ListGetAt(attributes.labels, i, attributes.delimiter))/>
			<cfset finalOutput = Replace(finalOutput, "${output.id}", attributes.name & "_" & createCleanId(ListGetAt(attributes.items, i, attributes.delimiter))) />
			
			<cfset variables.outputBuffer.content = "" />
			
			<cfoutput>#finalOutput#</cfoutput>
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfif attributes.items.getDimension() eq 1>
			<cfif IsSimpleValue(attributes.items[1])>
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<cfset checkboxAttributes.value = attributes.items[i] />
					
					<form:checkbox attributeCollection="#checkboxAttributes#" 
						output="true" 
						outputBuffer="#variables.outputBuffer#" />
					
					<cfset finalOutput = Replace(originalGeneratedContent, "${output.checkbox}", variables.outputBuffer.content) />
					<cfset finalOutput = Replace(finalOutput, "${output.label}", attributes.labels[i]) />
					<cfset finalOutput = Replace(finalOutput, "${output.id}", attributes.name & "_" & createCleanId(attributes.items[i])) />
					
					<cfset variables.outputBuffer.content = "" />
					
					<cfoutput>#finalOutput#</cfoutput>
				</cfloop>
			<cfelseif IsStruct(attributes.items[1])>
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<cfset checkboxAttributes.value = attributes.items[i].value />
					
					<form:checkbox attributeCollection="#checkboxAttributes#" 
						output="true" 
						outputBuffer="#variables.outputBuffer#" />

					<cfset finalOutput = Replace(originalGeneratedContent, "${output.checkbox}", variables.outputBuffer.content) />
					<cfset finalOutput = Replace(finalOutput, "${output.label}", attributes.items[i].label) />
					<cfset finalOutput = Replace(finalOutput, "${output.id}", attributes.name & "_" & createCleanId(attributes.items[i].value)) />
					
					<cfset variables.outputBuffer.content = "" />
					
					<cfoutput>#finalOutput#</cfoutput>
				</cfloop>
				<cfelse>
					<cfthrow type="MachII.customtags.form.checkboxgroup" 
							message="Unsupported Data Type in Array" 
							detail="The checkbox group form tag only supports simple values or structs as array elements." />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.customtags.form.checkboxgroup" 
					message="Unsupported Number of Array Dimensions in Checkbox Group Tag" 
					detail="The checkbox group form tag only supports arrays of 1 dimension. Array values may be either simple values or structs. The array you passed to the tag is #attributes.items.getDimension()# dimensions." />
		</cfif>
	<cfelseif IsStruct(attributes.items)>
		<cfset sortedKeys = StructSort(attributes.items, "text") />
		
		<!--- struct key is value, struct value is label --->
		<cfloop index="i" from="1" to="#ArrayLen(sortedKeys)#">
			<cfset checkboxAttributes.value = sortedKeys[i] />
			
			<form:checkbox attributeCollection="#checkboxAttributes#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
			
			<cfset finalOutput = Replace(originalGeneratedContent, "${output.checkbox}", variables.outputBuffer.content) />
			<cfset finalOutput = Replace(finalOutput, "${output.label}", attributes.items[sortedKeys[i]]) />
			<cfset finalOutput = Replace(finalOutput, "${output.id}", attributes.name & "_" & createCleanId(sortedKeys[i])) />
			
			<cfset variables.outputBuffer.content = "" />
			
			<cfoutput>#finalOutput#</cfoutput>
		</cfloop>
	<cfelseif IsQuery(attributes.items)>
		<cfloop query="attributes.items">
			<cfset checkboxAttributes.value = attributes.items[attributes.valueCol][attributes.items.CurrentRow] />
			
			<form:checkbox attributeCollection="#checkboxAttributes#" 
				output="true" 
				outputBuffer="#variables.outputBuffer#" />
			
			<cfset finalOutput = Replace(originalGeneratedContent, "${output.checkbox}", variables.outputBuffer.content) />
			<cfset finalOutput = Replace(finalOutput, "${output.label}", attributes.items[attributes.labelCol][attributes.items.CurrentRow]) />
			<cfset finalOutput = Replace(finalOutput, "${output.id}", attributes.name & "_" & createCleanId(attributes.items[attributes.valueCol][attributes.items.CurrentRow])) />
			
			<cfset variables.outputBuffer.content = "" />
			
			<cfoutput>#finalOutput#</cfoutput>
		</cfloop>
	<cfelse>
		<cfthrow type="MachII.customtags.form.checkboxgroup" 
					message="Unsupported Data Type" 
					detail="The checkbox group form tag only supports lists, arrays, structs, and queries." />
	</cfif>

	<cfif attributes.output>
		<cfset thisTag.GeneratedContent = "" />
		<cfset appendGeneratedContentToBuffer(variables.outputBuffer.content, attributes.outputBuffer) />
	<cfelse>
		<cfset thisTag.GeneratedContent = variables.outputBuffer.content />
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />