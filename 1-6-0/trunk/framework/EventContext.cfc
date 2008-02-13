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
Updated version: 1.5.0

Notes:
--->
<cfcomponent 
	displayname="EventContext"
	output="false"
	hint="Handles event-command execution and event processing mechanism for an event lifecycle.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.requestHandler = "" />
	<cfset variables.appManager = "" />
	<cfset variables.eventQueue = "" />
	<cfset variables.viewContext =  ""/>
	<cfset variables.currentEvent = "" />
	<cfset variables.previousEvent = "" />
	<cfset variables.mappings = StructNew() />
	<cfset variables.exceptionEventName = "" />
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventContext" output="false"
		hint="Initalizes the event-context.">
		<cfargument name="requestHandler" type="MachII.framework.RequestHandler" required="true" />
		<cfargument name="eventQueue" type="MachII.util.SizedQueue" required="true" />
		
		<cfset setRequestHandler(arguments.requestHandler) />
		<cfset setEventQueue(arguments.eventQueue) />
		<cfset setViewContext(CreateObject("component", "MachII.framework.ViewContext")) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Sets up the event-context.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="currentEvent" type="any" required="false" default="" />
		
		<cfset setAppManager(arguments.appManager) />
		<cfif hasCurrentEvent()>
			<cfset setPreviousEvent(getCurrentEvent()) />
		</cfif>
		<cfif IsObject(arguments.currentEvent)>
			<cfset setCurrentEvent(arguments.currentEvent) />
		</cfif>
		
		<!--- Set the exception event --->
		<cfset setExceptionEventName(getAppManager().getPropertyManager().getProperty("exceptionEvent")) />
		
		<!--- (re)init the ViewContext. --->
		<cfset getViewContext().init(getAppManager()) />
		
		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<!--- Clear the event mappings --->
		<cfset clearEventMappings() />
	</cffunction>	
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="announceEvent" access="public" returntype="void" output="true"
		hint="Queues an event for the framework to handle.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="moduleName" type="string" required="false" default="#getAppManager().getModuleName()#" />
		
		<cfset var mapping = "" />
		<cfset var nextEvent = "" />
		<cfset var nextModuleName = arguments.moduleName />
		<cfset var nextEventName = arguments.eventName />
		<cfset var exception = "" />
		<cfset var missingEvent = "" />
		<cfset var log = getLog() />
		
		<cftry>
			<!--- Check for an event-mapping. --->
			<cfif isEventMappingDefined(arguments.eventName)>
				<cfset mapping = getEventMapping(arguments.eventName) />
				<cfset nextModuleName = mapping.moduleName />
				<cfset nextEventName = mapping.eventName />
				
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Announcing event '#nextEventName#' in module '#nextModuleName#' mapped from '#arguments.eventName#'.") />
				</cfif>
			<cfelse>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Announcing event '#nextEventName#' in module '#nextModuleName#'.") />
				</cfif>
			</cfif>
			
			<!--- Create the event. --->
			<cfset nextEvent = getAppManager().getEventManager().createEvent(nextModuleName, nextEventName, arguments.eventArgs, getRequestHandler().getRequestEventName(), getRequestHandler().getRequestModuleName()) />
			<!--- Queue the event. --->
			<cfset getEventQueue().put(nextEvent) />
			
			<cfcatch  type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("Cannot announce event '#nextEventName#' in module '#nextModuleName#' because it cannot be found.", cfcatch) />
				</cfif>
				
				<cfset missingEvent = getAppManager().getEventManager().createEvent(nextModuleName, nextEventName, arguments.eventArgs, getRequestHandler().getRequestEventName(), getRequestHandler().getRequestModuleName(), false) />
				<cfset exception = getRequestHandler().wrapException(cfcatch) />
				<cfset handleException(exception, true, missingEvent) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="executeSubroutine" access="public" returntype="boolean" output="true"
		hint="Executes a subroutine.">
		<cfargument name="subroutineName" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var subroutineHandler = "" />
		<cfset var exception = "" />
		<cfset var continue = true />
		<cfset var log = getLog() />
	
		<cftry>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Subroutine '#arguments.subroutineName#' beginning execution.") />
			</cfif>
			
			<!--- Get the subroutine handler --->		
			<cfset subroutineHandler = getAppManager().getSubroutineManager().getSubroutineHandler(arguments.subroutineName) />
			<!--- Execute the subroutine --->
			<cfset continue = subroutineHandler.handleSubroutine(arguments.event, this) />

			<cfif log.isDebugEnabled()>
				<cfset log.debug("Subroutine '#arguments.subroutineName#' execution has ended.") />
			</cfif>
			
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("Subroutine '#arguments.subroutineName#' has caused an exception.", cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<cfif log.isInfoEnabled() AND NOT continue>
			<cfset log.info("Subroutine '#arguments.subroutineName#' has changed the flow of this event.") />
		</cfif>
		
		<cfreturn continue />
	</cffunction>

	<cffunction name="setEventMapping" access="public" returntype="void" output="false"
		hint="Sets an event mapping.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="mappingName" type="string" required="true" />
		<cfargument name="mappingModuleName" type="string" required="false"
			default="#getAppManager().getModuleName()#" />

		<cfset var mapping = StructNew() />
		<cfset var log = getLog() />

		<cfif Len(arguments.mappingModuleName)
			AND NOT getAppManager().getModuleManager().isModuleDefined(arguments.mappingModuleName)>
			
			<cfif log.isErrorEnabled()>
				<cfset log.error("Cannot create an event-mapping on event '#arguments.eventMapping#' because the mapping '#arguments.mappingName#' in module '#arguments.mappingModuleName#' cannot be found.") />
			</cfif>
			
			<cfthrow type="MachII.framework.eventMappingModuleNotDefined"
				message="The module '#arguments.mappingModuleName#' cannot be found for this event-mapping." />	
		</cfif>
		
		<!--- Build the mapping --->
		<cfset mapping.eventName = arguments.mappingName />
		<cfset mapping.moduleName = arguments.mappingModuleName />
		
		<cfset variables.mappings[arguments.eventName] = mapping />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Created event-mapping named '#arguments.eventName#' to event '#arguments.mappingName#' in module '#arguments.mappingModuleName#'.") />
		</cfif>
	</cffunction>
	<cffunction name="getEventMapping" access="public" returntype="struct" output="false"
		hint="Gets an event mapping by the event name.">
		<cfargument name="eventName" type="string" required="true" />
		
		<cfset var mapping = StructNew() />
		
		<!--- Get the mapping or default to the eventName if no mapping exists --->
		<cfif StructKeyExists(variables.mappings, arguments.eventName)>
			<cfset mapping = variables.mappings[arguments.eventName] />
		<cfelse>
			<cfset mapping.eventName = arguments.eventName />
			<cfset mapping.moduleName = getAppManager().getModuleName() />
		</cfif>
		
		<cfreturn mapping />
	</cffunction>
	<cffunction name="isEventMappingDefined" type="public" returntype="boolean" output="false"
		hint="Checks if an event mapping is defined.">
		<cfargument name="eventName" type="string" required="true" />
		
		<cfset var result = false />
		
		<cfif StructKeyExists(variables.mappings, arguments.eventName)>
			<cfset result = true />
		</cfif>
		
		<cfreturn result />
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

	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="Handles an exception.">
		<cfargument name="exception" type="MachII.util.Exception" required="true" />
		<cfargument name="clearEventQueue" type="boolean" required="false" default="true" />
		<cfargument name="missingEvent" type="any" required="false" default="" />
		
		<cfset var nextEvent = "" />
		<cfset var eventArgs = StructNew() />
		<cfset var appManager = getAppManager() />
		<cfset var result = StructNew() />
		<cfset var log = getLog() />
		
		<cfset result.eventName = getExceptionEventName() />
		
		<cftry>
			<!--- Create eventArg data --->			
			<cfset eventArgs.exception = arguments.exception />
			<cfif hasCurrentEvent()>
				<cfset eventArgs.exceptionEvent = getCurrentEvent() />
			</cfif>
			<cfif IsObject(arguments.missingEvent)>
				<cfset eventArgs.missingEvent = arguments.missingEvent />
			</cfif>
			
			<!--- Clear event queue (must be called from the variables scope or it fails)--->
			<cfif arguments.clearEventQueue>
				<cfset variables.clearEventQueue() />
			</cfif>
			
			<!--- Check for an event-mapping. --->
			<cfif isEventMappingDefined(result.eventName)>
				<cfset result = getEventMapping(exceptionEventName) />
				<cfif Len(result.moduleName)>
					<cfset appManager = appManager.getModuleManager().getModule(result.moduleName).getModuleAppManager() />
				<cfelse>
					<cfset appManager = appManager.getModuleManager().getAppManager() />
				</cfif>
			<!--- If the exception event is not defined, then we know it's in the parent --->
			<cfelseif appManager.getPropertyManager().isPropertyDefined("exceptionEvent")>
				<cfset result.moduleName = appManager.getModuleName() />
			<cfelse>
				<cfset result.moduleName = "" />
			</cfif>
			
			<cfif log.isInfoEnabled()>
				<cfset log.info("Handling exception.") />
			</cfif>
			
			<!--- Queue the exception event instead of handling it immediately. 
			The queue is cleared by default so it will be handled first anyway. --->
			<cfset nextEvent = appManager.getEventManager().createEvent(result.moduleName, result.eventName, eventArgs, getRequestHandler().getRequestEventName(), getRequestHandler().getRequestModuleName()) />
			<cfset getEventQueue().put(nextEvent) />
			
			<!--- Call the handleException point in the plugins for the current event first --->
			<cfset appManager.getPluginManager().handleException(this, arguments.exception) />
			
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
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

	<cffunction name="clearEventQueue" access="public" returntype="void" output="false"
		hint="Clears the event queue.">
			
		<cfset var log = getLog() />
		
		<cfif log.isWarnEnabled()>
			<cfset log.warn("Event queue has been cleared.") />
		</cfif>
		
		<cfset getEventQueue().clear() />
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn getRequestHandler().getEventCount() />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setRequestHandler" access="private" returntype="void" output="false">
		<cfargument name="requestHandler" type="MachII.framework.RequestHandler" required="true" />
		<cfset variables.requestHandler = arguments.requestHandler />
	</cffunction>
	<cffunction name="getRequestHandler" access="public" type="MachII.framework.RequestHandler" output="false">
		<cfreturn variables.requestHandler />
	</cffunction>

	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the appManager that pertains to context of currently executing event.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>	
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the appManager that pertains to context of currently executing event.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setEventQueue" access="private" returntype="void" output="false">
		<cfargument name="eventQueue" type="MachII.util.SizedQueue" required="true" />
		<cfset variables.eventQueue = arguments.eventQueue />
	</cffunction>
	<cffunction name="getEventQueue" access="private" returntype="MachII.util.SizedQueue" output="false">
		<cfreturn variables.eventQueue />
	</cffunction>

	<cffunction name="setViewContext" access="private" returntype="void" output="false">
		<cfargument name="viewContext" type="MachII.framework.ViewContext" required="true" />
		<cfset variables.viewContext = arguments.viewContext />
	</cffunction>	
	<cffunction name="getViewContext" access="private" type="MachII.framework.ViewContext" output="false">
		<cfreturn variables.viewContext />
	</cffunction>

	<cffunction name="setExceptionEventName" access="public" returntype="void" output="false">
		<cfargument name="exceptionEventName" type="string" required="true" />
		<cfset variables.exceptionEventName = arguments.exceptionEventName />
	</cffunction>
	<cffunction name="getExceptionEventName" access="public" returntype="string" output="false">
		<cfreturn variables.exceptionEventName />
	</cffunction>
	
	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>