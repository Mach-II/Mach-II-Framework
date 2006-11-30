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
$Id: EventContext.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.1

Notes:
- Added request event name functionality. (pfarrell)
--->
<cfcomponent 
	displayname="EventContext"
	output="false"
	hint="The framework workhorse. Handles event-queue functionality and event-command execution. Controls the event queue and event processing mechanism for a request/event lifecycle.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventCount = 0 />
	<cfset variables.viewContext = "" />
	<cfset variables.appManager = "" />
	<cfset variables.eventQueue = "" />
	<cfset variables.requestEventName = "" />
	<cfset variables.currentEventHandler = "" />
	<cfset variables.currentEvent = "" />
	<cfset variables.mappings = StructNew() />
	<cfset variables.exceptionEventName = "" />
	<cfset variables.maxEvents = 10 />
	<cfset variables.isProcessing = false />
	<cfset variables.previousEvent = "" />
	<cfset variables.isException = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventContext" output="false"
		hint="Initalizes the event-context.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="requestEventName" type="string" required="false" default="" />
		
		<cfset var eventQueue = 0 />
		<cfset var viewContext = 0 />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setRequestEventName(arguments.requestEventName) />
		<cfset setExceptionEventName(getAppManager().getPropertyManager().getProperty('exceptionEvent')) />
		<cfset setMaxEvents(getAppManager().getPropertyManager().getProperty('maxEvents')) />
		
		<!--- Setup the event Queue. --->
		<cfset eventQueue = CreateObject('component', 'MachII.util.SizedQueue') />
		<cfset eventQueue.init(getMaxEvents()) />
		<cfset setEventQueue(eventQueue) />
		
		<!--- Setup the ViewContext. --->
		<cfset viewContext = CreateObject('component', 'MachII.framework.ViewContext') />
		<cfset viewContext.init(getAppManager()) />
		<cfset setViewContext(viewContext) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="announceEvent" access="public" returntype="void" output="true"
		hint="Queues an event for the framework to handle.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var nextEventName = "" />
		<cfset var nextEvent = "" />
		<cfset var exception = "" />
		
		<cftry>
			<!--- Check for an event-mapping. --->
			<cfset nextEventName = getEventMapping(arguments.eventName) />
			<!--- Create the event. --->
			<cfset nextEvent = getAppManager().getEventManager().createEvent(nextEventName, arguments.eventArgs) />
			<!--- Put the request event name --->
			<cfset nextEvent.setRequestName(getRequestEventName()) />
			<!--- Queue the event. --->
			<cfset getEventQueue().put(nextEvent) />
			
			<cfcatch>
				<cfset exception = wrapException(cfcatch) />
				<cfset handleException(exception, true) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="setCurrentEvent" access="private" returntype="void" output="false">
		<cfargument name="currentEvent" type="MachII.framework.Event" required="true" />
		<cfset variables.currentEvent = arguments.currentEvent />
	</cffunction>
	<cffunction name="getCurrentEvent" access="public" returntype="MachII.framework.Event" output="false"
		hint="Gets the current event object.">
		<cfreturn variables.currentEvent />
	</cffunction>
	<cffunction name="hasCurrentEvent" access="public" returntype="boolean" output="false"
		hint="Checks if the current event has an event object.">
		<cfreturn IsObject(variables.currentEvent) />
	</cffunction>
	
	<cffunction name="getNextEvent" access="public" returntype="MachII.framework.Event" output="false"
		hint="Peeks at the next event in the queue.">
		<cfreturn getEventQueue().peek() />
	</cffunction>
	<cffunction name="hasNextEvent" access="public" returntype="boolean" output="false"
		hint="Peeks at the next event in the queue.">
		<cfreturn hasMoreEvents() />
	</cffunction>
	
	<cffunction name="setPreviousEvent" access="private" returntype="void" output="false">
		<cfargument name="previousEvent" type="MachII.framework.Event" required="true" />
		<cfset variables.previousEvent = arguments.previousEvent />
	</cffunction>
	<cffunction name="getPreviousEvent" access="public" returntype="MachII.framework.Event" output="false"
		hint="Returns the previous handled event.">
		<cfreturn variables.previousEvent />
	</cffunction>
	<cffunction name="hasPreviousEvent" access="public" returntype="boolean" output="false"
		hint="Returns whether or not getPreviousEvent() can be called to return an event.">
		<cfreturn IsObject(variables.previousEvent) />
	</cffunction>
	
	<cffunction name="hasMoreEvents" access="public" returntype="boolean" output="false"
		hint="Checks if there are more events in the queue.">
		<cfreturn NOT getEventQueue().isEmpty() />
	</cffunction>
	
	<cffunction name="setEventMapping" access="public" returntype="string" output="false"
		hint="Sets an event mapping.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="mappingName" type="string" required="true" />
		<cfset variables.mappings[arguments.eventName] = arguments.mappingName />
	</cffunction>
	<cffunction name="getEventMapping" access="public" returntype="string" output="false"
		hint="Gets an event mappiong by the event name.">
		<cfargument name="eventName" type="string" required="true" />
		<cfif StructKeyExists(variables.mappings, arguments.eventName)>
			<cfreturn variables.mappings[arguments.eventName] />
		<cfelse>
			<cfreturn arguments.eventName />
		</cfif>
	</cffunction>
	<cffunction name="clearEventMappings" access="public" returntype="void" output="false"
		hint="Clears the current event mappings.">
		<cfset StructClear(variables.mappings) />
	</cffunction>
	
	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="Handles an exception.">
		<cfargument name="exception" type="MachII.util.Exception" required="true" />
		<cfargument name="clearEventQueue" type="boolean" required="false" default="true" />
		
		<cfset var nextEventName = "" />
		<cfset var exceptionEvent = "" />
		
		<cftry>
			<cfset nextEventName = getEventMapping(getExceptionEventName()) />
			<cfset exceptionEvent = getAppManager().getEventManager().createEvent(nextEventName) />
			<!--- Put the request event name --->
			<cfset exceptionEvent.setRequestName(getRequestEventName()) />
			<!--- Put the exception object --->
			<cfset exceptionEvent.setArg('exception', arguments.exception) />
			
			<cfif hasCurrentEvent()>
				<cfset exceptionEvent.setArg('exceptionEvent', getCurrentEvent()) />
			</cfif>
			
			<cfset getAppManager().getPluginManager().handleException(this, arguments.exception) />
			
			<cfif arguments.clearEventQueue>
				<cfset variables.clearEventQueue() />
			</cfif>
			
			<!---<cfset handleEvent(exceptionEvent) /> --->
			<!--- Queue the exception event instead of handling it immediately. 
			The queue is cleared by default so it will be handled first anyway. --->
			<cfset getEventQueue().put(exceptionEvent) />
			
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="displayView" access="public" returntype="void" output="true"
		hint="Displays a view.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="viewName" type="string" required="true" />
		<cfargument name="contentKey" type="string" required="false" default="" />
		<cfargument name="contentArg" type="string" required="false" default="" />
		<cfargument name="append" type="boolean" required="false" default="false" />
		
		<!--- Pre-Invoke. --->
		<cfset getAppManager().getPluginManager().preView(this) />
		
		<cfset getViewContext().displayView(arguments.event, arguments.viewName, arguments.contentKey, arguments.contentArg, arguments.append) />
		
		<!--- Post-Invoke. --->
		<cfset getAppManager().getPluginManager().postView(this) />
	</cffunction>
	
	<cffunction name="processEvents" access="public" returntype="void" output="true"
		hint="Begins processing of queued events. Can only be called once.">
	
		<cfset var pluginManager = "" />
		<cfset var eventManager = "" />
		<cfset var exception = "" />
		
		<cfif getIsProcessing()>
			<cfthrow message="The EventContext is already processing the events in the queue. The processEvents() method can only be called once." />
		</cfif>
		<cfset setIsProcessing(true) />
		
		<cfset pluginManager = getAppManager().getPluginManager() />
		<cfset eventManager = getAppManager().getEventManager() />
	
		<!--- Pre-Process. --->
		<cfset pluginManager.preProcess(this) />
		
		<cfloop condition="hasMoreEvents() AND getEventCount() LT getMaxEvents()">
			<cfset handleNextEvent() />
		</cfloop>
		
		<!--- If there are still events in the queue after done processing, then throw an exception. --->
		<cfif NOT getEventQueue().isEmpty()>
			<cfset exception = createException("MachII.framework.MaxEventsExceeded", "The maximum number of events (#getMaxEvents()#) the framework will process for a single request has been exceeded.") />
			<cfset handleException(exception, true) />
		</cfif>
		
		<!--- Post-Process. --->
		<cfset pluginManager.postProcess(this) />
		<cfset setIsProcessing(false) />
	</cffunction>
	
	<cffunction name="clearEventQueue" access="public" returntype="void" output="false"
		hint="Clears the event queue.">
		<cfset getEventQueue().clear() />
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn variables.eventCount />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->	
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
		
		<cfif hasCurrentEvent()>
			<cfset setPreviousEvent(getCurrentEvent()) />
		</cfif>
		<cfset setCurrentEvent(arguments.event) />
		<cfset request.event = arguments.event />
		
		<cfset eventName = arguments.event.getName() />
		
		<cfset eventHandler = getAppManager().getEventManager().getEventHandler(eventName) />
		<cfset setCurrentEventHandler(eventHandler) />
		
		<!--- Pre-Invoke. --->
		<cfset getAppManager().getPluginManager().preEvent(this) />
		
		<cfset eventHandler.handleEvent(arguments.event, this) />
		
		<!--- Post-Invoke. --->
		<cfset getAppManager().getPluginManager().postEvent(this) />
		
		<!--- Event-mappings only live for one event, so clear them when this event is done executing. --->
		<cfset clearEventMappings() />
	</cffunction>
	
	<cffunction name="createException" access="private" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with no cfcatch).">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorCode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedInfo" type="string" required="false" default="" />
		<cfargument name="tagContext" type="array" required="false" default="#ArrayNew(1)#" />
		
		<cfset var exception = CreateObject('component', 'MachII.util.Exception') />
		<cfset exception.init(arguments.type, arguments.message, arguments.errorCode, arguments.detail, arguments.extendedInfo, arguments.tagContext) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>
	
	<cffunction name="wrapException" access="private" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with cfcatch).">
		<cfargument name="caughtException" type="any" required="true" />
		
		<cfset var exception = CreateObject('component', 'MachII.util.Exception') />
		<cfset exception.wrapException(arguments.caughtException) />
		<cfset setIsException(true) />
		
		<cfreturn exception />
	</cffunction>	
	
	<cffunction name="incrementEventCount" access="private" returntype="void" output="false"
		hint="Increments the current event count by 1.">
		<cfset variables.eventCount = variables.eventCount + 1 />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getAppManager" access="private" type="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	
	<cffunction name="getViewContext" access="private" type="MachII.framework.ViewContext" output="false">
		<cfreturn variables.viewContext />
	</cffunction>
	<cffunction name="setViewContext" access="private" returntype="void" output="false">
		<cfargument name="viewContext" type="MachII.framework.ViewContext" required="true" />
		<cfset variables.viewContext = arguments.viewContext />
	</cffunction>
	
	<cffunction name="setRequestEventName" access="private" returntype="void" output="false">
		<cfargument name="requestEventName" type="string" required="true" />
		<cfset variables.requestEventName = arguments.requestEventName />
	</cffunction>
	<cffunction name="getRequestEventName" access="private" returntype="string" output="false">
		<cfreturn variables.requestEventName />
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
	
	<cffunction name="setExceptionEventName" access="public" returntype="void" output="false">
		<cfargument name="exceptionEventName" type="string" required="true" />
		<cfset variables.exceptionEventName = arguments.exceptionEventName />
	</cffunction>
	<cffunction name="getExceptionEventName" access="public" returntype="string" output="false">
		<cfreturn variables.exceptionEventName />
	</cffunction>

</cfcomponent>