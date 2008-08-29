<!---
License:
Copyright 2008 GreatBizTools, LLC

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
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.Log.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var adapters = StructNew() />
				
		<cfset adapters.test = CreateObject("component", "MachII.logging.adapters.ScopeAdapter").init(StructNew()) />
		<cfset adapters.test.configure() />
		
		<cfset variables.log = CreateObject("component", "MachII.logging.Log").init("testChannel", adapters) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testDebug" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with debug log level.">

		<cfset variables.log.debug("This is a test message.") />
		<cfset variables.log.debug("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testError" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with error log level.">

		<cfset variables.log.error("This is a test message.") />
		<cfset variables.log.error("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testFatal" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with fatal log level.">

		<cfset variables.log.fatal("This is a test message.") />
		<cfset variables.log.fatal("This is a test message.", StructNew()) />
	</cffunction>

	<cffunction name="testInfo" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with info log level.">

		<cfset variables.log.info("This is a test message.") />
		<cfset variables.log.info("This is a test message.", StructNew()) />
	</cffunction>

	<cffunction name="testTrace" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with trace log level.">
		
		<cfset variables.log.trace("This is a test message.") />
		<cfset variables.log.trace("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testWarn" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with warn log level.">

		<cfset variables.log.warn("This is a test message.") />
		<cfset variables.log.warn("This is a test message.", StructNew()) />
	</cffunction>

</cfcomponent>