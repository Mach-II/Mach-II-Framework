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

$Id$

Created version: 1.0.1
Updated version: 1.8.0

Notes:
This bootstrapper is DEPRECATED since Mach-II no longer officially
supports Aobe ColdFusion 6.1. Use Application.cfc by extending MachII.mach-ii.
--->

<!--- Set the path to the application's mach-ii.xml file. Default to ./config/mach-ii.xml. --->
<cfparam name="MACHII_CONFIG_PATH" type="string" default="#ExpandPath('./config/mach-ii.xml')#" />
<!--- Set the configuration mode (when to reload): -1=never, 0=dynamic, 1=always --->
<cfparam name="MACHII_CONFIG_MODE" type="numeric" default="0" />
<!---
	Set the app key for sub-applications within a single cf-application. Default to the folder name below the Application.cfc/cfm.
	Windows systems use the nasty "\" so we convert all "\" to "/".
--->
<cfparam name="MACHII_APP_KEY" type="string" default="#ListLast(ReplaceNoCase(GetDirectoryFromPath(GetCurrentTemplatePath()), "\", "/", "all"), "/")#" />
<!--- Whether or not to validate the configuration XML before parsing. Default to false. --->
<cfparam name="MACHII_VALIDATE_XML" type="boolean" default="false" />
<!--- Set the path to the Mach-II's DTD file. Default to /MachII/mach-ii_1_8_0.dtd. --->
<cfparam name="MACHII_DTD_PATH" type="string" default="#ExpandPath('/MachII/mach-ii_1_9_0.dtd')#" />
<!--- Set the request timeout for loading of the framework. Defaults to 120 --->
<cfparam name="MACHII_ONLOAD_REQUEST_TIMEOUT" type="numeric" default="120" />

<!--- Clean the AppKey --->
<cfset MACHII_APP_KEY = REReplaceNoCase(MACHII_APP_KEY, "[[:punct:]|[:cntrl:]]", "", "all") />

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

<!---
	Handle the request and suppress whitespace. Enableoutputonly may be false
	so turn it back on for trailing whitespace. All these tags must be on the
	same line or additional whitespace may be introduced.
--->
<cfprocessingdirective suppresswhitespace="true"><cfcontent reset="true" /><cfsetting enablecfoutputonly="true" /><cfset application[MACHII_APP_KEY].appLoader.getAppManager().getRequestHandler().handleRequest() /><cfsetting enablecfoutputonly="true" /></cfprocessingdirective>