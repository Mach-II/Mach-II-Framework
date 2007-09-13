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
	displayname="EventMappingCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="An Command for setting up an event mapping for an event handler.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventName = "" />
	<cfset variables.mappingName = "" />
	<cfset variables.mappingModule = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventMappingCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="mappingName" type="string" required="true" />
		<cfargument name="mappingModule" type="string" required="true" />
		
		<cfset setEventName(arguments.eventName) />
		<cfset setMappingName(arguments.mappingName) />
		<cfset setMappingModule(arguments.mappingModule) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<!--- Only pass the module name if we know what it is otherwise assume it the base --->
		<cfif Len(getMappingModule())>
			<cfset arguments.eventContext.setEventMapping(getEventName(), getMappingName(), getMappingModule()) />
		<cfelse>
			<cfset arguments.eventContext.setEventMapping(getEventName(), getMappingName()) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setEventName" access="private" returntype="void" output="false">
		<cfargument name="eventName" type="string" required="true" />
		<cfset variables.eventName = arguments.eventName />
	</cffunction>
	<cffunction name="getEventName" access="private" returntype="string" output="false">
		<cfreturn variables.eventName />
	</cffunction>
	
	<cffunction name="setMappingName" access="private" returntype="void" output="false">
		<cfargument name="mappingName" type="string" required="true" />
		<cfset variables.mappingName = arguments.mappingName />
	</cffunction>
	<cffunction name="getMappingName" access="private" returntype="string" output="false">
		<cfreturn variables.mappingName />
	</cffunction>
	
	<cffunction name="setMappingModule" access="private" returntype="void" output="false">
		<cfargument name="mappingModule" type="string" required="true" />
		<cfset variables.mappingModule = arguments.mappingModule />
	</cffunction>
	<cffunction name="getMappingModule" access="private" returntype="string" output="false">
		<cfreturn variables.mappingModule />
	</cffunction>

</cfcomponent>