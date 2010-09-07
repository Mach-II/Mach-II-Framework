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
$Id: index.cfm 2331 2010-08-26 21:30:46Z jorge_loyo $

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<view:meta type="title" content="Properties Viewer" />
	<cfset copyToScope("${event.baseComponentData},${event.moduleData},${event.baseData},nameOfModule=${event.module:base}") />
	<cfset variables.moduleOrder = StructKeyArray(variables.moduleData) />
	<cfset ArraySort( variables.moduleOrder , "textnocase", "asc") />
	<cfif nameOfModule eq "base">
		<cfset variables.propertyStruct = baseData.appManager.getPropertyManager().getProperties() />
	<cfelse>
		<cfset variables.propertyStruct = moduledata[nameOfModule].appManager.getPropertyManager().getProperties() />
	</cfif>
	<cfset variables.propertyArray = StructKeyArray(variables.propertyStruct) />
	<cfset ArraySort(variables.propertyArray, "textnocase", "asc") />
	<cfset nameOfModule = "#UCase(Left(nameOfModule, 1))##Right(nameOfModule, Len(nameOfModule) -1)# Module" />
</cfsilent>

<h1>Property Viewer</h1>
<cfoutput>
<table>
	<tr><th><h3>Modules</h3></th></tr>
	<tr>
		<td class="small">
			<view:a event="#event.getName()#" p:module="base">
				<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/link_go.png")#" width="16" height="16" alt="Link" />
				base
			</view:a>
		</td>
	</tr>
	<cfloop from="1" to="#ArrayLen(variables.moduleOrder)#" index="i">
	<tr class="<view:flip value='#i mod 2#' items='none,shade' />">
		<td class="small">
			<view:a event="#event.getName()#" p:module="#variables.moduleOrder[i]#">
				<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/link_go.png")#" width="16" height="16" alt="Link" />
				#variables.moduleOrder[i]#
			</view:a>
		</td>
	</tr>
	</cfloop>
</table>
</cfoutput>

<cfoutput>
<h2 style="margin:1em 0 3px 0;">#nameOfModule#</h2>
<table>
	<tr>
		<th width="200"><h3>Property</h3></th>
		<th width="80"><h3>Type</h3></th>
		<th><h3>Value</h3></th>
	</tr>
	<cfloop from="1" to="#ArrayLen(variables.propertyArray)#" index="i">
		<tr class="<view:flip value='#i mod 2#' items='none,shade' />">
			<td class="small">#variables.propertyArray[i]#</td>
			<td class="small">
				<cfset propertyValue = variables.propertyStruct[variables.propertyArray[i]] />
				<cfset propertyType = "" />
				<cfif IsSimpleValue(propertyValue)>
					<cfset propertyType = "String" />
				<cfelse>
					<cfif IsArray(propertyValue)>
						<cfset propertyType = "Array" />
					<cfelseif IsQuery(propertyValue)>
						<cfset propertyType = "Query" />
					<cfelseif IsObject(propertyValue)>
						<cfset propertyType = "Object" />
					<cfelseif IsStruct(propertyValue)>
						<cfset propertyType = "Struct" />
					<cfelse>
						<cfset propertyType = "Other" />
					</cfif>
				</cfif>
				<span class="green">#propertyType#</span>
			</td>
			<td class="small">
				<cfif propertyType eq "String">
					#propertyValue#
				<cfelseif propertyType eq "Object">
					<cfset propertyValue = getMetaData(propertyValue) />
					<cfdump var="#propertyValue#" label="#propertyValue.name#" expand="false" />
				<cfelse>
					<cfdump var="#propertyValue#" label="#variables.propertyArray[i]#" expand="false" />
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>