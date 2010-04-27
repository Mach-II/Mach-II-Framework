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
	displayname="CFLogAdapterTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.adapters.CFLogAdapter.">

	<!---
	PROPERTIES
	--->
	<cfset variables.channel = "AdapterTest" />
	<cfset variables.adapter = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var parameters = StructNew() />

		<!--- Setup parameters --->
		<cfset parameters.loggingLevel = "all" />

		<cfset variables.adapter = CreateObject("component", "MachII.logging.adapters.CFLogAdapter").init(parameters) />
		<cfset variables.adapter.configure() />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfset variables.adapter.debug(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfset variables.adapter.error(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfset variables.adapter.fatal(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfset variables.adapter.info(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfset variables.adapter.trace(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfset variables.adapter.warn(variables.channel, "Test message") />
	</cffunction>

	<cffunction name="isDebugEnabled" access="public" returntype="void" output="false"
		hint="Checks if debug level logging is enabled.">
		<cfset assertTrue(variables.adapter.isDebugEnabled()) />
	</cffunction>

	<cffunction name="isErrorEnabled" access="public" returntype="void" output="false"
		hint="Checks if error level logging is enabled.">
		<cfset assertTrue(variables.adapter.isErrorEnabled()) />
	</cffunction>

	<cffunction name="isFatalEnabled" access="public" returntype="void" output="false"
		hint="Checks if fatal level logging is enabled.">
		<cfset assertTrue(variables.adapter.isFatalEnabled()) />
	</cffunction>

	<cffunction name="isInfoEnabled" access="public" returntype="void" output="false"
		hint="Checks if info level logging is enabled.">
		<cfset assertTrue(variables.adapter.isInfoEnabled()) />
	</cffunction>

	<cffunction name="isTraceEnabled" access="public" returntype="void" output="false"
		hint="Checks if trace level logging is enabled.">
		<cfset assertTrue(variables.adapter.isTraceEnabled()) />
	</cffunction>

	<cffunction name="isWarnEnabled" access="public" returntype="void" output="false"
		hint="Checks if warn level logging is enabled.">
		<cfset assertTrue(variables.adapter.isWarnEnabled()) />
	</cffunction>

	<cffunction name="testChangeLogLevel" access="public" returntype="void" output="false"
		hint="Tests changing log level by name.">

		<cfset var levels = "trace|debug|info|warn|error|fatal|all|off" />
		<cfset var i = "" />

		<cfloop list="#levels#" delimiters="|" index="i">
			<cfset variables.adapter.setLoggingLevel(i) />
			<cfset assertEquals(variables.adapter.getLoggingLevel(), i) />
		</cfloop>
	</cffunction>

</cfcomponent>