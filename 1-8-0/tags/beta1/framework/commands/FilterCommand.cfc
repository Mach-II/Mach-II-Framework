<!---
License:
Copyright 2009 GreatBizTools, LLC

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
	displayname="FilterCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for processing an EventFilter.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "filter" />
	<cfset variables.filterProxy = "" />
	<cfset variables.paramArgs = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="FilterCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="filterProxy" type="MachII.framework.BaseProxy" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset setFilterProxy(arguments.filterProxy) />
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
		<cfset var filter = getFilterProxy().getObject() />
		<cfset var log = filter.getLog() />
		<cfset var paramArgs = getParamArgs() />
		
		<cfif log.isDebugEnabled()>
			<cfif StructCount(paramArgs)>
				<cfset log.debug("Filter '#filter.getComponentNameForLogging()#' beginning execution with runtime paramArgs.", paramArgs) />
			<cfelse>
				<cfset log.debug("Filter '#filter.getComponentNameForLogging()#' beginning execution with no runtime paramArgs.") />
			</cfif>
		</cfif>
		
		<cfinvoke component="#filter#" method="filterEvent" returnVariable="continue">
			<cfinvokeargument name="event" value="#arguments.event#" />
			<cfinvokeargument name="eventContext" value="#arguments.eventContext#" />
			<cfinvokeargument name="paramArgs" value="#paramArgs#" />
		</cfinvoke>

		<cfif NOT continue AND log.isInfoEnabled()>
			<cfset log.info("Filter '#filter.getComponentNameForLogging()# has changed the flow of this event.") />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setFilterProxy" access="private" returntype="void" output="false">
		<cfargument name="filterProxy" type="MachII.framework.BaseProxy" required="true" />
		<cfset variables.filterProxy = arguments.filterProxy />
	</cffunction>
	<cffunction name="getFilterProxy" access="private" returntype="MachII.framework.BaseProxy" output="false">
		<cfreturn variables.filterProxy />
	</cffunction>
	
	<cffunction name="setParamArgs" access="private" returntype="void" output="false">
		<cfargument name="paramArgs" type="struct" required="true" />
		<cfset variables.paramArgs = arguments.paramArgs />
	</cffunction>
	<cffunction name="getParamArgs" access="private" returntype="struct" output="false">
		<cfreturn variables.paramArgs />
	</cffunction>

</cfcomponent>