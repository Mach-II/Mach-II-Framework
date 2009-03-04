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
Updated version: 1.6.1

Notes:
<property name="Logging" type="MachII.logging.LoggingProperty">
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
				<!-- Optional and defaults to 'false'
					Shows output only if CF's debug mode is enabled -->
				<key name="debugModeOnly" value="false" />
				<!-- Optional and defaults to 'suppressDebug'
					Name of event arg that suppresses debug output
					(useful when a request returns xml, json or images) -->
				<key name="suppressDebugArg" value="suppressDebug" />
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
	<cfset variables.instance.loggerTypeName = "Mach-II" />
	<cfset variables.instance.displayOutputTemplateFile = "defaultOutputTemplate.cfm" />
	<cfset variables.instance.debugModeOnly = false />
	<cfset variables.instance.suppressDebugArg = "suppressDebug" />
	
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
		<cfset adapter.configure() />
		<cfset setLogAdapter(adapter) />
		
		<!--- Configure the remaining parameters --->
		<cfif isParameterDefined("displayOutputTemplateFile")>
			<cfset setDisplayOutputTemplateFile(getParameter("displayOutputTemplateFile")) />
		</cfif>
		
		<cfif isParameterDefined("debugModeOnly")>
			<cfif NOT IsBoolean(getParameter("debugModeOnly"))>
				<cfthrow type="MachII.logging.loggers.MachIILog.Logger"
					message="The value of 'debugModeOnly' must be boolean."
					detail="Current value '#getParameter('debugModeOnly')#'" />
			<cfelse>
				<cfset setDebugModeOnly(getParameter("debugModeOnly")) />
			</cfif>
		</cfif>
		
		<cfif isParameterDefined("suppressDebugArg")>
			<cfset setSuppressDebugArg(getParameter("suppressDebugArg")) />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void"
		hint="Displays output for this logger.">
		
		<!--- Note that leaving off the 'output' attribute requires all output to be
			surrounded by cfoutput tags --->
		
		<cfset var data = ArrayNew(1) />
		<cfset var local = StructNew() />
		<cfset var out = getPageContext().getOut() />
		<cfset var buffer = "" />
		<cfset var count = 0 />
		<cfset var output = "" />
		
		<!--- Only display output if logging is enabled --->
		<cfif getLogAdapter().getLoggingEnabled()
			AND getLogAdapter().isLoggingDataDefined()
			AND ((getDebugModeOnly() AND IsDebugMode()) OR NOT getDebugModeOnly())
			AND NOT arguments.event.isArgDefined(getSuppressDebugArg())>

			<cfset data = getLogAdapter().getLoggingData().data />
			
			<cfsavecontent variable="output">
				<cfinclude template="#getDisplayOutputTemplateFile()#" />
			</cfsavecontent>
			
			<!--- Get the buffer which differs on Adobe CF --->
			<cftry>
				<cfset buffer = out.getBuffer().toString() />
				<cfcatch type="any">
					<!--- Do nothing --->
				</cfcatch>
			</cftry>

			<!--- Put head element items if defined --->
			<cfif StructKeyExists(local, "headElement")>
				<cfhtmlhead text="#local.headElement#" />
			</cfif>
				
			<!--- Inserting output before the body tag only works on Adobe CF --->
			<cfset count = FindNoCase("</body>", buffer) />
			<cfif count>
				<cfset output = Insert(output, buffer, count - 1) />
				<cfset out.clearBuffer() />
			</cfif>
			
			<cfoutput>#output#</cfoutput>
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
		
		<cfset data["Debug Mode Only"] = getDebugModeOnly() />
		<cfset data["Supress Debug Arg"] = getSuppressDebugArg() />
		<cfset data["Display Output Template"] = getDisplayOutputTemplateFile() />
		<cfset data["Logging Enabled"] = YesNoFormat(isLoggingEnabled()) />
		
		<cfreturn data />
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
				<cfset release = "BER - Unknown build" />
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
				<cfset release = "Production Stable" />
			</cfcase>
			<cfcase value="9">
				<cfset release = "Production-Only Stable (duck-typed)" />
			</cfcase>
			<cfdefaultcase>
				<cfset release = "BER - Build " & ListLast(arguments.version, ".") />
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
	
	<cffunction name="processCfdump" access="private" returntype="struct" output="false"
		hint="Processes a cfdump and returns a struct with data and head elements. 
		Also, cleans up invalid HTML syntax so debugging output will not mess up HTML validators.">
		<cfargument name="dataToDump" type="any" required="true" />
		
		<cfset var data = CreateObject("java", "java.lang.StringBuffer") />
		<cfset var results = StructNew() />
		<cfset var reFindResults = "" />
		<cfset var temp = "" />
		
		<!--- Get the dump data into a variable --->
		<cfsavecontent variable="temp"><cfdump var="#arguments.dataToDump#" expand="false" /></cfsavecontent>
		<cfset data.init(temp) />
		
		<!--- Build results struct --->
		<cfset results.data = "" />
		<cfset results.headElement = "" />
		
		<!--- Find the style element --->
		<cfset reFindResults = REFindNoCase("(<style.*</style>)", data.toString(), 1, true) />
		
		<cfif reFindResults.pos[1] NEQ 0>
			<!---
			Java substrings start with 0 not 1 like in CFML
			Must use Javacast for CF7 compatibility
			--->
			<cfset temp = data.substring(Javacast("int", reFindResults.pos[1] - 1), Javacast("int", reFindResults.len[1] + reFindResults.pos[1] - 1)) />

			<!--- Fix Adobe CF's bad syntax that does not validate --->
			<cfset temp = REReplace(temp, "<style.*?>", '<style type="text/css">', "one") />
			
			<cfset data.delete(Javacast("int", reFindResults.pos[1] - 1), Javacast("int", reFindResults.len[1] + reFindResults.pos[1] - 1)) />
			<cfset results.headElement = results.headElement & temp & Chr(13) />
		</cfif>
		
		<!--- Find the script element --->
		<cfset reFindResults = REFindNoCase("(<script.*</script>)", data.toString(), 1, true) />
		
		<cfif reFindResults.pos[1] NEQ 0>
			<!---
			Java substrings start with 0 not 1 like in CFML
			Must use Javacast for CF7 compatibility
			--->
			<cfset temp = data.substring(Javacast("int", reFindResults.pos[1] - 1), Javacast("int", reFindResults.len[1] + reFindResults.pos[1] - 1)) />
			
			<!--- Fix Adobe CF's bad syntax that does not validate --->
			<cfset temp = REReplace(temp, "<script.*?>", '<script type="text/javascript">', "one") />
			
			<cfset data.delete(Javacast("int", reFindResults.pos[1] - 1), Javacast("int", reFindResults.len[1] + reFindResults.pos[1] - 1)) />
			<cfset results.headElement = results.headElement & temp & Chr(13) />
		</cfif>
		
		<!--- Remainder is the data --->
		<cfset results.data = data.toString() />

		<cfreturn results />
	</cffunction>
		
	<!---
	ACCESSORS
	--->
	<cffunction name="setDisplayOutputTemplateFile" access="private" returntype="void" output="false"
		hint="Sets the output template location which is used for display output.">
		<cfargument name="displayOutputTemplateFile" type="string" required="true" />
		<cfset variables.instance.displayOutputTemplateFile = arguments.displayOutputTemplateFile />
	</cffunction>
	<cffunction name="getDisplayOutputTemplateFile" access="public" returntype="string" output="false"
		hint="Gets the output template location which is used for display output.">
		<cfreturn variables.instance.displayOutputTemplateFile />
	</cffunction>

	<cffunction name="setDebugModeOnly" access="private" returntype="void" output="false"
		hint="Sets if the output is shown only if CF's debug mode is enabled.">
		<cfargument name="debugModeOnly" type="boolean" required="true" />
		<cfset variables.instance.debugModeOnly = arguments.debugModeOnly />
	</cffunction>
	<cffunction name="getDebugModeOnly" access="public" returntype="boolean" output="false"
		hint="Gets if the output is shown only if CF's debug mode is enabled.">
		<cfreturn variables.instance.debugModeOnly />
	</cffunction>
	
	<cffunction name="setSuppressDebugArg" access="private" returntype="void" output="false"
		hint="Sets the event-arg the suppresses debug output if it is present.">
		<cfargument name="suppressDebugArg" type="string" required="true" />
		<cfset variables.instance.suppressDebugArg = arguments.suppressDebugArg />
	</cffunction>
	<cffunction name="getSuppressDebugArg" access="public" returntype="string" output="false"
		hint="Gets the event-arg the suppresses debug output if it is present.">
		<cfreturn variables.instance.suppressDebugArg />
	</cffunction>
	
</cfcomponent>