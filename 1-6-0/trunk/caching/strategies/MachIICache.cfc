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
 	displayname="MachIICache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A default caching strategy.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.cache = structNew() />
	<cfset variables.cacheFor = 1 />
	<cfset variables.cacheForUnit = "hours" />
	<cfset variables.scope = "application" />
	<cfset variables.scopeKey = createUUID() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy. Override to provide custom functionality.">

		<cfif isParameterDefined("cacheFor")>
			<cfset setCacheFor(getParameter("cacheFor")) />
		</cfif>
		<cfif isParameterDefined("cacheForUnit")>
			<cfset setCacheForUnit(getParameter("cacheForUnit")) />
		</cfif>
		<cfif isParameterDefined("scope")>
			<cfset setScope(getParameter("scope")) />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfset var cache = getCacheScope() />
		<cfif NOT structKeyExists(cache, arguments.key)>
			<cfset cache[arguments.key] = structNew() />
			<cfset getCacheStats().totalElements = getCacheStats().totalElements + 1 />
			<cfset getCacheStats().activeElements = getCacheStats().activeElements + 1 />
		</cfif>
		<cfset cache[arguments.key].data = arguments.data />
		<cfset cache[arguments.key].timestamp = now() />
		<cfset setCacheScope(cache) />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfset var cache = getCacheScope() />
		<cfif structKeyExists(cache, arguments.key) AND structKeyExists(cache[arguments.key], "data")>
			<cfset getCacheStats().cacheHits = getCacheStats().cacheHits + 1 />
			<cfreturn cache[arguments.key].data />
		<cfelse>
			<cfset getCacheStats().cacheMisses = getCacheStats().cacheMisses + 1 />
			<cfthrow type="MachII.caching.strategies.MachIICache"
				message="The key '#arguments.key#' does not exist in the cache." />
		</cfif>
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false">
		<cfset var cache = getCacheScope() />
		<cfset cache = structNew() />
		<cfset setCacheScope(cache) />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfset var cache = getCacheScope() />
		<cfset var findKey = structKeyExists(cache, arguments.key) />
		<cfif NOT findKey OR DateCompare(cache[arguments.key].timestamp, computeCacheUntilTimestamp()) GTE 0>
			<cfset remove(arguments.key) />
			<!--- TODO: is it ok to call this a cache miss? --->
			<cfset getCacheStats().cacheMisses = getCacheStats().cacheMisses + 1 />
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfset var cache = getCacheScope() />
		<cfif structKeyExists(cache, arguments.key)>
			<cfset structDelete(cache, arguments.key) />
			<cfset getCacheStats().evictions = getCacheStats().evictions + 1 />
			<cfset getCacheStats().totalElements = getCacheStats().totalElements - 1 />
			<cfset getCacheStats().activeElements = getCacheStats().activeElements - 1 />
		</cfif>
		<cfset setCacheScope(cache) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="computeCacheUntilTimestamp" access="private" returntype="date" output="false"
		hint="Computes a cache until timestamp for this cache block.">
		
		<cfset var timestamp = Now() />
		<cfset var cacheFor = getCacheFor() />
		<cfset var unit = getCacheForUnit() />
		
		<cfif unit EQ "seconds">
			<cfset timestamp = DateAdd("s", cacheFor, timestamp) />
		<cfelseif unit EQ "minutes">
			<cfset timestamp = DateAdd("n", cacheFor, timestamp) />
		<cfelseif unit EQ "hours">
			<cfset timestamp = DateAdd("h", cacheFor, timestamp) />
		<cfelseif unit EQ "days">
			<cfset timestamp = DateAdd("d", cacheFor, timestamp) />
		<cfelseif unit EQ "forever">
			<cfset timestamp = DateAdd("y", 100, timestamp) />
		<cfelse>
			<cfthrow type="MachII.caching.strategies.MachIICache"
				message="Invalid CacheForUnit of '#unit#'. Use 'seconds, 'minutes', 'hours', 'days' or 'forever'." />
		</cfif>
		
		<cfreturn timestamp />
	</cffunction>
	
	<cffunction name="getCacheScope" access="private" returntype="struct" output="false"
		hint="Gets the cache scope which is dependent on the storage location.">
		
		<cfset var storage = variables.cache />
		
		<cfif getScope() EQ "application">
			<cfset storage = variables.cache />
		<cfelseif getType() EQ "session">
			<cfset storage = StructGet("session") />
			
			<cfif NOT StructKeyExists(storage, "_MachIICache.#getScopeKey()#")>
				<cfset storage._MachIICache[getScopeKey()] = StructNew() />
			</cfif>
			
			<cfset storage = storage._MachIICache[getScopeKey()] />
		<cfelseif getType() EQ "server">
			<cfset storage = StructGet("server") />
			
			<cfif NOT StructKeyExists(storage, "_MachIICache.#getScopeKey()#")>
				<cfset storage._MachIICache[getScopeKey()] = StructNew() />
			</cfif>
			
			<cfset storage = storage._MachIICache[getScopeKey()] />
		</cfif>
		
		<cfreturn storage />
	</cffunction>
	
	<cffunction name="setCacheScope" access="private" returntype="void" output="false">
		<cfargument name="cache" type="struct" required="true" />
		<cfif getScope() EQ "application">
			<cfset variables.cache = arguments.cache />
		<cfelseif getType() EQ "session">
			<cfset session._MachIICache[getScopeKey()] = arguments.cache />
		<cfelseif getType EQ "server">
			<cfset server._MachIICache[getScopeKey()] = arguments.cache />
		</cfif>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setCacheFor" access="private" returntype="void" output="false">
		<cfargument name="cacheFor" type="string" required="true" />
		<cfset variables.cacheFor = arguments.cacheFor />
	</cffunction>
	<cffunction name="getCacheFor" access="private" returntype="string" output="false">
		<cfreturn variables.cacheFor />
	</cffunction>

	<cffunction name="setCacheForUnit" access="private" returntype="void" output="false">
		<cfargument name="cacheForUnit" type="string" required="true" />
		<cfset variables.cacheForUnit = arguments.cacheForUnit />
	</cffunction>
	<cffunction name="getCacheForUnit" access="private" returntype="string" output="false">
		<cfreturn variables.cacheForUnit />
	</cffunction>
	
	<cffunction name="setScope" access="private" returntype="void" output="false">
		<cfargument name="scope" type="string" required="true" />
		<cfset variables.scope = arguments.scope />
	</cffunction>
	<cffunction name="getScope" access="private" returntype="string" output="false">
		<cfreturn variables.scope />
	</cffunction>
	
	<cffunction name="getScopeKey" access="private" returntype="string" output="false">
		<cfreturn variables.scopeKey />
	</cffunction>
	
</cfcomponent>