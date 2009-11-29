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
Updated version: 1.8.0

Notes:
Special thanks to the Simple Log in Apache Commons Logging project for 
inspiration for this component.
--->
<cfcomponent
	displayname="CFLogAdapter"
	extends="MachII.logging.adapters.AbstractLogAdapter"
	output="false"
	hint="A concrete adapter for CFLog.">
	
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
	
	<cfset variables.level = variables.LOG_LEVEL_FATAL />
	<cfset variables.debugModeOnly = false />
	<cfset variables.instance.logFile = "application" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the adapter.">
		
		<cfif isParameterDefined("logFile")>
			<cfset setlogFile(getParameter("logFile")) />
		</cfif>
		<cfif isParameterDefined("loggingLevel")>
			<cfset setLoggingLevel(getParameter("loggingLevel")) />
		</cfif>
		<cfif isParameterDefined("loggingEnabled")>
			<cfset setLoggingEnabled(getParameter("loggingEnabled")) />
		</cfif>
		<cfif isParameterDefined("debugModeOnly")>
			<cfif NOT IsBoolean(getParameter("debugModeOnly"))>
				<cfthrow type="MachII.logging.strategies.MachIILog.Logger"
					message="The value of 'debugModeOnly' must be boolean."
					detail="Current value '#getParameter('debugModeOnly')#'" />
			<cfelse>
				<cfset setDebugModeOnly(getParameter("debugModeOnly")) />
			</cfif>
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		
		<cfif isDebugEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_DEBUG, arguments.message, arguments.additionalInformation) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_DEBUG, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		
		<cfif isErrorEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_ERROR, arguments.message, arguments.additionalInformation) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_ERROR, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		
		<cfif isFatalEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message, arguments.additionalInformation) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_FATAL, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />

		<cfif isInfoEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_INFO, arguments.message, arguments.additionalInformation) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_INFO, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />

		<cfif isTraceEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_TRACE, arguments.message, arguments.additionalInformation) />
			<cfelse>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_TRACE, arguments.message) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />

		<cfif isWarnEnabled()>
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset logMessage(arguments.channel, variables.LOG_LEVEL_WARN, arguments.message, arguments.additionalInformation) />
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
		<cfif getLoggingEnabled() AND ((getDebugModeOnly() AND IsDebugMode()) OR NOT getDebugModeOnly())>
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
		<cfargument name="additionalInformation" type="any" required="false" />
		
		<cfset var type = translateLogLevelToCFLogType(arguments.logLevel) />
		<cfset var text = "[" & arguments.channel & "] " />
		
		<!--- Use the filter if defined, otherwise continue --->
		<cfif NOT isFilterDefined() OR getFilter().decide(arguments)>
			<!--- Add downgrade notice if log level is Trace, Debug or Info since cflog 
				does not have these levels and are logged on the "Information" level--->
			<cfif arguments.logLevel EQ 1>
				<cfset text = text & "(Trace) " />
			<cfelseif arguments.logLevel EQ 2>
				<cfset text = text & "(Debug) " />
			<cfelseif arguments.logLevel EQ 3>
				<cfset text = text & "(Info) " />
			</cfif>
			
			<!--- Append message --->
			<cfset text = text & arguments.message />
			
			<!--- Append and serialize to string the additional information if available --->
			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cftry>
					<cfset text = text & " :: " & arguments.additionalInformation.toString() />
					<cfcatch type="any">
						<!--- Easier to try and serialize the additional information with toString and
							fail then to try and see if toString is available --->
							<cfset text = text & " :: [Complex Value]" />
					</cfcatch>
				</cftry>
			</cfif>
			
			<!--- Make the cflog call --->
			<cflog type="#type#" text="#text#" file="#getLogFile()#" />
		</cfif>
	</cffunction>
	
	<cffunction name="translateLogLevelToCFLogType" access="private" returntype="string" output="false"
		hint="Translates a log level to a human readable string.">
		<cfargument name="logLevel" type="numeric" required="true" />
		
		<cfset var result = "" />
		
		<cfif arguments.logLevel EQ 1>
			<cfset result = "Information" />
		<cfelseif arguments.logLevel EQ 2>
			<cfset result = "Information" />
		<cfelseif arguments.logLevel EQ 3>
			<cfset result = "Information" />
		<cfelseif arguments.logLevel EQ 4>
			<cfset result = "Warning" />
		<cfelseif arguments.logLevel EQ 5>
			<cfset result = "Error" />
		<cfelseif arguments.logLevel EQ 6>
			<cfset result = "Fatal" />
		</cfif>
		
		<cfreturn result />
	</cffunction>
		
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingLevel" access="public" returntype="void" output="false"
		hint="Sets the logging level by name.">
		<cfargument name="loggingLevelName" type="string" required="true"
			hint="Accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'." />
		<!--- Set the numerical representation of this logging level name --->
		<cfset setLevel(translateNameToLevel(arguments.loggingLevelName)) />
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
	
	<cffunction name="setLogFile" access="private" returntype="void" output="false"
		hint="Sets the value for the cflog 'file' attribute.">
		<cfargument name="logFile" type="string" required="true" />
		<cfset variables.instance.logFile = arguments.logFile />
	</cffunction>
	<cffunction name="getLogFile" access="public" returntype="string" output="false"
		hint="Gets the value for the cflog 'file' attribute">
		<cfreturn variables.instance.logFile />
	</cffunction>

	<cffunction name="setDebugModeOnly" access="private" returntype="void" output="false"
		hint="Sets if the adapter will log if the CFML server debug mode is enabled.">
		<cfargument name="debugModeOnly" type="boolean" required="true" />
		<cfset variables.debugModeOnly = arguments.debugModeOnly />
	</cffunction>
	<cffunction name="getDebugModeOnly" access="public" returntype="boolean" output="false"
		hint="Gets if the adapter will log if the CFML server debug mode is enabled.">
		<cfreturn variables.debugModeOnly />
	</cffunction>

</cfcomponent>