<cfsilent>
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
You must use the 'local' prefix for all variables created in this template 
since this display template is rendered inside a *non-thread safe* CFC.

Not using the 'local' prefix can cause errors due to threading.

--->
<cfset local.i = 1 />
</cfsilent>
<cfoutput>
<h3>General Information</h3>
<table>
	<tr>
		<td><h4>Request Event Name</h4></td>
		<td><p>#arguments.appManager.getRequestHandler().getRequestEventName()#</p></td>
	</tr>
	<tr>
		<td><h4>Request Module Name</h4></td>
		<td>
		<cfif Len(arguments.appManager.getRequestHandler().getRequestModuleName())>
			<p>#arguments.appManager.getRequestHandler().getRequestModuleName()#</p>
		<cfelse>
			<p><em>Base Application</em></p>
		</cfif>
		</td>
	</tr>
	<tr>
		<td><h4>Server Name</h4></td>
		<td><p>#cgi.SERVER_NAME#</p></td>
	</tr>
	<tr>
		<td><h4>Mach-II Version</h4></td>
		<td><p>#getMachIIVersion(arguments.appManager.getPropertyManager().getVersion())#</p></td>
	</tr>
	<tr>
		<td><h4>Mach-II Environment Name</h4></td>
		<td><p>#arguments.appManager.getEnvironmentName()#</p></td>
	</tr>
	<tr>
		<td><h4>Mach-II Environment Group Name</h4></td>
		<td><p>#arguments.appManager.getEnvironmentGroup()#</p></td>
	</tr>
	<tr>
		<td><h4>Timestamp</h4></td>
		<td><p>#DateFormat(Now())# #TimeFormat(Now())#</p></td>
	</tr>
	<tr>
		<td><h4>Remote IP</h4></td>
		<td><p>#cgi.remote_addr#</p></td>
	</tr>
	<tr>
		<td><h4>Remote User Agent</h4></td>
		<td><p>#cgi.http_user_agent#</p></td>
	</tr>
	<tr>
		<td><h4>Locale</h4></td>
		<td><p>#getLocale()#</p></td>
	</tr>
</table>

<h3>Application Log</h3>
<table>
	<tr>
		<td style="width:30%;"><h4>Channel</h4></td>
		<td style="width:7.5%;"><h4>Log Level</h4></td>
		<td style="width:55%;"><h4>Message</h4></td>
		<td style="width:7.5%;"><h4>Timing (ms)</h4></td>
	</tr>
<cfloop from="1" to="#ArrayLen(data)#" index="local.i">
	<tr class="<cfif local.i MOD 2>shade </cfif>#data[local.i].logLevelName#">
		<td><p>#data[local.i].channel#</p></td>
		<td><p>#data[local.i].logLevelName#</p></td>
		<td><p>#data[local.i].message#</p></td>
		<td><p><cfif local.i NEQ ArrayLen(data)>#data[local.i + 1].currentTick - data[local.i].currentTick#<cfelse>0</cfif></p></td>
	</tr>
	<cfif NOT IsSimpleValue(data[local.i].additionalInformation)>
	<tr>
		<td colspan="4"><cfdump var="#data[local.i].additionalInformation#" /></td>
	</tr>
	</cfif>
</cfloop>
<cfif ArrayLen(data) GT 1>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td><h4 class="right">First / Last Message Timing Difference</h4></td>
		<td><p class="right"><strong>#data[ArrayLen(data)].currentTick - data[1].currentTick#</strong></p></td>
	</tr>
</cfif>
</table>

<!--- If exception event, show original event at the time of the fatal problem --->
<cfif arguments.appManager.getRequestHandler().getIsException()>
	<cfif arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent().isArgDefined("exceptionEvent")>
		<cfset local.event = arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent().getArg("exceptionEvent") />
	<cfelseif arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent().isArgDefined("missingEvent")>
		<cfset local.event = arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent().getArg("missingEvent") />
	<cfelse>
		<cfset local.event = arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent() />
	</cfif>
<cfelse>
	<cfset local.event = arguments.appManager.getRequestHandler().getEventContext().getCurrentEvent() />
</cfif>

<h3>Event</h3>
<cfdump var="#local.event.getArgs()#" />
</cfoutput>