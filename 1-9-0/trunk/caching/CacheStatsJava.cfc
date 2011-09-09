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
$Id: CacheStats.cfc 2204 2010-04-27 07:36:11Z peterfarrell $

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
	displayname="CacheStatsJava"
	extends="MachII.caching.CacheStats"
	output="false"
	hint="Holds cache stats for a concrete strategy.">

	<!---
	PROPERTIES
	--->
	<!--- Do not mevore the instantiation of these Java objects because calling code try/catch tests will fail --->
	<cfset variables.cacheHits = CreateObject("java", "java.util.concurrent.atomic.AtomicLong") />
	<cfset variables.cacheMisses = CreateObject("java", "java.util.concurrent.atomic.AtomicLong") />
	<cfset variables.activeElements = CreateObject("java", "java.util.concurrent.atomic.AtomicLong") />
	<cfset variables.totalElements = CreateObject("java", "java.util.concurrent.atomic.AtomicLong") />
	<cfset variables.evictions = CreateObject("java", "java.util.concurrent.atomic.AtomicLong") />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheStatsJava" output="false"
		hint="Initializes the stats.">
		<cfset super.init() />
		<cfreturn this />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="incrementCacheHits" access="public" returntype="void" output="false"
		hint="Increments the number of hits by the default of 1 or by the amount passed.">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.cacheHits.incrementAndGet() />
		<cfelse>
			<cfset variables.cacheHits.addAndGet(arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="setCacheHits" access="public" returntype="void" output="false">
		<cfargument name="cacheHits" type="numeric" required="true" />
		<cfset variables.cacheHits.set(arguments.cacheHits) />
	</cffunction>
	<cffunction name="getCacheHits" access="public" returntype="numeric" output="false">
		<cfreturn variables.cacheHits.get() />
	</cffunction>

	<cffunction name="incrementCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.cacheMisses.incrementAndGet() />
		<cfelse>
			<cfset variables.cacheMisses.addAndGet(arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="decrementCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.cacheMisses.decrementAndGet() />
		<cfelse>
			<cfset variables.cacheMisses.addAndGet("-" & arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="setCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="cacheMisses" type="numeric" required="true" />
		<cfset variables.cacheMisses.set(arguments.cacheMisses) />
	</cffunction>
	<cffunction name="getCacheMisses" access="public" returntype="numeric" output="false">
		<cfreturn variables.cacheMisses.get() />
	</cffunction>

	<cffunction name="incrementEvictions" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.evictions.incrementAndGet() />
		<cfelse>
			<cfset variables.evictions.addAndGet(arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="setEvictions" access="public" returntype="void" output="false">
		<cfargument name="evictions" type="numeric" required="true" />
		<cfset variables.evictions.set(arguments.evictions) />
	</cffunction>
	<cffunction name="getEvictions" access="public" returntype="numeric" output="false">
		<cfreturn variables.evictions.get() />
	</cffunction>

	<cffunction name="incrementTotalElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.totalElements.incrementAndGet() />
		<cfelse>
			<cfset variables.totalElements.addAndGet(arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="decrementTotalElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.totalElements.decrementAndGet() />
		<cfelse>
			<cfset variables.totalElements.addAndGet("-" & arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="setTotalElements" access="public" returntype="void" output="false">
		<cfargument name="totalElements" type="numeric" required="true" />
		<cfset variables.totalElements.set(arguments.totalElements) />
	</cffunction>
	<cffunction name="getTotalElements" access="public" returntype="numeric" output="false">
		<cfreturn variables.totalElements.get() />
	</cffunction>

	<cffunction name="incrementActiveElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.activeElements.incrementAndGet() />
		<cfelse>
			<cfset variables.activeElements.addAndGet(arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="decrementActiveElements" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1" />
		<cfif arguments.amount EQ 1>
			<cfset variables.activeElements.decrementAndGet() />
		<cfelse>
			<cfset variables.activeElements.addAndGet("-" & arguments.amount) />
		</cfif>
	</cffunction>
	<cffunction name="setActiveElements" access="public" returntype="void" output="false">
		<cfargument name="activeElements" type="numeric" required="true" />
		<cfset variables.activeElements.set(arguments.activeElements) />
	</cffunction>
	<cffunction name="getActiveElements" access="public" returntype="numeric" output="false">
		<cfreturn variables.activeElements.get() />
	</cffunction>

</cfcomponent>