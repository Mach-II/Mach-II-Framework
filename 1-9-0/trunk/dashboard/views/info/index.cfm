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
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Information" />
	
	<cfset variables.sysProperties = createObject("java", "java.lang.System").getProperties() />
	
	<cfif StructKeyExists(variables.sysProperties, "jrun.server.name")>
		<cfset variables.instanceName = variables.sysProperties["jrun.server.name"] />
	<cfelse>
		<cfset variables.instanceName = "n/a" />
	</cfif>
	
	<cfset variables.engineInfo = getAppManager().getUtils().getCfmlEngineInfo() />
	
	<cftry>
		<!--- OpenBD on GAE do not support java.awt.* package so replace with mock function --->
		<cfif FindNoCase("BlueDragon", engineInfo.Name) AND engineInfo.productLevel EQ "Google App Engine">
			<!--- We must explicitly throw an exception because the GAE version silently fails --->
			<cfthrow type="MachII.framework.AWTNotSupportedOnThisEngine" />
		</cfif>
		
		<cfset variables.awtToolkit = CreateObject("java", "java.awt.Toolkit").getDefaultToolkit() />
		<cfset variables.awtToolkitAvailable = true />
		
		<cfcatch type="any">
			<cfset variables.awtToolkitAvailable = false />
		</cfcatch>
	</cftry>
	
	<view:script endpoint="dashboard.serveAsset" p:file="/js/handler/info.js">
		<cfoutput>
			myInfoHandler = new InfoHandler('#BuildUnescapedUrl("js.info.suggestGarbageCollection")#', '#BuildUnescapedUrl("js.info.snip_memoryInformation")#');
		</cfoutput>
	</view:script>
</cfsilent>
<cfoutput>
	
<div id="messageBox" style="display:none;">
<div class="info">
	<p id="messageBoxText"></p>
</div>
</div>

<h1>Server &amp; Application Information</h1>

<ul class="pageNavTabs">
	<li style="width:425px">
		<span id="miRun">
			<a onclick="myInfoHandler.refreshMemoryinformation();">
				<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/arrow_rotate_clockwise.png" width="16" height="16" alt="Refresh" />
				&nbsp;Refresh Memory Information (Automatically Updates Every 30 Seconds)
			</a>
		</span>
		<span id="miInProgress" style="display:none;" class="red">
			<<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/ajax-loader.gif" width="16" height="16" alt="Loading" />
			&nbsp;<strong>Memory Information Refresh In Progress</strong>
		</span>
	</li>
	<li style="width:425px">
		<span id="gcRun">
			<a onclick="myInfoHandler.suggestGarbageCollection();">
				<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/cog_delete.png" width="16" height="16" alt="Refresh" />
				&nbsp;Suggest Garbage Collection
			</a>
		</span>
		<span id="gcInProgress" style="display:none;" class="red">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/ajax-loader.gif" width="16" height="16" alt="Loading" />
			&nbsp;<strong>Garbage Collection In Progress - <span id="gcInProgressCount"></span></strong>
		</span>
	</li>
</ul>
<div class="twoColumn" style="margin-top:24px;">
	<div class="left" style="width:454px;">
		<table>
			<tr>
				<th colspan="2"><h3>CFML Server Information</h3></th>
			</tr>
			<tr>
				<td style="width:30%;"><h4>Vendor</h4></td>
				<td style="width:70%;"><p>#variables.engineInfo.Name#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Version</h4></td>
				<td><p>#variables.engineInfo.FullVersion#</p></td>
			</tr>
			<tr>
				<td><h4>Version Level</h4></td>
				<td><p>#variables.engineInfo.ProductLevel#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Application Server</h4></td>
				<td><p>#variables.engineInfo.AppServer#</p></td>
			</tr>
			<tr>
				<td>
					<h4>
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/instance.png" width="16" height="16" alt="Instance Name" title="Instance Name" />
						 Instance Name
					</h4>
				</td>
				<td>
					<p>#variables.instanceName#</p>
				</td>
			</tr>
		</table>
		<table style="margin-top:24px;">
			<tr>
				<th colspan="2"><h3>Server Information</h3></th>
			</tr>
			<tr>
				<td style="width:30%;">
					<h4>
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/world_link.png" width="16" height="16" alt="Domain Name" title="Domain Name" />
						 Domain Name
					</h4>
				</td>
				<td style="width:70%;"><p>#cgi.server_name#</p></td>
			</tr>
			<tr class="shade">
				<td>
					<h4>
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/server.png" width="16" height="16" alt="Machine Name" title="Machine Name" />
						Machine Name
					</h4>
				</td>
				<td><p>#CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()#</p></td>
			</tr>
		</table>

		<table style="margin-top:24px;">
			<tr>
				<th colspan="2"><h3>Application Information</h3></th>
			</tr>
			<tr>
				<td style="width:30%;">
					<h4>
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/application.png" width="16" height="16" alt="Application Name" title="Application Name" />
						 Application Name
					</h4>
				</td>
				<td style="width:70%;"><p>#application.applicationname#</p></td>
			</tr>
			<tr class="shade">
				<td>
					<h4>
						<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/application_key.png" width="16" height="16" alt="Application Key" title="Application Key" />
						Mach-II App Key
					</h4>
				</td>
				<td><p>#getAppManager().getAppKey()#</p></td>
			</tr>
		</table>
		
		<table style="margin-top:24px;">
			<tr>
				<th colspan="2"><h3>Mach-II Information</h3></th>
			</tr>
			<tr>
				<td style="width:30%;"><h4>Version</h4></td>
				<td style="width:70%;"><p>#getProperty("udfs").getMachIIVersionString()#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Threading</h4></td>
				<td><p>#YesNoFormat(getAppManager().getUtils().createThreadingAdapter().allowThreading())#</p></td>
			</tr>
			<tr>
				<td><h4>Persist Scope</h4></td>
				<td><p>#getProperty("redirectPersistScope")#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Persist Parameter</h4></td>
				<td><p>#getProperty("redirectPersistParameter")#</p></td>
			</tr>
			<tr>
				<td><h4>Java AWT Toolkit</h4></td>
				<td><p>#YesNoFormat(variables.awtToolkitAvailable)#</p></td>
			</tr>
		</table>
	</div>
	<div class="right" style="width:454px;">
		<div id="memoryInformation">
		</div>
	</div>
</div>
</cfoutput>