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
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

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
				<cftry>
					<cfset cacheStrategies[cacheStrategyName].reap() />
					<cfcatch type="MachII.caching.strategies.NotImplemented">
						<!--- Do nothing an continue since the reap method is not implemented for this strategy --->
					</cfcatch>
					<cfcatch type="any">
						<cfrethrow />
					</cfcatch>
				</cftry>
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
				<cftry>
					<cfset cacheStrategies[cacheStrategyName].flush() />
					<cfcatch type="MachII.caching.strategies.NotImplemented">
						<!--- Do nothing an continue since the flush method is not implemented for this strategy --->
					</cfcatch>
					<cfcatch type="any">
						<cfrethrow />
					</cfcatch>
				</cftry>
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
		
		<cftry>
			<cfset cacheStrategy.reap() />
			<cfcatch type="MachII.caching.strategies.NotImplemented">
				<cfset message.setMessage("Cannot reap '#strategyName#' in module '#arguments.event.getArg("ModuleName")#' as this strategy does not support reap.") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
			<cfcatch type="any">
				<cfset message.setMessage("Cannot reap '#strategyName#' in module '#arguments.event.getArg("ModuleName")#' as an exception occurred.") />
				<cfset message.setType("warn") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage(), message.getCaughtException()) />
	</cffunction>
	
	<cffunction name="flushCacheStrategy" access="public" returntype="void" output="false"
		hint="Flushes a cache strategy.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var strategyName = arguments.event.getArg("strategyName") />
		<cfset var cacheStrategy = getCacheStrategyByModuleAndStrategyName(arguments.event.getArg("moduleName"), strategyName) />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Flushed '#strategyName#' in module '#arguments.event.getArg("ModuleName")#'.") />		
		
		<cftry>
			<cfset cacheStrategy.flush() />
			<cfcatch type="MachII.caching.strategies.NotImplemented">
				<cfset message.setMessage("Cannot flush '#strategyName#' in module '#arguments.event.getArg("ModuleName")#' as this strategy does not support flush.") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
			<cfcatch type="any">
				<cfset message.setMessage("Cannot flush '#strategyName#' in module '#arguments.event.getArg("ModuleName")#' as an exception occurred.") />
				<cfset message.setType("warn") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>
		
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