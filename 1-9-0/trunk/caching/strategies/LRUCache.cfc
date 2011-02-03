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
	<cfset variables.system = CreateObject("java", "java.lang.System") />
	
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
			<cfset setScopeKey("_" & REReplaceNoCase(CreateUUID(), "[[:punct:]]", "", "ALL")) />
		</cfif>
		
		<!--- Setup the cache by running a flush() --->
		<cfset flush() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Puts data into the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key to used for the cache data. Key should not be pre-hashed." />
		<cfargument name="data" type="any" required="true"
			hint="The data to be put in the cache." />

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
			hint="The key to use to get data from the cache. Key should not be hashed." />

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
			hint="The key to use to check if the data is in the cache. Key should not be hashed." />
		<cfreturn StructKeyExists(getStorage(), hashKey(arguments.key)) />
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes data from the cache by key.">
		<cfargument name="key" type="string" required="true"
			hint="The key to use to remove the data from the cache. The key should not be hashed." />
		<cfset removeHashedKey(hashKey(arguments.key)) />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Looks at the timestamps of the cache pieces and throws out oldest one if the cache has more then the its max size.">
			
		<cfset var dataStorage = getStorage() />
		<cfset var sortedTimestamps = "" />
		<cfset var i = "" />
		
		<cfif (StructCount(dataStorage) + 1) GT getSize()>
	
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
		<cfset var elementExists = StructDelete(dataStorage, arguments.hashedKey, true) />

		<!--- Only update the cache stats if the element still existed (due to a possible race condition) --->
		<cfif elementExists>
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