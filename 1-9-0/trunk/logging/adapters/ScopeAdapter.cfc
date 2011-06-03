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
Updated version: 1.8.0

Notes:
Special thanks to the Simple Log in Apache Commons Logging project for inspiration for this component.

Uses the GenericChannelFitler for filtering. See that CFC for information on how to use to setup filters.
--->
<cfcomponent
	displayname="ScopeAdapter"
	extends="MachII.logging.adapters.AbstractLogAdapter"
	output="false"
	hint="A concrete adapter for scope logging. Logs messages to a scope.">

	<!---
	PROPERTIES
	--->
	<cfset variables.level = variables.LOG_LEVEL_DEBUG />
	<cfset variables.debugModeOnly = false />

	<cfset variables.instance.loggingScope = "request" />
	<cfset variables.instance.loggingPath = "_ScopeLogging" & "_" & Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000)) />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the adapter.">

		<cfif isParameterDefined("loggingScope")>
			<cfset setLoggingScope(getParameter("loggingScope")) />
		</cfif>
		<cfif isParameterDefined("loggingPath")>
			<cfset setLoggingPath(getParameter("loggingPath")) />
		</cfif>
		<cfif isParameterDefined("loggingLevel")>
			<cfset setLoggingLevel(getParameter("loggingLevel")) />
		</cfif>
		<cfif isParameterDefined("loggingEnabled")>
			<cfset setLoggingEnabled(getParameter("loggingEnabled")) />
		</cfif>
		<cfif isParameterDefined("debugModeOnly")>
			<cfset setDebugModeOnly(getParameter("debugModeOnly")) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="isLoggingDataDefined" access="public" returntype="boolean" output="false"
		hint="Checks if logging data is defined.">

		<!--- Deprecated as of revision 1933 (1.8). Always returns true --->
		<cfreturn true/>
	</cffunction>

	<cffunction name="getLoggingData" access="public" returntype="struct" output="false"
		hint="Gets logging data.">

		<cfset var scope = StructGet(getLoggingScope()) />

		<cfif not StructKeyExists(scope, getLoggingPath())>
			<cfset scope[getLoggingPath()] = StructNew() />
			<cfset scope[getLoggingPath()].data = ArrayNew(1) />
		</cfif>

		<cfreturn scope[getLoggingPath()] />
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
		<cfargument name="additionalInformation" type="any" required="false" />

		<cfset var entry = StructNew() />
		<cfset var scope = StructGet(getLoggingScope()) />

		<!--- Filter the message by channel --->
		<cfif NOT isFilterDefined() OR getFilter().decide(arguments)>
			<!--- See if we need to create a place to put the log messages --->
			<cfif NOT IsDefined(getLoggingScope() & "." & getLoggingPath() & ".data")>
				<cfset scope[getLoggingPath()] = StructNew() />
				<cfset scope[getLoggingPath()].data = ArrayNew(1) />
			</cfif>

			<cfset entry.channel = arguments.channel />
			<cfset entry.logLevel = arguments.logLevel />
			<cfset entry.logLevelName = translateLevelToName(arguments.logLevel) />
			<cfset entry.message = arguments.message />
			<cfset entry.currentTick = getTickCount() />

			<cfif StructKeyExists(arguments, "additionalInformation")>
				<cfset entry.additionalInformation = arguments.additionalInformation />
			<cfelse>
				<cfset entry.additionalInformation = "" />
			</cfif>

			<cfset ArrayAppend(scope[getLoggingPath()].data, entry) />
		</cfif>
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

	<cffunction name="setLoggingScope" access="private" returntype="void" output="false"
		hint="Sets the logging scope.">
		<cfargument name="loggingScope" type="string" required="true" />
		<cfset variables.instance.loggingScope = arguments.loggingScope />
	</cffunction>
	<cffunction name="getLoggingScope" access="public" returntype="string" output="false"
		hint="Gets the logging scope.">
		<cfreturn variables.instance.loggingScope />
	</cffunction>

	<cffunction name="setLoggingPath" access="private" returntype="void" output="false"
		hint="Sets the logging path.">
		<cfargument name="loggingPath" type="string" required="true" />
		<cfset variables.instance.loggingPath = arguments.loggingPath />
	</cffunction>
	<cffunction name="getLoggingPath" access="public" returntype="string" output="false"
		hint="Gets the logging path.">
		<cfreturn variables.instance.loggingPath />
	</cffunction>

	<cffunction name="setDebugModeOnly" access="private" returntype="void" output="false"
		hint="Sets if the adapter will log if the CFML server debug mode is enabled.">
		<cfargument name="debugModeOnly" type="boolean" required="true" />
		<cfset variables.debugModeOnly = arguments.debugModeOnly />
	</cffunction>
	<cffunction name="getDebugModeOnly" access="public" returntype="string" output="false"
		hint="Gets if the adapter will log if the CFML server debug mode is enabled.">
		<cfreturn variables.debugModeOnly />
	</cffunction>

</cfcomponent>