<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
Stats on a particular cache's performance may be tracked by a Mach-II provided CFC 
that exposes several metrics. One potential use of these metrics is to display them 
inside a dashboard that can be monitored while the application is running. The metrics 
tracked by Mach-II are as follows:
 
* Cache hits
* Cache misses
* Cache active element count
* Cache total element count
* Cache evictions - number of elements that the cache removed to make room for new elements 

N.B. CacheStats method is not synchronized and therefore not completely thread-safe. This 
could lead to "slightly" inaccurate counts due to collision in which a counter is incremented
or decremented concurrently. We could ensure complete thread-safety of the counters by wrapping
each method in a cflock, but that would lead to degraded performance. Since CacheStats merely
gives an "idea"" of the counts, Team Mach-II felt that 100% accuracy was not warranted.
--->
<cfcomponent
	displayname="CacheStats"
	output="false"
	hint="Holds cache stats for a concrete strategy.">

	<!---
	PROPERTIES
	--->
	<cfset variables.extraStats = structNew() />
	<cfset variables.statsActiveSince = Now() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheStats" output="false"
		hint="Initializes the stats.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->	
	<cffunction name="reset" access="public" returntype="void" output="false"
		hint="Resets all the standard caching stats.">
		<cfset setCacheHits(0) />
		<cfset setCacheMisses(0) />
		<cfset setEvictions(0) />
		<cfset setTotalElements(0) />
		<cfset setActiveElements(0) />
		<cfset setStatsActiveSince(Now()) />
	</cffunction>

	<cffunction name="setExtraStat" access="public" returntype="void" output="false"
		hint="Sets an extra stats value by stat name.">
		<cfargument name="statName" type="string" required="true" />
		<cfargument name="statValue" type="any" required="true" />
		<cfset variables.extraStats[statName] = statValue />
	</cffunction>
	<cffunction name="getExtraStats" access="public" returntype="struct" output="false"
		hint="Gets the extra stats which must be a key of this struct.">
		<cfreturn variables.extraStats />
	</cffunction>
	
	<cffunction name="getCacheHitRatio" access="public" returntype="numeric" output="false"
		hint="Gets the hit ratio (decimal) which is (hits / total accesses) where total accesses is hits + misses.">
		
		<cfset var hits = getCacheHits() />
		<cfset var totalAccesses = hits + getCacheMisses() />
		
		<!--- Ensure that we are not dividing anything with a 0 --->
		<cfif hits AND totalAccesses>
			<cfreturn hits / totalAccesses />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>
	
	<cffunction name="getAllStats" access="public" returntype="struct" output="false"
		hint="Gets all the standard caching stats.">
		
		<cfset var stats = StructNew() />
		
		<cfset stats.cacheHits = getCacheHits() />
		<cfset stats.cacheMisses = getCacheMisses() />
		<cfset stats.activeElements = getActiveElements() />
		<cfset stats.totalElements = getTotalElements() />
		<cfset stats.evictions = getEvictions() />
		<cfset stats.statsActiveSince = getStatsActiveSince() />
	
		<cfreturn stats />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="incrementCacheHits" access="public" returntype="void" output="false"
		hint="Increments the number of hits by the default of 1 or by the amount passed.">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="setCacheHits" access="public" returntype="void" output="false">
		<cfargument name="cacheHits" type="numeric" required="true" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="getCacheHits" access="public" returntype="numeric" output="false">
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>

	<cffunction name="incrementCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="decrementCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="setCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="cacheMisses" type="numeric" required="true" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="getCacheMisses" access="public" returntype="numeric" output="false">
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	
	<cffunction name="incrementEvictions" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="setEvictions" access="public" returntype="void" output="false">
		<cfargument name="evictions" type="numeric" required="true" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="getEvictions" access="public" returntype="numeric" output="false">
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	
	<cffunction name="incrementTotalElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="decrementTotalElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="setTotalElements" access="public" returntype="void" output="false">
		<cfargument name="totalElements" type="numeric" required="true" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="getTotalElements" access="public" returntype="numeric" output="false">
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	
	<cffunction name="incrementActiveElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="decrementActiveElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="setActiveElements" access="public" returntype="void" output="false">
		<cfargument name="activeElements" type="numeric" required="true" />
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	<cffunction name="getActiveElements" access="public" returntype="numeric" output="false">
		<cfthrow message="This method must be implemented by the class that exteneds CacheStats" />
	</cffunction>
	
	<cffunction name="setStatsActiveSince" access="public" returntype="void" output="false">
		<cfargument name="statsActiveSince" type="date" required="true" />
		<cfset variables.statsActiveSince = arguments.statsActiveSince />
	</cffunction>
	<cffunction name="getStatsActiveSince" access="public" returntype="date" output="false">
		<cfreturn variables.statsActiveSince />
	</cffunction>

</cfcomponent>