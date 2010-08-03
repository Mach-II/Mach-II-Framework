<cfsilent>
<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->

	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Debugging" />
	
	<cfset variables.exceptionViewer = event.getArg("exceptionViewer") />
	<cfset variables.dataStorage = event.getArg("dataStorage") />
</cfsilent>
<cfoutput>
<dashboard:displayMessage />
	
<h1>Exception Viewer</h1>

<form action="#BuildUrl("debugging.changeSnapshotLevel")#"
	method="post"
	id="changeSnapshotLevel">
<ul class="pageNavTabs">
<cfif variables.exceptionViewer.isLoggingEnabled()>
	<li>
		<a href="#buildUrl("debugging.enableDisableExceptionViewer", "mode=disable")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@stop.png")#" width="16" height="16" alt="Disabled" />
			&nbsp;Disable Exception Viewer
		</a>
	</li>
<cfelse>
	<li>
		<a href="#buildUrl("debugging.enableDisableExceptionViewer", "mode=enable")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@accept.png")#" width="16" height="16" alt="Disabled" />
			&nbsp;Enable Exception Viewer
		</a>
	</li>
</cfif>
	<li>
		<a href="#buildUrl("debugging.flushExceptionViewerDataStorage")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_delete.png")#" width="16" height="16" alt="Disabled" />
			&nbsp;Flush Exception Viewer Data Storage
		</a>
	</li>
	<li>
		<a href="#BuildUrl("debugging.index")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@arrow_rotate_clockwise.png")#" width="16" height="16" alt="Flush All" />
			&nbsp;Refresh Stats
		</a>
	</li>
	<li>
		Snapshot Level&nbsp;

			<cfset variables.level = variables.exceptionViewer.getSnapshotLevel()>
			<select name="level" style="width:8em;" onchange="document.getElementById('changeSnapshotLevel').submit();">
				<option value="all"  
						<cfif variables.level EQ "all">selected="selected"</cfif>>All</option>
				<option value="trace" class="green"  
						<cfif variables.level EQ "trace">selected="selected"</cfif>>Trace</option>
				<option value="debug" class="green"  
						<cfif variables.level EQ "debug">selected="selected"</cfif>>Debug</option>
				<option value="info"  
						<cfif variables.level EQ "info">selected="selected"</cfif>>Info</option>
				<option value="warn"  
						<cfif variables.level EQ "warn">selected="selected"</cfif>>Warn</option>
				<option value="error" class="red"  
						<cfif variables.level EQ "error">selected="selected"</cfif>>Error</option>
				<option value="fatal" class="red"  
						<cfif variables.level EQ "fatal">selected="selected"</cfif>>Fatal</option>
				<option value="off"  
						<cfif variables.level EQ "off">selected="selected"</cfif>>Off</option>
			</select>
	</li>
</ul>
</form>

<cfif ArrayLen(variables.dataStorage.data)>
<cfloop from="1" to="#ArrayLen(variables.dataStorage.data)#" index="i">
	<table <cfif i NEQ 1>style="padding-top:12px;"</cfif>>
		<tr>
			<th style="width:20%;"><h3>Exception ##</h3></th>
			<th style="width:30%;"><h3>Module / Event</h3></th>
			<th style="width:30%;"><h3>Time Stamp</h3></th>
			<th style="width:20%;"><h3>Request IP Address</h3></th>
		</tr>
		<tr>
			<td><h4>#i#</h4></td>
			<td><h4>#variables.dataStorage.data[i].requestModuleName#:#variables.dataStorage.data[i].requestEventName#</h4></td>
			<td><h4>#DateFormat(variables.dataStorage.data[i].timestamp)# #TimeFormat(variables.dataStorage.data[i].timestamp)#</h4></td>
			<td><h4>#variables.dataStorage.data[i].requestIpAddress#</h4></td>
		</tr>
	</table>
	<cfset variables.messages = variables.dataStorage.data[i].messages />
	<table>
		<tr>
			<th><h3>Channel</h3></th>
			<th><h3 class="white-space:no-wrap;">Log Level</h3></th>
			<th><h3>Message</h3></th>
			<th><h3>Timing</h3></th>
		</tr>
	<cfloop from="1" to="#ArrayLen(variables.messages)#" index="j">
		<tr class="small<cfif NOT j MOD 2> shade</cfif>">
			<td><p>#variables.messages[j].channel#</p></td>
			<td><p>#variables.messages[j].logLevelName#</p></td>
			<td><p>#variables.messages[j].message#</p></td>
			<td><p class="right"><cfif j NEQ ArrayLen(variables.messages)>#variables.messages[j + 1].currentTick - variables.messages[j].currentTick#<cfelse>0</cfif></p></td>
		</tr>
	<cfif NOT IsSimpleValue(variables.messages[j].additionalInformation) 
		OR (IsSimpleValue(variables.messages[j].additionalInformation) AND Len(variables.messages[j].additionalInformation))>
		<tr>
			<td colspan="4"><cfdump var="#variables.messages[j].additionalInformation#" expand="false" /></td>
		</tr>
	</cfif>
	</cfloop>
		<tr>
			<td colspan="3"><h3 class="right">First / Last Message Timing Difference (ms)</h3></td>
			<td><h3 class="right">#variables.messages[ArrayLen(variables.messages)].currentTick - variables.messages[1].currentTick#</h3></td>
		</tr>
	</table>
</cfloop>
<cfelse>
<div class="error">
	<p>There are no request exceptions.</p>
</div>
</cfif>
</cfoutput>