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
	<cfset variables.cacheEnabled = true />
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
	
	<cffunction name="loadCacheHandlerFromXml" access="public" returntype="string" output="false"
		hint="Loads a cache handler from Xml.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfargument name="parentHandlerType" type="string" required="true" />
		
		<cfset var nestedCommandNodes = arguments.configXML.xmlChildren />
		<cfset var command = "" />

		<cfset var cacheStrategy = "" />
		<cfset var cacheHandler = "" />		

		<cfset var id = "" />
		<cfset var aliases = "" />
		<cfset var strategyName = "" />
		<cfset var criteria = "" />
		<cfset var i = 0 />

		<cfif StructKeyExists(arguments.configXML.xmlAttributes, "id")>
			<cfset id = arguments.configXML.xmlAttributes["id"] />
		</cfif>		
		<cfif StructKeyExists(arguments.configXML.xmlAttributes, "aliases")>
			<cfset aliases = arguments.configXML.xmlAttributes["aliases"] />
		</cfif>
		<cfif StructKeyExists(arguments.configXML.xmlAttributes, "strategyName")>
			<cfset strategyName = arguments.configXML.xmlAttributes["strategyName"] />
		</cfif>
		<cfif StructKeyExists(arguments.configXML.xmlAttributes, "criteria")>
			<cfset criteria = arguments.configXML.xmlAttributes["criteria"] />
		</cfif>
		
		<!--- Build cache handler --->
		<cfset cacheHandler = CreateObject("component", "MachII.framework.CacheHandler").init(
			id, aliases, strategyName, criteria, arguments.parentHandlerName, arguments.parentHandlerType) />
		<cfset cacheHandler.setLog(getAppManager().getLogFactory()) />
		<cfset cacheHandler.setAppManager(getAppManager()) />
		
		<!--- Add commands to the cache handler --->
		<cfloop from="1" to="#ArrayLen(nestedCommandNodes)#" index="i">
			<cfset command = createCommand(nestedCommandNodes[i], arguments.parentHandlerName, arguments.parentHandlerType) />
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
		<cfset var strategyName = "" />
		<cfset var cacheStrategyManager = getCacheStrategyManager() />
		
		<!--- Configure all loaded cache strategies --->
		<cfset cacheStrategyManager.configure() />
		
		<!--- Get the parent default cache name if this is a child manager
			with no default cache name defined --->
		<cfif IsObject(getParent()) AND Len(getParent().getDefaultCacheName()) 
			AND NOT Len(getDefaultCacheName())>
			<cfset setDefaultCacheName(getParent().getDefaultCacheName()) />
		</cfif>
		
		<!--- Associates the cache handlers with the right cache strategy now that all the cache strategies 
			have been loaded up by the PropertyManger. --->
		<cfloop collection="#variables.handlers#" item="handlerId">
			<cfset strategyName = variables.handlers[handlerId].getStrategyName() />
			
			<!--- Check if we need to use the default cache strategy name --->
			<cfif NOT Len(strategyName)>
				<cfset strategyName = getDefaultCacheName() />
			</cfif>
			
			<!--- Load the strategy into the handler --->
			<cfset cacheStrategy = cacheStrategyManager.getCacheStrategyByName(strategyName) />
			<cfset variables.handlers[handlerId].setCacheStrategy(cacheStrategy) />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCacheHandler" access="public" returntype="void" output="false"
		hint="Adds a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to add." />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var aliases = arguments.cacheHandler.getAliases() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />
		<cfset var currentAlias = "" />

		<!--- Add the handler --->
		<cfset StructInsert(variables.handlers, handlerId, arguments.cacheHandler, false) />

		<!--- Unregiester the handler by handler type --->
		<cfif handlerType EQ "event">
			<cfset StructInsert(variables.handlersByEventName, handlerId, getKeyHash(arguments.cacheHandler.getParentHandlerName()), false) />
		<cfelseif handlerType EQ "subroutine">
			<cfset StructInsert(variables.handlersBySubroutineName, handlerId, getKeyHash(arguments.cacheHandler.getParentHandlerName()), false) />
		</cfif>

		<!--- Register the aliases if defined --->
		<cfif Len(aliases)>
			<cfloop list="#aliases#" index="currentAlias">
				<cfset variables.handlersByAliases[getKeyHash(currentAlias)][handlerId] = true />
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheHandler" access="public" returntype="MachII.framework.CacheHandler" output="false"
		hint="Gets a cache handler by handlerId. Checks parent.">
		<cfargument name="handlerId" type="string" required="true"
			hint="Handler id of the cache handler you want to get." />

		<cfif isCacheHandlerDefined(arguments.handlerId)>
			<cfreturn variables.handlers[arguments.handlerId] />
		<cfelseif IsObject(getParent()) AND getParent().isCacheHandlerDefined(arguments.handlerId)>
			<cfreturn getParent().getCacheHandler(arguments.handlerId) />
		<cfelse>
			<cfthrow type="MachII.framework.CacheHandlerNotDefined" 
				message="CacheHandler for cache '#arguments.handlerId#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheHandlers" access="public" returntype="struct" output="false"
		hint="Gets all cache handlers in a struct keyed by the handlerId.">
		<cfreturn variables.handlers />
	</cffunction>
	
	<cffunction name="removeCacheHandler" access="public" returntype="void" output="false"
		hint="Removes a cache handler. Does NOT remove from the parent.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to remove." />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var aliases = arguments.cacheHandler.getAliases() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />
		<cfset var currentAlias = "" />

		<!--- Remove the handler --->
		<cfset StructDelete(variables.handlers, handlerId, false) />
		
		<!--- Unregiester the handler by handler type --->
		<cfif handlerType EQ "event">
			<cfset StructDelete(variables.handlersByEventName[handlerId], getKeyHash(arguments.cacheHandler.getParentHandlerName()), true) />
		<cfelseif handlerType EQ "subroutine">
			<cfset StructDelete(variables.handlersBySubroutineName[handlerId], getKeyHash(arguments.cacheHandler.getParentHandlerName()), true) />
		</cfif>
		
		<!--- Unregister the aliases if defined --->
		<cfif Len(aliases)>
			<cfloop list="#aliases#" index="currentAlias">
				<cfset StructDelete(variables.handlersByAliases[getKeyHash(currentAlias)], handlerId, false) />
			</cfloop>
		</cfif>
	</cffunction>
		
	<cffunction name="isCacheHandlerDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a cache handler is defined. Does NOT check the parent.">
		<cfargument name="handlerId" type="string" required="true" 
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
		<cfelseif isObject(getParent())>
			<cfset cacheHandlers = getParent().getCacheHandlersByAlias(arguments.alias) />
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>

	<cffunction name="clearCacheById" access="public" returntype="void" output="false"
		hint="Clears caches by cache id (handler id).">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var log = getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("CacheManager clear cache for id '#arguments.id#', " &
					"exists: #StructKeyExists(variables.handlers, arguments.id)#, handler keys:",
					StructKeyArray(variables.handlers)) />
		</cfif>
		
		<!--- Only try to clear if there are cache handlers that are registered with this handler id --->
		<cfif StructKeyExists(variables.handlers, arguments.id)>
			<cfset getCacheHandler(arguments.id).clearCache(arguments.event) />
		<cfelseif isObject(getParent())>
			<cfset getParent().clearCacheById(arguments.id, arguments.event) />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCachesByAlias" access="public" returntype="void" output="false"
		hint="Clears caches by alias.">
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var key = "" />

		<!--- Only try to clear if there are cache handlers that are registered with this alias --->
		<cfif StructKeyExists(variables.handlersByAliases, getKeyHash(arguments.alias))>
			<cfset cacheHandlers = variables.handlersByAliases[getKeyHash(arguments.alias)] />
			
			<cfloop collection="#cacheHandlers#" item="key">
				<cfset getCacheHandler(key).clearCache(arguments.event, arguments.criteria, arguments.alias) />
			</cfloop>
		<cfelseif isObject(getParent())>
			<cfset getParent().clearCachesByAlias(arguments.alias, arguments.event, arguments.criteria) />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCacheByStrategyName" access="public" returntype="void" output="false"
		hint="Clears caches by cacheName.">
		<cfargument name="cacheName" type="string" required="true" />
		
		<cfset var cacheStrategy = getCacheStrategyManager().getCacheStrategyByName(arguments.cacheName) />
		
		<cfset cacheStrategy.flush() />
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
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="disableCaching" access="public" returntype="void" output="false"
		hint="Disables caching.">
		
		<cfset var key = "" />
		<cfset var strategies = getCacheStrategyManager().getCacheStrategies() />
		
		<cfloop collection="#strategies#" item="key">
			<cfset strategies[key].setCacheEnabled(false) />
		</cfloop>
	</cffunction>
	<cffunction name="enableCaching" access="public" returntype="void" output="false"
		hint="Enables caching.">
			
		<cfset var key = "" />
		<cfset var strategies = getCacheStrategyManager().getCacheStrategies() />
		
		<cfloop collection="#strategies#" item="key">
			<cfset strategies[key].setCacheEnabled(true) />
		</cfloop>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getKeyHash" access="private" returntype="string" output="false"
		hint="Gets a key name hash (uppercase and hash the key name)">
		<cfargument name="keyName" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.keyName)) />
	</cffunction>
	
	<cffunction name="createCommand" access="private" returntype="MachII.framework.Command" output="false"
		hint="Creates a command and excludes 'announce', 'event-mapping' and 'redirect' commands as they cannot be used in a cache handler.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<!--- If we see a event-mapping, announce, or redirect commands an error should be thrown 
			since those are not replayed when the event is cached. --->
		<cfif ListFindNoCase("announce,event-mapping,redirect", arguments.commandNode.xmlName)>
			<cfthrow type="MachII.framework.InvalidNestedCommand"
					message="The #arguments.commandNode.xmlName# command in #arguments.parentHandlerType# named '#arguments.parentHandlerName#' is not valid inside a cache command."
					detail="The commands announce, event-mapping and redirect are now allowed inside a cache command since they cannot be replayed." />
		</cfif>
		
		<cfreturn super.createCommand(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
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
		<cfif getCacheStrategyManager().isCacheStrategyDefined(arguments.defaultCacheName, true)>
			<cfset variables.defaultCacheName = arguments.defaultCacheName />
		<cfelse>
			<cfthrow type="MachII.framework.DefaultStrategyNameNotAvailable"
				message="The 'defaultCacheName' was set to '#arguments.defaultCacheName#'. This strategy is not available. Please set the default to a strategy that is configured."
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