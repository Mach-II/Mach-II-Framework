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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id: CacheStats.cfc 701 2008-03-22 22:07:01Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheStrategyManager"
	output="false"
	hint="Manages cache strategies.">

	<!---
	PROPERTIES
	--->
	<cfset variables.parent = "" />
	<cfset variables.cacheStrategies = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheStrategyManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="parentCacheStrategyManager" type="MachII.caching.CacheStrategyManager" required="false" />
		
		<!--- Set optional arguments if they exist --->
		<cfif StructKeyExists(arguments, "parentCacheStrategyManager")>
			<cfset setParent(arguments.parentCacheStrategyManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the cache strategies.">
		
		<cfset var strategies = getCacheStrategies() />
		<cfset var key = "" />
		
		<cfloop collection="#strategies#" item="key">
			<cfset strategies[key].configure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getCacheStrategyByName" access="public" returntype="MachII.caching.strategies.AbstractCacheStrategy" output="false"
		hint="Gets a cache strategy with the specified name.">
		<cfargument name="cacheStrategyName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent strategy manager." />
		
		<cfif isCacheStrategyDefined(arguments.cacheStrategyName)>
			<cfreturn variables.cacheStrategies[arguments.cacheStrategyName] />
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isCacheStrategyDefined(arguments.cacheStrategyName)>
			<cfreturn getParent().getCacheStrategyByName(arguments.cacheStrategyName, arguments.checkParent) />
		<cfelse>
			<cfthrow type="MachII.caching.CacheStrategyNotDefined" 
				message="Cache strategy with name '#arguments.cacheStrategyName#' is not defined."
				detail="Available cache strategies: '#ArrayToList(getCacheStrategyNames())#'" />
		</cfif>
	</cffunction>

	<cffunction name="addCacheStrategy" access="public" returntype="void" output="false"
		hint="Registers a cache strategy with the specified name.">
		<cfargument name="cacheStrategyName" type="string" required="true" />
		<cfargument name="cacheStrategy" type="MachII.caching.strategies.AbstractCacheStrategy" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isCacheStrategyDefined(arguments.cacheStrategyName)>
			<cfthrow type="MachII.caching.CacheStrategyAlreadyDefined"
				message="A Cache Strategy with name '#arguments.cacheStrategyName#' is already registered." />
		<cfelse>
			<cfset variables.cacheStrategies[arguments.cacheStrategyName] = cacheStrategy />
		</cfif>
	</cffunction>

	<cffunction name="isCacheStrategyDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a cache strategy is registered with the specified name. Does NOT check parent.">
		<cfargument name="cacheStrategyName" type="string" required="true"
			hint="Name of cache strategy to check if defined." />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent strategy manager." />
		
		<cfif StructKeyExists(variables.cacheStrategies, arguments.cacheStrategyName)>
			<cfreturn true />
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isCacheStrategyDefined(arguments.cacheStrategyName)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="loadStrategy" access="public" returntype="void" output="false"
		hint="Loads a cache strategy and adds the cache strategy to the manager.">
		<cfargument name="cacheStrategyName" type="string" required="true"
			hint="Name of cache strategy name." />
		<cfargument name="cacheStrategyType" type="string" required="true"
			hint="Dot path to the cache strategy." />
		<cfargument name="cacheStrategyParameters" type="struct" required="false" default="#StructNew()#"
			hint="Configuration parameters for the cache strategy." />
		
		<cfset var strategy = "" />
		
		<!--- Create the strategy --->
		<cftry>
			<cfset strategy = CreateObject("component", arguments.cacheStrategyType).init(arguments.cacheStrategyParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName")>
					<cfthrow type="MachII.caching.CannotFindCacheStrategy"
						message="Cannot find a cache strategy CFC with type of '#arguments.cacheStrategyType#' for the cache named '#arguments.cacheStrategyName#'."
						detail="Please check that the cache strategy exists and that there is not a misconfiguration." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfset addCacheStrategy(arguments.cacheStrategyName, strategy) />
	</cffunction>

	<cffunction name="getCacheStrategies" access="public" returntype="struct" output="false"
		hint="Gets all registered cache strategies for this manager. Does NOT get strategies from a parent manager.">
		<cfreturn variables.cacheStrategies />
	</cffunction>

	<cffunction name="getCacheStrategyNames" access="public" returntype="array" output="false"
		hint="Returns an array of cache strategy names for this manager. Does NOT get strategy names from a parent manager.">
		<cfreturn StructKeyArray(variables.cacheStrategies) />
	</cffunction>
	
	<cffunction name="containsCacheStrategies" access="public" returntype="boolean" output="false"
		hint="Returns a boolean of on whether or not there are any registered cache strategies.">
		<cfreturn StructCount(variables.cacheStrategies) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent CacheManager instance this CacheManager belongs to.">
		<cfargument name="parentCacheStrategyManager" type="MachII.caching.CacheStrategyManager" required="true" />
		<cfset variables.parent = arguments.parentCacheStrategyManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent CacheStrategyManager instance this CacheStrategyManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parent />
	</cffunction>

</cfcomponent>