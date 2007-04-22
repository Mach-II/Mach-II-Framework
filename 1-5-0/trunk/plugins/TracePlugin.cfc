<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.1.0
Updated version: 1.5.0

Description:
A robust plugin that traces the execution of events and displays the trace
information on screen and/or logs it to a file.

Usage:
<plugin name="TracePlugin" type="MachII.plugins.TracePlugin">
	<parameters>
		<parameter name="traceMode" value="[boolean]" />
		<parameter name="displayCommented" value="[boolean]" />
		<parameter name="highlightLongTimings" value="[numeric]" />
		<parameter name="fileName" value="[string]" />
		<parameter name="suppressTraceArg" value="[string]" />
		<parameter name="debugModeOnly" value="[boolean]" />
	</parameters>
</plugin>

The {traceMode} value must be either "display", "file", "both" or "none" or a reference 
to a variable in the Mach-II properties.

If the parameter is not defined, the trace mode value will default to "display".
- "Display" mode will display the trace information on screen.
- "File" mode will log the trace information to a file.
- "Both" mode will display the trace information on screen and logs it to a file.
- "None" will not perform a trace. No trace information will be gathered.

The {displayComemented} value is boolean or a reference to a variable in the 
Mach-II properties.

If the parameter is not defined, the display commented value will default to FALSE.
- "true" will place the trace information in HTML comments and can useful if you do
not need to show trace information always, but sometime require access to a trace.
Use the view source option in your browser to see the trace information.
- "false" will display the trace information on screen.

The {highlightLongTimings} value must be numeric. If the parameter is not
defined, the highlight long timings will default "250" ms.
- Numeric integers above 0 will highlight any timings that exceed the
highlight long timings threshold. 
- "0" will disable the highlighting of long running trace timings.

The {fileName} value must be a name without a file extension.  If the
parameter is not defined, the file name value will default to "MachIITrace".

The {suppressTraceArg} value is the name of event arg to check if the trace
should be temporarily be suppressed. If the parameter is not defined, the
suppress trace arg the plugin will check will default to "suppressTrace".

The {debugModeOnly} value allows the trace to be shown only if ColdFusion's
debugging is turned on.

Notes:
Log files are created using <cflog> in the standard ColdFusion log directory
(WEB-INF/cfusion/logs/).  For more details, see Macromedia's livedocs about
<cflog>'s logging mechanism.

The plugin uses the request.tracePluginScope as a data bus to store per-request 
trace information.

The display mode outputs a div with an id of "MachIITraceDisplay".  You can 
easily reformat the appearence of the display output with CSS or extend this 
plugin and override the displayTraceInfo() method with your customized display.

This version is only compatible with Mach-II 1.1.1 or higher.
--->
<cfcomponent 
	displayname="tracePlugin"
	extends="MachII.framework.Plugin"
	output="false"
	hint="Traces the execution of Mach-II events and displays the trace information on screen and/or logs it to a file.">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = structNew() />
	<cfset variables.instance.traceMode = "display" />
	<cfset variables.instance.displayCommented = FALSE />
	<cfset variables.instance.highlightLongTimings = 250 />
	<cfset variables.instance.fileName = "MachIITrace" />
	<cfset variables.instance.suppressTraceArg = "suppressTrace" />
	<cfset variables.instance.debugModeOnly = FALSE />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the plugin.">

		<!--- Check and set the plugin parameters --->
		<cfif isParameterDefined("traceMode")>			
			<!--- Check and set --->
			<cfif NOT ListFindNoCase("display,file,both,none", getParameter("traceMode"))>
				<cfset throwUsageException("The TracePlugin {traceMode} parameter must be display, file, both or none.", "traceMode=#getParameter("traceMode")#") />
			<cfelse>
				<cfset setTraceMode(getParameter("traceMode")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("displayCommented")>		
			<cfif NOT IsBoolean(getParameter("displayCommented"))>
				<cfset throwUsageException("The TracePlugin {displayCommented} parameter must be a boolean value.", "displayCommented=#getParameter("displayCommented")#") />
			<cfelse>
				<cfset setDisplayCommented(getParameter("displayCommented")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("highlightLongTimings")>
			<cfif NOT Len(getParameter("highlightLongTimings")) OR NOT IsTrueNumeric(getParameter("highlightLongTimings"))>
				<cfset throwUsageException("The TracePlugin {highlightLongTimings} parameter must be a numeric value.", "highlightLongTimings=#getParameter("highlightLongTimings")#") />
			<cfelse>
				<cfset setHighlightLongTimings(getParameter("highlightLongTimings")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("fileName")>
			<cfif NOT Len(getParameter("fileName"))>
				<cfset throwUsageException("The TracePlugin {fileName} parameter must not be blank. Please set a file name.", "fileName=[blank]") />
			<cfelse>
				<cfset setFilename(getParameter("fileName")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("suppressTraceArg")>
			<cfif NOT Len(getParameter("suppressTraceArg"))>
				<cfset throwUsageException("The TracePlugin {suppressTraceArg} parameter must not be blank. Please set an argument name.", "suppressTraceArg=[blank]") />
			<cfelse>
				<cfset setSuppressTraceArg(getParameter("suppressTraceArg")) />
			</cfif>
		</cfif>
		<cfif isParameterDefined("debugModeOnly")>
			<cfif NOT Len(getParameter("debugModeOnly"))>
				<cfset throwUsageException("The TracePlugin {debugOnlyMode} parameter must not be blank. Please set a boolean value.", "debugOnlyMode=[blank]") />
			<cfelse>
				<cfset setDebugModeOnly(getParameter("debugModeOnly"))>
			</cfif>
		</cfif>
	</cffunction>

	<!---
	PLUGIN POINT FUNCTIONS called from EventContext
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Starts the trace if mode is not none.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getNextEvent() />
		
		<!--- Set the if we should trace this request or temporarily suppress it --->
		<cfif NOT getTraceMode() IS "none" AND ((getDebugModeOnly() AND isDebugMode()) OR NOT getDebugModeOnly())>
			<cfset setTraceRequest(TRUE) />
		<cfelse>
			<cfset setTraceRequest(FALSE) />
		</cfif>
		
		<!--- Perform trace for preProcess --->
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset setIsInitialTrace(TRUE) />
			<cfset setTraceInfo(arrayNew(1)) />	
			<cfset trace("preProcess", arguments.eventContext) />
		</cfif>
	</cffunction>

	<cffunction name="preEvent" access="public" returntype="void" output="false"
		hint="Runs the trace for the preEvent plugin point.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getCurrentEvent() />
		
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset trace("preEvent", arguments.eventContext) />
		</cfif>
	</cffunction>
	
	<cffunction name="postEvent" access="public" returntype="void" output="false"
		hint="Runs the trace for the postEvent plugin point.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getCurrentEvent() />
		
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset trace("postEvent", arguments.eventContext) />
		</cfif>
	</cffunction>
	
	<cffunction name="preView" access="public" returntype="void" output="false"
		hint="Runs the trace for the preView plugin point.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getCurrentEvent() />
		
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset trace("preView", arguments.eventContext) />
		</cfif>
	</cffunction>
	
	<cffunction name="postView" access="public" returntype="void" output="false"
		hint="Runs the trace for the postView plugin point.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getCurrentEvent() />
		
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset trace("postView", arguments.eventContext) />
		</cfif>
	</cffunction>
	
	<cffunction name="postProcess" access="public" returntype="void" output="true"
		hint="Ends the trace if the trace mode is not none and displays trace on screen if applicable.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var event = arguments.eventContext.getCurrentEvent() />
		
		<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
			<cfset trace("postProcess", arguments.eventContext) />
			<!--- Compute total since preProcess --->
			<cfset appendTrace("Total time", "", "", getTick() - getTickStart()) />
			<!--- Display trace on-screen if mode is correct --->
			<cfif ListFindNoCase("display,both", getTraceMode())>
				<cfoutput>#displayTraceInfo(getTraceInfo(), arguments.eventContext.getCurrentEvent().getRequestName(),  arguments.eventContext.getCurrentEvent().getRequestModuleName())#</cfoutput>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="handleException" access="public" returntype="void" output="false"
		hint="Runs a trace when an exception occurs (before exception event is handled).">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="exception" type="MachII.util.Exception" required="true" />
		<cfset var methodTraceInfo = structNew() />
		
		<cfset var event = "" />

		<!--- If no isInitialTrace exists, do not do trace as an exception occur before the preProcess point --->
		<cfif hasIsInitialTrace()>

			<!--- Get the current event since there is an event present --->
			<cfset event = arguments.eventContext.getCurrentEvent() />

			<cfif shouldTrace(event.isArgDefined(getSuppressTraceArg()))>
				<cfset trace("handleException", arguments.eventContext) />
				<cfset appendTrace("Messsage: " & arguments.exception.getMessage(), "exception", "-") />
			</cfif>
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->	
	<cffunction name="trace" access="private" returntype="void" output="false"
		hint="Runs a trace for the passed point and eventContext.">
		<cfargument name="point" type="string" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfif arguments.point EQ "postEvent">
			<cfset appendTrace(computeEventName(arguments.eventContext, arguments.point), computeModuleName(arguments.eventContext, arguments.point), arguments.point, computeTraceTime(), StructCopy(arguments.eventContext.getEventMappings())) />
		<cfelse>
			<cfset appendTrace(computeEventName(arguments.eventContext, arguments.point), computeModuleName(arguments.eventContext, arguments.point), arguments.point, computeTraceTime()) />
		</cfif>
	</cffunction>

	<cffunction name="computeEventName" access="private" returntype="string" output="false"
		hint="Computes the event name for this trace.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="point" type="string" required="true" />

		<cfif NOT ListFindNoCase("postProcess,preProcess", arguments.point) AND arguments.eventContext.hasCurrentEvent()>
			<cfreturn arguments.eventContext.getCurrentEvent().getName() />
		<cfelse>
			<cfreturn "Core Process" />
		</cfif>
	</cffunction>
	
	<cffunction name="computeModuleName" access="private" returntype="string" output="false"
		hint="Computes the module name for this trace.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="point" type="string" required="true" />

		<cfif NOT ListFindNoCase("postProcess,preProcess", arguments.point) AND arguments.eventContext.hasCurrentEvent()>
			<cfreturn arguments.eventContext.getCurrentEvent().getModuleName() />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

	<cffunction name="computeTraceTime" access="private" returntype="string" output="false"
		hint="Computes the trace time from the last trace until now.">
		<cfset var currentTick = getTickCount() />
		<cfset var timing  = "" />

		<cfif NOT getIsInitialTrace()>
			<cfset timing = currentTick - getTick()/>
		<cfelse>
			<cfset timing ="-"/>
			<cfset setIsInitialTrace(FALSE) />
			<cfset setTickStart(currentTick) />
		</cfif>
		<!--- Now reset the tick with the current tick for next trace --->
		<cfset setTick(currentTick) />

		<cfreturn timing />
	</cffunction>
	
	<cffunction name="appendTrace" access="private" returntype="void" output="false"
		hint="Appends a trace to the trace information array or to the log file.">
		<cfargument name="event" type="string" required="true"
			hint="Name of event for this trace." />
		<cfargument name="module" type="string" required="true"
			hint="Name of module for this trace." />
		<cfargument name="point" type="string" required="true"
			hint="Name of plugin method for this trace." />
		<cfargument name="timing" type="string" required="true"
			hint="Timing for this trace." />
		<cfargument name="mappings" type="struct" required="false"
			default="#StructNew()#" hint="Event mappings for the events if available." />
		<cfset var trace = structNew() />

		<!--- Create the trace information struct to be appended to the array or used in the log --->
		<cfset trace.event = arguments.event />
		<cfset trace.module = arguments.module />
		<cfset trace.point = arguments.point />
		<cfset trace.timing = arguments.timing />
		<cfset trace.mappings = arguments.mappings />

		<cfif ListFindNoCase("display,both", getTraceMode())>
			<cfset arrayAppend(getTraceInfo(), trace) />
		</cfif>
		<cfif ListFindNoCase("file,both", getTraceMode())>
			<cflog file="#getFileName()#" text="(#trace.timing#) - <cfif Len(trace.module)>#trace.module#:</cfif>#trace.event# :: #trace.point#" />
		</cfif>
	</cffunction>

	<cffunction name="displayTraceInfo" access="private" returntype="string" output="false"
		hint="Gets the trace information and formats for on-screen or HTML commented display.">
		<cfargument name="traceInfo" type="array" required="true"
			hint="Pass in the array from the getTraceInfo() method." />
		<cfargument name="requestEventName" type="string" required="true"
			hint="The event name that started the request lifecycle.">
		<cfargument name="requestModuleName" type="string" required="true"
			hint="The event name that started the request lifecycle.">

		<cfset var sc  = "" />
		<cfset var traceInfoArrLen = ArrayLen(arguments.traceInfo) />
		<cfset var i = "" />
		<cfset var timing = "" />

		<cfif getDisplayCommented()>
			<!-- Leave this code block as-is for proper HTML formatting --->
			<cfsavecontent variable="sc">
			<cfoutput><!--
				Mach-II Trace Information
				****************************************
				Event Name :: Point Name :: Average Time
				****************************************
				<cfloop from="1" to="#ArrayLen(arguments.traceInfo)-1#" index="i">#arguments.traceInfo[i].event# - #arguments.traceInfo[i].point# - #arguments.traceInfo[i].timing# ms
				</cfloop>#arguments.traceInfo[traceInfoArrLen].event# - #arguments.traceInfo[traceInfoArrLen].timing# ms
				****************************************
				Request Event Name: #arguments.requestEventName#
				Mach-Version: #getPropertyManager().getVersion()#
				Timestamp: #DateFormat(Now())# #TimeFormat(Now())#
				--></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="sc">
			<cfoutput>
				<div id="MachIITraceDisplay">
				<style type="text/css"><!--
					##MachIITraceDisplay table {
						border: 1px solid ##D0D0D0;
						padding: 0.5em;
						width:100%;
					}
					##MachIITraceDisplay td {
						vertical-align: top;
					}
					##MachIITraceDisplay td.lineBottom {
						border-bottom: 1px solid ##000;
					}
					##MachIITraceDisplay td.lineTop {
						border-top: 1px solid ##000;
					}
					##MachIITraceDisplay .shade {
						background-color: ##F5F5F5;
					}
					##MachIITraceDisplay ul li {
						margin-left:15px;
					}
					##MachIITraceDisplay .small {
						font-size: 0.9em;
					}
					##MachIITraceDisplay .red {
						color: ##FF0000;
					}
					##MachIITraceDisplay .green {
						color: ##6BB300;
					}
					##MachIITraceDisplay .strong {
						font-weight: bold;
					}
				-->
				</style>
				<h3>Mach-II Trace Information</h3>
				<table>
					<tr>
						<td class="lineBottom strong" style="width:65%;">Event Name</td>
						<td class="lineBottom strong" style="width:20%;">Trace Point</td>
						<td class="lineBottom strong" style="width:15%;">* Average Time</td>
					</tr>
				<cfloop from="1" to="#ArrayLen(traceInfo)-1#" index="i">
					<cfif arguments.traceInfo[i].point NEQ "preView">
					<tr <cfif i MOD 2> class="shade"</cfif>>
						<td<cfif ListFindNoCase("preEvent,postProcess", arguments.traceInfo[i].point)> class="lineTop"</cfif>>
						<cfif NOT ListFindNoCase("preView,postView,postEvent", arguments.traceInfo[i].point)>
							<cfif Len(arguments.traceInfo[i].module)>#arguments.traceInfo[i].module#:</cfif>#arguments.traceInfo[i].event#
						<cfelse>
							&nbsp;
						</cfif>
						</td>
						<td class="small<cfif ListFindNoCase("preEvent,postProcess", arguments.traceInfo[i].point)> lineTop</cfif>">
						<cfif arguments.traceInfo[i].point EQ "postView">
							view
						<cfelse>
							#arguments.traceInfo[i].point#
						</cfif>
						</td>
					<cfif arguments.traceInfo[i].point EQ "postView">
						<cfset timing = arguments.traceInfo[i].timing + arguments.traceInfo[i-1].timing>
					<cfelse>
						<cfset timing = arguments.traceInfo[i].timing />
					</cfif>
					<cfif getHighlightLongTimings() NEQ 0 AND timing GTE getHighlightLongTimings()>
						<td class="small red strong<cfif ListFindNoCase("preEvent,postProcess", arguments.traceInfo[i].point)> lineTop</cfif>" style="text-align: right;">#timing# ms</td>
					<cfelse>
						<td class="small<cfif ListFindNoCase("preEvent,postProcess", arguments.traceInfo[i].point)> lineTop</cfif>" style="text-align: right;">#timing# ms</td>
					</cfif>
					</tr>
					</cfif>
				</cfloop>
					<tr>
						<td colspan="2" class="lineTop"><em>#arguments.traceInfo[traceInfoArrLen].event#</em></td>
						<td  class="lineTop" style="text-align: right;"><em>#arguments.traceInfo[traceInfoArrLen].timing# ms</em></td>
					</tr>
				<cfif getHighlightLongTimings()>
					<tr>
						<td colspan="3" class="strong" style="text-align:right;">* Timings over #getHighlightLongTimings()# ms average execution time are red</td>
					</tr>
				</cfif>
				</table>
				<h3>General Information</h3>
				<table>
					<tr class="shade">
						<td class="lineTop strong">Request Event Name</td>
						<td class="lineTop">#arguments.requestEventName#</td>
					</tr>
					<tr>
						<td class="strong">Request Module Name</td>
						<td>#arguments.requestModuleName#</td>
					</tr>
					<tr class="shade">
						<td class="strong">Mach-II Version</td>
						<td>#getMachIIVersion()#</td>
					</tr>
					<tr>
						<td class="strong">Timestamp</td>
						<td>#DateFormat(Now())# #TimeFormat(Now())#</td>
					</tr>
				</table>
				</div>
			</cfoutput>
			</cfsavecontent>
		</cfif>

		<!--- Replace leading 4 tabs in the trace information with nothing so it appears correctly in the HTML --->
		<cfreturn replace(sc, chr(9) & chr(9) & chr(9) & chr(9), "", "ALL") />
	</cffunction>
	
	<cffunction name="getMachIIVersion" access="private" returntype="string" output="false"
		hint="Gets a nice version number istead of just numbers.">
		<cfset var version = getPropertyManager().getVersion() />
		<cfset var release = "" />
		
		<cfswitch expression="#Right(version, 1)#">
			<cfcase value="0">
				<cfset release = "Pre-Alpha / Bleeding Edge Release" />
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
				<cfset release = "Unknown Release" />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn Left(version, Len(version) - 2) & " " & release />
	</cffunction>
	
	<cffunction name="shouldTrace" access="private" returntype="boolean" output="false"
		hint="Checks if we should trace">
		<cfargument name="suppressTrace" type="boolean" required="true" />

		<cfif getTraceRequest() AND arguments.suppressTrace>
			<cfsetting showdebugoutput="false" />
			<cfset setTraceRequest(FALSE) />
		</cfif>
		
		<cfreturn getTraceRequest() />
	</cffunction>

	<cffunction name="isTrueNumeric" access="private" returntype="boolean" output="false"
		hint="Returns true if all characters in a string are numeric.">
		<cfargument name="str" type="string" required="true"
			hint="String to check.">
		<cfreturn REFind("[^0-9]", arguments.str) IS 0 />
	</cffunction>

	<cffunction name="throwUsageException" access="private" returntype="void" output="false"
		hint="Throws an usage exception.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="detail" type="string" required="false" default="No details." />
		<cfthrow type="TracePlugin.usageException"
			message="#arguments.message#"
			detail="#arguments.detail#" />
	</cffunction>

	<!---
	ACCESSORS
	--->	
	<cffunction name="setTraceMode" access="private" returntype="void" output="false">
		<cfargument name="traceMode" type="string" required="true" />
		<cfset variables.instance.traceMode = arguments.traceMode />
	</cffunction>
	<cffunction name="getTraceMode" access="private" returntype="string" output="false">
		<cfreturn variables.instance.traceMode />
	</cffunction>
	
	<cffunction name="setDebugModeOnly" access="private" returntype="void" output="false">
		<cfargument name="debugModeOnly" type="string" required="true" />
		<cfset variables.instance.debugModeOnly = arguments.debugModeOnly />
	</cffunction>
	<cffunction name="getDebugModeOnly" access="private" returntype="string" output="false">
		<cfreturn variables.instance.debugModeOnly />
	</cffunction>

	<cffunction name="setDisplayCommented" access="private" returntype="void" output="false">
		<cfargument name="displayCommented" type="boolean" required="true" />
		<cfset variables.instance.displayCommented = arguments.displayCommented />
	</cffunction>
	<cffunction name="getDisplayCommented" access="private" returntype="boolean" output="false">
		<cfreturn variables.instance.displayCommented />
	</cffunction>

	<cffunction name="setHighlightLongTimings" access="private" returntype="void" output="false">
		<cfargument name="highlightLongTimings" type="numeric" required="true" />
		<cfset variables.instance.highlightLongTimings = arguments.highlightLongTimings />
	</cffunction>
	<cffunction name="getHighlightLongTimings" access="private" returntype="numeric" output="false">
		<cfreturn variables.instance.highlightLongTimings />
	</cffunction>

	<cffunction name="setFileName" access="private" returntype="void" output="false">
		<cfargument name="fileName" type="string" required="true" />
		<cfset variables.instance.fileName = arguments.fileName />
	</cffunction>
	<cffunction name="getFileName" access="private" returntype="string" output="false">
		<cfreturn variables.instance.fileName />
	</cffunction>
	
	<cffunction name="setSuppressTraceArg" access="private" returntype="void" output="false">
		<cfargument name="suppressTraceArg" type="string" required="true" />
		<cfset variables.instance.suppressTraceArg = arguments.suppressTraceArg />
	</cffunction>
	<cffunction name="getSuppressTraceArg" access="private" returntype="string" output="false">
		<cfreturn variables.instance.suppressTraceArg />
	</cffunction>

	<cffunction name="setTraceRequest" access="private" returntype="void" output="false"
		hint="Sets the trace request request.tracePluginScope.">
		<cfargument name="traceRequest" type="boolean" required="false" />
		<cfset request.tracePluginScope.traceRequest = arguments.traceRequest />
	</cffunction>
	<cffunction name="getTraceRequest" access="private" returntype="boolean" output="false"
		hint="Gets the trace request from the request.tracePluginScope.">
		
		<cftry>
			<cfreturn request.tracePluginScope.traceRequest />
			<cfcatch type="expression">
				<cfset throwUsageException("Required request scope variable missing.", "Do not delete request.tracePluginScope.traceRequest.") />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setTraceInfo" access="private" returntype="void" output="false"
		hint="Sets the trace info array in the request.tracePluginScope.">
		<cfargument name="traceInfo" type="array" required="false" />
		<cfset request.tracePluginScope.traceInfo = arguments.traceInfo />
	</cffunction>
	<cffunction name="getTraceInfo" access="private" returntype="array" output="false"
		hint="Gets the trace info array from the request.tracePluginScope.">
		<cftry>
			<cfreturn request.tracePluginScope.traceInfo />
			<cfcatch type="expression">
				<cfset throwUsageException("Required request scope variable missing.", "Do not delete request.tracePluginScope.traceInfo.") />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setTick" access="private" returntype="void" output="false"
		hint="Sets the current tick in the request.tracePluginScope.">
		<cfargument name="tick" type="numeric" required="true" />
		<cfset request.tracePluginScope.tick = arguments.tick />
	</cffunction>
	<cffunction name="getTick" access="private" returntype="numeric" output="false"
		hint="Gets the current tick from the request.tracePluginScope.">
		<cftry>
			<cfreturn request.tracePluginScope.tick />
			<cfcatch type="expression">
				<cfset throwUsageException("Required request scope variable missing.", "Do not delete request.tracePluginScope.tick.") />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setTickStart" access="private" returntype="void" output="false"
		hint="Sets the tick start in the request.tracePluginScope.">
		<cfargument name="tickStart" type="numeric" required="true" />
		<cfset request.tracePluginScope.tickStart = arguments.tickStart />
	</cffunction>	
	<cffunction name="getTickStart" access="private" returntype="numeric" output="false"
		hint="Gets the tick start from the request.tracePluginScope.">
		<cftry>
			<cfreturn request.tracePluginScope.tickStart />
			<cfcatch type="expression">
				<cfset throwUsageException("Required request scope variable missing.", "Do not delete request.tracePluginScope.tickStart.") />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setIsInitialTrace" access="private" returntype="void" output="false"
		hint="Sets the initial trace flag in the request.tracePluginScope.">
		<cfargument name="isInitialTrace" type="boolean" required="true" />
		<cfset request.tracePluginScope.isInitialTrace = arguments.isInitialTrace />
	</cffunction>
	<cffunction name="getIsInitialTrace" access="private" returntype="boolean" output="false"
		hint="Gets the initial trace flag from the reuqest.tracePluginScope.">
		<cftry>
			<cfreturn request.tracePluginScope.isInitialTrace />
			<cfcatch type="expression">
				<cfset throwUsageException("Required request scope variable missing.", "Do not delete request.tracePluginScope.isInitialTrace.") />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="hasIsInitialTrace" access="private" returntype="boolean" output="false"
		hint="Checks if the initial trace flag exists in the request.tracePluginScope.">
		<cfreturn IsDefined("request.tracePluginScope.isInitialTrace") />
	</cffunction>

</cfcomponent>