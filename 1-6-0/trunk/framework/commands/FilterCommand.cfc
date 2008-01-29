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
Updated version: 1.5.0

Notes:
--->
<cfcomponent 
	displayname="FilterCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="An Command for processing an EventFilter.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.filter = "" />
	<cfset variables.paramArgs = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="FilterCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="filter" type="MachII.framework.EventFilter" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset setFilter(arguments.filter) />
		<cfset setParamArgs(arguments.paramArgs) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = false />
		<cfset var log = getFilter().getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Filter '#getFilter().getComponentNameForLogging()#' beginning execution.") />
		</cfif>
		
		<cfinvoke component="#getFilter()#" method="filterEvent" returnVariable="continue">
			<cfinvokeargument name="event" value="#arguments.event#" />
			<cfinvokeargument name="eventContext" value="#arguments.eventContext#" />
			<cfinvokeargument name="paramArgs" value="#getParamArgs()#" />
		</cfinvoke>

		<cfif log.isWarnEnabled() and NOT continue>
			<cfset log.warn("Filter '#getFilter().getComponentNameForLogging()# has changed the flow of this event.") />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setFilter" access="private" returntype="void" output="false">
		<cfargument name="filter" type="MachII.framework.EventFilter" required="true" />
		<cfset variables.filter = arguments.filter />
	</cffunction>
	<cffunction name="getFilter" access="private" returntype="MachII.framework.EventFilter" output="false">
		<cfreturn variables.filter />
	</cffunction>
	
	<cffunction name="setParamArgs" access="private" returntype="void" output="false">
		<cfargument name="paramArgs" type="struct" required="true" />
		<cfset variables.paramArgs = arguments.paramArgs />
	</cffunction>
	<cffunction name="getParamArgs" access="private" returntype="struct" output="false">
		<cfreturn variables.paramArgs />
	</cffunction>

</cfcomponent>