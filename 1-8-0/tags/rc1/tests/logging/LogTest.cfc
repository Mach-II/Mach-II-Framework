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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.Log.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var adapters = StructNew() />
				
		<cfset adapters.test = CreateObject("component", "MachII.logging.adapters.ScopeAdapter").init(StructNew()) />
		<cfset adapters.test.configure() />
		
		<cfset variables.log = CreateObject("component", "MachII.logging.Log").init("testChannel", adapters) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testDebug" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with debug log level.">

		<cfset variables.log.debug("This is a test message.") />
		<cfset variables.log.debug("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testError" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with error log level.">

		<cfset variables.log.error("This is a test message.") />
		<cfset variables.log.error("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testFatal" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with fatal log level.">

		<cfset variables.log.fatal("This is a test message.") />
		<cfset variables.log.fatal("This is a test message.", StructNew()) />
	</cffunction>

	<cffunction name="testInfo" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with info log level.">

		<cfset variables.log.info("This is a test message.") />
		<cfset variables.log.info("This is a test message.", StructNew()) />
	</cffunction>

	<cffunction name="testTrace" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with trace log level.">
		
		<cfset variables.log.trace("This is a test message.") />
		<cfset variables.log.trace("This is a test message.", StructNew()) />
	</cffunction>
	
	<cffunction name="testWarn" access="public" returntype="void" output="false"
		hint="Runs a test that logs a message with warn log level.">

		<cfset variables.log.warn("This is a test message.") />
		<cfset variables.log.warn("This is a test message.", StructNew()) />
	</cffunction>

</cfcomponent>