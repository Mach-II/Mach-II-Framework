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
	displayname="QueueTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.Queue.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.queue = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.queue = CreateObject("component", "MachII.util.Queue").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testComprehensive" access="public" returntype="void" output="false"
		hint="Queues the item.">
			
		<cfset var item = StructNew() />

		<cfset item.firstName = "Mach-II" />
		<cfset item.lastName = "Framework" />

		<!--- Put the test item --->
		<cfset variables.queue.put(item) />
		
		<!--- Peek at the first item wich will be the test item --->
		<cfset assertEquals(variables.queue.peek(), item) />
		
		<!--- Check the size of the queue --->
		<cfset assertEquals(variables.queue.getSize(), 1) />
		
		<!--- Clear the queue --->
		<cfset variables.queue.clear() />

		<!--- Assert that the queue is empty --->
		<cfset assertTrue(variables.queue.isEmpty()) />
	</cffunction>

</cfcomponent>