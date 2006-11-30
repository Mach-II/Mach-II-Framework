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
$Id: ViewPageCommand.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="ViewPageCommand" 
	extends="MachII.framework.EventCommand"
	output="false"
	hint="An EventCommand for processing a view.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.viewName = "" />
	<cfset variables.contentKey = "" />
	<cfset variables.contentArg = "" />
	<cfset variables.append = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewPageCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="viewName" type="string" required="true" />
		<cfargument name="contentKey" type="string" required="false" default="" />
		<cfargument name="contentArg" type="string" required="false" default="" />
		<cfargument name="append" type="string" required="false" default="false" />
		
		<cfset setViewName(arguments.viewName) />
		<cfset setContentKey(arguments.contentKey) />
		<cfset setContentArg(arguments.contentArg) />
		<cfset setAppend(arguments.append) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset arguments.eventContext.displayView(arguments.event, getViewName(), getContentKey(), getContentArg(), getAppend()) />
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setViewName" access="private" returntype="void" output="false">
		<cfargument name="viewName" type="string" required="true" />
		<cfset variables.viewName = arguments.viewName />
	</cffunction>
	<cffunction name="getViewName" access="private" returntype="string" output="false">
		<cfreturn variables.viewName />
	</cffunction>
	
	<cffunction name="setContentKey" access="private" returntype="void" output="false">
		<cfargument name="contentKey" type="string" required="true" />
		<cfset variables.contentKey = arguments.contentKey />
	</cffunction>
	<cffunction name="getContentKey" access="private" returntype="string" output="false">
		<cfreturn variables.contentKey />
	</cffunction>
	<cffunction name="hasContentKey" access="private" returntype="boolean" output="false">
		<cfreturn variables.contentKey NEQ '' />
	</cffunction>
	
	<cffunction name="setContentArg" access="private" returntype="void" output="false">
		<cfargument name="contentArg" type="string" required="true" />
		<cfset variables.contentArg = arguments.contentArg />
	</cffunction>
	<cffunction name="getContentArg" access="private" returntype="string" output="false">
		<cfreturn variables.contentArg />
	</cffunction>
	<cffunction name="hasContentArg" access="private" returntype="boolean" output="false">
		<cfreturn variables.contentArg NEQ '' />
	</cffunction>

	<cffunction name="setAppend" access="private" returntype="void" output="false">
		<cfargument name="append" type="string" required="true" />
		<cfset variables.append = (arguments.append is "true") />
	</cffunction>
	<cffunction name="getAppend" access="private" returntype="boolean" output="false">
		<cfreturn variables.append />
	</cffunction>

</cfcomponent>