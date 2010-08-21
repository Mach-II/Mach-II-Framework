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
 - Leave cfcontent reset next to DocType to remove a line break that cause some browsers to go into quirks mode
--->
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
</cfsilent>
<cfoutput><cfcontent reset="true" /><view:doctype />
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<view:charset outputType="inline" />
	
	<link href="#getProperty("urlBase")#/_dashboardFileServe/css/basic.cfm?pipe=css" type="text/css" rel="stylesheet" media="screen,projection" />
	
	<!--- <view:style event="sys.serveAsset" p:path="@css@basic.css" media="screen,projection" outputType="inline" /> --->
	<view:style event="sys.serveAsset" p:path="@css@dialog.css" media="screen,projection" outputType="inline" />
	<view:link type="icon" event="sys.serveAsset" p:path="@img@favicon.ico" outputType="inline" />
<cfif event.isArgDefined("meta.refresh")>
	<view:meta type="refresh" content="#event.getArg("meta.refresh")#" outputType="inline" />
</cfif>
	<view:meta type="Pragma" content="no-cache,no-store" outputType="inline" />
	<view:meta type="Cache-Control" content="no-cache,no-store,must-revalidate,max-age=0" outputType="inline" />
	<view:meta type="Expires" content="Sat, 05 Jul 1997 07:00:00 GMT" outputType="inline" />
	<cfset addHTTPHeaderByName("Pragma", "no-cache,no-store") />
	<cfset addHTTPHeaderByName("Cache-Control", "no-cache,no-store,must-revalidate,max-age=0") />
	<cfset addHTTPHeaderByName("Expires", "Sat, 05 Jul 1997 07:00:00 GMT") />

	<script src="#getProperty("urlBase")#/_dashboardFileServe/js/dump.js"></script>

	<!--- <view:script event="sys.serveAsset" p:path="@js@dump.js" outputType="inline" /> --->
	<view:script event="sys.serveAsset" p:path="@js@prototype.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@builder.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@effects.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@builder.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@dragdrop.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@controls.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@slider.js" outputType="inline" />
	<view:script event="sys.serveAsset" p:path="@js@dialog.js" outputType="inline">
		Dialog.settings.dialogOpacity = 1;
		Dialog.settings.cancelWhenOverlayIsClicked = true;
	</view:script>
	<cfif event.getName() NEQ "sys.login" AND getProperty("enableLogin")>
		<cfset variables.confirmLogout = getProperty("logoutPromptTimeout") />
	<cfelse>
		<cfset variables.confirmLogout = 0 />
	</cfif>
	<view:script event="sys.serveAsset" p:path="@js@handler@global.js" outputType="inline">
		myGlobalHandler = new GlobalHandler('#variables.confirmLogout#', '#BuildUnescapedUrl(event.getRequestName(), "logout=true")#');
	</view:script>
</head>
<body>
<div id="container">

<div id="header">
	#event.getArg("layout.header")#
</div>

<div id="content">
	#event.getArg("layout.content")#
</div>

<div id="footer">
	#event.getArg("layout.footer")#
</div>

</div>
</body>
</html></cfoutput><cfsetting enablecfoutputonly="true" />