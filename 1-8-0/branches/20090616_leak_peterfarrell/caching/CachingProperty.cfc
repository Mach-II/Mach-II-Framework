<!---
License:
Copyright 2007 GreatBizTools, LLC

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
$Id$

Created version: 1.6.0
Updated version: 1.8.0

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
		
		<!--- Set caching enabled/disabled --->
		<cfif NOT isCachingEnabled()>
			<cfset getAppManager().getCacheManager().disableCaching() />
		</cfif>
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
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="configureStrategy" access="private" returntype="void" output="false"
		hint="Configures a strategy.">
		<cfargument name="cacheName" type="string" required="true"
			hint="Name of the cache strategy." />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this strategy." />

		<cfset var moduleName = getModuleName() />
		<cfset var key = "" />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.caching.MissingCacheStrategyType"
				message="You must specify a parameter named 'type' for cache named '#arguments.cacheName#' in module named '#moduleName#'." />
		</cfif>

		<!--- Add in scopeKey as a parameter --->
		<cfset arguments.parameters.generatedScopeKey = createCacheId(arguments.cacheName) />
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset arguments.parameters[key] = bindValue(key, arguments.parameters[key]) />
		</cfloop>
		
		<!--- Decide the logging enabled mode --->
		<cfif StructKeyExists(arguments.parameters, "cachingEnabled")>
			<cftry>
				<cfset arguments.parameters["cachingEnabled"] = decidedCachingEnabled(arguments.parameters["cachingEnabled"]) />
				<cfcatch type="MachII.util.IllegalArgument">
					<cfthrow type="MachII.caching.InvalidEnvironmentConfiguration"
						message="#cfcatch.message#"
						detail="This misconfiguration error occurred in cache strategy named '#arguments.cacheName#' in module named '#moduleName#'." />
				</cfcatch>
				<cfcatch type="any">
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- Load the strategy  --->
		<cfset getAppManager().getCacheManager().getCacheStrategyManager().loadStrategy(arguments.cacheName, arguments.parameters.type, arguments.parameters) />
	</cffunction>
	
	<cffunction name="createCacheId" access="private" returntype="string" output="false"
		hint="Creates a cache indentifier.">
		<cfargument name="cacheName" type="string" required="true" />
		
		<cfset var moduleName = getAppManager().getModuleName() />
		
		<cfif NOT Len(moduleName)>
			<cfset moduleName = "_base_" />
		</cfif>
		
		<cfreturn getAppManager().getAppKey() & "._MachIICaching._" & Hash(moduleName & "_" & arguments.cacheName) />
	</cffunction>
	
	<cffunction name="getModuleName" access="private" returntype="string" output="false"
		hint="Gets the module name.">

		<cfset var moduleName = getAppManager().getModuleName() />
		
		<cfif NOT Len(moduleName)>
			<cfset moduleName = "_base_" />
		</cfif>

		<cfreturn moduleName />
	</cffunction>
	
	<cffunction name="decidedCachingEnabled" access="private" returntype="boolean" output="false"
		hint="Decides if the caching is enabled.">
		<cfargument name="cachingEnabled" type="any" required="true" />
		
		<cfset var environmentName = getAppManager().getEnvironmentName() />
		<cfset var result = true />
		
		<cfset getAssert().isTrue(IsBoolean(arguments.cachingEnabled) OR IsStruct(arguments.cachingEnabled)
				, "The 'cachingEnabled' parameter must be boolean or a struct of environment names / groups.") />
		
		<!--- Load caching enabled since this is a simple value (no environment names / group) --->
		<cfif IsBoolean(arguments.cachingEnabled)>
			<cfset result = arguments.cachingEnabled />
		<!--- Load caching enabled by environment name / group --->
		<cfelse>
			<cfset result = resolveValueByEnvironment(arguments.cachingEnabled) />
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
					message="#cfcatch.message#"
					detail="This misconfiguration error is defined in the property-wide 'cachingEnabled' parameter in the caching property in module named '#getModuleName()#'." />
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