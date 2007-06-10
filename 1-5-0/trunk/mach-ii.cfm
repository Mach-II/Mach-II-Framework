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
$Id$

Created version: 1.0.1
Updated version: 1.5.0

Notes:
- Added XML configuration file validation parameters. (bedwards)
- Added Mach-II version (pfarrell)
- Fixed bug where framework loaded twice on initial application start and where config mode is 1
--->
<!--- Set the path to the application's mach-ii.xml file. Default to ./config/mach-ii.xml. --->
<cfparam name="MACHII_CONFIG_PATH" type="string" default="#ExpandPath('./config/mach-ii.xml')#" />
<!--- Set the configuration mode (when to reload): -1=never, 0=dynamic, 1=always --->
<cfparam name="MACHII_CONFIG_MODE" type="numeric" default="0" />
<!--- Set the app key for sub-applications within a single cf-application. Default to the folder name. --->
<cfparam name="MACHII_APP_KEY" type="string" default="#GetFileFromPath(ExpandPath('.'))#" />
<!--- Whether or not to validate the configuration XML before parsing. Default to false. --->
<cfparam name="MACHII_VALIDATE_XML" type="boolean" default="false" />
<!--- Set the path to the Mach-II's DTD file. Default to /MachII/mach-ii_1_1_1.dtd. --->
<cfparam name="MACHII_DTD_PATH" type="string" default="#ExpandPath('/MachII/mach-ii_1_5_0.dtd')#" />
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
			<cfset application[MACHII_APP_KEY].appLoader = 
					 CreateObject("component", "MachII.framework.AppLoader").init(MACHII_CONFIG_PATH, MACHII_DTD_PATH, MACHII_APP_KEY, MACHII_VALIDATE_XML) />
		</cfif>
	</cflock>
<!--- Reload the configuration if necessary. --->
<cfelseif MACHII_CONFIG_MODE EQ -1>
	<!--- Do not reload config. --->
<cfelseif MACHII_CONFIG_MODE EQ 1>
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

<!--- Handle the Request. --->
<cfset application[MACHII_APP_KEY].appLoader.getAppManager().getRequestHandler().handleRequest() />