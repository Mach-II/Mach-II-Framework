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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

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
	<cfset variables.parentEventManager = "" />
	<cfset variables.handlers = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />	
				
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getEventManager()) />
		</cfif>
		
		<cfset super.init() />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var baseEventNodes = ArrayNew(1) />
		<cfset var baseSecureDefault = "" />
		<cfset var i = 0 />

		<!--- Search for event handlers --->
		<cfif NOT arguments.override>
			<cfset baseEventNodes = XMLSearch(arguments.configXML, "mach-ii/event-handlers") />
		<cfelse>
			<cfset baseEventNodes = XMLSearch(arguments.configXML, ".//event-handlers") />
		</cfif>
		
		<!--- Setup each event handler --->
		<cfloop from="1" to="#ArrayLen(baseEventNodes)#" index="i">
			<cfif StructKeyExists(baseEventNodes[i].xmlAttributes, "secureDefault")>
				<cfset baseSecureDefault = baseEventNodes[i].xmlAttributes["secureDefault"] />
			<cfelse>
				<cfset baseSecureDefault = "none" />
			</cfif>
			
			<cfset loadEventHandlersXml(baseEventNodes[i].xmlChildren, baseSecureDefault, arguments.override) />
		</cfloop>
	</cffunction>

	<cffunction name="loadEventHandlersXml" access="private" returntype="void" output="false"
		hint="Loads event-handlers xml for the manager.">
		<cfargument name="eventNodes" type="array" required="true" />
		<cfargument name="baseSecureDefault" type="string" required="true" />
		<cfargument name="override" type="boolean" required="true" />
		
		<cfset var eventHandler = "" />
		<cfset var eventAccess = "" />
		<cfset var eventSecure = "" />
		<cfset var eventName = "" />
		
		<cfset var commandNode = "" />
		<cfset var command = "" />
		
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Setup each event handler --->
		<cfloop from="1" to="#ArrayLen(arguments.eventNodes)#" index="i">
			<cfset eventName = arguments.eventNodes[i].xmlAttributes["event"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(arguments.eventNodes[i].xmlAttributes, "overrideAction")>
				<cfif arguments.eventNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeEvent(eventName) />
				<cfelseif arguments.eventNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(arguments.eventNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = arguments.eventNodes[i].xmlAttributes["mapping"] />
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
				<cfif StructKeyExists(arguments.eventNodes[i].xmlAttributes, "access")>
					<cfset eventAccess = arguments.eventNodes[i].xmlAttributes["access"] />
				<cfelse>
					<cfset eventAccess = "public" />
				</cfif>
				
				<cfif StructKeyExists(arguments.eventNodes[i].xmlAttributes, "secure")>
					<cfset eventSecure = arguments.eventNodes[i].xmlAttributes["secure"]>
				<cfelse>
					<cfset eventSecure = arguments.baseSecureDefault />
				</cfif>
				
				<cfset eventHandler = CreateObject("component", "MachII.framework.EventHandler").init(eventAccess, eventSecure) />
		  
				<cfloop from="1" to="#ArrayLen(arguments.eventNodes[i].XMLChildren)#" index="j">
				    <cfset commandNode = arguments.eventNodes[i].XMLChildren[j] />
					<cfset command = createCommand(commandNode, eventName, "event", arguments.override) />
					<cfset eventHandler.addCommand(command) />
				</cfloop>
				
				<cfset addEventHandler(eventName, eventHandler, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the EventManager and checks if default and exception are defined as required.">
		
		<cfset var propertyManager = getAppManager().getPropertyManager() />
		<cfset var defaultEvent = "" />
		<cfset var exceptionEvent = "" />
		
		<!--- Make sure a default and exception event is defined for parent--->
		<cfif NOT IsObject(getAppManager().getParent())>
			<cfset defaultEvent = propertyManager.getProperty("defaultEvent") />
			<cfif NOT isEventDefined(defaultEvent, false)>
				<cfthrow type="MachII.framework.noDefaultEvent"
					message="A default event named '#defaultEvent#' has been not defined in the base app, but is required. Please create one." />				
			</cfif>
			<cfset exceptionEvent = propertyManager.getProperty("exceptionEvent") />
			<cfif NOT isEventDefined(exceptionEvent, false)>
				<cfthrow type="MachII.framework.noExceptionEvent"
					message="A exception event named '#exceptionEvent#' has been not defined in the base app, but is required. Please create one." />
			</cfif>
		<!--- Make sure a default and exception event is defined for modules is they are 
			specified otherwise they default to the parent --->
		<cfelse>
			<cfif propertyManager.isPropertyDefined("defaultEvent")>
				<cfset defaultEvent = propertyManager.getProperty("defaultEvent") />
				<cfif NOT isEventDefined(defaultEvent, true)>
					<cfthrow type="MachII.framework.noDefaultEvent"
						message="A default event named '#defaultEvent#' has been defined for this module ('#getAppManager().getModuleName()#'), but no event-handler can be found in this module or parent. Please create one." />
				</cfif>
			</cfif>
			<cfif propertyManager.isPropertyDefined("exceptionEvent")>
				<cfset exceptionEvent = propertyManager.getProperty("exceptionEvent") />
				<cfif NOT isEventDefined(exceptionEvent, true)>
					<cfthrow type="MachII.framework.noExceptionEvent"
						message="A exception event named '#exceptionEvent#' has been defined for this module ('#getAppManager().getModuleName()#'), but no event-handler can be found in this module or parent." />
				</cfif>
			</cfif>
		</cfif>
		
		<cfset super.configure() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="addEventHandler" access="public" returntype="void" output="false"
		hint="Registers an EventHandler by name.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventHandler" type="MachII.framework.EventHandler" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck>
			<cftry>
				<cfset StructInsert(variables.handlers, arguments.eventName, arguments.eventHandler, false) />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.EventHandlerAlreadyDefined"
						message="An EventHandler with name '#arguments.eventName#' is already registered." />
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset variables.handlers[arguments.eventName] = arguments.eventHandler />
		</cfif>
	</cffunction>
	
	<cffunction name="createEvent" access="public" returntype="MachII.framework.Event" output="false"
		hint="Creates an Event instance.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="requestName" type="string" required="false" default="" />
		<cfargument name="requestModuleName" type="string" required="false" default="" />
		<cfargument name="checkIfEventDefined" type="boolean" required="false" default="true" />
		
		<cfset var event = "" />
		
		<cfif NOT arguments.checkIfEventDefined OR isEventDefined(arguments.eventName, true, arguments.moduleName)>
			<cfset event = CreateObject("component", "MachII.framework.Event").init(arguments.eventName, arguments.eventArgs, arguments.requestName, arguments.requestModuleName, arguments.moduleName) />
		<cfelse>
			<cfthrow type="MachII.framework.EventHandlerNotDefined" 
				message="EventHandler for event '#arguments.eventName#' in module '#arguments.moduleName#' is not defined." />
		</cfif>
		
		<cfreturn event />
	</cffunction>
	
	<cffunction name="getEventHandler" access="public" returntype="MachII.framework.EventHandler" output="false"
		hint="Returns the EventHandler for the named Event.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Event to handle." />
		<cfargument name="moduleName" type="string" required="false" default="" />
		
		<cfset var moduleEventManager = 0 />
		<cfset var moduleManager = 0 />
		
		<cfif arguments.moduleName neq "">
			<cfif NOT IsObject(getAppManager().getParent())>
				<cfset moduleManager = getAppManager().getModuleManager() />
			<cfelse>
				<cfset moduleManager = getAppManager().getParent().getModuleManager() />
			</cfif>
			<cfset moduleEventManager = moduleManager.getModule(arguments.moduleName).getModuleAppManager().getEventManager() />
			<cfreturn moduleEventManager.getEventHandler(arguments.eventName) />
		<cfelseif isEventDefined(arguments.eventName)>
			<cfreturn variables.handlers[arguments.eventName] />
		<cfelseif IsObject(getParent())>
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
			<cfif NOT IsObject(getAppManager().getParent())>
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
			<cfelseif arguments.checkParent AND IsObject(getParent())>
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
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isEventDefined(arguments.eventName)>
			<cfset eventHandler = getParent().getEventHandler(arguments.eventName) />
		<cfelse>
			<cfreturn false />
		</cfif>
		
		<cfreturn eventHandler.getAccess() EQ "public" />
	</cffunction>
	
	<cffunction name="getEventSecureType" access="public" returntype="numeric" output="false"
		hint="Check the secure type of the EventHandler for the named Event (1 for secure, 0 for unsecure, -1 for unknown).">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false" />
		
		<cfset var secure = -1 />
		
		<cfif isEventDefined(arguments.eventName)>
			<cfset secure = getEventHandler(arguments.eventName).getSecure() />
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isEventDefined(arguments.eventName)>
			<cfset secure = getParent().getEventHandler(arguments.eventName).getSecure() />
		<cfelse>
			<!--- Unknown --->
			<cfreturn -1 />
		</cfif>
		
		<cfif secure EQ "true">
			<cfreturn 1>
		<cfelseif secure EQ "false">
			<cfreturn 0 />
		<cfelse>
			<!--- Unknown --->
			<cfreturn -1 />		
		</cfif>
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