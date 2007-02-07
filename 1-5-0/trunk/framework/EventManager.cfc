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
	<!--- temps --->
	<cfset variables.listenerMgr = "" />
	<cfset variables.filterMgr = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset var commandNodes = "" />
		<cfset var commandNode = "" />
		<cfset var eventNodes = "" />
		<cfset var eventHandler = "" />
		<cfset var eventAccess = "" />
		<cfset var eventName = "" />
		<cfset var command = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfset setAppManager(arguments.appManager) />
		
		<!--- Set temps. --->
		<cfset variables.listenerMgr = getAppManager().getListenerManager() />
		<cfset variables.filterMgr = getAppManager().getFilterManager() />

		<cfset eventNodes = XMLSearch(configXML,"//event-handlers/event-handler") />
		<cfloop from="1" to="#ArrayLen(eventNodes)#" index="i">
			<cfset eventName = eventNodes[i].xmlAttributes['event'] />
			<cfif StructKeyExists(eventNodes[i].xmlAttributes, 'access')>
				<cfset eventAccess = eventNodes[i].xmlAttributes['access'] />
			<cfelse>
				<cfset eventAccess = 'public' />
			</cfif>
			
			<cfset eventHandler = CreateObject('component', 'MachII.framework.EventHandler') />
			<cfset eventHandler.init() />
			<cfset eventHandler.setAccess(eventAccess) />
	  
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
		<cfset variables.subroutineMgr = "" />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
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
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="eventType" type="string" required="false" default="MachII.framework.Event" />
		
		<cfset var event = "" />
		
		<cfif isEventDefined(arguments.eventName)>
			<cfset event = CreateObject('component', arguments.eventType) />
			<cfset event.init(arguments.eventName, arguments.eventArgs) />
			<cfreturn event />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="getEventHandler" access="public" returntype="MachII.framework.EventHandler"
		hint="Returns the EventHandler for the named Event.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		
		<cfif isEventDefined(arguments.eventName)>
			<cfreturn variables.handlers[arguments.eventName] />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="isEventDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if an EventHandler for the named Event is defined; otherwise false.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfreturn StructKeyExists(variables.handlers, arguments.eventName) />
	</cffunction>
	
	<cffunction name="isEventPublic" access="public" returntype="boolean" output="false"
		hint="Returns true if the EventHandler for the named Event is publicly accessible; otherwise false.">
		<cfargument name="eventName" type="string" required="true" />
		<cfset var eventHandler = "" />
		<cfset eventHandler = getEventHandler(arguments.eventName) />
		<cfreturn eventHandler.getAccess() EQ 'public' />
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
	
</cfcomponent>