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
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="EventManager"
	extends="MachII.framework.CommandLoaderBase"	
	output="false"
	hint="Manages registered EventHandlers for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.handlers = StructNew() />
	<cfset variables.parentEventManager = "" />
	<!--- temps --->
	<cfset variables.listenerMgr = "" />
	<cfset variables.filterMgr = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentEventManager" type="any" required="false" default=""
			hint="Optional argument for a parent event manager. If there isn't one default to empty string." />	
				
		<cfset setAppManager(arguments.appManager) />
		
		<cfif isObject(arguments.parentEventManager)>
			<cfset setParent(arguments.parentEventManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		
		<cfset var commandNode = "" />
		<cfset var eventNodes = "" />
		<cfset var eventHandler = "" />
		<cfset var eventAccess = "" />
		<cfset var eventName = "" />
		<cfset var command = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Set temps for the commandLoaderBase. --->
		<cfset variables.listenerMgr = getAppManager().getListenerManager() />
		<cfset variables.filterMgr = getAppManager().getFilterManager() />

		<cfset eventNodes = XMLSearch(arguments.configXML, "//event-handlers/event-handler") />
		<cfloop from="1" to="#ArrayLen(eventNodes)#" index="i">
			<cfset eventName = eventNodes[i].xmlAttributes["event"] />
			<cfif StructKeyExists(eventNodes[i].xmlAttributes, "access")>
				<cfset eventAccess = eventNodes[i].xmlAttributes["access"] />
			<cfelse>
				<cfset eventAccess = "public" />
			</cfif>
			
			<cfset eventHandler = CreateObject("component", "MachII.framework.EventHandler").init(eventAccess) />
	  
			<cfloop from="1" to="#ArrayLen(eventNodes[i].XMLChildren)#" index="j">
			    <cfset commandNode = eventNodes[i].XMLChildren[j] />
				<cfset command = createCommand(commandNode) />
				<cfset eventHandler.addCommand(command) />
			</cfloop>
			
			<cfset addEventHandler(eventName, eventHandler) />
		</cfloop>
		
		<!--- Clear temps. --->
		<cfset variables.listenerMgr = "" />
		<cfset variables.filterMgr = "" />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures nothing.">
		<!--- DO NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addEventHandler" access="public" returntype="void" output="false"
		hint="Registers an EventHandler by name.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventHandler" type="MachII.framework.EventHandler" required="true" />
		
		<cfif isEventDefined(arguments.eventName)>
			<cfthrow type="MachII.framework.EventHandlerAlreadyDefined"
				message="An EventHandler with name '#arguments.eventName#' is already registered." />
		<cfelse>
			<cfset variables.handlers[arguments.eventName] = arguments.eventHandler />
		</cfif>
	</cffunction>
	
	<cffunction name="createEvent" access="public" returntype="MachII.framework.Event" output="true"
		hint="Creates an Event instance.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="requestName" type="string" required="false" default="" />
		<cfargument name="requestModuleName" type="string" required="false" default="" />
		<cfargument name="eventType" type="string" required="false" default="MachII.framework.Event" />
		
		<cfset var event = "" />
		
		<cfif isEventDefined(arguments.eventName, true)>
			<cfset event = CreateObject("component", arguments.eventType).init(arguments.eventName, arguments.eventArgs, arguments.requestName, arguments.requestModuleName, arguments.moduleName) />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' is not defined." />
		</cfif>
		
		<cfreturn event />
	</cffunction>
	
	<cffunction name="getEventHandler" access="public" returntype="MachII.framework.EventHandler"
		hint="Returns the EventHandler for the named Event.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		
		<cfif isEventDefined(arguments.eventName)>
			<cfreturn variables.handlers[arguments.eventName] />
		<cfelseif isObject(getParent()) AND getParent().isEventDefined(arguments.eventName)>
			<cfreturn getParent().getEventHandler(arguments.eventName) />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="isEventDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if an EventHandler for the named Event is defined; otherwise false.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfargument name="checkParent" type="boolean" required="false" default="0"
			hint="Allows you to " />
		
		<cfset var localCheck = StructKeyExists(variables.handlers, arguments.eventName) />
		
		<cfif localCheck>
			<cfreturn true />
		<cfelseif arguments.checkParent AND isObject(getParent())>
			<cfreturn getParent().isEventDefined(arguments.eventName) />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="isEventPublic" access="public" returntype="boolean" output="false"
		hint="Returns true if the EventHandler for the named Event is publicly accessible; otherwise false.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="0" />
		<cfset var eventHandler = "" />
		<cfif isEventDefined(arguments.eventName)>
			<cfset eventHandler = getEventHandler(arguments.eventName) />
		<cfelseif arguments.checkParent AND isObject(getParent()) AND getParent().isEventDefined(arguments.eventName)>
			<cfset eventHandler = getParent().getEventHandler(arguments.eventName) />
		<cfelse>
			<cfreturn false />
		</cfif>
		<cfreturn eventHandler.getAccess() EQ "public" />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="getHandlerList" access="public" returntype="string" output="false">
		<cfreturn structKeyList(variables.handlers) />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent EventManager instance this EventManager belongs to.">
		<cfargument name="parentEventManager" type="MachII.framework.EventManager" required="true" />
		<cfset variables.parentEventManager = arguments.parentEventManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent EventManager instance this EventManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentEventManager />
	</cffunction>
	
</cfcomponent>