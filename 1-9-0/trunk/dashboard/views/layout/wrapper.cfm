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
 - Leave cfcontent reset next to DocType to remove a line break that cause some browsers to go into quirks mode
--->
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
</cfsilent>
<cfoutput><cfcontent reset="true" /><view:doctype />
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<view:charset outputType="inline" />
	
	<view:style endpoint="dashboard.serveAsset" p:file="/css/basic.cfm:css" media="screen,projection" outputType="inline" />
	<view:style endpoint="dashboard.serveAsset" p:file="/css/dialog.cfm:css" media="screen,projection" outputType="inline" />
	<view:link type="icon" endpoint="dashboard.serveAsset" p:file="/img/favicon.ico" outputType="inline" />
<cfif event.isArgDefined("meta.refresh")>
	<view:meta type="refresh" content="#event.getArg("meta.refresh")#" outputType="inline" />
</cfif>
	<view:meta type="Pragma" content="no-cache,no-store" outputType="inline" />
	<view:meta type="Cache-Control" content="no-cache,no-store,must-revalidate,max-age=0" outputType="inline" />
	<view:meta type="Expires" content="Sat, 05 Jul 1997 07:00:00 GMT" outputType="inline" />
	<cfset addHTTPHeaderByName("Pragma", "no-cache,no-store") />
	<cfset addHTTPHeaderByName("Cache-Control", "no-cache,no-store,must-revalidate,max-age=0") />
	<cfset addHTTPHeaderByName("Expires", "Sat, 05 Jul 1997 07:00:00 GMT") />

	<view:script endpoint="dashboard.serveAsset" p:file="/js/dump.js" outputType="inline" />

	<view:script endpoint="dashboard.serveAsset" p:file="/js/prototype.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/builder.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/effects.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/builder.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/dragdrop.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/controls.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/slider.js" outputType="inline" />
	<view:script endpoint="dashboard.serveAsset" p:file="/js/dialog.js" outputType="inline">
		Dialog.settings.dialogOpacity = 1;
		Dialog.settings.cancelWhenOverlayIsClicked = true;
	</view:script>
	<cfif event.getName() NEQ "sys.login" AND getProperty("enableLogin")>
		<cfset variables.confirmLogout = getProperty("logoutPromptTimeout") />
	<cfelse>
		<cfset variables.confirmLogout = 0 />
	</cfif>
	<view:script endpoint="dashboard.serveAsset" p:file="/js/handler/global.js" outputType="inline">
		myGlobalHandler = new GlobalHandler('#variables.confirmLogout#', '#BuildUnescapedUrl(event.getRequestName(), "logout=true")#');
	</view:script>
</head>
<body>
<div id="container">

<div id="header">
	#event.getArg("layout.header")#
</div>

<div id="subNavTabs">
	#event.getArg("layout.snip_pageNavTabs")#
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