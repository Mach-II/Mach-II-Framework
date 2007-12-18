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
Special thanks to the Simple Log in Apache Commons Logging project for inspiration for this component.

Uses the GenericChannelFitler for filtering. See that CFC for information on how to use to setup a filters.

Configuration Example:
<property name="logging" type="MachII.properties.LoggingProperty">
	<parameters>
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.adapters.MachIILogAdapter" />
				<key name="loggingEnabled" value="true|false" />
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<key name="debugModeOnly" value="true|false" />
				<key name="filter" value="list,of,filter,criteria" />
				- OR -
				<key name="filter">
					<array>
						<element value="array" />
						<element value="of" />
						<element value="filter" />
						<element value="criteria" />
					</array>
				</key>
			</struct>
		</parameter>
	</parameters>
</property>
--->
<cfcomponent
	displayname="CFLogAdapter"
	extends="MachII.logging.adapters.AbstractLogAdapter"
	output="false"
	hint="A concrete adapter for MachII logging.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.LOG_LEVEL_TRACE = 1 />
	<cfset variables.LOG_LEVEL_DEBUG = 2 />
	<cfset variables.LOG_LEVEL_INFO = 3 />
	<cfset variables.LOG_LEVEL_WARN = 4 />
	<cfset variables.LOG_LEVEL_ERROR = 5 />
	<cfset variables.LOG_LEVEL_FATAL = 6 />
	<cfset variables.LOG_LEVEL_ALL = 0 />
	<cfset variables.LOG_LEVEL_OFF = 7 />
	
	<cfset variables.level = variables.LOG_LEVEL_DEBUG />
	<cfset variables.loggerName = "MachII Logging" />
	<cfset variables.debugModeOnly = false />
	<cfset variables.filter = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the adapter.">
		
		<cfif isParameterDefined("loggingLevel")>
			<cfset setLoggingLevel(getParameter("loggingLevel")) />
		</cfif>
		<cfif isParameterDefined("loggingEnabled")>
			<cfset setLoggingEnabled(getParameter("loggingEnabled")) />
		</cfif>
		<cfif isParameterDefined("debugModeOnly")>
			<cfset setDebugModeOnly(getParameter("debugModeOnly")) />
		</cfif>
		
		<cfset setFilter(CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init(getParameter("filter", ""))) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />
		
		<cfif isDebugEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_DEBUG, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_DEBUG, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />
		
		<cfif isErrorEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_ERROR, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_ERROR, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />
		
		<cfif isFatalEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfif isFatalEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfif isTraceEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_TRACE, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_TRACE, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />

		<cfif isWarnEnabled()>
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_WARN, arguments.message, arguments.caughtException) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_WARN, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="isDebugEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if debug level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_DEBUG) />
	</cffunction>
	
	<cffunction name="isErrorEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if error level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_ERROR) />
	</cffunction>
	
	<cffunction name="isFatalEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if fatal level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_FATAL) />
	</cffunction>
	
	<cffunction name="isInfoEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if info level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_INFO) />
	</cffunction>
	
	<cffunction name="isTraceEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if trace level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_TRACE) />
	</cffunction>
	
	<cffunction name="isWarnEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if warn level logging is enabled.">
		<cfreturn isLevelEnabled(variables.LOG_LEVEL_WARN) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="isLevelEnabled" access="private" returntype="boolean" output="false"
		hint="Checks if the passed log level is enabled.">
		<cfargument name="logLevel" type="numeric" required="true"
			hint="Log levels are numerically ordered for easier comparison." />
		<cfif getLoggingEnabled() AND ((getDebugModeOnly() AND isDebugMode()) OR NOT getDebugModeOnly())>
			<cfreturn arguments.logLevel GTE getLevel() />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="logMessage" access="private" returntype="void" output="false"
		hint="Logs a message.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="logLevel" type="numeric" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="caughtException" type="any" required="false" />
		
		<cfset var entry = StructNew() />
		
		<!--- Filter the message by channel --->
		<cfif getFilter().decide(arguments.channel)>
		
			<!--- See if we need to create a place to put the log messages --->
			<cfif NOT StructKeyExists(request, "_MachIILog")>
				<cfset request._MachIILog = ArrayNew(1) />
			</cfif>
			
			<cfset entry.channel = arguments.channel />
			<cfset entry.logLevel = arguments.logLevel />
			<cfset entry.logLevelName = translateLevelToName(arguments.logLevel) />
			<cfset entry.message = arguments.message />
			<cfset entry.tick = getTickCount() />
			<cfif StructKeyExists(arguments, "caughtException")>
				<cfset entry.caughtException = arguments.caughtException />
			<cfelse>
				<cfset entry.caughtException = "" />
			</cfif>
			
			<cfset ArrayAppend(request._MachIILog, entry) />
		</cfif>
	</cffunction>
	
	<cffunction name="translateLevelToName" access="private" returntype="string" output="false"
		hint="Translate a numerical logging level to human readable string.">
		<cfargument name="level" type="numeric" required="true" />

		<cfset var loggingLevelName = "" />
		
		<cfif arguments.level EQ 1>
			<cfset loggingLevelName = "trace" />
		<cfelseif  arguments.level EQ 2>
			<cfset loggingLevelName = "debug" />
		<cfelseif  arguments.level EQ 3>
			<cfset loggingLevelName = "info" />
		<cfelseif  arguments.level EQ 4>
			<cfset loggingLevelName = "warn" />
		<cfelseif  arguments.level EQ 5>
			<cfset loggingLevelName = "error" />
		<cfelseif  arguments.level EQ 6>
			<cfset loggingLevelName = "fatal" />
		<cfelseif  arguments.level EQ 0>
			<cfset loggingLevelName = "all" />
		<cfelseif  arguments.level EQ 7>
			<cfset loggingLevelName = "off" />
		</cfif>
		
		<cfreturn loggingLevelName />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingLevel" access="public" returntype="void" output="false"
		hint="Sets the logging level by name.">
		<cfargument name="loggingLevelName" type="string" required="true"
			hint="Accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'." />
		
		<cfset var level = "" />
		
		<cfif NOT ListFindNoCase("trace|debug|info|warn|error|fatal|all|off",  arguments.loggingLevelName, "|")>
			<cfthrow message="The argument named 'loggingLevelName' accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'."
				detail="Passed value:#arguments.loggingLevelName#" />
		</cfif>
		
		<cfif arguments.loggingLevelName EQ "trace">
			<cfset level = 1 />
		<cfelseif  arguments.loggingLevelName EQ "debug">
			<cfset level = 2 />
		<cfelseif  arguments.loggingLevelName EQ "info">
			<cfset level = 3 />
		<cfelseif  arguments.loggingLevelName EQ "warn">
			<cfset level = 4 />
		<cfelseif  arguments.loggingLevelName EQ "error">
			<cfset level = 5 />
		<cfelseif  arguments.loggingLevelName EQ "fatal">
			<cfset level = 6 />
		<cfelseif  arguments.loggingLevelName EQ "all">
			<cfset level = 0 />
		<cfelseif  arguments.loggingLevelName EQ "off">
			<cfset level = 7 />
		</cfif>
		
		<!--- Set the numerical representation of this logging level name --->
		<cfset setLevel(level) />
	</cffunction>
	<cffunction name="getLoggingLevel" access="public" returntype="string" output="false"
		hint="Gets the logging level by name.">
		<cfreturn translateLevelToName(getLevel()) />
	</cffunction>
	
	<cffunction name="setLevel" access="private" returntype="void" output="false"
		hint="Sets the internal numeric log level.">
		<cfargument name="level" type="numeric" required="true"
			hint="Accepts an integer 0 through 7" />
		
		<cfif NOT REFind("^([0-7]{1})$", arguments.level)>
			<cfthrow message="The argument named 'level' accepts an integer 0 through 7."
				detail="Passed value:#arguments.level#" />
		</cfif>
		
		<cfset variables.level = arguments.level />
	</cffunction>
	<cffunction name="getLevel" access="private" returntype="numeric" output="false"
		hint="Returns the internal numeric log level.">
		<cfreturn variables.level />
	</cffunction>
	
	<cffunction name="setFilter" access="private" returntype="void" output="false"
		hint="Sets the filter.">
		<cfargument name="filter" type="any" required="true" />
		<cfset variables.filter = arguments.filter />
	</cffunction>
	<cffunction name="getFilter" access="public" returntype="any" output="false"
		hint="Gets the filter.">
		<cfreturn variables.filter />
	</cffunction>
	
	<cffunction name="setDebugModeOnly" access="private" returntype="void" output="false"
		hint="Sets if we should log only if debug mode is on in CF.">
		<cfargument name="debugModeOnly" type="boolean" required="true" />
		<cfset variables.debugModeOnly = arguments.debugModeOnly />
	</cffunction>
	<cffunction name="getDebugModeOnly" access="public" returntype="string" output="false"
		hint="Gets the value of if we should log only if debug mode is on in CF.">
		<cfreturn variables.debugModeOnly />
	</cffunction>
	
</cfcomponent>