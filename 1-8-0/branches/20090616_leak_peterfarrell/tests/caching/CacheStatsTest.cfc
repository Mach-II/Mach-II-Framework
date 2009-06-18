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
$Id: $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="CacheStatsTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.caching.CacheStats.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.cacheStats = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.cacheStats = CreateObject("component", "MachII.caching.CacheStats").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testCacheHits" access="public" returntype="void" output="false"
		hint="Tests cache hits of the cache stats.">

		<!--- Increment by the default of '1' hit
			current total: 1 --->
		<cfset variables.cacheStats.incrementCacheHits() />
		<!--- Increment by '4' hits
			current total: 5 --->
		<cfset variables.cacheStats.incrementCacheHits(4) />
		
		<cfset assertEquals(variables.cacheStats.getCacheHits(), 5, 
			"Cache hits should be '5' but returned '#variables.cacheStats.getCacheHits()#'") />
	</cffunction>

	<cffunction name="testCacheMisses" access="public" returntype="void" output="false"
		hint="Tests cache misses of the cache stats.">

		<!--- Increment by the default of '1' miss
			current total: 1 --->
		<cfset variables.cacheStats.incrementCacheMisses() />
		<!--- Increment by '4' misses
			current total: 5 --->
		<cfset variables.cacheStats.incrementCacheMisses(4) />
		
		<cfset assertEquals(variables.cacheStats.getCacheMisses(), 5, 
			"Cache misses should be '5' but returned '#variables.cacheStats.getCacheMisses()#'") />
	</cffunction>

	<cffunction name="testEvictions" access="public" returntype="void" output="false"
		hint="Tests evictions of the cache stats.">

		<!--- Increment by the default of '1' eviction
			current total: 1 --->
		<cfset variables.cacheStats.incrementEvictions() />
		<!--- Increment by '4' evictions
			current total: 5 --->
		<cfset variables.cacheStats.incrementEvictions(4) />
		
		<cfset assertEquals(variables.cacheStats.getEvictions(), 5, 
			"Evictions should be '5' but returned '#variables.cacheStats.getEvictions()#'") />
	</cffunction>
	
	<cffunction name="testTotalElements" access="public" returntype="void" output="false"
		hint="Tests total elements of the cache stats.">

		<!--- Increment by the default of '1' total elements
			current total: 1 --->
		<cfset variables.cacheStats.incrementTotalElements() />
		<!--- Increment by '4' total elements
			current total: 5 --->
		<cfset variables.cacheStats.incrementTotalElements(4) />

		<!--- Decrease by the default of '1' total elements
			current total: 1 --->
		<cfset variables.cacheStats.decrementTotalElements() />
		<!--- Decrease by '4' total elements
			current total: 5 --->
		<cfset variables.cacheStats.decrementTotalElements(4) />
		
		<cfset assertEquals(variables.cacheStats.getTotalElements(), 0, 
			"Total elements should be '0' but returned '#variables.cacheStats.getTotalElements()#'") />
	</cffunction>

	<cffunction name="testActiveElements" access="public" returntype="void" output="false"
		hint="Tests active elements of the cache stats.">

		<!--- Increment by the default of '1' active elements
			current total: 1 --->
		<cfset variables.cacheStats.incrementActiveElements() />
		<!--- Increment by '4' active elements
			current total: 5 --->
		<cfset variables.cacheStats.incrementActiveElements(4) />

		<!--- Decrease by the default of '1' active elements
			current total: 1 --->
		<cfset variables.cacheStats.decrementActiveElements() />
		<!--- Decrease by '4' active elements
			current total: 5 --->
		<cfset variables.cacheStats.decrementActiveElements(4) />
		
		<cfset assertEquals(variables.cacheStats.getActiveElements(), 0, 
			"Active elements should be '0' but returned '#variables.cacheStats.getActiveElements()#'") />
	</cffunction>
	
	<cffunction name="testExtraStats" access="public" returntype="void" output="false"
		hint="Test the extra stats functionality.">
		
		<cfset var extraStats = "" />
		
		<!--- Add some extra stats --->
		<cfset variables.cacheStats.setExtraStat("a", "a") />
		<cfset variables.cacheStats.setExtraStat("b", "b") />
		
		<!--- Run assertions on extraStats --->
		<cfset extraStats = variables.cacheStats.getExtraStats() />
		
		<cfset assertTrue(StructKeyExists(extraStats, "a"), "Key 'a' not in extra stats.") />
		<cfset assertEquals(extraStats.a, "a", "Value of key 'a' in extra stats should be 'a' but returned '#extraStats.a#'.") />
		<cfset assertTrue(StructKeyExists(extraStats, "b"), "Key 'b' not in extra stats.") />
		<cfset assertEquals(extraStats.b, "b", "Value of key 'b' in extra stats should be 'b' but returned '#extraStats.b#'.") />
	</cffunction>
	
	<cffunction name="testCacheHitRatio" access="public" returntype="void" output="false"
		hint="Tests to see if the cache hit ratio is being computed correctly.">
		
		<cfset variables.cacheStats.incrementCacheHits(100) />
		<cfset variables.cacheStats.incrementCacheMisses(100) />
		
		<cfset assertTrue(variables.cacheStats.getCacheHitRatio() EQ .5, "The cache hit ratio should be .5, but returned a different number.") />
	</cffunction>
	
	<cffunction name="testReset" access="public" returntype="void" output="false"
		hint="Tests reset functionality of the stats.">
		
		<cfset variables.cacheStats.incrementCacheHits(100) />
		<cfset variables.cacheStats.incrementCacheMisses(100) />
		<cfset variables.cacheStats.incrementActiveElements(100) />
		<cfset variables.cacheStats.incrementTotalElements(100) />
		<cfset variables.cacheStats.incrementEvictions(100) />
		
		<cfset variables.cacheStats.reset() />
		
		<cfset assertTrue(variables.cacheStats.getCacheHits() EQ 0) />
		<cfset assertTrue(variables.cacheStats.getCacheMisses() EQ 0) />
		<cfset assertTrue(variables.cacheStats.getActiveElements() EQ 0) />
		<cfset assertTrue(variables.cacheStats.getTotalElements() EQ 0) />
		<cfset assertTrue(variables.cacheStats.getEvictions() EQ 0) />
	</cffunction>
	
</cfcomponent>