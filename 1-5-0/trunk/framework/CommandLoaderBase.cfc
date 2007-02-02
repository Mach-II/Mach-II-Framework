<!---
License:
Copyright 2007 Mach-II Corporation

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0
--->
<cfcomponent 
	displayname="CommandLoaderBase"
	output="false"
	hint="Base component to load commands for the framework.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<!--- Overrided by child object. --->
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures nothing.">
		<!--- DO NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
		
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createCommand" access="private" returntype="MachII.framework.Command" output="false">
		<cfargument name="commandNode" required="true" />
		
		<cfset var command = "" />

		<!--- Optimized: If/elseif blocks are faster than switch/case --->
		<!--- view-page --->
		<cfif arguments.commandNode.xmlName EQ "view-page">
			<cfset command = setupViewPage(arguments.commandNode) />
		<!--- notify --->
		<cfelseif arguments.commandNode.xmlName EQ "notify">
			<cfset command = setupNotify(arguments.commandNode) />
		<!--- announce --->
		<cfelseif arguments.commandNode.xmlName EQ "announce">
			<cfset command = setupAnnounce(arguments.commandNode) />
		<!--- event-mapping --->
		<cfelseif arguments.commandNode.xmlName EQ "event-mapping">
			<cfset command = setupEventMapping(arguments.commandNode) />
		<!--- execute --->
		<cfelseif arguments.commandNode.xmlName EQ "execute">
			<cfset command = setupExecute(arguments.commandNode) />
		<!--- filter --->
		<cfelseif arguments.commandNode.xmlName EQ "filter">
			<cfset command = setupFilter(arguments.commandNode) />
		<!--- event-bean --->
		<cfelseif arguments.commandNode.xmlName EQ "event-bean">
			<cfset command = setupEventBean(arguments.commandNode) />
		<!--- redirect --->
		<cfelseif arguments.commandNode.xmlName EQ "redirect">
			<cfset command = setupRedirect(arguments.commandNode) />
		<!--- event-arg --->
		<cfelseif arguments.commandNode.xmlName EQ "event-arg">
			<cfset command = setupEventArg(arguments.commandNode) />
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset command = setupDefault(arguments.commandNode) />
		</cfif>
		
		<cfreturn command />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="setupViewPage" access="private" returntype="MachII.framework.commands.ViewPageCommand" output="false"
		hint="Setups a view-page command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var viewName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var contentKey = "" />
		<cfset var contentArg = "" />
		<cfset var appendContent = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentKey")>
			<cfset contentKey = commandNode.xmlAttributes["contentKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentArg")>
			<cfset contentArg = commandNode.xmlAttributes["contentArg"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "append")>
			<cfset appendContent = arguments.commandNode.xmlAttributes["append"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.ViewPageCommand").init(viewName, contentKey, contentArg, appendContent) />
		
		<cfreturn command />
	</cffunction>

	<cffunction name="setupNotify" access="private" returntype="MachII.framework.commands.NotifyCommand" output="false"
		hint="Setups a notify command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var notifyListener = arguments.commandNode.xmlAttributes["listener"] />
		<cfset var notifyMethod = arguments.commandNode.xmlAttributes["method"] />
		<cfset var notifyResultKey = "" />
		<cfset var notifyResultArg = "" />
		<cfset var listener = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultKey")>
			<cfset notifyResultKey = arguments.commandNode.xmlAttributes["resultKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultArg")>
			<cfset notifyResultArg = arguments.commandNode.xmlAttributes["resultArg"] />
		</cfif>
		<cfset listener = variables.listenerMgr.getListener(notifyListener) />
		<cfset command = CreateObject("component", "MachII.framework.commands.NotifyCommand").init(listener, notifyMethod, notifyResultKey, notifyResultArg) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupAnnounce" access="private" returntype="MachII.framework.commands.AnnounceCommand" output="false"
		hint="Setups an announce command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var copyEventArgs = true />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "copyEventArgs")>
			<cfset copyEventArgs = arguments.commandNode.xmlAttributes["copyEventArgs"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.AnnounceCommand").init(eventName, copyEventArgs) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventMapping" access="private" returntype="MachII.framework.commands.EventMappingCommand" output="false"
		hint="Setups an event-mapping command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var mappingEventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var mappingName = arguments.commandNode.xmlAttributes["mapping"] />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventMappingCommand").init(mappingEventName, mappingName) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupExecute" access="private" returntype="MachII.framework.commands.ExecuteCommand" output="false"
		hint="Setups an execute command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var subroutineName = arguments.commandNode.xmlAttributes["subroutine"] />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.ExecuteCommand").init(subroutineName) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupFilter" access="private" returntype="MachII.framework.commands.FilterCommand" output="false"
		hint="Setups a filter command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var filterName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var filterParams = StructNew() />
		<cfset var paramNodes = arguments.commandNode.xmlChildren />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var filter = "" />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(paramNodes)#" index="i">
			<cfset paramName = paramNodes[i].xmlAttributes["name"] />
			<cfset paramValue = paramNodes[i].xmlAttributes["value"] />
			<cfset filterParams[paramName] = paramValue />
		</cfloop>
		<cfset filter = variables.filterMgr.getFilter(filterName) />
		<cfset command = CreateObject("component", "MachII.framework.commands.FilterCommand").init(filter, filterParams) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventBean" access="private" returntype="MachII.framework.commands.EventBeanCommand" output="false"
		hint="Setups a event-bean command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var beanName = "" />
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var reinit = true />

		<cfset beanName = arguments.commandNode.xmlAttributes["name"] />
		<cfset beanType = arguments.commandNode.xmlAttributes["type"] />
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "fields")>
			<cfset beanFields = arguments.commandNode.xmlAttributes["fields"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "reinit")>
			<cfset reinit = arguments.commandNode.xmlAttributes["reinit"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(beanName, beanType, beanFields, reinit) />

		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupRedirect" access="private" returntype="MachII.framework.commands.RedirectCommand" output="false"
		hint="Setups a redirect command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var paramName = "" />
		<cfset var eventName = "" />
		<cfset var redirectUrl = "" />
		<cfset var argVariable = "" />

		<cfset paramName = getAppManager().getPropertyManager().getProperty("eventParameter","event") />
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "event")>
			<cfset eventName = arguments.commandNode.xmlAttributes["event"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "url")>
			<cfset redirectUrl = arguments.commandNode.xmlAttributes["url"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "args")>
			<cfset argVariable = arguments.commandNode.xmlAttributes["args"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.RedirectCommand").init(eventName,paramName,redirectUrl,argVariable) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventArg" access="private" returntype="MachII.framework.commands.EventArgCommand" output="false"
		hint="Setups an event-arg command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var argValue = "" />
		<cfset var argVariable = "" />
		<cfset var command = "" />
		
		<cfset argName = arguments.commandNode.xmlAttributes["name"] />
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "value")>
			<cfset argValue = arguments.commandNode.xmlAttributes["value"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "variable")>
			<cfset argVariable = arguments.commandNode.xmlAttributes["variable"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.EventArgCommand").init(argName, argValue, argVariable) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupDefault" access="private" returntype="MachII.framework.command" output="false"
		hint="Setups a default command.">
		
		<cfset var command = CreateObject("component", "MachII.framework.command").init() />
		
		<cfreturn command />
	</cffunction>
	
</cfcomponent>