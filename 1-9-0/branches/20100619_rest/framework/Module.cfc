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
	displayname="Module"
	output="false"
	hint="Holds a Module.">
	
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
				getFile(), arguments.configDtdPath, getAppManager().getAppKey(), arguments.validateXML, getAppManager(), getOverrideXml(), getModuleName()) />
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
		
		<cfset var oldModuleAppManager = getModuleAppManager() />
		
		<!--- Create a new module --->
		<cfset configure(getDtdPath(), arguments.validateXml) />
		
		<!--- Only run deconfigure in old module once the new module has successfully been configured --->
		<cfset oldModuleAppManager.deconfigure() />
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
		hint="Returns the ModuleAppManager instance this ModuleManager belongs to.">
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