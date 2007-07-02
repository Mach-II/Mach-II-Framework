<!---
License:
Copyright 2007 GreatBizTools, LLC

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
$Id$

Created version: 1.5.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent
	displayname="CacheHandler"
	output="false"
	hint="Holds configuration and cache data.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commands = ArrayNew(1) />
	<cfset variables.handlerId = CreateUUID() />
	<cfset variables.storage = "" />
	<cfset variables.type = "" />
	<cfset variables.cacheFor = "" />
	<cfset variables.cacheForUnit = "" />
	<cfset variables.cache = StructNew() />
	<cfset variables.cacheOutputBuffer = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheHandler" output="false"
		hint="Initializes the handler.">
		<cfargument name="storage" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="cacheFor" type="string" required="false" default="" />
		<cfargument name="cacheForUnit" type="string" required="false" default="" />
	
		<!--- run setters --->
		<cfset setStorage(arguments.storage) />
		<cfset setType(arguments.type) />
		<cfset setCacheFor(arguments.cacheFor) />
		<cfset setCacheForUnit(arguments.cacheForUnit) />
		
		<!--- setup --->
		<cfset setHasCache(false) />
		<cfset setCacheData(StructNew()) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleCache" access="public" returntype="boolean" output="true"
		hint="Handles a Subroutine.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var outputBuffer = "" />
		<cfset var continue = true />
		<cfset var command = "" />
		<cfset var i = 0 />
		
		<!--- We have nothing in the cache or it is too old --->
		<cfif NOT useCache()>
			 
			<cfsavecontent variable="outputBuffer">
				<cfloop index="i" from="1" to="#ArrayLen(variables.commands)#">
					<cfset command = variables.commands[i] />
					<cfset continue = command.execute(arguments.event, arguments.eventContext) />
					<cfif continue IS false>
						<cfbreak />
					</cfif>
				</cfloop>
			</cfsavecontent>
			
			<!--- Grab the change data and cache it for later --->
			<cfset setCacheData(arguments.event.getArgs()) />
			<cfset setCacheOutputBuffer(outputBuffer) />
			<cfset setHasCache(true) />
			
			<cfoutput>#getCacheOutputBuffer()#</cfoutput>
		<!--- Replay the event from the cache --->
		<cfelse>
			<cfset arguments.event.setArgs(getCacheData()) />
			<cfoutput>#getCacheOutputBuffer()#</cfoutput>
		</cfif>
		
		<cfreturn continue />
	</cffunction>

	<cffunction name="addCommand" access="public" returntype="void" output="false"
		hint="Adds a Command.">
		<cfargument name="command" type="MachII.framework.Command" required="true" />
		<cfset ArrayAppend(variables.commands, arguments.command) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="useCache" access="private" returntype="boolean" output="false"
		hint="Checks if the cache should be used.">
		<cfif NOT getHasCache() OR DateCompare(Now(), computeCacheUntilTimestamp()) GTE 0>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
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
			<cfset timestamp = DateAdd("y", cacheFor, timestamp) />
		<cfelse>
			<cfthrow type="MachII.framework.CacheHandler"
				message="Invalid CacheForUnit of '#unit#'. Use 'seconds, 'minutes', 'hours', 'days' or 'forever'." />
		</cfif>
		
		<cfreturn timestamp />
	</cffunction>
	
	<cffunction name="getCacheStorage" access="private" returntype="struct" output="false"
		hint="Gets the cach storage which is dependent on the storage location.">
		
		<cfset var storage = "" />
		
		<cfif getType() EQ "application">
			<cfset storage = variables.cache />
		<cfelseif getType() EQ "session">
			<cfset storage = StructGet("session") />
			
			<cfif NOT StructKeyExists(storage, "_MachIICache.#getHandlerId()#")>
				<cfset storage._MachIICache[getHandlerId()] = StructNew() />
			</cfif>
			
			<cfset storage = storage._MachIICache[getHandlerId()] />
		</cfif>
		
		<cfreturn storage />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="getHandlerId" access="public" returntype="uuid" output="false"
		hint="Returns the handler id.">
		<cfreturn variables.handlerId />
	</cffunction>

	<cffunction name="setStorage" access="private" returntype="void" output="false">
		<cfargument name="storage" type="string" required="true" />
		<cfset variables.storage = arguments.storage />
	</cffunction>
	<cffunction name="getStorage" access="public" returntype="string" output="false">
		<cfreturn variables.storage />
	</cffunction>

	<cffunction name="setType" access="private" returntype="void" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset variables.type = arguments.type />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.type />
	</cffunction>

	<cffunction name="setCacheFor" access="private" returntype="void" output="false">
		<cfargument name="cacheFor" type="string" required="true" />
		<cfset variables.cacheFor = arguments.cacheFor />
	</cffunction>
	<cffunction name="getCacheFor" access="public" returntype="string" output="false">
		<cfreturn variables.cacheFor />
	</cffunction>

	<cffunction name="setCacheForUnit" access="private" returntype="void" output="false">
		<cfargument name="cacheForUnit" type="string" required="true" />
		<cfset variables.cacheForUnit = arguments.cacheForUnit />
	</cffunction>
	<cffunction name="getCacheForUnit" access="public" returntype="string" output="false">
		<cfreturn variables.cacheForUnit />
	</cffunction>
	
	<cffunction name="setHasCache" access="private" returntype="void" output="false">
		<cfargument name="hasCache" type="boolean" required="true" />
		
		<cfset var storage = getCacheStorage() />
		
		<cfset storage.hasCache = arguments.hasCache />
	</cffunction>
	<cffunction name="getHasCache" access="public" returntype="boolean" output="false">
		<cfset var storage = getCacheStorage() />
		
		<cfreturn storage.hasCache />
	</cffunction>
	
	<cffunction name="setCacheData" access="private" returntype="void" output="false">
		<cfargument name="cacheData" type="struct" required="true" />

		<cfset var storage = getCacheStorage() />

		<cfset storage.cacheData = arguments.cacheData />
	</cffunction>
	<cffunction name="getCacheData" access="public" returntype="struct" output="false">
	
		<cfset var storage = getCacheStorage() />
	
		<cfreturn storage.cacheData />
	</cffunction>
	
	<cffunction name="setCacheOutputBuffer" access="private" returntype="void" output="false">
		<cfargument name="cacheOutputBuffer" type="string" required="true" />

		<cfset var storage = getCacheStorage() />

		<cfset storage.cacheOutputBuffer = arguments.cacheOutputBuffer />
	</cffunction>
	<cffunction name="getCacheOutputBuffer" access="public" returntype="string" output="false">
	
		<cfset var storage = getCacheStorage() />
	
		<cfreturn storage.cacheOutputBuffer />
	</cffunction>
	
</cfcomponent>