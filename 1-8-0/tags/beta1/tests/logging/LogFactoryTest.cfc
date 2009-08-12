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
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogFactoryTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.LogFactory.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.logFactory = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.logFactory = CreateObject("component", "MachII.logging.LogFactory").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testGetLog" access="public" returntype="void" output="false"
		hint="Tests getting a new log instance.">
		
		<cfset var channel = "test" />
		
		<!--- Gets a log (this channel instance will be created since it will no be in the cache) --->
		<cfset variables.logFactory.getLog(channel) />
		
		<!--- Gets a log (this channel instance will be cache since the previous getLog created and cached a log for this channel) --->
		<cfset variables.logFactory.getLog(channel) />
	</cffunction>
	
	<cffunction name="testAddLogAdapter" access="public" returntype="void" output="false"
		hint="Tests adds a log adapter">
		
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.AbstractLogAdapter").init(StructNew()) />
		
		<cfset variables.logFactory.addLogAdapter(adapter) />
	</cffunction>
	
	<cffunction name="testAddRemoveLogAdapter" access="public" returntype="void" output="false"
		hint="Tests adding and removing a log adapter">
		
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.AbstractLogAdapter").init(StructNew()) />
		
		<cfset variables.logFactory.addLogAdapter(adapter) />
		
		<cfset variables.logFactory.removeLogAdapter(adapter) />
		
		<cfset assertTrue(NOT StructCount(variables.logFactory.getLogAdapters()), "A log adapter was added and removed, but that did not work correctly.") />
	</cffunction>
	
	<cffunction name="testDisableLogging" access="public" returntype="void" output="false"
		hint="Tests disabling the logging.">
		
		<!--- Add an adapter so when logging is disabled we have an adapter to disable logging --->
		<cfset testAddLogAdapter() />
		
		<cfset variables.logFactory.disableLogging() />
	</cffunction>

	<cffunction name="testEnableLogging" access="public" returntype="void" output="false"
		hint="Tests enabling the logging.">
		
		<!--- Add an adapter so when logging is disabled we have an adapter to disable logging --->
		<cfset testAddLogAdapter() />
		
		<cfset variables.logFactory.disableLogging() />
	</cffunction>

</cfcomponent>