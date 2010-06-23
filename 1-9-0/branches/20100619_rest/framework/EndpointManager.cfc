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
	<cfset variables.endpoints = StructNew() />
	<cfset variables.endpointContextPathMap = StructNew() />
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />

	<cfset variables.ENDPOINT_SHORTCUTS = StructNew() />
	<cfset variables.ENDPOINT_SHORTCUTS["ShortcutName"] = "MachII.endpoints.impl.NameOfEndpoint" />

	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EndpointManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="Sets the base AppManager." />

		<cfset setAppManager(arguments.appManager) />
		<cfset setLog(arguments.appManager.getLogFactory()) />
		<cfset setEndpointParameter(arguments.appManager.getPropertyManager().getProperty("endpointParameter")) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the endpoints.">

		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />

		<cfloop collection="#endpoints#" item="key">
			<cfset endpoints[key].configure() />
		</cfloop>

		<cfset buildEndpointContextPathMap() />
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures all the endpoints.">

		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />

		<cfloop collection="#endpoints#" item="key">
			<cfset endpoints[key].deconfigure() />
		</cfloop>

		<cfset variables.endpointContextPathMap = StructNew() />
	</cffunction>

	<cffunction name="buildEndpointContextPathMap" access="private" returntype="void" output="false"
		hint="Builds a map of context paths and endpoint names.">

		<cfset var endpointContextPathMap = StructNew() />
		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />
		<cfset var contextPath = "" />

		<cfloop collection="#endpoints#" item="key">
			<cfset contextPath = endpoints[key].getParameter("contextPath")>

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

		<cfif StructKeyExists(variables.endpointContextPathMap, cgi.SCRIPT_NAME)>
			<cfset arguments.eventArgs[getEndpointParameter()] = variables.endpointContextPathMap[cgi.SCRIPT_NAME] />
			<cfreturn true />
		<cfelseif StructKeyExists(arguments.eventArgs, getEndpointParameter())>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="handleEndpointRequest" access="public" returntype="void" output="true"
		hint="Handles an endpoint request.">
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="The events args needed to complete the request." />

		<cfset var event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset var endpoint = "" />
		<cfset var endpointLog = "" />
		<cfset event.setArgs(arguments.eventArgs) />

		<cftry>
			<cfset endpoint = getEndpointByName(event.getArg(getEndpointParameter())) />
			<cfset endpointLog = endpoint.getLog() />

			<cfif endpoint.isPreProcessDefined()>
				<cfset endpoint.preProcess(event) />
			</cfif>

			<cfset endpoint.handleRequest(event) />

			<cfif endpoint.isPostProcessDefined()>
				<cfset endpoint.postProcess(event) />
			</cfif>

			<!--- TODO: Still need to figure in onException handling --->

			<cfcatch type="MachII.endpoints.EndpointNotDefined">
				<!--- No endpoint so send a 404 --->
				<cfheader statuscode="404" statustext="Not Found" />
				<cfheader name="machii.endpoint.error" value="Endpoint named '#event.getArg(getEndpointParameter())#' not available." />
				<cfsetting enablecfoutputonly="false" /><cfoutput>Endpoint named '#event.getArg(getEndpointParameter())#' not available.</cfoutput><cfsetting enablecfoutputonly="true" />
			</cfcatch>
			<cfcatch type="any">
				<!--- Something went wrong and no concrete exception handling was performed by the endpoint --->
				<cfheader statuscode="500" statustext="Error" />
				<cfheader name="machii.endpoint.error" value="Endpoint named '#event.getArg(getEndpointParameter())#' encountered an unhanled exception." />
				<cfsetting enablecfoutputonly="false" /><cfoutput>Endpoint named '#event.getArg(getEndpointParameter())#' encountered an unhanled exception.</cfoutput><cfsetting enablecfoutputonly="true" />
			</cfcatch>
		</cftry>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="isTargetPageEndpoint" access="public" returntype="boolean" output="false"
		hint="Checks if the target page should be handled by the endpoint.">
		<cfargument name="targetPage" type="string" required="true" />
		<cfreturn StructKeyExists(variables.endpointTargetPageMap, arguments.targetPage) />
	</cffunction>

	<cffunction name="getEndpointByName" access="public" returntype="MachII.endpoints.AbstractEndpoint" output="false"
		hint="Gets a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to get." />

		<cfif isEndpointDefined(arguments.endpointName)>
			<cfreturn variables.endpoints[arguments.endpointName] />
		<cfelse>
			<cfthrow type="MachII.endpoints.EndpointNotDefined"
				message="Endpoints with name '#arguments.endpointName#' is not defined."
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

		<cfif NOT arguments.overrideCheck AND isEndpointDefined(arguments.endpointName)>
			<cfthrow type="MachII.endpoints.EndpointAlreadyDefined"
				message="An endpoint with name '#arguments.endpointName#' is already registered." />
		<cfelse>
			<cfset variables.endpoints[arguments.endpointName] = arguments.endpoint />
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
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager the endpoint was loaded from." />
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint." />
		<cfargument name="endpointType" type="string" required="true"
			hint="Dot path to the endpoint." />
		<cfargument name="endpointParameters" type="struct" required="false" default="#StructNew()#"
			hint="Configuration parameters for the endpoint." />

		<cfset var endpoint = "" />

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
			<cfset endpoint = CreateObject("component", arguments.endpointType).init(arguments.appManager, this, arguments.endpointParameters) />

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

		<cfset endpoint.setIsPreProcessDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="preProcess"', true, "MachII.endpoints.AbstractEndpoint"))) />
		<cfset endpoint.setIsPostProcessDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="postProcess"', true, "MachII.endpoints.AbstractEndpoint"))) />
		<cfset endpoint.setIsOnExceptionDefined(ArrayLen(variables.introspector.getFunctionDefinitions(endpoint, 'name="onException"', true, "MachII.endpoints.AbstractEndpoint"))) />

		<cfset addEndpoint(arguments.endpointName, endpoint) />
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

	<cffunction name="getEndpoints" access="public" returntype="struct" output="false"
		hint="Gets all registered endpoints for this manager.">
		<cfreturn variables.endpoints />
	</cffunction>

	<cffunction name="getEndpointNames" access="public" returntype="array" output="false"
		hint="Returns an array of endpoint names.">
		<cfreturn StructKeyArray(variables.endpoints) />
	</cffunction>

	<cffunction name="containsEndpoints" access="public" returntype="boolean" output="false"
		hint="Returns a boolean of on whether or not there are any registered endpoints.">
		<cfreturn StructCount(variables.endpoints) GT 0 />
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