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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.1.1
Updated version: 1.8.1

Notes:
- Compatible only with Adobe ColdFusion MX 7+, NewAtlanta BlueDragon 7+
	and Open BlueDragaon 1+.
- Call loadFramework in your onApplicationStart() event.
- Call handleRequest in your onRequestStart() or onRequest() events.

N.B.
Do not implement the handleRequest() in onRequest() application event if you
want to utilitze any CFCs that implement AJAX requests, web services, Flash
Remoting or event gateway requests.

ColdFusion MX will not execute these types of requests if you implement
the handleRequest() method in the onRequest() application event.

Certain methods are not available for use until after loadFramework() has
completed execution.  This is because the following method require the
framework to be loaded as they interact with framework components:

* setProperty()
* getProperty()
* isPropertyDefined()
* getAppManager()
* shouldReloadConfig()
--->
<cfcomponent
	displayname="mach-ii"
	output="false"
	hint="Bootstrapper for Application.cfc integration">

	<!---
	PROPERTIES - DEFAULTS
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
	<cfparam name="MACHII_DTD_PATH" type="string" default="#ExpandPath('/MachII/mach-ii_1_8_0.dtd')#" />
	<!--- Set the request timeout for loading of the framework. Defaults to 240 --->
	<cfparam name="MACHII_ONLOAD_REQUEST_TIMEOUT" type="numeric" default="240" />
	<!--- Set if the framework should serve a "loading" template --->
	<cfparam name="MACHII_HANDLE_ONLOAD" type="boolean" default="true" />
	<!--- Set the template to show for loading of the framework. Defaults to Mach-II default template. --->
	<cfparam name="MACHII_ONLOAD_TEMPLATE" type="string" default="/MachII/bootstrapper/defaultLoadingTemplate.cfm" />

	<!---
	APPLICATION SPECIFIC EVENTS
	--->
	<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false"
		hint="Handles the application start event. Override to provide customized functionality.">
		<!--- Load up the framework --->
		<cfset LoadFramework() />

		<cfreturn TRUE />
	</cffunction>

	<cffunction name="onApplicationEnd" access="public" returntype="void" output="false"
		hint="Handles the application start event. Override to provide customized functionality.">
		<cfargument name="applicationScope" type="struct" required="true">
		<cfset getAppManager().onApplicationEnd() />
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
		<cfset ensureLoadedFramework() />
		<cfset getAppManager().onSessionStart() />
	</cffunction>

	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="Handles on session end event if sessions are enabled for this application.">
		<cfargument name="sessionScope" type="struct" required="true" />
		<cfargument name="applicationScope" type="struct" required="true" />
		<!--- Access to the application and session scopes are passed in --->
		<cfset arguments.applicationScope[getAppKey()].appLoader.getAppManager().onSessionEnd(arguments.sessionScope) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="loadFramework" access="public" returntype="void" output="false"
		hint="Loads the framework. Only call in onApplicationStart() event.">

		<cfset var appKey = getAppKey() />

		<!--- Set the timeout --->
		<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />

		<!--- Create the AppLoader. No locking requires if called during the onApplicationStart() event. --->
		<cfset application[appKey] = StructNew() />
		<cfset application[appKey].loading = true />

		<cftry>
			<cfset application[appKey].appLoader = CreateObject("component", "MachII.framework.AppLoader").init(MACHII_CONFIG_PATH, MACHII_DTD_PATH, AppKey, MACHII_VALIDATE_XML) />

			<cfcatch type="any">
				<cfset application[appKey].loading = false />
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfset application[appKey].loading = false />
		<cfset request.MachIIReload = FALSE />
	</cffunction>

	<cffunction name="ensureLoadedFramework" access="public" returntype="void" output="false"
		hint="Ensures the framework is loaded and checks if it needs to be reloaded.">

		<cfset var appKey = getAppKey() />

		<!---
		Default is request.MachIIConfigMode if it is defined temporarily override the config mode
		DO NOT USE THIS LEGACY CODE
		THIS HAS BEEN DEPRECATED AND WILL BE REMOVED IN MACH-II 2.0
		--->
		<cfif StructKeyExists(request, "MachIIConfigMode")>
			<cfset variables.MACHII_CONFIG_MODE = request.MachIIConfigMode />
		</cfif>

		<cfset handleOnLoadTemplate() />

		<!--- Check if AppLoader is available. Double check required for proper multi-threading. --->
		<cfif NOT IsDefined("application.#appKey#.appLoader") OR NOT IsObject(application[appKey].appLoader)>
			<cflock name="application_#appKey#_reload" type="exclusive" timeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#">
				<cfif NOT IsDefined("application.#appKey#.appLoader") OR NOT IsObject(application[appKey].appLoader)>
					<cfset loadFramework() />
				</cfif>
			</cflock>
		</cfif>

		<!--- Reload the configuration if necessary --->
		<cfif MACHII_CONFIG_MODE EQ -1>
			<!--- Do not reload config. --->
		<cfelseif MACHII_CONFIG_MODE EQ 1 AND NOT StructKeyExists(request, "MachIIReload")>
			<cflock name="application_#appKey#_reload" type="exclusive" timeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#">
				<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
				<cfset application[appKey].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
			</cflock>
		<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[appKey].appLoader.shouldReloadBaseConfig()>
			<cflock name="application_#appKey#_reload" type="exclusive" timeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#">
				<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
				<cfset application[appKey].appLoader.reloadConfig(MACHII_VALIDATE_XML) />
			</cflock>
		<cfelseif MACHII_CONFIG_MODE EQ 0 AND application[appKey].appLoader.shouldReloadModuleConfig()>
			<cflock name="application_#appKey#_reload" type="exclusive" timeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#">
				<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />
				<cfset application[appKey].appLoader.reloadModuleConfig(MACHII_VALIDATE_XML) />
			</cflock>
		</cfif>
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a Mach-II request. Recommend to call in onRequestStart() event.">

		<cfset ensureLoadedFramework() />

		<!---
			Handle the request and suppress whitespace. EnableOutputOnly may be false
			so turn it back on for trailing whitespace. All these tags must be on the
			same line or additional whitespace may be introduced.
		--->
		<cfprocessingdirective suppresswhitespace="true"><cfcontent reset="true" /><cfsetting enablecfoutputonly="true" /><cfset getAppManager().getRequestHandler().handleRequest() /><cfsetting enablecfoutputonly="true" /></cfprocessingdirective>
	</cffunction>

	<cffunction name="handleOnLoadTemplate" access="public" returntype="void" output="true"
		hint="Handles on load template serving.">

		<cfset var appKey = getAppKey() />

		<cfif MACHII_HANDLE_ONLOAD AND IsDefined("application.#appKey#.loading") AND application[appKey].loading>
			<cfinclude template="#MACHII_ONLOAD_TEMPLATE#" />
			<cfabort />
		</cfif>
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
		<cftry>
			<cfreturn application[getAppKey()].appLoader.getAppManager() />
			<cfcatch type="any">
				<cfif NOT IsDefined("application.#getAppKey()#.appLoader")>
					<cfthrow type="MachII.framework.AppManagerNotAvailable"
						message="Calls to getAppManager(), getProperty(), setProperty() and isPropertyDefined() in your Application.cfc cannot be made until after loadFramework has completed processing."
						detail="This indicates a premature call to one of the listed methods in your Application.cfc before the framework has completely loaded. Please check your code." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="reloadConfig" access="public" returntype="void" output="false"
		hint="Dynamically reloads the entire appliation. Not available until loadFramework has been called.">

		<cfset var appKey = getAppKey() />

		<cftry>
			<!--- Set the timeout --->
			<cfsetting requestTimeout="#MACHII_ONLOAD_REQUEST_TIMEOUT#" />

			<cfset application[appKey].loading = true />
			<cfset application[appKey].appLoader.reloadConfig() />
			<cfset application[appKey].loading = false />

			<cfcatch type="any">
				<cfset application[appKey].loading = false />

				<cfif NOT IsDefined("application.#appKey#.appLoader")>
					<cfthrow type="MachII.framework.AppLoderNotAvailable"
						message="Calls to reloadConfig() in your Application.cfc cannot be made until after loadFramework has completed processing."
						detail="This indicates a premature call to this method in your Application.cfc before the framework has completely loaded. Please check your code." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false"
		hint="Returns if the config should be dynamically reloaded. Not available until loadFramework has been called.">
		<cftry>
			<cfreturn application[getAppKey()].appLoader.shouldReloadConfig() />
			<cfcatch type="any">
				<cfif NOT IsDefined("application.#getAppKey()#.appLoader")>
					<cfthrow type="MachII.framework.AppLoderNotAvailable"
						message="Calls to shouldReloadConfig() in your Application.cfc cannot be made until after loadFramework has completed processing."
						detail="This indicates a premature call to this method in your Application.cfc before the framework has completely loaded. Please check your code." />				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppKey" access="public" returntype="string" output="false"
		hint="Returns a clean AppKey.">
		<cfreturn REReplaceNoCase(MACHII_APP_KEY, "[[:punct:]|[:cntrl:]]", "", "all") />
	</cffunction>

</cfcomponent>