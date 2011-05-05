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
	displayname="ConfigListener"
	extends="MachII.framework.Listener"
	output="false"
	hint="Basic interface for base config actions.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getModuleData" access="public" returntype="struct" output="false"
		hint="Gets the data for all the modules.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var modules = getAppManager().getModuleManager().getModules(includeDisabled=true) />
		<cfset var moduleData = StructNew() />
		<cfset var dependencyInjectionEngineProperty = "" />
		<cfset var i = "" />
		<cfset var hasModuleErrors = false />

		<cfloop collection="#modules#" item="i">
			<cfset moduleData[modules[i].getModuleName()]["enabled"] = modules[i].isEnabled() />
			<cfset moduleData[modules[i].getModuleName()]["lazyload"] = modules[i].getLazyLoad() />
			<cfset moduleData[modules[i].getModuleName()]["loaded"] = modules[i].isLoaded() />
			<cfset moduleData[modules[i].getModuleName()]["loadException"] = modules[i].getLoadException() />
			<cfif isObject(moduleData[modules[i].getModuleName()]["loadException"])>
				<cfset hasModuleErrors = true />
			</cfif>

			<cfif modules[i].isEnabled() AND modules[i].isLoaded()>
				<cfset moduleData[modules[i].getModuleName()]["showInDashboard"]= true />
				<cfset moduleData[modules[i].getModuleName()]["lastReloadDateTime"] = modules[i].getModuleAppManager().getAppLoader().getLastReloadDatetime() />
				<cfset moduleData[modules[i].getModuleName()]["shouldReloadConfig"] = modules[i].getModuleAppManager().getAppLoader().shouldReloadConfig() />
				<cfset moduleData[modules[i].getModuleName()]["appManager"] = modules[i].getModuleAppManager() />
				<cfset dependencyInjectionEngineProperty = getProperty("udfs").findPropertyByType("MachII.properties.ColdspringProperty", modules[i].getModuleAppManager().getPropertyManager()) />
			<cfelse>
				<cfset moduleData[modules[i].getModuleName()]["showInDashboard"]= false />
			</cfif>

			<!--- Only grab this data if this module has a dependency injection engine property --->
			<cfif IsObject(dependencyInjectionEngineProperty)>
				<cfset moduleData[modules[i].getModuleName()]["lastDependencyInjectionEngineReloadDateTime"] = dependencyInjectionEngineProperty.getLastReloadDatetime() />
				<cfset moduleData[modules[i].getModuleName()]["shouldReloadDependencyInjectionEngineConfig"] = dependencyInjectionEngineProperty.shouldReloadConfig() />
			</cfif>
		</cfloop>

		<cfif hasModuleErrors>
			<cfset arguments.event.setArg("message",
					CreateObject("component", "MachII.dashboard.model.sys.Message").init("One or more modules contain a load error.", "exception")) />
		</cfif>
		<cfreturn moduleData />
	</cffunction>

	<cffunction name="getBaseData" access="public" returntype="struct" output="false"
		hint="Gets the data for the base app.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var baseData = StructNew() />
		<cfset var dependencyInjectionEngineProperty = "" />

		<cfset baseData["lastReloadDateTime"] = getAppManager().getParent().getAppLoader().getLastReloadDatetime() />
		<cfset baseData["shouldReloadConfig"] = getAppManager().getParent().getAppLoader().shouldReloadBaseConfig() />
		<cfset baseData["appManager"] = getAppManager().getParent() />
		<cfset baseData["enabled"] = true />
		<cfset baseData["loadException"] = "" />
		<cfset dependencyInjectionEngineProperty = getProperty("udfs").findPropertyByType("MachII.properties.ColdspringProperty", getAppManager().getParent().getPropertyManager()) />
		<cfif IsObject(dependencyInjectionEngineProperty)>
			<cfset baseData["lastDependencyInjectionEngineReloadDateTime"] = dependencyInjectionEngineProperty.getLastReloadDatetime() />
			<cfset baseData["shouldReloadDependencyInjectionEngineConfig"] = dependencyInjectionEngineProperty.shouldReloadConfig() />
		</cfif>

		<cfreturn baseData />
	</cffunction>

	<cffunction name="getBaseComponentData" access="public" returntype="struct" output="false"
		hint="Gets the component data for the base app.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfreturn getComponentDataByAppManager(getAppManager().getParent()) />
	</cffunction>

	<cffunction name="getModuleComponentData" access="public" returntype="struct" output="false"
		hint="Gets the component data for the base app.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var data = StructNew() />
		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var i = "" />

		<cfloop collection="#modules#" item="i">
			<cfif modules[i].isEnabled() AND modules[i].isLoaded()>
				<cfset data[modules[i].getModuleName()] = getComponentDataByAppManager(modules[i].getModuleAppManager()) />
			</cfif>
		</cfloop>

		<cfreturn data />
	</cffunction>

	<cffunction name="reloadModule" access="public" returntype="void" output="false"
		hint="Reloads a module.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var moduleName = arguments.event.getArg("moduleName", "") />
		<cfset var tickStart = 0 />
		<cfset var tickEnd = 0 />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />

		<cfif getAppManager().getModuleManager().isModuleDefined(moduleName)>
			<cftry>
				<cfset tickStart = getTickcount() />
				<cfset getAppManager().getModuleManager().getModule(moduleName, true).reloadModuleConfig() />
				<cfset tickEnd = getTickcount() />
				<cfset message.setMessage("Reloaded module '#moduleName#' in #NumberFormat(tickEnd - tickStart)#ms.") />
				<cfcatch type="any">
					<cfset message.setMessage("Exception occurred during the reload of module named '#moduleName#'.") />
					<cfset message.setType("exception") />
					<cfset message.setCaughtException(cfcatch) />
				</cfcatch>
			</cftry>

			<cfset arguments.event.setArg("message", message) />
			<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
		</cfif>
	</cffunction>

	<cffunction name="enableDisableModule" access="public" returntype="void" output="false"
		hint="Enables or disables a module.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var moduleName = arguments.event.getArg("moduleName", "") />
		<cfset var mode = arguments.event.getArg("mode", "enable") />
		<cfset var tickStart = 0 />
		<cfset var tickEnd = 0 />
		<cfset var moduleManager = "" />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />

		<cfif getAppManager().getModuleManager().isModuleDefined(moduleName)>
			<cftry>
				<cfset tickStart = getTickcount() />
				<cfset moduleManager = getAppManager().getModuleManager() />
				<cfif mode EQ "enable">
					<cfset moduleManager.enableModule(moduleName) />
				<cfelse>
					<cfset moduleManager.disableModule(moduleName) />
				</cfif>
				<cfset tickEnd = getTickcount() />
				<cfset message.setMessage("#mode#d module '#moduleName#' in #NumberFormat(tickEnd - tickStart)#ms.") />
				<cfcatch type="any">
					<cfset message.setMessage("Exception occurred attempting to #mode# module named '#moduleName#'.") />
					<cfset message.setType("exception") />
					<cfset message.setCaughtException(cfcatch) />
				</cfcatch>
			</cftry>

			<cfset arguments.event.setArg("message", message) />
			<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
		</cfif>
	</cffunction>

	<cffunction name="reloadBaseApp" access="public" returntype="void" output="false"
		hint="Reload the base app.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var tickStart = 0 />
		<cfset var tickEnd = 0 />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />
		<cfset var appKey = "" />

		<cftry>
			<cfset tickStart = getTickcount() />
			<cfset appKey = getAppManager().getParent().getAppLoader().getAppKey() />
			<cfset application[appKey].loading = true />
			<cfset getAppManager().getParent().getAppLoader().reloadConfig() />
			<cfset application[appKey].loading = false />
			<cfset tickEnd = getTickcount() />
			<cfset message.setMessage("Reloaded base application in #NumberFormat(tickEnd - tickStart)#ms.") />
			<cfcatch type="any">
				<cfset application[appKey].loading = false />
				<cfset message.setMessage("Exception occurred during the reload of the base application.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadAllChangedComponents" access="public" returntype="void" output="false"
		hints="Reloads all changed components.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var baseComponentData = getBaseComponentData(arguments.event) />
		<cfset var moduleComponentData = getModuleComponentData(arguments.event) />
		<cfset var manager = "" />
		<cfset var key = "" />
		<cfset var i = 0 />
		<cfset var temp = StructNew() />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
		<cfset var subMessageText = "" />
		<cfset var reloadedNamesText = "" />
		<cfset var type = "" />
		<cfset var name = "" />
		<cfset var module = "" />
		<cfset var count = 0 />
		<cfset var reloadedNames = "" />
		<cfset var tickStart = getTickCount() />
		<cfset var tickEnd = 0 />

		<!--- Reload base components --->
		<cftry>
			<cfloop from="1" to="#ArrayLen(baseComponentData.listeners)#" index="i">
				<cfif baseComponentData.listeners[i].shouldReloadObject>
					<cfset type = "listener" />
					<cfset name = baseComponentData.listeners[i].name />
					<cfset module = "" />
					<cfset count = count + 1 />
					<cfset reloadedNames = ListAppend(reloadedNames, name)>
					<cfset reloadListenerByModuleName(baseComponentData.listeners[i].name) />/
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(baseComponentData.filters)#" index="i">
				<cfif baseComponentData.filters[i].shouldReloadObject>
					<cfset type = "filter" />
					<cfset name = baseComponentData.filters[i].name />
					<cfset module = "" />
					<cfset count = count + 1 />
					<cfset reloadedNames = ListAppend(reloadedNames, name)>
					<cfset reloadFilterByModuleName(baseComponentData.filters[i].name) />
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(baseComponentData.plugins)#" index="i">
				<cfif baseComponentData.plugins[i].shouldReloadObject>
					<cfset type = "plugin" />
					<cfset name = baseComponentData.plugins[i].name />
					<cfset module = "" />
					<cfset reloadPluginByModuleName(baseComponentData.plugins[i].name) />
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(baseComponentData.properties)#" index="i">
				<cfif baseComponentData.properties[i].shouldReloadObject>
					<cfset type = "property" />
					<cfset name = baseComponentData.properties[i].name />
					<cfset module = "" />
					<cfset count = count + 1 />
					<cfset reloadedNames = ListAppend(reloadedNames, name)>
					<cfset reloadPropertyByModuleName(baseComponentData.properties[i].name) />
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(baseComponentData.endpoints)#" index="i">
				<cfif baseComponentData.endpoints[i].shouldReloadObject>
					<cfset type = "endpoint" />
					<cfset name = baseComponentData.endpoints[i].name />
					<cfset module = "" />
					<cfset count = count + 1 />
					<cfset reloadedNames = ListAppend(reloadedNames, name)>
					<cfset reloadEndpointByModuleName(baseComponentData.endpoints[i].name) />
				</cfif>
			</cfloop>

			<!--- Reload module components --->
			<cfloop collection="#moduleComponentData#" item="key">
				<cfloop from="1" to="#ArrayLen(moduleComponentData[key].listeners)#" index="i">
					<cfif moduleComponentData[key].listeners[i].shouldReloadObject>
						<cfset type = "listener" />
						<cfset name = moduleComponentData[key].listeners[i].name />
						<cfset module = key />
						<cfset count = count + 1 />
						<cfset reloadedNames = ListAppend(reloadedNames, name)>
						<cfset reloadListenerByModuleName(moduleComponentData[key].listeners[i].name, key) />
					</cfif>
				</cfloop>
				<cfloop from="1" to="#ArrayLen(moduleComponentData[key].filters)#" index="i">
					<cfif moduleComponentData[key].filters[i].shouldReloadObject>
						<cfset type = "filter" />
						<cfset name = moduleComponentData[key].filters[i].name />
						<cfset module = key />
						<cfset count = count + 1 />
						<cfset reloadedNames = ListAppend(reloadedNames, name)>
						<cfset reloadFilterByModuleName(moduleComponentData[key].filters[i].name, key) />
					</cfif>
				</cfloop>
				<cfloop from="1" to="#ArrayLen(moduleComponentData[key].plugins)#" index="i">
					<cfif moduleComponentData[key].plugins[i].shouldReloadObject>
						<cfset type = "plugin" />
						<cfset name = moduleComponentData[key].plugins[i].name />
						<cfset module = key />
						<cfset count = count + 1 />
						<cfset reloadedNames = ListAppend(reloadedNames, name)>
						<cfset reloadPluginByModuleName(moduleComponentData[key].plugins[i].name, key) />
					</cfif>
				</cfloop>
				<cfloop from="1" to="#ArrayLen(moduleComponentData[key].properties)#" index="i">
					<cfif moduleComponentData[key].properties[i].shouldReloadObject>
						<cfset type = "property" />
						<cfset name = moduleComponentData[key].properties[i].name />
						<cfset module = key />
						<cfset count = count + 1 />
						<cfset reloadedNames = ListAppend(reloadedNames, name)>
						<cfset reloadPropertyByModuleName(moduleComponentData[key].properties[i].name, key) />
					</cfif>
				</cfloop>
				<cfloop from="1" to="#ArrayLen(moduleComponentData[key].endpoints)#" index="i">
					<cfif moduleComponentData[key].endpoints[i].shouldReloadObject>
						<cfset type = "endpoint" />
						<cfset name = moduleComponentData[key].endpoints[i].name />
						<cfset module = "" />
						<cfset count = count + 1 />
						<cfset reloadedNames = ListAppend(reloadedNames, name)>
						<cfset reloadEndpointByModuleName(moduleComponentData[key].endpoints[i].name) />
					</cfif>
				</cfloop>
			</cfloop>

			<cfset tickEnd = getTickCount() />

			<cfif count GT 1>
				<cfset subMessageText = "components" />
			<cfelse>
				<cfset subMessageText = "component" />
			</cfif>
			<cfset reloadedNamesText = "<ul>" />
			<cfloop list="#reloadedNames#" index="i">
				<cfset reloadedNamesText = reloadedNamesText & "<li>" & i & "</li>" />
			</cfloop>
			<cfset reloadedNamesText = reloadedNamesText & "</ul>" />
			<cfset message.setMessage("<a href=""javascript:void(0)"" onclick=""$('messageDetails_#tickstart#').toggle();"">" & getProperty("html").addImage(BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/information.png")) & " Details</a> #TimeFormat(Now(), "medium")#: Reloaded #count# changed #subMessageText# in base and all modules in #NumberFormat(tickEnd - tickStart)#ms. <span id=""messageDetails_#tickstart#"" style=""display:none;""><br/>#reloadedNamesText#</span>") />

			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of #type# named '#name#' in module '#module#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfif count>
			<cfset arguments.event.setArg("message", message) />
			<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
		</cfif>
	</cffunction>

	<cffunction name="reloadAllOrmComponents" access="public" returntype="void" output="false"
		hints="Reloads all changed components.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var tickStart = 0 />
		<cfset var tickEnd = 0 />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />

		<cftry>
			<cfset tickStart = getTickCount() />
			<cfset OrmReload() />
			<cfset tickEnd = getTickCount() />
			<cfset message.setMessage("Reloaded all ORM Components in #NumberFormat(tickEnd - tickStart)#ms.") />

			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of the ORM.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadListener" access="public" returntype="void" output="false"
		hint="Reloads a listener.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var listenerName = arguments.event.getArg("listenerName") />
		<cfset var moduleName = arguments.event.getArg("moduleName", "") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded listener named '#listenerName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadListenerByModuleName(listenerName, moduleName) />
			<cfelse>
				<cfset reloadListenerByModuleName(listenerName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of listener named '#listenerName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadFilter" access="public" returntype="void" output="false"
		hint="Reloads a filter.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var filterName = arguments.event.getArg("filterName") />
		<cfset var moduleName = arguments.event.getArg("moduleName", "") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded event-filter named '#filterName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadFilterByModuleName(filterName, moduleName) />
			<cfelse>
				<cfset reloadFilterByModuleName(filterName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of event-filter named '#filterName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadPlugin" access="public" returntype="void" output="false"
		hint="Reloads a plugin.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var pluginName = arguments.event.getArg("pluginName") />
		<cfset var moduleName = arguments.event.getArg("moduleName") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded plugin named '#pluginName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadPluginByModuleName(pluginName, moduleName) />
			<cfelse>
				<cfset reloadPluginByModuleName(pluginName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of plugin named '#pluginName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadProperty" access="public" returntype="void" output="false"
		hint="Reloads a property.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var propertyName = arguments.event.getArg("propertyName") />
		<cfset var moduleName = arguments.event.getArg("moduleName") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded property named '#propertyName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadPropertyByModuleName(propertyName, moduleName) />
			<cfelse>
				<cfset reloadPropertyByModuleName(propertyName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of property named '#propertyName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadEndpoint" access="public" returntype="void" output="false"
		hint="Reloads an endpoint.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var endpointName = arguments.event.getArg("endpointName") />
		<cfset var moduleName = arguments.event.getArg("moduleName") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded endpoint named '#endpointName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadEndpointByModuleName(endpointName, moduleName) />
			<cfelse>
				<cfset reloadEndpointByModuleName(endpointName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of endpoint named '#endpointName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadViewLoader" access="public" returntype="void" output="false"
		hint="Reloads a view-loader.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var viewLoaderName = arguments.event.getArg("viewLoaderName") />
		<cfset var moduleName = arguments.event.getArg("moduleName") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Reloaded view-loader named '#viewLoaderName#' in module '#moduleName#'.", "success") />

		<cftry>
			<cfif Len(moduleName)>
				<cfset reloadViewLoaderByModuleName(viewLoaderName, moduleName) />
			<cfelse>
				<cfset reloadViewLoaderByModuleName(viewLoaderName) />
			</cfif>
			<cfcatch type="any">
				<cfset message.setMessage("Exception occurred during the reload of view-loader named '#viewLoaderName#' in module '#moduleName#'.") />
				<cfset message.setType("exception") />
				<cfset message.setCaughtException(cfcatch) />
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<cffunction name="reloadModuleDependencyInjectionEngine" access="public" returntype="void" output="false"
		hint="Reloads dependency injection engine in a module by module name.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var moduleName = arguments.event.getArg("moduleName", "") />
		<cfset var log = getLog() />
		<cfset var tickStart = 0 />
		<cfset var tickEnd = 0 />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />

		<cfif getAppManager().getModuleManager().isModuleDefined(moduleName)>
			<cftry>
				<cfset tickStart = getTickcount() />
				<cfset getProperty("udfs").findPropertyByType("MachII.properties.ColdspringProperty", getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getPropertyManager()).configure() />
				<cfset tickEnd = getTickcount() />
				<cfset message.setMessage("Reloaded dependency injection engine for module '#moduleName#' in #NumberFormat(tickEnd - tickStart)#ms.") />
				<cfcatch type="any">
					<cfset message.setMessage("Exception occurred during the reload of dependency injection engine in module '#moduleName#'.") />
					<cfset message.setType("exception") />
					<cfset message.setCaughtException(cfcatch) />
				</cfcatch>
			</cftry>

			<cfset arguments.event.setArg("message", message) />
			<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
		</cfif>
	</cffunction>

	<cffunction name="reloadBaseAppDependencyInjectionEngine" access="public" returntype="void" output="false"
		hint="Reloads dependency injection engine across the entire application.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var log = getLog() />
		<cfset var tickStart = getTickcount() />
		<cfset var tickEnd = 0 />
		<cfset var key = "" />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("", "success") />

		<cftry>
			<cfset getProperty("udfs").findPropertyByType("MachII.properties.ColdspringProperty", getAppManager().getParent().getPropertyManager()).configure() />

			<cfloop collection="#modules#" item="key">
				<!--- Don't reload the CS for the dashboard since it will just reload the base --->
				<cfif getAppManager().getModuleName() NEQ key>
					<cfset getProperty("udfs").findPropertyByType("MachII.properties.ColdspringProperty", modules[key].getModuleAppManager().getPropertyManager()).configure() />
				</cfif>
			</cfloop>

			<cfset tickEnd = getTickcount() />
			<cfset message.setMessage("Reloaded dependency injection engine in #tickEnd - tickStart#ms.") />

			<cfcatch type="any">
				<cfset message.setCaughtException(cfcatch) />
				<cfset message.setType("exception") />

				<cfif NOT Len(key)>
					<cfset message.setMessage("Exception occurred during the reload of dependency injection engine in base application.") />
				<cfelse>
					<cfset message.setMessage("Exception occurred during the reload of dependency injection engine in module '#key#'.") />
				</cfif>
			</cfcatch>
		</cftry>

		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().debug(message.getMessage(), message.getCaughtException()) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getComponentDataByAppManager" access="private" returntype="struct" output="false"
		hint="Gets the component data from the passed appManager.">
		<cfargument name="moduleAppManager" type="MachII.framework.AppManager" required="true" />

		<cfset var data = StructNew() />
		<cfset var objectNames = "" />
		<cfset var objectProxy = "" />
		<cfset var temp = StructNew() />
		<cfset var i = 0 />

		<!--- Listeners --->
		<cfset objectNames = moduleAppManager.getListenerManager().getListenerNames() />
		<cfset ArraySort(objectNames, "textnocase", "asc") />

		<cfset data.listeners = ArrayNew(1) />

		<cftry>
			<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">
				<cfset objectProxy = moduleAppManager.getListenerManager().getListener(objectNames[i]).getProxy() />
	
				<cfset temp = StructNew() />
	
				<cfset temp.name = objectNames[i] />
				<cfset temp.type = objectProxy.getType() />
				<cfset temp.shouldReloadObject = objectProxy.shouldReloadObject() />
	
				<cfset ArrayAppend(data.listeners, temp) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow type="MachII.dashboard.config.ListenerInfoNotAvailable"
					message="Unabled to obtain information for a listener named '#objectNames[i]#' in module '#arguments.moduleAppManager.getModuleName()#'. Please ensure that your listener extends ''MachII.framework.Listener'."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Plugins --->
		<cfset objectNames = moduleAppManager.getPluginManager().getPluginNames() />
		<cfset ArraySort(objectNames, "textnocase", "asc") />

		<cfset data.plugins = ArrayNew(1) />
		
		<cftry>
			<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">
				<cfset objectProxy = moduleAppManager.getPluginManager().getPlugin(objectNames[i]).getProxy() />
	
				<cfset temp = StructNew() />
	
				<cfset temp.name = objectNames[i] />
				<cfset temp.shouldReloadObject = objectProxy.shouldReloadObject() />
	
				<cfset ArrayAppend(data.plugins, temp) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow type="MachII.dashboard.config.PluginInfoNotAvailable"
					message="Unabled to obtain information for a property named '#objectNames[i]#' in module '#arguments.moduleAppManager.getModuleName()#'. Please ensure that your listener extends ''MachII.framework.Property'."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Filters --->
		<cfset objectNames = moduleAppManager.getFilterManager().getFilterNames() />
		<cfset ArraySort(objectNames, "textnocase", "asc") />

		<cfset data.filters = ArrayNew(1) />
		
		<cftry>
			<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">
				<cfset objectProxy = moduleAppManager.getFilterManager().getFilter(objectNames[i]).getProxy() />
	
				<cfset temp = StructNew() />
	
				<cfset temp.name = objectNames[i] />
				<cfset temp.shouldReloadObject = objectProxy.shouldReloadObject() />
	
				<cfset ArrayAppend(data.filters, temp) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow type="MachII.dashboard.config.EventFilterInfoNotAvailable"
					message="Unabled to obtain information for an event-filter named '#objectNames[i]#' in module '#arguments.moduleAppManager.getModuleName()#'. Please ensure that your listener extends ''MachII.framework.EventFilter'."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Configurable Properties --->
		<cfset objectNames = moduleAppManager.getPropertyManager().getConfigurablePropertyNames() />
		<cfset ArraySort(objectNames, "textnocase", "asc") />

		<cfset data.properties = ArrayNew(1) />

		<cftry>
			<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">
				<cfset objectProxy = moduleAppManager.getPropertyManager().getProperty(objectNames[i]).getProxy() />
	
				<cfset temp = StructNew() />
	
				<cfset temp.name = objectNames[i] />
				<cfset temp.shouldReloadObject = objectProxy.shouldReloadObject() />
	
				<cfset ArrayAppend(data.properties, temp) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow type="MachII.dashboard.config.PropertyInfoNotAvailable"
					message="Unabled to obtain information for a property named '#objectNames[i]#' in module '#arguments.moduleAppManager.getModuleName()#'. Please ensure that your listener extends ''MachII.framework.Listener'."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Endpoints --->
		<cfset objectNames = moduleAppManager.getEndpointManager().getLocalEndpointNames() />
		<cfset ArraySort(objectNames, "textnocase", "asc") />

		<cfset data.endpoints = ArrayNew(1) />

		<cftry>
			<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">
				<cfset objectProxy = moduleAppManager.getEndpointManager().getEndpointByName(objectNames[i]).getProxy() />
	
				<cfset temp = StructNew() />
	
				<cfset temp.name = objectNames[i] />
				<<cfset temp.shouldReloadObject = objectProxy.shouldReloadObject() /> --->
	
				<cfset ArrayAppend(data.endpoints, temp) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow type="MachII.dashboard.config.EndpointInfoNotAvailable"
					message="Unabled to obtain information for an endpoint named '#objectNames[i]#' in module '#arguments.moduleAppManager.getModuleName()#'."
					detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- View-Loaders --->
		<cfset objectNames = moduleAppManager.getViewManager().getViewLoaders() />

		<cfset data.viewLoaders = ArrayNew(1) />

		<cfloop from="1" to="#ArrayLen(objectNames)#" index="i">

			<cfset temp = StructNew() />

			<cfset temp.name = i />
			<cfset temp.shouldReloadObject = false />

			<cfset ArrayAppend(data.viewLoaders, temp) />
		</cfloop>

		<cfreturn data />
	</cffunction>

	<cffunction name="reloadListenerByModuleName" access="private" returntype="void" output="false"
		hint="Reloads a listener by module name.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var listenerManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset listenerManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getListenerManager() />
		<cfelse>
			<cfset listenerManager = getAppManager().getParent().getListenerManager() />
		</cfif>

		<cfset listenerManager.reloadListener(arguments.listenerName) />
	</cffunction>

	<cffunction name="reloadFilterByModuleName" access="private" returntype="void" output="false"
		hint="Reloads a filter by module name.">
		<cfargument name="filterName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var filterManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset filterManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getFilterManager() />
		<cfelse>
			<cfset filterManager = getAppManager().getParent().getFilterManager() />
		</cfif>

		<cfset filterManager.reloadFilter(arguments.filterName) />
	</cffunction>

	<cffunction name="reloadPluginByModuleName" access="private" returntype="void" output="false"
		hint="Reloads a plugin by module name.">
		<cfargument name="pluginName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var pluginManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset pluginManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getPluginManager() />
		<cfelse>
			<cfset pluginManager = getAppManager().getParent().getPluginManager() />
		</cfif>

		<cfset pluginManager.reloadPlugin(arguments.pluginName) />
	</cffunction>

	<cffunction name="reloadPropertyByModuleName" access="private" returntype="void" output="false"
		hint="Reloads a property by module name.">
		<cfargument name="propertyName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var propertyManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset propertyManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getPropertyManager() />
		<cfelse>
			<cfset propertyManager = getAppManager().getParent().getPropertyManager() />
		</cfif>

		<cfset propertyManager.reloadProperty(arguments.propertyName) />
	</cffunction>

	<cffunction name="reloadEndpointByModuleName" access="private" returntype="void" output="false"
		hint="Reloads an endpoint by module name.">
		<cfargument name="endpointName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var endpointManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset endpointManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getEndpointManager() />
		<cfelse>
			<cfset endpointManager = getAppManager().getParent().getEndpointManager() />
		</cfif>

		<cfset endpointManager.reloadEndpoint(arguments.endpointName) />
	</cffunction>

	<cffunction name="reloadViewLoaderByModuleName" access="private" returntype="void" output="false"
		hint="Reloads a view-loader by module name.">
		<cfargument name="viewLoaderName" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="false"
			hint="Not passing a module name indicates the 'base' application." />

		<cfset var viewManager = "" />

		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset viewManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getViewManager() />
		<cfelse>
			<cfset viewManager = getAppManager().getParent().getViewManager() />
		</cfif>

		<cfset viewManager.reloadViewLoader(arguments.viewLoaderName) />
	</cffunction>

</cfcomponent>