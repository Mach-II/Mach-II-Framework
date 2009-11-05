<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

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