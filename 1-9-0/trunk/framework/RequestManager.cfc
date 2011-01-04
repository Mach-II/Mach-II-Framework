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

Created version: 1.5.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="RequestManager"
	output="false"
	hint="Manages request functionality for the framework.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.propertyManager = "" />
	<cfset variables.utils = "" />
	<cfset variables.defaultUrlBase = "" />
	<cfset variables.eventParameter = "" />
	<cfset variables.parameterPrecedence = "" />
	<cfset variables.parseSes = "" />
	<cfset variables.urlExcludeEventParameter = false />
	<cfset variables.queryStringUrls = false />
	<cfset variables.queryStringDelimiter = "" />
	<cfset variables.seriesDelimiter ="" />
	<cfset variables.pairDelimiter = "" />
	<cfset varibales.moduleDelimiter = "" />
	<cfset variables.maxEvents = 0 />
	<cfset variables.onRequestEndCallbacks = ArrayNew(1) />
	<cfset variables.preRedirectCallbacks = ArrayNew(1) />
	<cfset variables.postRedirectCallbacks = ArrayNew(1) />
	<cfset variables.callbackGroupNames = "onRequestEndCallbacks,preRedirectCallbacks,postRedirectCallbacks" />
	<cfset variables.requestRedirectPersist = "" />
	<cfset variables.rewriteConfigFileOn = false />
	<cfset variables.rewriteConfigFile = "rewriteRules.cfm" />
	<cfset variables.rewriteBaseFileName = "index.cfm" />
	<cfset variables.log = "" />
	<cfset variables.routes = StructNew() />
	<cfset variables.routeAliases = StructNew() />
	<cfset variables.moduleNames = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="Sets the base AppManager." />

		<cfset setAppManager(arguments.appManager) />
		<cfset setPropertyManager(arguments.appManager.getPropertyManager()) />
		<cfset setUtils(arguments.appManager.getUtils()) />
		<cfset setLog(arguments.appManager.getLogFactory()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures properties required to manage requests.">

		<cfset var urlDelimiters = "" />
		<cfset var temp = "" />

		<!--- Setup defaults --->
		<cfset urlDelimiters = getPropertyManager().getProperty("urlDelimiters") />
		<cfset setDefaultUrlBase(getPropertyManager().getProperty("urlBase")) />
		<cfset setDefaultUrlSecureBase(getPropertyManager().getProperty("urlSecureBase")) />
		<cfset setEventParameter(getPropertyManager().getProperty("eventParameter")) />
		<cfset setParameterPrecedence(getPropertyManager().getProperty("parameterPrecedence")) />
		<cfset setParseSES(getPropertyManager().getProperty("urlParseSES")) />
		<cfset setUrlExcludeEventParameter(getPropertyManager().getProperty("urlExcludeEventParameter")) />
		<cfset setModuleDelimiter(getPropertyManager().getProperty("moduleDelimiter")) />
		<cfset setMaxEvents(getPropertyManager().getProperty("maxEvents")) />
		<cfset setModuleNames(getAppManager().getModuleManager().getModuleNames()) />

		<!--- TODO:Check if the urlBase and urlSecureBase need to be dynamic server names --->

		<cfif NOT getPropertyManager().isPropertyDefined("urlSecureBase")>
			<cfset temp =  getPropertyManager().getProperty("urlBase") />

			<!--- If urlBase is fully qualified URL --->
			<cfif temp.toLowerCase().startsWith("http://")>
				<cfset temp = ReplaceNoCase(temp, "http://", "https://", "one") />
			</cfif>

			<cfset getPropertyManager().setProperty("urlSecureBase", temp) />
		</cfif>
		<cfif NOT getPropertyManager().isPropertyDefined("urlSecureBaseCheckServerName")>
			<cfset temp =  getPropertyManager().getProperty("urlSecureBase") />

			<cfif ListLen(temp, "//") GTE 2>
				<cfset getPropertyManager().setProperty("urlSecureBaseCheckServerName", ListFirst(ListGetAt(temp, 2, "//")), "/") />
			</cfif>
		</cfif>

		<!--- Parse through the complex list of delimiters --->
		<cfset setQueryStringDelimiter(ListGetAt(urlDelimiters, 1, "|")) />
		<cfset setSeriesDelimiter(ListGetAt(urlDelimiters, 2, "|")) />
		<cfset setPairDelimiter(ListGetAt(urlDelimiters, 3, "|")) />

		<!--- Check if we are using standard query string URLs --->
		<cfif getQueryStringDelimiter() EQ "?"
			AND getSeriesDelimiter() EQ "&"
			AND getPairDelimiter() EQ "=">
			<cfset setQueryStringUrls(true) />
		</cfif>

		<!--- Setup the RequestRedirectPersist --->
		<cfset setRequestRedirectPersist(CreateObject("component", "MachII.framework.RequestRedirectPersist").init(getAppManager())) />

		<!--- Determine if _arrayFind_java/cfml should be used and reassign to common function --->
		<cftry>
			<cfset ArrayFind(ArrayNew(1), "test") />
			<cfcatch type="any">
				<cfset variables.arrayFind = variables._arrayFind_java />
			</cfcatch>
		</cftry>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getRequestHandler" access="public" returntype="MachII.framework.RequestHandler" output="false"
		hint="Returns a new or cached instance of a RequestHandler.">

		<cfset var appKey = getAppManager().getAppKey() />

		<cfif NOT StructKeyExists(request, "_MachIIRequestHandler_" & appKey)>
			<cfset request["_MachIIRequestHandler_" & appKey] =
					CreateObject("component", "MachII.framework.RequestHandler").init(getAppManager(), getEventParameter(), getParameterPrecedence(), getModuleDelimiter(), getMaxEvents(), getOnRequestEndCallbacks()) />
		</cfif>

		<cfreturn request["_MachIIRequestHandler_" & appKey]  />
	</cffunction>

	<cffunction name="redirectEvent" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to an event.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="moduleName" type="string" required="false" default="" />
		<cfargument name="persist" type="boolean" required="false" default="false" />
		<cfargument name="persistArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="statusType" type="string" required="false" default="" />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<cfset var redirectToUrl =  ""/>
		<cfset var persistId =  "" />
		<cfset var redirectPersistParam = getPropertyManager().getProperty("redirectPersistParameter", "persistId") />

		<!--- Delete the event name from the args if it exists so a redirect loop doesn't occur --->
		<cfset StructDelete(arguments.eventArgs, getEventParameter(), FALSE) />
		<cfset StructDelete(arguments.persistArgs, getEventParameter(), FALSE) />
		
		<!--- Build persist data and id if required --->
		<cfif arguments.persist>
			<cfset persistId = savePersistEventData(arguments.persistArgs) />

			<!--- Add the persistId parameter to the url args if persist is required --->
			<cfif getPropertyManager().getProperty("redirectPersistParameterLocation") NEQ "cookie">
				<cfset arguments.eventArgs[redirectPersistParam] = persistId />
			</cfif>
		</cfif>

		<cfset redirectToUrl = buildUrl(arguments.moduleName, arguments.eventName, arguments.eventArgs, arguments.urlBase) />

		<cfset redirectUrl(redirectToUrl, arguments.statusType) />
	</cffunction>

	<cffunction name="redirectRoute" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to a route.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="routeArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="persist" type="boolean" required="false" default="false" />
		<cfargument name="persistArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="statusType" type="string" required="false" default="" />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<cfset var redirectToUrl = "" />
		<cfset var persistId = "" />
		<cfset var queryStringParams = StructNew() />
		<cfset var redirectPersistParam = getPropertyManager().getProperty("redirectPersistParameter", "persistId") />

		<!--- Delete the event name from the args if it exists so a redirect loop doesn't occur --->
		<cfset StructDelete(arguments.routeArgs, getEventParameter(), FALSE) />
		<cfset StructDelete(arguments.persistArgs, getEventParameter(), FALSE) />

		<!--- Build persist data and id if required --->
		<cfif arguments.persist>
			<cfset persistId = savePersistEventData(arguments.persistArgs) />

			<!--- Add the persistId parameter to the url args if persist is required --->
			<cfif getPropertyManager().getProperty("redirectPersistParameterLocation") NEQ "cookie">
				<cfset queryStringParams[redirectPersistParam] = persistId />
			</cfif>
		</cfif>

		<cfset redirectToUrl = buildRouteUrl(arguments.routeName, arguments.routeArgs, queryStringParams, arguments.urlBase) />

		<cfset redirectUrl(redirectToUrl, arguments.statusType) />
	</cffunction>

	<cffunction name="redirectUrl" access="public" returntype="void" output="false">
		<cfargument name="redirectUrl" type="string" required="true"
			hint="An URL to redirect to." />
		<cfargument name="statusType" type="string" required="false" default="temporary"
			hint="The status type to use. Valid option: 'permanent' (301), 'prg' (303 - See Other), 'temporary' (302) [default option]" />
		
		<cfset getRequestHandler().getLog().info("End processing request. Redirect sequence in progress.") />

		<!--- Redirect based on the HTTP status type --->
		<cfif arguments.statusType EQ "permanent">
			<cfheader statuscode="301" statustext="Moved Permanently" />
			<cfheader name="Location" value="#arguments.redirectUrl#" />
			<!--- cflocation automatically calls abort so we have to do it manually --->
			<cfabort />
		<cfelseif arguments.statusType EQ "prg">
			<cfheader statuscode="303" statustext="See Other" />
			<cfheader name="Location" value="#arguments.redirectUrl#" />
			<!--- cflocation automatically calls abort so we have to do it manually --->
			<cfabort />
		<cfelse>
			<!--- Default condition for 302 (temporary) --->
			<cflocation url="#arguments.redirectUrl#" addtoken="no" />
		</cfif>
	</cffunction>

	<cffunction name="buildCurrentUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to replace or add into the current url with or a struct of data." />
		<cfargument name="urlParametersToRemove" type="string" required="false" default=""
			hint="Comma delimited list of url parameter names of items to remove from the current url" />

		<cfset var eventParameterName = getEventParameter() />
		<cfset var eventName = "" />
		<cfset var parsedModuleName = "" />
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var key = "" />
		<cfset var routeName = getRequestHandler().getCurrentRouteName() />
		<cfset var currentSESParams = getRequestHandler().getCurrentSESParams() />
		<cfset var moduleDelimiter = getModuleDelimiter() />

		<!--- Automatically remove the Mach II redirect persist id from the url params --->
		<cfset arguments.urlParametersToRemove = ListAppend(arguments.urlParametersToRemove, "persistId")>

		<cfloop collection="#url#" item="key">
			<cfif NOT StructKeyExists(params, key) AND key neq eventParameterName
				AND NOT ListFindNoCase(arguments.urlParametersToRemove, key)>
				<cfset arguments.urlParameters = ListAppend(arguments.urlParameters, "#key#=#url[key]#", "|") />
			</cfif>
		</cfloop>

		<cfif Len(routeName)>
			<cfset getLog().debug("Building route url for route '#routeName#'") />

			<cfreturn buildRouteUrl(routeName, getRequestHandler().getCurrentRouteParams(), arguments.urlParameters) />
		<cfelseif StructCount(currentSESParams)>
			<cfloop collection="#currentSESParams#" item="key">
				<cfif key eq eventParameterName>
					<cfset eventName = currentSESParams[key] />
					<cfif ListLen(eventName, moduleDelimiter) GT 1>
						<cfset parsedModuleName = ListGetAt(eventName, 1, moduleDelimiter) />
						<cfset eventName = ListGetAt(eventName, 2, moduleDelimiter) />
					<cfelse>
						<cfset parsedModuleName = arguments.moduleName />
					</cfif>
				<!--- No need to check if the key is the eventParameter in this condition because the first condition would catch it --->
				<cfelseif NOT StructKeyExists(params, key) AND NOT ListFindNoCase(arguments.urlParametersToRemove, key)>
					<cfset arguments.urlParameters = ListAppend(arguments.urlParameters, "#key#=#currentSESParams[key]#", "|") />
				</cfif>
			</cfloop>

			<cfreturn buildUrl(parsedModuleName, eventName, arguments.urlParameters) />
		<cfelse>
			<cfif isDefined("url.#eventParameterName#")>
				<cfset eventName = url[eventParameterName] />
			<cfelseif isDefined("form.#eventParameterName#")>
				<cfset eventName = form[eventParameterName] />
			</cfif>

			<cfif ListLen(eventName, moduleDelimiter) gt 1>
				<cfset parsedModuleName = ListGetAt(eventName, 1, moduleDelimiter) />
				<cfset eventName = ListGetAt(eventName, 2, moduleDelimiter) />
			<cfelse>
				<cfset parsedModuleName = arguments.moduleName />
			</cfif>

			<cfreturn buildUrl(parsedModuleName, eventName, arguments.urlParameters) />
		</cfif>

	</cffunction>

	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<cfset var builtUrl = "" />
		<cfset var queryString = "" />
		<cfset var params = StructNew() />
		<cfset var value = "" />
		<cfset var i = "" />
		<cfset var keyList = "" />
		<cfset var seriesDelimiter = getSeriesDelimiter() />
		<cfset var pairDelimiter = getPairDelimiter() />
		<cfset var parseSes = getParseSes() />
		<cfset var eventManager = "" />
		<cfset var secureType = -1 />

		<!--- This was moved out the var block to pass the bug in var scope that is getting fixed --->
		<cfset params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset keyList = StructKeyList(params) />

		<cfif getPropertyManager().getProperty("urlSecureEnabled") AND (NOT StructKeyExists(arguments, "urlBase") OR NOT Len(arguments.urlBase))>
			<cftry>
				<cfif Len(arguments.moduleName)>
					<cfset eventManager = getAppManager().getModuleManager().getModule(arguments.moduleName).getModuleAppManager().getEventManager() />
				<cfelse>
					<cfset eventManager = getAppManager().getEventManager() />
				</cfif>

				<cfset secureType = eventManager.getEventSecureType(arguments.eventName) />
				<cfcatch type="MachII.framework.ModuleFailedToLoad">
					<!--- If module:disableOnFailure is turned on, we need to ignore this exception
						and assume ambiguous secure type. This allows the url to build.  The exception
						will be thrown later when an event for that module is requested   --->
				</cfcatch>
			</cftry>

			<!--- If event handler secure type is ambiguous (-1), then default to the current secure type this request --->
			<cfif secureType EQ -1>
				<cfif cgi.SERVER_PORT_SECURE>
					<cfset arguments.urlBase = getDefaultUrlSecureBase() />
				<cfelse>
					<cfset arguments.urlBase = getDefaultUrlBase() />
				</cfif>
			<cfelseif secureType EQ 1>
				<cfset arguments.urlBase = getDefaultUrlSecureBase() />
			<cfelse>
				<cfset arguments.urlBase = getDefaultUrlBase() />
			</cfif>
		<cfelse>
			<cfset arguments.urlBase = getDefaultUrlBase() />
		</cfif>

		<!--- Nested the appending of the event parameter inside the next block
			Moving it causes redirect commands with just urls to wrongly append
			the event parameter on the end of the url --->

		<!--- Attach the module/event name if defined --->
		<cfif Len(arguments.moduleName) AND Len(arguments.eventName)>
			<!--- Attach event parameter only if it not supposed to be excluded --->
			<cfif NOT getUrlExcludeEventParameter() OR isQueryStringUrls()>
				<cfset queryString = getEventParameter() & pairDelimiter />
			</cfif>
			<cfset queryString = queryString & arguments.moduleName & getModuleDelimiter() & arguments.eventName />
		<cfelseif NOT Len(arguments.moduleName) AND Len(arguments.eventName)>
			<!--- Attach event parameter only if it not supposed to be excluded --->
			<cfif NOT getUrlExcludeEventParameter() OR isQueryStringUrls()>
				<cfset queryString = getEventParameter() & pairDelimiter />
			</cfif>
			<cfset queryString = queryString & arguments.eventName />
		</cfif>

		<!--- Sort the list of url args to keep them in a consistent order --->
		<cfset keyList = ListSort(keyList, "textnocase") />

		<!--- Attach each additional arguments if it exists and is a simple value --->
		<cfloop list="#keyList#" index="i">
			<cfif IsSimpleValue(params[i])>
				<!--- Encode all ';' to 'U+03B' (unicode) which is part of the fix for the path info truncation bug #78782 in Adobe ColdFusion --->
				<cfif parseSes>
					<cfset params[i] = Replace(params[i], ";", "U_03B", "all") />
				</cfif>
				<cfif NOT Len(params[i]) AND seriesDelimiter EQ pairDelimiter AND parseSes>
					<cfset params[i] = "_-_NULL_-_" />
				</cfif>
				<cfset queryString = queryString & seriesDelimiter & i & pairDelimiter & URLEncodedFormat(params[i]) />
			</cfif>
		</cfloop>

		<!--- Prepend the urlBase and add trailing series delimiter --->
		<cfif Len(queryString)>
			<cfset builtUrl = arguments.urlBase & getQueryStringDelimiter() & queryString />
			<cfif seriesDelimiter NEQ "&">
				<cfset builtUrl = builtUrl & seriesDelimiter />
			</cfif>
		<cfelse>
			<cfset builtUrl = arguments.urlBase />
		</cfif>

		<cfreturn builtUrl />
	</cffunction>

	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name or Url alias of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="queryStringParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of query string parameters to append to end of the route." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var parsedQueryStringParams = getUtils().parseAttributesIntoStruct(arguments.queryStringParameters) />
		<cfset var route = getRoute(arguments.routeName) />
		<cfset var moduleName = route.getModuleName() />
		<cfset var eventName = route.getEventName() />
		<cfset var eventManager = "" />
		<cfset var secureType = -1 />

		<cfif NOT StructKeyExists(arguments, "urlBase") OR NOT Len(arguments.urlBase)>
			<cftry>
				<cfif Len(moduleName)>
					<cfset eventManager = getAppManager().getModuleManager().getModule(moduleName).getModuleAppManager().getEventManager() />
				<cfelse>
					<cfset eventManager = getAppManager().getEventManager() />
				</cfif>

				<cfset secureType = eventManager.getEventSecureType(eventName) />
				<cfcatch type="MachII.framework.ModuleFailedToLoad">
					<!--- If module:disableOnFailure is turned on, we need to ignore this exception
						and assume ambiguous secure type. This allows the url to build.  The exception
						will be thrown later when an event for that module is requested   --->
				</cfcatch>
			</cftry>
			<!--- If event handler securt type is ambigous (-1), then default to the current secure type this request --->
			<cfif secureType EQ -1>
				<cfif cgi.SERVER_PORT_SECURE>
					<cfset arguments.urlBase = getDefaultUrlSecureBase() />
				<cfelse>
					<cfset arguments.urlBase = getDefaultUrlBase() />
				</cfif>
			<cfelseif secureType EQ 1>
				<cfset arguments.urlBase = getDefaultUrlSecureBase() />
			<cfelse>
				<cfset arguments.urlBase = getDefaultUrlBase() />
			</cfif>
		</cfif>

		<cfreturn route.buildRouteUrl(params, parsedQueryStringParams, arguments.urlBase, getSeriesDelimiter(), getQueryStringDelimiter()) />
	</cffunction>

	<cffunction name="parseSesParameters" access="public" returntype="struct" output="false"
		hint="Parse SES parameters.">
		<cfargument name="pathInfo" type="string" required="true" />

		<cfset var names = "" />
		<cfset var value = "" />
		<cfset var params = StructNew() />
		<cfset var i = "" />
		<cfset var routeName = "" />
		<cfset var seriesDelimiter = getSeriesDelimiter() />
		<cfset var log = getLog() />

		<!--- Remove the initial slash --->
		<cfset arguments.pathInfo = Mid(arguments.pathInfo, 2, Len(arguments.pathInfo)) />

		<!--- Decode all 'U+03B' back to ';' which is part of the fix for the path info truncation bug #78782 in Adobe ColdFusion --->
		<cfset arguments.pathInfo = Replace(arguments.pathInfo, "U_03B", ";", "all") />

		<!--- Parse SES if necessary --->
		<cfif getParseSes() AND Len(arguments.pathInfo) GT 1>
			<!--- Remove trailing series delimiter if defined --->
			<cfif Right(arguments.pathInfo, 1) IS seriesDelimiter>
				<cfset arguments.pathInfo = Mid(arguments.pathInfo, 1, Len(arguments.pathInfo) - 1) />
			</cfif>

			<cfset names = ListToArray(arguments.pathInfo, seriesDelimiter) />
			<!--- Check to see if we are dealing with processing routes --->
			<cfif ListFindNoCase(arguments.pathInfo, getEventParameter(), seriesDelimiter) GT 0>
				<!--- The SES url has the event parameter in it so routes are disabled --->
				<cfset params = parseNonRoute(names) />
				<cfset getRequestHandler().setCurrentSESParams(params) />
			<cfelse>
				<!--- No event parameter was found so check to see if a route url alias is present --->
				<cfif StructKeyExists(variables.routeAliases, names[1])>
					<cfset params = parseRoute(variables.routeAliases[names[1]], names) />
				<cfelse>
					<!--- No route found for this url --->
					<cfif getParseSes() AND getUrlExcludeEventParameter()>
						<!--- The SES url has the event parameter as the first element since the event parameter is excluded so routes are disabled --->
						<cfset params = parseNonRoute(names) />
						<cfset getRequestHandler().setCurrentSESParams(params) />
					<cfelse>
						<cfif log.isWarnEnabled()>
							<cfset getLog().warn("Could not find a configured url route with the url alias of '#names[1]#'. Routes can only be announced from the browser url using url alias. Route names are only used when referencing routes from within the framework such as BuildRouteUrl(). Cleaned path_info='#arguments.pathInfo#'") />
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		<cfelseif NOT getParseSes()>
			<!--- If SES is not enabled we just need to check to see if this is a request for a url route --->
			<!--- Remove trailing series delimiter if defined --->
			<cfif Right(arguments.pathInfo, 1) EQ "/">
				<cfset arguments.pathInfo = Mid(arguments.pathInfo, 1, Len(arguments.pathInfo) - 1) />
			</cfif>
			<cfset names = ListToArray(arguments.pathInfo, "/") />
			<cfif ListFindNoCase(arguments.pathInfo, getEventParameter(), "/") EQ 0
				AND ArrayLen(names) GTE 1>
				<cfif StructKeyExists(variables.routeAliases, names[1])>
					<cfset params = parseRoute(names[1], names) />
				<cfelse>
					<!--- No route found for this url --->
					<cfif log.isWarnEnabled()>
						<cfset getLog().warn("Could not find a configured url route with the url alias of '#names[1]#'. Routes can only be announced from the browser url using url alias. Route names are only used when referencing routes from within the framework such as BuildRouteUrl(). Cleaned path_info='#arguments.pathInfo#'") />
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn params />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTIL
	--->
	<cffunction name="createRewriteConfigFile" access="public" returntype="void" output="false"
		hint="Creates a rewrite config file.">

		<cfset var lf = Chr(10) />
		<cfset var configFilePath = ExpandPath(getRewriteConfigFile()) />
		<cfset var contents = CreateObject("java", "java.lang.StringBuffer") />
		<cfset var eventParameter = getPropertyManager().getProperty("eventParameter") />
		<cfset var endpointParameter = getPropertyManager().getProperty("endpointParameter") />
		<cfset var urlBase = getPropertyManager().getProperty("urlBase") />
		<cfset var rewriteBase = "" />
		<cfset var rewriteBaseFileName = getRewriteBaseFileName() />
		<cfset var routeNames = StructKeyArray(getRoutes()) />
		<cfset var endpointNames = getAppManager().getEndpointManager().getEndpointNames() />
		<cfset var route = 0 />
		<cfset var i = 0 />

		<cfif getRewriteConfigFileOn()>

			<!--- Clean up the appRoot --->
			<cfif NOT urlBase.endsWith("/")>
				<cfset urlBase = urlBase & "/" />
			</cfif>

			<!--- Build rewrite rules --->
			<!--- Some CFML engines do no obey enable cfouput only use cfsilent is required as well --->
			<cfset contents.append('#### <cfsilent><cfsetting enablecfoutputonly="true"/>' & lf) />
			<cfset contents.append("#### Date Generated: #dateFormat(now(), "m/d/yyyy")# #timeFormat(now(), "h:mm tt")#" & lf) />
			<cfset contents.append(lf) />
			<cfset contents.append("RewriteEngine on" & lf) />
			<cfset contents.append(lf) />

			<!---
				RewriteBase cannot be located in a basic http.conf or virtual host so only write
				it if the Mach-II application does not live in the root of the host.
			--->
			<cfif urlBase NEQ "/" AND getPropertyManager().getProperty("urlRewriteBaseEnabled", true)>
				<cfset contents.append("RewriteBase " & urlBase & lf) />
				<cfset contents.append(lf) />
				<cfset rewriteBase = "" />
			<cfelse>
				<cfset rewriteBase = "/" />
			</cfif>

			<!---
				Check if requested file name is a real file, directory or symbolic link before
				evaluating all the rewrite rules. This is for performance.

				We use document_root and request_uri because request_filename does not work unless nested in a <directory>
				node in Apache.  When nesting in a <directory> node and using a proxy to a servlet engine like Tomcat,
				none of the rewrite rules are checked.
			--->
			<cfset contents.append("#### Check if the requested file name is a real file for performance" & lf) />
			<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]" & lf) />
			<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d [OR]" & lf) />
			<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -l" & lf) />
			<cfset contents.append("RewriteRule ^(.*)$ - [PT,L]" & lf) />
			<cfset contents.append(lf) />

			<!--- Add standard url rule (e.g. with event parameter) --->
			<cfset contents.append("#### Rewrite any URIs that start with the event parameter" & lf) />
			<cfset contents.append("RewriteRule ^" & rewriteBase & eventParameter & "(/.*)?$ " & rewriteBase & rewriteBaseFileName & "/" & eventParameter & "/$1 [PT,L]" & lf) />
			<cfset contents.append(lf) />

			<!--- Add standard url rule (e.g. with endpoint parameter) --->
			<cfset contents.append("#### Rewrite any URIs that start with the endpoint parameter" & lf) />
			<cfset contents.append("RewriteRule ^" & rewriteBase & endpointParameter & "(/.*)?$ " & rewriteBase & rewriteBaseFileName & "/" & endpointParameter & "/$1 [PT,L]" & lf) />
			<cfset contents.append(lf) />

			<!--- Add all the endpoint --->
			<cfset contents.append("#### Rewrite all base endpoints" & lf) />
			<cfloop from="1" to="#ArrayLen(endpointNames)#" index="i">
				<cfset contents.append("RewriteRule ^" & rewriteBase & endpointNames[i] & "(/.*)?$ " & rewriteBase & rewriteBaseFileName & "/" & endpointNames[i] & "$1 [PT,L]" & lf) />
			</cfloop>
			<cfset contents.append(lf) />

			<!--- Add all the routes --->
			<cfset contents.append("#### Rewrite all base URL routes" & lf) />
			<cfloop from="1" to="#ArrayLen(routeNames)#" index="i">
				<cfset route = getRoute(routeNames[i]) />
				<!---
				 Because the base has been defined we dont use it here. Additionally we can end the rule without the
				 trailing forward slash as many users may not type this. If a slash is found then we can also grab any
				 other params that may or may not be following it. This allows us to match the following type of urls:

				 news
				 news/
				 news/1
				 news/1/
				 newsArticle
				 newsArticle/
				 newsArticle/1
				 newsArticle/1/

				 And if someone happened to type in: newss they would be routed to index.cfm/event/newss where the
				 exception handling of the framework could divert the missing event name (provided newss didnt exist)
				 --->
				<cfset contents.append("RewriteRule ^" & rewriteBase & route.getUrlAlias() & "(/.*)?$ " & rewriteBase & rewriteBaseFileName & "/" & route.getUrlAlias() & "$1 [PT,L]" & lf) />
			</cfloop>
			<cfset contents.append(lf) />

			<!--- Add a catch all to run all request through Mach-II if it's not a real file and there is not index.cfm in the URL  --->
			<cfif getPropertyManager().getProperty("urlExcludeEventParameter", false)>
				<cfset contents.append("#### Catch all for all requests if not a real file and does not contain index.cfm" & lf) />
				<cfset contents.append("RewriteCond $1 !^index\.cfm" & lf) />
				<cfset contents.append("RewriteRule ^" & rewriteBase & "(.*)?$ " & rewriteBase & rewriteBaseFileName & "/$1 [PT,L]" & lf) />
				<cfset contents.append(lf) />
			</cfif>

			<!--- The ampersand in the middle of the append is so that CFEclipse does think this is invalid code --->
			<cfset contents.append('#### <cfsetting enablecfoutputonly="false"/></' & 'cfsilent>' & lf) />

			<!--- Write to file --->
			<cftry>
				<cffile action="write"
					file="#configFilePath#"
					output="#contents.toString()#"
					mode="777"
					attributes="normal" />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.RulesWritePermissions"
						message="Cannot write rewrite rules file to '#configFilePath#'. Does your CFML engine have write permissions to this directory?"
						detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
			</cftry>

		</cfif>
	</cffunction>

	<!---
	REDIRECT PERSIST
	--->
	<cffunction name="savePersistEventData" access="public" returntype="string" output="false"
		hint="Saves persisted event data and returns the persistId.">
		<cfargument name="eventArgs" type="struct" required="true"
			hint="A struct of event-args to persist." />

		<cfset var persistId = "" />
		<cfset var data = StructNew() />
		<cfset var preRedirectCallbacks = getPreRedirectCallbacks() />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(preRedirectCallbacks)#" index="i">
			<cfinvoke component="#preRedirectCallbacks[i].callback#"
				method="#preRedirectCallbacks[i].method#">
				<cfinvokeargument name="data" value="#data#" />
			</cfinvoke>
		</cfloop>

		<cfset data.eventArgs = arguments.eventArgs />

		<cfset persistId = getRequestRedirectPersist().save(data) />

		<cfif getPropertyManager().getProperty("redirectPersistParameterLocation") EQ "cookie">
			<cfcookie name="#getPropertyManager().getProperty("redirectPersistParameter")#" value="#persistId#" />
		</cfif>

		<cfreturn persistId />
	</cffunction>
	<cffunction name="readPersistEventData" access="public" returntype="struct" output="false"
		hint="Gets a persisted event by id if found in event args.">
		<cfargument name="eventArgs" type="struct" required="true"
			hint="The current eventArgs to append the redirect persist event args to via a reference." />

		<cfset var data = "" />
		<cfset var postRedirectCallbacks = getPostRedirectCallbacks() />
		<cfset var i = "" />
		<cfset var parameterId = getPropertyManager().getProperty("redirectPersistParameter") />

		<cfif getPropertyManager().getProperty("redirectPersistParameterLocation") EQ "cookie">
			<cfif StructKeyExists(cookie, parameterId)>
				<cfset arguments.eventArgs[parameterId] = cookie[parameterId] />
				<cfcookie name="#parameterId#" expires="now" />
			</cfif>
		</cfif>

		<cfset data = getRequestRedirectPersist().read(arguments.eventArgs) />
		
		<!--- If there is data, run post-redirect callbacks --->
		<cfif StructCount(data)>

			<cfloop from="1" to="#ArrayLen(postRedirectCallbacks)#" index="i">
				<cfinvoke component="#postRedirectCallbacks[i].callback#"
					method="#postRedirectCallbacks[i].method#">
					<cfinvokeargument name="data" value="#data#" />
				</cfinvoke>
			</cfloop>

			<cfreturn data.eventArgs />
		<cfelse>
			<cfreturn data />
		</cfif>
	</cffunction>

	<!---
	REQUEST CALLBACKS
	--->
	<cffunction name="addOnRequestEndCallback" access="public" returntype="void" output="false"
		hint="Adds an on request end callback to be run at the end of processing an event.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.onRequestEndCallbacks, arguments) />
	</cffunction>
	<cffunction name="removeOnRequestEndCallback" access="public" returntype="void" output="false"
		hint="Removes an onRequestEndCallback from the stack by passing in the callback object.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(variables.onRequestEndCallbacks)#" index="i">
			<cfif getUtils().assertSame(variables.onRequestEndCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.onRequestEndCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	<cffunction name="getOnRequestEndCallbacks" access="public" returntype="array" output="false"
		hints="Gets the on request end callbacks.">
		<cfreturn variables.onRequestEndCallbacks />
	</cffunction>

	<cffunction name="addPreRedirectCallback" access="public" returntype="void" output="false"
		hint="Adds a pre-redirect callback to be run before a redirect occurs.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.preRedirectCallbacks, arguments) />
	</cffunction>
	<cffunction name="removePreRedirectCallback" access="public" returntype="void" output="false"
		hint="Removes an preRedirect from the stack by passing in the callback object.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(variables.preRedirectCallbacks)#" index="i">
			<cfif getUtils().assertSame(variables.preRedirectCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.preRedirectCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	<cffunction name="getPreRedirectCallbacks" access="public" returntype="array" output="false"
		hints="Gets the pre-redirect callbacks.">
		<cfreturn variables.preRedirectCallbacks />
	</cffunction>

	<cffunction name="addPostRedirectCallback" access="public" returntype="void" output="false"
		hint="Adds a post-redirect callback to be run after a redirect occurs.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.postRedirectCallbacks, arguments) />
	</cffunction>
	<cffunction name="removePostRedirectCallback" access="public" returntype="void" output="false"
		hint="Removes an postRedirect from the stack by passing in the callback object.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(variables.postRedirectCallbacks)#" index="i">
			<cfif getUtils().assertSame(variables.postRedirectCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.postRedirectCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	<cffunction name="getPostRedirectCallbacks" access="public" returntype="array" output="false"
		hints="Gets the post-redirect callbacks.">
		<cfreturn variables.postRedirectCallbacks />
	</cffunction>

	<!---
	ROUTES
	--->
	<cffunction name="addRoute" access="public" returntype="void" output="false"
		hint="Adds a route by route name.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="route" type="MachII.framework.url.UrlRoute" required="true" />
		<cfargument name="overwrite" type="boolean" required="false" default="false" />

		<!--- Check for name conflicts if this is not an overwrite --->
		<cfif NOT arguments.overwrite>
			<cfif StructKeyExists(variables.routes,  arguments.routeName)>
				<cfthrow type="MachII.RequestManager.RouteNameConflict"
					message="A route named '#arguments.routeName#' is already defined. Please remove the route name conflict." />
			<cfelseif arguments.route.isUrlAliasDefined()
				AND StructKeyExists(variables.routeAliases, arguments.route.getUrlAlias())>
				<cfthrow type="MachII.RequestManager.RouteNameConflict"
					message="A route named '#arguments.routeName#' with an URL alias of '#arguments.route.getUrlAlias()#' is already defined. Please remove the route alias conflict." />
			</cfif>
		</cfif>

		<cfset variables.routes[arguments.routeName] = arguments.route />
		<cfset variables.routeAliases[arguments.route.getUrlAlias()] = arguments.routeName />
	</cffunction>
	<cffunction name="removeRoute" access="public" returntype="void" output="false"
		hint="Removes a route by route name.">
		<cfargument name="routeName" type="string" required="true"
			hint="The name of the route to remove." />
		<cfargument name="ownerId" type="string" required="false"
			hint="The owner id of the owner if the route. If defined, the route will only be removed if the owner id matches." />

		<cfset var route = getRoute(arguments.routeName) />

		<cfif NOT StructKeyExists(arguments, "ownerId") OR route.getOwnerId() EQ arguments.ownerId>
			<cfset StructDelete(variables.routes, arguments.routeName, false) />
			<cfset StructDelete(variables.routeAliases, route.getUrlAlias(), false) />
		</cfif>
	</cffunction>
	<cffunction name="getRoute" access="public" returntype="MachII.framework.url.UrlRoute" output="false"
		hint="Gets a route by route name.">
		<cfargument name="routeNameOrUrlAlias" type="string" required="true" />

		<cfset var routes = getRoutes() />

		<cfif StructKeyExists(routes, arguments.routeNameOrUrlAlias)>
			<cfreturn variables.routes[arguments.routeNameOrUrlAlias] />
		<cfelseif StructKeyExists(variables.routeAliases, arguments.routeNameOrUrlAlias)>
			<cfreturn variables.routes[variables.routeAliases[arguments.routeNameOrUrlAlias]] />
		<cfelse>
			<cfthrow type="MachII.RequestManager.NoRouteConfigured"
				message="No named route or route url alias of '#arguments.routeNameOrUrlAlias#' could be found." />
		</cfif>
	</cffunction>
	<cffunction name="getRoutes" access="public" returntype="struct" output="false"
		hint="Get all registered url routes.">
		<cfreturn variables.routes />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="parseNonRoute" access="private" returntype="struct" output="false"
		hint="Parses a non-route Url elements into request data.">
		<cfargument name="urlElements" type="array" required="true" />

		<cfset var value = "" />
		<cfset var i = 0 />
		<cfset var params = parseNonRouteModuleAndEvent(arguments.urlElements) />
		<cfset var elements = params["elements"] />
		<cfset var pairDelimiter = getPairDelimiter() />

		<!--- Remove elements array from returned params (returned here from parseNonRouteModuleAndEvent)--->
		<cfset StructDelete(params, "elements") />

		<cfif getSeriesDelimiter() EQ pairDelimiter>
			<cfloop from="1" to="#ArrayLen(elements)#" index="i" step="2">
				<cfif i + 1 LTE ArrayLen(elements) AND elements[i+1] NEQ "_-_NULL_-_">
					<cfset value = elements[i+1] />
				<cfelse>
					<cfset value = "" />
				</cfif>
				<cfset params[elements[i]] = value />
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#ArrayLen(elements)#" index="i">
				<cfif ListLen(elements[i], pairDelimiter) EQ 2>
					<cfset value = ListGetAt(elements[i], 2, pairDelimiter) />
				<cfelse>
					<cfset value = "" />
				</cfif>
				<cfset params[ListGetAt(elements[i], 1, pairDelimiter)] =  value />
			</cfloop>
		</cfif>
		<cfreturn params />
	</cffunction>

	<cffunction name="parseNonRouteModuleAndEvent" access="private" returntype="struct" output="false"
		hint="Parses the module and/or event name out of an array of non-route URL elements. Supports a moduleDelimiter that is the same as the seriesDelimiter (as with all slashes in URL).">
		<cfargument name="urlElements" type="array" required="true" />

		<cfset var i = 0 />
		<cfset var elements = arguments.urlElements />
		<cfset var params = StructNew() />
		<cfset var moduleNames = getModuleNames() />
		<cfset var hasEventParam = false />

		<cfif getUrlExcludeEventParameter()>
			<cfset i = 1 />
			<cfif ArrayLen(arguments.urlElements) MOD 2>
				<cfset hasEventParam = true />
			</cfif>
		<cfelse>
			<!---
				Get position in array of event parameter
				The `arrayFind` could be CFML or Java based depending on CFML engine
			--->
			<cfset i = arrayFind(elements, getEventParameter()) />
			<cfif i GT 0>
				<cfset ArrayDeleteAt(elements, i) />
				<cfset hasEventParam = true />
			</cfif>
		</cfif>

		<cfif i GT 0 AND ArrayLen(elements) GTE i>
			<!--- Module and/or event has to be the first element --->

			<!--- Using moduleNames.contains() is case sensitive so convert to lower since moduleNames is all lower --->
			<cfif moduleNames.contains(LCase(elements[i]))>
				<cfset params[getEventParameter()] = elements[i] & getModuleDelimiter() />
				<cfset ArrayDeleteAt(elements, i) />
				<cfif ArrayLen(elements) GTE i AND getSeriesDelimiter() EQ getModuleDelimiter()>
					<!--- Any next element has to be an event name, append it to module name --->
					<cfset params[getEventParameter()] = params[getEventParameter()] & elements[i] />
					<cfset ArrayDeleteAt(elements, i) />
				</cfif>
			<cfelseif hasEventParam>
				<!--- First element is an event or module:event with moduleDelimiter than is different than seriesDelimiter --->
				<cfset params[getEventParameter()] = elements[i] />
				<cfset ArrayDeleteAt(elements, i) />
			</cfif>
		</cfif>

		<!--- Pass the remaining elements back to caller. --->
		<cfset params["elements"] = elements />

		<cfreturn params />
	</cffunction>

	<cffunction name="parseRoute" access="private" returntype="struct" output="false"
		hint="Parses a route by route name.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="urlElements" type="array" required="true" />

		<cfset var route = getRoute(arguments.routeName) />
		<cfset var routeParams = 0 />
		<cfset var rH = getRequestHandler() />

		<!--- Put current route params in the request scope so we can grab them in buildCurrentUrl() --->
		<cfset routeParams = route.parseRoute(arguments.urlElements, getModuleDelimiter(), getEventParameter()) />
		<cfset rH.setCurrentRouteName(arguments.routeName) />
		<cfset rH.setCurrentRouteParams(routeParams) />

		<cfreturn routeParams />
	</cffunction>

	<cffunction name="checkRouteParameterNames" access="private" returntype="void" output="false"
		hint="Checks for collisions between route names and event handler names.">
		<cfset var route = 0 />
		<cfset var routes = getRoutes() />
		<cfset var index = "" />

		<cfloop list="#StructKeyList(routes)#" index="index">
			<cfset route = routes[index] />

			<!--- Check to see if any parameter names match the eventParameter --->
			<cfif ListFindNoCase(route.getAllParameterNames(), getEventParameter()) gt 0>
				<cfthrow type="MachII.RequestManager.RouteParameterNameConflict"
					message="A route named '#index#' with an URL alias of '#route.getUrlAlias()#' has a parameter called '#getEventParameter()#' which is same as the event parameter name. Route parameters can not have the same name as the event parameter." />
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="_arrayFind_java" access="private" returntype="numeric" output="false"
		hint="A simple ArrayFind using Java for systems that do not support the built-in tag.">
		<cfargument name="object" type="array" required="true" />
		<cfargument name="search" type="any" required="true" />
		<cfreturn arguments.object.indexOf(arguments.search) + 1 />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="private" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setPropertyManager" access="private" returntype="void" output="false">
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		<cfset variables.propertyManager = arguments.propertyManager />
	</cffunction>
	<cffunction name="getPropertyManager" access="private" returntype="MachII.framework.PropertyManager" output="false">
		<cfreturn variables.propertyManager />
	</cffunction>

	<cffunction name="setUtils" access="private" returntype="void" output="false">
		<cfargument name="utils" type="MachII.util.Utils" required="true" />
		<cfset variables.utils = arguments.utils />
	</cffunction>
	<cffunction name="getUtils" access="private" returntype="MachII.util.Utils" output="false">
		<cfreturn variables.utils />
	</cffunction>

	<cffunction name="setEventParameter" access="private" returntype="void" output="false">
		<cfargument name="eventParameter" type="string" required="true" />
		<cfset variables.eventParameter = arguments.eventParameter />
		<cfset checkRouteParameterNames() />
	</cffunction>
	<cffunction name="getEventParameter" access="private" returntype="string" output="false">
		<cfreturn variables.eventParameter />
	</cffunction>

	<cffunction name="setParameterPrecedence" access="private" returntype="void" output="false">
		<cfargument name="parameterPrecedence" type="string" required="true" />
		<cfset variables.parameterPrecedence = arguments.parameterPrecedence />
	</cffunction>
	<cffunction name="getParameterPrecedence" access="private" returntype="string" output="false">
		<cfreturn variables.parameterPrecedence />
	</cffunction>

	<cffunction name="setParseSes" access="private" returntype="void" output="false">
		<cfargument name="parseSes" type="string" required="true" />
		<cfset variables.parseSes = arguments.parseSes />
	</cffunction>
	<cffunction name="getParseSes" access="private" returntype="string" output="false">
		<cfreturn variables.parseSes />
	</cffunction>

	<cffunction name="setUrlExcludeEventParameter" access="private" returntype="void" output="false">
		<cfargument name="urlExcludeEventParameter" type="boolean" required="true" />
		<cfset variables.urlExcludeEventParameter = arguments.urlExcludeEventParameter />
	</cffunction>
	<cffunction name="getUrlExcludeEventParameter" access="private" returntype="boolean" output="false">
		<cfreturn variables.urlExcludeEventParameter />
	</cffunction>

	<cffunction name="setQueryStringUrls" access="private" returntype="void" output="false">
		<cfargument name="queryStringUrls" type="boolean" required="true" />
		<cfset variables.queryStringUrls = arguments.queryStringUrls />
	</cffunction>
	<cffunction name="isQueryStringUrls" access="private" returntype="boolean" output="false">
		<cfreturn variables.queryStringUrls />
	</cffunction>

	<cffunction name="setDefaultUrlBase" access="private" returntype="void" output="false">
		<cfargument name="defaultUrlBase" type="string" required="true" />
		
		<cfif arguments.defaultUrlBase NEQ "/">
			<cfset variables.defaultUrlBase = arguments.defaultUrlBase />
		<cfelse>
			<cfset variables.defaultUrlBase = "" />
		</cfif>
	</cffunction>
	<cffunction name="getDefaultUrlBase" access="private" returntype="string" output="false">
		<cfreturn variables.defaultUrlBase />
	</cffunction>
	<!--- TODO: This needs to be completed --->
	<cffunction name="getDefaultUrlBase_dynamic" access="private" returntype="string" output="false">
		<cfreturn "http://" & cgi.SERVER_NAME & variables.defaultUrlBase />
	</cffunction>

	<cffunction name="setDefaultUrlSecureBase" access="private" returntype="void" output="false">
		<cfargument name="defaultUrlSecureBase" type="string" required="true" />
		
		<cfif arguments.defaultUrlSecureBase NEQ "/">
			<cfset variables.defaultUrlSecureBase = arguments.defaultUrlSecureBase />
		<cfelse>
			<cfset variables.defaultUrlSecureBase = "" />
		</cfif>
	</cffunction>
	<cffunction name="getDefaultUrlSecureBase" access="private" returntype="string" output="false">
		<cfreturn variables.defaultUrlSecureBase />
	</cffunction>
	<!--- TODO: This needs to be completed --->
	<cffunction name="getDefaultUrlSecureBase_dynamic" access="private" returntype="string" output="false">
		<cfreturn "https://" & cgi.SERVER_NAME & variables.defaultUrlSecureBase />
	</cffunction>

	<cffunction name="setQueryStringDelimiter" access="private" returntype="void" output="false">
		<cfargument name="queryStringDelimiter" type="string" required="true" />
		<cfset variables.queryStringDelimiter = arguments.queryStringDelimiter />
	</cffunction>
	<cffunction name="getQueryStringDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.queryStringDelimiter />
	</cffunction>

	<cffunction name="setSeriesDelimiter" access="private" returntype="void" output="false">
		<cfargument name="seriesDelimiter" type="string" required="true" />
		<cfset variables.seriesDelimiter = arguments.seriesDelimiter />
	</cffunction>
	<cffunction name="getSeriesDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.seriesDelimiter />
	</cffunction>

	<cffunction name="setPairDelimiter" access="private" returntype="void" output="false">
		<cfargument name="pairDelimiter" type="string" required="true" />
		<cfset variables.pairDelimiter = arguments.pairDelimiter />
	</cffunction>
	<cffunction name="getPairDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.pairDelimiter />
	</cffunction>

	<cffunction name="setModuleDelimiter" access="private" returntype="void" output="false">
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfset variables.moduleDelimiter = arguments.moduleDelimiter />
	</cffunction>
	<cffunction name="getModuleDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.moduleDelimiter />
	</cffunction>

	<cffunction name="setModuleNames" access="private" returntype="void" output="false">
		<cfargument name="moduleNames" type="array" required="true" />
		<cfset var names = ArrayNew(1) />
		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(arguments.moduleNames)#" index="i">
			<cfset names[i] = LCase(arguments.moduleNames[i]) />
		</cfloop>

		<cfset variables.moduleNames = names />
	</cffunction>
	<cffunction name="getModuleNames" access="private" returntype="array" output="false">
		<cfreturn variables.moduleNames />
	</cffunction>

	<cffunction name="setMaxEvents" access="private" returntype="void" output="false">
		<cfargument name="maxEvents" type="numeric" required="true" />
		<cfset variables.maxEvents = arguments.maxEvents />
	</cffunction>
	<cffunction name="getMaxEvents" access="private" returntype="numeric" output="false">
		<cfreturn variables.maxEvents />
	</cffunction>

	<cffunction name="setRequestRedirectPersist" access="public" returntype="void" output="false">
		<cfargument name="requestRedirectPersist" type="any" required="true" />
		<cfset variables.requestRedirectPersist = arguments.requestRedirectPersist />
	</cffunction>
	<cffunction name="getRequestRedirectPersist" access="public" returntype="any" output="false">
		<cfreturn variables.requestRedirectPersist />
	</cffunction>

	<cffunction name="setRewriteConfigFileOn" access="public" returntype="void" output="false">
		<cfargument name="rewriteConfigFileOn" type="boolean" required="true" />
		<cfset variables.rewriteConfigFileOn = arguments.rewriteConfigFileOn />
	</cffunction>
	<cffunction name="getRewriteConfigFileOn" access="public" returntype="boolean" output="false">
		<cfreturn variables.rewriteConfigFileOn />
	</cffunction>

	<cffunction name="setRewriteConfigFile" access="public" returntype="void" output="false">
		<cfargument name="rewriteConfigFile" type="string" required="true" />
		<cfset variables.rewriteConfigFile = arguments.rewriteConfigFile />
	</cffunction>
	<cffunction name="getRewriteConfigFile" access="public" returntype="string" output="false">
		<cfreturn variables.rewriteConfigFile />
	</cffunction>

	<cffunction name="setRewriteBaseFileName" access="public" returntype="void" output="false">
		<cfargument name="rewriteBaseFileName" type="string" required="true" />
		<cfset variables.rewriteBaseFileName = arguments.rewriteBaseFileName />
	</cffunction>
	<cffunction name="getRewriteBaseFileName" access="public" returntype="string" output="false">
		<cfreturn variables.rewriteBaseFileName />
	</cffunction>

	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog("MachII.framework.RequestManager") />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>