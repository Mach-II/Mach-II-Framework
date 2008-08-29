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
Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheStatsTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.caching.CacheStats.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.cacheStrategyManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.cacheStrategyManager = CreateObject("component", "MachII.caching.CacheStrategyManager").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testLoadConfigureGet" access="public" returntype="void"
		hint="Tests load(), configure() and get() routines.">
		
		<cfset var strategy = "" />
		
		<!--- Load in a strategy to test with --->
		<cfset variables.cacheStrategyManager.loadStrategy("default", "MachII.caching.strategies.TimeSpanCache") />
		
		<!--- Configure all the strategies --->
		<cfset variables.cacheStrategyManager.configure() />
		
		<!--- Get the strategy --->
		<cfset strategy = variables.cacheStrategyManager.getCacheStrategyByName("default") />
		
		<!--- Assert we got a strategy back --->
		<cfset assertTrue(IsObject(strategy)) />
	</cffunction>
	
</cfcomponent>