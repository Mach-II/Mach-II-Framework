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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="TimeSpanCacheTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.caching.strategies.TimeSpanCache.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.cache = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var parameters = StructNew() />

		<cfset parameters.timespan = "0,1,0,0" />
		<cfset parameters.scope = "application" />

		<cfset variables.cache = CreateObject("component", "MachII.caching.strategies.TimeSpanCache").init(parameters) />
		<cfset variables.cache.configure() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testPutExistsGet" access="public" returntype="void"
		hint="Tests put, exist and getting a piece of data from the cache.">

		<cfset var testKey = "productID=1" />
		
		<cfset variables.cache.put(testkey, "testing") />
		
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		<cfset assertTrue(variables.cache.get(testkey) eq "testing") />
	</cffunction>
	
	<cffunction name="testFlush" access="public" returntype="void"
		hint="Tests flushing the cache.">
		
		<cfset var testKey = "productID=1" />

		<cfset variables.cache.put(testkey, "testing") />
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		
		<cfset variables.cache.flush() />
		<cfset assertFalse(variables.cache.keyExists(testkey)) />
	</cffunction>
	
	<cffunction name="testRemove" access="public" returntype="void"
		hint="Tests removing cached data by key.">
		
		<cfset var testKey = "productID=1" />

		<cfset variables.cache.put(testkey, "testing") />
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		
		<cfset variables.cache.remove(testkey) />
		<cfset assertFalse(variables.cache.keyExists(testkey)) />
	</cffunction>
	
	<cffunction name="testReap" access="public" returntype="void"
		hint="Tests removing cached data by key.">
		
		<cfset var i = 0 />
		
		<!--- Load the cache --->
		<cfloop from="1" to="2" index="i">
			<cfset variables.cache.put("productID=#i#", "testing #i#") />
		</cfloop>
		
		<!--- "Fake" 55 minutes passing of time and force a reap  --->
		<cfset variables.cache.setCurrentTickCount(getTickCount() + 3300000) />
		<cfset variables.cache.reap() />
		<cfset variables.cache.setCurrentTickCount("") />
		
		<!--- Check for elements should still be cached --->
		<cfset assertTrue(variables.cache.keyExists("productID=1"), 
			"Check for elements should still be cached (productID=1)") />
		<cfset assertTrue(variables.cache.keyExists("productID=2"), 
			"Check for elements should still be cached (productID=2)") />

		<!--- "Fake" 2 hours passing of time that exceeds cache element timestamps and force a reap --->
		<cfset variables.cache.setCurrentTickCount(getTickCount() + 7200000) />
		<cfset variables.cache.reap() />
		<cfset variables.cache.setCurrentTickCount("") />
		
		<!--- Check for elements that should have been reaped --->
		<cfset assertFalse(variables.cache.keyExists("productID=1"), 
			"Check for elements that should have been reaped (productID=1)") />
		<cfset assertFalse(variables.cache.keyExists("productID=2"), 
			"Check for elements that should have been reaped (productID=2)") />		
	</cffunction>

</cfcomponent>