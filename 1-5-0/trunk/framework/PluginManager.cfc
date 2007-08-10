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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
- Added introspection to call only defined plugin points. (dross, pfarrell, hklein)
- Fixed metadata introspection bug with components that have no fuctions (pfarrell)
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
	<cfset variables.pluginArrayPosition = StructNew() />
	<cfset variables.preProcessPlugins = ArrayNew(1) />
	<cfset variables.preProcessPluginsPosition = "" />
	<cfset variables.preEventPlugins = ArrayNew(1) />
	<cfset variables.preEventPluginsPosition = "" />
	<cfset variables.postEventPlugins = ArrayNew(1) />
	<cfset variables.postEventPluginsPosition = "" />
	<cfset variables.preViewPlugins = ArrayNew(1) />
	<cfset variables.preViewPluginsPosition = "" />
	<cfset variables.postViewPlugins = ArrayNew(1) />
	<cfset variables.postViewPluginsPosition = "" />
	<cfset variables.postProcessPlugins = ArrayNew(1) />
	<cfset variables.postProcessPluginsPosition = "" />
	<cfset variables.handleExceptionPlugins = ArrayNew(1) />
	<cfset variables.handleExceptionPluginsPosition = "" />
	<cfset variables.nPlugins = 0 />
	<cfset variables.parentPluginManager = "" />
	<cfset variables.utils = "" />
	<cfset variables.pluginPointArray = ListToArray("preProcess,preEvent,postEvent,preView,postView,postProcess,handleException") />
	<cfset variables.runParent = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PluginManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentPluginManager" type="any" required="false" default=""
			hint="Optional argument for a parent plugin manager. If there isn't one default to empty string." />

		<cfset setAppManager(arguments.appManager) />
		<cfset variables.utils = getAppManager().getUtils() />

		<cfif isObject(arguments.parentPluginManager)>
			<cfset setParent(arguments.parentPluginManager) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var pluginNodes = 0 />
		<cfset var paramNodes = 0 />
		<cfset var paramName = 0 />
		<cfset var paramValue = 0 />
		<cfset var plugin = 0 />
		<cfset var pluginName = 0 />
		<cfset var pluginType = 0 />
		<cfset var pluginParams = 0 />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Scoped argument variable - configXML --->
		<cfif NOT arguments.override>
			<cfset pluginNodes = XMLSearch(arguments.configXML, "mach-ii/plugins/plugin") />
		<cfelse>
			<cfset pluginNodes = XMLSearch(arguments.configXML, ".//plugins") />
			<cfif arrayLen(pluginNodes) gt 0 AND structKeyExists(pluginNodes[1].xmlAttributes, "runParent")>
				<cfset setRunParent(pluginNodes[1].xmlAttributes["runParent"]) />
			</cfif>
			<cfset pluginNodes = XMLSearch(arguments.configXML, ".//plugins/plugin") />
		</cfif>
		<cfloop index="i" from="1" to="#ArrayLen(pluginNodes)#">
			<cfset pluginName = pluginNodes[i].XmlAttributes["name"] />
			<cfset pluginType = pluginNodes[i].XmlAttributes["type"] />

			<!--- Set the Plugin's parameters. --->
			<cfset pluginParams = StructNew() />

			<!--- For each plugin, parse all the parameters --->
			<cfif StructKeyExists(pluginNodes[i], "parameters")>
				<cfset paramNodes = pluginNodes[i].parameters.xmlChildren />
				<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
					<cfset paramName = paramNodes[j].XmlAttributes["name"] />
					<cftry>
						<cfset paramValue = variables.utils.recurseComplexValues(paramNodes[j]) />
						<cfcatch type="any">
							<cfthrow type="MachII.framework.InvalidParameterXml"
								message="Xml parsing error for the parameter named '#paramName#' for plugin '#pluginName#' in module '#getAppManager().getModuleName()#'." />
						</cfcatch>
					</cftry>
					<cfset pluginParams[paramName] = paramValue />
				</cfloop>
			</cfif>

			<cfset plugin = CreateObject("component", pluginType).init(getAppManager(), pluginParams) />
			<cfset addPlugin(pluginName, plugin, arguments.override) />
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered Plugins.">
		<cfset var aPlugin = 0 />
		<cfset var i = 0 />

		<cfloop from="1" to="#variables.nPlugins#" index="i">
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
		<cfelseif isObject(getParent()) AND getParent().isPluginDefined(arguments.pluginName)>
			<cfreturn getParent().getPlugin(arguments.pluginName) />
		<cfelse>
			<cfthrow type="MachII.framework.PluginNotDefined"
				message="Plugin with name '#arguments.pluginName#' is not defined." />
		</cfif>
	</cffunction>

	<cffunction name="addPlugin" access="public" returntype="void" output="false"
		hint="Registers a plugin with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfargument name="plugin" type="MachII.framework.Plugin" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var i = 0 />
		<cfset var pointName = 0 />
		<cfset var temp = "" />
		<cfset var pluginRegisteredPoints = findPluginPoints(arguments.plugin) />

		<cfif NOT arguments.override AND isPluginDefined(arguments.pluginName)>
			<cfthrow type="MachII.framework.PluginAlreadyDefined"
				message="A Plugin with name '#arguments.pluginName#' is already registered." />
		<cfelseif arguments.override AND isPluginDefined(arguments.pluginName)>
			<cfset variables.plugins[arguments.pluginName] = arguments.plugin />
			<cfset variables.pluginArray[variables.pluginArrayPosition[arguments.pluginName]] = arguments.plugin />

			<!--- re-add references to this plugin for each registered point --->
			<cfloop from="1" to="#ArrayLen(pluginRegisteredPoints)#" index="i">
				<cfset pointName = pluginRegisteredPoints[i] />
				<cfif StructKeyExists(variables, pointName & "Plugins")>
					<cfif ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)>
						<cfset variables[pointName & "Plugins"][ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)] = arguments.plugin />
					<cfelse>
						<cfset ArrayInsertAt(variables[pointName & "Plugins"], variables.pluginArrayPosition[arguments.pluginName], arguments.plugin) />
						<cfif ListLen(variables[pointName & "PluginsPosition"]) GT 1>
							<cfset variables[pointName & "PluginsPosition"] = ListInsertAt(variables[pointName & "PluginsPosition"], variables.pluginArrayPosition[arguments.pluginName], arguments.pluginName) />
						<cfelse>
							<cfset variables[pointName & "PluginsPosition"] = ListAppend(variables[pointName & "PluginsPosition"], variables.pluginArrayPosition[arguments.pluginName]) />
						</cfif>
					</cfif>
					<cfset temp = ListAppend(temp, pointName) />
				</cfif>
			</cfloop>

			<!--- delete any references from the old plugin for each registered point not in new plugin --->
			<cfloop from="1" to="#ArrayLen(variables.pluginPointArray)#" index="i">
				<cfset pointName = variables.pluginPointArray[i] />
				<cfif ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName) AND NOT ListFindNoCase(temp, pointName)>
					<cfset ArrayDeleteAt(variables[pointName & "Plugins"], ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)) />
					<cfset ListDeleteAt(variables[pointName & "PluginsPosition"], ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset variables.plugins[arguments.pluginName] = arguments.plugin />

			<cfset variables.nPlugins = variables.nPlugins + 1 />
			<cfset variables.pluginArray[variables.nPlugins] = arguments.plugin />
			<cfset variables.pluginArrayPosition[arguments.pluginName] = variables.nPlugins />

			<!--- add references to this plugin for each registered point --->
			<cfloop from="1" to="#ArrayLen(pluginRegisteredPoints)#" index="i">
				<cfset pointName = pluginRegisteredPoints[i] />
				<cfif StructKeyExists(variables, pointName & "Plugins")>
					<cfset ArrayAppend(variables[pointName & "Plugins"], arguments.plugin) />
					<cfset variables[pointName & "PluginsPosition"] = ListAppend(variables[pointName & "PluginsPosition"], arguments.pluginName) />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="isPluginDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a Plugin is registered with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.plugins, arguments.pluginName) />
	</cffunction>

	<cffunction name="getPluginNames" access="public" returntype="array" output="false"
		hint="Returns an array of plugin names.">
		<cfreturn StructKeyArray(variables.plugins) />
	</cffunction>

	<!---
	PLUGIN POINT FUNCTIONS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="true"
		hint="preProcess() is called for each new EventContext once before event processing begins.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().preProcess(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.preProcessPlugins)#" index="i">
			<cfset variables.preProcessPlugins[i].preProcess(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().preProcess(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="preEvent" access="public" returntype="void" output="true"
		hint="preEvent() is called for each announced Event before it is handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().preEvent(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.preEventPlugins)#" index="i">
			<cfset variables.preEventPlugins[i].preEvent(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().preEvent(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="postEvent" access="public" returntype="void" output="true"
		hint="postEvent() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().postEvent(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.postEventPlugins)#" index="i">
			<cfset variables.postEventPlugins[i].postEvent(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().postEvent(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="preView" access="public" returntype="void" output="true"
		hint="preView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().preView(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.preViewPlugins)#" index="i">
			<cfset variables.preViewPlugins[i].preView(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().preView(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="postView" access="public" returntype="void" output="true"
		hint="postView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().postView(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.postViewPlugins)#" index="i">
			<cfset variables.postViewPlugins[i].postView(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().postView(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="true"
		hint="postProcess() is called for each new EventContext once after event processing completes.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().postProcess(arguments.eventContext) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.postProcessPlugins)#" index="i">
			<cfset variables.postProcessPlugins[i].postProcess(arguments.eventContext) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().postProcess(arguments.eventContext) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="handleException() is called for each exception caught by the framework.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext under which the exception was thrown/caught." />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception object." />

		<cfset var i = 0 />

		<cfif getRunParent() eq "before">
			<cfif isObject(getParent())>
				<cfset getParent().handleException(arguments.eventContext, arguments.exception) />
			</cfif>
		</cfif>

		<cfloop from="1" to="#ArrayLen(variables.handleExceptionPlugins)#" index="i">
			<cfset variables.handleExceptionPlugins[i].handleException(arguments.eventContext, arguments.exception) />
		</cfloop>

		<cfif getRunParent() eq "after" OR getRunParent() eq "">
			<cfif isObject(getParent())>
				<cfset getParent().handleException(arguments.eventContext, arguments.exception) />
			</cfif>
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="findPluginPoints" access="private" returntype="array" output="false"
		hint="Finds the registered plugin points in a plugin.">
		<cfargument name="plugin" type="MachII.framework.Plugin" required="true" />

		<cfset var md = GetMetaData(arguments.plugin) />
		<cfset var points = StructNew() />

		<!--- recursively search the plugin's parents for plugin points --->
		<cfset gatherPluginMetaData(md, points) />

		<cfreturn StructKeyArray(points) />
	</cffunction>

	<cffunction name="gatherPluginMetaData" access="private" returntype="void" output="false"
		hint="Gathers meta data about a plugin.">
		<cfargument name="metadata" type="struct" required="true" />
		<cfargument name="points" type="struct" required="true" />

		<cfset var i = 0 />

		<cfif StructKeyExists(arguments.metadata, "functions")>
			<cfloop from="1" to="#ArrayLen(arguments.metadata.functions)#" index="i">
				<cfset StructInsert(arguments.points, arguments.metadata.functions[i].name, 1, true) />
			</cfloop>
		</cfif>

		<cfif StructKeyExists(arguments.metadata, "extends") and arguments.metadata.extends.name neq "MachII.framework.Plugin">
			<cfset gatherPluginMetaData(arguments.metadata.extends, arguments.points) />
		</cfif>
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
	
	<cffunction name="setRunParent" access="public" returntype="void" output="false">
		<cfargument name="runParent" type="string" required="true" />
		<cfset variables.runParent = arguments.runParent />
	</cffunction>
	<cffunction name="getRunParent" access="public" returntype="string" output="false">
		<cfreturn variables.runParent />
	</cffunction>

	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent PluginManager instance this PluginManager belongs to.">
		<cfargument name="parentPluginManager" type="MachII.framework.PluginManager" required="true" />
		<cfset variables.parentPluginManager = arguments.parentPluginManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent PluginManager instance this PluginManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentPluginManager />
	</cffunction>

</cfcomponent>