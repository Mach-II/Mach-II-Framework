<!---
License:
Copyright 2008 GreatBizTools, LLC

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
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="AnnounceCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for announcing an event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "announce" />
	<cfset variables.eventName = "" />
	<cfset variables.copyEventArgs = true />
	<cfset variables.moduleName = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AnnounceCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="copyEventArgs" type="boolean" required="false" default="true" />
		<cfargument name="moduleName" type="string" required="false" default="" />
		
		<cfset setEventName(arguments.eventName) />
		<cfset setCopyEventArgs(arguments.copyEventArgs) />
		<cfset setModuleName(arguments.moduleName) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var eventArgs = StructNew() />
		
		<cfif isCopyEventArgs()>
			<cfset eventArgs = arguments.event.getArgs() />
		</cfif>
		
		<cfset arguments.eventContext.announceEvent(getEventName(), eventArgs, getModuleName()) />
		
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
	
	<cffunction name="setCopyEventArgs" access="private" returntype="void" output="false">
		<cfargument name="copyEventArgs" type="string" required="false" default="true" />
		<!--- Enforce that copyEventsArgs is always true unless 'false' is passed--->
		<cfset variables.copyEventArgs = (arguments.copyEventArgs IS NOT "false") />
	</cffunction>
	<cffunction name="isCopyEventArgs" access="private" returntype="boolean" output="false">
		<cfreturn variables.copyEventArgs />
	</cffunction>
	
	<cffunction name="setModuleName" access="private" returntype="void" output="false">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="private" returntype="string" output="false">
		<cfreturn variables.moduleName />
	</cffunction>

</cfcomponent>