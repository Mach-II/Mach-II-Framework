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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="ViewContext"
	output="false"
	hint="Handles view display for an EventContext.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.propertyManager = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewContext" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />
		<cfset setPropertyManager(getAppManager().getPropertyManager()) />
		<cfset setLog(getAppManager().getLogFactory().getLog("MachII.framework.ViewContext")) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="displayView" access="public" returntype="void" output="true"
		hint="Displays a view by view name and peforms contentKey, contentArg and append functions.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The current Event object." />
		<cfargument name="viewName" type="string" required="true"
			hint="The view name to display." />
		<cfargument name="contentKey" type="string" required="false" default=""
			hint="The contentKey name if defined." />
		<cfargument name="contentArg" type="string" required="false" default=""
			hint="The contentArg name if defined." />
		<cfargument name="append" type="any" required="false"
			hint="Directive to append the view to an event arg." />
		<cfargument name="prepend" type="any" required="false"
			hint="Directive to prepend the view to an event arg." />

		<cfset var viewPath = getFullPath(arguments.viewName) />
		<cfset var viewContent = "" />
		<cfset var resolvedContentData = "" />
		<cfset var log = getLog() />

		<!--- Log this view --->
		<cfif Len(arguments.contentKey)>
			<cfset log.debug("Rendering view '#arguments.viewName#' in ContentKey '#arguments.contentKey#' with append '#arguments.append#' and prepend '#arguments.prepend#'.") />
		</cfif>
		<cfif Len(arguments.contentArg)>
			<cfset log.debug("Rendering view '#arguments.viewName#' in ContentArg '#arguments.contentArg#' with append '#arguments.append#' and prepend '#arguments.prepend#'.") />
		</cfif>
		<cfif NOT Len(arguments.contentKey) AND NOT Len(arguments.ContentArg)>
			<cfset log.debug("Rendering view '#arguments.viewName#'.") />
		</cfif>

		<!--- This has been left in for BC --->
		<cfset request.event = arguments.event />

		<!--- Include must be on same line as save content or an extra tab will occur --->
		<cftry>
			<cfsavecontent variable="viewContent"><cfsetting enablecfoutputonly="false" /><cfinclude template="#viewPath#" /><cfsetting enablecfoutputonly="true" /></cfsavecontent>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception occurred in a view named '#arguments.viewName#'. "
								& getAppManager().getUtils().buildMessageFromCfCatch(cfcatch, getUnresolvedPath(arguments.viewName))
								, cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<!--- Suppress any whitespace --->
		<cfset viewContent = Trim(viewContent) />

		<cfif arguments.contentKey NEQ ''>
			<cfif log.isWarnEnabled()>
				<cfset log.warn("DEPRECATED: The ContentKey attribute has been deprecated. This was called by view '#arguments.viewName#'.") />
			</cfif>

			<cfif arguments.append AND IsDefined(arguments.contentKey)>
				<cfset resolvedContentData = Evaluate(arguments.contentKey) />
				<cfset getAssert().isTrue(IsSimpleValue(resolvedContentData)
							, "Cannot append view content on a complex data type for view '#arguments.viewName#' in ContentKey '#arguments.contentKey#'."
							, "Ensure that the contentKey is of a simple data type.") />
				<cfset viewContent = resolvedContentData & viewContent />
			<cfelseif arguments.prepend AND IsDefined(arguments.contentKey)>
				<cfset resolvedContentData = Evaluate(arguments.contentKey) />
				<cfset getAssert().isTrue(IsSimpleValue(resolvedContentData)
							, "Cannot prepend view content on a complex data type for view '#arguments.viewName#' in ContentKey '#arguments.contentKey#'."
							, "Ensure that the contentKey is of a simple data type.") />
				<cfset viewContent = viewContent & resolvedContentData />
			</cfif>
			<cfset SetVariable(arguments.contentKey, viewContent) />
		</cfif>

		<cfif arguments.contentArg NEQ ''>
			<cfif arguments.append>
				<cfset resolvedContentData = arguments.event.getArg(arguments.contentArg, "") />
				<cfset getAssert().isTrue(IsSimpleValue(resolvedContentData)
							, "Cannot append view content on a complex data type for view '#arguments.viewName#' in ContentArg '#arguments.contentArg#'."
							, "Ensure that the contentArg is of a simple data type.") />
				<cfset viewContent = resolvedContentData & viewContent />
			<cfelseif arguments.prepend>
				<cfset resolvedContentData = arguments.event.getArg(arguments.contentArg, "") />
				<cfset getAssert().isTrue(IsSimpleValue(resolvedContentData)
							, "Cannot prepend view content on a complex data type for view '#arguments.viewName#' in ContentArg '#arguments.contentArg#'."
							, "Ensure that the contentArg is of a simple data type.") />
				<cfset viewContent = viewContent & resolvedContentData />
			</cfif>
			<cfset arguments.event.setArg(arguments.contentArg, viewContent) />
		</cfif>

		<cfif arguments.contentKey EQ '' AND arguments.contentArg EQ ''>
			<cfoutput>#viewContent#</cfoutput>
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getUtils().escapeHtml(getAppManager().getRequestManager().buildUrl(argumentcollection=arguments)) />
	</cffunction>

	<cffunction name="buildCurrentUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to replace or add into the current url with or a struct of data." />
		<cfargument name="urlParametersToRemove" type="string" required="false" default=""
			hint="Comma delimited list of url parameter names of items to remove from the current url" />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getUtils().escapeHtml(getAppManager().getRequestManager().buildCurrentUrl(argumentcollection=arguments)) />
	</cffunction>

	<cffunction name="buildUnescapedCurrentUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url that does not escape entities for html display.">
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to replace or add into the current url with or a struct of data." />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getRequestManager().buildCurrentUrl(argumentcollection=arguments) />
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

		<cfreturn getAppManager().getUtils().escapeHtml(getAppManager().getRequestManager().buildRouteUrl(argumentcollection=arguments)) />
	</cffunction>

	<cffunction name="buildUnescapedRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="queryStringParameters" type="string" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of query string parameters to append to end of the route." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getRequestManager().buildRouteUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildUnescapedUrl" access="public" returntype="string" output="false"
		hint="Builds an unescaped framework specific url and does not escape entities.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildUrlToModule" access="public" returntype="string" output="false"
		hint="Builds a framework specific url with module name and automatically escapes entities for html display.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with. Defaults to current module if empty string." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getUtils().escapeHtml(getAppManager().getRequestManager().buildUrl(argumentcollection=arguments)) />
	</cffunction>

	<cffunction name="buildUnescapedUrlToModule" access="public" returntype="string" output="false"
		hint="Builds an escaped framework specific url with module name and does not escape entities.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with. Defaults to current module if empty string." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="buildEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an endpoint specific url.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of the target endpoint." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />		
		<cfreturn getAppManager().getUtils().escapeHtml(getAppManager().getEndpointManager().buildEndpointUrl(argumentcollection=arguments)) />
	</cffunction>
	
	<cffunction name="buildUnescapedEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an endpoint specific url.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of the target endpoint." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfreturn getAppManager().getEndpointManager().buildEndpointUrl(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="inEnvironmentGroup" access="public" returntype="boolean" output="false"
		hint="Checks if the current environment group matches the passed list/array of groups.">
		<cfargument name="environmentGroup" type="any" required="true"
			hint="A comma-delimited list or array of groups to use for matching." />
		<cfreturn getAppManager().inEnvironmentGroup(arguments.environmentGroup) />
	</cffunction>

	<cffunction name="inEnvironmentName" access="public" returntype="boolean" output="false"
		hint="Checks if the current environment name matches the passed list/array of names.">
		<cfargument name="environmentName" type="any" required="true"
			hint="A comma-delimited list or array of names to use for matching." />
		<cfreturn getAppManager().inEnvironmentName(arguments.environmentName) />
	</cffunction>

	<cffunction name="addHTMLHeadElement" access="public" returntype="boolean" output="false"
		hint="Adds a HTML head element.">
		<cfargument name="text" type="string" required="true"
			hint="Text to add to the HTML head section." />
		<cfargument name="blockDuplicate" type="boolean" required="false"
			hint="Checks for *exact* duplicates using the text if true. Does not check if false (default behavior)." />
		<cfargument name="blockDuplicateCheckString" type="string" required="false"
			hint="The check string to use if blocking duplicates is selected. Default to 'arguments.text' if not defined" />
		<cfreturn getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTMLHeadElement(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTMLBodyElement" access="public" returntype="boolean" output="false"
		hint="Adds a HTML body element.">
		<cfargument name="text" type="string" required="true"
			hint="Text to add to the HTML body section." />
		<cfargument name="blockDuplicate" type="boolean" required="false"
			hint="Checks for *exact* duplicates using the text if true. Does not check if false (default behavior)." />
		<cfargument name="blockDuplicateCheckString" type="string" required="false"
			hint="The check string to use if blocking duplicates is selected. Default to 'arguments.text' if not defined" />
		<cfreturn getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTMLBodyElement(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTTPHeader" access="public" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">
		<cfargument name="name" type="string" required="false" />
		<cfargument name="value" type="string" required="false" />
		<cfargument name="statusCode" type="numeric" required="false" />
		<cfargument name="statusText" type="string" required="false" />
		<cfargument name="charset" type="string" required="false" />
		<cfset getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTTPHeaderByName" access="public" returntype="void" output="false"
		hint="Adds a HTTP header by name/value.">
		<cfargument name="name" type="string" required="true"
			hint="The HTTP header name." />
		<cfargument name="value" type="string" required="true"
			hint="The HTTP header value." />
		<cfargument name="charset" type="string" required="false"
			hint="The charset to use for the HTTP header." />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTTPHeaderByStatus" access="public" returntype="void" output="false"
		hint="Adds a HTTP header by statusCode/statusText.">
		<cfargument name="statuscode" type="string" required="true"
			hint="The statuscode for the HTTP header." />
		<cfargument name="statustext" type="string" required="false"
			hint="The text for the statuscode for the HTTP header. Defaults to the correct text if the statuscode matches a standard statuscode." />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="copyToScope" access="public" returntype="void" output="false"
		hint="Copies an evaluation string to a scope.">
		<cfargument name="evaluationString" type="string" required="true"
			hint="A list of EL items to evaluate." />
		<cfargument name="scopeReference" type="struct" required="false" default="#variables#"
			hint="A reference to the scope to to place the copies into. Defaults to the variables scope." />
		<cfset getAppManager().getUtils().copyToScope(arguments.evaluationString, arguments.scopeReference, getAppManager()) />
	</cffunction>

	<cffunction name="getAssert" access="public" returntype="MachII.util.Assert" output="false"
		hint="Gets the basic assertion utility.">
		<cfreturn getAppManager().getAssert() />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getFullPath" access="private" returntype="string" output="false"
		hint="Gets the full path of a view by view name from the view manager.">
		<cfargument name="viewName" type="string" required="true" />
		<cfreturn getAppManager().getViewManager().getViewPath(arguments.viewName) />
	</cffunction>

	<cffunction name="getUnresolvedPath" access="private" returntype="string" output="false"
		hint="Gets the full path of a view by view name from the view manager.">
		<cfargument name="viewName" type="string" required="true" />
		<cfreturn getAppManager().getViewManager().getUnresolvedViewPath(arguments.viewName) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the AppManager instance this ViewContext belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Gets the AppManager instance this ViewContext belongs to.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setPropertyManager" access="private" returntype="void" output="false"
		hint="Sets the components PropertyManager instance.">
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true"
			hint="The PropertyManager instance to set." />
		<cfset variables.propertyManager = arguments.propertyManager />
	</cffunction>
	<cffunction name="getPropertyManager" access="public" returntype="MachII.framework.PropertyManager" output="false"
		hint="Gets the components PropertyManager instance.">
		<cfreturn variables.propertyManager />
	</cffunction>

	<cffunction name="setProperty" access="public" returntype="void" output="false"
		hint="Sets the specified property - this is just a shortcut for getAppManager().getPropertyManager().setProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to set." />
		<cfargument name="propertyValue" type="any" required="true"
			hint="The value to store in the property." />
		<cfset getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getAppManager().getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to return." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to use if the requested property is not defined." />
		<cfreturn getPropertyManager().getProperty(arguments.propertyName, arguments.defaultValue) />
	</cffunction>
	<cffunction name="isPropertyDefined" access="public" returntype="boolean" output="false"
		hint="Checks if property name is defined in the properties. Does NOT check a parent.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The named of the property to check if it is defined." />
		<cfreturn getPropertyManager().isPropertyDefined(arguments.propertyName) />
	</cffunction>

	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.log = arguments.log />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>