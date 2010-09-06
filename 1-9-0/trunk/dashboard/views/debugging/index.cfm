<cfsilent>
<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

	As a special exception, the copyright holders of this library give you
	permission to link this library with independent modules to produce an
	executable, regardless of the license terms of these independent
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

$Id$

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->

	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<view:meta type="title" content="Debugging" />
	
	<cfset variables.exceptionViewer = event.getArg("exceptionViewer") />
	<cfset variables.dataStorage = event.getArg("dataStorage") />
</cfsilent>
<cfoutput>
<dashboard:displayMessage />
	
<h1>Exception Viewer</h1>

<form:form actionEvent="debugging.changeSnapshotLevel"
	method="post"
	id="changeSnapshotLevel">
<ul class="pageNavTabs">
<cfif variables.exceptionViewer.isLoggingEnabled()>
	<li>
		<view:a event="debugging.enableDisableExceptionViewer" p:mode="disable">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/stop.png" width="16" height="16" alt="Disabled" />
			&nbsp;Disable Exception Viewer
		</view:a>
	</li>
<cfelse>
	<li>
		<view:a event="debugging.enableDisableExceptionViewer" p:mode="enable">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/accept.png" width="16" height="16" alt="Enable" />
			&nbsp;Enable Exception Viewer
		</view:a>
	</li>
</cfif>
	<li>
		<view:a event="debugging.flushExceptionViewerDataStorage">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_delete.png" width="16" height="16" alt="Flush" />
			&nbsp;Flush Exception Viewer Data Storage
		</view:a>
	</li>
	<li>
		<view:a event="debugging.index">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/arrow_rotate_clockwise.png" width="16" height="16" alt="Refresh" />
			&nbsp;Refresh Stats
		</view:a>
	</li>
	<li>
		Snapshot Level&nbsp;
		<form:select name="level" checkValue="#variables.exceptionViewer.getSnapshotLevel()#" style="width:8em;" onchange="document.getElementById('changeSnapshotLevel').submit();">
			<form:options items="All" />
			<form:options items="Trace,Debug,Info" class="green" />
			<form:options items="Warn,Error,Fatal" class="red" />
			<form:options items="Off" />
		</form:select>
	</li>
</ul>
</form:form>

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