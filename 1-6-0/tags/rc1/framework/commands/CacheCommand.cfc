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
$Id: CacheCommand.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for performing caching.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "cache" />
	<cfset variables.handlerId = "" />
	<cfset variables.alias = "" />
	<cfset variables.strategyName = "" />
	<cfset variables.criteria = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="handlerId" type="string" required="false" default="" />
		<cfargument name="strategyName" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />

		<cfset setHandlerId(arguments.handlerId) />
		<cfset setAlias(arguments.alias) />
		<cfset setStrategyName(arguments.strategyName) />
		<cfset setCriteria(arguments.criteria) />
		
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = true />
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<cfset var cacheHandler = "" />
		<cfset var log = getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Cache-handler '#getHandlerId()#' in module named '#arguments.eventContext.getAppManager().getModuleName()#' beginning execution.") />
		</cfif>
		
		<cfset cacheHandler = cacheManager.getCacheHandler(getHandlerId()) />
		<cfset continue = cacheHandler.handleCache(arguments.event, arguments.eventContext) />

		<cfif log.isWarnEnabled() AND NOT continue>
			<cfset log.warn("Cache-handler '#getHandlerId()#' has changed the flow of this event.") />
		</cfif>

		<cfif log.isDebugEnabled()>
			<cfset log.debug("Cache-handler '#getHandlerId()#' in module named '#arguments.eventContext.getAppManager().getModuleName()#' has ended.") />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setHandlerId" access="private" returntype="void" output="false">
		<cfargument name="handlerId" type="string" required="true" />
		<cfset variables.handlerId = arguments.handlerId />
	</cffunction>
	<cffunction name="getHandlerId" access="private" returntype="string" output="false">
		<cfreturn variables.handlerId />
	</cffunction>
	
	<cffunction name="setAlias" access="private" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="private" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>
	
	<cffunction name="setStrategyName" access="private" returntype="void" output="false">
		<cfargument name="strategyName" type="string" required="true" />
		<cfset variables.strategyName = arguments.strategyName />
	</cffunction>
	<cffunction name="getStrategyName" access="private" returntype="string" output="false">
		<cfreturn variables.strategyName />
	</cffunction>
	
	<cffunction name="setCriteria" access="private" returntype="void" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = arguments.criteria />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false">
		<cfreturn variables.criteria />
	</cffunction>

</cfcomponent>