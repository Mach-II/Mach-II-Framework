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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent 
	displayname="PublishCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="An Command that publishing messages in which message subscribers listen for.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.message = "" />
	<cfset variables.messageHandler = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PublishCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="messageHandler" type="MachII.framework.MessageHandler" required="true" />
		
		<cfset setMessage(arguments.message) />
		<cfset setMessageHandler(arguments.messageHandler) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = getMessageHandler().handleMessage(arguments.event, arguments.eventContext) />
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setMessage" access="private" returntype="void" output="false">
		<cfargument name="message" type="string" required="true" />
		<cfset variables.message = arguments.message />
	</cffunction>
	<cffunction name="getMessage" access="private" returntype="string" output="false">
		<cfreturn variables.message />
	</cffunction>
	
	<cffunction name="setMessageHandler" access="private" returntype="void" output="false">
		<cfargument name="messageHandler" type="MachII.framework.MessageHandler" required="true" />
		<cfset variables.messageHandler = arguments.messageHandler />
	</cffunction>
	<cffunction name="getMessageHandler" access="private" returntype="MachII.framework.MessageHandler" output="false">
		<cfreturn variables.messageHandler />
	</cffunction>

</cfcomponent>