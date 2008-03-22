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
Updated version: 1.6.0

Notes:
Configuring with default timespan strategy with default parameters:
<property name="Caching" type="MachII.caching.CachingProperty"/>

This will cache data for a timespan of 1 hour.

Configuring multiple caching strategires:
<property name="Caching" type="MachII.caching.CachingProperty">
      <parameters>
            <!-- Naming a default cache name is not required, but required if you do not want 
                 to specify the 'name' attribute in the cache command -->
			<parameter name="cachingEnabled" value="true" />
            <parameter name="defaultCacheName" value="default" />
            <parameter name="default">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.TimeSpanCache" />
                        <key name="scope" value="application" />
                        <key name="cacheFor" value="1" />
                        <key name="cacheUnit" value="hour" />
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
	<cfset variables.defaultCacheName = "default" />
	<cfset variables.cachingEnabled = true />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var params = getParameters() />
		<cfset var strategies = StructNew() />
		<cfset var key = "" />

		<!--- Set the default cache strategy
			(this must be done before default strategy is configured if required) --->
		<cfset setDefaultCacheName(getParameter("defaultCacheName", "default")) />
		
		<!--- Set caching mode
			(which is by default true) --->
		<cfset setCachingEnabled(getParameter("cachingEnabled", true)) />
		
		<!--- Load defined cache strategies --->
		<cfloop collection="#params#" item="key">
			<cfif IsStruct(params[key])>
				<cfset configureStrategy(key, getParameter(key)) />
			</cfif>
		</cfloop>

		<!--- Configure the default strategy if no strategies were set --->		
		<cfif NOT StructCount(getAppManager().getCacheManager().getCacheStrategies())>
			<cfset configureDefaultStrategy() />
		</cfif>
		
		<!--- Set the default cache strategy name (this must be done only after all strategies 
			have been added)--->
		<cfset getAppManager().getCacheManager().setDefaultCacheName(getDefaultCacheName()) />
		
		<!--- Set caching enabled/disabled --->
		<cfif NOT getCachingEnabled()>
			<cfset getAppManager().getCacheManager().disableCaching() />
		</cfif>
		
		
		<!--- Configure the registered stragies --->
		<cfset strategies = getAppManager().getCacheManager().getCacheStrategies() />
		
		<cfloop collection="#strategies#" item="key">
			<cfset strategies[key].configure() />
		</cfloop>
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
	<cffunction name="configureDefaultStrategy" access="private" returntype="void" output="false"
		hint="Configures the default caching strategy (e.g. MachII.caching.strategies.TimeSpanCache).">
		
		<cfset var strategy = "" />
		<cfset var parameters = StructNew() />
		
		<!--- Create the strategy --->
		<cfset strategy = CreateObject("component", "MachII.caching.strategies.TimeSpanCache").init(parameters) />
		<cfset strategy.setLog(getAppManager().getLogFactory()) />

		<!--- Set the strategy to the CacheManager  --->
		<cfset getAppManager().getCacheManager().addCacheStrategy(getDefaultCacheName(), strategy) />	
	</cffunction>
	
	<cffunction name="configureStrategy" access="private" returntype="void" output="false"
		hint="Configures a strategy.">
		<cfargument name="name" type="string" required="true"
			hint="Name of the strategy" />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this strategy." />

		<cfset var strategy = "" />
		<cfset var key = "" />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.caching.MissingCacheStrategyType"
				message="You must specify a parameter named 'type' for cache named '#arguments.name#' in module named '#getAppManager().getModuleName()#'." />
		</cfif>
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset arguments.parameters[key] = bindValue(key, arguments.parameters[key]) />
		</cfloop>
		
		<!--- Create the strategy --->
		<cftry>
			<cfset strategy = CreateObject("component", arguments.parameters.type).init(arguments.parameters) />
			<cfset strategy.setLog(getAppManager().getLogFactory()) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName")>
					<cfthrow type="MachII.caching.CannotFindCacheStrategy"
						message="The CachingProperty  in module named '#getAppManager().getModuleName()#' cannot find a cache strategy CFC with type of '#arguments.parameters.type#' for the cache named '#arguments.name#'."
						detail="Please check that the cache strategy exists and that there is not a misconfiguration in the XML configuration file." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>
		
		<!--- Set the strategy to the CacheManager --->
		<cfset getAppManager().getCacheManager().addCacheStrategy(arguments.name, strategy) />
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
		<cfargument name="cachingEnabled" type="boolean" required="true" />
		<cfset variables.cachingEnabled = arguments.cachingEnabled />
	</cffunction>
	<cffunction name="getCachingEnabled" access="public" returntype="boolean" output="false"
		hint="Gets the value if caching is enabled.">
		<cfreturn variables.cachingEnabled />
	</cffunction>
	
</cfcomponent>