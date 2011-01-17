<cfsetting enablecfoutputonly="true" /><cfsilent>
<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

Author: Matt Woodward (matt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.9.0

Notes:
- REQUIRED ATTRIBUTES
	items		= [list]|[struct]|[query]|[array]
--->

<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("radiogroup", true) />

	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	<cfset ensureByName("items") />

	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.checkValue" type="string"
			default="#wrapResolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
		<cfparam name="attributes.checkValue" type="string"
			default="" />
	</cfif>

	<!--- Set optional attributes --->
	<cfset attributes.name = resolveName() />
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
	<cfparam name="attributes.displayOrder" type="string"
		default="" />

<cfelse>
	<!--- Trim is used to control additional whitespace --->
	<cfset variables.originalGeneratedContent = ReplaceNoCase(Trim(thisTag.GeneratedContent), "${output.id}", "#attributes.name#_${output.id}", "all") />
	<cfset thisTag.GeneratedContent = "" />

	<!--- Create a crazy outbuffer struct so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />

	<cfif not StructKeyExists(attributes, "labels")
			and (IsSimpleValue(attributes.items)
				or (IsArray(attributes.items)
					and IsSimpleValue(attributes.items[1])))>
		<cfset attributes.labels = attributes.items />
	</cfif>

	<!---
		Create an option template because calling the options tag repeatedly
		on a huge number of items is exponentially slow
	--->
	<form:radio attributeCollection="#attributes#"
		value="${output.value}"
		id="${output.id}"
		ignoreFirstElementId="true"
		output="true"
		outputBuffer="#variables.outputBuffer#" />

	<!--- The line break is put here as to not reproduce it on each iteration therefore saving a small amount of clock cycles --->
	<cfset variables.radioTemplate = ReplaceNoCase(variables.outputBuffer.content & Chr(13), "${output.id}", "#attributes.name#_${output.id}", "all") />
	<cfset variables.outputBuffer.content = CreateObject("java", "java.lang.StringBuffer").init() />

	<cfif IsSimpleValue(attributes.items)>
		<cfloop index="i" from="1" to="#ListLen(attributes.items, attributes.delimiter)#">
			<cfset variables.value = ListGetAt(attributes.items, i, attributes.delimiter) />

			<cfif StructKeyExists(attributes, "checkValue") AND attributes.checkValue EQ variables.value>
				<cfset variables.finalOutput = ReplaceNoCase(variables.radioTemplate, "/>", ' checked="checked"/>') />
			<cfelse>
				<cfset variables.finalOutput = variables.radioTemplate />
			</cfif>
			
			<cfif i EQ 1>
				<cfset setFirstElementId(attributes.name & "_" & createCleanId(variables.value)) />
			</cfif>

			<cfset variables.finalOutput = ReplaceNoCase(variables.originalGeneratedContent, "${output.radio}", variables.finalOutput) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.value}", variables.value) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.label}", ListGetAt(attributes.labels, i, attributes.delimiter))/>
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.id}", createCleanId(variables.value), "all") />

			<cfset variables.outputBuffer.content.append(variables.finalOutput) />
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfif attributes.items.getDimension() EQ 1>
			<cfif IsSimpleValue(attributes.items[1])>
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<cfset variables.value = attributes.items[i] />

					<cfif StructKeyExists(attributes, "checkValue") AND attributes.checkValue EQ variables.value>
						<cfset variables.finalOutput = ReplaceNoCase(variables.radioTemplate, "/>", ' checked="checked"/>') />
					<cfelse>
						<cfset variables.finalOutput = variables.radioTemplate />
					</cfif>
					
					<cfif i EQ 1>
						<cfset setFirstElementId(attributes.name & "_" & createCleanId(variables.value)) />
					</cfif>

					<cfset variables.finalOutput = ReplaceNoCase(variables.originalGeneratedContent, "${output.radio}", variables.finalOutput) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.value}", variables.value) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.label}", attributes.labels[i]) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.id}", createCleanId(variables.value), "all") />

					<cfset variables.outputBuffer.content.append(variables.finalOutput) />
				</cfloop>
			<cfelseif IsStruct(attributes.items[1])>
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<cfset variables.value = attributes.items[i][attributes.valueKey] />

					<cfif StructKeyExists(attributes, "checkValue") AND attributes.checkValue EQ variables.value>
						<cfset variables.finalOutput = ReplaceNoCase(variables.radioTemplate, "/>", ' checked="checked"/>') />
					<cfelse>
						<cfset variables.finalOutput = variables.radioTemplate />
					</cfif>

					<cfif i EQ 1>
						<cfset setFirstElementId(attributes.name & "_" & createCleanId(variables.value)) />
					</cfif>

					<cfset variables.finalOutput = ReplaceNoCase(variables.originalGeneratedContent, "${output.radio}", variables.finalOutput) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.value}", variables.value) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.label}", attributes.items[i][attributes.labelKey]) />
					<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.id}", createCleanId(variables.value), "all") />

					<cfset variables.outputBuffer.content.append(variables.finalOutput) />
				</cfloop>
			<cfelse>
				<cfthrow type="MachII.customtags.form.radiogroup.unsupportedItemsDatatype"
						message="Unsupported Data Type in Array"
						detail="The radio group form tag only supports simple values or structs as array elements." />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.customtags.form.radiogroup.unsupportedItemsDatatype"
					message="Unsupported Number of Array Dimensions in Radio Group Tag"
					detail="The radio group form tag only supports arrays of 1 dimension. Array values may be either simple values or structs. The array you passed to the tag is #attributes.items.getDimension()# dimensions." />
		</cfif>
	<cfelseif IsStruct(attributes.items)>
		<cfset variables.sortedKeys = sortStructByDisplayOrder(attributes.items, attributes.displayOrder) />

		<!--- struct key is value, struct value is label --->
		<cfloop index="i" from="1" to="#ArrayLen(variables.sortedKeys)#">
			<cfset variables.value = LCase(variables.sortedKeys[i]) />

			<cfif StructKeyExists(attributes, "checkValue") AND attributes.checkValue EQ variables.value>
				<cfset variables.finalOutput = ReplaceNoCase(variables.radioTemplate, "/>", ' checked="checked"/>') />
			<cfelse>
				<cfset variables.finalOutput = variables.radioTemplate />
			</cfif>

			<cfif i EQ 1>
				<cfset setFirstElementId(attributes.name & "_" & createCleanId(variables.value)) />
			</cfif>

			<cfset variables.finalOutput = ReplaceNoCase(variables.originalGeneratedContent, "${output.radio}", variables.finalOutput) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.value}", variables.value) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.label}", attributes.items[variables.value]) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.id}", createCleanId(variables.value), "all") />

			<cfset variables.outputBuffer.content.append(variables.finalOutput) />
		</cfloop>
	<cfelseif IsQuery(attributes.items)>
		<cfloop query="attributes.items">
			<cfset variables.value = attributes.items[attributes.valueCol][attributes.items.CurrentRow] />

			<cfif StructKeyExists(attributes, "checkValue") AND attributes.checkValue EQ variables.value>
				<cfset variables.finalOutput = ReplaceNoCase(variables.radioTemplate, "/>", ' checked="checked"/>') />
			<cfelse>
				<cfset variables.finalOutput = variables.radioTemplate />
			</cfif>

			<cfif attributes.items.currentRow EQ 1>
				<cfset setFirstElementId(attributes.name & "_" & createCleanId(variables.value)) />
			</cfif>

			<cfset variables.finalOutput = ReplaceNoCase(variables.originalGeneratedContent, "${output.radio}", variables.finalOutput) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.value}", variables.value) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.label}", attributes.items[attributes.labelCol][attributes.items.CurrentRow]) />
			<cfset variables.finalOutput = ReplaceNoCase(variables.finalOutput, "${output.id}", createCleanId(variables.value), "all") />

			<cfset variables.outputBuffer.content.append(variables.finalOutput) />
		</cfloop>
	<cfelse>
		<cfthrow type="MachII.customtags.form.radiogroup.unsupportedItemsDatatype"
					message="Unsupported datatype for the 'items' attribute."
					detail="The radio group form tag only supports lists, arrays, structs, and queries." />
	</cfif>

	<cfif attributes.output>
		<cfset thisTag.GeneratedContent = "" />
		<cfset appendGeneratedContentToBuffer(variables.outputBuffer.content.toString(), attributes.outputBuffer) />
	<cfelse>
		<cfset thisTag.GeneratedContent = variables.outputBuffer.content.toString() />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />