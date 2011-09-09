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
	displayname="HiddenTest"
	extends="FormTestCaseBase"
	hint="Test cases for 'hidden' custom tag.">

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset super.setup() />

		<!--- Include the tag library only once and it cannot be done in the inherited CFC --->
		<cfif NOT variables.included>
			<cfimport prefix="form" taglib="/MachII/customtags/form" />
			<cfset variables.included = true />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testHidden" access="public" returntype="void" output="false"
		hint="Test basic 'hidden' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />

		<!--- Add data to the the bean and set to the event so we can do binding --->
		<cfset bean.setFavoriteColor("red") />
		<cfset bean.setFirstName("Peter") />
		<cfset bean.setLastName("Farrell") />
		<cfset event.setArg("user", bean) />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:hidden path="favoriteColor" />
					<form:hidden path="firstName" />
					<form:hidden path="lastName" onclick="doSomething();" />
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/input[@type="hidden" and @value="red" and @id="favoriteColor"]', xml) />
		<cfset node = assertXPath('/root/form/input[@type="hidden" and @value="Peter" and @id="firstName"]', xml) />
		<cfset node = assertXPath('/root/form/input[@type="hidden" and @value="Farrell" and @id="lastName" and @onclick="doSomething();"]', xml) />
	</cffunction>

</cfcomponent>