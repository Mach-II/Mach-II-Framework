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
 	displayname="LRUCache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A default caching strategy.">

	<!---
	PROPERTIES
	--->
	<cfset variables.cache = structNew() />
	<cfset variables.cache.data = structNew() />
	<cfset variables.cache.timestamps = structNew() />
	<cfset variables.size = 10 />
	<cfset variables.scope = "application" />
	<cfset variables.scopeKey = createUUID() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy.">

		<cfif isParameterDefined("size")>
			<cfset setSize(getParameter("size")) />
		</cfif>
		<cfif isParameterDefined("scope")>
			<cfset setScope(getParameter("scope")) />
		</cfif>
		
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Puts data into the cache by key.">
		<cfargument name="key" type="string" required="true" hint="Doesn't need to be hashed" />
		<cfargument name="data" type="any" required="true" />

		<cfset var dataStorage = getCacheScope() />
		<cfset var hashedKey = hashKey(arguments.key) />
		
		<!--- Clean out the cache if neccessary --->
		<cfset reap() />
		
		<cfif NOT StructKeyExists(dataStorage.data, hashedKey)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		</cfif>
		<cfset dataStorage.data[hashedKey] = arguments.data />
		<cfset dataStorage.timestamps[createTimestamp() & "_" & hashedKey] = hashedKey />
		<cfset setCacheScope(dataStorage) />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets data from the cache by key. Returns null if the key isn't in the cache.">
		<cfargument name="key" type="string" required="true" hint="Doesn't need to be hashed" />

		<cfset var dataStorage = getCacheScope() />
		<cfset var cache = dataStorage.data />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var timeStampKey = StructFindValue(dataStorage.timestamps, hashedKey, "one") />
		
		<cfif keyExists(arguments.key)>
			<cfset getCacheStats().incrementCacheHits(1) />
			<cfset dataStorage.timestamps[timeStampKey[1].key] = createTimeStamp() />
			<cfreturn cache[hashedKey] />
		<cfelse>
			<cfset getCacheStats().incrementCacheMisses(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false"
		hint="Flushes the entire cache.">
		
		<cfset var dataStorage = getCacheScope() />

		<cfset dataStorage.data = StructNew() />
		<cfset dataStorage.timestamps = StructNew() />
		<cfset setCacheScope(dataStorage) />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false"
		hint="Checkes if a key exists in the cache.">
		<cfargument name="key" type="string" required="true" hint="Doesn't needs to be hashed" />

		<cfset var dataStorage = getCacheScope() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var findKey = StructKeyExists(dataStorage.data, hashedKey) />

		<cfif NOT findKey>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes data from the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key does not need to be hashed." />

		<cfset var hashedKey = hashKey(arguments.key) />
		
		<cfset removeHashedKey(hashedKey) />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Looks at the timestamps of the cache pieces and throws out oldest one if the cache has more then the its max size.">
			
		<cfset var dataStorage = getCacheScope() />
		<cfset var key = "" />
		
		<cfif (structCount(dataStorage.data) + 1) gt getSize()>
		
			<cflock name="_MachIILRUCacheCleanup" type="exclusive" timeout="5" throwontimeout="false">
				
				<cfif (structCount(dataStorage.data) + 1) gt getSize()>
					<!--- Get array of timestamps and sorted by oldest (least) timestamp first --->
					<cfset dataTimestampArray = StructKeyArray(dataStorage.timestamps) />
					<cfset ArraySort(dataTimestampArray, "textnocase", "asc") />
					
					<!--- Cleanup by removing the oldest entry --->
					<cfset key = listLast(dataTimestampArray[1], "_") />
					<cfset removeHashedKey(key) />
				</cfif>
				
			</cflock>
			
		</cfif>
	</cffunction>
	
	<cffunction name="hashKey" access="public" returntype="string" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.key)) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="removeHashedKey" access="private" returntype="void" output="false">
		<cfargument name="hashedKey" type="string" required="true"
			hint="The key does need to be hashed." />
		<cfset var dataStorage = getCacheScope() />
		<cfset var cache = dataStorage.data />
		<cfset var timeStampKey = "" />

		<cfif StructKeyExists(cache, arguments.hashedKey)>
			<cfset StructDelete(cache, arguments.hashedKey, false) />
			<cfset timeStampKey = StructFindValue(dataStorage.timestamps, arguments.hashedKey, "one") />
			<cfset StructDelete(dataStorage.timestamps, timeStampKey[1].key, false) />
			<cfset getCacheStats().incrementEvictions(1) />
			<cfset getCacheStats().decrementTotalElements(1) />
			<cfset getCacheStats().decrementActiveElements(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="createTimestamp" access="private" returntype="string" output="false"
		hint="Creates a timestamp for use.">
		<cfargument name="time" type="date" required="false" default="#Now()#" />
		<cfreturn REReplace(arguments.time, "[ts[:punct:][:space:]]", "", "ALL") />
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
	<cffunction name="setSize" access="private" returntype="void" output="false">
		<cfargument name="size" type="numeric" required="true" />
		<cfset variables.size = arguments.size />
	</cffunction>
	<cffunction name="getSize" access="public" returntype="string" output="false">
		<cfreturn variables.size />
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