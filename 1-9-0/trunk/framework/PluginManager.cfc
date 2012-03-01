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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="PluginManager"
	output="false"
	hint="Manages registered Plugins for the framework instance.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.pluginProxies = StructNew() />
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
	<cfset variables.onSessionStartPlugins = ArrayNew(1) />
	<cfset variables.onSessionStartPluginsPosition = "" />
	<cfset variables.onSessionEndPlugins = ArrayNew(1) />
	<cfset variables.onSessionEndPluginsPosition = "" />
	<cfset variables.handleExceptionPlugins = ArrayNew(1) />
	<cfset variables.handleExceptionPluginsPosition = "" />
	<cfset variables.nPlugins = 0 />
	<cfset variables.parentPluginManager = "" />
	<cfset variables.pluginPointArray = ListToArray("preProcess,preEvent,postEvent,preView,postView,postProcess,onSessionStart,onSessionEnd,handleException") />
	<cfset variables.runParent = "" />
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	<cfset variables.baseProxyTarget = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PluginManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getPluginManager()) />
		</cfif>

		<!--- Setup for duplicate for performance --->
		<cfset variables.baseProxyTarget = CreateObject("component",  "MachII.framework.BaseProxy") />

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var pluginNodes = ArrayNew(1) />
		<cfset var pluginName = "" />
		<cfset var pluginType = "" />
		<cfset var pluginParams = StructNew() />
		<cfset var plugin = "" />

		<cfset var paramNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var hasParent = IsObject(getParent()) />
		<cfset var utils = getAppManager().getUtils() />
		<cfset var baseProxy = "" />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Set runParent attribute if this is a child PluginManager --->
		<cfif hasParent>
			<cfset pluginNodes = XMLSearch(arguments.configXML, ".//plugins") />
			<cfif ArrayLen(pluginNodes) gt 0 AND StructKeyExists(pluginNodes[1].xmlAttributes, "runParent")>
				<cfset setRunParent(pluginNodes[1].xmlAttributes["runParent"]) />
			<cfelseif NOT arguments.override AND NOT Len(getRunParent())>
				<!--- If no 'runParent' attribute set, use the default of 'after' --->
				<cfset setRunParent("after") />
			</cfif>
		</cfif>

		<!--- Scoped argument variable - configXML --->
		<cfif NOT arguments.override>
			<cfset pluginNodes = XMLSearch(arguments.configXML, "mach-ii/plugins/plugin") />
		<cfelse>
			<cfset pluginNodes = XMLSearch(arguments.configXML, ".//plugins/plugin") />
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(pluginNodes)#">
			<cfset pluginName = pluginNodes[i].XmlAttributes["name"] />

			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(pluginNodes[i].xmlAttributes, "overrideAction")>
				<!--- Check for a mapping --->
				<cfif StructKeyExists(pluginNodes[i].xmlAttributes, "mapping")>
					<cfset mapping = pluginNodes[i].xmlAttributes["mapping"] />
				<cfelse>
					<cfset mapping = pluginName />
				</cfif>

				<!--- Check if parent has event handler with the mapping name --->
				<cfif NOT getParent().isPluginDefined(mapping)>
					<cfthrow type="MachII.framework.overridePluginNotDefined"
						message="An plugin named '#mapping#' cannot be found in the parent plugin manager for the override named '#pluginName#' in module '#getAppManager().getModuleName()#'." />
				</cfif>

				<cfset addPlugin(pluginName, getParent().getPlugin(mapping), arguments.override) />
			<!--- General XML setup --->
			<cfelse>
				<!--- Set the Plugin's type and parameters. --->
				<cfset pluginType = pluginNodes[i].XmlAttributes["type"] />
				<cfset pluginParams = StructNew() />

				<!--- For each plugin, parse all the parameters --->
				<cfif StructKeyExists(pluginNodes[i], "parameters")>
					<cfset paramNodes = pluginNodes[i].parameters.xmlChildren />
					<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
						<cfset paramName = paramNodes[j].XmlAttributes["name"] />
						<cftry>
							<cfset paramValue = utils.recurseComplexValues(paramNodes[j]) />
							<cfcatch type="any">
								<cfthrow type="MachII.framework.InvalidParameterXml"
									message="Xml parsing error for the parameter named '#paramName#' for plugin '#pluginName#' in module '#getAppManager().getModuleName()#'." />
							</cfcatch>
						</cftry>
						<cfset pluginParams[paramName] = paramValue />
					</cfloop>
				</cfif>

				<cftry>
					<!--- Do not method chain the init() on the instantiation
						or objects that have their init() overridden will
						cause the variable the object is assigned to will
						be deleted if init() returns void --->
					<cfset plugin = CreateObject("component", pluginType) />
					<cfset plugin.init(getAppManager(), pluginParams) />

					<cfcatch type="any">
						<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ pluginType>
							<cfthrow type="MachII.framework.CannotFindPlugin"
								message="Cannot find a CFC with the type of '#pluginType#' for the plugin named '#pluginName#' in module named '#getAppManager().getModuleName()#'."
								detail="Please check that a plugin exists and that there is not a misconfiguration in the XML configuration file." />
						<cfelse>
							<cfthrow type="MachII.framework.PluginSyntaxException"
								message="Mach-II could not register a plugin with type of '#pluginType#' for the plugin named '#pluginName#' in module named '#getAppManager().getModuleName()#'."
								detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
						</cfif>
					</cfcatch>
				</cftry>

				<cfset baseProxy = Duplicate(variables.baseProxyTarget).init(plugin, pluginType, pluginParams) />
				<cfset plugin.setProxy(baseProxy) />

				<cfset addPlugin(pluginName, plugin, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered Plugins.">

		<cfset var appManager = getAppManager() />
		<cfset var aPlugin = 0 />
		<cfset var i = 0 />

		<cfloop from="1" to="#variables.nPlugins#" index="i">
			<cfset aPlugin = variables.pluginArray[i] />
			<cfset appManager.onObjectReload(aPlugin) />
			<cfset aPlugin.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Performs deconfiguration logic.">

		<cfset var aPlugin = 0 />
		<cfset var i = 0 />

		<cfloop from="1" to="#variables.nPlugins#" index="i">
			<cfset aPlugin = variables.pluginArray[i] />
			<cfset aPlugin.deconfigure() />
		</cfloop>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getPlugin" access="public" returntype="MachII.framework.Plugin" output="false"
		hint="Gets a plugin with the specified name.">
		<cfargument name="pluginName" type="string" required="true" />

		<cfif isPluginDefined(arguments.pluginName)>
			<cfreturn variables.pluginProxies[arguments.pluginName].getObject() />
		<cfelseif IsObject(getParent())>
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
			<cfset variables.pluginProxies[arguments.pluginName] = arguments.plugin.getProxy() />
			<cfset variables.pluginArray[variables.pluginArrayPosition[arguments.pluginName]] = arguments.plugin />

			<!--- re-add references to this plugin for each registered point --->
			<cfloop from="1" to="#ArrayLen(pluginRegisteredPoints)#" index="i">
				<cfset pointName = pluginRegisteredPoints[i] />
				<cfif StructKeyExists(variables, pointName & "Plugins")>
					<cfif ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)>
						<cfset variables[pointName & "Plugins"][ListFindNoCase(variables[pointName & "PluginsPosition"], arguments.pluginName)] = arguments.plugin />
					<cfelse>
						<cfif ArrayLen(variables[pointName & "Plugins"]) GTE variables.pluginArrayPosition[arguments.pluginName]>
							<cfset ArrayInsertAt(variables[pointName & "Plugins"], variables.pluginArrayPosition[arguments.pluginName], arguments.plugin) />
						<cfelse>
							<cfset ArrayAppend(variables[pointName & "Plugins"], arguments.plugin) />
						</cfif>
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
			<cfset variables.pluginProxies[arguments.pluginName] = arguments.plugin.getProxy() />

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
		hint="Returns true if a Plugin is registered with the specified name. Does NOT check parent.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.pluginProxies, arguments.pluginName) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getPluginNames" access="public" returntype="array" output="false"
		hint="Returns an array of plugin names.">
		<cfreturn StructKeyArray(variables.pluginProxies) />
	</cffunction>

	<cffunction name="reloadPlugin" access="public" returntype="void" output="false"
		hint="Reloads a plugin.">
		<cfargument name="pluginName" type="string" required="true" />

		<cfset var newPlugin = "" />
		<cfset var currentPlugin = getPlugin(arguments.PluginName) />
		<cfset var baseProxy = currentPlugin.getProxy() />

		<!--- Setup the Plugin --->
		<cftry>
			<!--- Do not method chain the init() on the instantiation
				or objects that have their init() overridden will
				cause the variable the object is assigned to will
				be deleted if init() returns void --->
			<cfset newPlugin = CreateObject("component", baseProxy.getType()) />
			<cfset newPlugin.init(getAppManager(), baseProxy.getOriginalParameters()) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ baseProxy.getType()>
					<cfthrow type="MachII.framework.CannotFindPlugin"
						message="Cannot find a CFC with the type of '#baseProxy.getType()#' for the plugin named '#arguments.pluginName#' in module named '#getAppManager().getModuleName()#'."
						detail="Please check that a plugin exists and that there is not a misconfiguration in the XML configuration file." />
				<cfelse>
					<cfthrow type="MachII.framework.PluginSyntaxException"
						message="Mach-II could not register a plugin with type of '#baseProxy.getType()#' for the plugin named '#arguments.pluginName#' in module named '#getAppManager().getModuleName()#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfif>
			</cfcatch>
		</cftry>

		<!--- Run deconfigure in the current Plugin
			which must take place before configure is
			run in the new Plugin --->
		<cfset currentPlugin.deconfigure() />

		<!--- Continue setup on the Plugin --->
		<cfset baseProxy.setObject(newPlugin) />
		<cfset newPlugin.setProxy(baseProxy) />

		<!--- Configure the Plugin --->
		<cfset getAppManager().onObjectReload(newPlugin) />
		<cfset newPlugin.configure() />

		<!--- Add the Plugin to the manager --->
		<cfset addPlugin(arguments.PluginName, newPlugin, true) />
	</cffunction>

	<!---
	PLUGIN POINT FUNCTIONS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="true"
		hint="preProcess() is called for each new EventContext once before event processing begins.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().preProcess(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.preProcessPlugins)#" index="i">
				<cfset log = variables.preProcessPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.preProcessPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running pre-process point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.preProcessPlugins[i].preProcess(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'preProcess' point in plugin '#variables.preProcessPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.preProcessPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().preProcess(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="preEvent" access="public" returntype="void" output="true"
		hint="preEvent() is called for each announced Event before it is handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().preEvent(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.preEventPlugins)#" index="i">
				<cfset log = variables.preEventPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.preEventPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running pre-event point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.preEventPlugins[i].preEvent(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'preEvent' point in plugin '#variables.preEventPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.preEventPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().preEvent(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="postEvent" access="public" returntype="void" output="true"
		hint="postEvent() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in. Call arguments.eventContext.getCurrentEvent() to access the Event." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().postEvent(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.postEventPlugins)#" index="i">
				<cfset log = variables.postEventPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.postEventPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running post-event point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.postEventPlugins[i].postEvent(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'postEvent' point in plugin '#variables.postEventPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.postEventPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().postEvent(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="preView" access="public" returntype="void" output="true"
		hint="preView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().preView(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.preViewPlugins)#" index="i">
				<cfset log = variables.preViewPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.preViewPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running pre-view point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.preViewPlugins[i].preView(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'preView' point in plugin '#variables.preViewPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.preViewPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().preView(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="postView" access="public" returntype="void" output="true"
		hint="postView() is called for each announced Event after it has been handled.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().postView(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.postViewPlugins)#" index="i">
				<cfset log = variables.postViewPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.postViewPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running post-view point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.postViewPlugins[i].postView(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'postView' point in plugin '#variables.postViewPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.postViewPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().postView(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="true"
		hint="postProcess() is called for each new EventContext once after event processing completes.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />

		<cfset var loggingName = "" />
		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().postProcess(arguments.eventContext) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.postProcessPlugins)#" index="i">
				<cfset log = variables.postProcessPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.postProcessPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running post-process point.") />

				<cfsetting enablecfoutputonly="false" /><cfset variables.postProcessPlugins[i].postProcess(arguments.eventContext) /><cfsetting enablecfoutputonly="true" />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'postProcess' point in plugin '#variables.postProcessPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.postProcessPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().postProcess(arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="onSessionStart" access="public" returntype="void" output="false"
		hint="onSessionStart() is called at the start of a session. All onSessionStart() points are invoked regardless of the module so no run parent is needed.">

		<cfset var log = "" />
		<cfset var i = 0 />

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.onSessionStartPlugins)#" index="i">
				<cfset log = variables.onSessionStartPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.onSessionStartPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running on-session-start point.") />

				<cfset variables.onSessionStartPlugins[i].onSessionStart() />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'onSessionStart' point in plugin '#variables.onSessionStartPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.onSessionStartPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="onSessionEnd() is called at the end of a session. All onSessionEnd() points are invoked regardless of the module so no run parent is needed.">
		<cfargument name="sessionScope" type="struct" required="true"
			hint="The session scope is passed in since direct access is not allowed during the on session end application event." />

		<cfset var log = "" />
		<cfset var i = 0 />

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.onSessionEndPlugins)#" index="i">
				<cfset log = variables.onSessionEndPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.onSessionEndPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running on-session-end point.") />

				<cfset variables.onSessionEndPlugins[i].onSessionEnd(arguments.sessionScope) />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'onSessionEnd' point in plugin '#variables.onSessionEndPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.onSessionEndPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="handleException() is called for each exception caught by the framework.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext under which the exception was thrown/caught." />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception object." />

		<cfset var loggingName = "" />
		<cfset var log = "" />
		<cfset var i = 0 />

		<!--- Usually it's best practice to use a getter like getRunParent() but we are direct accessing it for performance --->
		<cfif variables.runParent eq "before" AND IsObject(getParent())>
			<cfset getParent().handleException(arguments.eventContext, arguments.exception) />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.handleExceptionPlugins)#" index="i">
				<cfset log = variables.handleExceptionPlugins[i].getLog() />
				<cfset log.debug("Plugin '#variables.handleExceptionPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#' running handle-exception point.") />

				<cfset variables.handleExceptionPlugins[i].handleException(arguments.eventContext, arguments.exception) />
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occured in the 'handleException' point in plugin '#variables.handleExceptionPlugins[i].getComponentNameForLogging()#' in module '#getAppManager().getModuleName()#'. "
							& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getMetadata(variables.handleExceptionPlugins[i]).path)
							, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfif variables.runParent eq "after" AND IsObject(getParent())>
			<cfset getParent().handleException(arguments.eventContext, arguments.exception) />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="findPluginPoints" access="private" returntype="array" output="false"
		hint="Finds the registered plugin points in a plugin.">
		<cfargument name="plugin" type="MachII.framework.Plugin" required="true" />

		<cfset var md = variables.introspector.getFunctionDefinitions(arguments.plugin, "", true, "MachII.framework.Plugin") />
		<cfset var points = StructNew() />

		<!--- recursively search the plugin's parents for plugin points --->
		<cfset gatherPluginMetaData(md, points) />

		<cfreturn StructKeyArray(points) />
	</cffunction>

	<cffunction name="gatherPluginMetaData" access="private" returntype="void" output="false"
		hint="A recursive method that gathers meta data about a plugin.">
		<cfargument name="metadata" type="array" required="true" />
		<cfargument name="points" type="struct" required="true" />

		<cfset var currentLevel = arguments.metadata[1] />
		<cfset var i = 0 />

		<cfif StructKeyExists(currentLevel, "functions")>
			<cfloop from="1" to="#ArrayLen(currentLevel.functions)#" index="i">
				<cfset StructInsert(arguments.points, currentLevel.functions[i].name, 1, true) />
			</cfloop>
		</cfif>

		<cfif ArrayLen(arguments.metadata) GT 1>
			<cfset ArrayDeleteAt(arguments.metadata, 1) />
			<cfset gatherPluginMetaData(arguments.metadata, arguments.points) />
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