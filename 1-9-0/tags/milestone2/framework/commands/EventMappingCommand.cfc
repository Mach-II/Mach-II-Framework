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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="EventMappingCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for setting up an event mapping for an event handler.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "event-mapping" />
	<cfset variables.eventName = "" />
	<cfset variables.mappingName = "" />
	<cfset variables.mappingModule = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventMappingCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="mappingName" type="string" required="true" />
		<cfargument name="mappingModule" type="string" required="true" />

		<cfset setEventName(arguments.eventName) />
		<cfset setMappingName(arguments.mappingName) />
		<cfset setMappingModule(arguments.mappingModule) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset arguments.eventContext.setEventMapping(getEventName(), getMappingName(), getMappingModule()) />

		<cfreturn true />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setEventName" access="private" returntype="void" output="false">
		<cfargument name="eventName" type="string" required="true" />
		<cfset variables.eventName = arguments.eventName />
	</cffunction>
	<cffunction name="getEventName" access="private" returntype="string" output="false">
		<cfreturn variables.eventName />
	</cffunction>

	<cffunction name="setMappingName" access="private" returntype="void" output="false">
		<cfargument name="mappingName" type="string" required="true" />
		<cfset variables.mappingName = arguments.mappingName />
	</cffunction>
	<cffunction name="getMappingName" access="private" returntype="string" output="false">
		<cfreturn variables.mappingName />
	</cffunction>

	<cffunction name="setMappingModule" access="private" returntype="void" output="false">
		<cfargument name="mappingModule" type="string" required="true" />
		<cfset variables.mappingModule = arguments.mappingModule />
	</cffunction>
	<cffunction name="getMappingModule" access="private" returntype="string" output="false">
		<cfreturn variables.mappingModule />
	</cffunction>

</cfcomponent>