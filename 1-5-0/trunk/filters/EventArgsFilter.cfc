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
$Id: EventArgsFilter.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.10
Updated version: 1.1.0

EventArgsFilter
	This event-filter adds args to the current event being handled.
	
Configuration Parameters:
	None.
	
Event-Handler Parameters:
	The name/value of each parameter are the name/value of the args added to the event.
--->
<cfcomponent 
	displayname="EventArgsFilter" 
	extends="MachII.framework.EventFilter"
	output="false"
	hint="An EventFilter for adding args to the current event being handled.">
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="This configure method does nothing.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean"
		hint="Runs the filter event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var paramArgKeys = StructKeyArray(arguments.paramArgs) />
		<cfset var i = 0 />
		<cfset var argName = 0 />

		<cfloop index="i" from="1" to="#ArrayLen(paramArgKeys)#">
			<cfset argName = paramArgKeys[i] />
			<cfset arguments.event.setArg(argName, paramArgs[argName]) />
		</cfloop>
		
		<cfreturn true />
	</cffunction>
	
</cfcomponent>