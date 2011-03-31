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
$Id: index.cfm 2006 2009-12-02 01:36:06Z peterfarrell $

Created version: 1.1.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfset copyToScope("${event.type},${event.results},${event.input}") />
</cfsilent>
<cfoutput>
<cfif variables.type EQ "refind">
	<cfloop from="1" to="3" index="i">
		<cfset variables.matches = variables.results[i].matches />

		<table style="padding-top:24px;">
			<tr>
				<th style="width:80%;"><h3>Pattern #i# - '#event.getArg("pattern" & i)#' - Text Match</h3></th>
				<th style="width:10%;"><h3>Position</h3></th>
				<th style="width:10%;"><h3>Length</h3></th>
			</tr>
		<cfif NOT variables.results[i].exception>
			<cfif ArrayLen(variables.results[i].matches)>
				<cfloop from="1" to="#ArrayLen(variables.matches)#" index="j">
					<tr class="<view:flip value="#i#" items="shade" />">
						<td><p><form:textarea name="pattern_#i#_#j#" id="pattern_#i#_#j#" value="#variables.matches[j].text#" style="width:100%;" /></p></td>
						<td><p>#variables.matches[j].position#</p></td>
						<td><p>#variables.matches[j].length#</p></td>
					</tr>
					<view:script outputType="inline">
						new TextAreaResize('pattern_#i#_#j#');
					</view:script>
				</cfloop>
			<cfelse>
				<tr>
					<td class="shade" colspan="3"><p><em>No matches for this pattern...</em></p></td>
				</tr>
			</cfif>
		<cfelse>
			<tr>
				<td class="shade" colspan="3"><p class="red"><em>Exception: #variables[i].matches#</em></p></td>
			</tr>
		</cfif>
		</table>
	</cfloop>
<cfelseif type EQ "rereplace">
	<cfloop from="1" to="3" index="i">
		<table style="padding-top:24px;">
			<tr>
				<th style="width:100%;"><h3>Pattern #i# - '#event.getArg("pattern" & i)#' - Text Match</h3></th>
			</tr>
			<tr class="<view:flip value="#i#" items="shade" />">
			<cfif NOT variables.results[i].exception>
				<td><p><form:textarea name="pattern#i#" id="pattern#i#" value="#variables.results[i].matches#" style="width:100%;" /></p></td>
			<cfelse>
				<td><p class="red"><em>Exception: #variables.results[i].matches#</em></p></td>
			</cfif>
			</tr>
		</table>
		<view:script outputType="inline">
			new TextAreaResize('pattern#i#');
		</view:script>
	</cfloop>
</cfif>
</cfoutput>