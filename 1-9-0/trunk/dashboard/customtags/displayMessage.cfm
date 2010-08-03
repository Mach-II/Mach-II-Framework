<cfsetting enablecfoutputonly="true" />
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
Updated version: 1.0.0

Notes:
--->
<cfimport prefix="view" taglib="/MachII/customtags/view" />
<cfif thisTag.ExecutionMode IS "start">

	<cfset variables.event = request.event />

	<cfif variables.event.isArgDefined("message")>

	<cfset variables.message = variables.event.getArg("message") />
	<cfset variables.unique = getTickCount() />


	<cfparam name="attributes.refresh" default="true" />

	<cfoutput>
	<div id="messageBox_#variables.unique#">
	<div class="#variables.message.getType()#">
		<p>#variables.message.getMessage()#</p>
	</div>

	<cfif variables.message.hasCaughtException()>
	<cfset variables.exception = variables.message.getCaughtException() />

	<table>
		<tr>
			<th style="width:15%;">
				<h3>Message</h3>
			</th>
			<td style="width:85%;">
				<p>#variables.exception.message#</p>
			</td>
		</tr>
		<tr>
			<th>
				<h3>Detail</h3>
			</th>
			<td>
				<p>#variables.exception.detail#</p>
			</td>
		</tr>
		<tr>
			<th>
				<h3>Type</h3>
			</th>
			<td>
				<p>#variables.exception.type#</p>
			</td>
		</tr>
		<tr>
			<th>
				<h3>Full Catch</h3>
			</th>
			<td>
				<p><cfdump var="#variables.exception#" expand="false" /></p>
			</td>
		</tr>
	</table>

	</cfif>
	</div>

	<cfif variables.message.getType() NEQ "exception" AND attributes.refresh>
		<view:script outputType="inline">
			timeoutId = setInterval(function() { new Effect.BlindUp('messageBox_#variables.unique#', { queue: 'end' }); clearTimeout(timeoutId);}, 5000);
		</view:script>
	</cfif>
	</cfoutput>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />