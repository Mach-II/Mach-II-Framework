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
	<cfset variables.requestHandler = "" />
	<cfset variables.appManager = "" />
	<cfset variables.eventQueue = "" />
	<cfset variables.viewContext = CreateObject("component", "MachII.framework.ViewContext") />
	<cfset variables.currentEventHandler = "" />
	<cfset variables.currentEvent = "" />
	<cfset variables.mappings = StructNew() />
	<cfset variables.exceptionEventName = "" />
	<cfset variables.previousEvent = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventContext" output="false"
		hint="Initalizes the event-context.">
		<cfargument name="requestHandler" type="MachII.framework.RequestHandler" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="eventQueue" type="MachII.util.SizedQueue" required="true" />
		<cfargument name="requestEventName" type="string" required="false" default="" />
		<cfargument name="requestModuleName" type="string" required="false" default="" />
		
		<cfset setRequestHandler(arguments.requestHandler) />
		<cfset setAppManager(arguments.appManager) />
		<cfset setEventQueue(arguments.eventQueue) />
		<cfset setRequestEventName(arguments.requestEventName) />
		<cfset setRequestModuleName(arguments.requestModuleName) />
		<cfset setExceptionEventName(getAppManager().getPropertyManager().getProperty("exceptionEvent")) />
		
		<!--- (re)init the ViewContext. --->
		<cfset getViewContext().init(getAppManager()) />
		
		<!--- Clear the event mappings --->
		<cfset clearEventMappings() />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
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
	
	<cffunction name="executeSubroutine" access="public" returntype="void" output="true"
		hint="Executes a subroutine.">
		<cfargument name="subroutineName" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var subroutineHandler = "" />
		<cfset var exception = "" />
		
		<cftry>
			<!--- Get the subroutine handler --->		
			<cfset subroutineHandler = getAppManager().getSubroutineManager().getSubroutineHandler(arguments.subroutineName) />
			<!--- Execute the subroutine --->
			<cfset subroutineHandler.handleSubroutine(arguments.event, this) />
					
			<cfcatch>
				<cfset exception = wrapException(cfcatch) />
				<cfset handleException(exception, true) />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setEventMapping" access="public" returntype="string" output="false"
		hint="Sets an event mapping.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="mappingName" type="string" required="true" />
		<cfargument name="mappingModuleName" type="string" required="false" default="" />

		<cfset var temp = StructNew() />

		<cfif NOT Len(arguments.mappingModuleName)>
			<cfset argument.mappingModuleName = getCurrentEvent().getModuleName() />
		</cfif>
		
		<cfset temp.mappingEventName = arguments.mappingName />
		<cfset temp.mappingModuleName = arguments.mappingModuleName />
		
		<cfset variables.mappings[arguments.eventName] = temp />
	</cffunction>
	<cffunction name="getEventMapping" access="public" returntype="struct" output="false"
		hint="Gets an event mapping by the event name.">
		<cfargument name="eventName" type="string" required="true" />
		
		<cfset var temp = StructNew() />
		
		<cfif StructKeyExists(variables.mappings, arguments.eventName)>
			<cfreturn variables.mappings[arguments.eventName] />
		<cfelse>
			<cfset temp.mappingEventName = arguments.eventName />
			<cfset temp.mappingModuleName = getCurrentEvent().getModuleName() />
			<cfreturn temp />
		</cfif>
	</cffunction>
	<cffunction name="isEventMappingDefined" type="public" returntype="boolean" output="false"
		hint="Checks if an event mapping is defined.">
		<cfargument name="eventName" type="string" required="true" />
		<cfif StructKeyExists(variables.mappings, arguments.eventName)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	<cffunction name="clearEventMappings" access="public" returntype="void" output="false"
		hint="Clears the current event mappings.">
		<cfset StructClear(variables.mappings) />
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

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
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
	<cffunction name="hasMoreEvents" access="public" returntype="boolean" output="false"
		hint="Checks if there are more events in the queue.">
		<cfreturn NOT getEventQueue().isEmpty() />
	</cffunction>
	
	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="Handles an exception.">
		<cfargument name="exception" type="MachII.util.Exception" required="true" />
		<cfargument name="clearEventQueue" type="boolean" required="false" default="true" />
		
		<cfset var eventArgs = StructNew() />
		
		<cftry>
			<!--- Create eventArg data --->			
			<cfset eventArgs.exception = arguments.exception />
			<cfif hasCurrentEvent()>
				<cfset eventArgs.exceptionEvent = getCurrentEvent() />
			</cfif>
			
			<!--- Call the handleException point in the plugins --->
			<cfset getAppManager().getPluginManager().handleException(this, arguments.exception) />
			
			<!--- Clear event queue --->
			<cfif arguments.clearEventQueue>
				<cfset variables.clearEventQueue() />
			</cfif>
			
			<!--- Queue the exception event instead of handling it immediately. 
			The queue is cleared by default so it will be handled first anyway. --->
			<cfset announceEvent(getExceptionEventName(), eventArgs) />
			
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to index.cfm." />			
		<cfreturn getAppManager().getRequestManager().buildUrl(getCurrentEvent().getModuleName(), arguments.eventName, arguments.urlParameters, arguments.urlBase) />
	</cffunction>
	
	<cffunction name="buildUrlToModule" access="public" returntype="string" output="false"
		hint="Builds a framework specific url and automatically escapes entities for html display.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with. Defaults to current module if empty string." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to index.cfm." />
		
		<!--- Pull the current module name if empty string (we use the request scope so we do not
			pollute the variables scope which is shared in the views) --->
		<cfif NOT Len(arguments.moduleName)>
			<cfset argument.moduleName = getCurrentEvent().getModuleName() />
		</cfif>
		<cfreturn getAppManager().getRequestManager().buildUrl(arguments.moduleName, arguments.eventName, arguments.urlParameters, arguments.urlBase) />
	</cffunction>
	
	<cffunction name="savePersistEventData" access="public" returntype="string" output="false"
		hint="Saves persisted event data and returns the persistId.">
		<cfargument name="eventArgs" type="struct" required="true" />
		<cfreturn getAppManager().getRequestManager().savePersistEventData(arguments.eventArgs) />
	</cffunction>

	<cffunction name="clearEventQueue" access="public" returntype="void" output="false"
		hint="Clears the event queue.">
		<cfset getEventQueue().clear() />
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn getRequestHandler().getEventCount() />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->	
	

	<!---
	ACCESSORS
	--->
	<cffunction name="getRequestHandler" access="private" type="MachII.framework.RequestHandler" output="false">
		<cfreturn variables.requestHandler />
	</cffunction>
	<cffunction name="setRequestHandler" access="private" returntype="void" output="false">
		<cfargument name="requestHandler" type="MachII.framework.RequestHandler" required="true" />
		<cfset variables.requestHandler = arguments.requestHandler />
	</cffunction>
	
	<cffunction name="getAppManager" access="private" type="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	
	<cffunction name="getEventQueue" access="private" type="MachII.framework.AppManager" output="false">
		<cfreturn variables.eventQueue />
	</cffunction>
	<cffunction name="setEventQueue" access="private" returntype="void" output="false">
		<cfargument name="eventQueue" type="MachII.utils.SizedQueue" required="true" />
		<cfset variables.eventQueue = arguments.eventQueue />
	</cffunction>
	
	<cffunction name="getViewContext" access="private" type="MachII.framework.ViewContext" output="false">
		<cfreturn variables.viewContext />
	</cffunction>
	<cffunction name="setViewContext" access="private" returntype="void" output="false">
		<cfargument name="viewContext" type="MachII.framework.ViewContext" required="true" />
		<cfset variables.viewContext = arguments.viewContext />
	</cffunction>
	
	<cffunction name="setExceptionEventName" access="public" returntype="void" output="false">
		<cfargument name="exceptionEventName" type="string" required="true" />
		<cfset variables.exceptionEventName = arguments.exceptionEventName />
	</cffunction>
	<cffunction name="getExceptionEventName" access="public" returntype="string" output="false">
		<cfreturn variables.exceptionEventName />
	</cffunction>

</cfcomponent>