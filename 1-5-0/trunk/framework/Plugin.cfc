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
$Id: Plugin.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Mach-II Component:
Base Plugin component

Notes:
All user-defined plugins extend this base plugin component.
--->
<cfcomponent 
	displayname="Plugin" 
	extends="MachII.framework.BaseComponent"
	output="false"
	hint="Base Plugin component.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Plugin" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parameters" type="struct" required="false" />
		
		<cfset super.init(arguments.appManager, arguments.parameters) />
		
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="abortEvent" access="public" returntype="void" output="false"
		hint="Call this function to abort processing of the current event. When called, an AbortEventException exception is thrown, caught, and handled by the framework.">
		<cfargument name="message" type="string" required="false" default="" />
		<cfthrow type="AbortEventException" message="#arguments.message#" />
	</cffunction>

	<!---
	PLUGIN POINT FUNCTIONS called from EventContext
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="true"
		hint="Plugin point called before Event processing begins. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="preEvent" access="public" returntype="void" output="true"
		hint="Plugin point called before each Event is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in.  Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="postEvent" access="public" returntype="void" output="true"
		hint="Plugin point called after each Event is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in.  Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="preView" access="public" returntype="void" output="true"
		hint="Plugin point called before each View is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="postView" access="public" returntype="void" output="true"
		hint="Plugin point called after each View is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="postProcess" access="public" returntype="void" output="true"
		hint="Plugin point called after Event processing finishes. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>
	
	<cffunction name="handleException" access="public" returntype="void" output="true"
		hint="Plugin point called when an exception occurs (before exception event is handled). Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext under which the exception was thrown/caught." />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception that was thrown/caught by the framework." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

</cfcomponent>