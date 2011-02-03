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
Updated version: 1.8.1

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

CachingEnabled
- Set whether caching enabled or disabled.
- The default setting is "true".
- Accepts a boolean or a struct of environments with corresponding booleans.

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
 	displayname="TimeSpanCache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A caching strategy which uses a time span eviction policy.">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance.strategyTypeName = "Time Span" />
	<cfset variables.instance.timespan = createBigInteger("3600000") /><!--- Default to 1 hour --->
	<cfset variables.instance.timespanString =  "0,1,0,0" /><!--- Default to 1 hour --->
	<cfset variables.instance.scope = "application" />
	<cfset variables.instance.scopeKey = "" />
	<cfset variables.instance.cleanupInterval = createBigInteger("180000") /><!--- Default to 3 minutes --->
	
	<cfset variables.currentTickCount = "" />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.utils = CreateObject("component", "MachII.util.Utils").init("false") />
	<cfset variables.system = CreateObject("java", "java.lang.System") />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy.">

		<!--- Validate and set parameters --->
		<cfif isParameterDefined("timespan")
			AND getAssert().isTrue(getParameter("timespan") EQ "forever" OR ListLen(getParameter("timespan")) EQ 4
				, "Invalid timespan of '#getParameter("timespan")#'."
				, "Timespan must be set to 'forever' or a list of 4 numbers (days, hours, minutes, seconds).")>
			<cfset setTimespanString(getParameter("timespan")) />
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
			<cfset setScopeKey("_" & REReplaceNoCase(CreateUUID(), "[[:punct:]]", "", "ALL")) />
		</cfif>
		<cfif isParameterDefined("cleanupIntervalInMinutes")
			AND getAssert().isTrue(IsNumeric(getParameter("cleanupIntervalInMinutes")) AND getParameter("cleanupIntervalInMinutes") GT 0
				, "Invalid CleanupIntervalInMinutes of '#getParameter("cleanupIntervalInMinutes")#'."
				, "CleanupIntervalInMinutes must be numeric and greater than 0.")>
			<cfset setCleanupInterval(getParameter("cleanupIntervalInMinutes")) />
		</cfif>

		<cfset setThreadingAdapter(variables.utils.createThreadingAdapter()) />
		
		<!--- Setup the cache by running a flush() --->
		<cfset flush() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Puts an element by key into the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key to put the data in the cache. The key should not be a hashed key." />
		<cfargument name="data" type="any" required="true"
			hint="The data to cache." />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var cacheElement = StructNew() />
		<cfset var cacheUntilTimestamp = computeCacheUntilTimestamp() />
		
		<!--- Only increment if the element did not previous exist in the cache --->
		<cfif NOT StructKeyExists(dataStorage, hashedKey)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		<cfelse>
			<cfif dataStorage[hashedKey].isStale>
				<cfset getCacheStats().incrementActiveElements(1) />
			</cfif>
		</cfif>
		
		<!--- Build the cache element --->
		<cfset cacheElement.data  = arguments.data />
		<cfset cacheElement.isStale = false />
		<cfset cacheElement.timestamp = cacheUntilTimestamp />
		
		<cfset dataStorage[hashedKey] = cacheElement />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets en element by key from the cache. Returns 'null' if the key is not in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key to get the data from the cache. The key should not be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var cacheElement = "" />
		
		<cfset shouldCleanup() />
		
		<cfif keyExists(arguments.key)>
			<cfset cacheElement = dataStorage[hashedKey]>

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
		
		<cfset StructClear(dataStorage) />

		<cfset getCacheStats().reset() />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="any" output="false"
		hint="Checks if an element exists by key in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The key to check if the data exists in the cache. The key should not be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var cacheElement = "" />

		<cfif NOT StructKeyExists(dataStorage, hashedKey)>
			<cfreturn false />
		<cfelse>
			<cfset cacheElement = dataStorage[hashedKey] />
			
			<cfif cacheElement.isStale>
				<cfreturn false />
			<cfelseif cacheElement.timestamp.compareTo(getCurrentTickCount()) LT 1>
				<cfset removeByHashedKey(hashedKey) />
				<cfreturn false />
			<cfelse>
				<cfreturn true />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes data from the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key to use to remove data from the cache. The key should not be a hashed key." />
		<cfset removeByHashedKey(hashKey(arguments.key)) />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Inspects the timestamps of cached elements and throws out the expired ones.">
			
		<cfset var currentTick = getCurrentTickCount() />
		<cfset var dataStorage = getStorage() />
		<cfset var keyArray = "" />
		<cfset var i = "" />
		<cfset var count = 0 />
		
		<!---
		It is ok to have nested lock if we are already in an excluse lock from shouldCleanup()
		--->
		<cflock name="#getNamedLockName("cleanup")#" 
			type="exclusive" 
			timeout="1" 
			throwontimeout="false">
			
			<!--- Reset the timestamp of the last cleanup --->
			<cfset dataStorage._lastCleanup = currentTick />
			
			<cfset keyArray = StructKeyArray(dataStorage) />
			
			<!--- Cleanup --->
			<cfloop from="1" to="#ArrayLen(keyArray)#" index="i">
				<cftry>
					<cfif currentTick.compareTo(dataStorage[keyArray[i]].timestamp) GT 0>
						<cfset removeByHashedKey(keyArray[i]) />
					</cfif>
					<cfcatch type="any">
						<!--- Do nothing --->
					</cfcatch>
				</cftry>
			</cfloop>
		</cflock>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets pretty configuration data for this caching strategy.">
		
		<cfset var data = StructNew() />
		<cfset var cleanupInterval = getCleanupInterval() />
		
		<cfset data["Scope"] = getScope() />
		<cfset data["Cache Enabled"] = YesNoFormat(isCacheEnabled()) />
		<cfset data["Timespan"] = getTimespanString() />
		<cfset data["Cleanup Interval"] = cleanupInterval.divide(createBigInteger(60000)).toString() & " minutes" />
		
		<cfreturn data />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="removeByHashedKey" access="private" returntype="void" output="false"
		hint="Removes data from the cache by hashed key.">
		<cfargument name="hashedKey" type="string" required="true"
			hint="The passed key needs to be a hashed key." />

		<cfset var dataStorage = getStorage() />
		<cfset var cacheElement = "" />
		<cfset var elementExists = "" />

		<cfif StructKeyExists(dataStorage, arguments.hashedKey)>
			<cfset cacheElement = dataStorage[arguments.hashedKey] />
			
 			<cfif cacheElement.isStale>
				<cfset elementExists = StructDelete(dataStorage, arguments.hashedKey, true) />

				<!--- Only update the cache stats if the element still existed (due to a possible race condition) --->
				<cfif elementExists>
					<cfset getCacheStats().incrementEvictions(1) />
					<cfset getCacheStats().decrementTotalElements(1) />
				</cfif>
			<cfelse>
				<cfset cacheElement.isStale = true />
				<cfset getCacheStats().decrementActiveElements(1) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="shouldCleanup" access="private" returntype="void" output="false"
		hint="Cleanups the data storage.">
		
		<cfset var diffTimestamp = getCurrentTickCount() />
		<cfset var dataStorage = getStorage() />		
		
		<!--- No point in running periodic cleanups if the cache lasts "forever" --->
		<cfif getTimespanString() NEQ "forever">
		
			<cfset diffTimestamp = diffTimestamp.subtract(getCleanupInterval()) />
			
			<!--- Ensure that the lastCleanup is available --->
			<cfparam name="dataStorage._lastCleanup" default="#getCurrentTickCount()#" />
			
			<cfif diffTimestamp.compareTo(dataStorage._lastCleanup) GT 0>
				<!---
				Don't wait because an exclusive lock that has already been obtained
				indicates that a reap is in progress and we should not wait for the
				second check in the double-lock-check routine
				Setting the timeout to 0 indicates to wait indefinitely
				--->
				<cflock name="#getNamedLockName("cleanup")#" 
						type="exclusive" 
						timeout="1" 
						throwontimeout="false">
					<cfif diffTimestamp.compareTo(dataStorage._lastCleanup) GT 0>
						<cfif getThreadingAdapter().allowThreading()>
							<!---
							We have to set last cleanup here because reaping in a thread
							may not be immediate
							--->
							<cfset dataStorage._lastCleanup = getCurrentTickCount() />
							<cfset getThreadingAdapter().run(this, "reap") />
						<cfelse>
							<cfset reap() />
						</cfif>
					</cfif>
				</cflock>
			</cfif>
		
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - UTIL
	--->
	<cffunction name="hashKey" access="private" returntype="string" output="false"
		hint="Creates a hash from a key name.">
		<cfargument name="key" type="string" required="true"
			hint="The key to hash." />
		<cfreturn Hash(UCase(Trim(arguments.key))) />
	</cffunction>
	
	<cffunction name="computeCacheUntilTimestamp" access="private" returntype="any" output="false"
		hint="Computes a cache until timestamp in ms.">

		<cfset var timestamp = getCurrentTickCount() />
		
		<!--- Add the timespan offset to the current tick count --->
		<cfset timestamp = timestamp.add(getTimespan()) />
			
		<cfreturn timestamp />
	</cffunction>

	<cffunction name="getStorage" access="private" returntype="struct" output="false"
		hint="Gets a reference to the cache data storage.">
		<cfreturn StructGet(getScope() & "." & getScopeKey()) />
	</cffunction>
	
	<cffunction name="getNamedLockName" access="private" returntype="string" output="false"
		hint="Gets a named lock name based on choosen scope and other factors">
		<cfargument name="actionType" type="string" required="true" />
		
		<cfset var name = "_MachIITimeSpanCache_" & arguments.actionType & "_" & getScopeKey() />
		
		<!---
		We don't want all sessions to share the same named lock
		since they will run reap independently whereas reap 
		done in the application or server scopes will only run once
		--->
		<cfif getScope() EQ "session">
			<!---
			We used to use session.sessionId however that was problematic 
			if StructClear() was ever used the on the session.
			
			We now use the system identity hash code on the data storage struct
			as an unique id.
			--->
			<cfset name = name & "_" & variables.system.identityHashCode(getStorage()) />
		</cfif>

		<cfreturn name />
	</cffunction>
	
	<cffunction name="createBigInteger" access="private" returntype="any" output="false"
		hint="Helper method that creates a java.math.BigInteger with the passed value.">
		<cfargument name="value" type="any" required="true" />
		<cfreturn CreateObject("java", "java.math.BigInteger").init(arguments.value) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setTimespan" access="private" returntype="void" output="false"
		hint="Sets and builds a timespan in ms.">
		<cfargument name="timespan" type="string" required="true"
			hint="Must be in format of 0,0,0,0 (days,hours,minutes,seconds) or 'forever'." />
		
		<cfset var offset = "" />
		<cfset var value = "" />
		
		<cfif arguments.timespan EQ "forever">
			<cfset offset = createBigInteger("1228000000000") />
		<cfelse>
			<cfset offset = createBigInteger(variables.utils.convertTimespanStringToSeconds(arguments.timespan)) />
		</cfif>
				
		<cfset variables.instance.timespan = offset />
	</cffunction>
	<cffunction name="getTimespan" access="public" returntype="any" output="false"
		hint="Gets the timespan interval which is of type java.lang.BigInteger">
		<cfreturn variables.instance.timespan />
	</cffunction>

	<cffunction name="setTimespanString" access="private" returntype="void" output="false"
		hint="Sets a timespan string.">
		<cfargument name="timespanString" type="string" required="true"
			hint="Must be in format of 0,0,0,0 (days,hours,minutes,seconds) or 'forever'." />
		<cfset variables.instance.timespanString = arguments.timeSpanString />
		<cfset setTimespan(arguments.timespanString) />
	</cffunction>
	<cffunction name="getTimespanString" access="public" returntype="string" output="false">
		<cfreturn variables.instance.timespanString />
	</cffunction>

	<cffunction name="getCurrentTickCount" access="public" returntype="any" output="false"
		hint="Gets the current tick count as a big integer.  Has logic that is that is used internally for unit testing.">
		<cfif Len(variables.currentTickCount)>
			<cfreturn createBigInteger(variables.currentTickCount) />
		<cfelse>
			<cfreturn createBigInteger(getTickCount()) />
		</cfif>
	</cffunction>
	<cffunction name="setCurrentTickCount" access="public" returntype="void" output="false" 
		hint="Used internally for unit testing. Set to '' when you want to use the current tick count.">
		<cfargument name="currentTickCount" type="string" required="true" />
		<cfset variables.currentTickCount = arguments.currentTickCount />
	</cffunction>

	<cffunction name="setScope" access="private" returntype="void" output="false">
		<cfargument name="scope" type="string" required="true" />		
		<cfset variables.instance.scope = arguments.scope />
	</cffunction>
	<cffunction name="getScope" access="public" returntype="string" output="false">
		<cfreturn variables.instance.scope />
	</cffunction>

	<cffunction name="setScopeKey" access="private" returntype="void" output="false">
		<cfargument name="scopeKey" type="string" required="true" />
		<cfset variables.instance.scopeKey = arguments.scopeKey />
	</cffunction>
	<cffunction name="getScopeKey" access="private" returntype="string" output="false">
		<cfreturn variables.instance.scopeKey />
	</cffunction>

	<cffunction name="setCleanupInterval" access="private" returntype="void" output="false"
		hint="Sets and converts the incoming minutes into ms.">
		<cfargument name="cleanupInterval" type="numeric" required="true"
			hint="Cleanup interval in minutes." />		
		
		<cfset var interval = createBigInteger(arguments.cleanupInterval) />
		
		<cfset interval = interval.multiply(variables.MINUTE) />
		
		<cfset variables.instance.cleanupInterval = interval />
	</cffunction>
	<cffunction name="getCleanupInterval" access="public" returntype="any" output="false"
		hint="Cleanup interval in ms.">
		<cfreturn variables.instance.cleanupInterval />
	</cffunction>
	
	<cffunction name="setThreadingAdapter" access="private" returntype="void" output="false">
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />
		<cfset variables.threadingAdapter = arguments.threadingAdapter />
	</cffunction>
	<cffunction name="getThreadingAdapter" access="private" returntype="MachII.util.threading.ThreadingAdapter" output="false">
		<cfreturn variables.threadingAdapter />
	</cffunction>
	
</cfcomponent>