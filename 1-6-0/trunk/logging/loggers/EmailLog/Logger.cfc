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
<property name="Logging" type="MachII.logging.LoggingProperty">
	<parameters>
		<parameter name="EmailLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.EmailLog.Logger" />
				<!-- Optional and defaults to true -->
				<key name="loggingEnabled" value="true|false" />
				<!-- Optional and defaults to 'fatal' -->
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional and defaults to the default display template if not defined -->
				<key name="emailTemplateFile" value="/path/to/customEmailTemplate.cfm" />
				<!-- Required - list of email addresses to send the log report to -->
				<key name="to" value="list,of,email,addresses" />
				<!-- Required - email address to send the log report from -->
				<key name="from" value="logreports@example.com" />
				<!-- Optional - the name of the subject of the log report email
					defaults to 'Application Log' -->
				<key name="subject" value="Application Log" />
				<!-- Optional - list of mail server names or IPs
					defaults to mail server specified in the coldfusion admin -->
				<key name="servers" value="mail.example.com" />
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
	<cfset variables.onRequestEndAvailable = true />
	<cfset variables.prePostRedirectAvailable = true />
	<cfset variables.emailTemplateFile = "defaultEmailTemplate.cfm" />
	<cfset variables.loggingScope = "" />
	<cfset variables.loggingPath = "" />
	<cfset variables.to = "" />
	<cfset variables.from = "" />
	<cfset variables.subject = "" />
	<cfset variables.servers = "" />
	
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
		
		<!--- Apply configuration from adapter that is needed by the logger --->
		<cfset setLoggingScope(adapter.getLoggingScope()) />
		<cfset setLoggingPath(adapter.getLoggingPath()) />
		
		<!--- Add the adapter to the log factory --->
		<cfset getLogFactory().addLogAdapter(adapter) />
		
		<!--- Configure the remaining parameters --->
		<cfif isParameterDefined("emailTemplateFile")>
			<cfset setEmailTemplateFile(getParameter("emailTemplateFile")) />
		</cfif>
		
		<cfif isParameterDefined("to")>
			<cfset setTo(getParameter("to")) />
		<cfelse>
			<cfthrow type="MachII.logging.loggers.EmailLog.Logger"
				message="A parameter named 'to' is required. A list of email address(es) to send a log report to.">
		</cfif>
		
		<cfif isParameterDefined("from")>
			<cfset setFrom(getParameter("from")) />
		<cfelse>
			<cfthrow type="MachII.logging.loggers.EmailLog.Logger"
				message="A parameter named 'from' is required. This indicates the email address to send a log report from.">
		</cfif>
		
		<cfset setSubject(getParameter("subject", "Application Log")) />
		<cfset setServers(getParameter("servers", "")) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void" output="false"
		hint="Sends an email for this logger.">
		
		<cfset var body = "" />
		<cfset var scope = StructGet(getLoggingScope()) />
		<cfset var data = ArrayNew(1) />
		<cfset var local = StructNew() />
		
		<!--- Only display output if logging is enabled --->
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			
			<cfset data = scope[getLoggingPath()].data />
			
			<cfif ArrayLen(data)>
				<!--- Save the body of the email --->
				<cfsavecontent variable="body">
					<cfinclude template="#getEmailTemplateFile()#" />
				</cfsavecontent>
				
				<!--- Send the email --->
				<cfif NOT Len(getServers())>
					<cfmail from="#getFrom()#" to="#getTo()#" subject="#getSubject()#"><cfoutput>#body#</cfoutput></cfmail>
				<cfelse>
					<cfmail from="#getFrom()#" to="#getTo()#" subject="#getSubject()#" server="#getServers()#"><cfoutput>#body#</cfoutput></cfmail>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="preRedirect" access="public" returntype="void" output="false"
		hint="Pre-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />

		<cfset var scope = StructGet(getLoggingScope()) />
		
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			<cfset arguments.data[getLoggerId()] = scope[getLoggingPath()] />
		</cfif>
	</cffunction>

	<cffunction name="postRedirect" access="public" returntype="void" output="false"
		hint="Post-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />

		<cfset var scope = StructGet(getLoggingScope()) />
		
		<cfif getLogAdapter().getLoggingEnabled() AND StructKeyExists(scope, getLoggingPath())>
			<cftry>
				<cfset scope[getLoggingPath()].data = arrayConcat(arguments.data[getLoggerId()].data, scope[getLoggingPath()].data) />
				<cfcatch type="any">
					<!--- Do nothing as the configuration may have changed between start of
					the redirect and now --->
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
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
	
	<cffunction name="setTo" access="private" returntype="void" output="false">
		<cfargument name="to" type="string" required="true" />
		<cfset variables.to = arguments.to />
	</cffunction>
	<cffunction name="getTo" access="public" returntype="string" output="false">
		<cfreturn variables.to />
	</cffunction>

	<cffunction name="setFrom" access="private" returntype="void" output="false">
		<cfargument name="from" type="string" required="true" />
		<cfset variables.from = arguments.from />
	</cffunction>
	<cffunction name="getFrom" access="public" returntype="string" output="false">
		<cfreturn variables.from />
	</cffunction>

	<cffunction name="setSubject" access="private" returntype="void" output="false">
		<cfargument name="subject" type="string" required="true" />
		<cfset variables.subject = arguments.subject />
	</cffunction>
	<cffunction name="getSubject" access="public" returntype="string" output="false">
		<cfreturn variables.subject />
	</cffunction>

	<cffunction name="setServers" access="private" returntype="void" output="false">
		<cfargument name="servers" type="string" required="true" />
		<cfset variables.servers = arguments.servers />
	</cffunction>
	<cffunction name="getServers" access="public" returntype="string" output="false">
		<cfreturn variables.servers />
	</cffunction>
	
</cfcomponent>