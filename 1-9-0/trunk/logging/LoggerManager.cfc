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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Mach-II Logging is heavily based on Apache Commons Logging interface.
--->
<cfcomponent
	displayname="LoggerManager"
	output="false"
	hint="A manager that handles loggers.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.parent = "" />
	<cfset variables.logFactory = "" />
	<cfset variables.loggers = StructNew() />

	<cfset variables.LOGGER_SHORTCUTS = StructNew() />
	<cfset variables.LOGGER_SHORTCUTS["CFLogLogger"] = "MachII.logging.loggers.CFLog.Logger" />
	<cfset variables.LOGGER_SHORTCUTS["EmailLogger"] = "MachII.logging.loggers.EmailLog.Logger" />
	<cfset variables.LOGGER_SHORTCUTS["MachIILogger"] = "MachII.logging.loggers.MachIILog.Logger" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="LoggerManager" output="false" 
		hint="Initializes the manager.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="false"
			default="#CreateObject("component", "MachII.logging.LogFactory").init()#"
			hint="A log factory instance to use. Otherwise it will create its own instance." />
		<cfargument name="parentLoggerManager" type="MachII.logging.LoggerManager" required="false"
			hint="The parent LoggerManager. Used in hierarchical circumstances like Mach-II modules." />
		
		<!--- Set the log factory use the default of an external one is not provided  --->
		<cfset setLogFactory(arguments.logFactory) />
		
		<!--- Set optional arguments if they exist --->
		<cfif StructKeyExists(arguments, "parentLoggerManager")>
			<cfset setParent(arguments.parentLoggerManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the loggers (or ones passed in).">
		<cfargument name="loggers" type="struct" required="false" default="#getLoggers()#"
			hint="A struct of loggers to configure or defaults to all loggers registered in the manager." />
		
		<cfset var logFactory = getLogFactory() />
		<cfset var thisLogger = "" />
		<cfset var key = "" />
		
		<cfloop collection="#loggers#" item="key">
			<cfset thisLogger = arguments.loggers[key] />
			
			<cfset thisLogger.configure() />
			<cfset logFactory.addLogAdapter(thisLogger.getLogAdapter()) />
		</cfloop>
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures all the loggers (or ones passed in).">
		<cfargument name="loggers" type="struct" required="false" default="#getLoggers()#"
			hint="A struct of loggers to deconfigure or defaults to all loggers registered in the manager."/>
		
		<cfset var logFactory = getLogFactory() />
		<cfset var thisLogger = "" />
		<cfset var key = "" />

		<!---
		We need to remove the LogAdapter from the LogFactory before deconfiguring it
		as the process needs to be in reverse over of the configure() process
		--->		
		<cfloop collection="#arguments.loggers#" item="key">
			<cfset thisLogger = arguments.loggers[key] />
			
			<cfset logFactory.removeLogAdapter(thisLogger.getLogAdapter()) />
			<cfset thisLogger.deconfigure() />
			
			<!--- Once we've deconfigued a logger, we need to remove it from the LoggerManager --->
			<cfset removeLoggerByName(key) />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getLoggerByName" access="public" returntype="MachII.logging.loggers.AbstractLogger" output="false"
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
			<cfset variables.loggers[arguments.LoggerName] = arguments.logger />
		</cfif>
	</cffunction>

	<cffunction name="removeLoggerByName" access="public" returntype="void" output="false"
		hint="Removes a logger with the specified name. Does NOT remove from parent.">
		<cfargument name="loggerName" type="string" required="true" />
		
		<cftry>
			<cfset StructDelete(variables.loggers, arguments.loggerName, true) />
			<cfcatch type="any">
				<cfthrow type="MachII.logging.LoggerNotRemove"
					message="A logger with name '#arguments.loggerName#' cannot be found and therefore it was not removed." /> 
			</cfcatch>
		</cftry>
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
		
		<!--- Resolve if a shortcut --->
		<cfset arguments.loggerType = resolveLoggerTypeShortcut(arguments.loggerType) />
		<!--- Ensure type is correct in parameters (where it is duplicated) --->
		<cfset arguments.loggerParameters.type = arguments.loggerType />
		
		<!--- Create the logger --->
		<cftry>
			<cfset logger = CreateObject("component", arguments.LoggerType).init(arguments.loggerId, arguments.LoggerParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ arguments.LoggerType>
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

	<cffunction name="resolveLoggerTypeShortcut" access="public" returntype="string" output="false"
		hint="Resolves a logger type shorcut and returns the passed value if no match is found.">
		<cfargument name="loggerType" type="string" required="true"
			hint="Dot path to the logger strategy." />
		
		<cfif StructKeyExists(variables.LOGGER_SHORTCUTS, arguments.loggerType)>
			<cfreturn variables.LOGGER_SHORTCUTS[arguments.loggerType] />
		<cfelse>
			<cfreturn arguments.loggerType />
		</cfif>
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