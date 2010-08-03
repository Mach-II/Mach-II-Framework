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
	<cfset copyToScope("${event.baseComponentData},${event.moduleData},${event.baseData}") />
	<cfset copyToScope("${event.baseComponentData},${event.moduleData},${event.baseData}") />
	<cfset variables.moduleOrder = StructKeyArray(variables.moduleData) />
	<cfset ArraySort( variables.moduleOrder , "textnocase", "asc") />
</cfsilent>
<cfoutput>

<dashboard:displayMessage />

<h2 style="margin:1em 0 3px 0;">Base Module</h2>
<table>
	<tr>
		<th style="width:25%;"><h3>Listeners (#ArrayLen(variables.baseComponentData.listeners)#)</h3></th>
		<th style="width:25%;"><h3>Event-Filters (#ArrayLen(variables.baseComponentData.filters)#)</h3></th>
		<th style="width:25%;"><h3>Plugins (#ArrayLen(variables.baseComponentData.plugins)#)</h3></th>
		<th style="width:25%;"><h3>Configurable Properties (#ArrayLen(variables.baseComponentData.properties)#)</h3></th>
	</tr>
	<tr>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.baseComponentData.listeners)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadListener", "listenerName=#variables.baseComponentData.listeners[i].name#")#">
						<cfif variables.baseComponentData.listeners[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.listeners[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.baseComponentData.listeners[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.baseComponentData.filters)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadFilter", "filterName=#variables.baseComponentData.filters[i].name#")#">
						<cfif variables.baseComponentData.filters[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.filters[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.baseComponentData.filters[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.baseComponentData.plugins)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadPlugin", "pluginName=#variables.baseComponentData.plugins[i].name#")#">
						<cfif variables.baseComponentData.plugins[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.plugins[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.baseComponentData.plugins[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.baseComponentData.properties)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadProperty", "propertyName=#variables.baseComponentData.properties[i].name#")#">
						<cfif variables.baseComponentData.properties[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.properties[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.baseComponentData.properties[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
	</tr>
</table>

<cfset variables.moduleComponentData = event.getArg("moduleComponentData") />

<cfloop from="1" to="#ArrayLen(variables.moduleOrder)#" index="j">
<h2 style="margin:1em 0 3px 0;">#UCase(Left(variables.moduleOrder[j], 1))##Right(variables.moduleOrder[j], Len(variables.moduleOrder[j]) -1)# Module</h2>
<table>
	<tr>
		<th style="width:25%;"><h3>Listeners (#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].listeners)#)</h3></th>
		<th style="width:25%;"><h3>Event-Filters (#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].filters)#)</h3></th>
		<th style="width:25%;"><h3>Plugins (#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].plugins)#)</h3></th>
		<th style="width:25%;"><h3>Configurable Properties (#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].properties)#)</h3></th>
	</tr>
	<tr>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].listeners)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadListener", "listenerName=#variables.moduleComponentData[variables.moduleOrder[j]].listeners[i].name#|moduleName=#variables.moduleOrder[j]#")#">
						<cfif variables.moduleComponentData[variables.moduleOrder[j]].listeners[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].listeners[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].listeners[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].filters)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadFilter", "filterName=#variables.moduleComponentData[variables.moduleOrder[j]].filters[i].name#|moduleName=#variables.moduleOrder[j]#")#">
						<cfif variables.moduleComponentData[variables.moduleOrder[j]].filters[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].filters[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].filters[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].plugins)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadPlugin", "pluginName=#variables.moduleComponentData[variables.moduleOrder[j]].plugins[i].name#|moduleName=#variables.moduleOrder[j]#")#">
						<cfif variables.moduleComponentData[variables.moduleOrder[j]].plugins[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].plugins[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].plugins[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
		<td style="padding:0;">
			<cfloop from="1" to="#ArrayLen(variables.moduleComponentData[variables.moduleOrder[j]].properties)#" index="i">
			<table>
				<tr <cfif i MOD 2>class="shade"</cfif>>
					<td>
						<p><a href="#buildUrl("config.reloadProperty", "propertyName=#variables.moduleComponentData[variables.moduleOrder[j]].properties[i].name#|moduleName=#variables.moduleOrder[j]#")#">
						<cfif variables.moduleComponentData[variables.moduleOrder[j]].properties[i].shouldReloadObject>
							<span class="red">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].properties[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].properties[i].name#
							</span>
						</cfif>
						</a></p>
					</td>
				</tr>
			</table>
			</cfloop>
		</td>
	</tr>
</table>
</cfloop>
</cfoutput>