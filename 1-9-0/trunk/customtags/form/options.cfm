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

Author: Peter J. Farrell (peter@mach-ii.com)
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
	<cfset setupTag("options", true) />

	<!--- Ensure certain attributes are defined --->
	<cfset ensureByName("items") />

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
	<cfparam name="attributes.checkValueCol" type="string"
		default="value" />
	<cfparam name="attributes.displayOrder" type="string"
		default="" />

<cfelse>
	<!--- checkValue can be a list, array, or struct, but ultimately
			we'll use a list to do the comparisons as we build the output --->
	<cfset variables.checkValues = request._MachIIFormLib.selectCheckValue />
	<cfset variables.checkValueDelimiter = request._MachIIFormLib.selectCheckValueDelimiter />

	<!--- Create a crazy outbuffer struct  so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />

	<!---
		Create an option template because calling the options tag repeatedly
		on a huge number of items is exponentially slow
	--->
	<form:option attributeCollection="#attributes#"		
		value="${output.value}"
		label="${output.label}"
		id="#getParentTagAttribute("select", "id")#_${output.id}"
		checkValue=""
		output="true"
		outputBuffer="#variables.outputBuffer#" />

	<cfset variables.optionTemplate = variables.outputBuffer.content />
	<cfset variables.outputBuffer.content = CreateObject("java", "java.lang.StringBuffer").init() />

	<cfif IsSimpleValue(attributes.items)>
		<cfif NOT StructKeyExists(attributes, "labels")>
			<cfset attributes.labels = attributes.items />
		</cfif>

		<cfloop index="i" from="1" to="#ListLen(attributes.items, attributes.delimiter)#">
			<cfset variables.value = LCase(Trim(ListGetAt(attributes.items, i, attributes.delimiter))) />

			<cfset variables.option = ReplaceNoCase(variables.optionTemplate, "${output.value}", variables.value, "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.id}", createCleanId(variables.value), "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.label}", variables.utils.escapeHtml(Trim(ListGetAt(attributes.labels, i, attributes.delimiter))), "one") />
			<cfif ListFindNoCase(variables.checkValues, variables.value, variables.checkValueDelimiter)>
				<cfset variables.option = ReplaceNoCase(variables.option, '>', ' selected="selected">', "one") />
			</cfif>

			<cfset variables.outputBuffer.content.append(variables.option) />
		</cfloop>
	<cfelseif IsStruct(attributes.items)>
		<cfset variables.itemOrder = sortStructByDisplayOrder(attributes.items, attributes.displayOrder) />

		<cfloop from="1" to="#ArrayLen(variables.itemOrder)#" index="i">
			<cfset variables.value = LCase(variables.itemOrder[i]) />

			<cfset variables.option = ReplaceNoCase(variables.optionTemplate, "${output.value}", variables.value, "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.id}", createCleanId(variables.value), "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.label}", variables.utils.escapeHtml(attributes.items[variables.itemOrder[i]]), "one") />
			<cfif ListFindNoCase(variables.checkValues, variables.itemOrder[i], variables.checkValueDelimiter)>
				<cfset variables.option = ReplaceNoCase(variables.option, '>', ' selected="selected">', "one") />
			</cfif>

			<cfset variables.outputBuffer.content.append(variables.option) />
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfif attributes.items.getDimension() EQ 1>
			<!--- need to check to see if this may be an array of structs --->
			<cfif IsSimpleValue(attributes.items[1])>
				<!--- this is an array of simple values, proceed as needed --->
				<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
					<cfset variables.value = LCase(attributes.items[i]) />

					<cfset variables.option = ReplaceNoCase(variables.optionTemplate, "${output.value}", variables.value, "all") />
					<cfset variables.option = ReplaceNoCase(variables.option, "${output.id}", createCleanId(variables.value), "all") />
					<cfset variables.option = ReplaceNoCase(variables.option, "${output.label}", variables.utils.escapeHtml(attributes.items[i]), "one") />
					<cfif ListFindNoCase(variables.checkValues, attributes.items[i], variables.checkValueDelimiter)>
						<cfset variables.option = ReplaceNoCase(variables.option, '>', ' selected="selected">', "one") />
					</cfif>

					<cfset variables.outputBuffer.content.append(variables.option) />
				</cfloop>
			<cfelseif IsStruct(attributes.items[1])>
				<!--- each array node contains a struct of elements, determine if the proper struct keys exist --->
				<cfif StructKeyExists(attributes.items[1], attributes.valueKey) AND StructKeyExists(attributes.items[1], attributes.labelKey)>
					<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
						<cfset variables.value = attributes.items[i][attributes.valueKey] />

						<cfset variables.option = ReplaceNoCase(variables.optionTemplate, "${output.value}", variables.value, "all") />
						<cfset variables.option = ReplaceNoCase(variables.option, "${output.id}", createCleanId(variables.value), "all") />
						<cfset variables.option = ReplaceNoCase(variables.option, "${output.label}", variables.utils.escapeHtml(attributes.items[i][attributes.labelKey]), "one") />
						<cfif ListFindNoCase(variables.checkValues, attributes.items[i][attributes.valueKey], variables.checkValueDelimiter)>
							<cfset variables.option = ReplaceNoCase(variables.option, '>', ' selected="selected">', "one") />
						</cfif>

						<cfset variables.outputBuffer.content.append(variables.option) />
					</cfloop>
				<cfelse>
					<!--- either the valueCol or lableCol attributes were not found in the structure, throw an error --->
					<cfthrow type="MachII.customtags.form.options.unsupportedItemsDatatype"
							message="Missing struct key values"
							detail="The options form tag supports an array of struct elements, however the valueKey and labelKey attributes do not match the struct keys contained in the first array element." />
				</cfif>
			<cfelse>
				<cfthrow type="MachII.customtags.form.options.unsupportedItemsDatatype"
						message="Unsupported Data Type in Array"
						detail="The options form tag only supports simple values or structs as array elements." />
			</cfif>
		<cfelse>
			<!--- only single dimension arrays are support, throw an exception for the multi-dimensional array passed --->
			<cfthrow type="MachII.customtags.form.options.unsupportedItemsDatatype"
					message="Unsupported Number of Array Dimensions in Options Tag"
					detail="The options form tag only supports arrays of 1 dimension. Array values may be either simple values or structs. The array you passed to the tag as the items attribute is #attributes.items.getDimension()# dimensions." />
		</cfif>
	<cfelseif IsQuery(attributes.items)>
		<cfloop query="attributes.items">
			<cfset variables.value = attributes.items[attributes.valueCol][attributes.items.currentRow] />

			<cfset variables.option = ReplaceNoCase(variables.optionTemplate, "${output.value}", variables.value, "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.id}", createCleanId(variables.value), "all") />
			<cfset variables.option = ReplaceNoCase(variables.option, "${output.label}", variables.utils.escapeHtml(attributes.items[attributes.labelCol][attributes.items.currentRow]), "one") />
			<cfif ListFindNoCase(variables.checkValues, attributes.items[attributes.valueCol][attributes.items.currentRow], variables.checkValueDelimiter)>
				<cfset variables.option = ReplaceNoCase(variables.option, '>', ' selected="selected">', "one") />
			</cfif>

			<cfset variables.outputBuffer.content.append(variables.option) />
		</cfloop>
	<cfelse>
		<cfthrow type="MachII.customtags.form.#getTagType()#"
			message="The 'items' attribute for #getTagType()# custom tag does not support the passed datatype."
			detail="The 'items' attribute only supports lists, structs, queries and arrays." />
	</cfif>

	<cfif attributes.output>
		<cfset thisTag.GeneratedContent = "" />
		<cfset appendGeneratedContentToBuffer(variables.outputBuffer.content.toString(), attributes.outputBuffer) />
	<cfelse>
		<cfset thisTag.GeneratedContent = variables.outputBuffer.content.toString() />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />