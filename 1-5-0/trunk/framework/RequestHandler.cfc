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
	hint="Handles request to event conversion for the framework. The framework workhorse and controls the event-queue functionality.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.eventContext = "" />
	<cfset variables.eventParameter = "" />
	<cfset variables.parameterPrecedence = "" />
	<cfset variables.moduleDelimiter = "" />
	<cfset variables.requestEventName = "" />
	<cfset variables.requestModuleName = "" />
	<cfset variables.eventQueue = "" />
	<cfset variables.eventCount = 0 />
	<cfset variables.maxEvents = 10 />
	<cfset variables.isProcessing = false />
	<cfset variables.isException = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestHandler" output="false"
		hint="Initializes the RequestHandler.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="eventParameter" type="string" required="true" />
		<cfargument name="parameterPrecedence" type="string" required="true" />
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfargument name="maxEvents" type="numeric" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setEventParameter(arguments.eventParameter) />
		<cfset setModuleDelimiter(arguments.moduleDelimiter) />
		<cfset setMaxEvents(arguments.maxEvents) />
		
		<!--- Setup the EventQueue --->
		<cfset setEventQueue(CreateObject("component", "MachII.util.SizedQueue").init(getMaxEvents())) />
				
		<!--- Setup the EventContext --->
		<cfset setEventContext(CreateObject("component", "MachII.framework.EventContext").init(this, getEventQueue())) />
		
		<!--- Set the EventContext into the request scope for backwards compatibility --->
		<cfset request.eventContext = getEventContext() />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a request made to the framework.">
		
		<cfset var eventArgs = getRequestEventArgs() />
		<cfset var result = parseEventParameter(eventArgs) />
		<cfset var appManager = getAppManager() />
		<cfset var moduleManager = getAppManager().getModuleManager() />
		<cfset var nextEvent = "" />
		<cfset var exception = "" />
		
		<cfset setRequestEventName(result.eventName) />
		<cfset setRequestModuleName(result.moduleName) />
		<cfset setupEventContext(appManager) />
		
		<cftry>
			<!--- Get the correct AppManager if inital event is in a module --->
			<cfif Len(result.moduleName)>
				<cfif NOT moduleManager.isModuleDefined(result.moduleName)>
					<cfthrow type="MachII.framework.ModuleNotDefined"  	
						message="The module '#result.moduleName#' for event '#result.eventName#' is not defined." />
				<cfelse>
					<cfset appManager = appManager.getModuleManager().getModule(result.moduleName).getModuleAppManager() />
				</cfif>
			</cfif>
			
			<!--- Check if the event exists and is publically accessible --->
			<cfif NOT appManager.getEventManager().isEventDefined(result.eventName, true)>
				<cfthrow type="MachII.framework.EventHandlerNotDefined" 
					message="Event-handler for event '#result.eventName#', module '#result.moduleName#' is not defined." />
			<cfelseif NOT appManager.getEventManager().isEventPublic(result.eventName, true)>
				<cfthrow type="MachII.framework.EventHandlerNotAccessible" 
					message="Event-handler for event '#result.eventName#', module '#result.moduleName#' is not accessible." />
			</cfif>
			
			<!--- Create and queue the event. --->
			<cfset nextEvent = appManager.getEventManager().createEvent(result.moduleName, result.eventName, eventArgs, result.eventName, result.moduleName) />
			<cfset getEventQueue().put(nextEvent) />
			<cfset setupEventContext(appManager, nextEvent) />
			
			<!--- Handle any errors with the exception event --->
			<cfcatch type="any">
				<cfset exception = wrapException(cfcatch) />
				<cfset getEventContext().handleException(exception, true) />
			</cfcatch>
		</cftry>
		
		<!--- Start the event processing --->
		<cfset processEvents() />
	</cffunction>
	
	<cffunction name="createException" access="public" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with no cfcatch).">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorCode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedInfo" type="string" required="false" default="" />
		<cfargument name="tagContext" type="array" required="false" default="#ArrayNew(1)#" />
		
		<cfset var exception = CreateObject("component", "MachII.util.Exception").init(arguments.type, arguments.message, arguments.errorCode, arguments.detail, arguments.extendedInfo, arguments.tagContext) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>
	
	<cffunction name="wrapException" access="public" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with cfcatch).">
		<cfargument name="caughtException" type="any" required="true" />
		
		<cfset var exception = CreateObject("component", "MachII.util.Exception").wrapException(arguments.caughtException) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn variables.eventCount />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="setupEventContext" access="private" returntype="void" output="false"
		hint="Setup an EventContext instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="currentEvent" type="any" required="false" default="" />
		<cfset getEventContext().setup(arguments.appManager, arguments.currentEvent) />
	</cffunction>
	
	<cffunction name="processEvents" access="private" returntype="void" output="true"
		hint="Begins processing of queued events. Can only be called once.">
	
		<cfset var pluginManager = "" />
		<cfset var exception = "" />
		
		<cfif getIsProcessing()>
			<cfthrow message="The RequestHandler is already processing the events in the queue. The processEvents() method can only be called once." />
		</cfif>
		<cfset setIsProcessing(true) />
		
		<cfset pluginManager = getAppManager().getPluginManager() />
	
		<!--- Pre-Process. --->
		<cfset pluginManager.preProcess(getEventContext()) />
		
		<cfloop condition="hasMoreEvents() AND getEventCount() LT getMaxEvents()">
			<cfset handleNextEvent() />
		</cfloop>
		
		<!--- If there are still events in the queue after done processing, then throw an exception. --->
		<cfif NOT getIsException() AND hasMoreEvents()>
			<cfset exception = createException("MachII.framework.MaxEventsExceeded", "The maximum number of events (#getMaxEvents()#) the framework will process for a single request has been exceeded.") />
			<cfset getEventContext().handleException(exception, true) />
			
			<!--- Reset the count so the exception has the max number of event to process itself --->
			<cfset resetEventCount() />
			
			<cfloop condition="hasMoreEvents() AND getEventCount() LT getMaxEvents()">
				<cfset handleNextEvent() />
			</cfloop>
			
			<cfif hasMoreEvents()>
				<cfthrow
					type="MachII.framework.MaxEventsExceededDuringException"
					message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
					detail="Please check your exception handling since it initiated an infinite loop." />
			</cfif>
		<!--- If we're in an exception and we've exceed the max queue, then something is 
			wrong with the developer's exception handling, so throw an exception --->
		<cfelseif getIsException() AND hasMoreEvents()>
			<cfthrow
				type="MachII.framework.MaxEventsExceededDuringException"
				message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
				detail="Please check your exception handling since it initiated an infinite loop." />
		</cfif>
		
		<!--- Post-Process. --->
		<cfset pluginManager.postProcess(getEventContext()) />
		<cfset setIsProcessing(false) />
	</cffunction>
	
	<cffunction name="handleNextEvent" access="private" returntype="void" output="true"
		hint="Handles the next event in the queue.">
		<cfset var exception = 0 />
		
		<cftry>
			<cfset incrementEventCount() />
			<cfset handleEvent(getEventQueue().get()) />
			
			<cfcatch type="AbortEventException">
				<!--- Do nothing, just continue event processing. --->
			</cfcatch>
			<cfcatch type="any">
				<cfif getIsException()>
					<cfrethrow />
				<cfelse>
					<cfset exception = wrapException(cfcatch) />
					<cfset getEventContext().handleException(exception, true) />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="handleEvent" access="private" returntype="void" output="true"
		hint="Handles the current event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var eventHandler = 0 />
		<cfset var topAppManager = 0 />
		<cfset var thisEventAppManager = 0 />
		
		<cfif IsObject(getAppManager().getParent())>
			<cfset topAppManager = getAppManager().getParent() />
		<cfelse>
			<cfset topAppManager = getAppManager() />
		</cfif>
		
		<cfif Len(arguments.event.getModuleName())>
			<cfset thisEventAppManager = topAppManager.getModuleManager().getModule(arguments.event.getModuleName()).getModuleAppManager() />
		<cfelse>
			<cfset thisEventAppManager = topAppManager />
		</cfif>
		
		<cfset setupEventContext(thisEventAppManager, arguments.event) />
		<cfset request.event = arguments.event />
		
		<!--- Pre-Event --->
		<cfset thisEventAppManager.getPluginManager().preEvent(getEventContext()) />

		<!--- Run command --->
		<cfset eventHandler = thisEventAppManager.getEventManager().getEventHandler(arguments.event.getName(), arguments.event.getModuleName()) />		
		<cfset eventHandler.handleEvent(arguments.event, getEventContext()) />
		
		<!--- Post-Event --->
		<cfset thisEventAppManager.getPluginManager().postEvent(getEventContext()) />
	</cffunction>

	<cffunction name="hasMoreEvents" access="private" returntype="boolean" output="false"
		hint="Checks if there are more events in the queue.">
		<cfreturn NOT getEventQueue().isEmpty() />
	</cffunction>

	<cffunction name="incrementEventCount" access="private" returntype="void" output="false"
		hint="Increments the current event count by 1.">
		<cfset variables.eventCount = variables.eventCount + 1 />
	</cffunction>	
	<cffunction name="resetEventCount" access="private" returntype="void" output="false"
		hint="Reset the current event count.">
		<cfset variables.eventCount = 0 />
	</cffunction>

	<cffunction name="parseEventParameter" access="private" returntype="struct" output="false"
		hint="Gets the module and event name from the incoming event arg struct.">
		<cfargument name="eventArgs" type="struct" required="true" />
		
		<cfset var rawEvent = "" />
		<cfset var eventParameter = getEventParameter() />
		<cfset var moduleDelimiter = getModuleDelimiter() />
		<cfset var result = StructNew() />
		
		<!--- Get the event and module names --->
		<cfif StructKeyExists(arguments.eventArgs, eventParameter) AND Len(arguments.eventArgs[eventParameter])>
		
			<cfset rawEvent = arguments.eventArgs[eventParameter] />
		
			<!--- Has a module --->
			<cfif listLen(rawEvent, moduleDelimiter) eq 2>
				<cfset result.moduleName = listGetAt(rawEvent, 1, moduleDelimiter) />
				<cfset result.eventName = listGetAt(rawEvent, 2, moduleDelimiter) />
			<!--- Has a module, but no event is defined so announce the default event for that module (i.e sample:) --->
			<cfelseif listLen(rawEvent, moduleDelimiter) eq 1 AND Right(rawEvent, 1) eq moduleDelimiter>
				<cfset result.moduleName = listGetAt(rawEvent, 1, moduleDelimiter) />
				<cfset result.eventName = getAppManager().getModuleManager().getModule(result.moduleName).getAppManager().getPropertyManager().getProperty("defaultEvent") />			
			<!--- Has no module --->
			<cfelse>
				<cfset result.moduleName = "" />
				<cfset result.eventName = rawEvent />
			</cfif>
		<!--- No event so announce the default event --->
		<cfelse>
			<cfset result.moduleName = "" />
			<cfset result.eventName = getAppManager().getPropertyManager().getProperty("defaultEvent") />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getRequestEventArgs" access="private" returntype="struct" output="false"
		hint="Builds a struct of incoming event args.">
		<cfset var eventArgs = StructNew() />
		<cfset var overwriteFormParams = (getParameterPrecedence() EQ "url") />
		
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
	
	<cffunction name="setEventParameter" access="private" returntype="void" output="false">
		<cfargument name="eventParameter" type="string" required="true" />
		<cfset variables.eventParameter = arguments.eventParameter />
	</cffunction>
	<cffunction name="getEventParameter" access="private" returntype="string" output="false">
		<cfreturn variables.eventParameter />
	</cffunction>
	
	<cffunction name="setParameterPrecedence" access="private" returntype="void" output="false">
		<cfargument name="parameterPrecedence" type="string" required="true" />
		<cfset variables.parameterPrecedence = arguments.parameterPrecedencerameter />
	</cffunction>
	<cffunction name="getParameterPrecedence" access="private" returntype="string" output="false">
		<cfreturn variables.parameterPrecedence />
	</cffunction>

	<cffunction name="setModuleDelimiter" access="private" returntype="void" output="false">
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfset variables.moduleDelimiter = arguments.moduleDelimiter />
	</cffunction>
	<cffunction name="getModuleDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.moduleDelimiter />
	</cffunction>
	
	<cffunction name="setRequestEventName" access="private" returntype="void" output="false">
		<cfargument name="requestEventName" type="string" required="true" />
		<cfset variables.requestEventName = arguments.requestEventName />
	</cffunction>
	<cffunction name="getRequestEventName" access="public" returntype="string" output="false">
		<cfreturn variables.requestEventName />
	</cffunction>
	
	<cffunction name="setRequestModuleName" access="private" returntype="void" output="false">
		<cfargument name="requestModuleName" type="string" required="true" />
		<cfset variables.requestModuleName = arguments.requestModuleName />
	</cffunction>
	<cffunction name="getRequestModuleName" access="public" returntype="string" output="false">
		<cfreturn variables.requestModuleName />
	</cffunction>

	<cffunction name="setEventContext" access="private" returntype="void" output="false">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfset variables.eventContext = arguments.eventContext />
	</cffunction>	
	<cffunction name="getEventContext" access="public" returntype="MachII.framework.EventContext" output="false">
		<cfreturn variables.eventContext />
	</cffunction>
	
	<cffunction name="setEventQueue" access="private" returntype="void" output="false">
		<cfargument name="eventQueue" type="MachII.util.SizedQueue" required="true" />
		<cfset variables.eventQueue = arguments.eventQueue />
	</cffunction>
	<cffunction name="getEventQueue" access="private" returntype="MachII.util.SizedQueue" output="false">
		<cfreturn variables.eventQueue />
	</cffunction>
	
	<cffunction name="setIsProcessing" access="private" returntype="void" output="false">
		<cfargument name="isProcessing" type="boolean" required="true" />
		<cfset variables.isProcessing = arguments.isProcessing />
	</cffunction>
	<cffunction name="getIsProcessing" access="private" returntype="boolean" output="false">
		<cfreturn variables.isProcessing />
	</cffunction>

	<cffunction name="getIsException" access="private" returntype="string" output="false">
		<cfreturn variables.isException />
	</cffunction>	
	<cffunction name="setIsException" access="private" returntype="void" output="false">
		<cfargument name="isException" type="boolean" required="true" />
		<cfset variables.isException = arguments.isException />
	</cffunction>
	
	<cffunction name="setMaxEvents" access="private" returntype="void" output="false">
		<cfargument name="maxEvents" required="true" type="numeric" />
		<cfset variables.maxEvents = arguments.maxEvents />
	</cffunction>
	<cffunction name="getMaxEvents" access="private" returntype="numeric" output="false">
		<cfreturn variables.maxEvents />
	</cffunction>

</cfcomponent>