<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

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
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager of the context in which this listener belongs to." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The plugin configure time parameters." />

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
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Plugin point called before Event processing begins. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="preEvent" access="public" returntype="void" output="false"
		hint="Plugin point called before each Event is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in.  Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="postEvent" access="public" returntype="void" output="false"
		hint="Plugin point called after each Event is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext the Event occurred in.  Call arguments.eventContext.getCurrentEvent() to access the Event." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="preView" access="public" returntype="void" output="false"
		hint="Plugin point called before each View is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="postView" access="public" returntype="void" output="false"
		hint="Plugin point called after each View is processed. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="false"
		hint="Plugin point called after Event processing finishes. Override to provide custom functionality.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The EventContext of the processing." />
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="onSessionStart" access="public" returntype="void" output="false"
		hint="Plugin point called when a session starts. Override to provide custom functionality.">
		<!--- There is no access to the eventContext since sessions start asynchronously
			from the Mach-II request life cycle--->
		<!--- Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="Plugin point called when a session ends. Override to provide custom functionality.">
		<cfargument name="sessionScope" type="struct" required="true"
			hint="The session scope is passed in since direct access to it is not available." />
		<!--- There is no access to the eventContext since sessions end asynchronously
			from the Mach-II request life cycle--->
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