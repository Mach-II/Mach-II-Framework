<!---
License:
Copyright 2007 Mach-II Corporation

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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0
--->
<cfcomponent
	displayname="Module"
	output="false"
	hint="Module">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.moduleName = "" />
	<cfset variables.file = "" />
	<cfset variables.moduleAppManager = "" />
	<cfset variables.appManager = "" />
	<cfset variables.appLoader = "" />
	<cfset variables.dtdPath = "" />
	<cfset variables.overrideXml = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Module" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="overrideXml" type="any" required="true" />
		
		<cfset setFile(arguments.file) />
		<cfset setModuleName(arguments.moduleName) />
		<cfset setAppManager(arguments.appManager) />
		<cfset setOverrideXml(arguments.overrideXml) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfargument name="configDtdPath" type="string" required="true"
		 	hint="The full path to the configuration DTD file." />
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />

		<cfset var appLoader = CreateObject("component", "MachII.framework.AppLoader").init(
				expandPath(getFile()), arguments.configDtdPath, getAppManager().getAppKey(), arguments.validateXML, getAppManager(), getOverrideXml(), getModuleName()) />
		<cfset var moduleAppManager = appLoader.getAppManager() />

		<cfset setDtdPath(arguments.configDtdPath) />
		<cfset moduleAppManager.setAppLoader(appLoader) />
		<cfset setModuleAppManager(moduleAppManager) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false">
		<cfreturn getModuleAppManager().getAppLoader().shouldReloadConfig() />
	</cffunction>
		
	<cffunction name="reloadModuleConfig" access="public" returntype="void" output="false">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfset var appLoader = CreateObject("component", "MachII.framework.AppLoader").init(
				expandPath(getFile()), getDtdPath(), getAppManager().getAppKey(), arguments.validateXML, getAppManager(), getOverrideXml(), getModuleName()) />
		<cfset var moduleAppManager = appLoader.getAppManager() />

		<cfset moduleAppManager.setAppLoader(appLoader) />
		<cfset setModuleAppManager(moduleAppManager) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setFile" access="public" returntype="void" output="false"
		hint="Sets the path to the module Mach II config file">
		<cfargument name="file" type="string" required="true" />
		<cfset variables.file = arguments.file />
	</cffunction>
	<cffunction name="getFile" access="public" type="string" output="false"
		hint="Gets the file to use when setting up the module's AppManager">
		<cfreturn variables.file />
	</cffunction>
	
	<cffunction name="setDtdPath" access="public" returntype="void" output="false">
		<cfargument name="dtdPath" type="string" required="true" />
		<cfset variables.dtdPath = arguments.dtdPath />
	</cffunction>
	<cffunction name="getDtdPath" access="public" type="string" output="false">
		<cfreturn variables.dtdPath />
	</cffunction>
	
	<cffunction name="setModuleName" access="public" returntype="void" output="false"
		hint="Sets the name of the module">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="public" type="string" output="false"
		hint="Gets the module name">
		<cfreturn variables.moduleName />
	</cffunction>
	
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this Module belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the AppManager instance this ModuleManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setModuleAppManager" access="public" returntype="void" output="false"
		hint="Returns the ModuLeAppManager instance this ModuleManager belongs to.">
		<cfargument name="moduleAppManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.moduleAppManager = arguments.moduleAppManager />
	</cffunction>
	<cffunction name="getModuleAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the ModuLeAppManager instance this ModuleManager belongs to.">
		<cfreturn variables.moduleAppManager />
	</cffunction>
	
	<cffunction name="setOverrideXml" access="public" returntype="void" output="false"
		hint="Sets the override Xml for this module.">
		<cfargument name="overrideXml" type="any" required="true" />
		<cfset variables.overrideXml = arguments.overrideXml />
	</cffunction>
	<cffunction name="getOverrideXml" access="public" type="any" output="false"
		hint="Gets the override Xml for this module.">
		<cfreturn variables.overrideXml />
	</cffunction>

</cfcomponent>