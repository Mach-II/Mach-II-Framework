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
$Id: ListenerManager.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Notes:
- Added logic to invoke the default invoker if no invoker is defined. (pfarrell)
--->
<cfcomponent 
	displayname="ListenerManager"
	output="false"
	hint="Manages registered Listeners for the framework instance.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.listeners = StructNew() />
	<cfset variables.appManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ListenerManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset var listenerNodes = "" />
		<cfset var listenerParams = "" />
		<cfset var name = "" />
		<cfset var type = "" />
		<cfset var paramNodes = "" />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var invokerNodes = "" />
		<cfset var invokerType = "" />
		<cfset var invoker = "" />
		<cfset var listener = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfset setAppManager(arguments.appManager) />

		<!--- Setup up each Listener. --->
		<cfset listenerNodes = XMLSearch(configXML,"//listeners/listener") />
		<cfloop from="1" to="#ArrayLen(listenerNodes)#" index="i">
			<cfset name = listenerNodes[i].xmlAttributes['name'] />
			<cfset type = listenerNodes[i].xmlAttributes['type'] />
		
			<!--- Get the Listener's parameters. --->
			<cfset listenerParams = StructNew() />
			<cfset paramNodes = XMLSearch(listenerNodes[i], "./parameters/parameter") />
			<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
				<cfset paramName = paramNodes[j].xmlAttributes['name'] />
				<cfset paramValue = paramNodes[j].xmlAttributes['value'] />
				<cfset listenerParams[paramName] = paramValue />
			</cfloop>
		
			<!--- Setup the Listener. --->
			<cfset listener = CreateObject('component', type) />
			<cfset listener.init(arguments.appManager, listenerParams) />

			<!--- Setup the Listener's Invoker. --->
			<cfset invokerNodes = XMLSearch(listenerNodes[i], "./invoker") />	
			<!--- Use declared invoker from config file --->
			<cfif arrayLen(invokerNodes)>
				<cfset invokerType = invokerNodes[1].xmlAttributes['type'] />

				<cfset invoker = CreateObject('component', invokerType) />
				<cfset invoker.init() />
			<!--- Use defaultInvoker --->
			<cfelse>
				<cfset invoker = listener.getDefaultInvoker() >
			</cfif>

			<!--- Continue setup on the Lister. --->
			<cfset listener.setInvoker(invoker) />
			<!--- Add the Listener to the Manager. --->
			<cfset addListener(name, listener) />
		</cfloop>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered Listeners.">
		<cfset var key = "" />
		<cfloop collection="#variables.listeners#" item="key">
			<cfset getListener(key).configure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getListener" access="public" returntype="MachII.framework.Listener" output="false"
		hint="Gets a Listener with the specified name.">
		<cfargument name="listenerName" type="string" required="true" />
		
		<cfif isListenerDefined(arguments.listenerName)>
			<cfreturn variables.listeners[arguments.listenerName] />
		<cfelse>
			<cfthrow type="MachII.framework.ListenerNotDefined" 
				message="Listener with name '#arguments.listenerName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="addListener" access="public" returntype="void" output="false"
		hint="Registers a Listener with the specified name.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfargument name="listener" type="MachII.framework.Listener" required="true" />
		
		<cfif isListenerDefined(arguments.listenerName)>
			<cfthrow type="MachII.framework.ListenerAlreadyDefined"
				message="A Listener with name '#arguments.listenerName#' is already registered." />
		<cfelse>
			<cfset variables.listeners[arguments.listenerName] = arguments.listener />
		</cfif>
	</cffunction>
	
	<cffunction name="isListenerDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a Listener is registered with the specified name.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.listeners, arguments.listenerName) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this ListenerManager belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the AppManager instance this ListenerManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="getListenerNames" access="public" returntype="array" output="false"
		hint="Returns an array of listener names.">
		<cfreturn StructKeyArray(variables.listeners) />
	</cffunction>
	
</cfcomponent>