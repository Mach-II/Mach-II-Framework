<!---
License:
Copyright 2009 GreatBizTools, LLC

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
Updated version: 1.8.0

Notes:
<property name="Logging" type="MachII.logging.LoggingProperty">
	<parameters>
		<parameter name="EmailLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.EmailLog.Logger" />
				<!-- Optional and defaults to true -->
				<key name="loggingEnabled" value="true|false" />
				- OR - 
	            <key name="loggingEnabled">
	            	<struct>
	            		<key name="development" value="false"/>
	            		<key name="production" value="true"/>
	            	</struct>
	            </key>
				<!-- Optional - defaults to 'debug' -->
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional - defaults to 'fatal' -->
				<key name="loggingLevelEmailTrigger" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional - defaults to the default display template if not defined -->
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
				<!-- Optional - mail type for the cfmail (default: text/html) -->
				<key name="mailType" value="text/html" />
				<!-- Optional - username to use for all servers -->
				<key name="username" value="" />
				<!-- Optional - password to use for all servers -->
				<key name="password" value="" />
				<!-- Optional - charset to use and defaults to 'utf-8' -->
				<key name="charset" value="utf-8" />
				<!-- Optional - enable/disable spool enable for mail and defaults to 'true' -->
				<key name="spoolenable" value="true" />
				<!-- Optional - value to wait for mail server and defaults to 60 -->
				<key name="timeout" value="60" />
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
	<!--- The variables.instance struct is created in the AbstractLogger do not initialize here --->
	<cfset variables.instance.loggerTypeName = "Email" />
	<cfset variables.instance.emailTemplateFile = "defaultEmailTemplate.cfm" />
	<cfset variables.instance.levelEmailTrigger = 6 />
	<cfset variables.instance.to = "" />
	<cfset variables.instance.from = "" />
	<cfset variables.instance.subject = "" />
	<cfset variables.instance.servers = "" />
	<cfset variables.instance.mailType = "text/html" />
	<cfset variables.instance.username = "" />
	<cfset variables.instance.password = "" />
	<cfset variables.instance.charset = "utf-8" />
	<cfset variables.instance.spoolEnable = true />
	<cfset variables.instance.timeout = 60 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the logger.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init(getParameter("filter", "")) />
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.ScopeAdapter").init(getParameters()) />
		
		<!---For better peformance, set the filter to the adapter only we have something to filter --->
		<cfif ArrayLen(filter.getFilterChannels())>
			<cfset adapter.setFilter(filter) />
		</cfif>
		
		<!--- Configure and set the adapter --->
		<cfset adapter.configure() />
		<cfset setLogAdapter(adapter) />
		
		<!--- Configure the remaining parameters --->
		<cfif isParameterDefined("emailTemplateFile")
			AND getAssert().hasText(getParameter("emailTemplateFile")
			, "A parameter named 'emailTemplateFile' is required."
			, "A path to the email template is required.")>
			<cfset setEmailTemplateFile(getParameter("emailTemplateFile")) />
		</cfif>

		<cfset setLoggingLevelEmailTrigger(getParameter("loggingLevelEmailTrigger", "fatal")) />
		
		<cfif getAssert().hasText(getParameter("to")
			, "A parameter named 'to' is required."
			, "A list of email address(es) to send a log report to.")>
			<cfset setTo(getParameter("to")) />
		</cfif>
		
		<cfif getAssert().hasText(getParameter("from")
			, "A parameter named 'from' is required."
			, "This indicates the email address to send a log report from.")>
			<cfset setFrom(getParameter("from")) />
		</cfif>
		
		<cfset setSubject(getParameter("subject", "Application Log")) />
		<cfset setServers(getParameter("servers", "")) />
		<cfset setMailType(getParameter("mailType", "text/html")) />
		<cfset setUsername(getParameter("username", "")) />
		<cfset setPassword(getParameter("password", "")) />
		
		<cfif isParameterDefined("charset")
			AND getAssert().hasLength(getParameter("charset")
				, "A parameter named 'charset' cannot be blank if defined."
				, "This indicates the charset to be used when sending mail.")>
			<cfset setCharset(getParameter("charset", "utf-8")) />
		</cfif>
		
		<cfif isParameterDefined("spoolEnabled")
			AND getAssert().isTrue(IsBoolean(getParameter("spoolenable"))
				, "A parameter named 'spoolEnabled' must be boolean if defined."
				, "This indicates if your CFML should spool mail for delivery.")>
			<cfset setSpoolEnable(getParameter("spoolenable")) />
		</cfif>
		
		<cfif isParameterDefined("timeout")
			AND getAssert().isNumber(getParameter("timeout")
				, "A parameter named 'timeout' must be numeric if defined."
				, "This indicates the amount of time to wait while trying to deliver mail.")>
			<cfset setTimeout(getParameter("timeout")) />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void" output="false"
		hint="Sends an email for this logger.">
		
		<cfset var body = "" />
		<cfset var data = ArrayNew(1) />
		<cfset var local = StructNew() />
		
		<!--- Only display output if logging is enabled --->
		<cfif getLogAdapter().getLoggingEnabled() 
			AND getLogAdapter().isLoggingDataDefined()
			AND hasReachedLoggingLevelEmailTrigger()>
			
			<!---
			This variable is used by the email template file which is included
			and therefore needs to remain as a var'ed local variable.
			--->
			<cfset data = getLogAdapter().getLoggingData().data />
			
			<!--- Save the body of the email --->
			<!--- Everything needs to be one line or any extra tab / space may be produced on certain CFML engines --->
			<cfsavecontent variable="body"><cfinclude template="#getEmailTemplateFile()#" /></cfsavecontent>

			<!--- Send the email --->
			<cfif Len(getServers())>
				
				<cfif hasSpecifiedAuthCredentials()>
					<cfmail from="#getFrom()#" 
						to="#getTo()#"
						subject="#getSubject()#"
						type="#getMailType()#" 
						server="#getServers()#"
						username="#getUsername()#"
						password="#getPassword()#"
						charset="#getCharset()#"
						spoolenable="#getSpoolEnable()#"
						timeout="#getTimeout()#"><cfoutput>#body#</cfoutput></cfmail>
				<cfelse>
					<cfmail from="#getFrom()#" 
						to="#getTo()#"
						subject="#getSubject()#"
						type="#getMailType()#" 
						server="#getServers()#"
						charset="#getCharset()#"
						spoolenable="#getSpoolEnable()#"
						timeout="#getTimeout()#"><cfoutput>#body#</cfoutput></cfmail>
				</cfif>

			<cfelse><!--- User has not defined custom servers in the xml config --->

				<cfif hasSpecifiedAuthCredentials()>
					<cfmail from="#getFrom()#" 
						to="#getTo()#"
						subject="#getSubject()#"
						type="#getMailType()#"
						username="#getUsername()#"
						password="#getPassword()#"
						charset="#getCharset()#"
						spoolenable="#getSpoolEnable()#"
						timeout="#getTimeout()#"><cfoutput>#body#</cfoutput></cfmail>
				<cfelse>
					<cfmail from="#getFrom()#" 
						to="#getTo()#"
						subject="#getSubject()#"
						type="#getMailType()#"
						charset="#getCharset()#"
						spoolenable="#getSpoolEnable()#"
						timeout="#getTimeout()#"><cfoutput>#body#</cfoutput></cfmail>
				</cfif>

			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="preRedirect" access="public" returntype="void" output="false"
		hint="Pre-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />
		
		<cfif getLogAdapter().getLoggingEnabled() AND getLogAdapter().isLoggingDataDefined()>
			<cfset arguments.data[getLoggerId()] = getLogAdapter().getLoggingData() />
		</cfif>
	</cffunction>

	<cffunction name="postRedirect" access="public" returntype="void" output="false"
		hint="Post-redirect logic for this logger.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />

		<cfset var loggingData = StructNew() />
		
		<cfif getLogAdapter().getLoggingEnabled() AND getLogAdapter().isLoggingDataDefined()>
			<cftry>
				<cfset loggingData = getLogAdapter().getLoggingData() />
				<cfset loggingData.data = arrayConcat(arguments.data[getLoggerId()].data, loggingData.data) />
				<cfcatch type="any">
					<!--- Do nothing as the configuration may have changed between start of
					the redirect and now --->
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets the configuration data for this logger including adapter and filter.">
		
		<cfset var data = StructNew() />
		
		<cfset data["To Email"] = getTo() />
		<cfset data["From Email"] = getFrom() />
		<cfset data["Subject"] = getSubject() />
		<cfset data["SMTP Servers"] = getServers() />
		<cfset data["Email Template"] = getEmailTemplateFile() />
		<cfset data["Username"] = getUsername() />
		<cfset data["Password"] = getPassword() />
		<cfset data["Charset"] = getCharset() />
		<cfset data["Spool Enable"] = getSpoolEnable() />
		<cfset data["Timeout"] = getTimeout() />
		<cfset data["Logging Enabled"] = YesNoFormat(isLoggingEnabled()) />
		<cfset data["Logging Level for Email Trigger"] = getLoggingLevelEmailTrigger() />
		
		<cfreturn data />
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

	<cffunction name="hasReachedLoggingLevelEmailTrigger" access="private" returntype="boolean" output="false"
		hint="Determines if the current logging data has reached the logging level defined to trigger an email.">
		
		<cfset var data = getLogAdapter().getLoggingData().data />
		<cfset var triggerLevel = getLevelEmailTrigger() />
		<cfset var i = 0 />
		<cfset var result = false />
		
		<cfloop from="1" to="#ArrayLen(data)#" index="i">
			<cfif data[i].logLevel GTE triggerLevel>
				<cfset result = true />
				<cfbreak />
			</cfif>
		</cfloop>
	
		<cfreturn result />	
	</cffunction>

	<cffunction name="hasSpecifiedAuthCredentials" access="private" returntype="boolean" output="false"
		hint="Determines if user correctly specified a username and password in the loggers xml configuration file">
		
		<cfset var result = false />

		<cfif Len(getUsername()) AND Len(getPassword())>
			<cfset result = true />
		<cfelseif len(getUsername()) and not len(getPassword()) or len(getPassword()) and not len(getUsername())>
			<cfthrow message="If you provide a value for the username or password parameter, you must specify both a username AND password"
				detail="The passed values are username: '#getUsername()#', password: '#getPassword()#'." />
		</cfif>

		<cfreturn result />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setEmailTemplateFile" access="private" returntype="void" output="false"
		hint="Sets the email template location.">
		<cfargument name="emailTemplateFile" type="string" required="true" />
		<cfset variables.instance.emailTemplateFile = arguments.emailTemplateFile />
	</cffunction>
	<cffunction name="getEmailTemplateFile" access="public" returntype="string" output="false"
		hint="Gets the email template location.">
		<cfreturn variables.instance.emailTemplateFile />
	</cffunction>
	
	<cffunction name="setTo" access="private" returntype="void" output="false">
		<cfargument name="to" type="string" required="true" />
		<cfset variables.instance.to = arguments.to />
	</cffunction>
	<cffunction name="getTo" access="public" returntype="string" output="false">
		<cfreturn variables.instance.to />
	</cffunction>

	<cffunction name="setFrom" access="private" returntype="void" output="false">
		<cfargument name="from" type="string" required="true" />
		<cfset variables.instance.from = arguments.from />
	</cffunction>
	<cffunction name="getFrom" access="public" returntype="string" output="false">
		<cfreturn variables.instance.from />
	</cffunction>
	
	<cffunction name="setLoggingLevelEmailTrigger" access="private" returntype="void" output="false"
		hint="Sets the human readable logging level name which is translated to ">
		<cfargument name="loggingLevelEmailTrigger" type="string" required="true" />
		<!--- Set the numerical representation of this logging level name --->
		<cfset setLevelEmailTrigger(getLogAdapter().translateNameToLevel(arguments.loggingLevelEmailTrigger)) />
	</cffunction>
	<cffunction name="getLoggingLevelEmailTrigger" access="public" returntype="string" output="false">
		<cfreturn getLogAdapter().translateLevelToName(getLevelEmailTrigger()) />
	</cffunction>
	
	<cffunction name="setLevelEmailTrigger" access="private" returntype="void" output="false">
		<cfargument name="levelEmailTrigger" type="numeric" required="true" />
		<cfset variables.instance.levelEmailTrigger = arguments.levelEmailTrigger />
	</cffunction>
	<cffunction name="getLevelEmailTrigger" access="public" returntype="numeric" output="false">
		<cfreturn variables.instance.levelEmailTrigger />
	</cffunction>

	<cffunction name="setSubject" access="private" returntype="void" output="false">
		<cfargument name="subject" type="string" required="true" />
		<cfset variables.instance.subject = arguments.subject />
	</cffunction>
	<cffunction name="getSubject" access="public" returntype="string" output="false">
		<cfreturn variables.instance.subject />
	</cffunction>

	<cffunction name="setServers" access="private" returntype="void" output="false">
		<cfargument name="servers" type="string" required="true" />
		<cfset variables.instance.servers = arguments.servers />
	</cffunction>
	<cffunction name="getServers" access="public" returntype="string" output="false">
		<cfreturn variables.instance.servers />
	</cffunction>

	<cffunction name="setUsername" access="private" returntype="void" output="false">
		<cfargument name="username" type="string" required="true" />
		<cfset variables.instance.username = arguments.username />
	</cffunction>
	<cffunction name="getUsername" access="public" returntype="string" output="false">
		<cfreturn variables.instance.username />
	</cffunction>

	<cffunction name="setPassword" access="private" returntype="void" output="false">
		<cfargument name="password" type="string" required="true" />
		<cfset variables.instance.password = arguments.password />
	</cffunction>
	<cffunction name="getPassword" access="public" returntype="string" output="false">
		<cfreturn variables.instance.password />
	</cffunction>

	<cffunction name="setCharset" access="private" returntype="void" output="false">
		<cfargument name="charset" type="string" required="true" />
		<cfset variables.instance.charset = arguments.charset />
	</cffunction>
	<cffunction name="getCharset" access="public" returntype="string" output="false">
		<cfreturn variables.instance.charset />
	</cffunction>

	<cffunction name="setSpoolenable" access="private" returntype="void" output="false">
		<cfargument name="spoolEnable" type="boolean" required="true" />
		<cfset variables.instance.spoolEnable = arguments.spoolEnable />
	</cffunction>
	<cffunction name="getSpoolEnable" access="public" returntype="boolean" output="false">
		<cfreturn variables.instance.spoolEnable />
	</cffunction>

	<cffunction name="setTimeout" access="private" returntype="void" output="false">
		<cfargument name="timeout" type="numeric" required="true" />
		<cfset variables.instance.timeout = arguments.timeout />
	</cffunction>
	<cffunction name="getTimeout" access="public" returntype="numeric" output="false">
		<cfreturn variables.instance.timeout />
	</cffunction>
	
	<cffunction name="setMailType" access="private" returntype="void" output="false">
		<cfargument name="mailType" type="string" required="true" />
		<cfset variables.instance.mailType = arguments.mailType />
	</cffunction>
	<cffunction name="getMailType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.mailType />
	</cffunction>
	
</cfcomponent>