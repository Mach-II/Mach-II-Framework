<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
$Id: AppManager.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.1

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
	<cfset variables.propertyManager = "" />
	<cfset variables.listenerManager = "" />
	<cfset variables.filterManager = "" />
	<cfset variables.eventManager = "" />
	<cfset variables.pluginManager = "" />
	<cfset variables.viewManager = "" />
	<cfset variables.requestHandler = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfset variables.requestHandler = CreateObject('component', 'MachII.framework.RequestHandler') />
		<cfset variables.requestHandler.init(this) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="configure" access="public" returntype="void"
		hint="Calls configure() on each of the manager instances.">
		<cfset getPropertyManager().configure() />
		<cfset getPluginManager().configure() />
		<cfset getListenerManager().configure() />
		<cfset getFilterManager().configure() />
		<cfset getEventManager().configure() />
		<cfset getViewManager().configure() />
	</cffunction>
	
	<cffunction name="createEventContext" access="public" returntype="MachII.framework.EventContext" output="false"
		hint="Creates an EventContext instance.">
		<cfargument name="requestEventName" type="string" required="true" />
		
		<cfset var eventContext = CreateObject('component', 'MachII.framework.EventContext') />
		<cfset eventContext.init(this, arguments.requestEventName) />
		<cfreturn eventContext />
	</cffunction>
	
	<cffunction name="createRequestHandler" access="public" returntype="MachII.framework.RequestHandler" output="false"
		hint="Creates a RequestHandler instance.">
		<cfset var requestHandler = CreateObject('component', 'MachII.framework.RequestHandler') />
		<cfset requestHandler.init(this) />
		<cfreturn requestHandler />
	</cffunction>
	
	<cffunction name="getRequestHandler" access="public" returntype="MachII.framework.RequestHandler" output="false"
		hint="Returns a new or cached instance of a RequestHandler.">
		<cfargument name="createNew" type="boolean" required="false" default="false"
			hint="Pass true to return a new instance of a RequestHandler." />
		
		<cfif arguments.createNew>
			<cfreturn createRequestHandler() />
		<cfelse>
			<cfreturn variables.requestHandler />
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setEventManager" access="public" returntype="void" output="false">
		<cfargument name="eventManager" type="MachII.framework.EventManager" required="true" />
		<cfset variables.eventManager = arguments.eventManager />
	</cffunction>
	<cffunction name="getEventManager" access="public" returntype="MachII.framework.EventManager" output="false">
		<cfreturn variables.eventManager />
	</cffunction>
	
	<cffunction name="setFilterManager" access="public" returntype="void" output="false">
		<cfargument name="filterManager" type="MachII.framework.FilterManager" required="true" />
		<cfset variables.filterManager = arguments.filterManager />
	</cffunction>
	<cffunction name="getFilterManager" access="public" returntype="MachII.framework.FilterManager" output="false">
		<cfreturn variables.filterManager />
	</cffunction>

	<cffunction name="setListenerManager" access="public" returntype="void" output="false">
		<cfargument name="listenerManager" type="MachII.framework.ListenerManager" required="true" />
		<cfset variables.listenerManager = arguments.listenerManager />
	</cffunction>	
	<cffunction name="getListenerManager" access="public" returntype="MachII.framework.ListenerManager" output="false">
		<cfreturn variables.listenerManager />
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

	<cffunction name="setViewManager" access="public" returntype="void" output="false">
		<cfargument name="viewManager" type="MachII.framework.ViewManager" required="true" />
		<cfset variables.viewManager = arguments.viewManager />
	</cffunction>
	<cffunction name="getViewManager" access="public" returntype="MachII.framework.ViewManager" output="false">
		<cfreturn variables.viewManager />
	</cffunction>
	
</cfcomponent>