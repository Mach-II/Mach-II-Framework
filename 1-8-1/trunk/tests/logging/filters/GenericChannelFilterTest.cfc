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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogFactoryTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.filters.GenericChannelFilter.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testMatchNothing" access="public" returntype="void" output="false"
		hint="Tests that matches no channels.">

		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("!*") />

		<cfset doTest(filter, "path.to.that", false) />
		<cfset doTest(filter, "path.to.this", false) />
	</cffunction>

	<cffunction name="testMatchEverything" access="public" returntype="void" output="false"
		hint="Tests that matches all channels.">

		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("*") />

		<cfset doTest(filter, "path.to.that", true) />
		<cfset doTest(filter, "path.to.this", true) />
	</cffunction>

	<cffunction name="testMatchSome" access="public" returntype="void" output="false"
		hint="Tests that matches only some channels.">

		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init("!*,MachII.*,!MachII.filters.*") />

		<cfset doTest(filter, "MachII.framework.RequestHandler", true) />
		<cfset doTest(filter, "MachII.framework.EventHandler", true) />
		<cfset doTest(filter, "MachII.filters.EventArgsFilter", false) />
		<cfset doTest(filter, "path.to.that", false) />
		<cfset doTest(filter, "path.to.this", false) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="doTest" access="private" returntype="void" output="false"
		hint="Helper method to perform a test.">
		<cfargument name="filter" type="any" required="true" />
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="shouldMatch" type="boolean" required="true" />

		<cfset var logMessageElements = StructNew() />

		<cfset logMessageElements.channel = arguments.channel />

		<cfif arguments.shouldMatch>
			<cfset assertTrue(arguments.filter.decide(logMessageElements), "Failed on channel '#logMessageElements.channel#'.") />
		<cfelse>
			<cfset assertFalse(arguments.filter.decide(logMessageElements), "Failed on channel '#logMessageElements.channel#'.") />
		</cfif>
	</cffunction>

</cfcomponent>