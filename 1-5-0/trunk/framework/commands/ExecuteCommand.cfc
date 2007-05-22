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
	displayname="ExecuteCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="An Command for executing a subroutine.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.subroutineName = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ExecuteCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="subroutineName" type="string" required="true" />
		
		<cfset setSubroutineName(arguments.subroutineName) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfreturn arguments.eventContext.executeSubroutine(getSubroutineName(), arguments.event) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setSubroutineName" access="private" returntype="void" output="false">
		<cfargument name="subroutineName" type="string" required="true" />
		<cfset variables.subroutineName = arguments.subroutineName />
	</cffunction>
	<cffunction name="getSubroutineName" access="private" returntype="string" output="false">
		<cfreturn variables.subroutineName />
	</cffunction>

</cfcomponent>