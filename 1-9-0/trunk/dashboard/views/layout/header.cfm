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

Copyright: GreatBizTools, LLC
$Id$

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->

<cfset variables.sysProperties = createObject("java", "java.lang.System").getProperties() />

<cfif StructKeyExists(variables.sysProperties, "jrun.server.name")>
	<cfset variables.instanceName = variables.sysProperties["jrun.server.name"] />
<cfelse>
	<cfset variables.instanceName = "n/a" />
</cfif>

	<cfimport prefix="view" taglib="/MachII/customtags/view" />
</cfsilent>

<cfoutput>
<div id="logo">
	<h3>
		<view:a event="#getProperty("defaultEvent")#">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/machiiLogo.gif" width="218" height="60" alt="Mach-II" />
		</view:a>
	</h3>
</div>
<cfif NOT event.getArg("suppressHeadElements", false)>
<div id="serverInfo">
	<ul>
		<li>
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/world_link.png" width="16" height="16" alt="Domain Name" title="Domain Name" />
			 #cgi.server_name#
		</li>
		<li>
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/server.png" width="16" height="16" alt="Machine Name" title="Machine Name" />
			 #CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()#
		</li>
		<li>
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/instance.png" width="16" height="16" alt="Instance Name" title="Instance Name" />
			#variables.instanceName#
		</li>
		<li>
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/application.png" width="16" height="16" alt="Application Name" title="Application Name" />
			#application.applicationName#
		</li>
	<cfif getProperty("enableLogin")>
		<li class="red">
			<view:img endpoint="dashboard.serveAsset" p:file="/img/icons/cancel.png" width="16" height="16" alt="Logout" title="Logout"
				 onclick="myGlobalHandler.performLogout();" />
			<a onclick="myGlobalHandler.performLogout();">Logout</a>
		</li>
	</cfif>
	</ul>
</div>

<div id="navTabs">
	<ul>
		<li><view:a event="info.index" class="#getProperty("udfs").highlight("info.")#">Info</view:a></li>
		<li><view:a event="config.index" class="#getProperty("udfs").highlight("config.")#">Config</view:a></li>
		<li><view:a event="logging.index" class="#getProperty("udfs").highlight("logging.")#">Logging</view:a></li>
		<li><view:a event="caching.index" class="#getProperty("udfs").highlight("caching.")#">Caching</view:a></li>
		<li><view:a event="debugging.index" class="#getProperty("udfs").highlight("debugging.")#">Debugging</view:a></li>
		<li><view:a event="tools.index" class="#getProperty("udfs").highlight("tools.")#">Tools</view:a></li>
		<li><view:a event="autoUpdate.index" class="#getProperty("udfs").highlight("autoupdate.")#">Auto Update</view:a></li>
	</ul>
</div>
</cfif>
</cfoutput>