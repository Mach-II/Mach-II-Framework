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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.1.1
Updated version: 1.6.0

Notes:
- Compatible only with Adobe ColdFusion MX 7.0+ or NewAtlanta BlueDragon 7+.
- Call loadFramework in your onApplicationStart() event.
- Call handleRequest in your onRequestStart() or onRequest() events.

N.B.
Do not implement the handleRequest() in onRequest() application event if you
want to utilitze any CFCs that implement AJAX requests, web services, Flash 
Remoting or event gateway requests.

ColdFusion MX will not execute these types of requests if you implement 
the handleRequest() method in the onRequest() application event.
--->
<cfcomponent
	displayname="mach-ii"
	output="false"
	hint="Base component for Application.cfc integration">
	
	<!---
	PROPERTIES - DEFAULTS
	--->
	<!--- Set the path to the application's mach-ii.xml file. Default to ./config/mach-ii.xml. --->
	<cfparam name="MACHII_CONFIG_PATH" type="string" default="#ExpandPath('./config/mach-ii.xml')#" />
	<!--- Set the configuration mode (when to reload): -1=never, 0=dynamic, 1=always --->
	<cfparam name="MACHII_CONFIG_MODE" type="numeric" default="0" />
	<!--- Set the app key for sub-applications within a single cf-application. Default to the folder name. --->
	<cfparam name="MACHII_APP_KEY" type="string" default="#GetFileFromPath(ExpandPath('.'))#" />
	<!--- Whether or not to validate the configuration XML before parsing. Default to false. --->
	<cfparam name="MACHII_VALIDATE_XML" type="boolean" default="false" />
	<!--- Set the path to the Mach-II's DTD file. Default to /MachII/mach-ii_1_1.dtd. --->
	<cfparam name="MACHII_DTD_PATH" type="string" default="#ExpandPath('/MachII/mach-ii_1_6_0.dtd')#" />	
	<!--- Set the request timeout for loading of the framework. Defaults to 120 --->
	<cfparam name="MACHII_ONLOAD_REQUEST_TIMEOUT" type="numeric" default="120" />

	<!---
	APPLICATION SPECIFIC EVENTS
	--->
	<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false"
		hint="Run on the application start event. Override to provide customize functionality.">
		<!--- Load up the framework --->
		<cfset LoadFramework() />
		
		<cfreturn TRUE />
	</cffunction>
	
	<cffunction name="onRequestStart" access="public" returntype="void" output="true"
		hint="Handles Mach-II requests. Output must be set to true. Override to provide custom functionality.">
		<cfargument name="targetPage" type="string" required="true" />

		<!--- Handle Mach-II request --->
		<cfif FindNoCase("index.cfm", arguments.targetPage)>
			<cfset handleRequest() />
		</cfif>
	</cffunction>
	
	<cffunction name="onSessionStart" access="public" returntype="void" output="false"
		hint="Handles on session start event if sessions are enabled for this application.">
		<cfset getAppManager().onSessionStart() />
	</cffunction>
	
	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="Handles on session end event if sessions are enabled for this application.">
		<cfargument name="sessionScope" type="struct" required="true" />
		<cfargument name="applicationScope" type="struct" required="true" />
		<!--- Access to the application and session scopes are passed in --->	
		<cfset arguments.applicationScope[MACHII_APP_KEY].appLoader.getAppManager().onSessionEnd(arguments.sessionScope) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="loadFramework" access="public" returntype="void" output="false"
		hint="Loads the framework. Only call in onApplicationStart() event.">		
		<!--- Set the timeout --->
		<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
		
		<!--- Create the AppLoader. No locking requires if called during the onApplicationStart() event. --->
		<cfset application[MACHII_APP_KEY] = StructNew() />
		<cfset application[MACHII_APP_KEY].appLoader = CreateObject("component", "MachII.framework.AppLoader").init(MACHII_CONFIG_PATH, MACHII_DTD_PATH, MACHII_APP_KEY, MACHII_VALIDATE_XML) />
		<cfset request.MachIIReload = FALSE />
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a Mach-II request. Recommend to call in onRequestStart() event.">
		<!---
		Default is request.MachIIConfigMode if it is defined temporarily override the config mode
		DO NOT USE THIS LEGACY CODE
		THIS HAS BEEN DEPRECATED AND WILL BE REMOVED IN MACH-II 2.0
		--->
		<cfif StructKeyExists(request,"MachIIConfigMode")>
			<cfset MACHII_CONFIG_MODE = request.MachIIConfigMode />
		</cfif>
		
		<!--- Check if AppLoader is available. Double check required for proper multi-threading. --->
		<cfif NOT IsDefined("application.#MACHII_APP_KEY#.appLoader") OR NOT IsObject(application[MACHII_APP_KEY].appLoader)>
			<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
				<cfif NOT IsDefined("application.#MACHII_APP_KEY#.appLoader") OR NOT IsObject(application[MACHII_APP_KEY].appLoader)>
					<cfset loadFramework() />
				</cfif>
			</cflock>
		</cfif>

		<!--- Reload the configuration if necessary --->
		<cfif MACHII_CONFIG_MODE EQ -1>
			<!--- Do not reload config. --->
		<cfelseif MACHII_CONFIG_MODE EQ 1 AND NOT StructKeyExists(request, "MachIIReload")>
			<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
				<cfset application[MACHII_APP_KEY].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
			</cflock>
		<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[MACHII_APP_KEY].appLoader.shouldReloadBaseConfig()>
			<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
				<cfset application[MACHII_APP_KEY].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
			</cflock>
		<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[MACHII_APP_KEY].appLoader.shouldReloadModuleConfig()>
			<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
				<cfset application[MACHII_APP_KEY].appLoader.reloadModuleConfig(MACHII_VALIDATE_XML) />
			</cflock>
		</cfif>

		<!--- Handle the request --->
		<cfset application[MACHII_APP_KEY].appLoader.getAppManager().getRequestHandler().handleRequest() />
	</cffunction>

	<!---
	ACCESSORS - MACHII INTEGRATION
	--->
	<cffunction name="setProperty" access="public" returntype="void" output="false"
		hint="Sets the property value by name. Not available until loadFramework() has been called.">
		<cfargument name="propertyName" type="string" required="true" />
		<cfargument name="propertyValue" type="any" required="true" />
		<cfset getAppManager().getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Returns the property value by name. If the property is not defined, and a default value is passed, it will be returned. If the property and a default value are both not defined then an exception is thrown. Not available until loadFramework() has been called.">
		<cfargument name="propertyName" type="string" required="true" />
		<cfargument name="defaultValue" type="any" required="false" default="" />
		<cfreturn getAppManager().getPropertyManager().getProperty(arguments.propertyName, arguments.defaultValue) />
	</cffunction>
	<cffunction name="isPropertyDefined" access="public" returntype="boolean" output="false"
		hint="Checks if property name is defined in the properties. Not available until loadFramework() has been called.">
		<cfargument name="propertyName" type="string" required="true"/>
		<cfreturn getAppManager().getPropertyManager().isPropertyDefined(arguments.propertyName) />
	</cffunction>
	
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Get the Mach-II AppManager. Not available until loadFramework has been called.">
		<cfreturn application[MACHII_APP_KEY].appLoader.getAppManager() />
	</cffunction>
	
	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false"
		hint="Returns if the config should be dynamically reloaded.">
		<cfreturn application[MACHII_APP_KEY].appLoader.shouldReloadConfig() />
	</cffunction>

</cfcomponent>