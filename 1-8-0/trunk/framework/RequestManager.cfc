<!---
License:
Copyright 2009 GreatBizTools, LLC

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
	<cfset variables.requestHandler = "" />
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
	<cfset variables.log = "" />
	<cfset variables.routes = StructNew() />
	<cfset variables.routeAliases = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="Sets the base AppManager." />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setLog(arguments.appManager.getLogFactory()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures properties required to manage requests.">

		<cfset var urlDelimiters = "" />	

		<!--- Setup defaults --->
		<cfset urlDelimiters = getPropertyManager().getProperty("urlDelimiters") />
		<cfset setDefaultUrlBase(getPropertyManager().getProperty("urlBase")) />
		<cfset setEventParameter(getPropertyManager().getProperty("eventParameter")) />
		<cfset setParameterPrecedence(getPropertyManager().getProperty("parameterPrecedence")) />
		<cfset setParseSES(getPropertyManager().getProperty("urlParseSES")) />
		<cfset setUrlExcludeEventParameter(getPropertyManager().getProperty("urlExcludeEventParameter")) />
		<cfset setModuleDelimiter(getPropertyManager().getProperty("moduleDelimiter")) />
		<cfset setMaxEvents(getPropertyManager().getProperty("maxEvents")) />
		
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

		<cfset var redirectToUrl =  ""/>
		<cfset var persistId =  "" />
		<cfset var redirectPersistParam = getAppManager().getPropertyManager().getProperty("redirectPersistParameter", "persistId") />
		
		<!--- Delete the event name from the args if it exists so a redirect loop doesn't occur --->
		<cfset StructDelete(arguments.eventArgs, getEventParameter(), FALSE) />
		<cfset StructDelete(arguments.persistArgs, getEventParameter(), FALSE) />
		
		<cfif arguments.persist>
			<cfset persistId = savePersistEventData(arguments.persistArgs) />
		</cfif>
		
		<!--- Add the persistId parameter to the url args if persist is required --->
		<cfif arguments.persist AND getAppManager().getPropertyManager().getProperty("redirectPersistParameterLocation") NEQ "cookie">
			<cfset arguments.eventArgs[redirectPersistParam] = persistId />
		</cfif>
		
		<cfset redirectToUrl = buildUrl(arguments.moduleName, arguments.eventName, arguments.eventArgs) />
		
		<cfset redirectUrl(redirectToUrl, arguments.statusType) />
	</cffunction>
	
	<cffunction name="redirectRoute" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to a route.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="routeArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="persist" type="boolean" required="false" default="false" />
		<cfargument name="persistArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="statusType" type="string" required="false" default="" />

		<cfset var redirectToUrl = "" />
		<cfset var persistId = "" />
		
		<!--- Delete the event name from the args if it exists so a redirect loop doesn't occur --->
		<cfset StructDelete(arguments.routeArgs, getEventParameter(), FALSE) />
		<cfset StructDelete(arguments.persistArgs, getEventParameter(), FALSE) />
		
		<cfif arguments.persist>
			<cfset persistId = savePersistEventData(arguments.persistArgs) />
		</cfif>
		
		<cfset redirectToUrl = buildRouteUrl(arguments.routeName, arguments.routeArgs) />

		<cfset redirectUrl(redirectToUrl, arguments.statusType) />
	</cffunction>
	
	<cffunction name="redirectUrl" access="public" returntype="void" output="false">
		<cfargument name="redirectUrl" type="string" required="true"
			hint="An URL to redirect to." />
		<cfargument name="statusType" type="string" required="false" default="temporary"
			hint="The status type to use. Valid option: 'permanent' (301), 'prg' (303 - See Other), 'temporary' (302) [default option]" />

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
		<cfset var log = getLog() />
		
		<!--- Automatically remove the Mach II redirect persist id from the url params --->
		<cfset arguments.urlParametersToRemove = ListAppend(arguments.urlParametersToRemove, "persistId")>
		
		<cfloop collection="#url#" item="key">
			<cfif NOT StructKeyExists(params, key) AND key neq eventParameterName 
				AND NOT ListFindNoCase(arguments.urlParametersToRemove, key)>
				<cfset arguments.urlParameters = ListAppend(arguments.urlParameters, "#key#=#url[key]#", "|") />
			</cfif>
		</cfloop>
		
		<cfif Len(routeName)>
			<cfset log.debug("Building route url for route '#routeName#'") />

			<cfreturn buildRouteUrl(routeName, getRequestHandler().getCurrentRouteParams(), arguments.urlParameters) />
		<cfelseif StructCount(currentSESParams)>
			<cfloop collection="#currentSESParams#" item="key">
				<cfif key eq getEventParameter()>
					<cfset eventName = currentSESParams[key] />
					<cfif ListLen(eventName, moduleDelimiter) GT 1>
						<cfset parsedModuleName = ListGetAt(eventName, 1, moduleDelimiter) />
						<cfset eventName = ListGetAt(eventName, 2, moduleDelimiter) />
					<cfelse>
						<cfset parsedModuleName = arguments.moduleName />
					</cfif>
				<cfelseif NOT StructKeyExists(params, key) AND key neq eventParameterName
					AND NOT ListFindNoCase(arguments.urlParametersToRemove, key)>
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
		<cfargument name="urlBase" type="string" required="false" default="#getDefaultUrlBase()#"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		
		<cfset var builtUrl = "" />
		<cfset var queryString = "" />
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var value = "" />
		<cfset var i = "" />
		<cfset var keyList = StructKeyList(params) />
		<cfset var seriesDelimiter = getSeriesDelimiter() />
		<cfset var pairDelimiter = getPairDelimiter() />
		<cfset var parseSes = getParseSes() />

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
		<cfargument name="urlBase" type="string" required="false" default="#getDefaultUrlBase()#"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var parsedQueryStringParams = getUtils().parseAttributesIntoStruct(arguments.queryStringParameters) />
		<cfset var route = getRoute(arguments.routeName) />	
		
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

		<!--- Remove the query string delimiter --->
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
					<cfthrow type="MachII.framework.UrlRouteNotDefined"  
						message="Could not find a configured url route with the url alias of '#names[1]#'"
						detail="Routes can only be announced from the browser url using url alias. Route names are only used when referencing routes from within the framework such as BuildRouteUrl(). Cleaned path_info='#arguments.pathInfo#'" />
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
					<cfthrow type="MachII.framework.UrlRouteNotDefined"  
						message="Could not find a configured url route with the url alias of '#names[1]#'"
						detail="Routes can only be announced from the browser url using url alias. Route names are only used when referencing routes from within the framework such as BuildRouteUrl(). Cleaned path_info='#arguments.pathInfo#'" />
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn params />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTIL
	--->
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
		
		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.onRequestEndCallbacks)#" index="i">
			<cfif utils.assertSame(variables.onRequestEndCallbacks[i].callback, arguments.callback)>
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
		
		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.preRedirectCallbacks)#" index="i">
			<cfif utils.assertSame(variables.preRedirectCallbacks[i].callback, arguments.callback)>
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
		
		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.postRedirectCallbacks)#" index="i">
			<cfif utils.assertSame(variables.postRedirectCallbacks[i].callback, arguments.callback)>
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
		<cfargument name="route" type="MachII.framework.UrlRoute" required="true" />
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
	<cffunction name="getRoute" access="public" returntype="MachII.framework.UrlRoute" output="false"
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
	PROTECTED FUNCTIONS
	--->
	<cffunction name="parseNonRoute" access="private" returntype="struct" output="false"
		hint="Parses a non-route Url elements into request data.">
		<cfargument name="urlElements" type="array" required="true" />
		
		<cfset var value = "" />
		<cfset var i = 0 />
		<cfset var names = arguments.urlElements />
		<cfset var params = StructNew() />
		<cfset var pairDelimiter = getPairDelimiter() />
		
		<!---
		If the event name was excluded from the URL and there are an odd number of
		URL elements then pop off the first element
		--->
		<cfif getUrlExcludeEventParameter() AND ArrayLen(arguments.urlElements) MOD 2>
			<cfset params[getEventParameter()] = arguments.urlElements[1] />
			<cfset ArrayDeleteAt(names, 1) />
		</cfif>
	
		<cfif getSeriesDelimiter() EQ pairDelimiter>
			<cfloop from="1" to="#ArrayLen(names)#" index="i" step="2">
				<cfif i + 1 LTE ArrayLen(names) AND names[i+1] NEQ "_-_NULL_-_">
					<cfset value = names[i+1] />
				<cfelse>
					<cfset value = "" />
				</cfif>
				<cfset params[names[i]] = value />
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#ArrayLen(names)#" index="i">
				<cfif ListLen(names[i], pairDelimiter) EQ 2>
					<cfset value = ListGetAt(names[i], 2, pairDelimiter) />
				<cfelse>
					<cfset value = "" />
				</cfif>
				<cfset params[ListGetAt(names[i], 1, pairDelimiter)] =  value />
			</cfloop>
		</cfif>
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="parseRoute" access="private" returntype="struct" output="false"
		hint="Parses a route by route name.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="urlElements" type="array" required="true" />
		
		<cfset var route = getRoute(arguments.routeName) />
		<cfset var routeParams = 0 />
		
		<!--- Put current route params in the request scope so we can grab them in buildCurrentUrl() --->
		<cfset routeParams = route.parseRoute(arguments.urlElements, getModuleDelimiter(), getEventParameter()) />
		<cfset getRequestHandler().setCurrentRouteName(arguments.routeName) />
		<cfset getRequestHandler().setCurrentRouteParams(route.parseRouteParams(arguments.urlElements)) />
		
		<cfreturn routeParams />
	</cffunction>
	
	<cffunction name="checkRouteParameterNames" access="private" returntype="void" output="false">
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
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="private" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="getPropertyManager" access="private" returntype="MachII.framework.PropertyManager" output="false">
		<cfreturn getAppManager().getPropertyManager() />
	</cffunction>
	
	<cffunction name="getUtils" access="private" returntype="MachII.util.Utils" output="false">
		<cfreturn getAppManager().getUtils() />
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
		<cfset variables.defaultUrlBase = arguments.defaultUrlBase />
	</cffunction>
	<cffunction name="getDefaultUrlBase" access="private" returntype="string" output="false">
		<cfreturn variables.defaultUrlBase />
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
	
	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>