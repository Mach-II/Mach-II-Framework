<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id: CacheManager.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.8.0

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
	<cfset variables.cacheHandlerlog = "" />
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfset setCacheStrategyManager(CreateObject("component", "MachII.caching.CacheStrategyManager").init()) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getCacheManager()) />
			<cfset getCacheStrategyManager().setParent(getParent().getCacheStrategyManager()) />
		</cfif>
		
		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<!--- Quick reference for performance reasons --->
		<cfset variables.cacheHandlerlog = getAppManager().getLogFactory().getLog("MachII.framework.CacheHandler") />
		
		<cfset super.init() />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadCacheHandlerFromXml" access="public" returntype="string" output="false"
		hint="Loads a cache handler from Xml.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfargument name="parentHandlerType" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
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
		<cfset cacheHandler.setLog(variables.cacheHandlerlog) />
		<cfset cacheHandler.setAppManager(getAppManager()) />
		
		<!--- Add commands to the cache handler --->
		<cfloop from="1" to="#ArrayLen(nestedCommandNodes)#" index="i">
			<cfset command = createCommand(nestedCommandNodes[i], arguments.parentHandlerName, arguments.parentHandlerType) />
			<cfset cacheHandler.addCommand(command) />
		</cfloop>
		
		<!--- Set the cache handler to the manager --->
		<cftry>
			<cfset addCacheHandler(cacheHandler, arguments.override) />
			<cfcatch type="any">
				<cfthrow type="#cfcatch.type#"
					message="An exception occurred in #arguments.parentHandlerType# named '#arguments.parentHandlerName#'." 
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>
		
		<cfreturn cacheHandler.getHandlerId() />
	</cffunction>
		
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the cache handlers and runs configure in the CacheStrategyManager.">
		
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
		
		<!--- Check to make sure we have cache strategies to use otherwise throw an error --->
		<cfif StructCount(variables.handlers)>
			<cfif (NOT IsObject(getParent()) AND NOT cacheStrategyManager.containsCacheStrategies())
				OR (IsObject(getParent()) AND NOT cacheStrategyManager.containsCacheStrategies() 
					AND NOT cacheStrategyManager.getParent().containsCacheStrategies())>
				<cfthrow type="MachII.caching.NoCacheStrategiesDefined" 
					message="A &lt;cache&gt; command was encountered and there are no cache strategies defined."
					detail="Please add the 'MachII.caching.CachingProperty' to your configuration file or define strategies in the CachingProperty if you wish to use the caching features." />
			</cfif>
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
			<cfset cacheStrategy = cacheStrategyManager.getCacheStrategyByName(strategyName, true) />
			<cfset variables.handlers[handlerId].setCacheStrategy(cacheStrategy) />
		</cfloop>
		
		<cfset super.configure() />
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Runs deconfigure in the CacheStrategyManager.">
		
		<cfset var cacheStrategyManager = getCacheStrategyManager() />
		
		<!--- Configure all loaded cache strategies --->
		<cfset cacheStrategyManager.deconfigure() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCacheHandler" access="public" returntype="void" output="false"
		hint="Adds a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to add." />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var aliases = arguments.cacheHandler.getAliases() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />
		<cfset var currentAlias = "" />
		
		<cfif NOT arguments.overrideCheck>
			<cftry>
				<cfset StructInsert(variables.handlers, handlerId, arguments.cacheHandler, false) />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.CacheHandlerAlreadyDefined"
						message="A cache handler with the id '#handlerId#' is already registered."
						detail="The cache handler id must be unique." />
				</cfcatch>
			</cftry>
			
			<!--- Unregiester the handler by handler type --->
			<cfif handlerType EQ "event">
				<cfset StructInsert(variables.handlersByEventName, handlerId, getKeyHash(arguments.cacheHandler.getParentHandlerName()), false) />
			<cfelseif handlerType EQ "subroutine">
				<cfset StructInsert(variables.handlersBySubroutineName, handlerId, getKeyHash(arguments.cacheHandler.getParentHandlerName()), false) />
			</cfif>
		<cfelse>
			<cfset variables.handlers[handlerId] = arguments.cacheHandler />
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
		hint="Clears caches by cache id (handler id) and tries to clear parent by id if not found in child.">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		
		<cfset var log = getLog() />
		
		<cfif log.isTraceEnabled()>
			<cfset log.trace("CacheManager clear cache for id '#arguments.id#', " &
					"exists: #StructKeyExists(variables.handlers, arguments.id)#, handler keys:",
					StructKeyArray(variables.handlers)) />
		</cfif>
		
		<!--- Only try to clear if there are cache handlers that are registered with this handler id --->
		<cfif isCacheHandlerDefined(arguments.id)>
			<cfset getCacheHandler(arguments.id).clearCache(arguments.event, arguments.criteria) />
		<cfelseif isObject(getParent())>
			<cfset getParent().clearCacheById(arguments.id, arguments.event, arguments.criteria) />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCachesByAlias" access="public" returntype="void" output="false"
		hint="Clears caches by alias and tries to clear parent by alias if not found in child.">
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var key = "" />
		
		<cfif log.isTraceEnabled()>
			<cfset log.trace("CacheManager clear cache for alias '#arguments.alias#', " &
					"exists: #StructKeyExists(variables.handlersByAliases, getKeyHash(arguments.alias))#, " &
					"criteria: #arguments.criteria#") />
		</cfif>
		
		<!--- Only try to clear if there are cache handlers that are registered with this alias --->
		<cfif StructKeyExists(variables.handlersByAliases, getKeyHash(arguments.alias))>
			<cfset cacheHandlers = variables.handlersByAliases[getKeyHash(arguments.alias)] />
			
			<cfloop collection="#cacheHandlers#" item="key">
				<cfset getCacheHandler(key).clearCache(arguments.event, arguments.criteria) />
			</cfloop>
		<cfelseif isObject(getParent())>
			<cfset getParent().clearCachesByAlias(arguments.alias, arguments.event, arguments.criteria) />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCacheByStrategyName" access="public" returntype="void" output="false"
		hint="Clears caches by cacheName and tries to clear parent strategy by name if not found in child.">
		<cfargument name="cacheName" type="string" required="true" />
		
		<!--- Also checks parent --->
		<cfset var cacheStrategy = getCacheStrategyManager().getCacheStrategyByName(arguments.cacheName, true) />
		
		<cfif log.isTraceEnabled()>
			<cfset log.trace("CacheManager clear cache by strategy name '#arguments.cacheName#'") />
		</cfif>
		
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