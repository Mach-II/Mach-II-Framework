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

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent
	displayname="ModuleManager"
	output="false"
	hint="Manages registered modules for the framework instance.">

	<!---
	PROPERTIES
	--->
	<cfset variables.enabledModules = StructNew() />
	<cfset variables.disabledModules = StructNew() />
	<cfset variables.appManager = "" />
	<cfset variables.baseConfigFileDirectory = "" />
	<cfset variables.dtdPath = "" />
	<cfset variables.validateXml = "" />
	<cfset variables.baseName = "" />
	<cfset variables.xml = ArrayNew(1) />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ModuleManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="baseConfigFileDirectory" type="string" required="true"
			hint="The directory of the base config file. Required for relative path support resolution." />
		<cfargument name="configDtdPath" type="string" required="true"
		 	hint="The full path to the configuration DTD file." />
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />

		<cfset setAppManager(arguments.appManager) />
		<cfset setBaseConfigFileDirectory(arguments.baseConfigFileDirectory) />
		<cfset setDtdPath(arguments.configDtdPath) />
		<cfset setValidateXml(arguments.validateXml) />

		<cfreturn this />
	</cffunction>

	<cffunction name="registerXml" access="public" returntype="void" output="false"
		hint="Registers xml for the manager.">
		<cfargument name="configXml" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset ArrayAppend(variables.xml, arguments) />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXml" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var moduleNodes = ArrayNew(1) />
		<cfset var modulesNode = "" />
		<cfset var modulesNodes = "" />
		<cfset var module = "" />

		<cfset var name = "" />
		<cfset var file = "" />
		<cfset var overrideXml = "" />
		<cfset var i = 0 />
		<cfset var lazyLoad = "" />

		<!--- Setup up each Module. --->
		<cfif NOT arguments.override>
			<cfset moduleNodes = XMLSearch(arguments.configXML, "mach-ii/modules/module") />
		<cfelse>
			<cfset moduleNodes = XMLSearch(arguments.configXML, ".//modules/module") />
		</cfif>
		<cfloop from="1" to="#ArrayLen(moduleNodes)#" index="i">
			<cfset name = moduleNodes[i].xmlAttributes["name"] />
			<cfset file = moduleNodes[i].xmlAttributes["file"] />

			<!--- Resolve the file path --->
			<cfif Left(file, 1) IS ".">
				<cfset file = getAppManager().getUtils().expandRelativePath(getBaseConfigFileDirectory(), file) />
			<cfelse>
				<cfset file = ExpandPath(file) />
			</cfif>

			<cfif StructKeyExists(moduleNodes[i], "mach-ii")>
				<cfset overrideXml = moduleNodes[i]["mach-ii"] />
			<cfelse>
				<cfset overrideXml = "" />
			</cfif>

			<cftry>
				<!--- Setup the Module. --->
				<cfset module = CreateObject("component", "MachII.framework.Module") />
				<cfset module.init(getAppManager(), name, file, overrideXml) />

				<cfset lazyLoad = getAppManager().getPropertyManager().getProperty("modules:lazyLoad", "!*") />
				<cfif lazyLoad EQ "*" OR ListFindNoCase(lazyLoad, name) >
			 		<cfset getAppManager().getLogFactory().getLog("MachII.framework.ModuleManager").debug("Configuring module: '#name#' to lazy load") />
					<cfset module.setLazyLoad(true) />
				</cfif>

				<cfif ListFindNoCase(getAppManager().getPropertyManager().getProperty("modules:disable", ""), name) >
					<cfset module.setEnabled(false) />
				</cfif>

				<!--- Add the Module to the Manager. --->
				<cfset addModule(name, module, arguments.override) />

				<cfcatch type="any">
					<cfif getAppManager().getPropertyManager().getProperty("modules:disableOnFailure", false) >
						<cfset module.setLoadException(CreateObject("component", "MachII.util.Exception").wrapException(cfcatch)) />
						<cfset module.setEnabled(false) />
						<cfset addModule(name, module, arguments.override) />
					<cfelse>
						<cfrethrow />
					</cfif>
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered modules.">

		<cfset var i = 0 />
		<cfset var key = "" />

		<!--- Load all registered xml --->
		<cfloop from="1" to="#ArrayLen(variables.xml)#" index="i">
			<cfset loadXml(argumentcollection=variables.xml[i]) />
		</cfloop>

		<cfloop collection="#variables.enabledModules#" item="key">
			<cftry>
				<cfset variables.enabledModules[key].configure(getDtdPath(), getValidateXML()) />
				<cfcatch type="any">
					<cfif getAppManager().getPropertyManager().getProperty("modules:disableOnFailure", false) >
						<cfset variables.enabledModules[key].setLoadException(CreateObject("component", "MachII.util.Exception").wrapException(cfcatch)) />
						<cfset disableModule(key) />
					<cfelse>
						<cfrethrow />
					</cfif>
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Preforms deconfiguration logic in each of the registered modules.">

		<cfset var key = "" />

		<cfloop collection="#variables.enabledModules#" item="key">
			<cfset variables.enabledModules[key].getModuleAppManager().deconfigure() />
		</cfloop>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getModule" access="public" returntype="MachII.framework.Module" output="false"
		hint="Gets a module with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="includeDisabled" type="boolean" required="false" default="false" />

		<cfif isModuleDefined(arguments.moduleName)>
			<cfif isModuleEnabled(arguments.moduleName)>
				<cfreturn variables.enabledModules[arguments.moduleName] />
			<cfelseif arguments.includeDisabled>
				<cfreturn variables.disabledModules[arguments.moduleName] />
			<cfelse>
				<cfif variables.disabledModules[arguments.moduleName].hasException()>
					<cfthrow type="MachII.framework.ModuleFailedToLoad"
						message="Module with name '#arguments.moduleName#' failed to load."
						extendedInfo="#variables.disabledModules[arguments.moduleName].getLoadException().getMessage()#" />
				<cfelse>
					<cfthrow type="MachII.framework.ModuleDisabled"
						message="Module with name '#arguments.moduleName#' is disabled." />
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow type="MachII.framework.ModuleNotDefined"
				message="Module with name '#arguments.moduleName#' is not defined." />
		</cfif>
	</cffunction>

	<cffunction name="getModules" access="public" returntype="struct" output="false"
		hint="Returns a struct of all enabled registered modules.">
		<cfargument name="includeDisabled" type="boolean" required="false" default="false" />

		<cfset var tempStruct = "" />

		<cfif NOT arguments.includeDisabled>
			<cfreturn variables.enabledModules />
		<cfelse>
			<cfset tempStruct = StructCopy(variables.enabledModules) />
			<cfset StructAppend(tempStruct, variables.disabledModules) />
			<cfreturn tempStruct />
		</cfif>
	</cffunction>

	<cffunction name="getDisabledModules" access="public" returntype="struct" output="false"
		hint="Returns a struct of all enabled registered modules.">
		<cfreturn variables.disabledModules />
	</cffunction>

	<cffunction name="addModule" access="public" returntype="void" output="false"
		hint="Registers a module with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="module" type="MachII.framework.Module" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfif NOT arguments.override AND isModuleDefined(arguments.moduleName)>
			<cfthrow type="MachII.framework.ModuleAlreadyDefined"
				message="A Module with name '#arguments.moduleName#' is already registered." />
		<cfelseif arguments.module.isEnabled()>
	 		<cfset getAppManager().getLogFactory().getLog("MachII.framework.ModuleManager").debug("Adding enabled module: '#arguments.moduleName#'") />
			<cfset variables.enabledModules[arguments.moduleName] = arguments.module />
		<cfelse>
	 		<cfset getAppManager().getLogFactory().getLog("MachII.framework.ModuleManager").debug("Adding disabled module: '#arguments.moduleName#'") />
			<cfset variables.disabledModules[arguments.moduleName] = arguments.module />
		</cfif>
	</cffunction>

	<cffunction name="isModuleDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a module is registered with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.enabledModules, arguments.moduleName)
					OR StructKeyExists(variables.disabledModules, arguments.moduleName) />
	</cffunction>

	<cffunction name="isModuleEnabled" access="public" returntype="boolean" output="false"
		hint="Returns true if a module is enabled with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.enabledModules, arguments.moduleName) />
	</cffunction>

	<cffunction name="disableModule" access="public" returntype="void" output="false"
		hint="Disables a module.">
		<cfargument name="moduleName" type="string" required="true" />

		<cfif isModuleEnabled(arguments.moduleName)>
			<cfset variables.disabledModules[arguments.moduleName] = variables.enabledModules[arguments.moduleName] />
			<cfset variables.disabledModules[arguments.moduleName].setEnabled(false) />
			<cfset StructDelete(variables.enabledModules, arguments.moduleName) />
		</cfif>
	</cffunction>

	<cffunction name="enableModule" access="public" returntype="void" output="false"
		hint="Enables a module.">
		<cfargument name="moduleName" type="string" required="true" />

		<cfif NOT isModuleEnabled(arguments.moduleName)>
			<cfset variables.enabledModules[arguments.moduleName] = variables.disabledModules[arguments.moduleName] />
			<cfset variables.enabledModules[arguments.moduleName].setEnabled(true) />
			<cfset StructDelete(variables.disabledModules, arguments.moduleName) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getModuleNames" access="public" returntype="array" output="false"
		hint="Returns an array of module names.">
		<cfreturn StructKeyArray(variables.enabledModules) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this ModuleManager belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the AppManager instance this ModuleManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setBaseConfigFileDirectory" access="public" returntype="void" output="false">
		<cfargument name="baseConfigFileDirectory" type="string" required="true" />
		<cfset variables.baseConfigFileDirectory = arguments.baseConfigFileDirectory />
	</cffunction>
	<cffunction name="getBaseConfigFileDirectory" access="public" returntype="string" output="false">
		<cfreturn variables.baseConfigFileDirectory />
	</cffunction>

	<cffunction name="setDtdPath" access="public" returntype="void" output="false">
		<cfargument name="dtdPath" type="string" required="true" />
		<cfset variables.dtdPath = arguments.dtdPath />
	</cffunction>
	<cffunction name="getDtdPath" access="public" returntype="string" output="false">
		<cfreturn variables.dtdPath />
	</cffunction>

	<cffunction name="setValidateXML" access="public" returntype="void" output="false">
		<cfargument name="validateXML" type="string" required="true" />
		<cfset variables.validateXML = arguments.validateXML />
	</cffunction>
	<cffunction name="getValidateXML" access="public" returntype="boolean" output="false">
		<cfreturn variables.validateXML />
	</cffunction>

</cfcomponent>