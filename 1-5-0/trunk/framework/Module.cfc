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
	<cfset variables.file = "" />
	<cfset variables.moduleAppManager = "" />
	<cfset variables.appManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Module" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset setFile(arguments.file)>
		<cfset setAppManager(arguments.appManager)>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false">
		<!--- TODO: Figure out how to get to the validation and DTD attributes from here --->
		<cfset var appLoader = CreateObject("component", "MachII.framework.AppLoader").init(
				expandPath(getFile()), "", 0, getAppManager()) />
		<cfset var moduleAppManager = appLoader.getAppManager() />
		<cfset setModuleAppManager(moduleAppManager) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
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
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this ModuleManager belongs to.">
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

</cfcomponent>