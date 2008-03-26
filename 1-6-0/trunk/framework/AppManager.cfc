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
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
- Added request event name functionality. (pfarrell)
--->
<cfcomponent 
	displayname="AppManager" 
	output="false"
	hint="The main framework manager.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.moduleName = "" />
	<cfset variables.appLoader = "" />
	<cfset variables.filterManager = "" />
	<cfset variables.listenerManager = "" />
	<cfset variables.messageManager = "" />
	<cfset variables.eventManager = "" />
	<cfset variables.moduleManager = "" />
	<cfset variables.propertyManager = "" />
	<cfset variables.pluginManager = "" />
	<cfset variables.requestManager = "" />
	<cfset variables.subroutineManager = "" />
	<cfset variables.cacheManager = "" />
	<cfset variables.utils = "" />
	<cfset variables.logFactory = "" />
	<cfset variables.viewManager = "" />
	<cfset variables.parentAppManager = "" />
	<cfset variables.appkey = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AppManager" output="false"
		hint="Used by the framework for initialization. Do not override.">		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="configure" access="public" returntype="void"
		hint="Calls configure() on each of the manager instances.">
		<!--- In order in which the managers are called is important
			DO NOT CHANGE ORDER OF METHOD CALLS --->
		<cfset getPropertyManager().configure() />
		<cfset getCacheManager().configure() />
		<cfset getRequestManager().configure() />
		<cfset getPluginManager().configure() />
		<cfset getListenerManager().configure() />
		<cfset getMessageManager().configure() />
		<cfset getFilterManager().configure() />
		<cfset getSubroutineManager().configure() />
		<cfset getEventManager().configure() />
		<cfset getViewManager().configure() />
		
		<!--- Module Manager is a singleton only call if this is the parent AppManager --->
		<cfif NOT IsObject(getParent())>
			<cfset getModuleManager().configure() />
		</cfif>
	</cffunction>
	
	<cffunction name="getRequestHandler" access="public" returntype="MachII.framework.RequestHandler" output="false"
		hint="Returns a new or cached instance of a RequestHandler.">
		<cfargument name="createNew" type="boolean" required="false" default="false"
			hint="Pass true to return a new instance of a RequestHandler." />
		<cfreturn getRequestManager().getRequestHandler(arguments.createNew) />
	</cffunction>
	
	<cffunction name="onSessionStart" access="public" returntype="void" output="false"
		hint="Handles on session start application event.">
		
		<cfset var modules = "" />
		<cfset var key = "" />
		
		<!--- Call this instance first --->
		<cfset getPluginManager().onSessionStart() />
		
		<!--- Call module instances only if this is the parent AppManager --->
		<cfif NOT IsObject(getParent())>
			
			<cfset modules = variables.moduleManager.getModules() />
			
			<cfloop collection="#modules#" item="key">
				<cfset modules[key].getModuleAppManager().onSessionStart() />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="Handles on session end application event.">
		<cfargument name="sessionScope" type="struct" required="true"
			hint="The session scope is passed in since direct access is not allowed during the on session end application event." />
		
		<cfset var modules = "" />
		<cfset var key = "" />
		
		<!--- Call this instance first --->
		<cfset getPluginManager().onSessionEnd(arguments.sessionScope) />
		
		<!--- Call module instances only if this is the parent AppManager --->
		<cfif NOT IsObject(getParent())>
			
			<cfset modules = variables.moduleManager.getModules() />
			
			<cfloop collection="#modules#" item="key">
				<cfset modules[key].getModuleAppManager().onSessionEnd(arguments.sessionScope) />
			</cfloop>
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setModuleName" access="public" returntype="void" output="false"
		hint="Sets the module name for this instance of the AppManager.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="public" returntype="string" output="false"
		hint="Gets the module name for this instance of the AppManager.">
		<cfreturn variables.moduleName />
	</cffunction>
	
	<cffunction name="setAppLoader" access="public" returntype="void" output="false"
		hint="Sets the AppLoader instance.">
		<cfargument name="appLoader" type="MachII.framework.AppLoader" required="true" />
		<cfset variables.appLoader = arguments.appLoader />
	</cffunction>
	<cffunction name="getAppLoader" access="public" returntype="MachII.framework.AppLoader" output="false"
		hint="Returns the AppLoader instance.">
		<cfreturn variables.appLoader />
	</cffunction>
	
	<cffunction name="setEventManager" access="public" returntype="void" output="false">
		<cfargument name="eventManager" type="MachII.framework.EventManager" required="true" />
		<cfset variables.eventManager = arguments.eventManager />
	</cffunction>
	<cffunction name="getEventManager" access="public" returntype="MachII.framework.EventManager" output="false">
		<cfreturn variables.eventManager />
	</cffunction>
	
	<cffunction name="setCacheManager" access="public" returntype="void" output="false">
		<cfargument name="cacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfset variables.cacheManager = arguments.cacheManager />
	</cffunction>
	<cffunction name="getCacheManager" access="public" returntype="MachII.framework.CacheManager" output="false">
		<cfreturn variables.cacheManager />
	</cffunction>
	
	<cffunction name="setFilterManager" access="public" returntype="void" output="false">
		<cfargument name="filterManager" type="MachII.framework.EventFilterManager" required="true" />
		<cfset variables.filterManager = arguments.filterManager />
	</cffunction>
	<cffunction name="getFilterManager" access="public" returntype="MachII.framework.EventFilterManager" output="false">
		<cfreturn variables.filterManager />
	</cffunction>

	<cffunction name="setListenerManager" access="public" returntype="void" output="false">
		<cfargument name="listenerManager" type="MachII.framework.ListenerManager" required="true" />
		<cfset variables.listenerManager = arguments.listenerManager />
	</cffunction>	
	<cffunction name="getListenerManager" access="public" returntype="MachII.framework.ListenerManager" output="false">
		<cfreturn variables.listenerManager />
	</cffunction>

	<cffunction name="setMessageManager" access="public" returntype="void" output="false">
		<cfargument name="messageManager" type="MachII.framework.MessageManager" required="true" />
		<cfset variables.messageManager = arguments.messageManager />
	</cffunction>	
	<cffunction name="getMessageManager" access="public" returntype="MachII.framework.MessageManager" output="false">
		<cfreturn variables.messageManager />
	</cffunction>

	<cffunction name="setModuleManager" access="public" returntype="void" output="false">
		<cfargument name="moduleManager" type="MachII.framework.ModuleManager" required="true" />
		<cfset variables.moduleManager = arguments.moduleManager />
	</cffunction>	
	<cffunction name="getModuleManager" access="public" returntype="MachII.framework.ModuleManager" output="false">
		<cfreturn variables.moduleManager />
	</cffunction>

	<cffunction name="setPropertyManager" access="public" returntype="void" output="false">
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		<cfset variables.propertyManager = arguments.propertyManager />
	</cffunction>	
	<cffunction name="getPropertyManager" access="public" returntype="MachII.framework.PropertyManager" output="false">
		<cfreturn variables.propertyManager />
	</cffunction>

	<cffunction name="setPluginManager" access="public" returntype="void" output="false">
		<cfargument name="pluginManager" type="MachII.framework.PluginManager" required="true" />
		<cfset variables.pluginManager = arguments.pluginManager />
	</cffunction>	
	<cffunction name="getPluginManager" access="public" returntype="MachII.framework.PluginManager" output="false">
		<cfreturn variables.pluginManager />
	</cffunction>
	
	<cffunction name="setRequestManager" access="public" returntype="void" output="false">
		<cfargument name="requestManager" type="MachII.framework.RequestManager" required="true" />
		<cfset variables.requestManager = arguments.requestManager />
	</cffunction>	
	<cffunction name="getRequestManager" access="public" returntype="MachII.framework.RequestManager" output="false">
		<cfreturn variables.requestManager />
	</cffunction>
	
	<cffunction name="setSubroutineManager" access="public" returntype="void" output="false">
		<cfargument name="subroutineManager" type="MachII.framework.SubroutineManager" required="true" />
		<cfset variables.subroutineManager = arguments.subroutineManager />
	</cffunction>
	<cffunction name="getSubroutineManager" access="public" returntype="MachII.framework.SubroutineManager" output="false">
		<cfreturn variables.subroutineManager />
	</cffunction>
	
	<cffunction name="setUtils" access="public" returntype="void" output="false">
		<cfargument name="utils" type="MachII.util.Utils" required="true" />
		<cfset variables.utils = arguments.utils />
	</cffunction>
	<cffunction name="getUtils" access="public" returntype="MachII.util.Utils" output="false">
		<cfreturn variables.utils />
	</cffunction>

	<cffunction name="setViewManager" access="public" returntype="void" output="false">
		<cfargument name="viewManager" type="MachII.framework.ViewManager" required="true" />
		<cfset variables.viewManager = arguments.viewManager />
	</cffunction>
	<cffunction name="getViewManager" access="public" returntype="MachII.framework.ViewManager" output="false">
		<cfreturn variables.viewManager />
	</cffunction>
	
	<cffunction name="setLogFactory" access="public" returntype="void" output="false">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.logFactory = arguments.logFactory />
	</cffunction>
	<cffunction name="getLogFactory" access="public" returntype="MachII.logging.LogFactory" output="false">
		<cfreturn variables.logFactory />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="parentAppManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.parentAppManager = arguments.parentAppManager />
	</cffunction>	
	<cffunction name="getParent" access="public" returntype="any" output="false">
		<cfreturn variables.parentAppManager />
	</cffunction>
	
	<cffunction name="setAppKey" access="public" returntype="void" output="false">
		<cfargument name="appkey" type="string" required="true" />
		<cfset variables.appkey = arguments.appkey />
	</cffunction>
	<cffunction name="getAppKey" access="public" type="string" output="false">
		<cfreturn variables.appkey />
	</cffunction>
	
</cfcomponent>