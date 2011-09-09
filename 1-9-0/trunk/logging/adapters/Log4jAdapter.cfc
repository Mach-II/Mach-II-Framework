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

Author: Jason York (jason.york@gmail.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

--->
<cfcomponent
	displayname="Log4jAdapter"
	extends="MachII.logging.adapters.AbstractLogAdapter"
	output="false"
	hint="A concrete adapter for Log4j.">

	<!---
	PROPERTIES
	--->
	<cfset variables.level = variables.LOG_LEVEL_FATAL />
	<cfset variables.debugModeOnly = false />
	<cfset variables.instance.configFile = "" />
	<cfset variables.log4jLogger = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the adapter.">

		<cfset var category = "" />
		<cfset var configurator = "" />

		<cfif isParameterDefined("configFile")>
			<cfset setConfigFile(ExpandPath(getParameter("configFile"))) />
		</cfif>
		<cfif isParameterDefined("loggingLevel")>
			<cfset setLoggingLevel(getParameter("loggingLevel")) />
		</cfif>
		<cfif isParameterDefined("loggingEnabled")>
			<cfset setLoggingEnabled(getParameter("loggingEnabled")) />
		</cfif>
		<cfif isParameterDefined("debugModeOnly")>
			<cfif NOT IsBoolean(getParameter("debugModeOnly"))>
				<cfthrow type="MachII.logging.adapters.Log4jAdapter"
					message="The value of 'debugModeOnly' must be boolean."
					detail="Current value '#getParameter('debugModeOnly')#'" />
			<cfelse>
				<cfset setDebugModeOnly(getParameter("debugModeOnly")) />
			</cfif>
		</cfif>

		<!--- Setup a configurator for Log4J if defined otherwise use the default --->
		<cfif Len(getConfigFile())>
			<cfif FileExists(getConfigFile())>
				<cfif getConfigFile().toLowerCase().endsWith(".properties")>
					<cfset configurator = CreateObject("java", "org.apache.log4j.PropertyConfigurator") />
				<cfelseif getConfigFile().toLowerCase().endsWith(".xml")>
					<cfset configurator = CreateObject("java", "org.apache.log4j.xml.DOMConfigurator") />
				<cfelse>
					<cfthrow type="MachII.logging.adapters.Log4jAdapter"
						message="Config file must end in either '.properties' or '.xml'" />
				</cfif>
				<cfset configurator.configure(getConfigFile()) />
			<cfelse>
				<cfthrow type="MachII.logging.adapters.Log4jAdapter"
					message="Could not find specified config file: #getConfigFile()#"/>
			</cfif>
		</cfif>

		<cfset variables.log4jLogger = CreateObject("java", "org.apache.log4j.Logger") />
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

		<cfset var text = "" />
		<cfset var logger = "" />

		<!--- Use the filter if defined, otherwise continue --->
		<cfif NOT isFilterDefined() OR getFilter().decide(arguments)>

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

			<cfset logger = variables.log4jLogger.getLogger(arguments.channel) />
			<cfif arguments.logLevel EQ variables.LOG_LEVEL_TRACE>
				<cfset logger.trace(text) />
			<cfelseif arguments.logLevel EQ variables.LOG_LEVEL_DEBUG>
				<cfset logger.debug(text) />
			<cfelseif arguments.logLevel EQ variables.LOG_LEVEL_INFO>
				<cfset logger.info(text) />
			<cfelseif arguments.logLevel EQ variables.LOG_LEVEL_WARN>
				<cfset logger.warn(text) />
			<cfelseif arguments.logLevel EQ variables.LOG_LEVEL_ERROR>
				<cfset logger.error(text) />
			<cfelseif arguments.logLevel EQ variables.LOG_LEVEL_FATAL>
				<cfset logger.fatal(text) />
			</cfif>
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

	<cffunction name="setConfigFile" access="private" returntype="void" output="false"
		hint="Sets the value for the cflog 'file' attribute.">
		<cfargument name="configFile" type="string" required="true" />
		<cfset variables.instance.configFile = arguments.configFile />
	</cffunction>
	<cffunction name="getConfigFile" access="public" returntype="string" output="false"
		hint="Gets the value for the cflog 'file' attribute">
		<cfreturn variables.instance.configFile />
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