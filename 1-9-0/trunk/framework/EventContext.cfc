<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.9.0

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
	<cfset variables.HTMLHeadElementCallbacks = ArrayNew(1) />
	<cfset variables.HTMLHeadElementDuplicateMap = StructNew() />
	<cfset variables.HTMLBodyElementCallbacks = ArrayNew(1) />
	<cfset variables.HTMLBodyElementDuplicateMap = StructNew() />
	<cfset variables.HTTPHeaderCallbacks = ArrayNew(1) />
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
		<cfset setLog(getAppManager().getLogFactory().getLog("MachII.framework.EventContext")) />
		
		<!--- Clear the event mappings --->
		<cfset clearEventMappings() />
	</cffunction>	
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="announceEvent" access="public" returntype="void" output="true"
		hint="Queues an event for the framework to handle.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the event to announce." />
		<cfargument name="eventArgs" type="any" required="false" default="#StructNew()#"
			hint="A struct of arguments or an entire Event object to set as the event's args." />
		<cfargument name="moduleName" type="string" required="false" default="#getAppManager().getModuleName()#"
			hint="The name of the module in which event exists." />
		
		<cfset var mapping = "" />
		<cfset var nextEvent = "" />
		<cfset var nextModuleName = arguments.moduleName />
		<cfset var nextEventName = arguments.eventName />
		<cfset var exception = "" />
		<cfset var missingEvent = "" />
		<cfset var log = getLog() />
		
		<cftry>
			<!--- Convert an Event object to a struct of args --->
			<cfif IsObject(arguments.eventArgs)>
				<cfset arguments.eventArgs = arguments.eventArgs.getArgs() />
			</cfif>
			
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
	
	<cffunction name="redirectUrl" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to a specific url.">
		<cfargument name="redirectUrl" type="string" required="true"
			hint="The url to redirect to. Should be in the form of 'http://www.google.com'." />
		<cfargument name="statusType" type="string" required="false" default=""
			hint="String that represent which http status type to use in the redirect.">
		
		<!--- Clear the event queue since we do not want the Application.cfc/cfm error
			handling to catch a cfabort --->
		<cfset clearEventQueue() />
		
		<cfset getAppManager().getRequestManager().redirectUrl(arguments.redirectUrl, arguments.statusType) />	
	</cffunction>
	
	<cffunction name="redirectEvent" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to an event.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the event to redirect to." />
		<cfargument name="args" type="any" required="false" default=""
			hint="You can pass in either a struct of arguments or a list of event args names from the current event to place in url." />
		<cfargument name="moduleName" type="string" required="false" default="#getAppManager().getModuleName()#"
			hint="The name of the module." />
		<cfargument name="persist" type="boolean" required="false" default="false"
			hint="Choose whether or not to sort any of the persistArgs into the session scope." />
		<cfargument name="persistArgs" type="any" required="false" default=""
			hint="You can pass in either a struct of items or a list of event args to persist." />
		<cfargument name="statusType" type="string" required="false" default=""
			hint="The HTTP status type to use for the redirect (temporary, permanent or PRG)." />
		
		<cfset var mapping = "" />
		<cfset var nextEvent = "" />
		<cfset var nextModuleName = arguments.moduleName />
		<cfset var nextEventName = arguments.eventName />
		<cfset var eventArgs = StructNew() />
		<cfset var argsToPersist = StructNew() />
		<cfset var utils = getAppManager().getUtils() />
		
		<!--- Check for an event-mapping. --->
		<cfif isEventMappingDefined(arguments.eventName)>
			<cfset mapping = getEventMapping(arguments.eventName) />
			<cfset nextModuleName = mapping.moduleName />
			<cfset nextEventName = mapping.eventName />			
		</cfif>
		
		<cfif IsSimpleValue(arguments.args)>
			<cftry>
				<!--- Resolve args to place in as url parameters --->
				<cfset eventArgs = utils.parseAttributesBindToEventAndEvaluateExpressionsIntoStruct(
											utils.trimList(arguments.args)
											, getAppManager()
											, ",") />
				<cfcatch type="MachII.framework.NoEventAvailable">
					<cfthrow type="MachII.framework.NoEventAvailable"
						message="The 'redirectEvent' method cannot find an available event. Be sure you have not cleared the event queue via 'clearEventQueue()' before calling this method."
						detail="Please check your code." />
				</cfcatch>
			</cftry>
		<cfelseif IsStruct(arguments.args)>
			<cfset eventArgs = arguments.args />
		<cfelse>
			<cfthrow type="MachII.framework.RedirectEventArgsInvalidDatatype"
				message="The 'args' argument for redirectEvent only accepts 'string' or 'struct'."
				detail="Please check your code." />
		</cfif>
		
		<cfif IsSimpleValue(arguments.persistArgs)>
			<cftry>
				<!--- Resolve args to persist --->
				<cfset argsToPersist = utils.parseAttributesBindToEventAndEvaluateExpressionsIntoStruct(
												utils.trimList(arguments.persistArgs)
												, getAppManager()
												, ",") />
				
				<!--- If persist is enabled and no persistArgs are specified then persist all the event args --->
				<cfif arguments.persist AND NOT StructCount(argsToPersist)>
					<!--- Ff there is no current event, then it is the preProcess so get the next event --->
					<cfif hasCurrentEvent()>
						<cfset argsToPersist = getCurrentEvent().getArgs() />
					<cfelseif hasNextEvent()>
						<cfset argsToPersist = getNextEvent().getArgs() />
					<cfelse>
						<cfthrow
							type="MachII.framework.NoEventAvailable"
							message="The 'redirectEvent' method cannot find an available event." />
					</cfif>
				</cfif>
				<cfcatch type="MachII.framework.NoEventAvailable">
					<cfthrow type="MachII.framework.NoEventAvailable"
						message="The 'redirectEvent' method cannot find an available event. Be sure you have not cleared the event queue before calling this method."
						detail="Please check your code." />
				</cfcatch>
				<cfcatch type="any">
					<cfrethrow />
				</cfcatch>
			</cftry>
		<!---
			CFML's isStruct on an object will evaluate to true so
			check if it's an Event object first
		--->
		<cfelseif IsObject(arguments.persistArgs)>
			<cfset argsToPersist = arguments.persistArgs.getArgs() />
		<cfelseif IsStruct(arguments.persistArgs)>
			<cfset argsToPersist = arguments.persistArgs />
		<cfelse>
			<cfthrow type="MachII.framework.RedirectEventPersistArgsInvalidDatatype"
				message="The 'persistArgs' argument for redirectEvent only accepts 'string' or 'struct'."
				detail="Please check your code." />
		</cfif>
		
		<!--- Clear the event queue since we do not want to Application.cfc/cfm error
			handling to catch a cfabort --->
		<cfset clearEventQueue() />
		
		<cfset getAppManager().getRequestManager().redirectEvent(
				nextEventName
				, eventArgs
				, nextModuleName
				, arguments.persist
				, argsToPersist
				, arguments.statusType) />
	</cffunction>
	
	<cffunction name="redirectRoute" access="public" returntype="void" output="false"
		hint="Triggers a server side redirect to a route.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name of the Url route to redirect to." />
		<cfargument name="routeArgs" type="any" required="false" default=""
			hint="You can pass in either a struct of arguments or a list of event args names from the current event to place in the url." />
		<cfargument name="persist" type="boolean" required="false" default="false"
			hint="Choose whether or not to sort any of the persistArgs into the session scope." />
		<cfargument name="persistArgs" type="any" required="false" default=""
			hint="You can pass in either a struct of items or a list of event args to persist." />
		<cfargument name="statusType" type="string" required="false" default=""
			hint="String that represent which http status type to use in the redirect.">
		
		<cfset var eventArgs = StructNew() />
		<cfset var argsToPersist = StructNew() />
		<cfset var utils = getAppManager().getUtils() />

		<cfif IsSimpleValue(arguments.routeArgs)>
			<!--- Resolve args to place in as url parameters --->
			<cfset eventArgs = utils.parseAttributesBindToEventAndEvaluateExpressionsIntoStruct(
										utils.trimList(arguments.routeArgs)
										, getAppManager()
										, ",") />
		<cfelseif IsStruct(arguments.routeArgs)>
			<cfset eventArgs = arguments.routeArgs />
		<cfelse>
			<cfthrow type="MachII.framework.RedirectRouteArgsInvalidDatatype"
				message="The 'args' argument for redirectRoute only accepts 'string' or 'struct'."
				detail="Please check your code." />
		</cfif>
		
		<cfif IsSimpleValue(arguments.persistArgs)>
			<!--- Resolve args to persist --->
			<cfset argsToPersist = utils.parseAttributesBindToEventAndEvaluateExpressionsIntoStruct(
											utils.trimList(arguments.persistArgs)
											, getAppManager()
											, ",") />
			
			<!--- If persist is enabled and no persistArgs are specified then persist all the event args --->
			<cfif arguments.persist AND NOT StructCount(argsToPersist)>
				<cfset argsToPersist = getCurrentEvent().getArgs() />
			</cfif>
		<!---
			CFML's isStruct on an object will evaluate to true so
			check if it's an Event object first
		--->
		<cfelseif IsObject(arguments.persistArgs)>
			<cfset argsToPersist = arguments.persistArgs.getArgs() />
		<cfelseif IsStruct(arguments.persistArgs)>
			<cfset argsToPersist = arguments.persistArgs />
		<cfelse>
			<cfthrow type="MachII.framework.RedirectRoutePersistArgsInvalidDatatype"
				message="The 'persistArgs' argument for redirectRoute only accepts 'string' or 'struct'."
				detail="Please check your code." />
		</cfif>
		
		<!--- Clear the event queue since we do not want to Application.cfc/cfm error
			handling to catch a cfabort --->
		<cfset clearEventQueue() />
		
		<cfset getAppManager().getRequestManager().redirectRoute(
					arguments.routeName
					, eventArgs
					, arguments.persist
					, argsToPersist
					, arguments.statusType) />
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
		<cfargument name="prepend" type="boolean" required="false" default="false" />
		
		<!--- Pre-Invoke. --->
		<cfset getAppManager().getPluginManager().preView(this) />
		
		<cfset getViewContext().displayView(arguments.event, arguments.viewName, arguments.contentKey, arguments.contentArg, arguments.append, arguments.prepend) />
		
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
	
	<cffunction name="addHTMLHeadElement" access="public" returntype="boolean" output="false"
		hint="Adds a HTML head element. Returns a boolean if the element was appened to head (always returns true unless you allow duplicates).">
		<cfargument name="text" type="string" required="true"
			hint="Complete text to add to head." />
		<cfargument name="blockDuplicate" type="boolean" required="false" default="false"
			hint="Checks for *exact* duplicates using the text if true. Does not check if false (default behavior)." />
		<cfargument name="blockDuplicateCheckString" type="string" required="false" default="#arguments.text#"
			hint="The check string to use if blocking duplicates is selected. Default to 'arguments.text' if not defined" />
		
		<cfset var i = 0 />
		<cfset var checkStringHash = "" />

		<cfset arguments.addToHead = true />
		
		<!--- Check for duplicate if requested --->
		<cfif arguments.blockDuplicate>
			<cfset checkStringHash = Hash(arguments.blockDuplicateCheckString) />
			
			<cfif StructKeyExists(variables.HTMLHeadElementDuplicateMap, checkStringHash)>
				<cfset arguments.addToHead = false />
			<cfelse>
				<cfset variables.HTMLHeadElementDuplicateMap[checkStringHash] = arguments.blockDuplicateCheckString />
			</cfif>
		</cfif>
		
		<cfif arguments.addToHead>
			<cfhtmlhead text="#arguments.text#" />
		</cfif>
		
		<!--- Notify any registered observers even if blocked (check "addToHead" to see if it was really appended to head)--->
		<cfloop from="1" to="#ArrayLen(variables.HTMLHeadElementCallbacks)#" index="i">
			<cfinvoke component="#variables.HTMLHeadElementCallbacks[i].callback#"
				method="#variables.HTMLHeadElementCallbacks[i].method#" 
				argumentcollection="#arguments#" />
				<!--- Expects "text", "addToHead", "blockDuplicates" and "blockDuplicateCheckString" --->
		</cfloop>
		
		<cfreturn arguments.addToHead />
	</cffunction>

	<cffunction name="addHTMLBodyElement" access="public" returntype="boolean" output="false"
		hint="Adds a HTML body element. Returns a boolean if the element was appened to body (always returns true unless you allow duplicates).">
		<cfargument name="text" type="string" required="true"
			hint="Complete text to add to body." />
		<cfargument name="blockDuplicate" type="boolean" required="false" default="false"
			hint="Checks for *exact* duplicates using the text if true. Does not check if false (default behavior)." />
		<cfargument name="blockDuplicateCheckString" type="string" required="false" default="#arguments.text#"
			hint="The check string to use if blocking duplicates is selected. Default to 'arguments.text' if not defined" />
		
		<cfset var i = 0 />
		<cfset var checkStringHash = "" />

		<cfset arguments.addToBody = true />
		
		<!--- Check for duplicate if requested --->
		<cfif arguments.blockDuplicate>
			<cfset checkStringHash = Hash(arguments.blockDuplicateCheckString) />
			
			<cfif StructKeyExists(variables.HTMLBodyElementDuplicateMap, checkStringHash)>
				<cfset arguments.addToBody = false />
			<cfelse>
				<cfset variables.HTMLBodyElementDuplicateMap[checkStringHash] = arguments.blockDuplicateCheckString />
			</cfif>
		</cfif>
		
		<cfif arguments.addToBody>
			<cftry>
				<cfhtmlbody text="#arguments.text#" />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.unsupportedCFMLEngineFeature"
						message="The tag 'cfhtmlbodyelement' is not supported on this engine." />
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- Notify any registered observers even if blocked (check "addToBody" to see if it was really appended to head)--->
		<cfloop from="1" to="#ArrayLen(variables.HTMLBodyElementCallbacks)#" index="i">
			<cfinvoke component="#variables.HTMLBodyElementCallbacks[i].callback#"
				method="#variables.HTMLBodyElementCallbacks[i].method#" 
				argumentcollection="#arguments#" />
				<!--- Expects "text", "addToBody", "blockDuplicates" and "blockDuplicateCheckString" --->
		</cfloop>
		
		<cfreturn arguments.addToBody />
	</cffunction>
	
	<cffunction name="addHTTPHeader" access="public" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="value" type="string" required="false" default="" />
		<cfargument name="statusCode" type="numeric" required="false" default="0" />
		<cfargument name="statusText" type="string" required="false" default="" />
		<cfargument name="charset" type="string" required="false" default="" />
		
		<cfset var i = 0 />
		<cfset var log = getLog() />
		
		<cfif Len(arguments.name)>
			<cfif Len(arguments.charset)>
				<cfheader name="#arguments.name#" 
					value="#arguments.value#" 
					charset="#arguments.charset#" />			
			<cfelse>
				<cfheader name="#arguments.name#" 
					value="#arguments.value#" />
			</cfif>
		<cfelseif arguments.statusCode NEQ 0>
			<cfif NOT Len(arguments.statusText)>
				<cfset arguments.statusText = getAppManager().getUtils().getHTTPHeaderStatusTextByStatusCode(arguments.statusCode) />
				
				<cfif NOT Len(arguments.statusText) AND log.isWarnEnabled()>
					<cfset log.warn("Unabled to resolve a status text shortcut for a HTTP header with the status code of '#arguments.statusCode#'. Please check that you are using a supported status code.") />
				</cfif>
			</cfif>
			<cfheader statuscode="#arguments.statusCode#" 
				statustext="#arguments.statusText#" />
		<cfelse>
			<cfthrow type="MachII.framework.invalidHTTPHeaderArguments"
				message="The method addHTTPHeader required arguments must be 'name,value' or 'statusCode'."
				detail="Passed arguments:#arguments.toString()#" />
		</cfif>
		
		<!--- Notify any registered observers --->
		<cfloop from="1" to="#ArrayLen(variables.HTTPHeaderCallbacks)#" index="i">
			<cfinvoke component="#variables.HTTPHeaderCallbacks[i].callback#"
				method="#variables.HTTPHeaderCallbacks[i].method#" 
				argumentcollection="#arguments#" />
		</cfloop>
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
		
		<cfif log.isInfoEnabled()>
			<cfset log.info("Event queue has been cleared.") />
		</cfif>
		
		<cfset getEventQueue().clear() />
	</cffunction>
	
	<cffunction name="getEventCount" access="public" returntype="numeric" output="false"
		hint="Returns the number of events that have been processed for this context.">
		<cfreturn getRequestHandler().getEventCount() />
	</cffunction>
	
	<cffunction name="addHTMLHeadElementCallback" access="public" returntype="void" output="false"
		hint="Adds callback to notify when addHTMLHeadElement is run.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.HTMLHeadElementCallbacks, arguments) />
	</cffunction>
	<cffunction name="removeHTMLHeadElementCallback" access="public" returntype="void" output="false"
		hint="Removes callback to notify when addHTMLHeadElement is run.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.HTMLHeadElementCallbacks)#" index="i">
			<cfif utils.assertSame(variables.HTMLHeadElementCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.HTMLHeadElementCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="addHTMLBodyElementCallback" access="public" returntype="void" output="false"
		hint="Adds callback to notify when addHTMLBodyElement is run.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.HTMLBodyElementCallbacks, arguments) />
	</cffunction>
	<cffunction name="removeHTMLBodyElementCallback" access="public" returntype="void" output="false"
		hint="Removes callback to notify when addHTMLBodyElement is run.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.HTMLBodyElementCallbacks)#" index="i">
			<cfif utils.assertSame(variables.HTMLBodyElementCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.HTMLBodyElementCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="addHTTPHeaderCallback" access="public" returntype="void" output="false"
		hint="Adds callback to notify when addHTMLHeadElement is run.">
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfset ArrayAppend(variables.HTTPHeaderCallbacks, arguments) />
	</cffunction>
	<cffunction name="removeHTTPHeaderCallback" access="public" returntype="void" output="false"
		hint="Removes callback to notify when addHTTPHeaderCallback is run.">
		<cfargument name="callback" type="any" required="true" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.HTTPHeaderCallbacks)#" index="i">
			<cfif utils.assertSame(variables.HTTPHeaderCallbacks[i].callback, arguments.callback)>
				<cfset ArrayDeleteAt(variables.HTTPHeaderCallbacks, i) />
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="uploadFile" access="public" returntype="struct" output="false" 
		hint="Wrapper for CFFILE action=upload to better integrate uploading files">
		<cfargument name="fileField" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		<cfargument name="nameConflict" type="string" required="false" default="error" />
		<cfargument name="accept" type="string" required="false" default="*" />
		<cfargument name="mode" type="string" required="false" />
		<cfargument name="fileAttributes" type="string" required="false" />
		
		<cfset var uploadResult = StructNew() />
		
		<!--- mode and attributes are mutually exclusive (mode = *nix only, attributes = Windows only), 
				but I suppose if someone was writing code that they wanted to have one apply on *nix 
				and the other on Windows they could potentially provide both, so we better 
				account for that --->
		<cfif StructKeyExists(arguments, "mode") and not StructKeyExists(arguments, "fileAttributes")>
			<cffile action="upload" filefield="#arguments.fileField#" destination="#arguments.destination#" 
					nameconflict="#arguments.nameConflict#" accept="#arguments.accept#" mode="#arguments.mode#" 
					result="uploadResult" />
		<cfelseif StructKeyExists(arguments, "fileAttributes") and not StructKeyExists(arguments, "mode")>
			<cffile action="upload" filefield="#arguments.fileField#" destination="#arguments.destination#" 
					nameconflict="#arguments.nameConflict#" accept="#arguments.accept#"
					attributes="#arguments.fileAttributes#" result="uploadResult" />
		<cfelseif StructKeyExists(arguments, "fileAttributes") and StructKeyExists(arguments, "mode")>
			<cffile action="upload" filefield="#arguments.fileField#" destination="#arguments.destination#" 
					nameconflict="#arguments.nameConflict#" accept="#arguments.accept#"
					mode="#arguments.mode#" attributes="#arguments.fileAttributes#" 
					result="uploadResult" />
		<cfelse>
			<cffile action="upload" filefield="#arguments.fileField#" destination="#arguments.destination#" 
					nameconflict="#arguments.nameConflict#" accept="#arguments.accept#" result="uploadResult" />
		</cfif>
		
		<cfreturn uploadResult />
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
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.log = arguments.log />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>