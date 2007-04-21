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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
- Added request event name functionality. (pfarrell)
--->
<cfcomponent 
	displayname="RequestHandler"
	output="false"
	hint="Handles request to event conversion for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestHandler" output="false"
		hint="Initializes the RequestHandler.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="moduleDelimiter" type="string" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setModuleDelimiter(arguments.moduleDelimiter) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a request made to the framework.">
		<!--- Set the EventArgs scope with Form/URL parameters. --->
		<cfset var eventArgs = getRequestEventArgs() />
		<!--- Get the Event. --->
		<cfset var result = getEventName(eventArgs) />
		
		<cfset handleEventRequest(result.eventName, eventArgs, result.moduleName) />
	</cffunction>
	
	<cffunction name="handleEventRequest" access="public" returntype="void" output="true"
		hint="Handles an event request made to the framework.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the requested event." />
		<cfargument name="eventArgs" type="struct" required="true" default="#StructNew()#"
			hint="The event arguments provided in the request." />
		<cfargument name="moduleName" type="string" required="true"
			hint="The name of the module for the requested event." />
		<cfset var exception = "" />
		<cfset var eventContext = appManager.createEventContext(arguments.eventName) />
		<cfset var moduleManager = getAppManager().getModuleManager() />
		<cfset var appManager = getAppManager()>
		
		<cftry>
			<cfif len(arguments.moduleName)>
				<cfif NOT moduleManager.isModuleDefined(arguments.moduleName)>
					<cfthrow type="MachII.framework.ModuleNotDefined" 
						message="The module '#arguments.moduleName#' for event '#arguments.eventName#' is not defined." />
					<cfset eventContext = appManager.createEventContext(arguments.eventName) />
				<cfelse>
					<cfset appManager = moduleManager.getModule(arguments.moduleName).getModuleAppManager() />
					<cfset eventContext = appManager.createEventContext(arguments.eventName) />
				</cfif>	
			<cfelse>
				<cfset eventContext = appManager.createEventContext(arguments.eventName) />
			</cfif>
			
			<cfset request.eventContext = eventContext />
			
			<cfif NOT appManager.getEventManager().isEventDefined(arguments.eventName, true)>
				<cfthrow type="MachII.framework.EventHandlerNotDefined" 
					message="Event-handler for event '#arguments.eventName#', module '#arguments.moduleName#' is not defined." />
			</cfif>
			
			<cfif appManager.getEventManager().isEventPublic(arguments.eventName, true)>
				<cfset eventContext.announceEvent(arguments.eventName, arguments.eventArgs) />
			<cfelse>
				<cfthrow type="MachII.framework.EventHandlerNotAccessible" 
					message="Event-handler for event '#arguments.eventName#' is not accessible." />
			</cfif>
			
			<!--- Handle any errors with the exception event.  --->
			<cfcatch type="any">
				<cfset exception = CreateObject("component", "MachII.util.Exception") />
				<cfset exception.wrapException(cfcatch) />
				<cfset eventContext.handleException(exception, true) />
			</cfcatch>
		</cftry>
		
		<!--- Start the event processing. --->
		<cfset eventContext.processEvents() />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="removeModuleName" access="private" returntype="string" output="false"
		hint="Return the module name removed from the event name">
		<cfargument name="eventName" type="string" required="true" hint="event name string with optional module name.">
		<cfset var cleanEventName = arguments.eventName />
		<cfset var moduleDelimiter = getAppManager().getPropertyManager().getProperty("moduleDelimiter") />
		
		<cfif listLen(arguments.eventName, moduleDelimiter) gt 1>
			<cfset cleanEventName = listDeleteAt(arguments.eventName, 1, moduleDelimiter) />
		</cfif>
		<cfreturn cleanEventName />
	</cffunction>
	
	<cffunction name="getModuleName" access="private" returntype="string" output="false">
		<cfargument name="eventName" type="string" required="true" hint="event name string with optional module name.">
		<cfset var moduleName = "" />
		<cfset var moduleDelimiter = getAppManager().getPropertyManager().getProperty("moduleDelimiter") />
		
		<cfif listLen(arguments.eventName, moduleDelimiter) gte 1>
			<cfset moduleName = listGetAt(arguments.eventName, 1, moduleDelimiter) />
		</cfif>
		
		<cfreturn moduleName />
	</cffunction>
	
	<cffunction name="getEventName" access="private" returntype="struct" output="false"
		hint="Gets the event name from the incoming event arg struct.">
		<cfargument name="eventArgs" type="struct" required="true" />
		
		<cfset var rawEvent = "" />
		<cfset var eventParam = getAppManager().getPropertyManager().getProperty("eventParameter") />
		<cfset var moduleDelimiter = getAppManager().getPropertyManager().getProperty("moduleDelimiter") />
		<cfset var result = StructNew() />
		
		<cfset result.moduleName = "" />
		
		<cfif StructKeyExists(arguments.eventArgs, eventParam) AND Len(arguments.eventArgs[eventParam])>
		
			<cfset rawEvent = arguments.eventArgs[eventParam] />
		
			<cfif listLen(rawEvent, moduleDelimiter) eq 2>
				<cfset result.moduleName = listGetAt(rawEvent, 1, moduleDelimiter) />
				<cfset result.eventName = listGetAt(rawEvent, 2, moduleDelimiter) />
			<cfelseif listLen(rawEvent, moduleDelimiter) eq 1 AND Right(rawEvent, 1) eq moduleDelimiter>
				<cfset result.moduleName = listGetAt(rawEvent, 1, moduleDelimiter) />
				<cfset result.eventName = getAppManager().getModuleManager().getModule(result.moduleName).getAppManager().getPropertyManager().getProperty("defaultEvent") />			
			<cfelse>
				<cfset result.eventName = rawEvent />
			</cfif>
		<cfelse>
			<cfset result.eventName = getAppManager().getPropertyManager().getProperty("defaultEvent") />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getRequestEventArgs" access="private" returntype="struct" output="false"
		hint="Builds a struct of incoming event args.">
		<cfset var eventArgs = StructNew() />
		<cfset var paramPrecedence = getAppManager().getPropertyManager().getProperty("parameterPrecedence") />
		<cfset var overwriteFormParams = (paramPrecedence EQ "url") />
		
		<!--- Build event args from form/url/SES --->
		<cfset StructAppend(eventArgs, form) />
		<cfset StructAppend(eventArgs, url, overwriteFormParams) />
		<cfset StructAppend(eventArgs, getAppManager().getRequestManager().parseSesParameters(cgi.PATH_INFO), overwriteFormParams) />
		
		<!--- Get redirect persist data and overwrite other args if conflct --->
		<cfset StructAppend(eventArgs, getAppManager().getRequestManager().readPersistEventData(eventArgs), true) />
		
		<cfreturn eventArgs />
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

	<cffunction name="setModuleDelimiter" access="private" returntype="void" output="false">
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfset variables.moduleDelimiter = arguments.moduleDelimiter />
	</cffunction>
	<cffunction name="getPairDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.moduleDelimiter />
	</cffunction>

</cfcomponent>