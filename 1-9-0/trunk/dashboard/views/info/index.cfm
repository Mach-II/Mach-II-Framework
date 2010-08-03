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
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Information" />
	
	<cfset variables.sysProperties = createObject("java", "java.lang.System").getProperties() />
	
	<cfif StructKeyExists(variables.sysProperties, "jrun.server.name")>
		<cfset variables.instanceName = variables.sysProperties["jrun.server.name"] />
	<cfelse>
		<cfset variables.instanceName = "n/a" />
	</cfif>
	
	<view:script event="sys.serveAsset" p:path="@js@handler@info.js">
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
				<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@arrow_rotate_clockwise.png")#" width="16" height="16" alt="Refresh" />
				&nbsp;Refresh Memory Information (Automatically Updates Every 30 Seconds)
			</a>
		</span>
		<span id="miInProgress" style="display:none;" class="red">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@ajax-loader.gif")#" width="16" height="16" alt="Loading" />
			&nbsp;<strong>Memory Information Refresh In Progress</strong>
		</span>
	</li>
	<li style="width:425px">
		<span id="gcRun">
			<a onclick="myInfoHandler.suggestGarbageCollection();">
				<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@cog_delete.png")#" width="16" height="16" alt="Refresh" />
				&nbsp;Suggest Garbage Collection
			</a>
		</span>
		<span id="gcInProgress" style="display:none;" class="red">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@ajax-loader.gif")#" width="16" height="16" alt="Loading" />
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
				<td style="width:70%;"><p>#server.ColdFusion.ProductName#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Version</h4></td>
				<td><p>#server.ColdFusion.ProductVersion#</p></td>
			</tr>
			<tr>
				<td><h4>Version Level</h4></td>
				<td><p>#server.ColdFusion.ProductLevel#</p></td>
			</tr>
			<tr class="shade">
				<td><h4>Application Server</h4></td>
				<td><p>#server.ColdFusion.Appserver#</p></td>
			</tr>
			<tr>
				<td>
					<h4>
						<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@instance.png")#" width="16" height="16" alt="Instance Name" title="Instance Name" />
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
						<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@world_link.png")#" width="16" height="16" alt="Domain Name" title="Domain Name" />
						 Domain Name
					</h4>
				</td>
				<td style="width:70%;"><p>#cgi.server_name#</p></td>
			</tr>
			<tr class="shade">
				<td>
					<h4>
						<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@server.png")#" width="16" height="16" alt="Machine Name" title="Machine Name" />
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
						<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@application.png")#" width="16" height="16" alt="Application Name" title="Application Name" />
						 Application Name
					</h4>
				</td>
				<td style="width:70%;"><p>#application.applicationname#</p></td>
			</tr>
			<tr class="shade">
				<td>
					<h4>
						<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@application_key.png")#" width="16" height="16" alt="Application Key" title="Application Key" />
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
		</table>
	</div>
	<div class="right" style="width:454px;">
		<div id="memoryInformation">
		</div>
	</div>
</div>
</cfoutput>