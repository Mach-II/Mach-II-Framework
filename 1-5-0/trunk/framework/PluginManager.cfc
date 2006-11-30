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
$Id: PluginManager.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Notes:
- Added introspection to call only defined plugin points. (dross, pfarrell, hklein)
--->
<cfcomponent 
	displayname="PluginManager"
	output="false"
	hint="Manages registered Plugins for the framework instance.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.plugins = StructNew() />
	<cfset variables.pluginArray = ArrayNew(1) />
	<cfset variables.preProcessPlugins = ArrayNew(1) />
	<cfset variables.preEventPlugins = ArrayNew(1) />
	<cfset variables.postEventPlugins = ArrayNew(1) />
	<cfset variables.preViewPlugins = ArrayNew(1) />
	<cfset variables.postViewPlugins = ArrayNew(1) />
	<cfset variables.postProcessPlugins = ArrayNew(1) />
	<cfset variables.handleExceptionPlugins = ArrayNew(1) />
	<cfset variables.nPlugins = 0 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset var xnPlugins = 0 />
		<cfset var xnParams = 0 />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var paramName = 0 />
		<cfset var paramValue = 0 />
		<cfset var plugin = 0 />
		<cfset var pluginName = 0 />
		<cfset var pluginType = 0 />
		<cfset var pluginParams = 0 />
		
		<cfset setAppManager(arguments.appManager) />
		<!--- Scoped argument variable - configXML --->
		<cfset xnPlugins = XMLSearch(arguments.configXML, "//plugins/plugin" ) />
		<cfloop index="i" from="1" to="#ArrayLen(xnPlugins)#">
			<cfset pluginName = xnPlugins[i].XmlAttributes['name'] />
			<cfset pluginType = xnPlugins[i].XmlAttributes['type'] />
			
			<!--- for each plugin, parse all the parameters --->
			<cfset pluginParams = StructNew() />
			<cfset xnParams = XMLSearch(xnPlugins[i], "./parameters/parameter") />
			<cfloop index="j" from="1" to="#ArrayLen(xnParams)#">
				<cfset paramName = xnParams[j].XmlAttributes['name'] />
				<cfset paramValue = xnParams[j].XmlAttributes['value'] />
				
				<cfset StructInsert(pluginParams, paramName, paramValue, true) />
			</cfloop>
			
			<cfset plugin = CreateObject('component', pluginType) />
			<cfset plugin.init(arguments.appManager, pluginParams) />
			<cfset addPlugin(pluginName, plugin) />
		</cfloop>
				
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered Plugins.">
		<cfset var aPlugin = 0 />
		<cfset var i = 0 />
		<cfloop index="i" from="1" to="#variables.nPlugins#">
			<cfset aPlugin = variables.pluginArray[i] />
			<cfset aPlugin.configure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getPlugin" access="public" returntype="MachII.framework.Plugin" output="false"
		hint="Gets a plugin with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />
		
		<cfif isPluginDefined(arguments.pluginName)>
			<cfreturn variables.plugins[arguments.pluginName] />
		<cfelse>
			<cfthrow type="MachII.framework.PluginNotDefined" 
				message="Plugin with name '#arguments.pluginName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="addPlugin" access="public" returntype="void" output="false"
		hint="Registers a plugin with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfargument name="plugin" type="MachII.framework.Plugin" required="true" />
		<cfset var i = 0 />
		<cfset var pointName = 0 />
		<cfset var pluginRegisteredPoints = listToArray(findPluginPoints(arguments.plugin)) />		

		<cfif isPluginDefined(arguments.pluginName)>
			<cfthrow type="MachII.framework.PluginAlreadyDefined"
				message="A Plugin with name '#arguments.pluginName#' is already registered." />
		<cfelse>
			<cfset variables.plugins[arguments.pluginName] = arguments.plugin />
			
			<cfset variables.nPlugins = variables.nPlugins + 1 />
			<cfset variables.pluginArray[variables.nPlugins] = arguments.plugin />
			
			<!--- add references to this plugin for each registered point --->
			<cfloop index="i" from="1" to="#arraylen(pluginRegisteredPoints)#">
				<cfset pointName = pluginRegisteredPoints[i] />
				<cfif structKeyExists(variables,pointName & "Plugins")>
					<cfset arrayAppend(variables[pointName & "Plugins" ], arguments.plugin) />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="isPluginDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a Plugin is registered with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.plugins, arguments.pluginName) />
	</cffunction>
	
	<!---
	PLUGIN POINT FUNCTIONS called from EventContext
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="true"
		hint="preProcess() is called for each new EventContext once before event processing begins.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" 
			hint="The EventContext of the processing." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.preProcessPlugins)#">
			<cfset variables.preProcessPlugins[i].preProcess(arguments.eventContext) />
		</cfloop>
	</cffunction>
	
	<cffunction name="preEvent" access="public" returntype="void" output="true"
		hint="preEvent() is called for each announced Event before it is handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.preEventPlugins)#">
			<cfset variables.preEventPlugins[i].preEvent(arguments.eventContext) />
		</cfloop>
	</cffunction>

	<cffunction name="postEvent" access="public" returntype="void" output="true"
		hint="postEvent() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.postEventPlugins)#">
			<cfset variables.postEventPlugins[i].postEvent(arguments.eventContext) />
		</cfloop>
	</cffunction>
	
	<cffunction name="preView" access="public" returntype="void" output="true"
		hint="preView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.preViewPlugins)#">
			<cfset variables.preViewPlugins[i].preView(arguments.eventContext) />
		</cfloop>
	</cffunction>

	<cffunction name="postView" access="public" returntype="void" output="true"
		hint="postView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.postViewPlugins)#">
			<cfset variables.postViewPlugins[i].postView(arguments.eventContext) />
		</cfloop>
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="true"
		hint="postProcess() is called for each new EventContext once after event processing completes.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" 
			hint="The EventContext of the processing." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.postProcessPlugins)#">
			<cfset variables.postProcessPlugins[i].postProcess(arguments.eventContext) />
		</cfloop>
	</cffunction>

	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="handleException() is called for each exception caught by the framework.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext under which the exception was thrown/caught." />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception object." />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#arrayLen(variables.handleExceptionPlugins)#">
			<cfset variables.handleExceptionPlugins[i].handleException(arguments.eventContext, arguments.exception) />
		</cfloop>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="findPluginPoints" access="private" returntype="string" output="false"
		hint="Finds the registered plugin points in a plugin.">
		<cfargument name="plugin" type="MachII.framework.Plugin" required="true" />		
		<cfset var md = getMetaData(arguments.plugin) />
		<cfset var pointArray = arraynew(1) />
		<cfset var returnList = "" />
		<cfset var i = 0 />
				
		<!--- recursively search the plugin's parents for plugin points --->
		<cfset pointArray = gatherPluginMetaData(md,pointArray) />
		
		<!--- then pull function names defined in this plugin --->
		<cfloop index="i" from="1" to="#arraylen(md.functions)#">
			<cfset arrayAppend(pointArray, md.functions[i].name) />
		</cfloop>
		
		<!--- remove duplicates --->
		<cfloop index="i" from="1" to="#arraylen(pointArray)#">
			<cfif not listFindNoCase(returnList, pointArray[i])>
				<cfset returnList = listAppend(returnList, pointArray[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn returnList />	
	</cffunction>
	
	<cffunction name="gatherPluginMetaData" access="private" returntype="array" output="false"
		hint="Gathers meta data about a plugin.">
		<cfargument name="metadata" type="struct" required="true" />
		<cfargument name="points" type="array" required="true" />
		<cfset var i = 0 />

		<cfif structKeyExists(arguments.metadata, "extends") and arguments.metadata.extends.name neq "MachII.framework.Plugin">
			<cfloop index="i" from="1" to="#arraylen(arguments.metadata.extends.functions)#">
				<cfset arrayAppend(arguments.points, arguments.metadata.extends.functions[i].name) />
			</cfloop>
			<cfset gatherPluginMetaData(arguments.metadata.extends, arguments.points) />
		</cfif>
		
	    <cfreturn arguments.points />		
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Sets the AppManager instance this PluginManager belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Returns the AppManager instance this PluginManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="getPluginNames" access="public" returntype="array" output="false"
		hint="Returns an array of plugin names.">
		<cfreturn StructKeyArray(variables.plugins) />
	</cffunction>
	
</cfcomponent>