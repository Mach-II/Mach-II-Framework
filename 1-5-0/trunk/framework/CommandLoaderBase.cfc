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
		<cfset var subroutineName = "" />
		<cfset var subroutine= "" />
		<cfset var viewName = "" />
		<cfset var contentKey = "" />
		<cfset var contentArg = "" />
		<cfset var appendContent = 0 />
		<cfset var beanName = "" />
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var reinit = "" />
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
			<cfset command = CreateObject('component', 'MachII.framework.commands.ViewPageCommand') />
			<cfset command.init(viewName, contentKey, contentArg, appendContent) />
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
			<cfset command = CreateObject('component', 'MachII.framework.commands.NotifyCommand') />
			<cfset command.init(listener, notifyMethod, notifyResultKey, notifyResultArg) />
		<!--- announce --->
		<cfelseif commandNode.xmlName EQ "announce">
			<cfset eventName = commandNode.xmlAttributes['event'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'copyEventArgs')>
				<cfset copyEventArgs = commandNode.xmlAttributes['copyEventArgs'] />
			<cfelse>
				<cfset copyEventArgs = true />
			</cfif>
			<cfset command = CreateObject('component', 'MachII.framework.commands.AnnounceCommand') />
			<cfset command.init(eventName, copyEventArgs) />
		<!--- event-mapping --->
		<cfelseif commandNode.xmlName EQ "event-mapping">
			<cfset mappingEventName = commandNode.xmlAttributes['event'] />
			<cfset mappingName = commandNode.xmlAttributes['mapping'] />
			<cfset command = CreateObject('component', 'MachII.framework.commands.EventMappingCommand') />
			<cfset command.init(mappingEventName, mappingName) />
		<!--- execute --->
		<cfelseif commandNode.xmlName EQ "execute">
			<cfset subroutineName = commandNode.xmlAttributes['subroutine'] />
			<cfset command = CreateObject('component', 'MachII.framework.commands.ExecuteCommand') />
			<cfset command.init(subroutineName) />
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
			<cfset command = CreateObject('component', 'MachII.framework.commands.FilterCommand') />
			<cfset command.init(filter, filterParams) />
		<!--- event-bean --->
		<cfelseif commandNode.xmlName EQ "event-bean">
			<cfset beanName = commandNode.xmlAttributes['name'] />
			<cfset beanType = commandNode.xmlAttributes['type'] />
			<cfif StructKeyExists(commandNode.xmlAttributes, 'fields')>
				<cfset beanFields = commandNode.xmlAttributes['fields'] />
			<cfelse>
				<cfset beanFields = '' />
			</cfif>
			<cfif StructKeyExists(commandNode.xmlAttributes['reinit'])>
				<cfset reinit = commandNode.xmlAttributes['reinit'] />
			<cfelse>
				<cfset reinit = TRUE />
			</cfif>
			<cfset command = CreateObject('component', 'MachII.framework.commands.EventBeanCommand') />
			<cfset command.init(beanName, beanType, beanFields, reinit) />
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
			<cfset command = CreateObject('component', 'MachII.framework.commands.RedirectCommand') />
			<cfset command.init(eventName,paramName,redirectUrl,argVariable) />
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
			<cfset command = CreateObject('component', 'MachII.framework.commands.EventArgCommand') />
			<cfset command.init(argName, argValue, argVariable) />	
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset command = CreateObject('component', 'MachII.framework.command') />
			<cfset command.init() />
		</cfif>
		
		<cfreturn command />
	</cffunction>
	
</cfcomponent>