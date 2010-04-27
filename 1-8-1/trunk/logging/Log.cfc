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
Updated version: 1.8.0

Notes:
Mach-II Logging is heavily based on Apache Commons Logging interface.

Logging levels in order of least severe to most severe:
 * trace
 * debug
 * info
 * warn
 * error
 * fatal
--->
<cfcomponent
	displayname="Log"
	output="false"
	hint="A simple logging API.">

	<!---
	PROPERTIES
	--->
	<cfset variables.channel = "" />
	<cfset variables.logAdapters = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Log" output="false"
		hint="Initializes the logging facade.">
		<cfargument name="channel" type="string" required="true"
			hint="The channel name for this Log." />
		<cfargument name="logAdapters" type="struct" required="true"
			hint="A struct of registered log adapters. Struct are by reference total number of adapters may change during the lifetime of the application." />

		<cfset setChannel(arguments.channel) />
		<cfset setLogAdapters(arguments.logAdapters) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<!---
		The result of the StructKeyExists evaluation will not change after the first evaluation.
		Having two loops saves on multiple StructKeyExist calls over the lifetime
		of the request instead of an internally nested conditional statement.
		--->
		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].debug(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].debug(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].error(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].error(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].fatal(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].fatal(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].info(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].info(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].trace(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].trace(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfargument name="message" type="string" required="true"
			hint="A message to log." />
		<cfargument name="additionalInformation" type="any" required="false"
			hint="Any additional information which may or may not be used by the adapters. Takes all data types." />

		<cfset var channel = getChannel() />
		<cfset var key = "" />

		<cfif StructKeyExists(arguments, "additionalInformation")>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].warn(channel, arguments.message, arguments.additionalInformation) />
			</cfloop>
		<cfelse>
			<cfloop collection="#variables.logAdapters#" item="key">
				<cfset variables.logAdapters[key].warn(channel, arguments.message) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="isDebugEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if debug level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isDebugEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="isErrorEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if error level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isErrorEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="isFatalEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if fatal level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isFatalEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="isInfoEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if info level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isInfoEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="isTraceEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if trace level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isTraceEnabled()>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="isWarnEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if warn level logging is enabled.">

		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif variables.logAdapters[key].isWarnEnabled()>
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
		<cfargument name="logAdapters" type="struct" required="true" />
		<cfset variables.logAdapters = arguments.logAdapters />
	</cffunction>
	<cffunction name="getLogAdapters" access="public" returntype="struct" output="false"
		hint="Returns the log adapters.">
		<cfreturn variables.logAdapters />
	</cffunction>

</cfcomponent>