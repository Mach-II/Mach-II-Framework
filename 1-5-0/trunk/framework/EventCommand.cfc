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
$Id: EventCommand.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Mach-II Component:
Base EventCommand component.
--->
<cfcomponent 
	displayname="EventCommand"
	output="false"
	hint="Base EventCommand component.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.parameters = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Overridden by the command that extends this component.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="setParameter" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>

	<cffunction name="getParameter" access="public" returntype="any" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfreturn variables.parameters[arguments.name] />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setParameters" access="package" returntype="void" output="false">
		<cfargument name="parameters" type="struct" required="true" />
		<cfset var key = "" />
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, parameters[key]) />
		</cfloop>
	</cffunction>

</cfcomponent>