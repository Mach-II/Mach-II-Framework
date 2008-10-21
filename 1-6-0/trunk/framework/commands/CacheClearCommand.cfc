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
$Id: CacheClearCommand.cfc 422 2007-07-06 05:34:59Z pfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheClearCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for clearing caching.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "cache-clear" />
	<cfset variables.ids = "" />
	<cfset variables.aliases = "" />
	<cfset variables.strategyNames = "" />
	<cfset variables.criteria = "" />
	<cfset variables.condition = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheClearCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="ids" type="string" required="false" default="" />
		<cfargument name="aliases" type="string" required="false" default="" />
		<cfargument name="strategyNames" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="condition" type="string" required="false" default="" />
		
		<cfset setIds(arguments.ids) />
		<cfset setAliases(arguments.aliases) />
		<cfset setStrategyNames(arguments.strategyNames) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setCondition(arguments.condition) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<cfset var log = getLog() />
				
		<!--- Make decision on whether or not to clear a cache by evaluating a condition --->
		<cfif NOT isConditionDefined()>
			<!--- Clear by id without condition --->
			<cfif isIdDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by id '#getId()#' (no condition to evaluated).") />
				</cfif>
				<cfset clearCacheById(arguments.event, cacheManager) />
			</cfif>
			<!--- Clear by alias without condition --->
			<cfif isAliasDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by alias '#getAlias()#' (no condition to evaluate).") />
				</cfif>
				<cfset clearCacheByAlias(arguments.event, cacheManager) />
			</cfif>
			<!--- Clear by cache name without condition --->
			<cfif isCacheNameDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by cacheName '#getCacheName()#' (no condition to evaluate).") />
				</cfif>
				<cfset clearCacheByCacheName(arguments.event, cacheManager) />
			</cfif>
		<!--- Evaluate(getCondition()) --->
		<cfelseif variables.expressionEvaluator.evaluateExpressionBody(getCondition(), arguments.event, getPropertyManager())>
			<!--- Clear by id with condition --->
			<cfif isIdDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by id '#getId()#' (condition '#getCondition()#' evaluated true).") />
				</cfif>
				<cfset clearCacheById(arguments.event, cacheManager) />
			</cfif>
			<!--- Clear by alias with condition --->
			<cfif isAliasDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by alias '#getAlias()#' (condition '#getCondition()#' evaluated true).") />
				</cfif>
				<cfset clearCacheByAlias(arguments.event, cacheManager) />
			</cfif>
			<!--- Clear by cache name with condition --->
			<cfif isCacheNameDefined()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing cache by cacheName '#getCacheName()#' (condition '#getCondition()#' evaluated true).") />
				</cfif>
				<cfset clearCacheByCacheName(arguments.event, cacheManager) />
			</cfif>
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfif isIdDefined()>
					<cfset log.debug("Cannot clear cache by id '#getId()#' (condition '#getCondition()#' evaluated false).") />
				</cfif>
				<cfif isAliasDefined()>
					<cfset log.debug("Cannot clear cache by alias '#getAlias()#' (condition '#getCondition()#' evaluated false).") />
				</cfif>
				<cfif isCacheNameDefined()>
					<cfset log.debug("Cannot clear cache by cacheName '#getCacheName()#' (condition '#getCondition()#' evaluated false).") />
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="clearCacheById" access="public" returntype="void" output="false"
		hint="Helper method to clear cache elements by id/ids.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		
		<cfset var currentId = "" />
		
		<cfloop list="#getId()#" index="currentId">
			<cfset arguments.cacheManager.clearCacheById(currentId, arguments.event) />
		</cfloop>
	</cffunction>
	
	<cffunction name="clearCacheByAlias" access="public" returntype="void" output="false"
		hint="Helper method to clear cache elements by alias/aliases.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		
		<cfset var currentAlias = "" />
		
		<cfloop list="#getAlias()#" index="currentAlias">
			<cfset arguments.cacheManager.clearCachesByAlias(currentAlias, arguments.event, getCriteria()) />
		</cfloop>
	</cffunction>
	
	<cffunction name="clearCacheByCacheName" access="public" returntype="void" output="false"
		hint="Helper method to clear cache elements by cache name/names.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		
		<cfset var currentCacheName = "" />
		
		<cfloop list="#getCacheName()#" index="currentCacheName">
			<cfset arguments.cacheManager.clearCacheByName(currentCacheName, arguments.event) />
		</cfloop>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setIds" access="private" returntype="void" output="false">
		<cfargument name="ids" type="string" required="true" />
		<cfset variables.ids = arguments.ids />
	</cffunction>
	<cffunction name="getIds" access="public" returntype="string" output="false">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="isIdsDefined" access="public" returntype="boolean" output="false"
		hint="Checks if ids are defined.">
		<cfreturn Len(variables.ids) />
	</cffunction>

	<cffunction name="setAliases" access="private" returntype="void" output="false">
		<cfargument name="aliases" type="string" required="true" />
		<cfset variables.aliases = arguments.aliases />
	</cffunction>
	<cffunction name="getAliases" access="public" returntype="string" output="false">
		<cfreturn variables.aliases />
	</cffunction>
	<cffunction name="isAliasDefined" access="public" returntype="boolean" output="false"
		hint="Checks if aliases are defined.">
		<cfreturn Len(variables.aliases) />
	</cffunction>
	
	<cffunction name="setStrategyNames" access="private" returntype="void" output="false">
		<cfargument name="strategyNames" type="string" required="true" />
		<cfset variables.strategyNames = arguments.strategyNames />
	</cffunction>
	<cffunction name="getStrategyNames" access="public" returntype="string" output="false">
		<cfreturn variables.strategyNames />
	</cffunction>
	<cffunction name="isStrategyNameDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a cache strategy names are defined.">
		<cfreturn Len(variables.strategyNames) />
	</cffunction>

	<cffunction name="setCriteria" access="private" returntype="void" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = arguments.criteria />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false">
		<cfreturn variables.criteria />
	</cffunction>
	
	<cffunction name="setCondition" access="private" returntype="void" output="false">
		<cfargument name="condition" type="string" required="true" />
		<cfset variables.condition = arguments.condition />
	</cffunction>
	<cffunction name="getCondition" access="public" returntype="string" output="false">
		<cfreturn variables.condition />
	</cffunction>
	<cffunction name="isConditionDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a condition is defined.">
		<cfreturn Len(variables.condition) />
	</cffunction>

</cfcomponent>