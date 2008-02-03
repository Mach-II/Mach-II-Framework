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

Configuring multiple caching adapters:
<property name="Caching" type="MachII.caching.CachingProperty">
      <parameters>
            <!-- Naming a default cache name is not required, but required if you do not want 
                 to specify the 'cacheName' attribute in the cache command -->
            <parameter name="defaultCacheName" value="default" />
            <parameter name="default">
                  <struct>
                        <key name="type" value="MachII.caching.strategies.MachIICache" />
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
	<cfset variables.defaultCacheName = "" />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var params = getParameters() />
		<cfset var configured = false />
		<cfset var i = 0 />
		
		<cftrace text="cachingproperty configure() called!">
		
		<!--- The default cache strategy if present --->
		<cfif isParameterDefined("defaultCacheName")>
			<cfset setDefaultCacheName(getParameter("defaultCacheName")) />
		</cfif>
		
		<cfloop collection="#params#" item="i">
			<cfif IsStruct(params[i])>
				<cfset configureStrategy(i, getParameter(i)) />
				<cfset configured = true />
			</cfif>
		</cfloop>
		
		<!--- Configure the default adapter since no adapters were set
		<cfif NOT configured>
			<cfset configureDefaultStrategy() />
		</cfif>  --->
		
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<!--- <cffunction name="configureDefaultStrategy" access="private" returntype="void" output="false"
		hint="Configures the default caching strategy (e.g. MachII.caching.strategies.MachIICache).">
		
		<cfset var strategy = "" />
		<cfset var parameters = StructNew() />
		
		<cfset strategy = CreateObject("component", "MachII.caching.strategies.MachIICache").init(parameters) />
		<cfset strategy.configure() />

		<!--- Set the adapter to the CacheManager  --->
		<cfset getAppManager().getCacheManager().addCacheStrategy("default", strategy) />	
	</cffunction> --->
	
	<cffunction name="configureStrategy" access="private" returntype="void" output="false"
		hint="Configures an strategy.">
		<cfargument name="name" type="string" required="true"
			hint="Name of the strategy" />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this strategy.">
		
		<cfset var type = "" />
		<cfset var strategy = "" />
		<cfset var i = 0 />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.caching.CachingProperty"
				message="You must specify a 'type' for cache named '#arguments.name#'." />
		</cfif>
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="i">
			<cfset arguments.parameters[i] = bindValue(i, arguments.parameters[i]) />
		</cfloop>
		
		<!--- Create the adapter --->
		<cfset strategy = CreateObject("component", arguments.parameters.type).init(arguments.parameters) />
		<cfset strategy.configure() />
		
		<!--- Set the strategy to the CacheManager --->
		<cfset getAppManager().getCacheManager().addCacheStrategy(arguments.name, strategy) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="getDefaultCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.defaultCacheName />
	</cffunction>
	<cffunction name="setDefaultCacheName" access="public" returntype="string" output="false">
		<cfargument name="defaultCacheName" type="string" required="true" />
		<cfset variables.defaultCacheName = arguments.defaultCacheName />
	</cffunction>
	
</cfcomponent>