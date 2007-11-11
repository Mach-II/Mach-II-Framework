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
	<cfset variables.modules = StructNew() />
	<cfset variables.appManager = "" />
	<cfset variables.baseConfigFileDirectory = "" />
	<cfset variables.dtdPath = "" />
	<cfset variables.validateXml = "" />
	<cfset variables.baseName = "" />
	
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
	
	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager">
		<cfargument name="configXml" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var moduleNodes = "" />
		<cfset var modulesNode = "" />
		<cfset var modulesNodes = "" />
		<cfset var name = "" />
		<cfset var file = "" />
		<cfset var module = "" />
		<cfset var overrideXml = "" />
		<cfset var baseName = "" />
		<cfset var i = 0 />

		<!--- Set the module baseName if defined in the xml --->
		<cfif NOT arguments.override>
			<cfset modulesNode = XMLSearch(arguments.configXML, "mach-ii/modules") />
		<cfelse>
			<cfset modulesNode = XMLSearch(arguments.configXML, ".//modules") />
		</cfif>
		<cfif arrayLen(modulesNode) eq 1>
			<cfset modulesNode = modulesNode[1]>
			<cfif structKeyExists(modulesNode[1].xmlAttributes, "baseName")>
				<cfset baseName = modulesNode[1].xmlAttributes["baseName"] />
			</cfif>
			<cfset setBaseName(baseName) />
		</cfif>
		
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
		
			<!--- Setup the Module. --->
			<cfset module = CreateObject("component", "MachII.framework.Module").init(getAppManager(), name, file, overrideXml) />

			<!--- Add the Module to the Manager. --->
			<cfset addModule(name, module, arguments.override) />
		</cfloop>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered modules.">
		
		<cfset var key = "" />
		
		<cfloop collection="#variables.modules#" item="key">
			<cfset variables.modules[key].configure(getDtdPath(), getValidateXML()) />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getModule" access="public" returntype="MachII.framework.Module" output="false"
		hint="Gets a module with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		
		<cfif isModuleDefined(arguments.moduleName)>
			<cfreturn variables.modules[arguments.moduleName] />
		<cfelse>
			<cfthrow type="MachII.framework.ModuleNotDefined" 
				message="Module with name '#arguments.moduleName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="getModules" access="public" returntype="struct" output="false"
		hint="Returns a struct of all registered modules.">
		<cfreturn variables.modules />
	</cffunction>
	
	<cffunction name="addModule" access="public" returntype="void" output="false"
		hint="Registers a module with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="module" type="MachII.framework.Module" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.override AND isModuleDefined(arguments.moduleName)>
			<cfthrow type="MachII.framework.ModuleAlreadyDefined"
				message="A Module with name '#arguments.moduleName#' is already registered." />
		<cfelse>
			<cfset variables.modules[arguments.moduleName] = arguments.module />
		</cfif>
	</cffunction>
	
	<cffunction name="isModuleDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a module is registered with the specified name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.modules, arguments.moduleName) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getModuleNames" access="public" returntype="array" output="false"
		hint="Returns an array of module names.">
		<cfreturn StructKeyArray(variables.modules) />
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
	
	<cffunction name="setBaseName" access="public" returntype="void" output="false">
		<cfargument name="baseName" type="string" required="true" />
		<cfset variables.baseName = arguments.baseName />
	</cffunction>
	<cffunction name="getBaseName" access="public" returntype="string" output="false">
		<cfreturn variables.baseName />
	</cffunction>
	
	<cffunction name="setValidateXML" access="public" returntype="void" output="false">
		<cfargument name="validateXML" type="string" required="true" />
		<cfset variables.validateXML = arguments.validateXML />
	</cffunction>
	<cffunction name="getValidateXML" access="public" returntype="boolean" output="false">
		<cfreturn variables.validateXML />
	</cffunction>
	
</cfcomponent>