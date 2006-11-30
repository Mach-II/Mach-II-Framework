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
$Id: EventManager.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="EventManager"
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
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset var commandNodes = "" />
		<cfset var commandNode = "" />
		<cfset var eventNodes = "" />
		<cfset var eventHandler = "" />
		<cfset var eventAccess = "" />
		<cfset var eventName = "" />
		<cfset var eventCommand = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfset setAppManager(arguments.appManager) />
		
		<!--- Set temps. --->
		<cfset variables.listenerMgr = arguments.appManager.getListenerManager() />
		<cfset variables.filterMgr = arguments.appManager.getFilterManager() />

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
				<cfset eventCommand = createEventCommand(commandNode) />
				<cfset eventHandler.addCommand(eventCommand) />
			</cfloop>
			
			<cfset addEventHandler(eventName, eventHandler) />
		</cfloop>
		
		<!--- Clear temps. --->
		<cfset variables.listenerMgr = "" />
		<cfset variables.filterMgr = "" />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered EventHandlers/Events.">
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
			<cfset variables.handlers[eventName] = eventHandler />
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
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createEventCommand" access="private" returntype="MachII.framework.EventCommand" output="false">
		<cfargument name="commandNode" required="true" />
		
		<cfset var eventCommand = "" />
		<cfset var filterName = "" />
		<cfset var filterParams = 0 />
		<cfset var paramNodes = 0 />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var filter = "" />
		<cfset var argName = "" />
		<cfset var argValue = "" />
		<cfset var argVariable = "" />
		<cfset var mappingEventName = "" />
		<cfset var mappingName = "" />
		<cfset var notifyListener = 0 />
		<cfset var notifyMethod = "" />
		<cfset var notifyResultKey = "" />
		<cfset var notifyResultArg = "" />
		<cfset var listener = "" />
		<cfset var eventName = "" />
		<cfset var copyEventArgs = 0 />
		<cfset var viewName = "" />
		<cfset var contentKey = "" />
		<cfset var contentArg = "" />
		<cfset var appendContent = 0 />
		<cfset var beanName = "" />
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var redirectUrl = "" />
		<cfset var k = 0 />

		<!--- Optimized: If/elseif blocks are faster than switch/case --->
		<!--- view-page --->
		<cfif commandNode.xmlName EQ "view-page">
			<cfset viewName = commandNode.xmlAttributes['name'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'contentKey')>
				<cfset contentKey = commandNode.xmlAttributes['contentKey'] />
			<cfelse>
				<cfset contentKey = '' />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'contentArg')>
				<cfset contentArg = commandNode.xmlAttributes['contentArg'] />
			<cfelse>
				<cfset contentArg = '' />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'append')>
				<cfset appendContent = commandNode.xmlAttributes['append'] />
			<cfelse>
				<cfset appendContent = '' />
			</cfif>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.ViewPageCommand') />
			<cfset eventCommand.init(viewName, contentKey, contentArg, appendContent) />
		<!--- notify --->
		<cfelseif commandNode.xmlName EQ "notify">
			<cfset notifyListener = commandNode.xmlAttributes['listener'] />
			<cfset notifyMethod = commandNode.xmlAttributes['method'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'resultKey')>
				<cfset notifyResultKey = commandNode.xmlAttributes['resultKey'] />
			<cfelse>
				<cfset notifyResultKey = '' />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'resultArg')>
				<cfset notifyResultArg = commandNode.xmlAttributes['resultArg'] />
			<cfelse>
				<cfset notifyResultArg = '' />
			</cfif>
			<cfset listener = variables.listenerMgr.getListener(notifyListener) />
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.NotifyCommand') />
			<cfset eventCommand.init(listener, notifyMethod, notifyResultKey, notifyResultArg) />
		<!--- announce --->
		<cfelseif commandNode.xmlName EQ "announce">
			<cfset eventName = commandNode.xmlAttributes['event'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'copyEventArgs')>
				<cfset copyEventArgs = commandNode.xmlAttributes['copyEventArgs'] />
			<cfelse>
				<cfset copyEventArgs = true />
			</cfif>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.AnnounceCommand') />
			<cfset eventCommand.init(eventName, copyEventArgs) />
		<!--- event-mapping --->
		<cfelseif commandNode.xmlName EQ "event-mapping">
			<cfset mappingEventName = commandNode.xmlAttributes['event'] />
			<cfset mappingName = commandNode.xmlAttributes['mapping'] />
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.EventMappingCommand') />
			<cfset eventCommand.init(mappingEventName, mappingName) />
		<!--- filter --->
		<cfelseif commandNode.xmlName EQ "filter">
			<cfset filterName = commandNode.xmlAttributes['name'] />
			<cfset filterParams = StructNew() />
			<cfset paramNodes = commandNode.xmlChildren />
			<cfloop from="1" to="#ArrayLen(paramNodes)#" index="k">
				<cfset paramName = paramNodes[k].xmlAttributes['name'] />
				<cfset paramValue = paramNodes[k].xmlAttributes['value'] />
				<cfset filterParams[paramName] = paramValue />
			</cfloop>
			<cfset filter = variables.filterMgr.getFilter(filterName) />
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.FilterCommand') />
			<cfset eventCommand.init(filter, filterParams) />
		<!--- event-bean --->
		<cfelseif commandNode.xmlName EQ "event-bean">
			<cfset beanName = commandNode.xmlAttributes['name'] />
			<cfset beanType = commandNode.xmlAttributes['type'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'fields')>
				<cfset beanFields = commandNode.xmlAttributes['fields'] />
			<cfelse>
				<cfset beanFields = '' />
			</cfif>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.EventBeanCommand') />
			<cfset eventCommand.init(beanName, beanType, beanFields) />
		<!--- redirect --->
		<cfelseif commandNode.xmlName EQ "redirect">
			<cfset paramName = getAppManager().getPropertyManager().getProperty('eventParameter','event') />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'event')>
				<cfset eventName = commandNode.xmlAttributes['event'] />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'url')>
				<cfset redirectUrl = commandNode.xmlAttributes['url'] />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'args')>
				<cfset argVariable = commandNode.xmlAttributes['args'] />
			</cfif>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.RedirectCommand') />
			<cfset eventCommand.init(eventName,paramName,redirectUrl,argVariable) />
		<!--- event-arg --->
		<cfelseif commandNode.xmlName EQ "event-arg">
			<cfset argName = commandNode.xmlAttributes['name'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'value')>
				<cfset argValue = commandNode.xmlAttributes['value'] />
			<cfelse>
				<cfset argValue = "" />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes, 'variable')>
				<cfset argVariable = commandNode.xmlAttributes['variable'] />
			<cfelse>
				<cfset argVariable = "" />
			</cfif>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.commands.EventArgCommand') />
			<cfset eventCommand.init(argName, argValue, argVariable) />	
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset eventCommand = CreateObject('component', 'MachII.framework.EventCommand') />
			<cfset eventCommand.init() />
		</cfif>
		
		<cfreturn eventCommand />
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