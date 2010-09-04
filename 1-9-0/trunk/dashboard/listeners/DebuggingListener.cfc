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

$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="FrameworkListener"
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for base framework structures.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="enableDisableExceptionViewer" access="public" returntype="void" output="false"
		hint="Enables/disables a exception viewer.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var logger = getExceptionViewer(arguments.event) />
		<cfset var mode = arguments.event.getArg("mode") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />		
		
		<cfif mode EQ "enable">
			<cfset logger.setLoggingEnabled(true) />
			<cfset message.setMessage("Enabled exception viewer.") />
		<cfelse>
			<cfset logger.setLoggingEnabled(false) />
			<cfset message.setMessage("Disabled exception viewer.") />
		</cfif>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>
	
	<cffunction name="getExceptionViewerDataStorage" access="public" returntype="struct" output="false"
		hint="Enables/disables a exception viewer.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfreturn getExceptionViewer(arguments.event).getDataStorage() />
	</cffunction>

	<cffunction name="flushExceptionViewerDataStorage" access="public" returntype="void" output="false"
		hint="Changes snapshot level for the exception viewer.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Flushed exception viewer data storage.") />

		<cfset getExceptionViewer(arguments.event).getDataStorage(true) />
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>

	<cffunction name="changeSnapshotLevel" access="public" returntype="void" output="false"
		hint="Changes snapshot level for the exception viewer.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Changed snapshot level to '#arguments.event.getArg('level')#'.") />
		
		<cfset getExceptionViewer(arguments.event).setSnapshotLevel(arguments.event.getArg("level")) />
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>
	
	<cffunction name="getExceptionViewer" access="public" returntype="any" output="false"
		hint="Gets the exception viewer.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfreturn getProperty("logging").getLoggerByName("exception") />
	</cffunction>

</cfcomponent>