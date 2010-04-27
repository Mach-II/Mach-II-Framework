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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent
	displayname="EventHandler"
	output="false"
	hint="Handles processing of EventCommands for an Event.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commands = ArrayNew(1) />
	<cfset variables.access = "public" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventHandler" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="access" type="string" required="true" />

		<cfset setAccess(arguments.access) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleEvent" access="public" returntype="void" output="true"
		hint="Handles an Event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var continue = true />
		<cfset var command = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(variables.commands)#" index="i">
			<cfset command = variables.commands[i] />
			<cfset continue = command.execute(arguments.event, arguments.eventContext) />
			<cfif continue IS false>
				<cfbreak />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="addCommand" access="public" returntype="void" output="false"
		hint="Adds an Command.">
		<cfargument name="command" type="MachII.framework.Command" required="true" />
		<cfset ArrayAppend(variables.commands, arguments.command) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAccess" access="public" returntype="void" output="false">
		<cfargument name="access" type="string" required="true" />
		<cfset variables.access = arguments.access />
	</cffunction>
	<cffunction name="getAccess" access="public" returntype="string" output="false">
		<cfreturn variables.access />
	</cffunction>

</cfcomponent>