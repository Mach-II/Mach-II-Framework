<!---
License:
Copyright 2006 Mach-II Corporation

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
$Id: AppLoader.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.1

Notes:
- Added fix for LSDatetimeParse() bug for Non-EN locales. (pfarrell)
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
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="MachII.framework.AppLoader" output="true"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="configPath" type="string" required="true"
			hint="The full path to the configuration XML file." />
		<cfargument name="dtdPath" type="string" required="true"
			hint="The full path to the Mach-II DTD file." />
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="version" type="string" required="false" default="Unknown BER"
			hint="The version number of Mach-II." />
		
		<cfset var appFactory = CreateObject('component', 'MachII.framework.AppFactory').init() />
		<cfset setAppFactory(appFactory) />

		<cfset setConfigPath(arguments.configPath) />
		<cfset setDtdPath(arguments.dtdPath) />
		<!--- (Re)Load the configuration. --->
		<cfset reloadConfig(arguments.validateXml, arguments.version) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false"
		hint="Determines of the configuration file should be reloaded.">
		<cfif CompareNoCase(getLastReloadHash(), getConfigFileReloadHash())>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="reloadConfig" access="public" returntype="void" output="false"
		hint="Reloads the config file and sets the last reload hash.">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="version" type="string" required="false" default="Unknown BER"
			hint="The version number of Mach-II." />
		
		<cfset setAppManager(getAppFactory().createAppManager(getConfigPath(), getDtdPath(), arguments.validateXml, arguments.version)) />
		<cfset setLastReloadHash(getConfigFileReloadHash()) />
	</cffunction>

	<cffunction name="getConfigFileReloadHash" access="public" returntype="string" output="false"
		hint="Get the current reload hash of the config file which is based on dateLastModified and size.">
		<cfset var configFile = "" />

		<cfdirectory action="LIST" directory="#GetDirectoryFromPath(getConfigPath())#" 
			name="configFile" filter="#GetFileFromPath(getConfigPath())#" />

		<cfreturn hash(configFile.dateLastModified & configFile.size) />
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
	
	<cffunction name="setDtdPath" access="public" returntype="void" output="false">
		<cfargument name="dtdPath" type="string" required="true" />
		<cfset variables.dtdPath = arguments.dtdPath />
	</cffunction>
	<cffunction name="getDtdPath" access="public" returntype="string" output="false">
		<cfreturn variables.dtdPath />
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

</cfcomponent>