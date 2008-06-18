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

Configuration parameters

Size
- The size of the LRU cache size.
- The default setting for the LRU cache "size" is 100.
- Valid numeric value only.

Scope
- The scope that the cache should be placed in.
- The default setting for "scope" is "application".
- Valid values are "application", "server" and "session".

ScopeKey
- The key place the cache in the choosen scope.
- Optional and by default the cache will be placed in scope._MachIICache.Hash(appKey & moduleName & cacheName)
- Rarely will this need to be used

Using all of the default settings will result in caching 100 elements of data
in the application scope.

<property name="Caching" type="MachII.caching.CachingProperty">
      <parameters>
            <!-- Naming a default cache name is not required, but required if you do not want 
                 to specify the 'name' attribute in the cache command -->
            <parameter name="defaultCacheName" value="default" />
            <parameter name="default">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.LRUCache" />
                        <key name="size" value="100" />
                        <key name="scope" value="application" />
                  </struct>
            </parameter>
      </parameters>
</property>
--->
<cfcomponent
 	displayname="LRUCache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A caching strategy which uses an LRU eviction policy.">

	<!---
	PROPERTIES
	--->
	<cfset variables.size = 100 />
	<cfset variables.scope = "application" />
	<cfset variables.scopeKey = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy.">

		<!--- Validate and set parameters --->
		<cfif isParameterDefined("size")>
			<cfif NOT isNumeric(getParameter("size")) OR getParameter("size") LTE 0>
				<cfthrow type="MachII.caching.strategies.LRUCache"
					message="Invalid Size of '#getParameter("size")#'."
					detail="Size must be numeric and greater than 0." />
			<cfelse>			
				<cfset setSize(getParameter("size")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("scope")>
			<cfif NOT ListFindNoCase("application,server,session", getParameter("scope"))>
				<cfthrow type="MachII.caching.strategies.LRUCache"
					message="Invalid Scope of '#getParameter("scope")#'."
					detail="Use 'application', 'server' or 'session'." />
			<cfelse>
				<cfset setScope(getParameter("scope")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("scopeKey")>
			<cfif NOT Len(getParameter("scopeKey"))>
				<cfthrow type="MachII.caching.strategies.LRUCache"
					message="Invalid ScopeKey of '#getParameter("ScopeKey")#'."
					detail="ScopeKey must have a length greater than 0 and be a valid struct key." />
			<cfelse>
				<cfset setScopeKey(getParameter("scopeKey")) />
			</cfif>
		<cfelseif isParameterDefined("generatedScopeKey")>
			<cfset setScopeKey(getParameter("generatedScopeKey")) />
		<cfelse>
			<cfset setScopeKey(REReplace(CreateUUID(), "[[:punct:]]", "", "ALL")) />
		</cfif>
		
		<cfset flush() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Puts data into the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="Key does not need to be hashed." />
		<cfargument name="data" type="any" required="true" />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		
		<!--- Clean out the cache if neccessary --->
		<cfset reap() />
		
		<cfif NOT StructKeyExists(dataStorage.data, hashedKey)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		</cfif>
		<cfset dataStorage.data[hashedKey] = arguments.data />
		<cfset dataStorage.timestamps[createTimestamp() & "_" & hashedKey] = hashedKey />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets data from the cache by key. Returns null if the key is not in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="Key does not need to be hashed." />

		<cfset var dataStorage = getStorage() />
		<cfset var cache = dataStorage.data />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var timeStampKey = StructFindValue(dataStorage.timestamps, hashedKey, "one") />
		
		<cfif keyExists(arguments.key)>
			<cfset getCacheStats().incrementCacheHits(1) />
			<cfset structDelete(dataStorage.timestamps, timeStampKey[1].key, false) />
			<cfset dataStorage.timestamps[createTimeStamp() & "_" & hashedKey] = hashedKey />
			<cfreturn cache[hashedKey] />
		<cfelse>
			<cfset getCacheStats().incrementCacheMisses(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false"
		hint="Flushes the entire cache.">
		
		<cfset var dataStorage = getStorage() />

		<cfset dataStorage.data = StructNew() />
		<cfset dataStorage.timestamps = StructNew() />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false"
		hint="Checkes if a key exists in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="Key does not need to be hashed." />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />

		<cfif NOT StructKeyExists(dataStorage.data, hashedKey)>
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
			
		<cfset var dataStorage = getStorage() />
		<cfset var dataTimestampArray = ArrayNew(1) />
		<cfset var key = "" />
		
		<cfif (StructCount(dataStorage.data) + 1) GT getSize()>
		
			<cflock name="_MachIILRUCacheCleanup_#getScopeKey()#" type="exclusive" timeout="5" throwontimeout="false">
				
				<cfif (StructCount(dataStorage.data) + 1) GT getSize()>
					<!--- Get array of timestamps and sorted by oldest (least) timestamp first --->
					<cfset dataTimestampArray = StructKeyArray(dataStorage.timestamps) />
					<cfset ArraySort(dataTimestampArray, "textnocase", "asc") />
					
					<!--- Cleanup by removing the oldest entry --->
					<cfset key = ListLast(dataTimestampArray[1], "_") />
					<cfset removeHashedKey(key) />
				</cfif>
				
			</cflock>
			
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="removeHashedKey" access="private" returntype="void" output="false">
		<cfargument name="hashedKey" type="string" required="true"
			hint="The key does need to be hashed." />

		<cfset var dataStorage = getStorage() />
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
	
	<cffunction name="hashKey" access="private" returntype="string" output="false"
		hint="Creates a hashed version of the passed key.">
		<cfargument name="key" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.key)) />
	</cffunction>
	
	<cffunction name="createTimestamp" access="private" returntype="string" output="false"
		hint="Creates a timestamp which is safe to use as a key.">
		<cfargument name="time" type="date" required="false" default="#Now()#" />
		<!--- Need to have a time stamp that includes milliseconds and is an integer with no punctuation --->
		<cfreturn REReplace(arguments.time & ":" & getTickCount(), "[ts[:punct:][:space:]]", "", "ALL") />
	</cffunction>
	
	<cffunction name="getStorage" access="private" returntype="struct" output="false"
		hint="Gets a reference to the cache data storage.">
		
		<!--- StructGet will create the cache key if it does not exist --->
		<cfset var storage = StructGet(getScope() & "." & getScopeKey()) />
		
		<!--- Check to see if the cache data structure is initialized --->
		<cfif NOT StructCount(storage)>
			<cfset storage.data = StructNew() />
			<cfset storage.timestamps = StructNew() />
		</cfif>
		
		<cfreturn storage />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setSize" access="private" returntype="void" output="false">
		<cfargument name="size" type="numeric" required="true" />
		<cfset variables.size = arguments.size />
	</cffunction>
	<cffunction name="getSize" access="public" returntype="string" output="false"
		hint="Returns the configured maximum size of the LRU cache.">
		<cfreturn variables.size />
	</cffunction>

	<cffunction name="setScope" access="private" returntype="void" output="false">
		<cfargument name="scope" type="string" required="true" />
		<cfset variables.scope = arguments.scope />
	</cffunction>
	<cffunction name="getScope" access="public" returntype="string" output="false"
		hint="Returns the scope where the LRU cache is stored.">
		<cfreturn variables.scope />
	</cffunction>
	
	<cffunction name="setScopeKey" access="private" returntype="void" output="false">
		<cfargument name="scopeKey" type="string" required="true" />
		<cfset variables.scopeKey = arguments.scopeKey />
	</cffunction>
	<cffunction name="getScopeKey" access="public" returntype="string" output="false"
		hint="Gets the unique cache key for this cache strategy.">
		<cfreturn variables.scopeKey />
	</cffunction>
	
</cfcomponent>