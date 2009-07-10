<!---
License:
Copyright 2009 GreatBizTools, LLC

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
Updated version: 1.8.0

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

CachingEnabled
- Set whether caching enabled or disabled.
- The default setting is "true".
- Accepts a boolean or a struct of environments with corresponding booleans.

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
						<key name="cachingEnabled" value="true|false" />
						- OR - 
			            <key name="cachingEnabled">
			            	<struct>
			            		<key name="development" value="false"/>
			            		<key name="production" value="true"/>
			            	</struct>
			            </key>
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
	<cfset variables.instance.size = 100 />
	<cfset variables.instance.strategyTypeName = "LRU" />
	<cfset variables.instance.scope = "application" />
	<cfset variables.instance.scopeKey = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy.">

		<!--- Validate and set parameters --->
		<cfif isParameterDefined("size")
			AND getAssert().isTrue(IsNumeric(getParameter("size")) AND getParameter("size") GT 0
				, "Invalid Size of '#getParameter("size")#'."
				, "Size must be numeric and greater than 0.")>		
			<cfset setSize(getParameter("size")) />
		</cfif>
		<cfif isParameterDefined("scope")
			AND getAssert().isTrue(ListFindNoCase("application,server,session", getParameter("scope"))
				, "Invalid Scope of '#getParameter("scope")#'."
				, "Use 'application', 'server' or 'session'.")>
			<cfset setScope(getParameter("scope")) />
		</cfif>
		<cfif isParameterDefined("scopeKey")
			AND getAssert().hasText(getParameter("scopeKey")
				, "Invalid ScopeKey of '#getParameter("ScopeKey")#'."
				, "ScopeKey must have a length greater than 0 and be a valid struct key.")>
			<cfset setScopeKey(getParameter("scopeKey")) />
		<cfelseif isParameterDefined("generatedScopeKey")>
			<cfset setScopeKey(getParameter("generatedScopeKey")) />
		<cfelse>
			<!--- BlueDragon does not like it when the cache starts with numbers --->
			<cfset setScopeKey("_" & REReplace(CreateUUID(), "[[:punct:]]", "", "ALL")) />
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
		<cfset var cacheElement = StructNew() />
		
		<!--- Clean out the cache --->
		<cfset reap() />
		
		<!--- Update the cache stats --->
		<cfif NOT keyExists(arguments.key)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		</cfif>
		
		<!--- Build and set the cache element --->
		<cfset cacheElement.data = arguments.data />
		<cfset cacheElement.timestamp = getCurrentTickCount() />
		<cfset dataStorage[hashKey(arguments.key)] = cacheElement />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets data from the cache by key. Returns null if the key is not in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="Key does not need to be hashed." />

		<cfset var dataStorage = getStorage() />
		<cfset var cacheElement = "" />
		<cfset var hashedKey = hashKey(arguments.key) />
		
		<cfif keyExists(arguments.key)>
			<cfset cacheElement = dataStorage[hashedKey] />
			<cfset cacheElement.timestamp = getCurrentTickCount() />

			<cfset getCacheStats().incrementCacheHits(1) />

			<cfreturn cacheElement.data />
		<cfelse>
			<cfset getCacheStats().incrementCacheMisses(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false"
		hint="Flushes the entire cache.">
		
		<cfset var dataStorage = getStorage() />

		<cfset StructClear(dataStorage) />
		<cfset getCacheStats().reset() />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false"
		hint="Checkes if a key exists in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="Key should not be hashed." />
		<cfif NOT StructKeyExists(getStorage(), hashKey(arguments.key))>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes data from the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key does not need to be hashed." />
		<cfset removeHashedKey(hashKey(arguments.key)) />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Looks at the timestamps of the cache pieces and throws out oldest one if the cache has more then the its max size.">
			
		<cfset var dataStorage = getStorage() />
		<cfset var sortedTimestamps = "" />
		<cfset var i = "" />
		
		<cfif (StructCount(dataStorage) + 1) GT getSize()>
	
			<!--- Don't wait because an exclusive lock that has already been obtained
				indicates that a reap is in progress and we should not wait for the
				second check in the double-lock-check routine
				Setting the timeout to 0 indicates to wait indefinitely --->
			<cflock name="#getNamedLockName("cleanup")#" 
				type="exclusive" 
				timeout="1" 
				throwontimeout="false">
				
				<cfif (StructCount(dataStorage) + 1) GT getSize()>
				
					<cfset sortedTimestamps = StructSort(dataStorage, "numeric", "asc", "timestamp") />
					
					<cfloop from="1" to="#ArrayLen(sortedTimestamps)#" index="i">
						<cftry>
							<cfif (StructCount(dataStorage) + 1) GT getSize()>
								<cfset removeHashedKey(sortedTimestamps[i]) />
							<cfelse>
								<cfbreak />
							</cfif>
							<cfcatch type="any">
								<!--- Do nothing --->
							</cfcatch>
						</cftry>
					</cfloop>
				</cfif>
			</cflock>
			
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets pretty configuration data for this caching strategy.">
		
		<cfset var data = StructNew() />
		
		<cfset data["Scope"] = getScope() />
		<cfset data["Size"] = getSize() />
		<cfset data["Cache Enabled"] = YesNoFormat(isCacheEnabled()) />
		
		<cfreturn data />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="removeHashedKey" access="private" returntype="void" output="false"
		hint="Removes a cached element by hashed key.">
		<cfargument name="hashedKey" type="string" required="true"
			hint="The key must be hashed." />

		<cfset var dataStorage = getStorage() />

		<cfif StructKeyExists(dataStorage, arguments.hashedKey)>
			<cfset StructDelete(dataStorage, arguments.hashedKey, false) />
			<cfset getCacheStats().incrementEvictions(1) />
			<cfset getCacheStats().decrementTotalElements(1) />
			<cfset getCacheStats().decrementActiveElements(1) />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - UTIL
	--->
	<cffunction name="hashKey" access="private" returntype="string" output="false"
		hint="Creates a hashed version of the passed key.">
		<cfargument name="key" type="string" required="true" />
		<cfreturn Hash(UCase(Trim(arguments.key))) />
	</cffunction>
	
	<cffunction name="getCurrentTickCount" access="private" returntype="any" output="false"
		hint="Gets the current tick count.">
		<cfreturn getTickCount() />
	</cffunction>
	
	<cffunction name="getStorage" access="public" returntype="struct" output="false"
		hint="Gets a reference to the cache data storage.">
		<cfreturn StructGet(getScope() & "." & getScopeKey()) />
	</cffunction>
	
	<cffunction name="getNamedLockName" access="private" returntype="string" output="false"
		hint="Gets a named lock name based on choosen scope and other factors">
		<cfargument name="actionType" type="string" required="true" />
		
		<cfset var name = "_MachIILRUCache_" & arguments.actionType & "_" & getScopeKey() />
		
		<!--- We don't want all sessions to share the same named lock
			since they will run reap independently whereas reap 
			done in the application or server scopes will only run once --->
		<cfif getScope() EQ "session">
			<!--- Cannot directly access session scope because most CFML
			engine will throw an error if sessions are disabled --->
			<!--- A StructClear(session) eliminates the sessionId needed
				so only use it if it available, otherwise too bad for you
				as all repeats will be single threaded because we have no 
				unique identifier --->
			<cfif StructKeyExists(StructGet("session"), "sessionId")>
				<cfset name = name & "_" & StructGet("session").sessionId />
			</cfif>
		</cfif>

		<cfreturn name />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setSize" access="private" returntype="void" output="false">
		<cfargument name="size" type="numeric" required="true" />
		<cfset variables.instance.size = arguments.size />
	</cffunction>
	<cffunction name="getSize" access="public" returntype="string" output="false"
		hint="Returns the configured maximum size of the LRU cache.">
		<cfreturn variables.instance.size />
	</cffunction>

	<cffunction name="setScope" access="private" returntype="void" output="false">
		<cfargument name="scope" type="string" required="true" />
		<cfset variables.instance.scope = arguments.scope />
	</cffunction>
	<cffunction name="getScope" access="public" returntype="string" output="false"
		hint="Returns the scope where the LRU cache is stored.">
		<cfreturn variables.instance.scope />
	</cffunction>
	
	<cffunction name="setScopeKey" access="private" returntype="void" output="false">
		<cfargument name="scopeKey" type="string" required="true" />
		<cfset variables.instance.scopeKey = arguments.scopeKey />
	</cffunction>
	<cffunction name="getScopeKey" access="public" returntype="string" output="false"
		hint="Gets the unique cache key for this cache strategy.">
		<cfreturn variables.instance.scopeKey />
	</cffunction>
	
</cfcomponent>