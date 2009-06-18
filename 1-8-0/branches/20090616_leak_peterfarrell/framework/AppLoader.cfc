<!---
License:
Copyright 2008 GreatBizTools, LLC

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

		<cfset var appLoader = "" />
		<cfset var appManager = "" />
		<cfset var oldAppManager = "" />
		
		<cfif isAppManagerDefined()>
			<cfset oldAppManager = getAppManager() />
		</cfif>

		<cfset updateLastReloadDatetime() />
		
		<cfset appLoader = CreateObject("component", "MachII.framework.AppLoader").init(
			getConfigPath(), getDtdPath(), getAppKey(), getValidateXML(), arguments.parentAppManager, getOverrideXml(), getModuleName()) />
		<cfset setAppManager(getAppFactory().createAppManager(getConfigPath(), getDtdPath(), 
				getAppKey(), getValidateXml(), arguments.parentAppManager, getOverrideXml(), getModuleName())) />
		<cfset getAppManager().setAppLoader(this) />
		<cfset setLastReloadHash(getConfigFileReloadHash()) />
		
		<cfif IsObject(oldAppManager)>
			<cfset getAppFactory().clearUtils() />
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
		<cfif Len(getModuleName())>
			<cfset application[getAppKey()]["appManager_" & getModuleName()] = arguments.appManager />			
		<cfelse>
			<cfset application[getAppKey()]["appManager"] = arguments.AppManager />
		</cfif>
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfif Len(getModuleName())>
			<cfreturn application[getAppKey()]["appManager_" & getModuleName()] />
		<cfelse>
			<cfreturn application[getAppKey()]["appManager"] />
		</cfif>
	</cffunction>
	<cffunction name="isAppManagerDefined" access="public" returntype="boolean">
		<cfif Len(getModuleName())>
			<cfreturn IsDefined("application.#getAppKey()#.appManager_#getModuleName()#") />
		<cfelse>
			<cfreturn IsDefined("application.#getAppKey()#.appManager") />
		</cfif>	
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

</cfcomponent>