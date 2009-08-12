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
$Id: LogFactoryTest.cfc 666 2008-03-09 02:55:35Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogFactoryTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.filters.GenericChannelFilter.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testMatchNothing" access="public" returntype="void" output="false"
		hint="Tests that matches no channels.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("!*") />

		<cfset doTest(filter, "path.to.that", false) />
		<cfset doTest(filter, "path.to.this", false) />
	</cffunction>
	
	<cffunction name="testMatchEverything" access="public" returntype="void" output="false"
		hint="Tests that matches all channels.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("*") />
		
		<cfset doTest(filter, "path.to.that", true) />
		<cfset doTest(filter, "path.to.this", true) />
	</cffunction>

	<cffunction name="testMatchSome" access="public" returntype="void" output="false"
		hint="Tests that matches only some channels.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("!*,MachII.*,!MachII.filters.*") />
		
		<cfset doTest(filter, "MachII.framework.RequestHandler", true) />
		<cfset doTest(filter, "MachII.framework.EventHandler", true) />
		<cfset doTest(filter, "MachII.filters.EventArgsFilter", false) />
		<cfset doTest(filter, "path.to.that", false) />
		<cfset doTest(filter, "path.to.this", false) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="doTest" access="private" returntype="void" output="false"
		hint="Helper method to perform a test.">
		<cfargument name="filter" type="any" required="true" />
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="shouldMatch" type="boolean" required="true" />
		
		<cfset var logMessageElements = StructNew() />
		
		<cfset logMessageElements.channel = arguments.channel />
		
		<cfif arguments.shouldMatch>
			<cfset assertTrue(arguments.filter.decide(logMessageElements), "Failed on channel '#logMessageElements.channel#'.") />
		<cfelse>
			<cfset assertFalse(arguments.filter.decide(logMessageElements), "Failed on channel '#logMessageElements.channel#'.") />
		</cfif>
	</cffunction>

</cfcomponent>