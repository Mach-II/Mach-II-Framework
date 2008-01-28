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
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
<property name="logging" type="MachII.properties.LoggingProperty">
	<parameters>
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.loggers.EmailLog.Logger" />
				<!-- Optional and defaults to true -->
				<key name="loggingEnabled" value="true|false" />
				<!-- Optional and defaults to 'fatal' -->
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional and defaults to the default display template if not defined -->
				<key name="emailTemplateFile" value="/path/to/customEmailTemplate.cfm" />
				<!-- Optional and defaults to 'Email Log' -->
				<key name="emailSubject" value="Custom Email Subject" />
				<!-- Required -->
				<key name="emailTo" value="list,of,email,addresses" />
				- OR -
				<key name="emailTo">
					<array>
						<element value="array" />
						<element value="of" />
						<element value="email" />
						<element value="addresses" />
					</array>
				</key>
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
	displayname="EmailLog.Logger"
	extends="MachII.logging.loggers.AbstractLogger"
	output="false"
	hint="A logger for sending emails of logs.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.loggerType = "Email Logger" />
	<cfset variables.displayOutputAvailable = true />
	<cfset variables.emailTemplateFile = "/MachII/logging/loggers/EmailLog/defaultEmailTemplate.cfm" />
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
		<cfif isParameterDefined("emailTemplateFile")>
			<cfset setEmailTemplateFile(getParamter("emailTemplateFile")) />
		</cfif>
		
		<cfset setLoggingScope(adapter.getLoggingScope()) />
		<cfset setLoggingPath(adapter.getLoggingPath()) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="displayOutput" access="public" returntype="void" output="false"
		hint="Sends an email for this logger.">
		
		<!--- Note that leaving off the 'output' attribute requires all output to be
			surrounded by cfoutput tags --->
		
		<cfset var body = "" />
		<cfset var data = ArrayNew(1) />
		<cfset var scope = StructGet(getLoggingScope()) />
		
		<!--- Only display output if logging is enabled --->
		<cfif getLogAdapter().getLoggingEnabled()>
			<cfset data = scope[getLoggingPath()] />
			
			<cfsavecontent variable="body">
				<cfinclude template="#getEmailTemplateFile()#" />
			</cfsavecontent>
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setEmailTemplateFile" access="private" returntype="void" output="false"
		hint="Sets the email template location.">
		<cfargument name="emailTemplateFile" type="string" required="true" />
		<cfset variables.emailTemplateFile = arguments.emailTemplateFile />
	</cffunction>
	<cffunction name="getEmailTemplateFile" access="public" returntype="string" output="false"
		hint="Gets the email template location.">
		<cfreturn variables.emailTemplateFile />
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