<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent 
	displayname="AppLoader" 
	output="false"
	hint="Responsible for controlling the loading/reloading of the AppManager.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.configPath = "" />
	<cfset variables.dtdPath = "" />
	<cfset variables.appManager = "" />
	<cfset variables.appFactory = "" />
	<cfset variables.lastReloadHash = 0 />
	<cfset variables.validateXML = 0 />
	<cfset variables.overrideXml = "" />
	<cfset variables.lastReloadDatetime = "" />
	<cfset variables.appKey = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="MachII.framework.AppLoader" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="configPath" type="string" required="true"
			hint="The full path to the configuration XML file." />
		<cfargument name="dtdPath" type="string" required="true"
			hint="The full path to the Mach-II DTD file." />
		<cfargument name="appKey" type="string" required="true"
			hint="Unqiue key for this application.">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="parentAppManager" type="any" required="false" default=""
			hint="Optional argument for a parent app manager. If there isn't one default to empty string." />
		<cfargument name="overrideXml" type="any" required="false" default=""
			hint="Optional argument for override Xml for a module. Default to empty string." />
		<cfargument name="moduleName" type="string" required="false" default=""
			hint="Optional argument for the name of a module. Defaults to empty string." />
		
		<cfset var appFactory = CreateObject("component", "MachII.framework.AppFactory").init() />
		
		<cfset setAppFactory(appFactory) />

		<cfset setConfigPath(arguments.configPath) />
		<cfset setDtdPath(arguments.dtdPath) />
		<cfset setValidateXml(arguments.validateXml) />
		<cfset setOverrideXml(arguments.overrideXml) />
		<cfset setModuleName(arguments.moduleName) />
		<cfset setAppKey(arguments.appKey) />
		
		<!--- (Re)Load the configuration. --->
		<cfset reloadConfig(arguments.validateXml, arguments.parentAppManager) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false"
		hint="Determines if the configuration file should be reloaded.">
		
		<cfset var result = false />
		
		<cfif shouldReloadBaseConfig() OR shouldReloadModuleConfig()>
			<cfset result = true />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="shouldReloadModuleConfig" access="public" returntype="boolean" output="false"
		hint="Determines if any of the module configuration files should be reloaded.">

		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var module = 0 />
		<cfset var result = false />
		
		<!--- Only loop over the modules if this is the base app --->
		<cfif NOT IsObject(getAppManager().getParent())>
			<cfloop collection="#modules#" item="module">
				<cfif modules[module].shouldReloadConfig()>
					<cfset result = true />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="shouldReloadBaseConfig" access="public" returntype="boolean" output="false"
		hint="Determines if any of the base configuration files should be reloaded.">
		
		<cfset var result = false />
		
		<cfif CompareNoCase(getLastReloadHash(), getConfigFileReloadHash()) NEQ 0>
			<cfset result = true />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="reloadConfig" access="public" returntype="void" output="false"
		hint="Reloads the config file and sets the last reload hash.">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="parentAppManager" type="any" required="false" default=""
			hint="Optional argument for a parent app manager. If there isn't one default to empty string." />

		<cfset var oldAppManager = variables.appManager />
		
		<cfset updateLastReloadDatetime() />		
		<cfset setAppManager(getAppFactory().createAppManager(getConfigPath(), getDtdPath(), 
				getAppKey(), getValidateXml(), arguments.parentAppManager, getOverrideXml(), getModuleName())) />
		<cfset getAppManager().setAppLoader(this) />
		<cfset setLastReloadHash(getConfigFileReloadHash()) />
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<cfif IsObject(oldAppManager)>
			<cfset oldAppManager.deconfigure() />
		</cfif>
	</cffunction>
	
	<cffunction name="reloadModuleConfig" access="public" returntype="void" output="false"
		hint="Reloads the config file and sets the last reload hash.">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="parentAppManager" type="any" required="false" default=""
			hint="Optional argument for a parent app manager. If there isn't one default to empty string." />

		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var module = 0 />
		
		<!--- Only loop over the modules if this is the base app --->
		<cfif NOT IsObject(getAppManager().getParent())>
			<cfloop collection="#modules#" item="module">
				<cfif modules[module].shouldReloadConfig()>
					<cfset modules[module].reloadModuleConfig(arguments.validateXml) />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getConfigFileReloadHash" access="private" returntype="string" output="false"
		hint="Get the current reload hash of the master config file and any include files which is based on dateLastModified and size.">

		<cfset var configFilePaths = getAppFactory().getConfigFilePaths() />
		<cfset var directoryResults = "" />
		<cfset var hashableString = "" />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(configFilePaths)#" index="i">
			<cfdirectory action="LIST" directory="#GetDirectoryFromPath(configFilePaths[i])#" 
				name="directoryResults" filter="#GetFileFromPath(configFilePaths[i])#" />
			<cfset hashableString = hashableString & directoryResults.dateLastModified & directoryResults.size />
		</cfloop>

		<cfreturn Hash(hashableString) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setLastReloadHash" access="public" returntype="void" output="false">
		<cfargument name="lastReloadHash" type="string" required="true" />
		<cfset variables.lastReloadHash = arguments.lastReloadHash />
	</cffunction>
	<cffunction name="getLastReloadHash" access="public" returntype="string" output="false">
		<cfreturn variables.lastReloadHash />
	</cffunction>
	
	<cffunction name="setConfigPath" access="public" returntype="void" output="false">
		<cfargument name="configPath" type="string" required="true" />
		<cfset variables.configPath = arguments.configPath />
	</cffunction>
	<cffunction name="getConfigPath" access="public" returntype="string" output="false">
		<cfreturn variables.configPath />
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
	
	<cffunction name="setDtdPath" access="public" returntype="void" output="false">
		<cfargument name="dtdPath" type="string" required="true" />
		<cfset variables.dtdPath = arguments.dtdPath />
	</cffunction>
	<cffunction name="getDtdPath" access="public" returntype="string" output="false">
		<cfreturn variables.dtdPath />
	</cffunction>
	
	<cffunction name="setValidateXML" access="public" returntype="void" output="false">
		<cfargument name="validateXML" type="boolean" required="true" />
		<cfset variables.validateXML = arguments.validateXML />
	</cffunction>
	<cffunction name="getValidateXML" access="public" returntype="boolean" output="false">
		<cfreturn variables.validateXML />
	</cffunction>
	
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setAppFactory" access="public" returntype="void" output="false">
		<cfargument name="appFactory" type="MachII.framework.AppFactory" required="true" />
		<cfset variables.appFactory = arguments.appFactory />
	</cffunction>
	<cffunction name="getAppFactory" access="public" returntype="MachII.framework.AppFactory" output="false">
		<cfreturn variables.appFactory />
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
	
	<cffunction name="updateLastReloadDatetime" access="private" returntype="void" output="false"
		hint="Updates the last reload datetime for this module or base application.">
		<cfset variables.lastReloadDatetime = Now() />
	</cffunction>
	<cffunction name="getLastReloadDatetime" access="public" type="date" output="false"
		hint="Gets the last reload datetime for this module or base application.">
		<cfreturn variables.lastReloadDatetime />
	</cffunction>
	
	<cffunction name="setAppKey" access="public" returntype="void" output="false">
		<cfargument name="appkey" type="string" required="true" />
		<cfset variables.appkey = arguments.appkey />
	</cffunction>
	<cffunction name="getAppKey" access="public" type="string" output="false">
		<cfreturn variables.appkey />
	</cffunction>
	
	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>