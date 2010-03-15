<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.6.0
Updated version: 1.9.0

Notes:
Simple configuration that uses the timespan strategy with its' default parameters
as the basic strategy:
<property name="Caching" type="MachII.caching.CachingProperty"/>

This will cache data for a timespan of 1 hour by using the 
MachII.caching.strategies.TimeSpanCache

Example configuration of multiple caching strategires:
<property name="Caching" type="MachII.caching.CachingProperty">
      <parameters>
            <!-- Naming a default cache name is not required, but required if you do not want 
                 to specify the 'name' attribute in the cache command -->
			<parameter name="cachingEnabled" value="true" />
			- OR -
			<parameter name="cachingEnabled">
				<struct>
					<key name="development" value="false" />
					<key name="production" value="true" />
				</struct>
			</parameter>
            <parameter name="defaultCacheName" value="foo" />
            <parameter name="foo">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.TimeSpanCache" />
                        <key name="scope" value="application" />
                        <key name="timespan" value="0,1,0,0"/><!-- Cache for 1 hour -->
						<key name="cleanupIntervalInMinutes" value="3" />
                  </struct>
            </parameter>
            <parameter name="bar">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.LRUCache" />
                        <key name="size" value="100" />
                        <key name="scope" value="application" />
                  </struct>
            </parameter>
      </parameters>
</property>

See individual caching strategies for more information on configuration.
--->
<cfcomponent
	displayname="CachingProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Allows you to configure the Mach-II caching features.">
	
	<!---
	PROPERTIES
	--->
	<!--- Default cache name default value is programmatically discovered --->
	<cfset variables.defaultCacheName = "Default" />
	<cfset variables.defaultCacheType = "MachII.caching.strategies.TimeSpanCache" />
	<cfset variables.cachingEnabled = true />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var cacheStrategyManager = getAppManager().getCacheManager().getCacheStrategyManager() />
		<cfset var params = getParameters() />
		<cfset var defaultCacheParameters = StructNew() />
		<cfset var key = "" />

		<!--- Set the "global" caching enabled directive --->
		<cfset setCachingEnabled(getParameter("cachingEnabled", true)) />
		
		<!--- Load defined cache strategies --->
		<cfloop collection="#params#" item="key">
			<cfif key NEQ "cachingEnabled" AND IsStruct(params[key])>
				<cfset configureStrategy(key, getParameter(key)) />
			</cfif>
		</cfloop>

		<!--- Configure the default strategy if no strategies were set --->		
		<cfif NOT StructCount(cacheStrategyManager.getCacheStrategies())>
			<cfset defaultCacheParameters.type = variables.defaultCacheType />
			<cfset configureStrategy(variables.defaultCacheName, defaultCacheParameters) />
		</cfif>

		<!--- Set the default cache strategy if defined in the parameters --->
		<cfif isParameterDefined("defaultCacheName")>
			<cfset setDefaultCacheName(getParameter("defaultCacheName")) />
		<!--- Set the default cache name if there is only one strategy defined --->
		<cfelseif StructCount(cacheStrategyManager.getCacheStrategies()) EQ 1>
			<cfset setDefaultCacheName(ListGetAt(StructKeyList(cacheStrategyManager.getCacheStrategies()), 1)) />
		</cfif>
		
		<!--- Set the default cache strategy name (this must be done only after all strategies 
			have been added)--->
		<cfset getAppManager().getCacheManager().setDefaultCacheName(getDefaultCacheName()) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="disableCaching" access="public" returntype="void" output="false"
		hint="Disables caching. Same as calling getAppManager().getCacheManager().disableCaching()">
		<cfset getAppManager().getCacheManager().disableCaching() />
	</cffunction>
	<cffunction name="enableCaching" access="public" returntype="void" output="false"
		hint="Enables caching. Same as calling getAppManager().getCacheManager().enableCaching()">
		<cfset getAppManager().getCacheManager().enableCaching() />
	</cffunction>
	
	<cffunction name="configureStrategy" access="public" returntype="void" output="false"
		hint="Configures a strategy.">
		<cfargument name="cacheName" type="string" required="true"
			hint="Name of the cache strategy." />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this strategy." />

		<cfset var cacheStrategyManager = getAppManager().getCacheManager().getCacheStrategyManager() />
		<cfset var moduleName = getAppManager().getModuleName() />
		<cfset var key = "" />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.caching.MissingCacheStrategyType"
				message="You must specify a parameter named 'type' for cache named '#arguments.cacheName#' in module named '#moduleName#'." />
		</cfif>

		<!--- Generated a scopeKey as a parameter --->
		<cfset arguments.parameters.generatedScopeKey = cacheStrategyManager.generateScopeKey(arguments.cacheName, getAppManager().getAppKey(), moduleName) />
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset arguments.parameters[key] = bindValue(key, arguments.parameters[key]) />
		</cfloop>
		
		<!--- Decide the "local" caching enabled mode --->
		<cfif StructKeyExists(arguments.parameters, "cachingEnabled")>
			<cftry>
				<cfset arguments.parameters["cachingEnabled"] = decidedCachingEnabled(arguments.parameters["cachingEnabled"]) />
				<cfcatch type="MachII.util.IllegalArgument">
					<cfthrow type="MachII.caching.InvalidEnvironmentConfiguration"
						message="This misconfiguration error occurred in cache strategy named '#arguments.cacheName#' in module named '#moduleName#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
				<cfcatch type="any">
					<cfrethrow />
				</cfcatch>
			</cftry>
		<!--- Fall back to the "global" caching mode if no "local" mode defined--->
		<cfelse>
			<cfset arguments.parameters["cachingEnabled"] = isCachingEnabled() />
		</cfif>
		
		<!--- Load the strategy  --->
		<cfset cacheStrategyManager.loadStrategy(arguments.cacheName, arguments.parameters.type, arguments.parameters) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="decidedCachingEnabled" access="private" returntype="boolean" output="false"
		hint="Decides if the caching is enabled.">
		<cfargument name="cachingEnabled" type="any" required="true" />
		
		<cfset var result = true />
		
		<cfset getAssert().isTrue(IsBoolean(arguments.cachingEnabled) OR IsStruct(arguments.cachingEnabled)
				, "The 'cachingEnabled' parameter for 'CachingProperty' in module '#getAppManager().getModuleName()#' must be boolean or a struct of environment names / groups.") />
		
		<!--- Load caching enabled since this is a simple value (no environment names / group) --->
		<cfif IsBoolean(arguments.cachingEnabled)>
			<cfset result = arguments.cachingEnabled />
		<!--- Load caching enabled by environment name / group --->
		<cfelse>
			<cfset result = resolveValueByEnvironment(arguments.cachingEnabled, true) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setDefaultCacheName" access="public" returntype="string" output="false">
		<cfargument name="defaultCacheName" type="string" required="true" />
		<cfset variables.defaultCacheName = arguments.defaultCacheName />
	</cffunction>
	<cffunction name="getDefaultCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.defaultCacheName />
	</cffunction>
	
	<cffunction name="setCachingEnabled" access="public" returntype="void" output="false"
		hint="Sets if caching is enabled.">
		<cfargument name="cachingEnabled" type="any" required="true" />
		
		<cftry>
			<cfset variables.cachingEnabled = decidedCachingEnabled(arguments.cachingEnabled) />
			<cfcatch type="MachII.util.IllegalArgument">
				<cfthrow type="MachII.caching.InvalidEnvironmentConfiguration"
					message="This misconfiguration error is defined in the property-wide 'cachingEnabled' parameter in the caching property in module named '#getModuleName()#'."
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>			
		</cftry>
	</cffunction>
	<cffunction name="isCachingEnabled" access="public" returntype="boolean" output="false"
		hint="Gets the value if caching is enabled.">
		<cfreturn variables.cachingEnabled />
	</cffunction>
	
</cfcomponent>