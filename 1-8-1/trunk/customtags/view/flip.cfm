<cfsetting enablecfoutputonly="true" /><cfsilent>
<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
	value	= [numeric|boolean] value to evaluate against (converts a value of "yes|true" to 1 and "no|false" to 0)
	items	= [string] a list of items to use when evaluating the value
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("flip", true) />

	<!--- Setup required --->
	<cfset ensureByName("value") />
	<cfset ensureByName("items", "Must be a list or an array.") />

<cfelse>

	<!--- Convert a "string" boolean to a number --->
	<cfset attributes.value = booleanize(attributes.value, "value") />

	<!--- Convert items array to list --->
	<cfif IsSimpleValue(attributes.items)>
		<cfset attributes.items = ListToArray(attributes.items) />
	</cfif>

	<!--- We can't zebra stripe if there is only one item so assume nothing for the second item --->
	<cfif ArrayLen(attributes.items) EQ 1>
		<cfset ArrayAppend(attributes.items, "") />
	</cfif>

	<cfset variables.modResult = attributes.value MOD ArrayLen(attributes.items) />
	<cfset variables.output = "" />

	<cfif variables.modResult EQ 0>
		<cfset variables.output = attributes.items[ArrayLen(attributes.items)] />
	<cfelse>
		<cfset variables.output = attributes.items[variables.modResult] />
	</cfif>

	<cfset thisTag.GeneratedContent = Trim(variables.output) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />