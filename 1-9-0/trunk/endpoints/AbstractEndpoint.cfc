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
	displayname="AbstractEndpoint"
	output="false"
	hint="An endpoint. This is abstract and must be extended by a concrete strategy implementation.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parameters = StructNew() />
	<cfset variables.log = "" />
	<cfset variables.baseProxy = "" />
	<cfset variables.componentNameFull = "" />
	<cfset variables.componentNameForLogging = "" />
	<cfset variables.endpointManager = "" />

	<cfset variables.enableThrow = false />
	<cfset variables.throwTemplate = "/MachII/endpoints/defaultThrowTemplate.cfm" />
	<cfset variables.customMimeTypeMap = StructNew() />
	<cfset variables.isPreProcessDefined = false />
	<cfset variables.isPostProcessDefined = false />
	<cfset variables.isOnAuthenticateDefined = false />
	<!--- This is set when a status is added by the addHTTPHeaderByStatus method.  --->
	<cfset variables.httpStatusCode = 0 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractEndpoint" output="false"
		hint="Initializes the endpoint. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="A reference to the AppManager this endpoint was loaded from." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="A struct of configure time parameters." />

		<cfset var defaultEnableThrow = StructNew() />

		<!--- Run setters --->
		<cfset setAppManager(arguments.appManager) />
		<cfset setParameters(arguments.parameters) />

		<!--- Compute the full and short component name that will be used for logging --->
		<cfset variables.componentNameFull = getMetaData(this).name />
		<cfset variables.componentNameForLogging = ListLast(variables.componentNameFull, ".") />

		<cfset setLog(getAppManager().getLogFactory()) />

		<!--- Setup required default parameters --->
		<cfif isParameterDefined("enableThrow") AND getAssert().isTrue(IsBoolean(getParameter("enableThrow")) OR IsStruct(getParameter("enableThrow"))
				, "Invalid enableThrow."
				, "Must be boolean or struct of environments.")>
			<cfif IsStruct(getParameter("enableThrow"))>
				<cfset setEnableThrow(resolveValueByEnvironment(getParameter("enableThrow"), false)) />
			<cfelse>
				<cfset setEnableThrow(getParameter("enableThrow", false)) />
			</cfif>
		<cfelse>
			<cfset defaultEnableThrow["group:development"] = true />
			<cfset defaultEnableThrow["group:local"] = true />
			<cfset defaultEnableThrow["group:_default_"] = false />
			<cfset setEnableThrow(resolveValueByEnvironment(defaultEnableThrow, false)) />
		</cfif>

		<cfif isParameterDefined("throwTemplate") AND getAssert().hasText(getParameter("throwTemplate")
				, "Invalid throwTemplate."
				, "Must be path to throw template.")>
			<cfset setThrowTemplate(getParameter("throwTemplate")) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(variables.componentNameFull) />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

	<cffunction name="setProxy" access="public" returntype="void" output="false"
		hint="Sets the base proxy.">
		<cfargument name="proxy" type="MachII.framework.BaseProxy" required="true" />
		<cfset variables.baseProxy = arguments.proxy>
	</cffunction>
	<cffunction name="getProxy" access="public" returntype="any" output="false"
		hint="Gets the base proxy.">
		<cfreturn variables.baseProxy />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the endpoint. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the endpoint. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - ENDPOINT REQUEST HANDLING
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="String" output="true"
		hint="Handles endpoint request. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden. This method is required for all concrete endpoints." />
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request end. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<cffunction name="onAuthenticate" access="public" returntype="void" output="false"
		hint="Runs when an endpoint authentication is required. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true"
		hint="Runs when an exception occurs in the endpoint. Override to provide custom functionality and call super.onException() for basic error handling.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception that was thrown/caught by the endpoint request processor." />

		<!--- Optional "throw" parameter can cause the full exception to be rendered in the browser. --->
		<cfif arguments.event.isArgDefined("throw") AND getEnableThrow()>
			<cfset addHTTPHeaderByStatus(500) />
			<cfsetting enablecfoutputonly="false" /><cfoutput><cfinclude template="#getThrowTemplate()#" /></cfoutput><cfsetting enablecfoutputonly="true" />
		<!--- Default exception handling --->
		<cfelse>
			<cfset variables.log.error(getUtils().buildMessageFromCfCatch(arguments.exception.getCaughtException()), arguments.exception.getCaughtException()) />
			<cfif getHttpStatusCode() EQ 0>
				<cfset addHTTPHeaderByStatus(500) />
			</cfif>
			<cfset addHTTPHeaderByName("machii.endpoint.error", "Endpoint named '#event.getArg(getProperty("endpointParameter"))#' encountered an unhandled exception.") />
			<cfsetting enablecfoutputonly="false" /><cfoutput>Endpoint named '#event.getArg(getProperty("endpointParameter"))#' encountered an unhandled exception.</cfoutput><cfsetting enablecfoutputonly="true" />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url without specifying a module name. Does not escape entities.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<!--- If we are loading, then fall back to current module, because this means
			BuildUrl is being called during configure() and there is no current request --->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildUrlToModule" access="public" returntype="string" output="false"
		hint="Builds a framework specific url. Does not escape entities.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with. Defaults to base module if empty string." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="queryStringParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of query string parameters to append to end of the route." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildRouteUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an endpoint specific URL.">
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<cffunction name="resolveValueByEnvironment" access="public" returntype="any" output="false"
		hint="Resolves a value by deployed environment name or group (explicit environment names are searched first then groups then default).">
		<cfargument name="environmentValues" type="struct" required="true"
			hint="A struct of environment values. Key prefixed with 'group:' are treated as groups and keys can contain ',' to indicate multiple environments names or groups." />
		<cfargument name="defaultValue" type="any" required="false"
			hint="A default value to provide if no environment is found. An exception will be thrown if no 'defaultValue' is provide and no value can be resolved." />

		<cfset var currentEnvironmentName = getAppManager().getEnvironmentName() />
		<cfset var currentEnvironmentGroup = getAppManager().getEnvironmentGroup() />
		<cfset var valuesByEnvironmentName = StructNew() />
		<cfset var valuesByEnvironmentGroup = StructNew() />
		<cfset var validEnvironmentGroupNames = getAppManager().getEnvironmentGroupNames() />
		<cfset var scrubbedEnvironmentGroups = "" />
		<cfset var scrubbedEnvironmentNames = "" />
		<cfset var i = "" />
		<cfset var key = "" />
		<cfset var assert = getAssert() />
		<cfset var utils = getUtils() />

		<!--- Build values by name and group --->
		<cfloop collection="#arguments.environmentValues#" item="key">
			<!--- An environment group if it is prefixed with 'group:' --->
			<cfif key.toLowerCase().startsWith("group:")>
				<!--- Removed 'group:' and trim each list element --->
				<cfset scrubbedEnvironmentGroups = utils.trimList(Right(key, Len(key) - 6)) />

				<cfloop list="#scrubbedEnvironmentGroups#" index="i">
					<cfset assert.isTrue(ListFindNoCase(validEnvironmentGroupNames, i)
							, "An environment group named '#i#' is not a valid environment group name. Valid environment group names: '#validEnvironmentGroupNames#'.") />
					<cfset valuesByEnvironmentGroup[i] = arguments.environmentValues[key] />
				</cfloop>
			<!--- An explicit environment name if it does not have a prefix --->
			<cfelse>
				<!--- Trim each list element --->
				<cfset scrubbedEnvironmentNames = utils.trimList(key) />

				<cfloop list="#scrubbedEnvironmentNames#" index="i">
					<cfset valuesByEnvironmentName[i] = arguments.environmentValues[key] />
				</cfloop>
			</cfif>
		</cfloop>

		<!---
			Typically, we prefer to only have one return, however in this case
			it is easier to just short-ciruit the process.

			Resolution order:
			 * by explicit environment name
			 * by environment group
			 * by default value (if provided)
			 * throw exception
		--->

		<!--- Resolve value by explicit environment name --->
		<cfif StructKeyExists(valuesByEnvironmentName, currentEnvironmentName)>
			<cfreturn valuesByEnvironmentName[currentEnvironmentName] />
		</cfif>

		<!--- Resolve value by explicit environment group --->
		<cfif StructKeyExists(valuesByEnvironmentGroup, currentEnvironmentGroup)>
			<cfreturn valuesByEnvironmentGroup[currentEnvironmentGroup] />
		</cfif>

		<!--- No environment to resolve, return default value if provided --->
		<cfset assert.isTrue(StructKeyExists(arguments, "defaultValue")
					, "Cannot resolve value by environment name or group and no default value was provided. Provide an explicit value by environment name, environment group or provide a default value. Current environment name: '#currentEnvironmentName#' Current environment group: '#currentEnvironmentGroup#'") />
		
		<cfreturn arguments.defaultValue />
	</cffunction>

	<cffunction name="setParameter" access="public" returntype="void" output="false"
		hint="Sets a configuration parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" type="any" required="true"
			hint="The parameter value." />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" output="false"
		hint="Gets a configuration parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to return if the parameter is not defined. Defaults to a blank string." />
		<cfif isParameterDefined(arguments.name)>
			<cfreturn bindValue(arguments.name, variables.parameters[arguments.name]) />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>
	<cffunction name="isParameterDefined" access="public" returntype="boolean" output="false"
		hint="Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>
	<cffunction name="getParameterNames" access="public" returntype="string" output="false"
		hint="Returns a comma delimited list of parameter names.">
		<cfreturn StructKeyList(variables.parameters) />
	</cffunction>

	<cffunction name="setProperty" access="public" returntype="void" output="false"
		hint="Sets the specified property - this is just a shortcut for getPropertyManager().setProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to set."/>
		<cfargument name="propertyValue" type="any" required="true"
			hint="The value to store in the property." />
		<cfset getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to return."/>
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to use if the requested property is not defined." />
		<cfreturn getPropertyManager().getProperty(arguments.propertyName, arguments.defaultValue) />
	</cffunction>
	<cffunction name="isPropertyDefined" access="public" returntype="boolean" output="false"
		hint="Checks if property name is defined in the properties - this is just a shortcutfor getPropertyManager().isPropertyDefined(). Does NOT check a parent.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The named of the property to check if it is defined." />
		<cfreturn getPropertyManager().isPropertyDefined(arguments.propertyName) />
	</cffunction>

	<cffunction name="getPropertyManager" access="public" returntype="MachII.framework.PropertyManager" output="false"
		hint="Gets the components PropertyManager instance.">
		<cfreturn getAppManager().getPropertyManager() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getEndpointManager" access="public" returntype="MachII.framework.EndpointManager" output="false">
		<cfreturn getAppManager().getEndpointManager() />
	</cffunction>

	<cffunction name="getUtils" access="public" returntype="MachII.util.Utils" output="false"
		hint="Gets the Utils component.">
		<cfreturn getAppManager().getUtils() />
	</cffunction>

	<cffunction name="getAssert" access="public" returntype="MachII.util.Assert" output="false"
		hint="Gets the Assert component.">
		<cfreturn getAppManager().getAssert() />
	</cffunction>

	<cffunction name="getComponentNameForLogging" access="public" returntype="string" output="false"
		hint="Gets the component name for logging.">
		<cfreturn variables.componentNameForLogging />
	</cffunction>

	<cffunction name="registerMimeType" access="private" returntype="void" output="false"
		hint="Registers a custom mime type which adds to or overrides the base mime-type map known to Mach-II.">
		<cfargument name="fileExtension" type="string" required="true"
			hint="The file extension to map the mime-type to." />
		<cfargument name="mimeType" type="string" required="true"
			hint="The mime-type associated with the file extension." />

		<!--- Remove a leading "." if defined on the file extension --->
		<cfif arguments.fileExtension.startsWith(".")>
			<cfset arguments.fileExtension = Right(arguments.fileExtension, Len(arguments.fileExtension) - 1) />
		</cfif>

		<cfset variables.customMimeTypeMap[arguments.fileExtension] = arguments.mimeType />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="bindValue" access="private" returntype="any" output="false"
		hint="Binds placeholders to any passed value.">
		<cfargument name="parameterName" type="string" required="true"
			hint="The name of the parameter to bind." />
		<cfargument name="parameterValue" type="any" required="true"
			hint="The current value of the parameter." />

		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />
		<cfset var value =  arguments.parameterValue />
		<cfset var scope = "" />
		<cfset var event = "" />

		<!--- Can only bind simple parameter values --->
		<cfif IsSimpleValue(arguments.parameterValue)
			AND expressionEvaluator.isExpression(arguments.parameterValue)>

			<!---
				For BC with bindable property parameters, a scope name was not "required"
				(during framework loading) and defaults to "properties", however it is best
				practice to provide a scope
			--->
			<cfif getAppManager().isLoading()>
				<!--- Disallow event scope during framework load --->
				<cfif FindNoCase("${event.", value)>
					<cfthrow type="MachII.framework.BindToParameterInvalidScope"
						message="Cannot bind to a parameter named '#arguments.parameterName#' for '#getComponentNameForLogging()#' because the 'event.' scope is not available for use during on framework load." />
				</cfif>

				<!--- Create a dummy event object to pass in --->
				<cfset event = CreateObject("component", "MachII.framework.Event").init() />
			<cfelse>
				<cfset event = request.event />
			</cfif>

			<!--- Add in properties scope if missing and the expression is not scoped (for BC since the "properties." was not required)--->
			<cfset value = REReplaceNoCase(value, "\$\{(?!properties\.|event\.)", "${properties.", "all") />

			<cftry>
				<cfset value = expressionEvaluator.evaluateExpression(value, event, getPropertyManager()) />

				<cfcatch type="any">
					<cfthrow type="MachII.framework.BindToParameterException"
						message="Error trying bind to a parameter named '#arguments.parameterName#' for '#getComponentNameForLogging()#'."
						detail="Please check your expression for errors." />
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn value />
	</cffunction>

	<cffunction name="addHTTPHeader" access="public" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="value" type="string" required="false" default="" />
		<cfargument name="statusCode" type="numeric" required="false" default="0" />
		<cfargument name="statusText" type="string" required="false" default="" />
		<cfargument name="charset" type="string" required="false" default="" />

		<cfset var i = 0 />
		<cfset var log = getLog() />

		<cfif Len(arguments.name)>
			<cfif Len(arguments.charset)>
				<cfheader name="#arguments.name#"
					value="#arguments.value#"
					charset="#arguments.charset#" />
			<cfelse>
				<cfheader name="#arguments.name#"
					value="#arguments.value#" />
			</cfif>
		<cfelseif arguments.statusCode NEQ 0>
			<cfif NOT Len(arguments.statusText)>
				<cfset arguments.statusText = getUtils().getHTTPHeaderStatusTextByStatusCode(arguments.statusCode) />

				<cfif NOT Len(arguments.statusText) AND log.isWarnEnabled()>
					<cfset log.warn("Unable to resolve a status text shortcut for a HTTP header with the status code of '#arguments.statusCode#'. Please check that you are using a supported status code.") />
				</cfif>
			</cfif>
			<cfheader statuscode="#arguments.statusCode#"
				statustext="#arguments.statusText#" />
		<cfelse>
			<cfthrow type="MachII.framework.invalidHTTPHeaderArguments"
				message="The method addHTTPHeader required arguments must be 'name,value' or 'statusCode'."
				detail="Passed arguments:#arguments.toString()#" />
		</cfif>

		<!--- Notify any registered observers --->
		<cfif StructKeyExists(request, "_MachIIEndpoint_HTTPHeaderCallbacks")>
			<cfloop from="1" to="#ArrayLen(request._MachIIEndpoint_HTTPHeaderCallbacks)#" index="i">
				<cfinvoke component="#request._MachIIEndpoint_HTTPHeaderCallbacks[i].callback#"
					method="#request._MachIIEndpoint_HTTPHeaderCallbacks[i].method#"
					argumentcollection="#arguments#" />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="addHTTPHeaderByName" access="public" returntype="void" output="false"
		hint="Adds a HTTP header by name/value.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfargument name="charset" type="string" required="false" />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTTPHeaderByStatus" access="public" returntype="void" output="false"
		hint="Adds a HTTP header by statusCode/statusText.">
		<cfargument name="statuscode" type="numeric" required="true" />
		<cfargument name="statustext" type="string" required="false" />
		<cfset variables.httpStatusCode = arguments.statuscode />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="observeHTTPHeader" access="private" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">

		<!--- Individual arguments are not passed in so we just observe the argument collection --->

		<cfif NOT IsDefined("request._MachIIEndpoint_HTTPHeaders")>
			<cfset request["_MachIIEndpoint_HTTPHeaders"] = ArrayNew(1) />
		</cfif>

		<cfset ArrayAppend(request["_MachIIEndpoint_HTTPHeaders"], arguments) />
	</cffunction>

	<cffunction name="getObservedHTTPHeaders" access="private" returntype="array" output="false"
		hint="Gets observed HTTP headers.">
		<cfif IsDefined("request._MachIIEndpoint_HTTPHeaders")>
			<cfreturn request["_MachIIEndpoint_HTTPHeaders"] />
		<cfelse>
			<cfreturn ArrayNew(1) />
		</cfif>
	</cffunction>
	<cffunction name="replayHTTPHeaders" access="private" returntype="void" output="false"
		hint="Replays cached HTTP header.">
		<cfargument name="HTTPHeaders" type="array" required="true" />

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(arguments.HTTPHeaders)#" index="i">
			<cfset addHTTPHeader(argumentcollection=arguments.HTTPHeaders[i]) />
		</cfloop>
	</cffunction>

	<cffunction name="addHTTPHeaderCallback" access="private" returntype="void" output="false"
		hint="Adds callback to notify when addHTMLHeadElement is run.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />

		<cfif NOT IsDefined("request._MachIIEndpoint_HTTPHeaderCallbacks")>
			<cfset request["_MachIIEndpoint_HTTPHeaderCallbacks"] = ArrayNew(1) />
		</cfif>

		<cfset ArrayAppend(request._MachIIEndpoint_HTTPHeaderCallbacks, arguments) />
	</cffunction>
	<cffunction name="removeHTTPHeaderCallback" access="private" returntype="void" output="false"
		hint="Removes callback to notify when addHTTPHeaderCallback is run.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var utils = getUtils() />
		<cfset var i = 0 />

		<cfif StructKeyExists(request, "_MachIIEndpoint_HTTPHeaderCallbacks")>
			<cfloop from="1" to="#ArrayLen(request._MachIIEndpoint_HTTPHeaderCallbacks)#" index="i">
				<cfif utils.assertSame(request._MachIIEndpoint_HTTPHeaderCallbacks[i].callback, arguments.callback)>
					<cfset ArrayDeleteAt(request._MachIIEndpoint_HTTPHeaderCallbacks, i) />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the components AppManager instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager instance to set." />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Gets the components AppManager instance.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of configuration parameters for the component.">
		<cfargument name="parameters" type="struct" required="true"
			hint="Struct to set as parameters" />

		<cfset var key = "" />

		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, arguments.parameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of configuration parameters for the component.">

		<cfset var key = "" />
		<cfset var resolvedParameters = StructNew() />

		<!--- Get values and bind placeholders --->
		<cfloop collection="#variables.parameters#" item="key">
			<cfset resolvedParameters[key] = bindValue(key, variables.parameters[key]) />
		</cfloop>

		<cfreturn resolvedParameters />
	</cffunction>

	<cffunction name="setEnableThrow" access="public" returntype="void" output="false">
		<cfargument name="enableThrow" type="boolean" required="true" />
		<cfset variables.enableThrow = arguments.enableThrow />
	</cffunction>
	<cffunction name="getEnableThrow" access="public" returntype="boolean" output="false">
		<cfreturn variables.enableThrow />
	</cffunction>

	<cffunction name="setThrowTemplate" access="public" returntype="void" output="false">
		<cfargument name="throwTemplate" type="string" required="true" />
		<cfset variables.throwTemplate = arguments.throwTemplate />
	</cffunction>
	<cffunction name="getThrowTemplate" access="public" returntype="string" output="false">
		<cfreturn variables.throwTemplate />
	</cffunction>

	<cffunction name="setIsPreProcessDefined" access="public" returntype="void" output="false">
		<cfargument name="isPreProcessDefined" type="boolean" required="true" />
		<cfset variables.isPreProcessDefined = arguments.isPreProcessDefined />
	</cffunction>
	<cffunction name="isPreProcessDefined" access="public" returntype="boolean" output="false">
		<cfreturn variables.isPreProcessDefined />
	</cffunction>

	<cffunction name="setIsPostProcessDefined" access="public" returntype="void" output="false">
		<cfargument name="isPostProcessDefined" type="boolean" required="true" />
		<cfset variables.isPostProcessDefined = arguments.isPostProcessDefined />
	</cffunction>
	<cffunction name="isPostProcessDefined" access="public" returntype="boolean" output="false">
		<cfreturn variables.isPostProcessDefined />
	</cffunction>

	<cffunction name="setIsOnAuthenticateDefined" access="public" returntype="void" output="false">
		<cfargument name="isOnAuthenticateDefined" type="boolean" required="true" />
		<cfset variables.isOnAuthenticateDefined = arguments.isOnAuthenticateDefined />
	</cffunction>
	<cffunction name="isOnAuthenticateDefined" access="public" returntype="boolean" output="false">
		<cfreturn variables.isOnAuthenticateDefined />
	</cffunction>

	<cffunction name="getHttpStatusCode" access="public" returntype="numeric" output="false">
		<cfreturn variables.httpStatusCode />
	</cffunction>

</cfcomponent>