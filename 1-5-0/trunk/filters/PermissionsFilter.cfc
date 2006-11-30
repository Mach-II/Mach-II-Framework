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
$Id: PermissionsFilter.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.10
Updated version: 1.1.0

PermissionsFilter
	This event-filter tests an event for required permissions specified.
	If the required permissions are not possessed by the user then event
	processing is aborted and a specified event is announced.
	
Configuration Parameters:
	["requiredPermissions"] - default comma delimited list of permission keys required to process the event
	["invalidEvent"] - default event to announce if all required permissions are not possessed by the user
	["invalidMessage"] - default message to provide if the all required permissions are not possessed by the user 
	["clearEventQueue"] - whether or not to clear the event queue if the permissions are invalid (defaults to true)
	
Event-Handler Parameters:
	"requiredPermissions" - a comma delimited list of permission keys required to process the event
	"invalidEvent" - the event to announce if all required permissions are not possessed by the user
	["invalidMessage"] - the message to provide if the all required permissions are not possessed by the user 
	["clearEventQueue"] - whether or not to clear the event queue if the permissions are invalid (defaults to true)
--->
<cfcomponent 
	displayname="PermissionsFilter" 
	extends="MachII.framework.EventFilter"
	output="false"
	hint="A robust EventFilter for testing that a user has the proper permissions to execute and event.">
	
	<!---
	PROPERTIES
	--->
	<cfset this.REQUIRED_PERMISSIONS_PARAM = "requiredPermissions" />
	<cfset this.INVALID_EVENT_PARAM = "invalidEvent" />
	<cfset this.INVALID_MESSAGE_PARAM = "invalidMessage" />
	<cfset this.CLEAR_EVENT_QUEUE_PARAM = "clearEventQueue" />

	<!---
	INITIALIZATION / CONFIGURTAION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="This configure does nothing.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean" output="true"
		hint="Runs the filter event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var isContinue = true />
		<cfset var requiredPermissions = '' />
		<cfset var invalidEvent = '' />
		<cfset var invalidMessage = '' />
		<cfset var clearEventQueue = '' />
		<cfset var userPermissions = '' />
		<cfset var newEventArgs = 0 />
				
		<!--- requiredPermissions --->
		<cfif StructKeyExists(arguments.paramArgs,this.REQUIRED_PERMISSIONS_PARAM)>
			<cfset requiredPermissions = paramArgs[this.REQUIRED_PERMISSIONS_PARAM] />
		<cfelse>
			<cfset requiredPermissions = getParameter(this.REQUIRED_PERMISSIONS_PARAM,'') />
		</cfif>
		<!--- invalidEvent --->
		<cfif StructKeyExists(arguments.paramArgs,this.INVALID_EVENT_PARAM)>
			<cfset invalidEvent = paramArgs[this.INVALID_EVENT_PARAM] />
		<cfelse>
			<cfset invalidEvent = getParameter(this.INVALID_EVENT_PARAM,'') />
		</cfif>
		<!--- invalidMessage --->
		<cfif StructKeyExists(arguments.paramArgs,this.INVALID_MESSAGE_PARAM)>
			<cfset invalidMessage = paramArgs[this.INVALID_MESSAGE_PARAM] />
		<cfelse>
			<cfset invalidMessage = getParameter(this.INVALID_MESSAGE_PARAM,'') />
		</cfif>
		<!--- clearEventQueue --->
		<cfif StructKeyExists(arguments.paramArgs,this.CLEAR_EVENT_QUEUE_PARAM)>
			<cfset clearEventQueue = paramArgs[this.CLEAR_EVENT_QUEUE_PARAM] />
		<cfelse>
			<cfset clearEventQueue = getParameter(this.CLEAR_EVENT_QUEUE_PARAM,true) />
		</cfif>
		
		<!--- Ensure required parameters are specified. --->
		<cfif NOT (requiredPermissions EQ '' OR invalidEvent EQ '')>
			<cfset userPermissions = getUserPermissions() />
			<cfset isContinue = validatePermissions(requiredPermissions, userPermissions) />
		<cfelse>
			<cfset throwUsageException() />
		</cfif>
		
		<cfif isContinue>
			<!--- If the permissions are acceptable then return true to continue processing the current event. --->
			<cfreturn true />
		<cfelse>
			<!--- Clear the event queue if supposed to. --->
			<cfif clearEventQueue>
				<cfset arguments.eventContext.clearEventQueue() />
			</cfif>
			<!--- Announce the invalidEvent. --->
			<cfset newEventArgs = arguments.event.getArgs() />
			<cfset newEventArgs[this.INVALID_MESSAGE_PARAM] = invalidMessage />
			<cfset arguments.eventContext.announceEvent(invalidEvent, newEventArgs) />
			<!--- Return false to abort the processing of the current event. --->
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="getUserPermissions" access="public" returntype="any"
		hint="Checks if user permissions is defined.">
		<!--- Overwrite to specifiy where to find the user's permissions. --->
		<!--- Defaults to session.permissions. --->
		<cfif IsDefined('session.permissions')>
			<cfreturn session.permissions />
		<cfelse>
			<cfreturn '' />
		</cfif>
	</cffunction>
	
	<cffunction name="validatePermissions" access="public" returntype="boolean"
		hint="Validates if required permissions exists in the user's permissions.">
		<cfargument name="requiredPermissions" type="string" required="true" />
		<cfargument name="userPermissions" type="string" required="true" />
		
		<cfset var isValidated = true />
		<cfset var permission = 0 />
		
		<cfloop index="permission" list="#requiredPermissions#" delimiters=",">
			<cfif NOT ListContainsNoCase(arguments.userPermissions,permission)>
				<cfset isValidated = false />
			</cfif>
		</cfloop>
		
		<cfreturn isValidated />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="throwUsageException" access="private" returntype="void" output="false"
		hint="Throws an usage exception.">
		<cfset var throwMsg = "PermissionsFilter requires the following usage parameters: " & this.REQUIRED_PERMISSIONS_PARAM & ", " & this.INVALID_EVENT_PARAM & "." />
		<cfthrow message="#throwMsg#" />
	</cffunction>
	
</cfcomponent>