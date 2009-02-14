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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.6.0

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
		<cfset setLog(getAppManager().getLogFactory()) />
		
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
		<cfargument name="append" type="boolean" required="false" default="false"
			hint="Directive to append event." />	
		
		<cfset var viewPath = getFullPath(arguments.viewName) />
		<cfset var viewContent = "" />
		<cfset var log = getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfif Len(arguments.contentKey)>
				<cfset log.debug("Rendering view '#arguments.viewName#' in ContentKey '#arguments.contentKey#'.") />
			</cfif>
			<cfif Len(arguments.contentArg)>
				<cfset log.debug("Rendering view '#arguments.viewName#' in ContentArg '#arguments.contentArg#'.") />
			</cfif>
			<cfif NOT Len(arguments.contentKey) AND NOT Len(arguments.ContentArg)>
				<cfset log.debug("Rendering view '#arguments.viewName#'.") />
			</cfif>
		</cfif>
		
		<!--- This has been left in for BC --->
		<cfset request.event = arguments.event />

		<cfif arguments.contentKey NEQ ''>
			<cfif log.isWarnEnabled()>
				<cfset log.warn("DEPRECATED: The ContentKey attribute has been deprecated. This was called by view '#arguments.viewName#'.") />
			</cfif>
			<!--- Include must be on same line as save content or an extra tab will occur --->
			<cfsavecontent variable="viewContent"><cfinclude template="#viewPath#" /></cfsavecontent>
			<cfif arguments.append AND IsDefined(arguments.contentKey)>
				<cfset viewContent = Evaluate(arguments.contentKey) & viewContent />
			</cfif>
			<cfset setVariable(arguments.contentKey, viewContent) />
		</cfif>
		
		<cfif arguments.contentArg NEQ ''>
			<!--- Include must be on same line as save content or an extra tab will occur --->
			<cfsavecontent variable="viewContent"><cfinclude template="#viewPath#" /></cfsavecontent>
			<cfif arguments.append>
				<cfset viewContent = arguments.event.getArg(arguments.contentArg, "") & viewContent />
			</cfif>
			<cfset arguments.event.setArg(arguments.contentArg, viewContent) />
		</cfif>
		
		<cfif arguments.contentKey EQ '' AND arguments.contentArg EQ ''>
			<cfinclude template="#viewPath#" />
		</cfif>
	</cffunction>
	
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
		
		<cfreturn HtmlEditFormat(getAppManager().getRequestManager().buildUrl(argumentcollection=arguments)) />
	</cffunction>
	
	<cffunction name="buildCurrentUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to replace or add into the current url with or a struct of data." />
		
		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />

		<cfreturn HtmlEditFormat(getAppManager().getRequestManager().buildCurrentUrl(argumentcollection=arguments)) />
	</cffunction>
	
	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />

		<!--- Grab the module name from the context of the currently executing request--->
		<cfset arguments.moduleName = getAppManager().getModuleName() />
		
		<cfreturn HtmlEditFormat(getAppManager().getRequestManager().buildRouteUrl(argumentcollection=arguments)) />
	</cffunction>

	<cffunction name="buildUnescapedRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
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
		<cfreturn HtmlEditFormat(getAppManager().getRequestManager().buildUrl(argumentcollection=arguments)) />
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

	<cffunction name="addHTMLHeadElement" access="public" returntype="void" output="false"
		hint="Adds a HTML head element.">
		<cfargument name="text" type="string" required="true" />
		<cfset getAppManager().getRequestManager().getRequestHandler().getEventContext().addHTMLHeadElement(arguments.text) />
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
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfargument name="charset" type="string" required="false" />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>

	<cffunction name="addHTTPHeaderByStatus" access="public" returntype="void" output="false"
		hint="Adds a HTTP header by statusCode/statusText.">
		<cfargument name="statuscode" type="string" required="true" />
		<cfargument name="statustext" type="string" required="false" />
		<cfset addHTTPHeader(argumentcollection=arguments) />
	</cffunction>
	
	<cffunction name="copyToScope" access="public" returntype="void" output="false"
		hint="Copies an evaluation string to a scope.">
		<cfargument name="evaluationString" type="string" required="true" />
		<cfargument name="scopeReference" type="struct" required="false" default="#variables#" />
		
		<cfset var event = getAppManager().getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var propertyManager = getPropertyManager() />
		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />
		<cfset var stem = "" />
		<cfset var key = "" />
		<cfset var element = "" />
		
		<cfloop list="#arguments.evaluationString#" index="stem">
			<!--- Remove any spaces or carriage returns or this will fail --->
			<cfset stem = Trim(stem) />
			
			<cfif ListLen(stem, "=") EQ 2>
				<cfset element = ListGetAt(stem, 2, "=") />
				<cfset key = ListGetAt(stem, 1, "=") />
				<cfif expressionEvaluator.isExpression(element)>
					<cfset arguments.scopeReference[key] = expressionEvaluator.evaluateExpression(element, event, propertyManager) />
				<cfelse>
					<cfset arguments.scopeReference[key] = element />
				</cfif>
			<cfelse>
				<cfset element = stem />
				<cfset key = stem />
				<cfif expressionEvaluator.isExpression(stem)>
					<!--- It would be better to replace this with RegEx --->
					<cfset key = ListLast(ListFirst(REReplaceNoCase(key, "^\${(.*)}$", "\1", "all"), ":"), ".") />
					<cfset arguments.scopeReference[key] = expressionEvaluator.evaluateExpression(element, event, propertyManager) />
				<cfelse>
					<cfset arguments.scopeReference[key] = stem />
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getFullPath" access="private" returntype="string" output="false"
		hint="Gets the full path of a view by view name from the view manager.">
		<cfargument name="viewName" type="string" required="true" />
		<cfreturn getAppManager().getViewManager().getViewPath(arguments.viewName) />
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
		<cfargument name="propertyName" type="string" required="yes"
			hint="The name of the property to set." />
		<cfargument name="propertyValue" type="any" required="yes" 
			hint="The value to store in the property." />
		<cfset getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>	
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getAppManager().getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="yes"
			hint="The name of the property to return." />
		<cfreturn getPropertyManager().getProperty(arguments.propertyName) />
	</cffunction>
	
	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>