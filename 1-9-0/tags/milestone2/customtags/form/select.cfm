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
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	name		= AUTOMATIC|[string]
	type		= select
- OPTIONAL ATTRIBUTES
	disabled	= disabled|[null]
	size		= [numeric]
	checkValue	= [string]|[null]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("select", false) />

	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />

	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.checkValue" type="string"
			default="#wrapResolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
		<cfparam name="attributes.checkValue" type="string"
			default="" />
	</cfif>

	<!--- Set defaults --->
	<cfset attributes.name = resolveName() />
	<cfparam name="attributes.id" type="string"
		default="#attributes.name#" />
	<cfparam name="attributes.delimiter" type="string"
		default="," />
	<cfparam name="attributes.checkValueCol" type="string"
		default="value" />

	<cfset setFirstElementId(attributes.id) />

	<!--- Syncronize check value for option/options tag --->
	<!--- checkValue can be a list, array, or struct, but ultimately
			we'll use a list to do the comparisons as we build the output --->
	<cfset request._MachIIFormLib.selectCheckValue = translateCheckValue(attributes.checkValue, attributes.checkValueCol, attributes.delimiter) />
	<cfset request._MachIIFormLib.selectCheckValueDelimiter = attributes.delimiter />

	<!--- Set required attributes--->
	<cfset setAttribute("name") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("size") />
	<cfset setAttributeIfDefinedAndTrue("multiple", "multiple") />
	<cfset setAttributeIfDefinedAndTrue("disabled", "disabled") />

	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />

<cfelse>
	<!--- Create a crazy outbuffer struct  so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />

	<cfif StructKeyExists(attributes, "items")>
		<form:options attributeCollection="#attributes#"
			output="true"
			outputBuffer="#variables.outputBuffer#"/>
		<cfset variables.outputBuffer.content = Chr(13) & variables.outputBuffer.content />
	</cfif>

	<!--- Any options generated from items are append at the end of any nested option tags --->
	<cfset setContent(thisTag.GeneratedContent & variables.outputBuffer.content) />

	<cfset thisTag.GeneratedContent = doStartTag() & doEndTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />