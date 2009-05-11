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

		<cfset var logFactory = getAppManager().getLogFactory() />
		<cfset var aMessageHandler = 0 />
		<cfset var i = 0 />

		<cfloop collection="#variables.messageHandlers#" item="i">
			<cfset aMessageHandler = variables.messageHandlers[i] />
			<cfset aMessageHandler.setLog(logFactory) />
		</cfloop>
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