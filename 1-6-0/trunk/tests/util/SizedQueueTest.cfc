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
	displayname="BeanUtilTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.BeanUtil.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.sizedQueue = "" />
	<cfset variables.maxSize = 5 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.sizedQueue = CreateObject("component", "MachII.util.SizedQueue").init(variables.maxSize) />
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
		<cfset var cfcatch = "" />
		<cfset var i = "" />

		<cfset item.firstName = "Mach-II" />
		<cfset item.lastName = "Framework" />

		<!--- Load up the queue to the max size --->
		<cfloop from="1" to="#variables.maxSize#" index="i">
			<cfset variables.sizedQueue.put(item) />
		</cfloop>		
		
		<!--- Peek at the first item wich will be the test item --->
		<cfset assertEquals(variables.sizedQueue.peek(), item) />
		
		<!--- Check the size of the queue --->
		<cfset assertEquals(variables.sizedQueue.getSize(), variables.maxSize) />
		
		<!--- Assert that the queue is full --->
		<cfset assertTrue(variables.sizedQueue.isFull()) />
		
		<!--- Overload the queue --->
		<cftry>
			<cfset variables.sizedQueue.put(item) />
			<cfcatch type="any">
				<!--- Do nothing --->
			</cfcatch>
		</cftry>		
		<cfif NOT IsStruct(cfcatch)>
			<cfset fail("The sized queue failed to throw an error that the queue was full.") />
		</cfif>
		
		<!--- Clear the queue --->
		<cfset variables.sizedQueue.clear() />

		<!--- Assert that the queue is empty --->
		<cfset assertTrue(variables.sizedQueue.isEmpty()) />
	</cffunction>

</cfcomponent>