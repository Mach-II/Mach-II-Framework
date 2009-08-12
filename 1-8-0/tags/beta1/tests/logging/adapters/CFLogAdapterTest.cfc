<!---
License:
Copyright 2009 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
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