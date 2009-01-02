<cfsilent>
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
You must use the 'local' prefix for all variables created in this template 
since this display template is rendered inside a *non-thread safe* CFC
unlike using views in ViewContext.

*** WARNING ***
Not using the 'local' prefix will cause concurency errors due 
to multiple threading.
*** WARNING ***

If you are creating a custom output template and using custom CSS, create a
reference to your CSS in the local.headElement variable and the MachIILogger will
automatically put your CSS in the head section via <cfhtmlhead />
--->
<cfset local.headElement = "" />
<cfset local.cfdumpData = "" />
<cfset local.hasAppendedHeadElementFromCfdump = false />
<cfset local.i = 1 />
<cfset local.cookieRow = 1 />
</cfsilent>
<cfoutput>
<cfsavecontent variable="local.headElement">
<style type="text/css"><!--
	##MachIIRequestLogDisplay {
		color: ##000;
		background-color: ##FFF;
		text-align: left;
		padding: 1em;
	}
	##MachIIRequestLogDisplay h3 {
		color: ##000;
	}
	##MachIIRequestLogDisplay table {
		margin: 1em 0 1em 0;
		width:100%;
	}
	##MachIIRequestLogDisplay table td {
		vertical-align: top;
	}
	##MachIIRequestLogDisplay table th {
		padding: 0.5em;
		color: ##FFF;
		background-color: ##999;
		border-top: 1px solid ##666;
		border-bottom: 1px solid ##666; 
	}
	##MachIIRequestLogDisplay table th h3 {
		margin: 0;
		color: ##FFF; 
	}
	##MachIIRequestLogDisplay table td {
		padding: 0.5em;
		border-top: 1px dotted ##D0D0D0;
		border-bottom: 1px dotted ##D0D0D0;
	}
	##MachIIRequestLogDisplay table td.lineBottom {
		border-bottom: 1px dotted ##666;
	}
	##MachIIRequestLogDisplay table td.lineTop {
		border-top: 1px dotted ##666;
	}
	##MachIIRequestLogDisplay .shade {
		background-color: ##F5F5F5;
	}
	##MachIIRequestLogDisplay ul li {
		margin-left:15px;
	}
	##MachIIRequestLogDisplay .small {
		font-size: 0.9em;
	}
	##MachIIRequestLogDisplay .right {
		text-align: right;
	}
	##MachIIRequestLogDisplay .fatal {
		color: ##FFF;
		background-color: ##FF9999;
		font-weight: bold;
	}
	##MachIIRequestLogDisplay .error {
		background-color: ##FFCC66;
		font-weight: bold;
	}
	##MachIIRequestLogDisplay .warn {
		background-color: ##FFFF99;
		font-weight: bold;
	}
	##MachIIRequestLogDisplay .info {
		background-color: ##CCFF99;
		font-weight: bold;
	}
	##MachIIRequestLogDisplay .strong {
		font-weight: bold;
	}
-->
</style>
</cfsavecontent>
<div id="MachIIRequestLogDisplay">
	<table>
		<tr>
			<th style="width:30%;"><h3>Channel</h3></th>
			<th style="width:10%;"><h3>Log Level</h3></th>
			<th style="width:50%;"><h3>Message</h3></th>
			<th style="width:10%;"><h3>Timing</h3></th>
		</tr>
	<cfif ArrayLen(data)>
		<cfloop from="1" to="#ArrayLen(data)#" index="local.i">
			<tr class="<cfif local.i MOD 2>shade </cfif>#data[local.i].logLevelName#">
				<td><p>#data[local.i].channel#</p></td>
				<td><p>#data[local.i].logLevelName#</p></td>
				<td><p>#data[local.i].message#</p></td>
				<td><p class="right"><cfif local.i NEQ ArrayLen(data)>#data[local.i + 1].currentTick - data[local.i].currentTick#<cfelse>0</cfif></p></td>
			</tr>
			<cfif NOT IsSimpleValue(data[local.i].additionalInformation) OR (IsSimpleValue(data[local.i].additionalInformation) AND Len(data[local.i].additionalInformation))>
			<tr>
				<td colspan="4">
					<cfset local.cfdumpData = processCfdump(data[local.i].additionalInformation) />
					#local.cfdumpData.data#
					<cfif NOT local.hasAppendedHeadElementFromCfdump>
						<cfset local.headElement = local.headElement & local.cfdumpData.headElement />
						<cfset local.hasAppendedHeadElementFromCfdump = true />
					</cfif>
			</tr>
			</cfif>
		</cfloop>
		<cfif ArrayLen(data) GT 1>
			<tr>
				<td class="lineTop lineBottom" colspan="3"><h3 class="right">First / Last Message Timing Difference (ms)</h3></td>
				<td class="lineTop lineBottom"><h3 class="right">#data[ArrayLen(data)].currentTick - data[1].currentTick#</h3></td>
			</tr>
		</cfif>
	<cfelse>
		<tr>
			<td colspan="4"><p><em>No messages available</em></p></td>
		</tr>
	</cfif>
	</table>

	<table>
		<tr>
			<th colspan="2"><h3>Request Information</h3></th>
		</tr>
		<tr>
			<td><h4>Request Event Name</h4></td>
			<td><p>#arguments.appManager.getRequestHandler().getRequestEventName()#</p></td>
		</tr>
		<tr class="shade">
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
			<td><h4>Mach-II Version</h4></td>
			<td><p>#getMachIIVersion(arguments.appManager.getPropertyManager().getVersion())#</p></td>
		</tr>
		<tr class="shade">
			<td><h4>Timestamp</h4></td>
			<td><p>#DateFormat(Now())# #TimeFormat(Now())#</p></td>
		</tr>
		<tr>
			<td><h4>Remote IP</h4></td>
			<td><p>#cgi.remote_addr#</p></td>
		</tr>
		<tr class="shade">
			<td><h4>Remote User Agent</h4></td>
			<td><p>#cgi.http_user_agent#</p></td>
		</tr>
		<tr>
			<td><h4>Locale</h4></td>
			<td><p>#getLocale()#</p></td>
		</tr>
	</table>

	<table>
		<tr>
			<th colspan="2"><h3>Cookies</h3></th>
		</tr>
	<cfloop collection="#cookie#" item="local.i">
		<tr <cfif local.cookieRow MOD 2>class="shade"</cfif>>
			<td><h4>#local.i#</h4></td>
			<td><p>#cookie[local.i]#</p></td>
		</tr>
		<cfset local.cookieRow = local.cookieRow + 1 />
	</cfloop>
	</table>
</div>
</cfoutput>