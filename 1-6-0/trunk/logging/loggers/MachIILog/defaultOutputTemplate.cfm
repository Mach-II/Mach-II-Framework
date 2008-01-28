<cfsilent>
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
--->
</cfsilent>
<cfoutput>
<div id="MachIITraceDisplay">
	<style type="text/css"><!--
		##MachIITraceDisplay {
			color: ##000;
			background-color: ##FFF;
		}
		##MachIITraceDisplay h3 {
			color: ##000;
		}
		##MachIITraceDisplay table {
			border: 1px solid ##D0D0D0;
			padding: 0.5em;
			width:100%;
		}
		##MachIITraceDisplay table td {
			vertical-align: top;
		}
		##MachIITraceDisplay table td.lineBottom {
			border-bottom: 1px solid ##000;
		}
		##MachIITraceDisplay table td.lineTop {
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
		##MachIITraceDisplay .fatal {
			color: ##FFF;
			background-color: ##FF9999;
			font-weight: bold;
		}
		##MachIITraceDisplay .error {
			background-color: ##FFCC66;
			font-weight: bold;
		}
		##MachIITraceDisplay .warn {
			background-color: ##FFFF99;
			font-weight: bold;
		}
		##MachIITraceDisplay .info {
			background-color: ##CCFF99;
			font-weight: bold;
		}
		##MachIITraceDisplay .strong {
			font-weight: bold;
		}
	-->
	</style>

	<h3>Mach-II Request Log</h3>
	<table>
		<tr>
			<td class="lineBottom strong" style="width:30%;">Channel</td>
			<td class="lineBottom strong" style="width:10%;">Log Level</td>
			<td class="lineBottom strong" style="width:50%;">Message</td>
			<td class="lineBottom strong" style="width:10%;">Timing (ms)</td>
		</tr>
	<cfloop from="1" to="#ArrayLen(data)#" index="i">
		<tr class="<cfif i MOD 2>shade</cfif> #data[i].logLevelName#">
			<td><p>#data[i].channel#</p></td>
			<td><p>#data[i].logLevelName#</p></td>
			<td><p>#data[i].message#</p></td>
			<td><p><cfif i EQ 1>0<cfelse>#data[i].currentTick - data[i - 1].currentTick#</cfif></p></td>
		</tr>
		<cfif NOT IsSimpleValue(data[i].caughtException)>
		<tr>
			<td colspan="4"><cfdump var="#data[i].caughtException#"  expand="false" /></td>
		</tr>
		</cfif>
	</cfloop>
	</table>

	<h3>General Information</h3>
	<table>
		<tr class="shade">
			<td class="strong">Request Event Name</td>
			<td>#arguments.appManager.getRequestHandler().getRequestEventName()#</td>
		</tr>
		<tr>
			<td class="strong">Request Module Name</td>
			<td>#arguments.appManager.getRequestHandler().getRequestModuleName()#</td>
		</tr>
		<tr class="shade">
			<td class="strong">Mach-II Version</td>
			<td>#getMachIIVersion(arguments.appManager.getPropertyManager().getVersion())#</td>
		</tr>
		<tr>
			<td class="strong">Timestamp</td>
			<td>#DateFormat(Now())# #TimeFormat(Now())#</td>
		</tr>
	</table>
</div>
</cfoutput>