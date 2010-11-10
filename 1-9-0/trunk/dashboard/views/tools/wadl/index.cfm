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

Created version: 1.1.0
Updated version: 1.1.0

Notes:
--->
	<cfset copyToScope("${event.restEndpoints}") />
	<cfset variables.sortOrder = StructKeyArray(variables.restEndpoints)>
	<cfset ArraySort(variables.sortOrder, "textnocase") />
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Tools - REST Endpoint Documentation Generator" />
</cfsilent>
<cfoutput>
<h1>REST Endpoint Documentation Generator</h1>



<form:form actionEvent="tools.wadl.process" id="processRegEx">

<h2>Select Available Endpoints</h2>

<table>
	<tr>
		<th style="width:5%"><h3>&nbsp;</h3></th>
		<th style="width:15%;"><h3>Endpoint Name</h4></th>
		<th style="width:15%;"><h3>Module</h4></th>
		<th style="width:65%;"><h3>Parameters</h4></th>
	</tr>
<cfif ArrayLen(variables.sortOrder)>
	<cfloop from="1" to="#ArrayLen(variables.sortOrder)#" index="i">
	<cfset variables.endpointName = variables.sortOrder[i] />
	<tr <cfif i MOD 2>class="shade"</cfif>>
		<td>
			<!--- By default, don't check the dashboard API --->
			<cfif variables.endpointName EQ "dashboard.api">
				<cfset variables.checked = false />
			<cfelse>
				<cfset variables.checked = true />
			</cfif>
			<form:checkbox name="endpointNames" value="#variables.endpointName#" checked="#variables.checked#" />
		</td>
		<td><p>#variables.endpointName#</p></td>
		<td>
			<cfset variables.moduelName = variables.restEndpoints[variables.endpointName].getAppManager().getModuleName() />
			<cfif Len(variables.moduelName)>
				<p>#variables.moduelName#</p>
			<cfelse>
				<p>base</p>
			</cfif>
		</td>
		<td>
			<cfset variables.parameters = variables.restEndpoints[variables.endpointName].getParameters() />
			<table class="small">
			<cfloop collection="#variables.parameters#" item="propName">
				<cfif NOT listFindNoCase("type,parameters", propName)>
					<tr>
						<td style="width:35%;"><h4>#LCase(propName)#</h4></td>
						<td style="width:65%;">
						<cfset propValue = variables.parameters[propName] />
						<cfif IsSimpleValue(propValue)>
							<p>#propValue#</p>
						<cfelse>
							<p><em>[complex value]</em></p>
						</cfif>
						</td>							
					</tr>
				</cfif>
			</cfloop>
			</table>
		</td>
	</tr>
	</cfloop>
	
<cfelse>
	<tr>
		<td colspan="3"><p><em>There are no REST based endpoints in this application.</em></p></td>
	</tr>
</cfif>
</table>

<h2>Configuration Options</h2>
<p class="right"><form:button name="view" value="View HTML" /><!---  <form:button name="pdf" value="Download PDF" /> ---> <form:button name="xml" value="Download WADL XML" /> </p>
</form:form>
</cfoutput>