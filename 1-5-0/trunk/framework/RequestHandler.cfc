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
	<cfset variables.eventContext = CreateObject("component", "MachII.framework.EventContext") />
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
		<cfargument name="moduleDelimiter" type="string" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setModuleDelimiter(arguments.moduleDelimiter) />
		<cfset setMaxEvents(getAppManager().getPropertyManager().getProperty("maxEvents")) />
		
		<!--- Setup the event queue --->
		<cfset setEventQueue(CreateObject("component", "MachII.util.SizedQueue").init(getMaxEvents())) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles a request made to the framework.">
		<!--- Set the EventArgs scope with Form/URL parameters. --->
		<cfset var eventArgs = getRequestEventArgs() />
		<!--- Get the module and event names --->
		<cfset var result = parseEventParameter(eventArgs) />
		<cfset var appManager = getAppManager() />
		<cfset var moduleManager = getAppManager().getModuleManager() />
		<cfset var exception = "" />
		<cfset var nextEvent = "" />
		
		<cfset setRequestEventName(result.eventName) />
		<cfset setRequestModuleName(result.moduleName) />
		
		<!--- <cftry> --->
			<cfif len(result.moduleName)>
				<cfif NOT moduleManager.isModuleDefined(result.moduleName)>
					<cfthrow type="MachII.framework.ModuleNotDefined" 
						message="The module '#result.moduleName#' for event '#result.eventName#' is not defined." />
				<cfelse>
					<cfset appManager = appManager.getModuleManager().getModule(result.moduleName).getModuleAppManager() />
				</cfif>	
			</cfif>
			
			<cfif NOT appManager.getEventManager().isEventDefined(result.eventName, true)>
				<cfthrow type="MachII.framework.EventHandlerNotDefined" 
					message="Event-handler for event '#arguments.eventName#', module '#arguments.moduleName#' is not defined." />
			</cfif>
			
			<cfif appManager.getEventManager().isEventPublic(result.eventName, true)>
				<!--- Create the event. --->
				<cfset nextEvent = getAppManager().getEventManager().createEvent(result.moduleName, result.eventName, eventArgs, result.eventName, result.moduleName) />
				<!--- Queue the event. --->
				<cfset getEventQueue().put(nextEvent) />
				<cfset setupEventContext(appManager, nextEvent) />
			<cfelse>
				<cfthrow type="MachII.framework.EventHandlerNotAccessible" 
					message="Event-handler for event '#result.eventName#' is not accessible." />
			</cfif>
			
			<!--- Handle any errors with the exception event --->
			<!--- <cfcatch type="any">
				<cfset exception = wrapException(cfcatch) />
				<cfset handleException(exception, true) />
			</cfcatch>
		</cftry> --->
		
		<!--- Start the event processing --->
		<cfset processEvents() />
	</cffunction>
	
	<cffunction name="announceEvent" access="public" returntype="void" output="true"
		hint="Queues an event for the framework to handle.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="moduleName" type="string" required="false" default="" />
		
		<cfset var mapping = "" />
		<cfset var nextEvent = "" />
		<cfset var nextModuleName = arguments.moduleName />
		<cfset var nextEventName = arguments.eventName />
		<cfset var exception = "" />
		<cftrace text="announceEvent: module: #moduleName#, event: #eventName#">
		<cftry>
			<!--- Check for an event-mapping. --->
			<cfif isEventMappingDefined(arguments.eventName)>
				<cfset mapping = getEventMapping(arguments.eventName) />
				<cfset nextModuleName = mapping.mappingModuleName />
				<cfset nextEventName = mapping.mappingEventName />
			</cfif>
			<!--- Create the event. --->
			<cfset nextEvent = getAppManager().getEventManager().createEvent(nextModuleName, nextEventName, arguments.eventArgs, getRequestEventName(), getRequestModuleName()) />
			<!--- Queue the event. --->
			<cfset getEventQueue().put(nextEvent) />
			
			<cfcatch>
				<cfset exception = wrapException(cfcatch) />
				<cfset handleException(exception, true) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn variables.eventCount />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
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
		<cfset pluginManager.preProcess(variables.eventContext) />
		
		<cfloop condition="hasMoreEvents() AND getEventCount() LT getMaxEvents()">
			<cfset handleNextEvent() />
		</cfloop>
		
		<!--- If there are still events in the queue after done processing, then throw an exception. --->
		<cfif NOT getIsException() AND NOT getEventQueue().isEmpty()>
			<cfset exception = createException("MachII.framework.MaxEventsExceeded", "The maximum number of events (#getMaxEvents()#) the framework will process for a single request has been exceeded.") />
			<cfset handleException(exception, true) />
			
			<!--- Reset the count so the exception has the max number of event to process itself --->
			<cfset resetEventCount() />
			
			<cfloop condition="hasMoreEvents() AND getEventCount() LT getMaxEvents()">
				<cfset handleNextEvent() />
			</cfloop>
			
			<cfif NOT getEventQueue().isEmpty()>
				<cfthrow
					type="MachII.framework.MaxEventsExceededDuringException"
					message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
					detail="Please check your exception handling since it initiated an infinite loop." />
			</cfif>
		<!--- If we're in an exception and we've exceed the max queue, then something is 
			wrong with the developer's exception handling, so throw an exception --->
		<cfelseif getIsException() AND NOT getEventQueue().isEmpty()>
			<cfthrow
				type="MachII.framework.MaxEventsExceededDuringException"
				message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
				detail="Please check your exception handling since it initiated an infinite loop." />
		</cfif>
		
		<!--- Post-Process. --->
		<cfset pluginManager.postProcess(variables.eventContext) />
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
					<cfdump var="#cfcatch#">
					<cfabort>
					<cfset exception = wrapException(cfcatch) />
					<cfset handleException(exception, true) />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="handleEvent" access="private" returntype="void" output="true"
		hint="Handles the current event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var eventName = "" />
		<cfset var eventHandler = 0 />
		<cfset var topAppManager = 0 />
		<cfset var moduleAppManager = 0 />
		<cfset var previousEvent = 0 />
		
		<cfif isObject(getAppManager().getParent())>
			<cfset topAppManager = getAppManager().getParent() />
		<cfelse>
			<cfset topAppManager = getAppManager() />
		</cfif>
		
		<cfif len(arguments.event.getModuleName())>
			<cfset moduleAppManager = topAppManager.getModuleManager().getModule(arguments.event.getModuleName()).getModuleAppManager() />
		<cfelse>
			<cfset moduleAppManager = topAppManager>
		</cfif>
		
		<cfif variables.eventContext.hasCurrentEvent()>
			<cfset previousEvent = variables.eventContext.getCurrentEvent()>
		<cfelse>
			<cfset previousEvent = createObject("component", "MachII.framework.Event")>
		</cfif>
		
		<cfset setupEventContext(moduleAppManager, arguments.event, previousEvent) />
		
		<cfset request.event = arguments.event />
		
		<cfset eventName = arguments.event.getName() />
		
		<cfset eventHandler = moduleAppManager.getEventManager().getEventHandler(eventName, arguments.event.getModuleName()) />
		<cfset setCurrentEventHandler(eventHandler) />
		
		<!--- Pre-Invoke. --->
		<cfset getAppManager().getPluginManager().preEvent(variables.eventContext) />
		
		<cfset eventHandler.handleEvent(arguments.event, variables.eventContext) />
		
		<!--- Post-Invoke. --->
		<cfset getAppManager().getPluginManager().postEvent(variables.eventContext) />
	</cffunction>
	
	<cffunction name="setupEventContext" access="private" returntype="MachII.framework.EventContext" output="false"
		hint="Setup an EventContext instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="currentEvent" type="MachII.framework.Event" required="false"
			default="#createObject("component", "MachII.framework.Event")#" />
		<cfargument name="previousEvent" type="any" required="false" default="" />
		<cfreturn variables.eventContext.init(this, arguments.appManager, getEventQueue(), currentEvent, previousEvent) />
	</cffunction>

	<cffunction name="hasMoreEvents" access="public" returntype="boolean" output="false"
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

	<cffunction name="setCurrentEventHandler" access="private" returntype="void" output="false">
		<cfargument name="currentEventHandler" type="MachII.framework.EventHandler" required="true" />
		<cfset variables.currentEventHandler = arguments.currentEventHandler />
	</cffunction>
	<cffunction name="getCurrentEventHandler" access="private" returntype="MachII.framework.EventHandler" output="false">
		<cfreturn variables.currentEventHandler />
	</cffunction>

	<cffunction name="getIsException" access="private" returntype="string" output="false">
		<cfreturn variables.isException />
	</cffunction>	
	<cffunction name="setIsException" access="private" returntype="void" output="false">
		<cfargument name="isException" type="boolean" required="true" />
		<cfset variables.isException = arguments.isException />
	</cffunction>

	<cffunction name="setMaxEvents" access="public" returntype="void" output="false">
		<cfargument name="maxEvents" required="true" type="numeric" />
		<cfset variables.maxEvents = arguments.maxEvents />
	</cffunction>
	<cffunction name="getMaxEvents" access="public" returntype="numeric" output="false">
		<cfreturn variables.maxEvents />
	</cffunction>
	
	<cffunction name="createException" access="private" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with no cfcatch).">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorCode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedInfo" type="string" required="false" default="" />
		<cfargument name="tagContext" type="array" required="false" default="#ArrayNew(1)#" />
		
		<cfset var exception = CreateObject("component", "MachII.util.Exception") />
		<cfset exception.init(arguments.type, arguments.message, arguments.errorCode, arguments.detail, arguments.extendedInfo, arguments.tagContext) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>
	
	<cffunction name="wrapException" access="private" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with cfcatch).">
		<cfargument name="caughtException" type="any" required="true" />
		
		<cfset var exception = CreateObject("component", "MachII.util.Exception") />
		<cfset exception.wrapException(arguments.caughtException) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>

	<cffunction name="parseEventParameter" access="private" returntype="struct" output="false"
		hint="Gets the module and event name from the incoming event arg struct.">
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
	
	<cffunction name="setRequestEventName" access="private" returntype="void" output="false">
		<cfargument name="requestEventName" type="string" required="true" />
		<cfset variables.requestEventName = arguments.requestEventName />
	</cffunction>
	<cffunction name="getRequestEventName" access="private" returntype="string" output="false">
		<cfreturn variables.requestEventName />
	</cffunction>
	
	<cffunction name="setRequestModuleName" access="private" returntype="void" output="false">
		<cfargument name="requestModuleName" type="string" required="true" />
		<cfset variables.requestModuleName = arguments.requestModuleName />
	</cffunction>
	<cffunction name="getRequestModuleName" access="private" returntype="string" output="false">
		<cfreturn variables.requestModuleName />
	</cffunction>

</cfcomponent>