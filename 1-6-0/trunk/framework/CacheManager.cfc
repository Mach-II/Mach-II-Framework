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
$Id: CacheManager.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheManager"
	extends="MachII.framework.CommandLoaderBase"
	output="false"
	hint="Provides an unified API for event and subroutine caching in Mach-II.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentCacheManager = "" />
	<cfset variables.cacheStrategyManager = "" />
	<cfset variables.defaultCacheName = "" />
	<cfset variables.handlers = StructNew() />
	<cfset variables.handlersByAliases = StructNew() />
	<cfset variables.handlersByEventName = StructNew() />
	<cfset variables.handlersBySubroutineName = StructNew() />
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentCacheManager" type="any" required="false" default=""
			hint="Optional argument for a parent cache manager. If not defined, default to zero-length string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfset setCacheStrategyManager(CreateObject("component", "MachII.caching.CacheStrategyManager").init()) />
		
		<cfif IsObject(arguments.parentCacheManager)>
			<cfset setParent(arguments.parentCacheManager) />
			<cfset getCacheStrategyManager().setParent(getParent().getCacheStrategyManager()) />
		</cfif>
		
		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadCacheHandlerFromXml" access="public" returntype="uuid" output="false"
		hint="Loads a cache handler from Xml.">
		<cfargument name="xml" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfargument name="parentHandlerType" type="string" required="true" />
		
		<cfset var command = "" />
		<cfset var cacheHandler = "" />
		<cfset var nestedCommandNodes = arguments.xml.xmlChildren />
		<cfset var alias = "" />
		<cfset var criteria = "" />
		<cfset var cacheName = "" />
		<cfset var cacheStrategy = "" />
		<cfset var i = 0 />
		
		<!--- Currently alias is not implemented --->
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "alias")>
			<cfset alias = arguments.xml.xmlAttributes["alias"] />
		</cfif>
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "criteria")>
			<cfset criteria = arguments.xml.xmlAttributes["criteria"] />
		</cfif>
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "name")>
			<cfset cacheName = arguments.xml.xmlAttributes["name"] />
		</cfif>
		
		<!--- Build the cache handler --->
		<cfset cacheHandler = CreateObject("component", "MachII.framework.CacheHandler").init(
			alias, cacheName, criteria, arguments.parentHandlerName, arguments.parentHandlerType) />
		<cfset cacheHandler.setLog(getAppManager().getLogFactory()) />
		<cfloop from="1" to="#ArrayLen(nestedCommandNodes)#" index="i">
			<cfset command = createCommand(nestedCommandNodes[i]) />
			<cfset cacheHandler.addCommand(command) />
		</cfloop>
		
		<!--- Set the cache handler to the manager --->
		<cfset addCacheHandler(cacheHandler) />
		
		<cfreturn cacheHandler.getHandlerId() />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the cache handlers.">
		
		<cfset var handlerId = "" />
		<cfset var cacheStrategy = "" />
		<cfset var cacheName = "" />
		<cfset var cacheStrategyManager = getCacheStrategyManager() />
		
		<!--- Configure all loaded cache strategies --->
		<cfset cacheStrategyManager.configure() />
		
		<!--- Associates the cache handlers with the right cache strategy now that all the cache strategies 
			have been loaded up by the PropertyManger. --->
		<cfloop collection="#variables.handlers#" item="handlerId">
			<cfset cacheName = variables.handlers[handlerId].getCacheName() />
			
			<!--- Check if we need to use the default cache name --->
			<cfif NOT Len(cacheName)>
				<cfset cacheName = getDefaultCacheName() />
			</cfif>
			
			<!--- Load the strategy into the handler --->
			<cfset cacheStrategy = cacheStrategyManager.getCacheStrategyByName(cacheName) />
			<cfset variables.handlers[handlerId].setCacheStrategy(cacheStrategy) />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="disableCaching" access="public" returntype="void" output="false"
		hint="Disables caching.">
		
		<cfset var key = "" />
		<cfset var handlers = getCacheHandlers() />
		
		<cfloop collection="#handlers#" item="key">
			<cfset handlers[key].disableCaching() />
		</cfloop>
	</cffunction>
	<cffunction name="enableCaching" access="public" returntype="void" output="false"
		hint="Enables caching.">
			
		<cfset var key = "" />
		<cfset var handlers = getCacheHandlers() />
		
		<cfloop collection="#handlers#" item="key">
			<cfset handlers[key].enableCaching() />
		</cfloop>
	</cffunction>
	
	<cffunction name="addCacheHandler" access="public" returntype="void" output="false"
		hint="Adds a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to add." />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var alias = arguments.cacheHandler.getAlias() />
		<cfset var cacheName = arguments.cacheHandler.getCacheName() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />

		<!--- Add the handler --->
		<cfset variables.handlers[handlerId] = arguments.cacheHandler />
		
		<!--- Register the handler by handler type --->
		<cfif handlerType EQ "event">
			<cfset variables.handlersByEventName[handlerId][getKeyHash(arguments.cacheHandler.getParentHandlerName())] = true />
		<cfelseif handlerType EQ "subroutine">
			<cfset variables.handlersBySubroutineName[handlerId][getKeyHash(arguments.cacheHandler.getParentHandlerName())] = true />
		</cfif>
		
		<cfset variables.handlersByName[getKeyHash(cacheName)] = handlerId />
		
		<!--- Register the alias if defined --->
		<cfif Len(alias)>
			<cfset variables.handlersByAliases[getKeyHash(alias)][handlerId] = true />
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheHandler" access="public" returntype="MachII.framework.CacheHandler" output="false"
		hint="Gets a cache handler by handlerId.">
		<cfargument name="handlerId" type="uuid" required="true"
			hint="Handler id of the cache handler you want to get." />
		<cfreturn variables.handlers[arguments.handlerId] />
	</cffunction>
	
	<cffunction name="getCacheHandlers" access="public" returntype="struct" output="false"
		hint="Gets all cache handlers in a struct keyed by the handlerId.">
		<cfreturn variables.handlers />
	</cffunction>
	
	<cffunction name="removeCacheHandler" access="public" returntype="void" output="false"
		hint="Removes a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to remove." />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var alias = arguments.cacheHandler.getAlias() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />

		<!--- Remove the handler --->
		<cfset StructDelete(variables.handlers, handlerId, false) />
		
		<!--- Unregiester the handler by handler type --->
		<cfif handlerType EQ "event">
			<cfset StructDelete(variables.handlersByEventName[handlerId], getKeyHash(arguments.cacheHandler.getParentHandlerName()), true) />
		<cfelseif handlerType EQ "subroutine">
			<cfset StructDelete(variables.handlersBySubroutineName[handlerId], getKeyHash(arguments.cacheHandler.getParentHandlerName()), true) />
		</cfif>
		
		<!--- Remove from cache name list --->
		<cfset StructDelete(variables.handlersByName, getKeyHash(cacheName)) />
		
		<!--- Unregister the alias if defined --->
		<cfif Len(alias)>
			<cfset StructDelete(variables.handlersByAliases[getKeyHash(alias)], handlerId, false) />
		</cfif>
	</cffunction>
		
	<cffunction name="isCacheHandlerDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a cache handler is defined.">
		<cfargument name="handlerId" type="uuid" required="true" 
			hint="Handler id of the cache handler you want to check." />
		<cfreturn StructKeyExists(variables.handlers, arguments.handlerId) />
	</cffunction>
	
	<cffunction name="getCacheHandlersByAlias" access="public" returntype="struct" output="false"
		hint="Gets cache handlers by alias.">
		<cfargument name="alias" type="string" required="true" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var handlerIds = StructNew() />
		<cfset var key = "" />
		
		<cfif StructKeyExists(variables.handlersByAliases, getKeyHash(arguments.alias))>
			<cfset handlerIds = variables.handlersByAliases[getKeyHash(arguments.alias)] />
			
			<cfloop collection="#handlerIds#" item="key">
				<cfset cacheHandlers[key] = getCacheHandler(key) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>
	
	<cffunction name="clearCachesByAlias" access="public" returntype="void" output="false"
		hint="Clears caches by alias.">
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var key = "" />
		
		<!--- Currently alias is no longer used --->
		
		<!--- Only try to clear if there are cache handlers that are registered with this alias --->
		<cfif StructKeyExists(variables.handlersByAliases, getKeyHash(arguments.alias))>
			<cfset cacheHandlers = variables.handlersByAliases[getKeyHash(arguments.alias)] />
			
			<cfloop collection="#cacheHandlers#" item="key">
				<cfset getCacheHandler(key).clearCache(event, criteria) />
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="clearCacheByName" access="public" returntype="void" output="false"
		hint="Clears caches by cacheName.">
		<cfargument name="cacheName" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var handlerId = "" />
		<cfset var keyHashed = getKeyHash(arguments.cacheName) />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("CacheManager clear cache for '#arguments.cacheName#' (#keyHashed#), " &
					"exists: #StructKeyExists(variables.handlersByName, keyHashed)#, " &
					"handler keys: #StructKeyList(variables.handlersByName)#.") />
		</cfif>
		
		<!--- Only try to clear if there are cache handlers that are registered with this cacheName --->
		<cfif StructKeyExists(variables.handlersByName, keyHashed)>
			<cfset handlerId = variables.handlersByName[keyHashed] />
			<cfset getCacheHandler(handlerId).clearCache(arguments.event) />
		</cfif>
	</cffunction>
	
	<cffunction name="isAliasDefined" access="public" returntype="boolean" output="false"
		hint="Checks if an alias is current defined and in use.">
		<cfargument name="alias" type="string" required="true" />
		
		<cfif StructKeyExists(variables.aliases, arguments.alias)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheHandlersByEventName" access="public" returntype="struct" output="false"
		hint="Gets all cache handlers by event name.">
		<cfargument name="eventName" type="string" required="true" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var handlerIds = StructNew() />
		<cfset var key = "" />
		
		<cfif StructKeyExists(variables.handlersByEventName, getKeyHash(arguments.eventName))>
			<cfset handlerIds = variables.handlersByEventName[getKeyHash(arguments.eventName)] />
			
			<cfloop collection="#handlerIds#" item="key">
				<cfset cacheHandlers[key] = getCacheHandler(key) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>
	
	<cffunction name="getCacheHandlersBySubroutine" access="public" returntype="struct" output="false"
		hint="Gets all cache handlers in subroutine name.">
		<cfargument name="subroutineName" type="string" required="true" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var handlerIds = StructNew() />
		<cfset var key = "" />
		
		<cfif StructKeyExists(variables.handlersBySubroutineName, getKeyHash(arguments.subroutineName))>
			<cfset handlerIds = variables.handlersBySubroutineName[getKeyHash(arguments.subroutineName)] />
			
			<cfloop collection="#handlerIds#" item="key">
				<cfset cacheHandlers[key] = getCacheHandler(key) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getKeyHash" access="private" returntype="string" output="false"
		hint="Gets a key name hash (uppercase and hash the key name)">
		<cfargument name="keyName" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.keyName)) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent CacheManager instance this CacheManager belongs to.">
		<cfargument name="parentCacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfset variables.parentCacheManager = arguments.parentCacheManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent CacheManager instance this CacheManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentCacheManager />
	</cffunction>

	<cffunction name="setCacheStrategyManager" access="public" returntype="void" output="false"
		hint="Returns the CacheStrategyManager.">
		<cfargument name="cacheStrategyManager" type="MachII.caching.CacheStrategyManager" required="true" />
		<cfset variables.cacheStrategyManager = arguments.cacheStrategyManager />
	</cffunction>
	<cffunction name="getCacheStrategyManager" access="public" returntype="any" output="false"
		hint="Sets the CacheStrategyManager. Returns empty string if no manager is defind.">
		<cfreturn variables.cacheStrategyManager />
	</cffunction>

	<cffunction name="setDefaultCacheName" access="public" returntype="string" output="false">
		<cfargument name="defaultCacheName" type="string" required="true" />
		<cfif getCacheStrategyManager().isCacheStrategyDefined(arguments.defaultCacheName)>
			<cfset variables.defaultCacheName = arguments.defaultCacheName />
		<cfelse>
			<cfthrow type="MachII.framework.DefaultCacheNameNotAvailable"
				message="The 'defaultCacheName' was set to '#arguments.defaultCacheName#'. This strategy that is not available. Please set the default to a stragety that is configured."
				detail="Available strategies:#ArrayToList(getCacheStrategyManager().getCacheStrategyNames())#" />
		</cfif>
	</cffunction>	
	<cffunction name="getDefaultCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.defaultCacheName />
	</cffunction>
	
	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>
	
</cfcomponent>