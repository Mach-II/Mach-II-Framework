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
<cfcomponent
	displayname="ParserUtilsTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.parsing.ParserUtils.">

	<!---
	PROPERTIES
	--->
	<cfset variables.parserUtils = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.parserUtils = CreateObject("component", "MachII.util.parsing.ParserUtils").init() />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="tesParseRequestBodyParameters" access="public" returntype="void" output="false"
		hint="Tests parseRequestBodyParameters().">

		<cfset var parameters = StructNew() />
		
		<cfset parameters = variables.parserUtils.parseRequestBodyParameters("code=%3Ccfdump%20var%3D%22%23getHttpRequestData()%23%22%2F%3E&submit=Share%20on%20PasteBin&submit=Back%20to%20Scribble&render1=Render&evalJS=true", true) />
		<cfset debug(parameters) />

		<cfset assertTrue(StructKeyExists(parameters, "code"), "Parameter named 'code' does not exist.") />
		<cfset assertTrue(Compare(parameters.code, '<cfdump var="##getHttpRequestData()##"/>') EQ 0, "The value of parameter named 'code' is incorrect.") />
		<cfset assertTrue(StructKeyExists(parameters, "render1"), "Parameter named 'render1' does not exist.") />
		<cfset assertTrue(Compare(parameters.render1, 'Render') EQ 0, "The value of parameter named 'render1' is incorrect.") />		
		
		<cfset parameters = variables.parserUtils.parseRequestBodyParameters("user[id]=1&user[name]=peter&user[numbers][]=1&user[numbers][]=2", true) />
		<cfset debug(parameters) />

		<cfset assertTrue(StructKeyExists(parameters, "user[numbers][]"), "Parameter named 'user[numbers][]' does not exist.") />
		<cfset assertTrue(Compare(parameters['user[numbers][]'], '2') EQ 0, "The value of parameter named 'user[numbers][]' is incorrect.") />
		<cfset assertTrue(StructKeyExists(parameters, "user[id]"), "Parameter named 'user[id]' does not exist.") />
		<cfset assertTrue(Compare(parameters['user[id]'], '1') EQ 0, "The value of parameter named 'user[id]' is incorrect.") />
	</cffunction>

</cfcomponent>