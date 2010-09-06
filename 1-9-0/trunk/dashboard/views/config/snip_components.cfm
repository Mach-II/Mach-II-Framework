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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.listeners[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.filters[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.plugins[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.baseComponentData.properties[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].listeners[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].filters[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].plugins[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/exclamation.png")#" width="16" height="16" alt="Reload" />
								&nbsp;#variables.moduleComponentData[variables.moduleOrder[j]].properties[i].name#
							</span>
						<cfelse>
							<span class="green">
								<img src="#BuildEndpointUrl("dashboard.serveAsset", "file=/img/icons/tick.png")#" width="16" height="16" alt="OK" />
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