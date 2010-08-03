<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="FrameworkListener"
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for base framework structures.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getLoggers" access="public" returntype="struct" output="false"
		hint="Gets the data for all the modules.">
		
		<cfset var modules = getAppManager().getModuleManager().getModules() />
		<cfset var data = StructNew() />
		<cfset var loggingProperty = "" />
		<cfset var key = "" />

		<cfset loggingProperty = getProperty("udfs").findPropertyByType("MachII.logging.LoggingProperty", getAppManager().getParent().getPropertyManager()) />
		
		<cfif IsObject(loggingProperty) AND StructCount(loggingProperty.getLoggerManager().getLoggers())>
			<cfset data['base'] = loggingProperty.getLoggerManager().getLoggers() />
		</cfif>
		
		<cfloop collection="#modules#" item="key">
			<cfset loggingProperty = getProperty("udfs").findPropertyByType("MachII.logging.LoggingProperty", modules[key].getModuleAppManager().getPropertyManager()) />
			<cfif IsObject(loggingProperty) AND StructCount(loggingProperty.getLoggerManager().getLoggers())>
				<cfset data[modules[key].getModuleName()] = loggingProperty.getLoggerManager().getLoggers() />
			</cfif>
		</cfloop>
		
		<cfreturn data />
	</cffunction>
	
	<cffunction name="enableDisableAll" access="public" returntype="void" output="false"
		hint="Enables or disabales all logging.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
		
		<cfif arguments.event.getArg("mode") EQ "enable">
			<cfset getAppManager().getLogFactory().enableLogging() />
			<cfset message.setMessage("Enabled all loggers.") />
		<cfelse>
			<cfset getAppManager().getLogFactory().disableLogging() />
			<cfset message.setMessage("Disabled all loggers.") />
		</cfif>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>
	
	<cffunction name="enableDisableLogger" access="public" returntype="void" output="false"
		hint="Enables/disables a logger.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var loggerName = arguments.event.getArg("loggerName") />
		<cfset var logger = getLoggerByModuleAndLoggerName(arguments.event.getArg("moduleName"), loggerName) />
		<cfset var mode = arguments.event.getArg("mode") />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />		
		
		<cfif mode EQ "enable">
			<cfset logger.setLoggingEnabled(true) />
			<cfset message.setMessage("Enabled '#loggerName#'.") />
		<cfelse>
			<cfset logger.setLoggingEnabled(false) />
			<cfset message.setMessage("Disabled '#loggerName#'.") />
		</cfif>
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>
	
	<cffunction name="changeLoggingLevel" access="public" returntype="void" output="false"
		hint="Changes logging level.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var loggerName = arguments.event.getArg("loggerName") />
		<cfset var logger = getLoggerByModuleAndLoggerName(arguments.event.getArg("moduleName"), loggerName) />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Changed level in '#loggerName#' to '#arguments.event.getArg('level')#'.") />
		
		<cfset logger.setLoggingLevel(arguments.event.getArg("level")) />
		
		<cfset arguments.event.setArg("message", message) />
		<cfset getLog().info(message.getMessage()) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getLoggerByModuleAndLoggerName" access="private" returntype="any" output="false"
		hint="Gets a logger by module and logger name.">
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="strategyName" type="string" required="true" />
		
		<cfset var loggers = getLoggers() />
		
		<cfreturn loggers[arguments.moduleName][arguments.strategyName] />
	</cffunction>

</cfcomponent>