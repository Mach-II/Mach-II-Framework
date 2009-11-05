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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id: CacheClearCommand.cfc 422 2007-07-06 05:34:59Z pfarrell $

Created version: 1.6.0
Updated version: 1.8.0

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
	<cfset variables.clearDefaultStrategy = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheClearCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="ids" type="string" required="false" default="" />
		<cfargument name="aliases" type="string" required="false" default="" />
		<cfargument name="strategyNames" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="criteriaCollectionName" type="any" required="false" default="" />
		<cfargument name="criteriaCollection" type="any" required="false" default="" />
		<cfargument name="condition" type="string" required="false" default="" />
		
		<cfset setIds(arguments.ids) />
		<cfset setAliases(arguments.aliases) />
		<cfset setStrategyNames(arguments.strategyNames) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setCriteriaCollectionName(arguments.criteriaCollectionName) />
		<cfset setCriteriaCollection(arguments.criteriaCollection) />
		<cfset setCondition(arguments.condition) />
		
		<!--- Check if default cache strategy should be clear if no 
			ids, aliases or strategy names are defined --->
		<cfset checkIfClearDefaultStrategy() />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var expressionResult = "" />
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<cfset var propertyManager = arguments.eventContext.getAppManager().getPropertyManager() />
		<cfset var log = getLog() />
				
		<!--- Make decision on whether or not to clear a cache by evaluating a condition --->
		<cfif NOT isConditionDefined()>
			<!--- Clear default strategy --->
			<cfif getClearDefaultStrategy()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Clearing default cache strategy '#cacheManager.getDefaultCacheName()#' (no condition to evaluate).") />
				</cfif>
				<cfset clearCacheByDefaultStrategy(cacheManager) />
			<!--- Clear by ids, aliases and/or strategy names --->
			<cfelse>
				<!--- Clear by ids without condition --->
				<cfif isIdsDefined()>
					<cfif log.isDebugEnabled()>
						<cfset log.debug("Clearing cache by ids '#getIds()#' (no condition to evaluate).") />
					</cfif>
					<cfset clearCacheByIds(cacheManager, propertyManager, arguments.event) />
				</cfif>
				<!--- Clear by aliases without condition --->
				<cfif isAliasesDefined()>
					<cfif log.isDebugEnabled()>
						<cfset log.debug("Clearing cache by aliases '#getAliases()#' (no condition to evaluate).") />
					</cfif>
					<cfset clearCacheByAliases(cacheManager, propertyManager, arguments.event) />
				</cfif>
				<!--- Clear by strategy names without condition --->
				<cfif isStrategyNamesDefined()>
					<cfif log.isDebugEnabled()>
						<cfset log.debug("Clearing cache by strategyNames '#getStrategyNames()#' (no condition to evaluate).") />
					</cfif>
					<cfset clearCacheByStrategyNames(cacheManager) />
				</cfif>
			</cfif>
		<cfelse>
			<cfif getExpressionEvaluator().isExpression(getCondition())>
				<cfset expressionResult = getExpressionEvaluator().evaluateExpression(getCondition(), 
						arguments.event, propertyManager) />
			<cfelse>
				<cfset expressionResult = getExpressionEvaluator().evaluateExpressionBody(getCondition(), 
						arguments.event, propertyManager) />
			</cfif>
			<cfif isBoolean(expressionResult) AND expressionResult>
				<!--- Clear default strategy --->
				<cfif getClearDefaultStrategy()>
					<cfif log.isDebugEnabled()>
						<cfset log.debug("Clearing default cache strategy '#cacheManager.getDefaultCacheName()#' (condition '#getCondition()#' evaluated true).") />
					</cfif>
					<cfset clearCacheByDefaultStrategy(cacheManager) />
				<!--- Clear by ids, aliases and/or strategy names --->
				<cfelse>
					<!--- Clear by id with condition --->
					<cfif isIdsDefined()>
						<cfif log.isDebugEnabled()>
							<cfset log.debug("Clearing cache by ids '#getIds()#' (condition '#getCondition()#' evaluated true).") />
						</cfif>
						<cfset clearCacheByIds(cacheManager, propertyManager, arguments.event) />
					</cfif>
					<!--- Clear by alias with condition --->
					<cfif isAliasesDefined()>
						<cfif log.isDebugEnabled()>
							<cfset log.debug("Clearing cache by aliases '#getAliases()#' (condition '#getCondition()#' evaluated true).") />
						</cfif>
						<cfset clearCacheByAliases(cacheManager, propertyManager, arguments.event) />
					</cfif>
					<!--- Clear by cache name with condition --->
					<cfif isStrategyNamesDefined()>
						<cfif log.isDebugEnabled()>
							<cfset log.debug("Clearing cache by strategyNames '#getStrategyNames()#' (condition '#getCondition()#' evaluated true).") />
						</cfif>
						<cfset clearCacheByStrategyNames(cacheManager) />
					</cfif>
				</cfif>
			<cfelseif isBoolean(expressionResult) AND NOT expressionResult>
				<cfif log.isDebugEnabled()>
					<!--- Clear default strategy --->
					<cfif getClearDefaultStrategy()>
						<cfset log.debug("Cannot clear default cache strategy '#cacheManager.getDefaultCacheName()#' (condition '#getCondition()#' evaluated false).") />
					<cfelse>
						<cfif isIdsDefined()>
							<cfset log.debug("Cannot clear cache by ids '#getIds()#' (condition '#getCondition()#' evaluated false).") />
						</cfif>
						<cfif isAliasesDefined()>
							<cfset log.debug("Cannot clear cache by aliases '#getAliases()#' (condition '#getCondition()#' evaluated false).") />
						</cfif>
						<cfif isStrategyNamesDefined()>
							<cfset log.debug("Cannot clear cache by strategyNames '#getStrategyNames()#' (condition '#getCondition()#' evaluated false).") />
						</cfif>
					</cfif>
				</cfif>
			<cfelse>
				<!--- Expression result was not a boolean --->
				<cfif log.isErrorEnabled()>
					<cfif getClearDefaultStrategy()>
						<cfset log.error("Cannot clear default cache strategy '#cacheManager.getDefaultCacheName()#' (condition '#getCondition()#' which evaulated to '#expressionResult#' did not evaluate to a boolean).") />
					<cfelse>
						<cfif isIdsDefined()>
							<cfset log.error("Cannot clear cache by ids '#getIds()#' (condition '#getCondition()#' which evaulated to '#expressionResult#' did not evaluate to a boolean).") />
						</cfif>
						<cfif isAliasesDefined()>
							<cfset log.error("Cannot clear cache by aliases '#getAliases()#' (condition '#getCondition()#' which evaulated to '#expressionResult#' did not evaluate to a boolean).") />
						</cfif>
						<cfif isStrategyNamesDefined()>
							<cfset log.error("Cannot clear cache by strategyNames '#getStrategyNames()#' (condition '#getCondition()#' which evaulated to '#expressionResult#' did not evaluate to a boolean).") />
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="clearCacheByIds" access="private" returntype="void" output="false"
		hint="Helper method to clear cache elements by id/ids.">
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var currentId = "" />
		<cfset var collectionName = getCriteriaCollectionName() />
		<cfset var collection = "" />
		<cfset var criteria = "" />
		<cfset var i = 0 />
		
		<cfif isCriteriaCollectionDefined()>
			<cfset collection = resolveCriteriaCollection(arguments.event, arguments.propertyManager) />
			
			<cfloop from="1" to="#ArrayLen(collection)#" index="i">
				<cfset criteria = ListAppend(getCriteria(), collectionName & "=" & collection[i]) />
				
				<cfloop list="#getAliases()#" index="currentId">
					<cfset arguments.cacheManager.clearCacheById(currentId, arguments.event, criteria) />
				</cfloop>
			</cfloop>
		<cfelse>
			<cfloop list="#getIds()#" index="currentId">
				<cfset arguments.cacheManager.clearCacheById(currentId, arguments.event, getCriteria()) />
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="clearCacheByAliases" access="private" returntype="void" output="false"
		hint="Helper method to clear cache elements by alias/aliases.">
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var currentAlias = "" />
		<cfset var collectionName = getCriteriaCollectionName() />
		<cfset var collection = "" />
		<cfset var criteria = "" />
		<cfset var i = 0 />
		
		<cfif isCriteriaCollectionDefined()>
			<cfset collection = resolveCriteriaCollection(arguments.event, arguments.propertyManager) />
			
			<cfloop from="1" to="#ArrayLen(collection)#" index="i">
				<cfset criteria = ListAppend(getCriteria(), collectionName & "=" & collection[i]) />
				
				<cfloop list="#getAliases()#" index="currentAlias">
					<cfset arguments.cacheManager.clearCachesByAlias(currentAlias, arguments.event, criteria) />
				</cfloop>
			</cfloop>
		<cfelse>
			<cfloop list="#getAliases()#" index="currentAlias">
				<cfset arguments.cacheManager.clearCachesByAlias(currentAlias, arguments.event, getCriteria()) />
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="clearCacheByStrategyNames" access="private" returntype="void" output="false"
		hint="Helper method to clear cache elements by strategy name/names.">
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		
		<cfset var currentStrategyName = "" />
		
		<cfloop list="#getStrategyNames()#" index="currentStrategyName">
			<cfset arguments.cacheManager.clearCacheByStrategyName(currentStrategyName) />
		</cfloop>
	</cffunction>
	
	<cffunction name="clearCacheByDefaultStrategy" access="private" returntype="void" output="false"
		hint="Helper method to clear default cache strategy.">
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfset arguments.cacheManager.clearCacheByStrategyName(cacheManager.getDefaultCacheName()) />
	</cffunction>
	
	<cffunction name="checkIfClearDefaultStrategy" access="private" returntype="void" output="false"
		hint="Checks and sets if the default strategy should be cleared (e.g. <cache-clear />).">
		
		<cfif NOT isIdsDefined() AND NOT isAliasesDefined() AND NOT isStrategyNamesDefined()>
			<cfset setClearDefaultStrategy(true) />
		</cfif>
	</cffunction>
	
	<cffunction name="resolveCriteriaCollection" access="private" returntype="array" output="false"
		hint="Resolves a criteria collection for use.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />

		<cfset var collection = getCriteriaCollection() />

		<cfif getExpressionEvaluator().isExpression(collection)>
			<cfset collection = getExpressionEvaluator().evaluateExpression(
					getCriteriaCollection()
					, arguments.event
					, arguments.propertyManager) />
		</cfif>
		
		<!--- Convert collection to an array --->
		<cfif IsSimpleValue(collection)>
			<cfset collection = ListToArray(collection) />
		</cfif>
		
		<!--- Throw exception if the collection is not an array (only lists and arrays are supported) --->
		<cfif NOT IsArray(collection)>
			<cfthrow type="MachII.CacheClearCommand.InvalidCriterionCollectionType"
				message="The criterion collection must be a list or an array. Structs are not supported." />
		</cfif>
		
		<cfreturn collection />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setIds" access="private" returntype="void" output="false">
		<cfargument name="ids" type="string" required="true" />
		<cfset variables.ids = arguments.ids />
	</cffunction>
	<cffunction name="getIds" access="public" returntype="string" output="false">
		<cfreturn variables.ids />
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
	<cffunction name="isAliasesDefined" access="public" returntype="boolean" output="false"
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
	<cffunction name="isStrategyNamesDefined" access="public" returntype="boolean" output="false"
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
	
	<cffunction name="setCriteriaCollectionName" access="private" returntype="void" output="false">
		<cfargument name="criteriaCollectionName" type="string" required="true" />
		<cfset variables.criteriaCollectionName = UCase(arguments.criteriaCollectionName) />
	</cffunction>
	<cffunction name="getCriteriaCollectionName" access="public" returntype="string" output="false">
		<cfreturn variables.criteriaCollectionName />
	</cffunction>
	
	<cffunction name="setCriteriaCollection" access="private" returntype="void" output="false">
		<cfargument name="criteriaCollection" type="any" required="true" />
		<cfset variables.criteriaCollection = arguments.criteriaCollection />
	</cffunction>
	<cffunction name="getCriteriaCollection" access="public" returntype="any" output="false">
		<cfreturn variables.criteriaCollection />
	</cffunction>
	<cffunction name="isCriteriaCollectionDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a criteria collection is defined.">
		<cfif IsSimpleValue(variables.criteriaCollection)>
			<cfreturn Len(variables.criteriaCollection) />
		<cfelseif IsArray(variables.criteriaCollection)>
			<cfreturn ArrayLen(variables.criteriaCollection) />
		</cfif>
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
	
	<cffunction name="setClearDefaultStrategy" access="private" returntype="void" output="false">
		<cfargument name="clearDefaultStrategy" type="boolean" required="true" />
		<cfset variables.clearDefaultStrategy = arguments.clearDefaultStrategy />
	</cffunction>
	<cffunction name="getClearDefaultStrategy" access="public" returntype="boolean" output="false">
		<cfreturn variables.clearDefaultStrategy />
	</cffunction>

</cfcomponent>