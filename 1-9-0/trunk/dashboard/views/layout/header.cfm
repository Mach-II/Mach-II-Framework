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
<cfset variables.eventName = event.getRequestName() />
<cfset variables.sysProperties = createObject("java", "java.lang.System").getProperties() />

<cfif StructKeyExists(variables.sysProperties, "jrun.server.name")>
	<cfset variables.instanceName = variables.sysProperties["jrun.server.name"] />
<cfelse>
	<cfset variables.instanceName = "n/a" />
</cfif>

	<!--- This is a hack --->
	<cffunction name="highlight" access="public" returntype="string" output="false">
		<cfargument name="level" type="string" required="true" />
		
		<cfset var result = "" />
		
		<cfif variables.eventName.toLowerCase().startsWith(arguments.level)>
			<cfset result = 'highlight' />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cfimport prefix="view" taglib="/MachII/customtags/view" />
</cfsilent>

<cfoutput>
<div id="logo">
	<h3>
		<view:a event="#getProperty("defaultEvent")#">
			<view:img event="sys.serveAsset" p:path="@img@machiiLogo.gif" width="218" height="60" alt="Mach-II" />
		</view:a>
	</h3>
</div>
<cfif NOT event.getArg("suppressHeadElements", false)>
<div id="serverInfo">
	<ul>
		<li>
			<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@world_link.png")#" width="16" height="16" alt="Domain Name" title="Domain Name" />
			 #cgi.server_name#</li>
		<li>
			<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@server.png")#" width="16" height="16" alt="Machine Name" title="Machine Name" />
			 #CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()#
		</li>
		<li>
			<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@instance.png")#" width="16" height="16" alt="Instance Name" title="Instance Name" />
			#variables.instanceName#</li>
		<li>
			<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@application.png")#" width="16" height="16" alt="Application Name" title="Application Name" />
			#application.applicationName#</li>
	<cfif getProperty("enableLogin")>
		<li class="red">
			<view:img src="#BuildUrl("sys.serveAsset", "path=@img@icons@cancel.png")#" width="16" height="16" alt="Logout" title="Logout"
				 onclick="myGlobalHandler.performLogout();" />
			<a onclick="myGlobalHandler.performLogout();">Logout</a></li>
	</cfif>
	</ul>
</div>

<div id="navTabs">
	<ul>
		<li><view:a event="info.index" class="#highlight("info.")#">Info</view:a></li>
		<li><view:a event="config.index" class="#highlight("config.")#">Config</view:a></li>
		<li><view:a event="logging.index" class="#highlight("logging.")#">Logging</view:a></li>
		<li><view:a event="caching.index" class="#highlight("caching.")#">Caching</view:a></li>
		<li><view:a event="debugging.index" class="#highlight("debugging.")#">Debugging</view:a></li>
		<li><view:a event="tools.index" class="#highlight("tools.")#">Tools</view:a></li>
		<li><view:a event="autoUpdate.index" class="#highlight("autoupdate.")#">Auto Update</view:a></li>
	</ul>
</div>
</cfif>
<!---
	Delete the function scope leakage into the ViewContext that can make errors hard to figure out
	We really shouldn't be putting a function at the top of the view.
--->
<cfset StructDelete(this, "highlight") />
<cfset StructDelete(variables, "highlight") />
</cfoutput>