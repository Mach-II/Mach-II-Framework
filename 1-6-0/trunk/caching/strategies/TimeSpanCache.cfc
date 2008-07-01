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

Scope
- The scope that the cache should be placed in.
- The default setting for "scope" is "application".
- Valid values are "application", "server" and "session".

ScopeKey
- The key place the cache in the choosen scope.
- Optional and by default the cache will be placed in scope._MachIICache.Hash(appKey & moduleName & cacheName)
- Rarely will this need to be used

Timespan
- Takes a string formatted like ColdFusion's createTimeSpan() function. The list is days, hours, minutes, seconds.
- Can also take "forever" for a non-expiring cache.
- The default is to cache for 1 hour.

CleanupIntervalInMinutes
- The interval of time in minutes in which to run the reap() method. Reap will
remove expired elements from the cache, but does not "refresh" the data. If an 
element is not available in the cache and an event-handler requests that data,
only that point will the data be "refreshed" and added back into the cache.
- The default setting for "cleanupIntervalInMinutes" is "3."
- Valid numeric value only.
- This attribute will rarely need to be changed.

Using all of the default settings will result in caching each element of data 
for 1 hour in the application scope. Expired cache elements will be cleaned up 
via reap() which is run every 3 minutes.

<property name="Caching" type="MachII.caching.CachingProperty">
      <parameters>
            <!-- Naming a default cache name is not required, but required if you do not want 
                 to specify the 'name' attribute in the cache command -->
            <parameter name="defaultCacheName" value="default" />
            <parameter name="default">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.TimeSpanCache" />
                        <key name="scope" value="application" />
                        <key name="timespan" value="0,1,0,0"/><!-- Cache for 1 hour -->
						<key name="cleanupIntervalInMinutes" value="3" />
                  </struct>
            </parameter>
      </parameters>
</property>
--->
<cfcomponent
 	displayname="TimeSpanCache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A caching strategy which uses a time span eviction policy.">

	<!---
	PROPERTIES
	--->
	<cfset variables.timespan = "" />
	<cfset variables.scope = "application" />
	<cfset variables.scopeKey = "" />
	<cfset variables.utils = CreateObject("component", "MachII.util.Utils").init() />
	<cfset variables.cleanupInterval = 3 />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.currentDateTime = "" />
	<cfset variables.lastCleanup = createTimestamp() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy.">

		<!--- Validate and set parameters --->
		<cfif isParameterDefined("timespan")>
			<cfif (getParameter("timespan") neq "forever" AND listLen(getParameter("timespan")) neq 4)
				OR listLen(getParameter("timespan")) neq 4>
				<cfthrow type="MachII.caching.strategies.TimeSpanCache"
					message="Invalid timespan of '#getParameter("timespan")#'."
					detail="Timespan must be set to 'forever' or a list of 4 numbers (days, hours, minutes, seconds)." />
			<cfelse>
				<cfset setTimespan(getParameter("timespan")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("scope")>
			<cfif NOT ListFindNoCase("application,server,session", getParameter("scope"))>
				<cfthrow type="MachII.caching.strategies.TimeSpanCache"
					message="Invalid Scope of '#getParameter("scope")#'."
					detail="Use 'application', 'server' or 'session'." />
			<cfelse>
				<cfset setScope(getParameter("scope")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("scopeKey")>
			<cfif NOT Len(getParameter("scopeKey"))>
				<cfthrow type="MachII.caching.strategies.TimeSpanCache"
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
		<cfif isParameterDefined("cleanupIntervalInMinutes")>
			<cfif NOT isNumeric(getParameter("cleanupIntervalInMinutes")) OR getParameter("cleanupIntervalInMinutes") LTE 0>
				<cfthrow type="MachII.caching.strategies.TimeSpanCache"
					message="Invalid CleanupIntervalInMinutes of '#getParameter("cleanupIntervalInMinutes")#'."
					detail="CleanupIntervalInMinutes must be numeric and greater than 0." />
			<cfelse>
				<cfset setCleanupInterval(getParameter("cleanupIntervalInMinutes")) />
			</cfif>
		</cfif>

		<cfset setThreadingAdapter(variables.utils.createThreadingAdapter()) />
		
		<!--- Setup and clear the cache by running a flush() --->
		<cfset flush() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Puts an element by key into the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key should not be a hashed key." />
		<cfargument name="data" type="any" required="true" />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var cacheElement = structNew() />
		
		<cfif NOT StructKeyExists(dataStorage.data, hashedKey)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		</cfif>
		<cfset cacheElement.data  = arguments.data />
		<cfset cacheElement.isStale = false />
		<cfset dataStorage.data[hashedKey] = cacheElement />
		<cfset dataStorage.timestamps[computeCacheUntilTimestamp() & "_" & hashedKey] = hashedKey />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets en element by key from the cache. Returns 'null' if the key is not in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key should not be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var cache = dataStorage.data />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var cacheElement = "" />
		
		<cfset shouldCleanup() />
		
		<cfif keyExists(arguments.key)>
			<cfset cacheElement = cache[hashedKey]>
			<cfif NOT cacheElement.isStale>
				<cfset getCacheStats().incrementCacheHits(1) />
				<cfreturn cacheElement.data />
			<cfelse>
				<cfset getCacheStats().incrementCacheMisses(1) />
			</cfif>
		<cfelse>
			<cfset getCacheStats().incrementCacheMisses(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false"
		hint="Flushes all elements from the cache.">
		
		<cfset var dataStorage = getStorage() />

		<cfset dataStorage.data = StructNew() />
		<cfset dataStorage.timestamps = StructNew() />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false"
		hint="Checks if an element exists by key in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key should not be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var timeStampKey = StructFindValue(dataStorage.timestamps, hashedKey, "one") />
		<cfset var diffTimestamp = createTimestamp() />
		<cfset var cacheElement = "" />

		<cfif NOT StructKeyExists(dataStorage.data, hashedKey)>
			<cfreturn false />
		<cfelseif (ListFirst(timeStampKey[1].key, "_") - diffTimestamp) LTE 0>
			<cfset remove(arguments.key) />
			<cfreturn false />
		<cfelseif StructKeyExists(dataStorage.data, hashedKey)>
			<cfset cacheElement = dataStorage.data[hashedKey] />
			<cfif cacheElement.isStale>
				<cfreturn false />
			<cfelse>
				<cfreturn true />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes data from the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key should not be a hashed key." />

		<cfset var hashedKey = hashKey(arguments.key) />
		
		<cfset removeByHashedKey(hashedKey) />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Inspects the timestamps of cached elements and throws out the expired ones.">
			
		<cfset var diffTimestamp = createTimestamp() />
		<cfset var dataStorage = getStorage() />
		<cfset var dataTimestampArray = "" />
		<cfset var key = "" />
		<cfset var i = "" />
		
		<cflock name="_MachIITimeSpanCacheCleanup_#getScopeKey()#" type="exclusive" timeout="5" throwontimeout="false">
			
			<!--- Reset the timestamp of the last cleanup --->
			<cfset variables.lastCleanup = createTimestamp() />
				
			<!--- Get array of timestamps and sort --->
			<cfset dataTimestampArray = StructKeyArray(dataStorage.timestamps) />
			<cfset ArraySort(dataTimestampArray, "textnocase", "asc") />
			
			<!--- Cleanup --->
			<cfloop from="1" to="#ArrayLen(dataTimestampArray)#" index="i">
				<cftry>
					<cfif (ListFirst(dataTimestampArray[i], "_") - diffTimestamp) LTE 0>
						<cfset key = listLast(dataTimestampArray[i], "_") />
						<cfset removeByHashedKey(key) />
					<cfelse>
						<cfbreak />
					</cfif>
					<cfcatch type="any">
						<!--- Ingore this error --->
					</cfcatch>
				</cftry>
			</cfloop>
		</cflock>
	</cffunction>
	 
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="removeByHashedKey" access="private" returntype="void" output="false"
		hint="Removes data from the cache by hashed key.">
		<cfargument name="hashedKey" type="string" required="true"
			hint="The passed key needs to be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var cache = dataStorage.data />
		<cfset var timeStampKey = "" />
		<cfset var cacheElement = "" />

		<cfif StructKeyExists(cache, arguments.hashedKey)>
			<cfset cacheElement = cache[arguments.hashedKey] />
			<cfif cacheElement.isStale>
				<cfset StructDelete(cache, arguments.hashedKey, false) />
				<cfset timeStampKey = StructFindValue(dataStorage.timestamps, arguments.hashedKey, "one") />
				<cfset StructDelete(dataStorage.timestamps, timeStampKey[1].key, false) />
				<cfset getCacheStats().incrementEvictions(1) />
				<cfset getCacheStats().decrementTotalElements(1) />
				<cfset getCacheStats().decrementActiveElements(1) />
			<cfelse>
				<cfset cacheElement.isStale = true />
				<cfset getCacheStats().decrementActiveElements(1) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="shouldCleanup" access="private" returntype="void" output="false"
		hint="Cleanups the data storage.">
		
		<cfset var diffTimestamp = createTimestamp(DateAdd("n", - getCleanupInterval(), getCurrentDateTime())) />
		<cfset var threadingAdapter = "" />
		
		<cfif (diffTimestamp - variables.lastCleanup) GTE 0>
		
			<cfset threadingAdapter = getThreadingAdapter() />
			
			<cflock name="_MachIITimespanCacheCleanup_#getScopeKey()#" type="exclusive" timeout="5" throwontimeout="false">
				<cfif (diffTimestamp - variables.lastCleanup) GTE 0>
					<cfif threadingAdapter.allowThreading()>
						<cfset threadingAdapter.run(this, "reap") />
					<cfelse>
						<cfset reap() />
					</cfif>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>
	
	<cffunction name="hashKey" access="private" returntype="string" output="false"
		hint="Creates a hash from a key name.">
		<cfargument name="key" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.key)) />
	</cffunction>
	
	<cffunction name="createTimestamp" access="private" returntype="string" output="false"
		hint="Creates a timestamp which is safe to use as a key.">
		<cfargument name="time" type="date" required="false" default="#getCurrentDateTime()#" />
		<cfreturn REReplace(arguments.time, "[ts[:punct:][:space:]]", "", "ALL") />
	</cffunction>
	
	<cffunction name="computeCacheUntilTimestamp" access="private" returntype="string" output="false"
		hint="Computes a cache until timestamp for this cache block.">
		
		<cfset var timestamp = Now() />
		<cfset var timespan = getTimespan() />
		
		<cfif timespan EQ "forever">
			<cfset timestamp = DateAdd("yyyy", 100, timestamp) />
		<cfelse>
			<cfif listGetAt(timespan, 4) gt 0>
				<cfset timestamp = DateAdd("s", listGetAt(timespan, 4), timestamp) />
			</cfif>
			<cfif listGetAt(timespan, 3) gt 0>
				<cfset timestamp = DateAdd("n", listGetAt(timespan, 3), timestamp) />
			</cfif>
			<cfif listGetAt(timespan, 2) gt 0>
				<cfset timestamp = DateAdd("h", listGetAt(timespan, 2), timestamp) />
			</cfif>
			<cfif listGetAt(timespan, 1) gt 0>
				<cfset timestamp = DateAdd("d", listGetAt(timespan, 1), timestamp) />
			</cfif>
		</cfif>
		
		<cfreturn createTimestamp(timestamp) />
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
	<cffunction name="setTimespan" access="private" returntype="void" output="false">
		<cfargument name="timespan" type="string" required="true" />
		<cfset variables.timespan = arguments.timespan />
	</cffunction>
	<cffunction name="getTimespan" access="public" returntype="string" output="false">
		<cfreturn variables.timespan />
	</cffunction>

	<cffunction name="getCurrentDateTime" access="public" returntype="date" output="false"
		hint="Used internally for unit testing.">
		<cfif IsDate(variables.currentDateTime)>
			<cfreturn variables.currentDateTime />
		<cfelse>
			<cfreturn Now() />
		</cfif>
	</cffunction>
	<cffunction name="setCurrentDateTime" access="public" returntype="void" output="false" 
		hint="Used internally for unit testing.">
		<cfargument name="currentDateTime" type="string" required="true" />
		<cfset variables.currentDateTime = arguments.currentDateTime />
	</cffunction>

	<cffunction name="setScope" access="private" returntype="void" output="false">
		<cfargument name="scope" type="string" required="true" />		
		<cfset variables.scope = arguments.scope />
	</cffunction>
	<cffunction name="getScope" access="public" returntype="string" output="false">
		<cfreturn variables.scope />
	</cffunction>

	<cffunction name="setScopeKey" access="private" returntype="void" output="false">
		<cfargument name="scopeKey" type="string" required="true" />
		<cfset variables.scopeKey = arguments.scopeKey />
	</cffunction>
	<cffunction name="getScopeKey" access="private" returntype="string" output="false">
		<cfreturn variables.scopeKey />
	</cffunction>

	<cffunction name="setCleanupInterval" access="private" returntype="void" output="false">
		<cfargument name="cleanupInterval" type="numeric" required="true" />		
		<cfset variables.cleanupInterval = arguments.cleanupInterval />
	</cffunction>
	<cffunction name="getCleanupInterval" access="public" returntype="numeric" output="false">
		<cfreturn variables.cleanupInterval />
	</cffunction>
	
	<cffunction name="setThreadingAdapter" access="private" returntype="void" output="false">
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />
		<cfset variables.threadingAdapter = arguments.threadingAdapter />
	</cffunction>
	<cffunction name="getThreadingAdapter" access="private" returntype="MachII.util.threading.ThreadingAdapter" output="false">
		<cfreturn variables.threadingAdapter />
	</cffunction>
	
</cfcomponent>