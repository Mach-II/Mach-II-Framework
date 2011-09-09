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
	displayname="FormatDateTest"
	extends="ViewTestCaseBase"
	hint="Test cases for 'FormatDateTest' custom tag.">

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset super.setup() />

		<!--- Include the tag library only once and it cannot be done in the inherited CFC --->
		<cfif NOT variables.included>
			<cfimport prefix="view" taglib="/MachII/customtags/view" />
			<cfset variables.included = true />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testFormattingWithDirectOutput" access="public" returntype="void" output="false"
		hint="Test basic 'formatdate' tag with direct output.">

		<cfset var output = "" />
		<cfset var testDate = CreateDateTime(2011, 9, 1, 14, 14, 14) />

		<!--- Test direct output using value (defaults to SHORT) --->
		<cfsavecontent variable="output"><view:formatdate value="#testDate#" locale="en_US" /></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("9/1/11", output) />

		<cfsavecontent variable="output"><view:formatdate value="#testDate#" locale="en_GB" /></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("01/09/11", output) />

		<cfsavecontent variable="output"><view:formatdate value="#testDate#" locale="fr_CA" /></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("11-09-01", output) />

		<!--- Test direct output using wrapped tag (defaults to SHORT) --->
		<cfsavecontent variable="output"><cfoutput><view:formatdate locale="en_US">#testDate#</view:formatdate></cfoutput></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("9/1/11", output) />

		<cfsavecontent variable="output"><cfoutput><view:formatdate locale="en_GB">#testDate#</view:formatdate></cfoutput></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("01/09/11", output) />

		<cfsavecontent variable="output"><cfoutput><view:formatdate locale="fr_CA">#testDate#</view:formatdate></cfoutput></cfsavecontent>
		<cfset debug(output) />
		<cfset assertEquals("11-09-01", output) />
	</cffunction>

	<cffunction name="testFormattingWithDirectToVariable" access="public" returntype="void" output="false"
		hint="Test basic 'formatdate' tag with direct to variables.">

		<cfset var testDate = CreateDateTime(2011, 9, 1, 14, 14, 14) />

		<!---
		Set the output to "request._output" and yes, we know it's not thread safe
		however formatdate tag uses setVariable() and it won't set to a local scoped
		variable.
		--->

		<!--- Test output to variable (defaults to SHORT) --->
		<view:formatdate value="#testDate#" locale="en_US" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("9/1/11", request._output) />

		<view:formatdate value="#testDate#" locale="en_GB" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("01/09/11", request._output) />

		<view:formatdate value="#testDate#" locale="fr_CA" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("11-09-01", request._output) />

		<!--- Test output to variable with MEDIUM pattern --->
		<view:formatdate value="#testDate#" locale="en_US" pattern="medium" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("sep 1, 2011", request._output) />

		<view:formatdate value="#testDate#" locale="en_GB" pattern="medium" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("01-sep-2011", request._output) />

		<view:formatdate value="#testDate#" locale="fr_CA" pattern="medium" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("2011-09-01", request._output) />

		<!--- Test output to variable with LONG pattern --->
		<view:formatdate value="#testDate#" locale="en_US" pattern="long" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("September 1, 2011", request._output) />

		<view:formatdate value="#testDate#" locale="en_GB" pattern="long" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("01 September 2011", request._output) />

		<view:formatdate value="#testDate#" locale="fr_CA" pattern="long" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("1 Septembre 2011", request._output) />

		<!--- Test output to variable with FULL pattern --->
		<view:formatdate value="#testDate#" locale="en_US" pattern="full" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("Thursday, September 1, 2011", request._output) />

		<view:formatdate value="#testDate#" locale="en_GB" pattern="full" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("Thursday, 1 September 2011", request._output) />

		<view:formatdate value="#testDate#" locale="fr_CA" pattern="full" var="request._output" />
		<cfset debug(request._output) />
		<cfset assertEquals("jeudi 1 septembre 2011", request._output) />
	</cffunction>

	<cffunction name="testFormattingWithCustomPattern" access="public" returntype="void" output="false"
		hint="Test basic 'formatdate' tag with custom pattern.">

		<cfset var testDate = CreateDateTime(2011, 9, 1, 14, 14, 14) />

		<!---
		Set the output to "request._output" and yes, we know it's not thread safe
		however formatdate tag uses setVariable() and it won't set to a local scoped
		variable.
		--->

		<!--- TODO: Complete formatdatetime with custom pattern --->

	</cffunction>

</cfcomponent>