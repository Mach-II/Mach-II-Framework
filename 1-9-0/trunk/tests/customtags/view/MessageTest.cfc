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

Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="FormatDatetimeTest"
	extends="ViewTestCaseBase"
	hint="Test cases for 'FormatDatetimeTest' custom tag.">

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var globalizationProperty = "" />
		<cfset var parameters = StructNew() />

		<cfset super.setup() />

		<!--- Setup globalization --->
		<cfset parameters.bundles = ArrayNew(1) />
		<cfset ArrayAppend(parameters.bundles, "/MachII/tests/dummy/resource/test") />

		<cfset globalizationProperty = CreateObject("component", "MachII.globalization.GlobalizationLoaderProperty").init(variables.appManager, parameters) />
		<cfset variables.appManager.getPropertyManager().setProperty("gp", globalizationProperty) />
		<cfset globalizationProperty.configure() />

		<!--- Include the tag library only once and it cannot be done in the inherited CFC --->
		<cfif NOT variables.included>
			<cfimport prefix="view" taglib="/MachII/customtags/view" />
			<cfset variables.included = true />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testMessage" access="public" returntype="void" output="false"
		hint="Test basic 'meassage' tag.">

		<cfset var args = ArrayNew(1) />

		<view:message key="simple" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("I am a simple message.", request._output) />

		<view:message key="complex" arguments="Peter,88123" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("Dear Peter, your order number is 88123.", request._output) />

		<cfset args = [CreateDateTime(2011, 9, 1, 14, 14, 14)] />
		<view:message key="orderDate" arguments="#args#" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("You ordered on 9/1/11.", request._output) />

		<view:message key="choice" arguments="#[0]#" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("There are no files.", request._output) />

		<view:message key="choice" arguments="#[1]#" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("There is one file.", request._output) />

		<view:message key="choice" arguments="#[33]#" var="request._output" locale="en_US" />
		<cfset debug(request._output) />
		<cfset assertEquals("There are 33 files.", request._output) />
	</cffunction>

</cfcomponent>