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
	<cfset variables.handlers = StructNew() />
	<cfset variables.handlersByAliases = StructNew() />
	<cfset variables.handlersByEventName = StructNew() />
	<cfset variables.handlersBySubroutineName = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentCacheManager" type="any" required="false" default=""
			hint="Optional argument for a parent cache manager. If not defined, default to zero-length string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif IsObject(arguments.parentCacheManager)>
			<cfset setParent(arguments.parentCacheManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadCacheHandlerFromXml" access="public" returntype="uuid" output="false"
		hint="Loads a cache handler from Xml.">
		<cfargument name="xml" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfargument name="parentHandlerType" type="string" required="true" />
		
		<cfset var cacheHandler = "" />
		<cfset var nestedCommandNodes = arguments.xml.xmlChildren />
		<cfset var alias = "" />
		<cfset var type = "application" />
		<cfset var cacheFor = 1 />
		<cfset var cacheForUnit = "forever" />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "alias")>
			<cfset alias = arguments.xml.xmlAttributes["alias"] />
		</cfif>
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "type")>
			<cfset type = arguments.xml.xmlAttributes["type"] />
		</cfif>
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "cacheFor")>
			<cfset cacheFor = arguments.xml.xmlAttributes["cacheFor"] />
		</cfif>
		<cfif StructKeyExists(arguments.xml.xmlAttributes, "cacheForUnit")>
			<cfset cacheForUnit = arguments.xml.xmlAttributes["cacheForUnit"] />
		</cfif>
		
		<!--- Set temps for the commandLoaderBase. --->
		<cfset variables.listenerMgr = getAppManager().getListenerManager() />
		<cfset variables.filterMgr = getAppManager().getFilterManager() />

		<!--- Build the cache handler --->
		<cfset cacheHandler = CreateObject("component", "MachII.framework.CacheHandler").init(alias, type, cacheFor, cacheForUnit, arguments.parentHandlerName, arguments.parentHandlerType) />
		<cfloop from="1" to="#ArrayLen(nestedCommandNodes)#" index="i">
			<cfset command = createCommand(nestedCommandNodes[i]) />
			<cfset cacheHandler.addCommand(command) />
		</cfloop>
		
		<!--- Set the cache handler to the manager --->
		<cfset addCacheHandler(cacheHandler) />
		
		<!--- Clear temps. --->
		<cfset variables.listenerMgr = "" />
		<cfset variables.filterMgr = "" />
		
		<cfreturn cacheHandler.getHandlerId() />		
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures manager.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCacheHandler" access="public" returntype="void" output="false"
		hint="Adds a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true"
			hint="The cache handler you want to add." />

		<cfset var handlerId = arguments.cacheHandler.getHandlerId() />
		<cfset var alias = arguments.cacheHandler.getAlias() />
		<cfset var handlerType = arguments.cacheHandler.getParentHandlerType() />

		<!--- Add the handler --->
		<cfset variables.handlers[handlerId] = arguments.cacheHandler />
		
		<!--- Register the handler by handler type --->
		<cfif handlerType EQ "event">
			<cfset variables.handlersByEventName[handlerId][Hash(arguments.cacheHandler.getParentHandlerName())] = true />
		<cfelseif handlerType EQ "subroutine">
			<cfset variables.handlersBySubroutineName[handlerId][Hash(arguments.cacheHandler.getParentHandlerName())] = true />
		</cfif>
		
		<!--- Register the alias if defined --->
		<cfif Len(alias)>
			<cfset variables.handlersByAliases[Hash(alias)][handlerId] = true />
		</cfif>
	</cffunction>
	
	<cffunction name="getCacheHandler" access="public" returntype="MachII.framework.CacheHandler" output="false"
		hint="Gets a cache handler.">
		<cfargument name="handlerId" type="uuid" required="true"
			hint="Handler id of the cache handler you want to get." />
		<cfreturn variables.handlers[arguments.handlerId] />
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
			<cfset StructDelete(variables.handlersByEventName[handlerId], Hash(arguments.cacheHandler.getParentHandlerName()), true) />
		<cfelseif handlerType EQ "subroutine">
			<cfset StructDelete(variables.handlersBySubroutineName[handlerId], Hash(arguments.cacheHandler.getParentHandlerName()), true) />
		</cfif>
		
		<!--- Unregister the alias if defined --->
		<cfif Len(alias)>
			<cfset StructDelete(variables.handlersByAliases[Hash(alias)], handlerId, false) />
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
		<cfset var i = 0 />
		
		<cfif StructKeyExists(variables.handlersByAliases, Hash(arguments.alias))>
			<cfset handlerIds = variables.handlersByAliases[Hash(arguments.alias)] />
			
			<cfloop collection="#handlerIds#" item="i">
				<cfset StructInsert(cacheHandlers, i, getCacheHandler(i), true) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>
	
	<cffunction name="clearCachesByAlias" access="public" returntype="void" output="false"
		hint="Clears caches by alias.">
		<cfargument name="alias" type="string" required="true" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var i = 0 />
		
		<!--- Only try to clear if there are cache handlers that are registered with this alias --->
		<cfif StructKeyExists(variables.handlersByAliases, Hash(arguments.alias))>
			<cfset cacheHandlers = variables.handlersByAliases[Hash(arguments.alias)] />

			<cfloop collection="#cacheHandlers#" item="i">
				<cfset getCacheHandler(i).clearCache() />
			</cfloop>
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
		<cfset var i = 0 />
		
		<cfif StructKeyExists(variables.handlersByEventName, Hash(arguments.eventName))>
			<cfset handlerIds = variables.handlersByEventName[Hash(arguments.eventName)] />
			
			<cfloop collection="#handlerIds#" item="i">
				<cfset StructInsert(cacheHandlers, i, getCacheHandler(i), true) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
	</cffunction>
	
	<cffunction name="getCacheHandlersBySubroutine" access="public" returntype="struct" output="false"
		hint="Gets all cache handlers in subroutine name.">
		<cfargument name="subroutineName" type="string" required="true" />
		
		<cfset var cacheHandlers = StructNew() />
		<cfset var handlerIds = StructNew() />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(variables.handlersBySubroutineName, Hash(arguments.subroutineName))>
			<cfset handlerIds = variables.handlersBySubroutineName[Hash(arguments.subroutineName)] />
			
			<cfloop collection="#handlerIds#" item="i">
				<cfset StructInsert(cacheHandlers, i, getCacheHandler(i), true) />
			</cfloop>
		</cfif>
		
		<cfreturn cacheHandlers />
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
	
</cfcomponent>