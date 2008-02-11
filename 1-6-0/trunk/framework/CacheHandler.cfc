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
$Id: CacheHandler.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.6.0

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
	<cfset variables.alias = ""/>
	<cfset variables.cacheName = "" />
	<cfset variables.criteria = "" />
	<cfset variables.parentHandlerName = "" />
	<cfset variables.parentHandlerType = "" />
	<cfset variables.cacheStrategy = 0 />
	<cfset variables.cacheOutputBuffer = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheHandler" output="false"
		hint="Initializes the handler.">
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="cacheName" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
	
		<!--- run setters --->
		<cfset setAlias(arguments.alias) />
		<cfset setCacheName(arguments.cacheName) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setParentHandlerName(arguments.parentHandlerName) />
		<cfset setParentHandlerType(arguments.parentHandlerType) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleCache" access="public" returntype="boolean" output="true"
		hint="Handles a cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		
		<cfset var outputBuffer = "" />
		<cfset var continue = true />
		<cfset var command = "" />
		<cfset var i = 0 />
		<cfset var key = getKeyFromCriteria(arguments.criteria, event) />
		
		<!--- Create the cache since we do not have one --->
		<cfif NOT useCache(key)>
			<!--- Run commands and save output to the buffer --->
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
			<cfset setCacheData(key, arguments.event.getArgs()) />
			<cfset setCacheOutputBuffer(key, outputBuffer) />
			
			<cfoutput>#outputBuffer#</cfoutput>
		<cfelse>
			<!--- Replay the event from the cache --->
			<cfset arguments.event.setArgs(getCacheData(key)) />
			<cfoutput>#getCacheOutputBuffer(key)#</cfoutput>
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<cffunction name="clearCache" access="public" returntype="void" output="false"
		hint="Clears the cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />

		<cfset var key = getKeyFromCriteria(arguments.criteria, arguments.event) />
		
		<cfif len(key)>
			<cfset getCacheStrategy().remove(key) />
			<cfset getCacheStrategy().remove(key & "_output") />
		<cfelse>
			<cfset getCacheStrategy().flush() />
		</cfif>
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
		<cfargument name="key" type="string" required="true" />
		<cfreturn getCacheStrategy().keyExists(key) />
	</cffunction>
	
	<cffunction name="getKeyFromCriteria" access="private" returntype="string" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var sortedCriteria = listSort(criteria, "text") />
		<cfset var item = "" />
		<cfset var key = "" />
		
		<cfloop list="#sortedCriteria#" index="item">
			<cfset key = key & "&#item#=#event.getArg("item")#">
		</cfloop>
		
		<cfreturn key />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="getHandlerId" access="public" returntype="uuid" output="false"
		hint="Returns the handler id.">
		<cfreturn variables.handlerId />
	</cffunction>
	
	<cffunction name="setCacheStrategy" access="public" returntype="void" output="false">
		<cfargument name="cacheStrategy" type="MachII.caching.strategies.AbstractCacheStrategy" required="true" />
		<cfset variables.cacheStrategy = arguments.cacheStrategy />
	</cffunction>
	<cffunction name="getCacheStrategy" access="public" returntype="MachII.caching.strategies.AbstractCacheStrategy" output="false">
		<cfreturn variables.cacheStrategy />
	</cffunction>
	
	<cffunction name="setAlias" access="private" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="public" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>

	<cffunction name="setCacheName" access="private" returntype="void" output="false">
		<cfargument name="cacheName" type="string" required="true" />
		<cfset variables.cacheName = arguments.cacheName />
	</cffunction>
	<cffunction name="getCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.cacheName />
	</cffunction>

	<cffunction name="setCriteria" access="private" returntype="void" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = arguments.criteria />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false">
		<cfreturn variables.criteria />
	</cffunction>
	
	<cffunction name="setParentHandlerName" access="private" returntype="void" output="false">
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfset variables.parentHandlerName = arguments.parentHandlerName />
	</cffunction>
	<cffunction name="getParentHandlerName" access="public" returntype="string" output="false">
		<cfreturn variables.parentHandlerName />
	</cffunction>
	
	<cffunction name="setParentHandlerType" access="private" returntype="void" output="false">
		<cfargument name="parentHandlerType" type="string" required="true" />
		<cfset variables.parentHandlerType = arguments.parentHandlerType />
	</cffunction>
	<cffunction name="getParentHandlerType" access="public" returntype="string" output="false">
		<cfreturn variables.parentHandlerType />
	</cffunction>
	
	<cffunction name="setCacheData" access="private" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="cacheData" type="struct" required="true" />
		<cfset getCacheStrategy().put(arguments.key, arguments.cacheData) />
	</cffunction>
	<cffunction name="getCacheData" access="public" returntype="struct" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfreturn getCacheStrategy().get(arguments.key) />
	</cffunction>
	
	<cffunction name="setCacheOutputBuffer" access="private" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="cacheOutputBuffer" type="string" required="true" />
		<cfset getCacheStrategy().put(arguments.key & "_output", arguments.cacheOutputBuffer) />
	</cffunction>
	<cffunction name="getCacheOutputBuffer" access="public" returntype="string" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfreturn getCacheStrategy().get(arguments.key & "_output") />
	</cffunction>
	
</cfcomponent>