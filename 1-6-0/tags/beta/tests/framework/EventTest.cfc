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
	displayname="EventTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.Event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.event = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		
		<cfset var args = StructNew() />
		
		<!--- Test data to populate args --->
		<cfset args.name = "Mach-II" />
		<cfset args.version = 1234 />
		
		<cfset variables.event = CreateObject("component", "MachII.framework.Event").init("test", args, "test", "", "") />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testGeneral" access="public" returntype="void" output="false"
		hint="Tests general functions.">

		<!--- setArg is tested by setArgs as it loops over the pass struct --->
		<cfset assertEquals(variables.event.getArg("name"), "Mach-II") />
		<cfset assertEquals(variables.event.getArg("version"), "1234") />

		<cfset assertTrue(variables.event.isArgDefined("name")) />
		<cfset assertTrue(variables.event.isArgDefined("version")) />

		<cfset assertFalse(variables.event.isArgDefined("junkArg")) />
		
	</cffunction>

</cfcomponent>