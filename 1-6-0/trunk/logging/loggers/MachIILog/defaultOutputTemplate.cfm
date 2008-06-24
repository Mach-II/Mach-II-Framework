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
since this display template is rendered inside a *non-thread safe* CFC.

Not using the 'local' prefix can cause errors due to threading.
--->
</cfsilent>
<cfoutput>
<cfsavecontent variable="local.style">
<style type="text/css"><!--
	##MachIIRequestLogDisplay {
		color: ##000;
		background-color: ##FFF;
	}
	##MachIIRequestLogDisplay h3 {
		color: ##000;
	}
	##MachIIRequestLogDisplay table {
		border: 1px solid ##D0D0D0;
		padding: 0.5em;
		width:100%;
	}
	##MachIIRequestLogDisplay table td {
		vertical-align: top;
	}
	##MachIIRequestLogDisplay table td.lineBottom {
		border-bottom: 1px solid ##000;
	}
	##MachIIRequestLogDisplay table td.lineTop {
		border-top: 1px solid ##000;
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
<cfhtmlhead text="#local.style#" />
<div id="MachIIRequestLogDisplay">

	<h3>Mach-II Request Log</h3>
	<table>
		<tr>
			<td class="lineBottom" style="width:30%;"><h4>Channel</h4></td>
			<td class="lineBottom" style="width:7.5%;"><h4>Log Level</h4></td>
			<td class="lineBottom" style="width:55%;"><h4>Message</h4></td>
			<td class="lineBottom" style="width:7.5%;"><h4>Timing (ms)</h4></td>
		</tr>
	<cfif ArrayLen(data)>
		<cfloop from="1" to="#ArrayLen(data)#" index="local.i">
			<tr class="<cfif local.i MOD 2>shade </cfif>#data[local.i].logLevelName#">
				<td><p>#data[local.i].channel#</p></td>
				<td><p>#data[local.i].logLevelName#</p></td>
				<td><p>#data[local.i].message#</p></td>
				<td><p class="right"><cfif local.i NEQ ArrayLen(data)>#data[local.i + 1].currentTick - data[local.i].currentTick#<cfelse>0</cfif></p></td>
			</tr>
			<cfif NOT IsSimpleValue(data[local.i].caughtException)>
			<tr>
				<td colspan="4"><cfdump var="#data[local.i].caughtException#" expand="false" /></td>
			</tr>
			</cfif>
		</cfloop>
		<cfif ArrayLen(data) GT 1>
			<tr>
				<td class="lineTop">&nbsp;</td>
				<td class="lineTop">&nbsp;</td>
				<td class="lineTop"><h4 class="right">First / Last Message Timing Difference</h4></td>
				<td class="lineTop"><p class="right"><strong>#data[ArrayLen(data)].currentTick - data[1].currentTick#</strong></p></td>
			</tr>
		</cfif>
	<cfelse>
		<tr>
			<td colspan="4"><p><em>No messages available</em></p></td>
		</tr>
	</cfif>
	</table>

	<h3>General Information</h3>
	<table>
		<tr class="shade">
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
		<tr class="shade">
			<td><h4>Mach-II Version</h4></td>
			<td><p>#getMachIIVersion(arguments.appManager.getPropertyManager().getVersion())#</p></td>
		</tr>
		<tr>
			<td><h4>Timestamp</h4></td>
			<td><p>#DateFormat(Now())# #TimeFormat(Now())#</p></td>
		</tr>
	</table>
</div>
</cfoutput>