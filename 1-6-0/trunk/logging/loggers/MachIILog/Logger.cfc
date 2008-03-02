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
<property name="logging" type="MachII.properties.LoggingProperty">
	<parameters>
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.loggers.MachIILog.Logger" />
				<!-- Optional and defaults to true -->
				<key name="loggingEnabled" value="true|false" />
				<!-- Optional and defaults to 'fatal' -->
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional and defaults to the default display template if not defined -->
				<key name="displayOutputTemplateFile" value="/path/to/customOutputTemplate.cfm" />
				<!-- Optional -->
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

Uses the generic channel filter (MachII.logging.filters.GenericChannelFilter)for filtering.
See that file header for configuration of filter criteria.
--->
<cfcomponent
	displayname="MachIILog.Logger"
	extends="MachII.logging.loggers.AbstractLogger"
	output="false"
	hint="A logger for Mach-II.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.loggerType = "Mach-II Log" />
	<cfset variables.onRequestEndAvailable = true />
	<cfset variables.prePostRedirectAvailable = true />
	<cfset variables.displayOutputTemplateFile = "/MachII/logging/loggers/MachIILog/defaultOutputTemplate.cfm" />
	<cfset variables.loggingScope = "" />
	<cfset variables.loggingPath = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the logger.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init(getParameter("filter", "")) />
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.ScopeAdapter").init(getParameters()) />
		
		<!--- Set the filter to the adapter --->
		<cfset adapter.setFilter(filter) />
		
		<!--- Configure and set the adapter --->
		<cfset adapter.configure()>
		<cfset setLogAdapter(adapter) />
		
		<!--- Add the adapter to the log factory --->
		<cfset getLogFactory().addLogAdapter(adapter) />
		
		<!--- Configure the remaining parameters --->
		<cfif isParameterDefined("displayOutputTemplateFile")>
			<cfset setDisplayOutputTemplateFile(getParamter("displayOutputTemplateFile")) />
		</cfif>
		
		<cfset setLoggingScope(adapter.getLoggingScope()) />
		<cfset setLoggingPath(adapter.getLoggingPath()) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void"
		hint="Displays output for this logger.">
		
		<!--- Note that leaving off the 'output' attribute requires all output to be
			surrounded by cfoutput tags --->
		
		<cfset var data = ArrayNew(1) />
		<cfset var scope = StructGet(getLoggingScope()) />
		
		<!--- Only display output if logging is enabled --->
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			<cfset data = scope[getLoggingPath()].data />
			
			<cfinclude template="#getDisplayOutputTemplateFile()#" />
		</cfif>
	</cffunction>
	
	<cffunction name="preRedirect" access="public" returntype="void" output="false"
		hint="Pre-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />

		<cfset var scope = StructGet(getLoggingScope()) />
		
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			<cfset data["machiilogger"] = scope[getLoggingPath()] />
		</cfif>
	</cffunction>

	<cffunction name="postRedirect" access="public" returntype="void" output="false"
		hint="Post-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />

		<cfset var scope = StructGet(getLoggingScope()) />
		
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			<cfset scope[getLoggingPath()].data = arrayConcat(data["machiilogger"].data, scope[getLoggingPath()].data) />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getMachIIVersion" access="private" returntype="string" output="false"
		hint="Gets a nice version number istead of just numbers.">
		<cfargument name="version" type="string" required="true" />

		<cfset var release = "" />
		
		<cfswitch expression="#ListLast(arguments.version, ".")#">
			<cfcase value="0">
				<cfset release = "Bleeding Edge Release - Unknown build" />
			</cfcase>
			<cfcase value="1">
				<cfset release = "Alpha" />
			</cfcase>
			<cfcase value="2">
				<cfset release = "Beta" />
			</cfcase>
			<cfcase value="3">
				<cfset release = "RC1" />
			</cfcase>
			<cfcase value="4">
				<cfset release = "RC2" />
			</cfcase>
			<cfcase value="5">
				<cfset release = "RC3" />
			</cfcase>
			<cfcase value="6">
				<cfset release = "RC4" />
			</cfcase>
			<cfcase value="7">
				<cfset release = "RC5" />
			</cfcase>
			<cfcase value="8">
				<cfset release = "Development and Production Stable (non-duck typed core)" />
			</cfcase>
			<cfcase value="9">
				<cfset release = "Production-Only Stable (duck-typed core for performance)" />
			</cfcase>
			<cfdefaultcase>
				<cfset release = "Bleeding Edge Release - Build " & ListLast(arguments.version, ".") />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn Left(arguments.version, Len(arguments.version) - Len(ListLast(arguments.version, ".")) - 1) & " " & release />
	</cffunction>
	
	<cffunction name="arrayConcat" access="private" returntype="array" output="false"
		hint="Concats two arrays together.">
		<cfargument name="array1" type="array" required="true" />
		<cfargument name="array2" type="array" required="true" />
		
		<cfset var result = arguments.array1 />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.array2)#" index="i">
			<cfset ArrayAppend(result, arguments.array2[i]) />
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setDisplayOutputTemplateFile" access="private" returntype="void" output="false"
		hint="Sets the output template location which is used for display output.">
		<cfargument name="displayOutputTemplateFile" type="string" required="true" />
		<cfset variables.displayOutputTemplateFile = arguments.displayOutputTemplateFile />
	</cffunction>
	<cffunction name="getDisplayOutputTemplateFile" access="public" returntype="string" output="false"
		hint="Gets the output template location which is used for display output.">
		<cfreturn variables.displayOutputTemplateFile />
	</cffunction>
	
	<cffunction name="setLoggingScope" access="private" returntype="void" output="false"
		hint="Sets the logging scope.">
		<cfargument name="loggingScope" type="string" required="true" />
		<cfset variables.loggingScope = arguments.loggingScope />
	</cffunction>
	<cffunction name="getLoggingScope" access="public" returntype="string" output="false"
		hint="Gets the logging scope.">
		<cfreturn variables.loggingScope />
	</cffunction>

	<cffunction name="setLoggingPath" access="private" returntype="void" output="false"
		hint="Sets the logging path.">
		<cfargument name="loggingPath" type="string" required="true" />
		<cfset variables.loggingPath = arguments.loggingPath />
	</cffunction>
	<cffunction name="getLoggingPath" access="public" returntype="string" output="false"
		hint="Gets the logging path.">
		<cfreturn variables.loggingPath />
	</cffunction>
	
</cfcomponent>