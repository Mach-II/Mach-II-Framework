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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="EventTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.Event.">

	<!---
	PROPERTIES
	--->
	<cfset variables.event = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var args = StructNew() />

		<!--- Test data to populate args --->
		<cfset args.name = "Mach-II" />
		<cfset args.version = 1234 />

		<cfset variables.event = CreateObject("component", "MachII.framework.Event").init("test", args, "test", "", "") />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testGeneral" access="public" returntype="void" output="false"
		hint="Tests general functions.">

		<!--- setArg is tested by setArgs as it loops over the pass struct --->
		<cfset assertEquals(variables.event.getArg("name"), "Mach-II") />
		<cfset assertEquals(variables.event.getArg("version"), "1234") />

		<cfset assertTrue(variables.event.isArgDefined("name")) />
		<cfset assertTrue(variables.event.isArgDefined("version")) />

		<cfset assertFalse(variables.event.isArgDefined("junkArg")) />

	</cffunction>

</cfcomponent>