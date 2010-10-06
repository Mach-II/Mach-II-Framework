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
	<view:meta type="title" content="Configuration" />
	<cfset copyToScope("${event.baseComponentData},${event.moduleData},${event.baseData}") />
	<cfset variables.moduleOrder = StructKeyArray(variables.moduleData) />
	<cfset ArraySort( variables.moduleOrder , "textnocase", "asc") />

	<view:script endpoint="dashboard.serveAsset" p:file="/js/handler/config.js">
		<cfoutput>
			myConfigHandler = new ConfigHandler('#BuildUnescapedUrl("config.reloadAllChangedComponents")#', '#BuildUnescapedUrl("config.refreshAllChangedComponents")#');
		</cfoutput>
	</view:script>
</cfsilent>
<cfoutput>

<dashboard:displayMessage />

<h1>Configuration File Status</h1>

<ul class="pageNavTabs">
	<li>
		<view:a event="config.reloadBaseApp">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_refresh.png" width="16" height="16" alt="Reload All Mach-II Config Files" />
			&nbsp;Reload All Mach-II Config Files
		</view:a>
	</li>
<cfif StructKeyExists(variables.baseData, "lastDependencyInjectionEngineReloadDateTime")>
	<li>
		<view:a event="config.reloadBaseAppDependencyInjectionEngine">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_refresh.png" width="16" height="16" alt="Reload All DI Engine Config Files" />
			&nbsp;Reload All DI Engine Config Files
		</view:a>
	</li>
</cfif>
	<li>
		<a onclick="myConfigHandler.reloadAllChangedComponents();">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_refresh.png" width="16" height="16" alt="Reload All Changed Components" />
			&nbsp;Reload All Changed Components
		</a>
	</li>
	<li>
		<view:a event="config.index">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/arrow_rotate_clockwise.png" width="16" height="16" alt="Refresh Stats" />
			&nbsp;Refresh Stats
		</view:a>
	</li>
</ul>

<table>
	<tr>
		<th style="width:20%;"><h3>Module</h3></th>
		<th style="width:15%;"><h3>Mach-II</h3></th>
		<th style="width:15%;"><h3>DI Engine</h3></th>
		<th style="width:15%;"><h3>Enabled</h3></th>
		<th style="width:35%;"><h3>Configuration</h3></th>
	</tr>
	<tr>
		<td>
			<h4>Base</h4>
			<p class="small">
				<view:a module="" event="#variables.baseData.appManager.getPropertyManager().getProperty("defaultEvent")#">
					<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/link_go.png" width="16" height="16" alt="Link" />
					go to default event
				</view:a>
			</p>
		</td>
		<td>
			<p>
				<view:a event="config.reloadBaseApp">
				<cfif variables.baseData.shouldReloadConfig>
					<span class="red">
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Reload" />
						&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.baseData.lastReloadDateTime)# ago
					</span>
				<cfelse>
					<span class="green">
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/tick.png" width="16" height="16" alt="OK" />
						&nbsp;OK
					</span>
				</cfif>
				</view:a>
			</p>
		</td>
	<cfif StructKeyExists(variables.baseData, "lastDependencyInjectionEngineReloadDateTime")>
		<td>
			<p>
				<view:a event="config.reloadBaseAppDependencyInjectionEngine">
					<cfif variables.baseData.shouldReloadDependencyInjectionEngineConfig>
						<span class="red">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Reload" />
							&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.baseData.lastDependencyInjectionEngineReloadDateTime)# ago
						</span>
					<cfelse>
						<span class="green">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/tick.png" width="16" height="16" alt="OK" />
							&nbsp;OK
						</span>
					</cfif>
				</view:a>
			</p>
		</td>
	<cfelse>
		<td>
			<p>n/a</p>
		</td>
	</cfif>
		<td>
			<p>n/a</p>
		</td>
		<td>
			<table class="small">
				<tr>
					<td style="width:50%;"><h4>Environment Name</h4></td>
					<td style="width:50%;"><p>#getAppManager().getParent().getEnvironmentName()#</p></td>
				</tr>
				<tr>
					<td><h4>Environment Group</h4></td>
					<td><p>#getAppManager().getParent().getEnvironmentGroup()#</p></td>
				</tr>
			</table>
		</td>
	</tr>
<cfloop from="1" to="#ArrayLen(variables.moduleOrder)#" index="i">
	<tr <cfif i MOD 2>class="shade"</cfif>>
		<td>
			<h4>#UCase(Left(variables.moduleOrder[i], 1))##Right(variables.moduleOrder[i], Len(variables.moduleOrder[i]) -1)#</h4>
		<cfif getAppManager().getModuleName() NEQ variables.moduleOrder[i] AND variables.moduleData[variables.moduleOrder[i]].showInDashboard>
			<p class="small">
				<view:a module="#variables.moduleOrder[i]#" event="#variables.moduleData[variables.moduleOrder[i]].appManager.getPropertyManager().getProperty("defaultEvent")#">
					<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/link_go.png" width="16" height="16" alt="Link" />
					go to default event
				</view:a>
			</p>
		<cfelse>
			<p>&nbsp;</p>
		</cfif>
		</td>

		<td>
			<p>
				<cfif variables.moduleData[variables.moduleOrder[i]].showInDashboard>
					<view:a event="config.reloadModule" p:moduleName="#variables.moduleOrder[i]#">
					<cfif variables.moduleData[variables.moduleOrder[i]].shouldReloadConfig >
						<span class="red">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Reload" />
							<cfif isDate(variables.moduleData[variables.moduleOrder[i]].lastReloadDateTime)>
								&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.moduleData[variables.moduleOrder[i]].lastReloadDateTime)# ago
							</cfif>
						</span>
					<cfelse>
						<span class="green">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/tick.png" width="16" height="16" alt="OK" />
							&nbsp;OK
						</span>
					</cfif>
					</view:a>
				<cfelseif isObject(variables.moduleData[variables.moduleOrder[i]].loadException)>
					<view:a event="config.reloadModule" p:moduleName="#variables.moduleOrder[i]#">
						<span class="red">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Reload" />
							&nbsp;Load Error
						</span>
						<p class="small">
							<a href="##" onclick="Effect.toggle('exception_#variables.moduleOrder[i]#', 'blind'); return false;">
								show error
							</a>
						</p>
					</view:a>
				<cfelse>
					n/a
				</cfif>
			</p>
		</td>
	<cfif variables.moduleData[variables.moduleOrder[i]].showInDashboard AND StructKeyExists(variables.moduleData[variables.moduleOrder[i]], "lastDependencyInjectionEngineReloadDateTime")>
		<td>
			<p>
				<view:a event="config.reloadModuleDependencyInjectionEngine" p:moduleName="#variables.moduleOrder[i]#">
					<cfif variables.moduleData[variables.moduleOrder[i]].shouldReloadDependencyInjectionEngineConfig>
						<span class="red">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Reload" />
							&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.moduleData[variables.moduleOrder[i]].lastDependencyInjectionEngineReloadDateTime)# ago
						</span>
					<cfelse>
						<span class="green">
							<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/tick.png" width="16" height="16" alt="OK" />
							&nbsp;OK
						</span>
					</cfif>
				</view:a>
			</p>
		</td>
	<cfelse>
		<td>
			<p>n/a</p>
		</td>
	</cfif>
		<td>
			<p>
				<!--- Don't allow the dashboard to be disable from within itself --->
				<cfif variables.moduleOrder[i] NEQ getAppManager().getModuleName()>
					<cfif variables.moduleData[variables.moduleOrder[i]].showInDashboard>
						<view:a event="config.enableDisableModule" p:moduleName="#variables.moduleOrder[i]#" p:mode="disable">
							<span class="green">
								<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/tick.png" width="16" height="16" alt="Enabled" />
								&nbsp;Enabled
							</span>
						</view:a>
					<cfelse>
						<cfif NOT isObject(variables.moduleData[variables.moduleOrder[i]].loadException)>
							<view:a event="config.enableDisableModule" p:moduleName="#variables.moduleOrder[i]#" p:mode="enable">
								<span class="red">
									<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Disabled" />
									&nbsp;Disabled
								</span>
							</view:a>
						<cfelse>
							<span class="red">
								<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/exclamation.png" width="16" height="16" alt="Disabled" />
								&nbsp;Error
							</span>
							<p class="small">
								<a href="##" onclick="Effect.toggle('exception_#variables.moduleOrder[i]#', 'blind'); return false;">
									show error
								</a>
							</p>
						</cfif>
					</cfif>
				<cfelse>
					n/a
				</cfif>
			</p>
		</td>
		<td>
			<cfif variables.moduleData[variables.moduleOrder[i]].showInDashboard>
				<!--- The _ is important or we get errors --->
				<cftry>
					<cfset variables._appManager = getAppManager().getModuleManager().getModule(variables.moduleOrder[i], true).getModuleAppManager() />
					<table class="small">
						<tr>
							<td style="width:50%;"><h4>Environment Name</h4></td>
							<td style="width:50%;"><p>#variables._appManager.getEnvironmentName()#</p></td>
						</tr>
						<tr>
							<td><h4>Environment Group</h4></td>
							<td><p>#variables._appManager.getEnvironmentGroup()#</p></td>
						</tr>
					</table>
					<cfcatch type="MachII.framework.ModuleFailedToLoad">
						<p>n/a</p>
					</cfcatch>
				</cftry>
			<cfelse>
					<table class="small">
						<tr>
							<td style="width:50%;"><h4>Lazy Load</h4></td>
							<td style="width:50%;"><p>#variables.moduleData[variables.moduleOrder[i]].lazyLoad#</p></td>
						</tr>
					</table>
			</cfif>
		</td>
	</tr>
	<cfif isObject(variables.moduleData[variables.moduleOrder[i]].loadException)>
		<cfset message = CreateObject("component", "MachII.dashboard.model.sys.Message").init("Exception occurred during the (re)load of module named '#variables.moduleOrder[i]#'.", "exception") />
		<cfset message.setCaughtException(variables.moduleData[variables.moduleOrder[i]].loadException.getCaughtException()) />
		<tr id="exception_#variables.moduleOrder[i]#" style="display:none"><td colspan="6"><dashboard:displayMessage message="#message#" /></td></tr>
	</cfif>
</cfloop>
</table>

<h1>Component Status</h1>
<ul class="pageNavTabs">
	<li>
		<a onclick="myConfigHandler.reloadAllChangedComponents();">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_refresh.png" width="16" height="16" alt="Reload" />
			&nbsp;Reload All Changed Components
		</a>
	</li>
	<li>
		<form:form actionEvent="">
			Check for Changed Components Every <form:select path="reloadAllChangedComponentsValue" items="0,3,6,9,12,15" checkValue="0" onchange="myConfigHandler.periodicUpdateChangedComponents();" /> Seconds
		</form:form>
	</li>
	<li>
		<a onclick="myConfigHandler.updateChangedComponents();">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/arrow_rotate_clockwise.png" width="16" height="16" alt="Flush All" />
			&nbsp;Refresh Stats
		</a>
	</li>
	<cfif getProperty('OrmEnabled') EQ true >
 	<li>
		<view:a event="config.reloadAllOrmComponents">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/database_refresh.png" width="16" height="16" alt="Reload ORM Components" />
			&nbsp;Reload ORM Components
		</view:a>
	</li>
	</cfif>
</ul>

<div id="changedComponents">
	#event.getArg('layout.snip_components')#
</div>

<view:script outputType="inline">
	myConfigHandler.updateChangedComponents();
</view:script>
</cfoutput>