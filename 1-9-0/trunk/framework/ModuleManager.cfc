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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

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
		
		<cfset var moduleNodes = ArrayNew(1) />
		<cfset var modulesNode = "" />
		<cfset var modulesNodes = "" />
		<cfset var module = "" />
		
		<cfset var name = "" />
		<cfset var file = "" />
		<cfset var overrideXml = "" />
		<cfset var i = 0 />
		
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

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Preforms deconfiguration logic in each of the registered modules.">
		
		<cfset var key = "" />
		
		<cfloop collection="#variables.modules#" item="key">
			<cfset variables.modules[key].getModuleAppManager().deconfigure() />
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
	
	<cffunction name="setValidateXML" access="public" returntype="void" output="false">
		<cfargument name="validateXML" type="string" required="true" />
		<cfset variables.validateXML = arguments.validateXML />
	</cffunction>
	<cffunction name="getValidateXML" access="public" returntype="boolean" output="false">
		<cfreturn variables.validateXML />
	</cffunction>
	
</cfcomponent>