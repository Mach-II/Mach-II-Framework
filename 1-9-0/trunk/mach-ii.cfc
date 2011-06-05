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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.1.1
Updated version: 1.8.1

Notes:
- Compatible only with Adobe ColdFusion MX 7+, NewAtlanta BlueDragon 7+
	and Open BlueDragaon 1+.
- Call loadFramework in your onApplicationStart() event.
- Call handleRequest in your onRequestStart() or onRequest() events.

N.B.
Do not implement the handleRequest() in onRequest() application event if you
want to utilitze any CFCs that implement AJAX requests, web services, Flash
Remoting or event gateway requests.

ColdFusion MX will not execute these types of requests if you implement
the handleRequest() method in the onRequest() application event.

Certain methods are not available for use until after loadFramework() has
completed execution.  This is because the following method require the
framework to be loaded as they interact with framework components:

* setProperty()
* getProperty()
* isPropertyDefined()
* getAppManager()
* shouldReloadConfig()
--->
<cfcomponent
	displayname="mach-ii"
	output="false"
	hint="Bootstrapper for Application.cfc integration">

	<!---
	PROPERTIES - DEFAULTS
	--->
	<cfinclude template="/MachII/bootstrapper/common.cfm" />

	<!---
	APPLICATION SPECIFIC EVENTS
	--->
	<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false"
		hint="Handles the application start event. Override to provide customized functionality.">

		<!--- Load up the framework --->
		<cfset LoadFramework() />

		<cfreturn TRUE />
	</cffunction>

	<cffunction name="onApplicationEnd" access="public" returntype="void" output="false"
		hint="Handles the application end event. Override to provide customized functionality.">
		<cfargument name="applicationScope" type="struct" required="true">

		<!--- Access to the application and session scopes are passed in so you cannot use 'getAppManager()' --->
		<cfset arguments.applicationScope[getAppKey()].appLoader.getAppManager().onApplicationEnd() />
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void" output="true"
		hint="Handles Mach-II requests. Output must be set to true. Override to provide custom functionality.">
		<cfargument name="targetPage" type="string" required="true" />

		<!--- Handle Mach-II request --->
		<cfif FindNoCase("index.cfm", arguments.targetPage)>
			<cfset handleRequest() />
		</cfif>
	</cffunction>

	<cffunction name="onSessionStart" access="public" returntype="void" output="false"
		hint="Handles on session start event if sessions are enabled for this application.">		
		<cfset ensureLoadedFramework() />
		<cfset getAppManager().onSessionStart() />
	</cffunction>

	<cffunction name="onSessionEnd" access="public" returntype="void" output="false"
		hint="Handles on session end event if sessions are enabled for this application.">
		<cfargument name="sessionScope" type="struct" required="true" />
		<cfargument name="applicationScope" type="struct" required="true" />

		<!--- Access to the application and session scopes are passed in so you cannot use 'getAppManager()' --->
		<cfset arguments.applicationScope[getAppKey()].appLoader.getAppManager().onSessionEnd(arguments.sessionScope) />
	</cffunction>

</cfcomponent>