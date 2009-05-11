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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="MessageHandler"
	output="false"
	hint="Handles processing of message subscribers from publish commands.">

	<!---
	PROPERTIES
	--->
	<cfset variables.messageName = "" />
	<cfset variables.multithreaded = "" />
	<cfset variables.waitForThreads = "" />
	<cfset variables.timeout = "" />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.messageSubscribers = StructNew() />
	<cfset variables.log = "" />
	<cfset variables.system = CreateObject("java", "java.lang.System") />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="MessageHandler" output="false"
		hint="Initializes the handler.">
		<cfargument name="messageName" type="string" required="true" />
		<cfargument name="multithreaded" type="boolean" required="true" />
		<cfargument name="waitForThreads" type="boolean" required="true" />
		<cfargument name="timeout" type="numeric" required="true" />
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />

		<!--- run setters --->
		<cfset setMessageName(arguments.messageName) />
		<cfset setMultithreaded(arguments.multithreaded) />
		<cfset setWaitForThreads(arguments.waitForThreads) />
		<cfset setTimeout(arguments.timeout) />
		<cfset setThreadingAdapter(arguments.threadingAdapter) />

		<cfreturn this />
 	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleMessage" access="public" returntype="boolean" output="false"
		hint="Handles the message.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var subscribers = getMessageSubscribers() />
		<cfset var threadingAdapter = getThreadingAdapter() />
		<cfset var threadIds = StructNew() />
		<cfset var publishThreadIdsInEvent = arguments.event.getArg("_publishThreadIds", StructNew()) />
		<cfset var parameters = StructNew() />
		<cfset var results = StructNew() />
		<cfset var exception = "" />
		<cfset var continue = true />
		<cfset var log = getLog() />
		<cfset var key = "" />
		
		<!--- Run in parallel if multithreaded is requested and threading is allow on this engine --->
		<cfif getMultithreaded() AND threadingAdapter.allowThreading()>
		
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Received published message named '#getMessageName()#' (running in multi-threaded).") />
			</cfif>
			
			<!--- Setup parameters --->
			<cfset parameters.event = arguments.event />
			<cfset parameters.eventContext = arguments.eventContext />
			
			<!--- Run all the threads --->
			<cfloop collection="#subscribers#" item="key">
				<cfset threadIds[threadingAdapter.run(subscribers[key], "execute", parameters)] = key />
			</cfloop>
			
			<!--- Wait and join --->
			<cfif getWaitForThreads()>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Joining threads for message named '#getMessageName()#'.") />
				</cfif>

				<cfset results = threadingAdapter.join(threadIds, getTimeout()) />
				
				<!--- Create an exception --->
				<cfif ArrayLen(results.errors)>
					<cfset continue = false />
					<!--- We can only handle one exception at once so use the first error --->
					<cfif log.isErrorEnabled()>
						<cfset log.error("#results[results.errors[1]].error.message#", results[results.errors[1]].error) />
					</cfif>					
					<cfset exception = arguments.eventContext.getRequestHandler().wrapException(results[results.errors[1]].error) />
					<cfset arguments.eventContext.handleException(exception, true) />
				</cfif>
			<!--- Or set thread ids into the event --->
			<cfelse>
				<cfif log.isTraceEnabled()>
					<cfset log.trace("Not waiting to join message threads.") />
				</cfif>
				<cfset StructAppend(publishThreadIdsInEvent, threadIds, "true") />
				<cfset arguments.event.setArg("_publishThreadIds", publishThreadIdsInEvent) />
			</cfif>
		<!--- Run in serial --->
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Received published message named '#getMessageName()#' (running in serial).") />
			</cfif>

			<cfloop collection="#subscribers#" item="key">
				<cfset subscribers[key].execute(arguments.event, arguments.eventContent) />
			</cfloop>
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<cffunction name="addMessageSubscriber" access="public" returntype="void" output="false"
		hint="Registers a subscriber (notify / call-method command) to this message.">
		<cfargument name="messageSubscriber" type="MachII.framework.Command" required="true" />
		
		<cfset var key = variables.system.identityHashCode(arguments.messageSubscriber) />
		
		<cfset variables.messageSubscribers[key] = arguments.messageSubscriber />
	</cffunction>
	
	<cffunction name="getMessageSubscribers" access="public" returntype="struct" output="false"
		hint="Gets all message subscribers.">
		<cfreturn variables.messageSubscribers />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getSubscriberNames" access="public" returntype="array" output="false"
		hint="Gets an array of message subscriber invoker names.">
		<cfreturn StructKeyArray(variables.messageSubscribers) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setMessageName" access="private" returntype="void" output="false">
		<cfargument name="messageName" type="string" required="true" />
		<cfset variables.messageName = arguments.messageName />
	</cffunction>
	<cffunction name="getMessageName" access="public" returntype="string" output="false">
		<cfreturn variables.messageName />
	</cffunction>
	
	<cffunction name="setMultithreaded" access="private" returntype="void" output="false">
		<cfargument name="multithreaded" type="boolean" required="true" />
		<cfset variables.multithreaded = arguments.multithreaded />
	</cffunction>
	<cffunction name="getMultithreaded" access="public" returntype="boolean" output="false">
		<cfreturn variables.multithreaded />
	</cffunction>

	<cffunction name="setWaitForThreads" access="private" returntype="void" output="false">
		<cfargument name="waitForThreads" type="boolean" required="true" />
		<cfset variables.waitForThreads = arguments.waitForThreads />
	</cffunction>
	<cffunction name="getWaitForThreads" access="public" returntype="boolean" output="false">
		<cfreturn variables.waitForThreads />
	</cffunction>

	<cffunction name="setTimeout" access="private" returntype="void" output="false">
		<cfargument name="timeout" type="numeric" required="true" />
		<cfset variables.timeout = arguments.timeout />
	</cffunction>
	<cffunction name="getTimeout" access="public" returntype="numeric" output="false">
		<cfreturn variables.timeout />
	</cffunction>

	<cffunction name="setThreadingAdapter" access="private" returntype="void" output="false"
		hint="Sets a threading adapter.">
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />
		<cfset variables.threadingAdapter = arguments.threadingAdapter />
	</cffunction>
	<cffunction name="getThreadingAdapter" access="private" returntype="MachII.util.threading.ThreadingAdapter" output="false"
		hint="Gets a threading adapter.">
		<cfreturn variables.threadingAdapter />
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