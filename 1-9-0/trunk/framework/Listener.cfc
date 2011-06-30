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
All user-defined listeners extend this base listener component.
--->
<cfcomponent
	displayname="Listener"
	extends="MachII.framework.BaseComponent"
	output="false"
	hint="Base Listener component.">

	<!---
	PROPERTIES
	--->
	<cfset variables.invoker = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Listener" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager of the context in which this listener belongs to." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The listener configure time parameters." />
		<cfargument name="invoker" type="MachII.framework.ListenerInvoker" required="false"
			hint="The invoker for this listener." />

		<cfset super.init(arguments.appManager, arguments.parameters) />

		<cfif StructKeyExists(arguments, "invoker")>
			<cfset setInvoker(arguments.invoker) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setInvoker" access="public" returntype="void" output="false"
		hint="Sets the ListenerInvoker to use when invoking methods for this Listener.">
		<cfargument name="invoker" type="MachII.framework.ListenerInvoker" required="true" />
		<cfset variables.invoker = arguments.invoker />
	</cffunction>
	<cffunction name="getInvoker" access="public" returntype="MachII.framework.ListenerInvoker" output="false"
		hint="Gets the ListenerInvoker to use when invoking methods for this Listener.">
		<cfreturn variables.invoker />
	</cffunction>

</cfcomponent>