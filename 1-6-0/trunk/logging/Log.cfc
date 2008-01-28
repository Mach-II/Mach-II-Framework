<!---
License:
Copyright 2007 GreatBizTools, LLC

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
Mach-II Logging is heavily based on Apache Commons Logging interface but is more flexible as
it allows you attach multiple loggers at once.
--->
<cfcomponent
	displayname="Log"
	output="false"
	hint="A simple logging interface abstracting logging APIs. This is abstract and must be extend by a concrete implementation.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.channel = "" />
	<cfset variables.logAdapters = ArrayNew(1) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="package" returntype="Log" output="false"
		hint="Initializes the logging facade.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="logAdapters" type="array" required="true" />

		<cfset setChannel(arguments.channel) />
		<cfset setLogAdapters(arguments.logAdapters) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].debug(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].debug(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].error(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].error(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].fatal(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].fatal(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].info(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].info(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].trace(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].trace(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset variables.logAdapters[i].warn(getChannel(), arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset variables.logAdapters[i].warn(getChannel(), arguments.message) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="isDebugEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if debug level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isDebugEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="isErrorEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if error level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isErrorEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="isFatalEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if fatal level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isFatalEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="isInfoEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if info level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isInfoEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="isTraceEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if trace level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isTraceEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="isWarnEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if warn level logging is enabled.">

		<cfset var i = "" />
		
		<cfloop from="1" to="#ArrayLen(variables.logAdapters)#" index="i">
			<cfif variables.logAdapters[i].isWarnEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

	<!--
	ACCESSORS
	--->
	<cffunction name="setChannel" access="private" returntype="void" output="false"
		hint="Sets the channel.">
		<cfargument name="channel" type="string" required="true" />
		<cfset variables.channel = arguments.channel />
	</cffunction>
	<cffunction name="getChannel" access="public" returntype="string" output="false"
		hint="Returns the channel.">
		<cfreturn variables.channel />
	</cffunction>
	
	<cffunction name="setLogAdapters" access="private" returntype="void" output="false"
		hint="Sets the log adapters.">
		<cfargument name="logAdapters" type="array" required="true" />
		<cfset variables.logAdapters = arguments.logAdapters />
	</cffunction>
	<cffunction name="getLogAdapters" access="private" returntype="array" output="false"
		hint="Returns the log adapters.">
		<cfreturn variables.logAdapters />
	</cffunction>

</cfcomponent>