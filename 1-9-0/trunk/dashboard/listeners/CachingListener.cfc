<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="CachingListener" 
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for caching structures.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getCacheStrategies" access="public" returntype="struct" output="false"
		hint="Gets the data for all the modules including the base app.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var cacheStrategies = structNew() />
		
		<cfset getBaseCacheStrategies(cacheStrategies) />
		<cfset getModuleCacheStrategies(cacheStrategies) />
		
		<cfreturn cacheStrategies />
	</cffunction>
	
	<cffunction name="enableDisableAll" access="public" returntype="void" output="false"
		hint="Enables a cache strategy.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var cacheStrategiesByModule = getCacheStrategies(arguments.event) />
		<cfset var cacheStrategies = "" />
		<cfset var mode = arguments.event.getArg("mode") />		
		<cfset var module = "" />
		<cfset var cacheStrategyName = "" />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
		
		<cfloop collection="#cacheStrategiesByModule#" item="module">
		
			<cfset cacheStrategies = cacheStrategiesByModule[module] />
			
			<cfloop collection="#cacheStrategies#" item="cacheStrategyName">
				<cfif mode EQ "enable">
					<cfset cacheStrategies[cacheStrategyName].setCacheEnabled(true) />
				<cfelse>
					<cfset cacheStrategies[cacheStrategyName].setCacheEnabled(false) />
				</cfif>				
			</cfloop>
		</cfloop>
		
		<cfif mode EQ "enable">
			<cfset message.setMessage("Enabled all cache strategies.") />
		<cfelse>
			<cfset message.setMessage("Disabled all cache strategies.") />
		</cfif>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>
	
	<cffunction name="reapAll" access="public" returntype="void" output="false"
		hint="Reaps all cache strategies.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var cacheStrategiesByModule = getCacheStrategies(arguments.event) />
		<cfset var cacheStrategies = "" />
		<cfset var module = "" />
		<cfset var cacheStrategyName = "" />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reaped all cache strategies.") />
		
		<cfloop collection="#cacheStrategiesByModule#" item="module">
		
			<cfset cacheStrategies = cacheStrategiesByModule[module] />
			
			<cfloop collection="#cacheStrategies#" item="cacheStrategyName">
				<cfset cacheStrategies[cacheStrategyName].reap() />
			</cfloop>
		</cfloop>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>
	
	<cffunction name="flushAll" access="public" returntype="void" output="false"
		hint="Reaps all cache strategies.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var cacheStrategiesByModule = getCacheStrategies(arguments.event) />
		<cfset var cacheStrategies = "" />
		<cfset var module = "" />
		<cfset var cacheStrategyName = "" />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Flushed all cache strategies.") />
		
		<cfloop collection="#cacheStrategiesByModule#" item="module">
		
			<cfset cacheStrategies = cacheStrategiesByModule[module] />
			
			<cfloop collection="#cacheStrategies#" item="cacheStrategyName">
				<cfset cacheStrategies[cacheStrategyName].flush() />
			</cfloop>
		</cfloop>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>
	
	<cffunction name="enableDisableCacheStrategy" access="public" returntype="void" output="false"
		hint="Enables/disables a cache strategy.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var cacheStrategy = "" />
		<cfset var strategyName = arguments.event.getArg("strategyName") />
		<cfset var mode = arguments.event.getArg("mode") />	
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />	

		<cfset cacheStrategy = getCacheStrategyByModuleAndStrategyName(arguments.event.getArg("moduleName"), strategyName) />
		
		<cfif mode EQ "enable">
			<cfset cacheStrategy.setCacheEnabled(true) />
			<cfset message.setMessage("Enabled '#strategyName#' in module '#arguments.event.getArg("ModuleName")#'.") />
			<cfset arguments.event.setArg("message", message) />
		<cfelse>
			<cfset cacheStrategy.setCacheEnabled(false) />
			<cfset message.setMessage("Disabled '#strategyName#' in module '#arguments.event.getArg("ModuleName")#'.") />
			<cfset arguments.event.setArg("message", message) />
		</cfif>
	</cffunction>
	
	<cffunction name="reapCacheStrategy" access="public" returntype="void" output="false"
		hint="Reaps a cache strategy.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var strategyName = arguments.event.getArg("strategyName") />
		<cfset var cacheStrategy = getCacheStrategyByModuleAndStrategyName(arguments.event.getArg("moduleName"), strategyName) />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reaped '#strategyName#' in module '#arguments.event.getArg("ModuleName")#'.") />		

		<cfset cacheStrategy.reap() />
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>
	
	<cffunction name="flushCacheStrategy" access="public" returntype="void" output="false"
		hint="Flushes a cache strategy.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var strategyName = arguments.event.getArg("strategyName") />
		<cfset var cacheStrategy = getCacheStrategyByModuleAndStrategyName(arguments.event.getArg("moduleName"), strategyName) />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Flushed '#strategyName#' in module '#arguments.event.getArg("ModuleName")#'.") />		

		<cfset cacheStrategy.flush() />
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getCacheStrategyByModuleAndStrategyName" access="private" returntype="any" output="false"
		hint="Gets a cache strategy by module and strategy name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="strategyName" type="string" required="true" />
		
		<cfset var cacheStrategyManager = "" />
		<cfset var cacheStrategy = "" />
		
		<cfif arguments.moduleName EQ "base">
			<cfset cacheStrategyManager = getAppManager().getParent().getCacheManager().getCacheStrategyManager() />
		<cfelse>
			<cfset cacheStrategyManager = getAppManager().getModuleManager().getModule(arguments.moduleName).getModuleAppManager().getCacheManager().getCacheStrategyManager() />
		</cfif>
				
		<cfset cacheStrategy = cacheStrategyManager.getCacheStrategyByName(strategyName) />
		
		<cfreturn cacheStrategy />
	</cffunction>
	
	<cffunction name="getModuleCacheStrategies" access="private" returntype="struct" output="false"
		hint="Gets the data for all the modules.">
		<cfargument name="cacheStrategies" type="struct" required="true" />
		
		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var cacheStrategyManager = "" />
		<cfset var cacheStrategyNames = "" />
		<cfset var key = "" />
		<cfset var i = 0>
		
		<cfloop collection="#modules#" item="key">
			<cfset cacheStrategyManager = modules[key].getModuleAppManager().getCacheManager().getCacheStrategyManager() />
			<cfset cacheStrategyNames = cacheStrategyManager.getCacheStrategyNames() />

			<cfif ArrayLen(cacheStrategyNames)>
				<cfset arguments.cacheStrategies[key] = structNew() />
				<cfloop from="1" to="#ArrayLen(cacheStrategyNames)#" index="i">
					<cfset arguments.cacheStrategies[key][cacheStrategyNames[i]] = cacheStrategyManager.getCacheStrategyByName(cacheStrategyNames[i]) />
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn arguments.cacheStrategies />
	</cffunction>
	
	<cffunction name="getBaseCacheStrategies" access="private" returntype="void" output="false"
		hint="Gets the cache strategies for the base app.">
		<cfargument name="cacheStrategies" type="struct" required="true" />

		<cfset var cacheStrategyManager = getAppManager().getParent().getCacheManager().getCacheStrategyManager() />
		<cfset var cacheStrategyNames = cacheStrategyManager.getCacheStrategyNames() />
		<cfset var key = "base" />
		<cfset var i = 0 />

		<cfloop from="1" to="#arrayLen(cacheStrategyNames)#" index="i">
			<cfset arguments.cacheStrategies[key][cacheStrategyNames[i]] = cacheStrategyManager.getCacheStrategyByName(cacheStrategyNames[i]) />
		</cfloop>
	</cffunction>

</cfcomponent>