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
$Id: Log.cfc 584 2007-12-15 08:44:43Z peterfarrell $

Created version: 1.6.0
Updated version: 1.8.0

Notes:

Configuring for Mach-II logger only:
<property name="Logging" type="MachII.logging.LoggingProperty" />

This will turn on the MachIILog logger and display the log message 
in the request output.

Configuring multiple logging adapters:
<property name="Logging" type="MachII.logging.LoggingProperty">
	<parameters>
		<!-- Optionally turns logging on/off (loggingEnabled values in the adapters are still adhered to)-->
		<parameter name="loggingEnabled" value="false"/>
		<parameter name="CFLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.CFLog.Logger" />
				<key name="loggingEnabled" value="true|false" />
				- OR - 
	            <key name="loggingEnabled">
	            	<struct>
	            		<key name="development" value="false"/>
	            		<key name="production" value="true"/>
	            	</struct>
	            </key>
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional -->
				<key name="logFile" value="nameOfCFLogFile" />
				<key name="debugModeOnly" value="false" />
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
		<parameter name="EmailLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.EmailLog.Logger" />
				<key name="loggingEnabled" value="true|false" />
				- OR - 
	            <key name="loggingEnabled">
	            	<struct>
	            		<key name="development" value="false"/>
	            		<key name="production" value="true"/>
	            	</struct>
	            </key>
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<key name="emailTemplateFile" value="/path/to/customEmailTemplate.cfm" />
				<key name="to" value="list,of,email,addresses" />
				<key name="from" value="logs@example.com" />
				<!-- Optional -->
				<key name="subject" value="Application Log" />
				<key name="servers" value="mail.example.com" />
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
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.loggers.MachIILog.Logger" />
				<key name="loggingEnabled" value="true|false" />
				- OR - 
	            <key name="loggingEnabled">
	            	<struct>
	            		<key name="development" value="false"/>
	            		<key name="production" value="true"/>
	            	</struct>
	            </key>
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional -->
				<key name="displayOutputTemplateFile" value="/path/to/customOutputTemplate.cfm" />
				<key name="debugModeOnly" value="true|false" />
				<key name="suppressDebugArg" value="suppressDebug" />
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

See individual loggers for more information on configuration.

The LoggingProperty also will bind nested parameter values using ${} syntax. Mach-II only
will bind to root parameter values.
--->
<cfcomponent
	displayname="LoggingProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Allows you to configure the Mach-II logging features.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.defaultLoggerName = "MachII" />
	<cfset variables.defaultLoggerType = "MachII.logging.loggers.MachIILog.Logger" />
	<cfset variables.loggerManager = "" />
	<cfset variables.loggingEnabled = true />
	
	<cfset variables.LOGGER_MANAGER_PROPERTY_NAME = "_LoggingProperty.loggerManager" />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var parentLoggerManager = "" />
		<cfset var params = getParameters() />
		<cfset var defaultLoggerParameters = StructNew() />
		<cfset var loggers = StructNew() />
		<cfset var moduleName = getAppManager().getModuleName() />
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var key = "" />
		
		<!--- Setup a manager for all of the loggers --->
		<cfif getAppManager().inModule()>
			<cfset parentLoggerManager = getPropertyManager().getParent().getProperty(variables.LOGGER_MANAGER_PROPERTY_NAME, "") />
		</cfif>
		
		<cfif IsObject(parentLoggerManager)>
			<cfset variables.loggerManager = CreateObject("component", "MachII.logging.LoggerManager").init(getAppManager().getLogFactory(), parentLoggerManager) />
		<cfelse>
			<cfset variables.loggerManager = CreateObject("component", "MachII.logging.LoggerManager").init(getAppManager().getLogFactory()) />
		</cfif>
		
		<!--- Get basic parameters --->
		<cfset setLoggingEnabled(getParameter("loggingEnabled", true)) />
		
		<!--- Load loggers --->
		<cfloop collection="#params#" item="key">
			<cfif key NEQ "loggingEnabled" AND IsStruct(params[key])>
				<cfset configureLogger(key, getParameter(key)) />
			</cfif>
		</cfloop>
		
		<!--- Configure the default logger since no loggers are registered --->
		<cfif NOT StructCount(getLoggerManager().getLoggers())>
			<cfset defaultLoggerParameters.type = variables.defaultLoggerType />
			<cfset defaultLoggerParameters.loggingLevel = "trace" />
			<cfset configureLogger(variables.defaultLoggerName, defaultLoggerParameters) />
		</cfif>	
		
		<!--- Configure the loggers --->
		<cfset getLoggerManager().configure() />
		<cfset loggers = getLoggerManager().getLoggers() />
		
		<cfloop collection="#loggers#" item="key">
			<!--- Add a callback to the RequestManager if there is onRequestEnd method --->
			<cfif loggers[key].isOnRequestEndAvailable()>
				<cfset requestManager.addOnRequestEndCallback(loggers[key], "onRequestEnd") />
			</cfif>
			
			<!--- Add a callbacks to the RequestManager if there is pre/postRedirect methods --->
			<cfif loggers[key].isPrePostRedirectAvailable()>
				<cfset requestManager.addPreRedirectCallback(loggers[key], "preRedirect") />
				<cfset requestManager.addPostRedirectCallback(loggers[key], "postRedirect") />
			</cfif>
		</cfloop>
				
		<!--- Set logging enabled/disabled --->
		<cfif NOT isLoggingEnabled()>
			<cfset getLoggerManager().getLogFactory().disableLogging() />
		</cfif>
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Unregisters some log adapters and callbacks.">
		
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var logFactory = getLoggerManager().getLogFactory() />
		<cfset var thisInstanceLoggers = getLoggers() />
		<cfset var key = "" />
		<cfset var currentLogger = "" />
		
		<!--- Cleanup this property's' loggers --->
		<cfloop collection="#thisInstanceLoggers#" item="key">
			<cfset currentLogger = thisInstanceLoggers[key] />

			<!--- Remove preRedirect, postRedirect and onRequestEnd callbacks --->
			<cfset requestManager.removeOnRequestEndCallback(currentLogger) />
			<cfset requestManager.removePreRedirectCallback(currentLogger) />
			<cfset requestManager.removePostRedirectCallback(currentLogger) />
			
			<!--- Remove log adapter from log factory --->
			<cfset logFactory.removeLogAdapter(currentLogger.getLogAdapter()) />
		</cfloop>
		
		<!--- Deconfigure all the loggers --->
		<cfset getLoggerManager().deconfigure()>
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
	
	<cffunction name="getLoggerByName" access="public" returntype="MachII.logging.loggers.AbstractLogger" output="false"
		hint="Helper method to get a logger by name from the logger manager.">
		<cfargument name="loggerName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent logger manager." />
		<cfreturn getLoggerManager().getLoggerByName(arguments.loggerName, arguments.checkParent) />
	</cffunction>
	<cffunction name="isLoggerDefined" access="public" returntype="boolean" output="false"
		hint="Helper method that checks if a logger is defined by name in the logger manager.">
		<cfargument name="loggerName" type="string" required="true" />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent logger manager." />
		<cfreturn getLoggerManager().isLoggerDefined(arguments.loggerName, arguments.checkParent) />
	</cffunction>
	<cffunction name="getLoggers" access="public" returntype="struct" output="false"
		hint="Gets all the registered loggers from the logger manager.">
		<cfreturn getLoggerManager().getLoggers() />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="configureLogger" access="private" returntype="void" output="false"
		hint="Configures an logger.">
		<cfargument name="loggerName" type="string" required="true"
			hint="Name of the logger." />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this logger.">
		
		<cfset var type = "" />
		<cfset var logger = "" />
		<cfset var loggerId = createLoggerId(arguments.loggerName) />
		<cfset var moduleName = getModuleName() />
		<cfset var key = "" />		
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.properties.LoggingProperty"
				message="You must specify a 'type' for log adapter named '#arguments.loggerName#'." />
		</cfif>
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset arguments.parameters[key] = bindValue(key, arguments.parameters[key]) />
		</cfloop>
		
		<!--- Decide the logging enabled mode --->
		<cfif StructKeyExists(arguments.parameters, "loggingEnabled")>
			<cftry>
				<cfset arguments.parameters["loggingEnabled"] = decidedLoggingEnabled(arguments.parameters["loggingEnabled"]) />
				<cfcatch type="MachII.util.IllegalArgument">
					<cfthrow type="MachII.logging.InvalidEnvironmentConfiguration"
						message="This misconfiguration error occurred in logger named '#arguments.loggerName#' in module named '#moduleName#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
				<cfcatch type="any">
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- Load the logger  --->
		<cfset getLoggerManager().loadLogger(arguments.loggerName, loggerId, arguments.parameters.type, arguments.parameters) />
	</cffunction>
	
	<cffunction name="createLoggerId" access="private" returntype="string" output="false"
		hint="Creates a logger id.">
		<cfargument name="loggerName" type="string" required="true" />
		<!--- Some CFML engines don't like logger ids that start with a number --->
		<cfreturn "_" & Hash(arguments.loggerName & getModuleName() & GetTickCount() & RandRange(0, 10000) & RandRange(0, 10000)) />
	</cffunction>
	
	<cffunction name="getModuleName" access="private" returntype="string" output="false"
		hint="Gets the module name.">

		<cfset var moduleName = getAppManager().getModuleName() />
		
		<cfif NOT Len(moduleName)>
			<cfset moduleName = "_base_" />
		</cfif>

		<cfreturn moduleName />
	</cffunction>
	
	<cffunction name="decidedLoggingEnabled" access="private" returntype="boolean" output="false"
		hint="Decides if the logging is enabled.">
		<cfargument name="loggingEnabled" type="any" required="true" />
		
		<cfset var result = true />
		
		<cfset getAssert().isTrue(IsBoolean(arguments.loggingEnabled) OR IsStruct(arguments.loggingEnabled)
				, "The 'loggingEnabled' parameter in 'LoggingProperty' in module '#getAppManager().getModuleName()#' must be boolean or a struct of environment names / groups.") />
		
		<!--- Load logging enabled by simple value (no environment names / group) --->
		<cfif IsBoolean(arguments.loggingEnabled)>
			<cfset result = arguments.loggingEnabled />
		<!--- Load logging enabled by environment name / group --->
		<cfelse>
			<cfset result = resolveValueByEnvironment(arguments.loggingEnabled, true) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingEnabled" access="private" returntype="void" output="false"
		hint="Sets the logging enabled status and decides by environment if struct.">
		<cfargument name="loggingEnabled" type="any" required="true" />
		
		<cftry>
			<cfset variables.loggingEnabled = decidedLoggingEnabled(arguments.loggingEnabled) />
			<cfcatch type="MachII.util.IllegalArgument">
				<cfthrow type="MachII.logging.InvalidEnvironmentConfiguration"
					message="This misconfiguration error is defined in the property-wide 'loggingEnabled' parameter in the logging property in module named '#getModuleName()#'."
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>			
		</cftry>
	</cffunction>
	<cffunction name="isLoggingEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if logging is enabled.">
		<cfreturn variables.loggingEnabled />
	</cffunction>
	
	<cffunction name="setLoggerManager" access="private" returntype="void" output="false">
		<cfargument name="loggerManager" type="MachII.logging.LoggerManager" required="true" />
		<cfset variables.loggerManager =  arguments.loggerManager />
	</cffunction>
	<cffunction name="getLoggerManager" access="public" returntype="MachII.logging.LoggerManager" output="false">
		<cfreturn variables.loggerManager />
	</cffunction>

</cfcomponent>