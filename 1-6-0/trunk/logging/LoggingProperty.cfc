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
$Id: Log.cfc 584 2007-12-15 08:44:43Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:

Configuring for Mach-II logging only:
<property name="Logging" type="MachII.properties.LoggingProperty" />

This will turn on the MachIILog logger and display the log message 
in the request output.

Configuring multiple logging adapters:
<property name="Logging" type="MachII.properties.LoggingProperty">
	<parameters>
		<!-- Optionally turns logging on/off (loggingEnabled values in the adapters are still adhered to)-->
		<parameter name="loggingEnabled" value="false"/>
		<parameter name="CFLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.CFLog.Logger" />
				<key name="loggingEnabled" value="false" />
				<key name="loggingLevel" value="warn" />
			</struct>
		</parameter>
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.loggers.MachIILog.Logger" />
				<key name="loggingEnabled" value="true" />
				<key name="loggingLevel" value="debug" />
			</struct>
		</parameter>
	</parameters>
</property>

See individual loggers for more information on configuration.
--->
<cfcomponent
	displayname="LoggingProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Connects Mach-II Logging to the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.loggingEnabled = true />
	<cfset variables.loggers = StructNew() />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var params = getParameters() />
		<cfset var configured = false />
		<cfset var i = 0 />
		
		<!--- Set if logging is enabled (which is by default true) --->
		<cfif isParameterDefined("loggingEnabled")>
			<cfset setLoggingEnabled(getParameter("loggingEnabled")) />
		</cfif>
		
		<!--- Determine if we should load logger or use the default 
			logger (e.g. MachII.logging.loggers.MachIILog.Logger) --->
		<cfloop collection="#params#" item="i">
			<cfif i NEQ "enableLogging" AND IsStruct(params[i])>
				<cfset configureLogger(i, getParameter(i)) />
				<cfset configured = true />
			</cfif>
		</cfloop>
		
		<!--- Configure the default logger since no loggers were set --->
		<cfif NOT configured>
			<cfset configureDefaultLogger() />
		</cfif>
		
		<!--- Set logging enabled/disabled --->
		<cfif NOT getLoggingEnabled()>
			<cfset getAppManager().getLogFactory().disableLogging() />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="disableLogging" access="public" returntype="void" output="false"
		hint="Disables logging.">
		<cfset getAppManager().getLogFactory().disableLogging() />
	</cffunction>
	
	<cffunction name="enableLogging" access="public" returntype="void" output="false"
		hint="Enables logging.">
		<cfset getAppManager().getLogFactory().enableLogging() />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="configureDefaultLogger" access="private" returntype="void" output="false"
		hint="Configures the default logging adapter (e.g. MachII.logging.adapters.MachIILogAdapter).">
		
		<cfset var logger = "" />
		<cfset var parameters = StructNew() />
		
		<cfset logger = CreateObject("component", "MachII.logging.loggers.MachIILog.Logger").init(parameters) />
		<cfset logger.configure() />

		<!--- Set the logger --->
		<cfset addLogger("logger", adapter) />
	</cffunction>
	
	<cffunction name="configureLogger" access="private" returntype="void" output="false"
		hint="Configures an logger.">
		<cfargument name="name" type="string" required="true"
			hint="Name of the logger" />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for thislogger.">
		
		<cfset var type = "" />
		<cfset var logger = "" />
		<cfset var i = 0 />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.properties.LoggingProperty"
				message="You must specify a 'type' for log adapter named '#arguments.name#'." />
		</cfif>
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="i">
			<cfset arguments.parameters[i] = bindValue(i, arguments.parameters[i]) />
		</cfloop>
		
		<!--- Create, init and configure the adapter --->
		<cfset logger = CreateObject("component", arguments.parameters.type).init(getAppManager().getLogFactory(), arguments.parameters) />
		<cfset logger.configure() />
		
		<!--- Add a callback to the request manager if there is display to output --->
		<cfif logger.isDisplayOutputAvailable()>
			<cfset getAppManager().getRequestManager().addOnRequestEndCallback(logger, "displayOutput") />
		</cfif>
		
		<!--- Add the logger --->
		<cfset addLogger(arguments.name, logger) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingEnabled" access="public" returntype="void" output="false"
		hint="Sets if logging is enabled.">
		<cfargument name="loggingEnabled" type="boolean" required="true" />
		<cfset variables.loggingEnabled = arguments.loggingEnabled />
	</cffunction>
	<cffunction name="getLoggingEnabled" access="public" returntype="boolean" output="false"
		hint="Gets the value if logging is enabled.">
		<cfreturn variables.loggingEnabled />
	</cffunction>
	
	<cffunction name="addLogger" access="private" returntype="void" output="false"
		hint="Adds a logger to the struct of registered loggers.">
		<cfargument name="loggerName" type="string" required="true" />
		<cfargument name="logger" type="MachII.logging.loggers.AbstractLogger" required="true" />
		
		<cfif StructKeyExists(variables.loggers, arguments.loggerName)>
			<cfthrow type="MachII.properties.LoggingProperty"
				message="A logger named '#arguments.loggerName#' already exists. Logger names must be unique." />
		<cfelse>
			<cfset variables.loggers[arguments.loggerName] = arguments.logger />
		</cfif>
	</cffunction>
	<cffunction name="getLoggers" access="public" returntype="struct" output="false"
		hint="Gets all the registered loggers.">
		<cfreturn variables.loggers />
	</cffunction>
	
</cfcomponent>