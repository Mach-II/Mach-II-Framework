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

Created version: 1.9.0

Notes:

--->
<cfcomponent
	displayname="EndpointManager"
	output="false"
	hint="Manages endpoints.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentEndpointManager = "" />
	<cfset variables.utils = "" />
	<cfset variables.log = "" />
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	<cfset variables.endpoints = StructNew() />
	<cfset variables.endpointContextPathMap = StructNew() />
	<cfset variables.localEndpointNames = StructNew() />
	<cfset variables.baseProxyTarget = "" />

	<!---
	CONSTANTS
	--->
	<cfset variables.ENDPOINT_SHORTCUTS = StructNew() />
	<cfset variables.ENDPOINT_SHORTCUTS["file"] = "MachII.endpoints.file.BaseEndpoint" />
	<cfset variables.ENDPOINT_STOP_CLASS = "MachII.endpoints.AbstractEndpoint" />

	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EndpointManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="Sets the base AppManager." />

		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getEndpointManager()) />

			<!--- Share the endpoints struct between the parent and child since they are global not module specific --->
			<cfset setEndpoints(getParent().getEndpoints()) />
			<cfset setEndpointContextPathMap(getParent().getEndpointContextPathMap()) />
		</cfif>

		<cfset setUtils(arguments.appManager.getUtils()) />
		<cfset setLog(arguments.appManager.getLogFactory()) />

		<!--- Setup for duplicate for performance --->
		<cfset variables.baseProxyTarget = CreateObject("component",  "MachII.framework.BaseProxy") />

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var endpointNodes = ArrayNew(1) />
		<cfset var endpointName = "" />
		<cfset var endpointType = "" />
		<cfset var endpointParams = "" />

		<cfset var paramsNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for endpoints --->
		<cfif NOT arguments.override>
			<cfset endpointNodes = XMLSearch(arguments.configXML, "mach-ii/endpoints/endpoint") />
		<cfelse>
			<cfset endpointNodes = XMLSearch(arguments.configXML, ".//endpoints/endpoint") />
		</cfif>

		<!--- Set the endpoints from the XML file. --->
		<cfloop from="1" to="#ArrayLen(endpointNodes)#" index="i">
			<cfset endpointName = endpointNodes[i].xmlAttributes["name"] />
			<cfset endpointType = endpointNodes[i].xmlAttributes["type"] />

			<!--- Set the Endpoint's parameters. --->
			<cfset endpointParams = StructNew() />

			<!--- Parse all the parameters --->
			<cfif StructKeyExists(endpointNodes[i], "parameters")>
				<cfset paramsNodes = endpointNodes[i].parameters.xmlChildren />
				<cfloop from="1" to="#ArrayLen(paramsNodes)#" index="j">
					<cfset paramName = paramsNodes[j].XmlAttributes["name"] />
					<cftry>
						<cfset paramValue = utils.recurseComplexValues(paramsNodes[j]) />
						<cfcatch type="any">
							<cfthrow type="MachII.framework.InvalidPropertyXml"
								message="Xml parsing error for the endpoint named '#endpointName#'." />
						</cfcatch>
					</cftry>
					<cfset endpointParams[paramName] = paramValue />
				</cfloop>
			</cfif>

			<!--- Set the property (allowable property names ared checked by setProperty() method so no check needed here)--->
			<cfset loadEndpoint(endpointName, endpointType, endpointParams, arguments.override) />
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the endpoints.">

		<cfset var appManager = getAppManager() />
		<cfset var anEndpoint = "" />
		<cfset var key = "" />

		<cfset setEndpointParameter(appManager.getPropertyManager().getProperty("endpointParameter")) />

		<cfloop collection="#variables.localEndpointNames#" item="key">
			<cfset anEndpoint = getEndpointByName(key) />
			<cfset appManager.onObjectReload(anEndpoint) />
			<cfset anEndpoint.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures all the endpoints.">

		<cfset var anEndpoint = "" />
		<cfset var key = "" />

		<cfloop collection="#variables.localEndpointNames#" item="key">
			<cfset anEndpoint = getEndpointByName(key) />
			<cfset anEndpoint.deconfigure() />
			<cfset removeEndpointByName(key) />
		</cfloop>
	</cffunction>

	<cffunction name="buildEndpointContextPathMap" access="private" returntype="struct" output="false"
		hint="Builds a map of context paths and endpoint names.">

		<cfset var endpointContextPathMap = StructNew() />
		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />
		<cfset var contextPath = "" />

		<cfloop collection="#endpoints#" item="key">
			<cfset contextPath = endpoints[key].getParameter("contextPath") />

			<cfif Len(contextPath)>
				<cfset endpointContextPathMap[contextPath] = key />
			</cfif>
		</cfloop>

		<cfset setEndpointContextPathMap(endpointContextPathMap) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - REQUEST HANDLING
	--->
	<cffunction name="isEndpointRequest" access="package" returntype="boolean" output="false"
		hint="Checks if the current request is an endpoint request.">
		<cfargument name="eventArgs" type="struct" required="true"
			hint="The incoming event args.">

		<cfset var firstUrlItem = ListFirst(cgi.PATH_INFO, "/") />

		<cfif StructKeyExists(variables.endpointContextPathMap, cgi.PATH_INFO)>
			<!--- The entire path info matched one of the endpoint contextPath parameters. --->
			<cfset arguments.eventArgs[getEndpointParameter()] = variables.endpointContextPathMap[cgi.PATH_INFO] />
			<cfset variables.log.debug("EndpointManager.isEndpointRequest(): Matched path '#cgi.PATH_INFO#' to endpoint.", arguments.eventArgs) />
			<cfreturn true />
		<cfelseif StructKeyExists(variables.endpoints, firstUrlItem)>
			<!--- The first part of the URI matched an endpoint name. --->
			<cfset arguments.eventArgs[getEndpointParameter()] = firstUrlItem />
			<cfset variables.log.debug("EndpointManager.isEndpointRequest(): Matched first URL item '#firstUrlItem#' to endpoint.", arguments.eventArgs) />
			<cfreturn true />
		<cfelseif StructKeyExists(arguments.eventArgs, getEndpointParameter())>
			<!--- The URL contains the endpoint parameter. --->
			<cfset variables.log.debug("EndpointManager.isEndpointRequest(): Endpoint parameter provided in URL.", arguments.eventArgs) />
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="handleEndpointRequest" access="public" returntype="void" output="true"
		hint="Handles an endpoint request.">
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="The events args needed to complete the request." />

		<cfset var event = CreateObject("component", "MachII.framework.Event").init(args:arguments.eventArgs) />
		<cfset var endpoint = "" />
		<cfset var exception = "" />

		<!--- Event is always in request scope --->
		<cfset request.event = event />

		<cftry>
			<cfset endpoint = getEndpointByName(event.getArg(getEndpointParameter())) />

			<cfif endpoint.isPreProcessDefined()>
				<cfset endpoint.preProcess(event) />
			</cfif>

			<cfif endpoint.isOnAuthenticateDefined()>
				<!--- Only run onAuthenticate() if the endpoint defines an isAuthentionRequired() method and returns true --->
				<cfif endpoint.isAuthenticationRequiredDefined()>
					<cfif endpoint.isAuthenticationRequired(event)>
						<cfset endpoint.onAuthenticate(event) />
					</cfif>
				<!--- isAuthenticationRequired() is not definedso by default run the onAuthenticate method because we don't know --->
				<cfelse>
					<cfset endpoint.onAuthenticate(event) />
				</cfif>
			</cfif>

			<cfset endpoint.handleRequest(event) />

			<cfif endpoint.isPostProcessDefined()>
				<cfset endpoint.postProcess(event) />
			</cfif>

			<cfcatch type="MachII.endpoints.EndpointNotDefined">
				<!--- No endpoint so send a 404 --->
				<cfheader statuscode="404" statustext="Not Found" />
				<cfheader name="machii.endpoint.error" value="#cfcatch.message#" />
				<cfset variables.log.error(cfcatch.message, event.getArgs()) />
				<cfsetting enablecfoutputonly="false" /><cfoutput>#cfcatch.message#</cfoutput><cfsetting enablecfoutputonly="true" />
			</cfcatch>
			<cfcatch type="any">
				<!--- Wrap the catch --->
				<cfset exception = CreateObject("component", "MachII.util.Exception").wrapException(cfcatch) />
				<cfset event.setArg("exception", exception) />

				<!--- Handle the exception --->
				<cfset endpoint.onException(event, exception) />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="buildEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an endpoint specific url.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of the target endpoint." />
		<cfargument name="urlParameters" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />

		<cfset var endpoint = getEndpointByName(arguments.endpointName) />
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />

		<cfreturn endpoint.buildEndpointUrl(argumentcollection=params) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getEndpointByName" access="public" returntype="MachII.endpoints.AbstractEndpoint" output="false"
		hint="Gets a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to get." />

		<cfif isEndpointDefined(arguments.endpointName)>
			<cfreturn variables.endpoints[arguments.endpointName] />
		<cfelse>
			<cfthrow type="MachII.endpoints.EndpointNotDefined"
				message="Endpoint named '#arguments.endpointName#' is not defined."
				detail="Available endpoints: '#ArrayToList(getEndpointNames())#'" />
		</cfif>
	</cffunction>

	<cffunction name="addEndpoint" access="public" returntype="void" output="false"
		hint="Registers a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to add." />
		<cfargument name="endpoint" type="MachII.endpoints.AbstractEndpoint" required="true"
			hint="A reference to the endpoint." />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false"
			hint="A boolean to allow an already managed endpoint to be overrided with a new one. Defaults to false." />

		<cfset var currEndpoint = "" />

		<cfif NOT arguments.overrideCheck AND isEndpointDefined(arguments.endpointName)>
			<cfset currEndpoint = getEndpointByName(arguments.endpointName) />

			<!--- If the endpoint being added is from the same module overwrite --->
			<cfif currEndpoint.getAppManager().getModuleName() EQ getAppManager().getModuleName()>
				<cfset variables.endpoints[arguments.endpointName] = arguments.endpoint />
				<cfset variables.localEndpointNames[arguments.endpointName] = ""  />
			<cfelse>
				<cfthrow type="MachII.endpoints.EndpointAlreadyDefined"
					message="An endpoint with name '#arguments.endpointName#' is already registered." />
			</cfif>
		<cfelse>
			<cfset variables.endpoints[arguments.endpointName] = arguments.endpoint />
			<cfset variables.localEndpointNames[arguments.endpointName] = ""  />
		</cfif>
	</cffunction>

	<cffunction name="removeEndpointByName" access="public" returntype="void" output="false"
		hint="Removes a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to get." />

		<cfif isEndpointDefined(arguments.endpointName)>
			<cfset StructDelete(variables.endpointContextPathMap, getEndpointByName(arguments.endpointName).getParameter("contextPath")) />
			<cfset StructDelete(variables.endpoints, arguments.endpointName, false) />
		</cfif>
	</cffunction>

	<cffunction name="isEndpointDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a endpoint is registered with the specified name. Does NOT check parent.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint to check." />
		<cfreturn StructKeyExists(variables.endpoints, arguments.endpointName) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="loadEndpoint" access="public" returntype="void" output="false"
		hint="Loads an endpoint and adds the endpoint to the manager.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint." />
		<cfargument name="endpointType" type="string" required="true"
			hint="Dot path to the endpoint." />
		<cfargument name="endpointParameters" type="struct" required="false" default="#StructNew()#"
			hint="Configuration parameters for the endpoint." />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false"
			hint="A boolean to allow an already managed endpoint to be overridden with a new one. Defaults to false." />

		<cfset var endpoint = "" />
		<cfset var baseProxy = "" />

		<!--- Resolve if a shortcut --->
		<cfset arguments.endpointType = resolveEndTypeShortcut(arguments.endpointType) />
		<!--- Ensure type is correct in parameters (where it is duplicated) --->
		<cfset arguments.endpointParameters.type = arguments.endpointType />
		<cfset arguments.endpointParameters.name = arguments.endpointName />

		<!--- Create a context path if not defined --->
		<cfif NOT StructKeyExists(arguments.endpointParameters, "contextPath")>
			<cfset arguments.endpointParameters.contextPath = "/" & arguments.endpointName & "/index.cfm" />
		</cfif>

		<!--- Create the endpoint --->
		<cftry>
			<cfset endpoint = CreateObject("component", arguments.endpointType).init(getAppManager(), arguments.endpointParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ arguments.endpointType>
					<cfthrow type="MachII.endpoints.CannotFindEndpoint"
						message="Cannot find an endpoint CFC with type of '#arguments.endpointType#' for the endpoint named '#arguments.endpointName#'."
						detail="Please check that the endpoints exists and that there is not a misconfiguration." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfset endpoint.setIsPreProcessDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="preProcess"', true, variables.ENDPOINT_STOP_CLASS))) />
		<cfset endpoint.setIsPostProcessDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="postProcess"', true, variables.ENDPOINT_STOP_CLASS))) />
		<cfset endpoint.setIsOnAuthenticateDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="onAuthenticate"', true, variables.ENDPOINT_STOP_CLASS))) />
		<cfset endpoint.setIsAuthenticationRequiredDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="isAuthenticationRequired"', true, variables.ENDPOINT_STOP_CLASS))) />

		<cfset baseProxy = Duplicate(variables.baseProxyTarget).init(endpoint, arguments.endpointType, arguments.endpointParameters) />
		<cfset endpoint.setProxy(baseProxy) />

		<cfset addEndpoint(arguments.endpointName, endpoint, arguments.overrideCheck) />
	</cffunction>

	<cffunction name="resolveEndTypeShortcut" access="public" returntype="string" output="false"
		hint="Resolves an endpoint type shorcut and returns the passed value if no match is found.">
		<cfargument name="endpointType" type="string" required="true"
			hint="Dot path to the endpoint." />

		<cfif StructKeyExists(variables.ENDPOINT_SHORTCUTS, arguments.endpointType)>
			<cfreturn variables.ENDPOINT_SHORTCUTS[arguments.endpointType] />
		<cfelse>
			<cfreturn arguments.endpointType />
		</cfif>
	</cffunction>

	<cffunction name="getEndpointNames" access="public" returntype="array" output="false"
		hint="Returns an array of endpoint names.">
		<cfreturn StructKeyArray(variables.endpoints) />
	</cffunction>

	<cffunction name="getLocalEndpointNames" access="public" returntype="array" output="false"
		hint="Returns an array of local endpoint names.">
		<cfreturn StructKeyArray(variables.localEndpointNames) />
	</cffunction>

	<cffunction name="containsEndpoints" access="public" returntype="boolean" output="false"
		hint="Returns a boolean of on whether or not there are any registered endpoints.">
		<cfreturn StructCount(variables.endpoints) GT 0 />
	</cffunction>

	<cffunction name="reloadEndpoint" access="public" returntype="void" output="false"
		hint="Reloads an endpoint.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint to reload." />

		<cfset var newEndpoint = "" />
		<cfset var currentEndpoint = getEndpointByName(arguments.endpointName) />

		<!--- Setup the endpoint --->
		<cfset loadEndpoint(arguments.endpointName, currentEndpoint.getParameter("type"), currentEndpoint.getParameters(), true) />

		<cfset newEndpoint = getEndpointByName(arguments.endpointName) />

		<!--- Configure the Property --->
		<cfset getAppManager().onObjectReload(newEndpoint) />
		<cfset newEndpoint.configure() />

		<!--- Deconfigure the current endpoint --->
		<cfset currentEndpoint.deconfigure() />
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

	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="parentEndpointManager" type="MachII.framework.EndpointManager" required="true" />
		<cfset variables.parentEndpointManager = arguments.parentEndpointManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false">
		<cfreturn variables.parentEndpointManager />
	</cffunction>

	<cffunction name="setUtils" access="private" returntype="void" output="false">
		<cfargument name="utils" type="MachII.util.Utils" required="true" />
		<cfset variables.utils = arguments.utils />
	</cffunction>
	<cffunction name="getUtils" access="private" returntype="MachII.util.Utils" output="false">
		<cfreturn variables.utils />
	</cffunction>

	<cffunction name="setEndpoints" access="public" returntype="void" output="false">
		<cfargument name="endpoints" type="struct" required="true" />
		<cfset variables.endpoints = arguments.endpoints />
	</cffunction>
	<cffunction name="getEndpoints" access="public" returntype="struct" output="false">
		<cfreturn variables.endpoints />
	</cffunction>

	<cffunction name="setEndpointContextPathMap" access="private" returntype="void" output="false">
		<cfargument name="endpointContextPathMap" type="struct" required="true" />
		<cfset variables.endpointContextPathMap = arguments.endpointContextPathMap />
	</cffunction>
	<cffunction name="getEndpointContextPathMap" access="public" returntype="struct" output="false">
		<cfreturn variables.endpointContextPathMap />
	</cffunction>

	<cffunction name="setEndpointParameter" access="private" returntype="void" output="false">
		<cfargument name="endpointParameter" type="string" required="true" />
		<cfset variables.endpointParameter = arguments.endpointParameter />
	</cffunction>
	<cffunction name="getEndpointParameter" access="public" returntype="string" output="false">
		<cfreturn variables.endpointParameter />
	</cffunction>

	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog("MachII.framework.EndpointManager") />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>