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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="AbstractLogAdapter"
	output="false"
	hint="A logging adapter. This is abstract and must be extend by a concrete adapter implementation.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />
	<cfset variables.instance.loggingEnabled = true />
	
	<cfset variables.filter = "" />
	<cfset variables.parameters = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractLogAdapter" output="false"
		hint="Initializes the logging adapter. Do not override.">
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset setParameters(arguments.parameters) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the adapter. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="debug" access="public" returntype="void" output="false"
		hint="Logs a message with debug log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="error" access="public" returntype="void" output="false"
		hint="Logs a message with error log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="fatal" access="public" returntype="void" output="false"
		hint="Logs a message with fatal log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false"
		hint="Logs a message with info log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<cffunction name="trace" access="public" returntype="void" output="false"
		hint="Logs a message with trace log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="warn" access="public" returntype="void" output="false"
		hint="Logs a message with warn log level.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="additionalInformation" type="any" required="false" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isDebugEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if debug level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isErrorEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if error level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isFatalEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if fatal level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isInfoEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if info level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isTraceEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if trace level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="isWarnEnabled" access="public" returntype="boolean" output="false"
		hint="Checks if warn level logging is enabled.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets the configuration data for this logging adapter.">
		<!--- TODO: Consider pulling in filter configuration data --->		
		<cfreturn variables.instance />
	</cffunction>
	
	<cffunction name="isFilterDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a filter has been defined for this adapter.">
		<cfreturn IsObject(variables.filter) />
	</cffunction>

	<cffunction name="translateLevelToName" access="public" returntype="string" output="false"
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
		<cfelse>
			<cfthrow message="The argument named 'level' accepts a number in the range of 1 through 7."
				detail="Passed value: '#arguments.level#'" />
		</cfif>
		
		<cfreturn loggingLevelName />
	</cffunction>
	
	<cffunction name="translateNameToLevel" access="public" returntype="string" output="false"
		hint="Translate a human readable string to a numerical logging level.">
		<cfargument name="name" type="string" required="true"
			hint="The leave" />
		
		<cfset var level = "" />
		
		<cfif arguments.name EQ "trace">
			<cfset level = 1 />
		<cfelseif  arguments.name EQ "debug">
			<cfset level = 2 />
		<cfelseif  arguments.name EQ "info">
			<cfset level = 3 />
		<cfelseif  arguments.name EQ "warn">
			<cfset level = 4 />
		<cfelseif  arguments.name EQ "error">
			<cfset level = 5 />
		<cfelseif  arguments.name EQ "fatal">
			<cfset level = 6 />
		<cfelseif  arguments.name EQ "all">
			<cfset level = 0 />
		<cfelseif  arguments.name EQ "off">
			<cfset level = 7 />
		<cfelse>
			<cfthrow message="The argument named 'name' accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'."
				detail="Passed value: '#arguments.name#'" />
		</cfif>

		<cfreturn level />
	</cffunction>
	
	<cffunction name="setParameter" access="public" returntype="void" output="false"
		hint="Sets a configuration parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" type="any" required="true"
			hint="The parameter value." />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" output="false"
		hint="Gets a configuration parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to return if the parameter is not defined. Defaults to a blank string." />
		<cfif isParameterDefined(arguments.name)>
			<cfreturn variables.parameters[arguments.name] />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>
	<cffunction name="isParameterDefined" access="public" returntype="boolean" output="false"
		hint="Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingLevel" access="public" returntype="string" output="false"
		hint="Returns the logging level by name. Required for Dashboard integration.">
		<cfargument name="loggingLevelName" type="string" required="true"
			hint="Accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'." />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	<cffunction name="getLoggingLevel" access="public" returntype="string" output="false"
		hint="Returns the logging level by name. Required for Dashboard integration.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="setLoggingEnabled" access="public" returntype="void" output="false"
		hint="Sets the logging enabled.">
		<cfargument name="loggingEnabled" type="boolean" required="true" />
		<cfset variables.instance.loggingEnabled = arguments.loggingEnabled />
	</cffunction>
	<cffunction name="getLoggingEnabled" access="public" returntype="boolean" output="false"
		hint="Gets the logging enabled.">
		<cfreturn variables.instance.loggingEnabled />
	</cffunction>
	
	<cffunction name="setFilter" access="public" returntype="void" output="false"
		hint="Sets the filter.">
		<cfargument name="filter" type="MachII.logging.filters.AbstractFilter" required="true" />
		<cfset variables.filter = arguments.filter />
	</cffunction>
	<cffunction name="getFilter" access="public" returntype="MachII.logging.filters.AbstractFilter" output="false"
		hint="Gets the filter.">
		<cfreturn variables.filter />
	</cffunction>
	
	<cffunction name="setParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of configuration parameters for the component.">
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset var key = "" />
		
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, arguments.parameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of configuration parameters for the component.">
		<cfreturn variables.parameters />
	</cffunction>
	
</cfcomponent>