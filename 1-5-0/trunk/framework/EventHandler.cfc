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
$Id: EventHandler.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="EventHandler"
	output="false"
	hint="Handles processing of EventCommands for an Event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commands = ArrayNew(1) />
	<cfset variables.access = "public" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventHandler" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleEvent" access="public" returntype="void" output="true"
		hint="Handles an Event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = true />
		<cfset var command = "" />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#ArrayLen(variables.commands)#">
			<cfset command = variables.commands[i] />
			<cfset continue = command.execute(arguments.event, arguments.eventContext) />
			<cfif continue IS false>
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="addCommand" access="public" returntype="void" output="false"
		hint="Adds an EventCommand.">
		<cfargument name="command" type="MachII.framework.EventCommand" required="true" />
		<cfset ArrayAppend(variables.commands, arguments.command) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAccess" access="public" returntype="void" output="false">
		<cfargument name="access" type="string" required="true" />
		<cfset variables.access = arguments.access />
	</cffunction>
	<cffunction name="getAccess" access="public" returntype="string" output="false">
		<cfreturn variables.access />
	</cffunction>
	
</cfcomponent>