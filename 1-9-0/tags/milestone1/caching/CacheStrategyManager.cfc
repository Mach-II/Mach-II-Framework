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
$Id: CacheStats.cfc 701 2008-03-22 22:07:01Z peterfarrell $

Created version: 1.6.0
Updated version: 1.8.0

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
	
	<cfset variables.CACHE_STRATEGIES_SHORTCUTS = StructNew() />
	<cfset variables.CACHE_STRATEGIES_SHORTCUTS["TimeSpanCache"] = "MachII.caching.strategies.TimeSpanCache" />
	<cfset variables.CACHE_STRATEGIES_SHORTCUTS["LRUCache"] = "MachII.caching.strategies.LRUCache" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheStrategyManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="parentCacheStrategyManager" type="MachII.caching.CacheStrategyManager" required="false"
			hint="A reference to a parent CacheStrategyManager if available." />
		
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
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures all the cache strategies.">
		
		<cfset var strategies = getCacheStrategies() />
		<cfset var key = "" />
		
		<cfloop collection="#strategies#" item="key">
			<cfset strategies[key].deconfigure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getCacheStrategyByName" access="public" returntype="MachII.caching.strategies.AbstractCacheStrategy" output="false"
		hint="Gets a cache strategy with the specified name.">
		<cfargument name="cacheStrategyName" type="string" required="true"
			hint="The name of the cache stategy to get." />
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
		<cfargument name="cacheStrategyName" type="string" required="true"
			hint="The name of the cache strategy to add." />
		<cfargument name="cacheStrategy" type="MachII.caching.strategies.AbstractCacheStrategy" required="true"
			hint="A reference to the cache strategy." />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false"
			hint="A boolean to allow an already managed cache strategy to be overrided with a new one. Defaults to false." />
		
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
			hint="Name of cache strategy to check." />
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
		
		<!--- Resolve if a shortcut --->
		<cfset arguments.cacheStrategyType = resolveCacheTypeShortcut(arguments.cacheStrategyType) />
		<!--- Ensure type is correct in parameters (where it is duplicated) --->
		<cfset arguments.cacheStrategyParameters.type = arguments.cacheStrategyType />
		
		<!--- Create the strategy --->
		<cftry>
			<cfset strategy = CreateObject("component", arguments.cacheStrategyType).init(arguments.cacheStrategyParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ arguments.cacheStrategyType>
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
	
	<cffunction name="generateScopeKey" access="public" returntype="string" output="false"
		hint="Generates scope key for a cache strategy.">
		<cfargument name="cacheName" type="string" required="true"
			hint="The name of the cache strategy." />
		<cfargument name="appKey" type="string" required="false" default=""
			hint="The scope prefix before '._MachIICaching'. In Mach-II applications, this is the 'appKey' in the bootstrapper. This value should be a valid struct key (no spaces, dashes, periods, etc.)." />
		<cfargument name="moduleName" type="string" required="false"
			hint="The module name of the Mach-II application. Not required by non-Mach-II applications." />
		
		<cfset var baseKey = "" />
		<cfset var stringToHash = "_" />
		
		<!--- Fix that the base module in Mach-II applications is '' (zero-length string) --->
		<cfif StructKeyExists(arguments, "moduleName") AND NOT Len(arguments.moduleName)>
			<cfset arguments.moduleName = "_base_" />
		<cfelseif NOT StructKeyExists(arguments, "moduleName")>
			<cfset arguments.moduleName = "" />
		</cfif>
		
		<!--- Build the base key --->
		<cfset baseKey = arguments.appKey />
		<cfset baseKey = ListAppend(baseKey, "_MachIICaching", ".") />
		
		<!--- Build the string to hash --->
		<cfset stringToHash = arguments.moduleName />
		<cfset stringToHash = ListAppend(stringToHash, arguments.cachename, "_") />
		
		<cfreturn ListAppend(baseKey, "_" & Hash(stringToHash), ".") />
	</cffunction>

	<cffunction name="resolveCacheTypeShortcut" access="public" returntype="string" output="false"
		hint="Resolves a cache type shorcut and returns the passed value if no match is found.">
		<cfargument name="cacheStrategyType" type="string" required="true"
			hint="Dot path to the cache strategy." />
		
		<cfif StructKeyExists(variables.CACHE_STRATEGIES_SHORTCUTS, arguments.cacheStrategyType)>
			<cfreturn variables.CACHE_STRATEGIES_SHORTCUTS[arguments.cacheStrategyType] />
		<cfelse>
			<cfreturn arguments.cacheStrategyType />
		</cfif>
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
		hint="Returns the parent CacheStrategyManager instance this CacheStrategyManager belongs to.">
		<cfargument name="parentCacheStrategyManager" type="MachII.caching.CacheStrategyManager" required="true" />
		<cfset variables.parent = arguments.parentCacheStrategyManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent CacheStrategyManager instance this CacheStrategyManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parent />
	</cffunction>

</cfcomponent>