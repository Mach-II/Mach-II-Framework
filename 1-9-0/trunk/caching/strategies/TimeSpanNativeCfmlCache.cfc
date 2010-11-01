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

Author: Joe Roberts (jroberts1@gmail.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
Engine Compatibility:
 * Adobe ColdFusion 9 - no named caches
 * Adobe ColdFusion 9.01 - allows named caches
 * Railo 3
 * Open BlueDragon 1.4

Known Issues:
- The eviction count in the cache stats will always remain at 0 because no CFML engine exposes that metadata
in an easy to use way.

Configuration parameters

CacheName
- Defines a named cache

Timespan
- Takes a string formatted like ColdFusion's createTimeSpan() function. The list is days, hours, minutes, seconds.
- The default is to cache for 1 hour.

IdleTimespan
- Takes a string formatted like ColdFusion's createTimeSpan() function. The list is days, hours, minutes, seconds.
- The default is to cache for 1 hour.

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
                        <key name="type" value="TimeSpanNativeCfmlCache" />
                        <key name="cacheName" value=""/>
                        <key name="timespan" value="0,1,0,0"/><!-- Cache for 1 hour -->
						<key name="idleTimespan" value="0,1,0,0" />
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
 	displayname="TimespanNativeCfmlStrategy"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A caching strategy that uses a cfml engine's native CachePut and CacheGet methods.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.reapImplemented = false />
	<cfset variables.instance.strategyTypeName = "Time Span Native CFML" />
	<cfset variables.instance.cacheName = "" />
	<cfset variables.instance.timespan = "" />
	<cfset variables.instacne.timespanString = "" />
	<cfset variables.instance.idleTimespan = "" />
	<cfset variables.instance.idleTimespanString = "" />
	<cfset variables.instance.useNamedCache = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy. Override to provide custom functionality.">
		
		<cfset var utils = CreateObject("component", "MachII.util.Utils").init(false) />
		<cfset var engineInfo = utils.getCfmlEngineInfo() />
		
		<!--- Optional: Specify the name of which cache to use - not supported by all cfml engines. To disable named caches, either specify an empty string, or don't provide this parameter. --->
		<cfif isParameterDefined("cacheName")>
			<cfset setCacheName(getParameter("cacheName")) />
		</cfif>
		
		<!--- The duration until the object is flushed from the cache --->
		<cfif isParameterDefined("timespan")
			AND getAssert().isTrue(listLen(getParameter("timespan")) eq 4
				, "Invalid timespan of '#getParameter("timespan")#'."
				, "Timespan must be set to a list of 4 numbers (days, hours, minutes, seconds).")>
			<cfset setTimespanString(getParameter("timespan")) />
		<cfelse>
			<cfset setTimespanString("0,1,0,0") />
		</cfif>
		
		<!--- A duration after which the object is flushed from the cache if it is not accessed during that time --->
		<cfif isParameterDefined("idleTimespan") 
			AND getAssert().isTrue(listLen(getParameter("idleTimespan")) eq 4
				, "Invalid idleTimespan of '#getParameter("idleTimespan")#'."
				, "IdleTimespan must be set to a list of 4 numbers (days, hours, minutes, seconds).")>
			<cfset setIdleTimespanString(getParameter("idleTimespan")) />
		<cfelse>
			<cfset setIdleTimespanString("0,1,0,0") />
		</cfif>
		
		<!--- ACF9 does not support cacheClear() so replace flush with a special method --->
		<cfif FindNoCase("ColdFusion", engineInfo.Name) AND engineInfo.majorVersion GTE 9>
			<cfset this.flush = this.flush_cf />
			<cfset variables.flush = variables.flush_cf />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false" 
		hint="Puts an element by key into the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The unique key for the data to put in the cache." />
		<cfargument name="data" type="any" required="true"
			hint="The data to cache." />
		
		<cfset var hashedKey = hashKey(arguments.key) />
		
		<!--- update the cache stats --->
		<cfif NOT keyExists(arguments.key)>
			<cfset getCacheStats().incrementTotalElements(1) />
			<cfset getCacheStats().incrementActiveElements(1) />
		<cfelse>
			<cfset getCacheStats().incrementActiveElements(1) />
		</cfif>
		
		<!--- write the element to the cache --->
		<cfif variables.instance.useNamedCache>
			<cfset CachePut(hashedKey, arguments.data, getTimespan(), getIdleTimespan(), getCacheName()) />
		<cfelse>
			<cfset CachePut(hashedKey, arguments.data, getTimespan(), getIdleTimespan()) />
		</cfif>
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Gets an element by key from the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The unique key for the data to get from the cache." />

		<!--- create a hash of the key (so it's compatible with different cache stores) --->
		<cfset var hashedKey = hashKey(arguments.key) />
		<cfset var element = "" />
		
		<!--- attempt to retrieve the element --->
		<cfif variables.instance.useNamedCache>
			<cfset element = CacheGet(hashedKey, false, getCacheName()) />
		<cfelse>
			<cfset element = CacheGet(hashedKey) />
		</cfif>
		
		<!--- if the requested element is in the cache, return it --->
		<cfif IsDefined("element")>
			<cfset getCacheStats().incrementCacheHits(1) />
			<cfreturn element />
		<cfelse>
			<cfset getCacheStats().incrementCacheMisses(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="flush_cf" access="public" returntype="void" output="false"
		hint="Flushes all elements from the cache for Adobe ColdFusion. This method dynamically replaces flush() if ACF9+ is used.">
		
		<cfset var ids = "" />
		<cfset var cacheName = getCacheName() />
		<cfset var i = 0 />
				
		<!--- clear this cache store --->
		<cfif variables.instance.useNamedCache>
			<cfset ids = CacheGetAllIds(cacheName) />
			<cfloop from="1" to="#ArrayLen(ids)#" index="i">
				<cfset CacheRemove(ids[i], false, cacheName) />
			</cfloop>
		<cfelse>
			<cfset ids = CacheGetAllIds() />
			<cfloop from="1" to="#ArrayLen(ids)#" index="i">
				<cfset CacheRemove(ids[i], false) />
			</cfloop>
		</cfif>

		<cfset getCacheStats().reset() />
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false"
		hint="Flushes all elements from the cache for Railo and OpenBD. This is dynanically replaces by flush_cf() if ACF9+ is used.">
		
		<!--- clear this cache store --->
		<cfif variables.instance.useNamedCache>
			<cfset CacheClear("", getCacheName()) />
		<cfelse>
			<cfset CacheClear() />
		</cfif>
		
		<cfset getCacheStats().reset() />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Reaps 'expired' cache elements. Throws 'MachII.caching.strategies.NotImplemented' intentionally as this method is not implemented.">
		<cfthrow type="MachII.caching.strategies.NotImplemented" 
			message="Reaping expired cache elements is handled natively in 'TimeSpanNativeCfmlCache'."
			detail="This exception is intentional as the reap method has not been implemented." />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false"
		hint="Checks if an element exists by key in the cache.">
		<cfargument name="key" type="string" required="true"
			hint="The unique key for the data to check if it is in the cache." />	
		<cfif variables.instance.useNamedCache>
			<cfreturn CacheKeyExists(hashKey(arguments.key), getCacheName()) />
		<cfelse>
			<cfreturn CacheKeyExists(hashKey(arguments.key)) />
		</cfif>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false"
		hint="Removes a cached element by key.">
		<cfargument name="key" type="string" required="true"
			hint="The unique key for the data to remove from the cache." />

		<!--- Remove this element from the cache --->
		<cfif variables.instance.useNamedCache>
			<cfset CacheRemove(hashKey(arguments.key), false, getCacheName()) />
		<cfelse>
			<cfset CacheRemove(hashKey(arguments.key), false) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets pretty configuration data for this caching strategy.">
		
		<cfset var data = StructNew() />
		
		<cfset data["Cache Enabled"] = YesNoFormat(isCacheEnabled()) />
		<cfset data["Cache Name"] = getCacheName() />
		<cfset data["Timespan"] = getTimespanString() />
		<cfset data["Idle Timespan"] = getIdleTimespanString() />
		
		<cfreturn data />
	</cffunction>
	
	<!---
	PRIVATE FUNCTIONS - UTILS
	--->
	<cffunction name="hashKey" access="private" returntype="string" output="false"
		hint="Creates a hash from a key name.">
		<cfargument name="key" type="string" required="true"
			hint="The key to hash." />
		<cfreturn Hash(UCase(Trim(arguments.key))) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setCacheName" access="private" returntype="void" output="false" 
		hint="Sets the name of the custom cache to use.">
		<cfargument name="cacheName" type="string" required="true" 
			hint="Custom cache name - must be defined in your CFML engine's admin" />
		
		<!--- Set flag on usage of named cache --->
		<cfif Len(arguments.cacheName)>
			<cfset variables.instance.useNamedCache = true />
		<cfelse>
			<cfset variables.instance.useNamedCache = false />
		</cfif>
		
		<cfset variables.instance.cacheName = arguments.cacheName />
	</cffunction>
	<cffunction name="getCacheName" access="public" returntype="any" output="false" 
		hint="Sets the name of the custom cache to use.">
		<cfreturn variables.instance.cacheName />
	</cffunction>
	
	<cffunction name="setTimespan" access="private" returntype="void" output="false" 
		hint="Sets a timespan for the cache - the max duration it can live in the cache before it is flushed.">
		<cfargument name="timespan" type="string" required="true" 
			hint="Must be in format of 0,0,0,0 (days,hours,minutes,seconds)." />
		<cfset variables.instance.timespan = createTimeSpan( 
			listGetAt(arguments.timespan, 1),
			listGetAt(arguments.timespan, 2),
			listGetAt(arguments.timespan, 3),
			listGetAt(arguments.timespan, 4)) />
	</cffunction>
	<cffunction name="getTimespan" access="public" returntype="any" output="false" 
		hint="Gets the timespan duration.">
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
	
	<cffunction name="setIdleTimespan" access="private" returntype="void" output="false" 
		hint="Sets a timespan for the idle timeout - if an element in the cache hasn't been accessed for this period of time, it is flushed.">
		<cfargument name="timespan" type="string" required="true"
			hint="Must be in format of 0,0,0,0 (days,hours,minutes,seconds)." />
		<cfset variables.instance.idleTimespan = createTimeSpan( 
			listGetAt(arguments.timespan, 1),
			listGetAt(arguments.timespan, 2),
			listGetAt(arguments.timespan, 3),
			listGetAt(arguments.timespan, 4)) />
	</cffunction>
	<cffunction name="getIdleTimespan" access="public" returntype="any" output="false" 
		hint="Gets the timespan duration">
		<cfreturn variables.instance.idleTimespan />
	</cffunction>
	
	<cffunction name="setIdleTimespanString" access="private" returntype="void" output="false"
		hint="Sets an idle timespan string.">
		<cfargument name="idleTimespanString" type="string" required="true"
			hint="Must be in format of 0,0,0,0 (days,hours,minutes,seconds) or 'forever'." />
		<cfset variables.instance.idleTimespanString = arguments.idleTimespanString />
		<cfset setIdleTimespan(arguments.idleTimespanString) />
	</cffunction>
	<cffunction name="getIdleTimespanString" access="public" returntype="string" output="false">
		<cfreturn variables.instance.idleTimespanString />
	</cffunction>
	
</cfcomponent>