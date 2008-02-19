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
Stats on a particular cache's performance may be tracked by a Mach-II provided CFC 
that exposes several metrics. One potential use of these metrics is to display them 
inside a dashboard that can be monitored while the application is running. The metrics 
tracked by Mach-II are as follows:
 
Cache hits
Cache misses
Cache active element count
Cache total element count
Cache evictions - number of elements that the cache removed to make room for new elements 
--->
<cfcomponent
	displayname="CacheStats"
	output="false"
	hint="Holds cache stats for a concrete strategy.">

	<!---
	PROPERTIES
	--->
	<cfproperty name="cacheHits" type="numeric" />
	<cfproperty name="cacheMisses" type="numeric" />
	<cfproperty name="activeElements" type="numeric" />
	<cfproperty name="totalElements" type="numeric" />
	<cfproperty name="evictions" type="numeric" />

	<cfset this.cacheHits = 0 />
	<cfset this.cacheMisses = 0 />
	<cfset this.activeElements = 0 />
	<cfset this.totalElements = 0 />
	<cfset this.evictions = 0 />
	
	<cfset variables.extraStats = structNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheStats" output="false"
		hint="Initializes the stats.">
		<cfreturn this />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="getExtraStats" access="public" returntype="struct" output="false">
		<cfreturn variables.extraStats />
	</cffunction>
	<cffunction name="setExtraStat" access="public" returntype="void" output="false">
		<cfargument name="statName" type="string" required="true" />
		<cfargument name="statValue" type="any" required="true" />
		<cfset variables.extraStats[statName] = statValue />
	</cffunction>
	
	<!--- <cfset variables.cacheHits = 0 />
	<cfset variables.cacheMisses = 0 />

	<cffunction name="incrementCacheHits" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1">
		<cfset variables.cacheHits = variables.cacheHits + arguments.amount />
	</cffunction>
	<cffunction name="getCacheHits" access="public" returntype="numeric" output="false">
		<cfreturn variables.cacheHits />
	</cffunction>

	<cffunction name="incrementCacheMisses" access="public" returntype="void" output="false">
		<cfargument name="amount" type="numeric" required="false" default="1">
		<cfset variables.cacheMisses = variables.cacheMisses + arguments.amount />
	</cffunction>
	<cffunction name="getcacheMisses" access="public" returntype="numeric" output="false">
		<cfreturn variables.cacheMisses />
	</cffunction> --->

</cfcomponent>