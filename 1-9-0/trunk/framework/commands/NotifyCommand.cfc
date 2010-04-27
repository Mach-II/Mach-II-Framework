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
	displayname="NotifyCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for notifying a Listener.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "notify" />
	<cfset variables.listenerProxy = "" />
	<cfset variables.method = "" />
	<cfset variables.resultKey = "" />
	<cfset variables.resultArg = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="NotifyCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="listenerProxy" type="MachII.framework.BaseProxy" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="resultKey" type="string" required="true" />
		<cfargument name="resultArg" type="string" required="true" />

		<cfset setListenerProxy(arguments.listenerProxy) />
		<cfset setMethod(arguments.method) />
		<cfset setResultKey(arguments.resultKey) />
		<cfset setResultArg(arguments.resultArg) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var listener = getListenerProxy().getObject() />
		<cfset var invoker = listener.getInvoker() />

		<cfset invoker.invokeListener(arguments.event, listener, getMethod(), getResultKey(), getResultArg()) />

		<cfreturn true />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setListenerProxy" access="private" returntype="void" output="false">
		<cfargument name="listenerProxy" type="MachII.framework.BaseProxy" required="true" />
		<cfset variables.listenerProxy = arguments.listenerProxy />
	</cffunction>
	<cffunction name="getListenerProxy" access="private" returntype="MachII.framework.BaseProxy" output="false">
		<cfreturn variables.listenerProxy />
	</cffunction>

	<cffunction name="setMethod" access="private" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset variables.method = arguments.method />
	</cffunction>
	<cffunction name="getMethod" access="private" returntype="string" output="false">
		<cfreturn variables.method />
	</cffunction>

	<cffunction name="setResultKey" access="private" returntype="void" output="false">
		<cfargument name="resultKey" type="string" required="true" />
		<cfset variables.resultKey = arguments.resultKey />
	</cffunction>
	<cffunction name="getResultKey" access="private" returntype="string" output="false">
		<cfreturn variables.resultKey />
	</cffunction>
	<cffunction name="hasResultKey" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.resultKey) />
	</cffunction>

	<cffunction name="setResultArg" access="private" returntype="void" output="false">
		<cfargument name="resultArg" type="string" required="true" />
		<cfset variables.resultArg = arguments.resultArg />
	</cffunction>
	<cffunction name="getResultArg" access="private" returntype="string" output="false">
		<cfreturn variables.resultArg />
	</cffunction>
	<cffunction name="hasResultArg" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.resultArg) />
	</cffunction>

</cfcomponent>