<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

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
	<cffunction name="filterEvent" access="public" returntype="boolean" output="false"
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