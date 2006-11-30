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
$Id: EventArgCommand.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="EventArgCommand" 
	extends="MachII.framework.EventCommand"
	output="false"
	hint="An EventCommand for putting an event arg into the current event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.argName = "" />
	<cfset variables.argValue = "" />
	<cfset variables.argVariable = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventArgCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="argName" type="string" required="true" />
		<cfargument name="argValue" type="string" required="false" default="" />
		<cfargument name="argVariable" type="string" required="false" default="" />
		
		<cfset setArgName(arguments.argName) />
		<cfset setArgValue(arguments.argValue) />
		<cfset setArgVariable(arguments.argVariable) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var value = "" />
		
		<cfif isArgVariableDefined()>
			<cfset value = getArgVariableValue() />
		<cfelseif isArgValueDefined()>
			<cfset value = getArgValue() />
		<cfelse>
			<cfset value = "" />
		</cfif>
		
		<cfset arguments.event.setArg(getArgName(), value) />
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setArgName" access="private" returntype="void" output="false">
		<cfargument name="argName" type="string" required="true" />
		<cfset variables.argName = arguments.argName />
	</cffunction>
	<cffunction name="getArgName" access="private" returntype="string" output="false">
		<cfreturn variables.argName />
	</cffunction>
	
	<cffunction name="setArgValue" access="private" returntype="void" output="false">
		<cfargument name="argValue" type="string" required="true" />
		<cfset variables.argValue = arguments.argValue />
	</cffunction>
	<cffunction name="getArgValue" access="private" returntype="string" output="false">
		<cfreturn variables.argValue />
	</cffunction>
	<cffunction name="isArgValueDefined" access="private" returntype="boolean" output="false">
		<cfreturn NOT getArgValue() EQ '' />
	</cffunction>
	
	<cffunction name="setArgVariable" access="private" returntype="void" output="false">
		<cfargument name="argVariable" type="string" required="true" />
		<cfset variables.argVariable = arguments.argVariable />
	</cffunction>
	<cffunction name="getArgVariable" access="private" returntype="string" output="false">
		<cfreturn variables.argVariable />
	</cffunction>
	<cffunction name="isArgVariableDefined" access="private" returntype="boolean" output="false">
		<cfreturn NOT getArgVariable() EQ '' />
	</cffunction>
	<cffunction name="getArgVariableValue" access="private" returntype="any" output="false">
		<cfset var value = "" />
		<cfif IsDefined(getArgVariable())>
			<cfset value = Evaluate(getArgVariable()) />
		</cfif>
		<cfreturn value />
	</cffunction>

</cfcomponent>