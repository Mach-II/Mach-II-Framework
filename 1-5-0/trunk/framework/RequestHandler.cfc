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
$Id: RequestHandler.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.1

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
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initializes the RequestHandler.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a request made to the framework.">
		<!--- Set the EventArgs scope with Form/URL parameters. --->
		<cfset var eventArgs = getRequestEventArgs() />
		<!--- Get the Event. --->
		<cfset var eventName = getEventName(eventArgs) />
		
		<cfset handleEventRequest(eventName, eventArgs) />
	</cffunction>
	
	<cffunction name="handleEventRequest" access="public" returntype="void" output="true"
		hint="Handles an event request made to the framework.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the requested event." />
		<cfargument name="eventArgs" type="struct" required="true" default="#StructNew()#"
			hint="The event arguments provided in the request." />
		<cfset var exception = "" />
		<cfset var eventContext = getAppManager().createEventContext(arguments.eventName) />
		<cfset request.eventContext = eventContext />
		
		<cftry>
			<cfif NOT getAppManager().getEventManager().isEventDefined(arguments.eventName)>
				<cfthrow type="MachII.framework.EventHandlerNotDefined" 
					message="Event-handler for event '#arguments.eventName#' is not defined." />
			</cfif>
			
			<cfif getAppManager().getEventManager().isEventPublic(arguments.eventName)>
				<cfset eventContext.announceEvent(arguments.eventName, arguments.eventArgs) />
			<cfelse>
				<cfthrow type="MachII.framework.EventHandlerNotAccessible" 
					message="Event-handler for event '#arguments.eventName#' is not accessible." />
			</cfif>
			
			<!--- Handle any errors with the exception event. --->
			<cfcatch type="any">
				<cfset exception = CreateObject('component', 'MachII.util.Exception') />
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
	<cffunction name="getEventName" access="private" returntype="string" output="false">
		<cfargument name="eventArgs" type="struct" required="true" />
		<cfset var eventParam = getAppManager().getPropertyManager().getProperty('eventParameter') />
		<cfset var eventName = "" />
		
		<cfif StructKeyExists(arguments.eventArgs, eventParam) AND arguments.eventArgs[eventParam] NEQ ''>
			<cfset eventName = arguments.eventArgs[eventParam] />
		<cfelse>
			<cfset eventName = getAppManager().getPropertyManager().getProperty('defaultEvent') />
		</cfif>
		
		<cfreturn eventName />
	</cffunction>
	
	<cffunction name="getRequestEventArgs" access="private" returntype="struct" output="false">
		<cfset var eventArgs = StructNew() />
		<cfset var paramPrecedence = getAppManager().getPropertyManager().getProperty('parameterPrecedence') />
		<cfset var overwriteFormParams = (paramPrecedence EQ 'url') />
		
		<cfset StructAppend(eventArgs, form) />
		<cfset StructAppend(eventArgs, url, overwriteFormParams) />
		
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

</cfcomponent>