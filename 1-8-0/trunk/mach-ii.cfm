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

Created version: 1.0.1
Updated version: 1.6.0

Notes:
This bootstrapper is DEPRECATED since Mach-II no longer officially 
supports Aobe ColdFusion 6.1. Use Application.cfc by extending MachII.mach-ii.
--->
<!--- Set the path to the application's mach-ii.xml file. Default to ./config/mach-ii.xml. --->
<cfparam name="MACHII_CONFIG_PATH" type="string" default="#ExpandPath('./config/mach-ii.xml')#" />
<!--- Set the configuration mode (when to reload): -1=never, 0=dynamic, 1=always --->
<cfparam name="MACHII_CONFIG_MODE" type="numeric" default="0" />
<!--- Set the app key for sub-applications within a single cf-application. Default to the folder name. --->
<cfparam name="MACHII_APP_KEY" type="string" default="#GetFileFromPath(ExpandPath('.'))#" />
<!--- Whether or not to validate the configuration XML before parsing. Default to false. --->
<cfparam name="MACHII_VALIDATE_XML" type="boolean" default="false" />
<!--- Set the path to the Mach-II's DTD file. Default to /MachII/mach-ii_1_8_0.dtd. --->
<cfparam name="MACHII_DTD_PATH" type="string" default="#ExpandPath('/MachII/mach-ii_1_8_0.dtd')#" />
<!--- Set the request timeout for loading of the framework. Defaults to 120 --->
<cfparam name="MACHII_ONLOAD_REQUEST_TIMEOUT" type="numeric" default="120" />

<!--- Clean the AppKey --->
<cfset MACHII_APP_KEY = REReplace(MACHII_APP_KEY, "[[:punct:]|[:cntrl:]]", "", "all") />

<!--- default is request.MachIIConfigMode if it is defined, else use cfparam --->
<cfif StructKeyExists(request,"MachIIConfigMode")>
	<cfset MACHII_CONFIG_MODE = request.MachIIConfigMode />
</cfif>

<!--- Create the sub-apps space in the application scope. Double check required for proper multi-threading. --->
<cfif NOT StructKeyExists(application,MACHII_APP_KEY)>
	<cflock name="application_#MACHII_APP_KEY#" type="exclusive" timeout="120">
		<cfif NOT StructKeyExists(application,MACHII_APP_KEY)>
			<cfset application[MACHII_APP_KEY] = StructNew() />
		</cfif>
	</cflock>
</cfif>

<!--- Create the AppLoader if necessary. Double check required for proper multi-threading. --->
<cfif NOT (StructKeyExists(application[MACHII_APP_KEY], "appLoader") 
		AND IsObject(application[MACHII_APP_KEY].appLoader))>
	<cflock name="application_#MACHII_APP_KEY#_apploader" type="exclusive" timeout="120">
		<cfif NOT (StructKeyExists(application[MACHII_APP_KEY], "appLoader") 
				AND IsObject(application[MACHII_APP_KEY].appLoader))>
			<!--- Set the timeout --->
			<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />

			<cfset application[MACHII_APP_KEY].appLoader = 
					 CreateObject("component", "MachII.framework.AppLoader").init(MACHII_CONFIG_PATH, MACHII_DTD_PATH, MACHII_APP_KEY, MACHII_VALIDATE_XML) />
		</cfif>
	</cflock>
<!--- Reload the configuration if necessary. --->
<cfelseif MACHII_CONFIG_MODE EQ -1>
	<!--- Do not reload config. --->
<cfelseif MACHII_CONFIG_MODE EQ 1>
	<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
		<!--- Set the timeout --->
		<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
		<cfset application[MACHII_APP_KEY].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
	</cflock>
<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[MACHII_APP_KEY].appLoader.shouldReloadBaseConfig()>
	<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
		<!--- Set the timeout --->
		<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
		<cfset application[MACHII_APP_KEY].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
	</cflock>
<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[MACHII_APP_KEY].appLoader.shouldReloadModuleConfig()>
	<cflock name="application_#MACHII_APP_KEY#_reload" type="exclusive" timeout="120">
		<!--- Set the timeout --->
		<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
		<cfset application[MACHII_APP_KEY].appLoader.reloadModuleConfig(MACHII_VALIDATE_XML) />
	</cflock>
</cfif>

<!--- Log a message that the mach-ii.cfm bootstrapper is deprecated --->
<cfset application[MACHII_APP_KEY].appLoader.getLog().warn("DEPRECATED: The mach-ii.cfm bootstrapper is deprecated. Please use the mach-ii.cfc bootstrapper for Application.cfc.") />

<!--- Handle the Request --->
<cfset application[MACHII_APP_KEY].appLoader.getAppManager().getRequestHandler().handleRequest() />