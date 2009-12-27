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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="MessageManager"
	extends="MachII.framework.CommandLoaderBase"
	output="false"
	hint="Manages registered Message Subscribers for the framework instance.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.messageHandlers = StructNew() />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.appManager = "" />
	<cfset variables.parentMessageManager = "" />
	<cfset variables.messageHandlerlog = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="MessageManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />	
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getMessageManager()) />
			<cfset setThreadingAdapter(getParent().getThreadingAdapter()) />
		<cfelse>
			<cfset setThreadingAdapter(getAppManager().getUtils().createThreadingAdapter()) />
		</cfif>
		
		<!--- Quick reference for performance reasons --->
		<cfset variables.messageHandlerlog = getAppManager().getLogFactory().getLog("MachII.framework.MessageHandler") />
		
		<cfset super.init() />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads message-subscriber xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var messageSubscribersNodes = ArrayNew(1) />
		<cfset var messageParams = "" />
		<cfset var messageName = "" />
		<cfset var messageMultithreaded = "" />
		<cfset var messageWaitForThreads = "" />
		<cfset var messageTimeout = "" />
		
		<cfset var subscriberNodes = ArrayNew(1) />		
		
		<cfset var messageHandler = "" />
		<cfset var messageSubscriber = "" />
		
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for messages --->
		<cfif NOT arguments.override>
			<cfset messageSubscribersNodes = XMLSearch(arguments.configXML, "mach-ii/message-subscribers/message") />
		<cfelse>
			<cfset messageSubscribersNodes = XMLSearch(arguments.configXML, ".//message-subscribers/message") />
		</cfif>
		
		<!--- Setup up each message --->
		<cfloop from="1" to="#ArrayLen(messageSubscribersNodes)#" index="i">
			<cfset messageName = messageSubscribersNodes[i].xmlAttributes["name"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(messageSubscribersNodes[i].xmlAttributes, "overrideAction")>
				<cfif messageSubscribersNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeMessageHandler(messageName) />
				<cfelseif messageSubscribersNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(messageSubscribersNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = messageSubscribersNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = messageName />
					</cfif>
					
					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isMessageHandlerDefined(mapping)>
						<cfthrow type="MachII.framework.overrideMessageHandlerNotDefined"
							message="An message-subscriber named '#mapping#' cannot be found in the parent listener manager for the override named '#messageName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>
					
					<cfset addMessageHandler(messageName, getParent().getMessageHandler(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<cfif StructKeyExists(messageSubscribersNodes[i].xmlAttributes, "multithreaded")>
					<cfset messageMultithreaded = messageSubscribersNodes[i].xmlAttributes["multithreaded"] />
				<cfelse>
					<cfset messageMultithreaded = true />
				</cfif>
				
				<cfif StructKeyExists(messageSubscribersNodes[i].xmlAttributes, "waitForThreads")>
					<cfset messageWaitForThreads = messageSubscribersNodes[i].xmlAttributes["waitForThreads"] />
				<cfelse>
					<cfset messageWaitForThreads = true />
				</cfif>
				
				<cfif StructKeyExists(messageSubscribersNodes[i].xmlAttributes, "timeout")>
					<cfset messageTimeout = messageSubscribersNodes[i].xmlAttributes["timeout"] />
				<cfelse>
					<cfset messageTimeout = 0 />
				</cfif>
				
				<!--- Setup the Message Handler --->
				<cfset messageHandler = CreateObject("component", "MachII.framework.MessageHandler").init(messageName, messageMultithreaded, messageWaitForThreads, messageTimeout, getThreadingAdapter()) />
				<cfset messageHandler.setLog(variables.messageHandlerlog) />
				<cfset messageHandler.setUtils(getAppManager().getUtils()) />
								
				<!--- For each message, parse all the parameters --->
				<cfif StructKeyExists(messageSubscribersNodes[i], "subscribe")>
					<cfset subscriberNodes = messageSubscribersNodes[i].xmlChildren />
					
					<cfloop from="1" to="#ArrayLen(subscriberNodes)#" index="j">
						<cfif StructKeyExists(subscriberNodes[j].xmlAttributes, "listener")>							
							<cfset messageSubscriber = setupNotify(subscriberNodes[j]) />
						<cfelseif StructKeyExists(subscriberNodes[j].xmlAttributes, "bean")>
							<cfset messageSubscriber = setupCallMethod(subscriberNodes[j]) />
						</cfif>
						
						<cfset messageHandler.addMessageSubscriber(messageSubscriber) />
					</cfloop>
				</cfif>

				<!--- Add the Message Handler to the Manager. --->
				<cfset addMessageHandler(messageName, messageHandler, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered message handlers.">
		<cfset super.configure() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getMessageHandler" access="public" returntype="MachII.framework.MessageHandler" output="false"
		hint="Gets a message handler with the specified name.">
		<cfargument name="messageName" type="string" required="true" />
		
		<cfif isMessageHandlerDefined(arguments.messageName)>
			<cfreturn variables.messageHandlers[arguments.messageName] />
		<cfelseif IsObject(getParent()) AND getParent().isMessageHandlerDefined(arguments.messageName)>
			<cfreturn getParent().getMessageHandler(arguments.messageName) />
		<cfelse>
			<cfthrow type="MachII.framework.MessageHandlerNotDefined" 
				message="A message-subscriber with name '#arguments.messageName#' is not defined."
				detail="Available Messages: '#ArrayToList(getMessageHandlerNames())#'" />
		</cfif>
	</cffunction>
	
	<cffunction name="addMessageHandler" access="public" returntype="void" output="false"
		hint="Registers a Message Handler with the specified name.">
		<cfargument name="messageName" type="string" required="true" />
		<cfargument name="messageHandler" type="MachII.framework.MessageHandler" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isMessageHandlerDefined(arguments.messageName)>
			<cfthrow type="MachII.framework.MessageHandlerAlreadyDefined"
				message="A message-subscriber with name '#arguments.messageName#' is already registered." />
		<cfelse>
			<cfset variables.messageHandlers[arguments.messageName] = arguments.messageHandler />
		</cfif>
	</cffunction>
	
	<cffunction name="removeMessageHandler" access="public" returntype="void" output="false"
		hint="Removes a Message Handler. Does NOT remove from a parent.">
		<cfargument name="messageName" type="string" required="true" />
		<cfset StructDelete(variables.messageHandlers, arguments.messageName, false) />
	</cffunction>
	
	<cffunction name="isMessageHandlerDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a Message Handler is registered with the specified name. Does NOT check parent.">
		<cfargument name="messageName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.messageHandlers, arguments.messageName) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->	
	<cffunction name="getMessageHandlerNames" access="public" returntype="array" output="false"
		hint="Returns an array of message handler names.">
		<cfreturn StructKeyArray(variables.messageHandlers) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Sets the AppManager instance this MessageManager belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Returns the AppManager instance this MessageManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Sets the parent MessageManager instance this MessageManager belongs to.">
		<cfargument name="parentMessageManager" type="MachII.framework.MessageManager" required="true" />
		<cfset variables.parentMessageManager = arguments.parentMessageManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Returns the parent MessageManager instance this MessageManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentMessageManager />
	</cffunction>
	
	<cffunction name="setThreadingAdapter" access="public" returntype="void" output="false"
		hint="Sets a threading adapter.">
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />
		<cfset variables.threadingAdapter = arguments.threadingAdapter />
	</cffunction>
	<cffunction name="getThreadingAdapter" access="public" returntype="MachII.util.threading.ThreadingAdapter" output="false"
		hint="Gets a threading adapter.">
		<cfreturn variables.threadingAdapter />
	</cffunction>
	
</cfcomponent>