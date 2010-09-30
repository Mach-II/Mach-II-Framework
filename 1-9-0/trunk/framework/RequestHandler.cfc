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

Created version: 1.0.0
Updated version: 1.9.0

Notes:
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
	<cfset variables.cleanedPathInfo = "" />
	<cfset variables.log = "" />
	<cfset variables.currentRouteParams = StructNew() />
	<cfset variables.currentSESParams = StructNew() />
	<cfset variables.currentRouteName = "" />

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
		<cfargument name="onRequestEndCallbacks" type="any" required="true" />

		<cfset setAppManager(arguments.appManager) />
		<cfset setEventParameter(arguments.eventParameter) />
		<cfset setParameterPrecedence(arguments.parameterPrecedence) />
		<cfset setModuleDelimiter(arguments.moduleDelimiter) />
		<cfset setMaxEvents(arguments.maxEvents) />
		<cfset setOnRequestEndCallbacks(arguments.onRequestEndCallbacks) />
		
		<!--- Cleanup the path info since IIS6  "can" butcher the path info --->
		<cfset setCleanedPathInfo(getAppManager().getUtils().cleanPathInfo(cgi.PATH_INFO, cgi.SCRIPT_NAME)) />

		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory().getLog("MachII.framework.RequestHandler")) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Handles all requests made to the framework. Checks for endpoint match first, and if no endpoint then go through handleEventRequest.">
		<cfargument name="eventArgs" type="struct" required="false" default="#getRequestEventArgs()#"
			hint="The event args to be used or the framweork will automatically use the results from getRequestEventArgs()." />

		<cfset var endpointManager = getAppManager().getEndpointManager() />
		<cfset var log = getLog() />

		<cfset log.info("Begin processing request.") />

		<cfset log.debug("Incoming event arguments:", arguments.eventArgs) />

		<cfif endpointManager.isEndpointRequest(arguments.eventArgs)>
			<cfset endpointManager.handleEndpointRequest(arguments.eventArgs) />
		<cfelse>
			<cfset handleEventRequest(arguments.eventArgs) />
		</cfif>

	</cffunction>

	<cffunction name="handleEventRequest" access="private" returntype="void" output="true"
		hint="Handles a normal module/event or route request made to the framework.">
		<cfargument name="eventArgs" type="struct" required="true"
			hint="The parsed event args." />

		<cfset var result = StructNew() />
		<cfset var appManager = getAppManager() />
		<cfset var moduleManager = getAppManager().getModuleManager() />
		<cfset var nextEvent = "" />
		<cfset var exception = "" />
		<cfset var missingEvent = "" />
		<cfset var log = getLog() />

		<!--- Setup the EventQueue --->
		<cfset setEventQueue(CreateObject("component", "MachII.util.SizedQueue").init(getMaxEvents())) />

		<!--- Setup the EventContext --->
		<cfset setEventContext(CreateObject("component", "MachII.framework.EventContext").init(this, getEventQueue())) />

		<!--- Set the EventContext into the request scope for backwards compatibility --->
		<cfset request.eventContext = getEventContext() />

		<!---
		We have to default the module and event name in case the call to
		getRequestEventArgs() throws a UrlRouteNotDefined exception
		--->
		<cfset result.eventName = "" />
		<cfset result.moduleName = "" />

		<cftry>
			<cfset result = parseEventParameter(arguments.eventArgs) />

			<!--- Set the module and name for now (in case module not found we need the original event name) --->
			<cfset setRequestEventName(result.eventName) />
			<cfset setRequestModuleName(result.moduleName) />
			<cfset setupEventContext(appManager) />

			<!--- Get the correct AppManager if inital event is in a module --->
			<cfif Len(result.moduleName)>
				<cfif NOT moduleManager.isModuleDefined(result.moduleName)>
					<cfthrow type="MachII.framework.ModuleNotDefined"
						message="Could not announce event '#result.eventName#' because module '#result.moduleName#' is not defined." />
				<cfelse>
					<cfset appManager = appManager.getModuleManager().getModule(result.moduleName).getModuleAppManager() />
				</cfif>
			</cfif>

			<!--- Get default event	if no event listed --->
			<cfif NOT Len(result.eventName)>
				<!--- If the current module is not the default module then switch the context --->
				<cfif Len(appManager.getPropertyManager().getProperty("defaultModule"))>
					<cfif result.moduleName NEQ appManager.getPropertyManager().getProperty("defaultModule")>
						<cftry>
							<cfset appManager = appManager.getModuleManager().getModule(appManager.getPropertyManager().getProperty("defaultModule")).getModuleAppManager() />
							<cfcatch>
								<cfthrow type="MachII.framework.ModuleNotDefined"
									message="Could not announce default event because module '#appManager.getPropertyManager().getProperty("defaultModule")#' is not defined." />
							</cfcatch>
						</cftry>

						<!--- Syncronize with new module name --->
						<cfset setRequestModuleName(result.moduleName) />
						<cfset result.moduleName = appManager.getPropertyManager().getProperty("defaultModule") />
					</cfif>
				</cfif>

				<cfset result.eventName = appManager.getPropertyManager().getProperty("defaultEvent") />
				<!--- Syncronize with new event name --->
				<cfset setRequestEventName(result.eventName) />
			</cfif>

			<!--- Check if the event exists and is publically accessible --->
			<cfif NOT appManager.getEventManager().isEventDefined(result.eventName, false)>
				<cfthrow type="MachII.framework.EventHandlerNotDefined"
					message="Event-handler for event '#result.eventName#' in module '#result.moduleName#' is not defined."
					detail="Check that the event-handler exists and for misspellings in your links or XML configuration file." />
			<cfelseif getCurrentRouteName() eq "" AND NOT appManager.getEventManager().isEventPublic(result.eventName, false)>
				<!--- Routes are allowed to trigger events which are private --->
				<cfthrow type="MachII.framework.EventHandlerNotAccessible"
					message="Event-handler for event '#result.eventName#' in module '#result.moduleName#' is marked as private and not accessible via the URL."
					detail="Event-handlers with an access modifier of private cannot be requested via an URL and can only be programmatically announced from within the framework." />
			</cfif>

			<!--- Create and queue the event. --->
			<cfset nextEvent = appManager.getEventManager().createEvent(result.moduleName, result.eventName, eventArgs, result.eventName, result.moduleName) />
			<cfset getEventQueue().put(nextEvent) />
			<cfset setupEventContext(appManager, nextEvent) />

			<!--- Handle any errors with the exception event --->
			<cfcatch type="any">
				<cfif log.isWarnEnabled()>
					<cfset log.warn(getAppManager().getUtils().buildMessageFromCfCatch(cfcatch), cfcatch) />
				</cfif>

				<!--- Setup the eventContext again in case we are announcing an event in a module --->
				<cfset setupEventContext(appManager) />
				<cfset missingEvent = appManager.getEventManager().createEvent(
					result.moduleName,
					result.eventName,
					eventArgs,
					result.eventName,
					result.moduleName,
					false) />
				<cfset exception = wrapException(cfcatch) />
				<cfset getEventContext().handleException(exception, true, missingEvent) />
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

		<cfif NOT getIsException()>
			<cfset resetEventCount() />
		</cfif>
		<cfset setIsException(true) />

		<cfreturn exception />
	</cffunction>

	<cffunction name="wrapException" access="public" returntype="MachII.util.Exception" output="false"
		hint="Creates an exception object (with cfcatch).">
		<cfargument name="caughtException" type="any" required="true" />

		<cfset var exception = CreateObject("component", "MachII.util.Exception").wrapException(arguments.caughtException) />

		<cfif NOT getIsException()>
			<cfset resetEventCount() />
		</cfif>
		<cfset setIsException(true) />

		<cfreturn exception />
	</cffunction>

	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn variables.eventCount />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="getWorkingLocale" access="private" returntype="string" output="false"
		hint="Returns the current Locale for this request">

		<cfset var locale = "" />

		<!--- If the current stored locale is empty, return the default locale --->
		<cfif IsObject(getAppManager().getGlobalizationManager())>
			<cfset locale = getAppManager().getGlobalizationManager().retrieveLocale() />
			<cfset getLog().debug("Retrieving locale from GlobalizationManager: #locale#") />
		</cfif>
		
		<cfif locale EQ "">
			<cfset locale = getPageContext().getRequest().getLocale() />
		</cfif>
		
		<cfreturn locale />
	</cffunction>
	
	<cffunction name="setWorkingLocale" access="private" returntype="void" output="false"
		hint="Sets the current Locale for this request (and session).">
		<cfargument name="locale" type="string" required="true" />
		
		<cfif IsObject(getAppManager().getGlobalizationManager())>
			<cfset getAppManager().getGlobalizationManager().persistLocale(arguments.locale) />
			
		<cfelse>
			<!--- I'm pretty ambivalent about the existence of this error message. --->
			<cfabort showerror="GlobalizationManager not configured for attempt to set a locale. Please add a Globalization property to your configuration file."/>
		</cfif>
		
		<cfset getLog().debug("Current locale set to #arguments.locale#") />
	</cffunction>

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
		<cfset var onRequestEndCallbacks = getOnRequestEndCallbacks() />
		<cfset var i = "" />

		<cfif getIsProcessing()>
			<cfthrow message="The RequestHandler is already processing the events in the queue. The processEvents() method can only be called once." />
		</cfif>
		<cfset setIsProcessing(true) />

		<cfset pluginManager = getEventContext().getAppManager().getPluginManager() />

		<!--- Execute all pre-process plugin points. --->
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
				<cfthrow type="MachII.framework.MaxEventsExceededDuringException"
					message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
					detail="Please check your exception handling since it initiated an infinite loop." />
			</cfif>
		<!--- If we're in an exception and we've exceed the max queue, then something is
			wrong with the developer's exception handling, so throw an exception --->
		<cfelseif getIsException() AND hasMoreEvents()>
			<cfset exception = getEventContext().getCurrentEvent().getArg("exception").getCaughtException() />
			<cfthrow type="MachII.framework.MaxEventsExceededDuringException"
				message="The maximum number of events (#getMaxEvents()#) has been exceeded. An exception was generated, but the maximum number of events was exceeded again during the handling of the exception."
				detail="The last exception was '#exception.detail#' which occurred on line #exception.tagContext[1].line# in '#exception.tagContext[1].template#'." />
		</cfif>

		<!--- Execute all post-process plugin points. --->
		<cfset pluginManager.postProcess(getEventContext()) />

		<cfset log.info("End processing request.") />

		<!--- Run On-Request-End callbacks --->
		<cfloop from="1" to="#ArrayLen(onRequestEndCallbacks)#" index="i">
			<cfinvoke component="#onRequestEndCallbacks[i].callback#"
				method="#onRequestEndCallbacks[i].method#">
				<cfinvokeargument name="appManager" value="#getAppManager()#" />
				<cfinvokeargument name="event" value="#getEventContext().getCurrentEvent()#" />
			</cfinvoke>
		</cfloop>

		<cfset setIsProcessing(false) />
	</cffunction>

	<cffunction name="handleNextEvent" access="private" returntype="void" output="true"
		hint="Handles the next event in the queue.">

		<cfset var exception = "" />
		<cfset var log = getLog() />

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
					<cfif log.isFatalEnabled()>
						<cfset log.fatal(getAppManager().getUtils().buildMessageFromCfCatch(cfcatch), cfcatch) />
					</cfif>
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
		<cfset var log = getLog() />

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

		<cfset log.debug("Event-handler '#arguments.event.getName()#' in module '#arguments.event.getModuleName()#' beginning execution.") />

		<!--- Pre-Event --->
		<cfset thisEventAppManager.getPluginManager().preEvent(getEventContext()) />

		<!--- Run commands --->
		<cfset eventHandler = thisEventAppManager.getEventManager().getEventHandler(arguments.event.getName(), arguments.event.getModuleName()) />
		<cfset eventHandler.handleEvent(arguments.event, getEventContext()) />

		<!--- Post-Event --->
		<cfset thisEventAppManager.getPluginManager().postEvent(getEventContext()) />

		<cfset log.debug("Event-handler '#arguments.event.getName()#' in module '#arguments.event.getModuleName()#' has ended.") />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
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

		<cfset result.moduleName = "" />
		<cfset result.eventName = "" />

		<!--- Get the event and module names --->
		<cfif StructKeyExists(arguments.eventArgs, eventParameter) AND Len(arguments.eventArgs[eventParameter])>

			<cfset rawEvent = arguments.eventArgs[eventParameter] />

			<!--- Has a module --->
			<cfif FindNoCase(moduleDelimiter, rawEvent)>
				<cfset result.moduleName = listGetAt(rawEvent, 1, moduleDelimiter) />
				<cfif ListLen(rawEvent, moduleDelimiter) EQ 2>
					<cfset result.eventName = listGetAt(rawEvent, 2, moduleDelimiter) />
				</cfif>
			<!--- Has no module --->
			<cfelse>
				<cfset result.moduleName = "" />
				<cfset result.eventName = rawEvent />
			</cfif>
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="getRequestEventArgs" access="private" returntype="struct" output="false"
		hint="Builds a struct of incoming event args.">

		<cfset var eventArgs = StructNew() />
		<cfset var overwriteFormParams = (getParameterPrecedence() EQ "url") />
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var key = "" />
		<cfset var locale = "" />

		<!--- Build event args from form/url/SES --->
		<cfset StructAppend(eventArgs, form) />
		<cfset StructAppend(eventArgs, url, overwriteFormParams) />
		<!--- requestManager.parseSesParameters() could throw a UrlRouteNotDefined exception --->
		<cfset StructAppend(eventArgs, requestManager.parseSesParameters(getCleanedPathInfo()), overwriteFormParams) />

		<!--- Get redirect persist data and overwrite other args if conflct --->
		<cfset StructAppend(eventArgs, requestManager.readPersistEventData(eventArgs), true) />

		<!--- Cleanup missing checkboxes which are indicated by incoming event args starting with '_-_keyNameHere' --->
		<cfloop collection="#eventArgs#" item="key">
			<cfif key.startsWith("_-_") AND NOT StructKeyExists(eventArgs, Right(key, Len(key) - 3))>
				<cfset eventArgs[Right(key, Len(key) - 3)] = eventArgs[key] />
			</cfif>
		</cfloop>
		
		<!--- If there is an incoming eventArg that matches the globalization locale key,
			persist the new locale --->
		<cfif IsObject(getAppManager().getGlobalizationManager()) AND
			  IsObject(getAppManager().getGlobalizationManager().getGlobalizationLoaderProperty()) AND
			  StructKeyExists(eventArgs, getAppManager().getGlobalizationManager().getGlobalizationLoaderProperty().getLocaleUrlParam())>
			<cfset locale = eventArgs[getAppManager().getGlobalizationManager().getGlobalizationLoaderProperty().getLocaleUrlParam()]>
			<cfset setCurrentLocale(locale) />
		</cfif>

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

	<cffunction name="setCurrentSESParams" access="public" returntype="void" output="false">
		<cfargument name="sesParams" type="struct" required="true" />
		<cfset variables.currentSESParams = arguments.sesParams />
	</cffunction>
	<cffunction name="getCurrentSESParams" access="public" returntype="struct" output="false">
		<cfreturn variables.currentSESParams />
	</cffunction>

	<cffunction name="setCurrentRouteParams" access="public" returntype="void" output="false">
		<cfargument name="routeParams" type="struct" required="true" />
		<cfset variables.currentRouteParams = arguments.routeParams />
	</cffunction>
	<cffunction name="getCurrentRouteParams" access="public" returntype="struct" output="false">
		<cfreturn variables.currentRouteParams />
	</cffunction>

	<cffunction name="setCurrentRouteName" access="public" returntype="void" output="false">
		<cfargument name="routeName" type="string" required="true" />
		<cfset variables.currentRouteName = arguments.routeName />
	</cffunction>
	<cffunction name="getCurrentRouteName" access="public" returntype="string" output="false">
		<cfreturn variables.currentRouteName />
	</cffunction>

	<cffunction name="setParameterPrecedence" access="private" returntype="void" output="false">
		<cfargument name="parameterPrecedence" type="string" required="true" />
		<cfset variables.parameterPrecedence = arguments.parameterPrecedence />
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
	<cffunction name="getIsProcessing" access="public" returntype="boolean" output="false">
		<cfreturn variables.isProcessing />
	</cffunction>

	<cffunction name="setIsException" access="private" returntype="void" output="false">
		<cfargument name="isException" type="boolean" required="true" />
		<cfset variables.isException = arguments.isException />
	</cffunction>
	<cffunction name="getIsException" access="public" returntype="boolean" output="false">
		<cfreturn variables.isException />
	</cffunction>

	<cffunction name="setMaxEvents" access="private" returntype="void" output="false">
		<cfargument name="maxEvents" type="numeric" required="true" />
		<cfset variables.maxEvents = arguments.maxEvents />
	</cffunction>
	<cffunction name="getMaxEvents" access="public" returntype="numeric" output="false">
		<cfreturn variables.maxEvents />
	</cffunction>

	<cffunction name="setCleanedPathInfo" access="private" returntype="void" output="false">
		<cfargument name="cleanedPathInfo" type="string" required="true" />
		<cfset variables.cleanedPathInfo = arguments.cleanedPathInfo />
	</cffunction>
	<cffunction name="getCleanedPathInfo" access="public" returntype="string" output="false">
		<cfreturn variables.cleanedPathInfo />
	</cffunction>

	<cffunction name="setOnRequestEndCallbacks" access="private" returntype="void" output="false">
		<cfargument name="onRequestEndCallbacks" type="any" required="true" />
		<cfset variables.onRequestEndCallbacks = arguments.onRequestEndCallbacks />
	</cffunction>
	<cffunction name="getOnRequestEndCallbacks" access="private" returntype="any" output="false">
		<cfreturn variables.onRequestEndCallbacks />
	</cffunction>

	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.log = arguments.log />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

	<cffunction name="setCurrentLocale" access="public" returntype="void" output="false"
		hint="Sets the current locale for a request">
		<cfargument name="locale" type="string" required="true" />
		<cfset setWorkingLocale(arguments.locale)/>
	</cffunction>
	<cffunction name="getCurrentLocale" access="public" returntype="string" output="false"
		hint="Gets the current locale for a request">
		<cfreturn getWorkingLocale()/>
	</cffunction>

</cfcomponent>