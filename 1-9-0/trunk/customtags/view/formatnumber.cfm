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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("formatnumber", false) />

	<!--- Setup defaults --->
	<cfparam name="attributes.var" type="string"
		default="" />
	<cfparam name="attributes.display" type="boolean"
		default="#NOT Len(attributes.var)#" />
	<cfparam name="attributes.locale"
		default="#getAppManager().getRequestManager().getRequestHandler().getCurrentLocale()#" />

	<!--- Get formatter based on attributes --->
	<cfif StructKeyExists(attributes, "pattern")>
		<cfset attributes.pattern = ReplaceNoCase(attributes.pattern, "_", "##", "all") />
		<cfset variables.formatter = getAppManager().getGlobalizationManager().getFormatDecimalInstance(attributes.locale, attributes.pattern) />

		<cfif StructKeyExists(attributes, "roundingMode")>
			<!---
				* UP
				* DOWN
				* CEILING
				* FLOOR
				* HALF_UP
				* HALF_DOWN
				* HALF_EVEN
				* UNNECESSARY
			--->
			<cfset variables.rounder = CreateObject("java", "java.math.RoundingMode") />
			<cftry>
				<cfset variables.formatter.setRoundingMode(variables.rounder[UCase(attributes.roundingMode)]) />
				<cfcatch type="any">
					<cfthrow type="MachII.customtags.view.formatnumber.invalidRoundingModeValue"
						message="The 'roundingMode' attribute is an invalid value."
						detail="Use 'up', 'down', 'ceiling', 'floor', 'half_up', half_down', 'half_even' or 'unecessary' as a value." />
				</cfcatch>
			</cftry>
		</cfif>

	<cfelse>
		<cfset variables.formatter = getAppManager().getGlobalizationManager().getFormatNumberInstance(attributes.locale) />
	</cfif>

<cfelse>
	<!--- Use nested content if no "value" is defined --->
	<cfif NOT StructKeyExists(attributes, "value")>
		<cfset attributes.value = Trim(thisTag.GeneratedContent) />
	</cfif>
	<cfset ensureByName("value") />

	<cfif Len(attributes.value)>
		<!--- Perform formatting --->
		<cfset variables.output = variables.formatter.format(JavaCast("double", attributes.value)) />
	<cfelseif StructKeyExists(attributes, "defaultValue")>
		<cfset variables.output = attributes.defaultValue />
	</cfif>

	<!--- Store the output to whatever variable 'var' is pointing to --->
	<cfif Len(attributes.var)>
		<cfset SetVariable(attributes.var, variables.output) />
	</cfif>

	<!--- Output the label message or reset the output buffer if nothing is to be outputted --->
	<cfif attributes.display>
		<cfset ThisTag.GeneratedContent = variables.output />
	<cfelse>
		<cfset ThisTag.GeneratedContent = "" />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />