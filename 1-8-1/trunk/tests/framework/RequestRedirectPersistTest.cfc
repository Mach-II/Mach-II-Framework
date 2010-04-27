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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="RequestRedirectPersistTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.RequestRedirectPersist.">

	<!---
	PROPERTIES
	--->
	<cfset variables.requestRedirectPersist = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var appManager = "" />
		<cfset var propertyManager = "" />

		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />

		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset propertyManager.setProperty("redirectPersistParameter", "persistId") />
		<cfset propertyManager.setProperty("redirectPersistScope", "application") />
		<cfset appManager.setPropertyManager(propertyManager) />

		<cfset variables.requestRedirectPersist = CreateObject("component", "MachII.framework.RequestRedirectPersist").init(appManager) />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testSaveRead" access="public" returntype="void" output="false"
		hint="Tests a save read process with simulated pause for the redirect.">

		<cfset var persistId = "" />
		<cfset var testData = buildTestData() />
		<cfset var eventArgs = StructNew() />

		<!--- Save before "redirect" --->
		<cfset persistId = variables.requestRedirectPersist.save(testData) />

		<!--- Simlulate "redirect" by sleeping for 1 second --->
		<cfset CreateObject("java", "java.lang.Thread").sleep(1000) />

		<!--- Retrieve the data post "redirect" setup --->
		<cfset eventArgs.persistId = persistId />
		<cfset eventArgs = variables.requestRedirectPersist.read(eventArgs) />

		<!--- Assert data is there --->
		<cfif NOT StructKeyExists(eventArgs, "team") OR NOT IsArray(eventArgs.team)>
			<cfset debug(eventArgs) />
			<cfset fail("Redirect persist did not have the data I expected.") />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="buildTestData" access="public" returntype="struct" output="false"
		hint="Builds a test data struct.">

		<cfset var data = StructNew() />

		<!--- Build some test data --->
		<cfset data.team = ArrayNew(1) />
		<cfset data.team[1] = "Peter" />
		<cfset data.team[2] = "Kurt" />
		<cfset data.team[3] = "Matt" />

		<cfreturn data />
	</cffunction>

</cfcomponent>