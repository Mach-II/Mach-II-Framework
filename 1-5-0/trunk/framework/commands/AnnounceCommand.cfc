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
$Id: AnnounceCommand.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="AnnounceCommand" 
	extends="MachII.framework.EventCommand"
	output="false"
	hint="An EventCommand for announcing an event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventName = "" />
	<cfset variables.copyEventArgs = true />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AnnounceCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="copyEventArgs" type="boolean" required="false" default="true" />
		
		<cfset setEventName(arguments.eventName) />
		<cfset setCopyEventArgs(arguments.copyEventArgs) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var eventArgs = "" />
		<cfif isCopyEventArgs()>
			<cfset eventArgs = event.getArgs() />
		<cfelse>
			<cfset eventArgs = StructNew() />
		</cfif>
		
		<cfset arguments.eventContext.announceEvent(getEventName(), eventArgs) />
		
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
		<cfargument name="copyEventArgs" type="boolean" required="false" default="true" />
		<cfset variables.copyEventArgs = arguments.copyEventArgs />
	</cffunction>
	<cffunction name="isCopyEventArgs" access="private" returntype="boolean" output="false">
		<cfreturn variables.copyEventArgs />
	</cffunction>

</cfcomponent>