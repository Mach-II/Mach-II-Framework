<!---
License:
Copyright 2007 GreatBizTools, LLC

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
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var commandNode = "" />
		<cfset var eventNodes = "" />
		<cfset var eventHandler = "" />
		<cfset var eventAccess = "" />
		<cfset var eventName = "" />
		<cfset var command = "" />
		<cfset var hasParent = isObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for event handlers --->
		<cfif NOT arguments.override>
			<cfset eventNodes = XMLSearch(arguments.configXML, "mach-ii/event-handlers/event-handler") />
		<cfelse>
			<cfset eventNodes = XMLSearch(arguments.configXML, ".//event-handlers/event-handler") />
		</cfif>
		
		<!--- Setup each even handler --->
		<cfloop from="1" to="#ArrayLen(eventNodes)#" index="i">
			<cfset eventName = eventNodes[i].xmlAttributes["event"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(eventNodes[i].xmlAttributes, "overrideAction")>
				<cfif eventNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeEvent(eventName) />
				<cfelseif eventNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(eventNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = eventNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = eventName />
					</cfif>
					
					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isEventDefined(mapping)>
						<cfthrow type="MachII.framework.overrideEventHandlerNotDefined"
							message="An event-handler named '#mapping#' cannot be found in the parent event manager for the override named '#eventName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>
					
					<cfset addEventHandler(eventName, getParent().getEventHandler(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
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
				
				<cfset addEventHandler(eventName, eventHandler, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the EventManager and checks if default and exception are defined as required.">
		
		<cfset var defaultEvent = "" />
		<cfset var exceptionEvent = "" />
		
		<!--- Make sure a default and exception event is defined for parent--->
		<cfif NOT IsObject(getAppManager().getParent())>
			<cfset defaultEvent = getAppManager().getPropertyManager().getProperty("defaultEvent") />
			<cfif NOT isEventDefined(defaultEvent, false)>
				<cfthrow type="MachII.framework.noDefaultEvent"
					message="A default event named '#defaultEvent#' has been not defined, but is required. Please create one." />				
			</cfif>
			<cfset exceptionEvent = getAppManager().getPropertyManager().getProperty("exceptionEvent") />
			<cfif NOT isEventDefined(exceptionEvent, false)>
				<cfthrow type="MachII.framework.noExceptionEvent"
					message="A exception event named '#exceptionEvent#' has been not defined, but is required. Please create one." />
			</cfif>
		<!--- Make sure a default and exception event is defined for modules is they are 
			specified otherwise they default to the parent --->
		<cfelse>
			<cfif getAppManager().getPropertyManager().isPropertyDefined("defaultEvent")>
				<cfset defaultEvent = getAppManager().getPropertyManager().getProperty("defaultEvent") />
				<cfif NOT isEventDefined(defaultEvent, true)>
					<cfthrow type="MachII.framework.noDefaultEvent"
						message="A default event named '#defaultEvent#' has been defined for this module ('#getAppManager().getModuleName()#'), but no event-handler can be found in this module or parent. Please create one." />
				</cfif>
			</cfif>
			<cfif getAppManager().getPropertyManager().isPropertyDefined("exceptionEvent")>
				<cfset exceptionEvent = getAppManager().getPropertyManager().getProperty("exceptionEvent") />
				<cfif NOT isEventDefined(exceptionEvent, true)>
					<cfthrow type="MachII.framework.noExceptionEvent"
						message="A exception event named '#exceptionEvent#' has been defined for this module ('#getAppManager().getModuleName()#'), but no event-handler can be found in this module or parent." />
				</cfif>
			</cfif>
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="addEventHandler" access="public" returntype="void" output="false"
		hint="Registers an EventHandler by name.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventHandler" type="MachII.framework.EventHandler" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isEventDefined(arguments.eventName)>
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
		
		<cfif isEventDefined(arguments.eventName, true, arguments.moduleName)>
			<cfset event = CreateObject("component", arguments.eventType).init(arguments.eventName, arguments.eventArgs, arguments.requestName, arguments.requestModuleName, arguments.moduleName) />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' in module '#arguments.moduleName#' is not defined." />
		</cfif>
		
		<cfreturn event />
	</cffunction>
	
	<cffunction name="getEventHandler" access="public" returntype="MachII.framework.EventHandler"
		hint="Returns the EventHandler for the named Event.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfargument name="moduleName" type="string" required="false" default="" />
		
		<cfset var moduleEventManager = 0 />
		<cfset var moduleManager = 0 />
		
		<cfif arguments.moduleName neq "">
			<cfif NOT isObject(getAppManager().getParent())>
				<cfset moduleManager = getAppManager().getModuleManager() />
			<cfelse>
				<cfset moduleManager = getAppManager().getParent().getModuleManager() />
			</cfif>
			<cfset moduleEventManager = moduleManager.getModule(arguments.moduleName).getModuleAppManager().getEventManager() />
			<cfreturn moduleEventManager.getEventHandler(arguments.eventName) />
		<cfelseif isEventDefined(arguments.eventName)>
			<cfreturn variables.handlers[arguments.eventName] />
		<cfelseif isObject(getParent()) AND getParent().isEventDefined(arguments.eventName)>
			<cfreturn getParent().getEventHandler(arguments.eventName) />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' is not defined." />
		</cfif>
	</cffunction>

	<cffunction name="removeEvent" access="public" returntype="void" output="false"
		hint="Removes an event-handler. Does NOT remove from parent.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfset StructDelete(variables.handlers, arguments.eventName, false) />
	</cffunction>
	
	<cffunction name="isEventDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if an EventHandler for the named Event is defined; otherwise false.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Allows you to check the parent to see if the event is in there" />
		<cfargument name="moduleName" type="string" required="false" default=""
			hint="Allows you to check in a specific module for an event" />
		
		<cfset var moduleManager = "" />
		<cfset var moduleEventManager = "" />
		
		<cfif arguments.moduleName neq "">
			<cfif NOT isObject(getAppManager().getParent())>
				<cfset moduleManager = getAppManager().getModuleManager() />
			<cfelse>
				<cfset moduleManager = getAppManager().getParent().getModuleManager() />
			</cfif>
			<cfif moduleManager.isModuleDefined(arguments.moduleName)>
				<cfset moduleEventManager = moduleManager.getModule(arguments.moduleName).getModuleAppManager().getEventManager() />
				<cfif moduleEventManager.isEventDefined(arguments.eventName, true)>
					<cfreturn true />
				<cfelse>
					<cfreturn false />
				</cfif>
			<cfelse>
				<cfreturn false />
			</cfif>
		<cfelse>
			<cfif StructKeyExists(variables.handlers, arguments.eventName)>
				<cfreturn true />
			<cfelseif arguments.checkParent AND isObject(getParent())>
				<cfreturn getParent().isEventDefined(arguments.eventName, false, arguments.moduleName) />
			<cfelse>
				<cfreturn false />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="isEventPublic" access="public" returntype="boolean" output="false"
		hint="Returns true if the EventHandler for the named Event is publicly accessible; otherwise false.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false" />
		
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
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getEventNames" access="public" returntype="array" output="false"
		hint="Returns an array of event-handler names.">
		<cfreturn StructKeyArray(variables.handlers) />
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