<!---
License:
Copyright 2009 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id: EventTest.cfc 888 2008-07-20 19:25:00Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="EventTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.Event.">
	
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
		<cfset appManager.setUtils(CreateObject("component", "MachII.util.Utils").init()) />
		<cfset appManager.setLogFactory(CreateObject("component", "MachII.logging.LogFactory").init()) />
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