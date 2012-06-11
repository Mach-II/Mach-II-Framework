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
	<cfset variables.utils = "" />
	<cfset variables.system = "" />

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

		<!--- This needs to be done in the init method not the psuedo constructor --->
		<cfset variables.system = CreateObject("java", "java.lang.System") />

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
		<cfset var i = 0 />
		<cfset var builtMessage = "" />
		<cfset var builtMessages = "" />

		<!--- Don't run if there are nothing subscribed --->
		<cfif StructCount(subscribers)>

			<!--- Run in parallel if multithreaded is requested and threading is allow on this engine --->
			<cfif getMultithreaded() AND threadingAdapter.allowThreading()>

				<cfset log.debug("Received published message named '#getMessageName()#' (running in multi-threaded).") />

				<!--- Setup parameters --->
				<cfset parameters.event = arguments.event />
				<cfset parameters.eventContext = arguments.eventContext />

				<!--- Run all the threads --->
				<cfloop collection="#subscribers#" item="key">
					<cfset threadIds[threadingAdapter.run(subscribers[key], "execute", parameters)] = key />
				</cfloop>

				<!--- Wait and join --->
				<cfif getWaitForThreads()>
					<cfset log.debug("Joining threads for message named '#getMessageName()#'.") />

					<cfset results = threadingAdapter.join(threadIds, getTimeout()) />

					<!--- Create an exception --->
					<cfif ArrayLen(results.errors)>
						<cfset continue = false />

						<!--- Log all the errors and build an exception message with all the errors to thrown --->
						<cfloop from="1" to="#ArrayLen(results.errors)#" index="i">
							<cfset builtMessage = getUtils().buildMessageFromCfCatch(results[results.errors[i]].error) />
							<cfset builtMessages = builtMessages & "***" &  i & ".*** " & builtMessage & " || " />

							<cfset log.error(builtMessage, results[results.errors[i]].error) />
						</cfloop>

						<!--- We can only handle one exception at once so use the first error --->
						<cfthrow type="application"
								message="An exception occurred while processing a published message named  '#getMessageName()#'. See the list of exceptions below."
								detail="#builtMessages#" />
					</cfif>
				<!--- Or set thread ids into the event --->
				<cfelse>
					<cfset log.trace("Not waiting to join message threads.") />

					<cfset StructAppend(publishThreadIdsInEvent, threadIds, "true") />
					<cfset arguments.event.setArg("_publishThreadIds", publishThreadIdsInEvent) />
				</cfif>
			<!--- Run in serial --->
			<cfelse>
				<cfset log.debug("Received published message named '#getMessageName()#' (running in serial).") />

				<cfloop collection="#subscribers#" item="key">
					<cfset subscribers[key].execute(arguments.event, arguments.eventContext) />
				</cfloop>
			</cfif>

		<cfelse>
			<cfset log.warn("There are no listeners or beans that have subscribed to a message named '#getMessageName()#'. Please check your configuration.") />
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

	<cffunction name="setUtils" access="public" returntype="void" output="false">
		<cfargument name="utils" type="MachII.util.Utils" required="true" />
		<cfset variables.utils = arguments.utils />
	</cffunction>
	<cffunction name="getUtils" access="public" returntype="MachII.util.Utils" output="false">
		<cfreturn variables.utils />
	</cffunction>

	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Sets the log.">
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.log = arguments.log />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>