<!---
License:
Copyright 2008 GreatBizTools, LLC

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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Mach-II Logging is heavily based on Apache Commons Logging interface.
--->
<cfcomponent
	displayname="LoggerManager"
	output="false"
	hint="A manager that handles loggers">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.parent = "" />
	<cfset variables.logFactory = "" />
	<cfset variables.loggers = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="LoggerManager" 
		hint="Initializes the manager.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfargument name="parentLoggerManager" type="MachII.logging.LoggerManager" required="false" />
		
		<cfset setLogFactory(arguments.logFactory) />
		
		<!--- Set optional arguments if they exist --->
		<cfif StructKeyExists(arguments, "parentLoggerManager")>
			<cfset setParent(arguments.parentLoggerManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the loggers.">
		
		<cfset var logFactory = getLogFactory() />
		<cfset var loggers = getLoggers() />
		<cfset var key = "" />
		
		<cfloop collection="#loggers#" item="key">
			<cfset loggers[key].configure() />
			<cfset logFactory.addLogAdapter(loggers[key].getLogAdapter()) />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getLoggerByName" access="public" returntype="MachII.caching.loggers.AbstractLogger" output="false"
		hint="Gets a logger with the specified name.">
		<cfargument name="loggerName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent logger manager." />
		
		<cfif isLoggerDefined(arguments.loggerName)>
			<cfreturn variables.loggers[arguments.loggerName] />
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isLoggerDefined(arguments.loggerName)>
			<cfreturn getParent().getLoggerByName(arguments.loggerName, arguments.checkParent) />
		<cfelse>
			<cfthrow type="MachII.logging.LoggerNotDefined" 
				message="Logger with name '#arguments.loggerName#' is not defined."
				detail="Available loggers: '#ArrayToList(getLoggerNames())#'" />
		</cfif>
	</cffunction>

	<cffunction name="addLogger" access="public" returntype="void" output="false"
		hint="Registers a logger with the specified name.">
		<cfargument name="loggerName" type="string" required="true" />
		<cfargument name="logger" type="MachII.logging.loggers.AbstractLogger" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isLoggerDefined(arguments.LoggerName)>
			<cfthrow type="MachII.logging.LoggerAlreadyDefined"
				message="A logger with name '#arguments.loggerName#' is already registered." />
		<cfelse>
			<cfset variables.Loggers[arguments.LoggerName] = Logger />
		</cfif>
	</cffunction>

	<cffunction name="isLoggerDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a logger is registered with the specified name. Does NOT check parent.">
		<cfargument name="loggerName" type="string" required="true"
			hint="Name of logger to check if defined." />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent logger manager." />
		
		<cfif StructKeyExists(variables.Loggers, arguments.LoggerName)>
			<cfreturn true />
		<cfelseif arguments.checkParent AND IsObject(getParent()) AND getParent().isLoggerDefined(arguments.LoggerName)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="loadLogger" access="public" returntype="void" output="false"
		hint="Loads a logger and adds the logger to the manager.">
		<cfargument name="loggerName" type="string" required="true"
			hint="Name of logger name." />
		<cfargument name="loggerId" type="string" required="true"
			hint="Name of logger id." />
		<cfargument name="loggerType" type="string" required="true"
			hint="Dot path to the logger." />
		<cfargument name="loggerParameters" type="struct" required="false" default="#StructNew()#"
			hint="Configuration parameters for the logger." />
		
		<cfset var logger = "" />
		
		<!--- Create the logger --->
		<cftry>
			<cfset logger = CreateObject("component", arguments.LoggerType).init(arguments.loggerId, arguments.LoggerParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName")>
					<cfthrow type="MachII.logger.CannotFindLogger"
						message="Cannot find a logger CFC with type of '#arguments.LoggerType#' for the logger named '#arguments.loggerName#'."
						detail="Please check that the logger exists and that there is not a misconfiguration." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfset addLogger(arguments.loggerName, logger) />
	</cffunction>

	<cffunction name="getLoggers" access="public" returntype="struct" output="false"
		hint="Gets all registered loggers for this manager. Does NOT get loggers from a parent manager.">
		<cfreturn variables.Loggers />
	</cffunction>

	<cffunction name="getLoggerNames" access="public" returntype="array" output="false"
		hint="Returns an array of logger names for this manager. Does NOT get logger names from a parent manager.">
		<cfreturn StructKeyArray(variables.Loggers) />
	</cffunction>
	
	<cffunction name="containsLoggers" access="public" returntype="boolean" output="false"
		hint="Returns a boolean of on whether or not there are any registered loggers.">
		<cfreturn StructCount(variables.Loggers) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setLogFactory" access="public" returntype="void" output="false">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.logFactory = arguments.logFactory />
	</cffunction>
	<cffunction name="getLogFactory" access="public" returntype="MachII.logging.LogFactory" output="false">
		<cfreturn variables.logFactory />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent LoggerManager instance this LoggerManager belongs to.">
		<cfargument name="parentLoggerManager" type="MachII.logging.LoggerManager" required="true" />
		<cfset variables.parent = arguments.parentLoggerManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent LoggerManager instance this LoggerManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parent />
	</cffunction>

</cfcomponent>