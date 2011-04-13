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

$Id: mach-ii.cfc 2608 2010-12-20 23:25:18Z peterjfarrell $

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent 
	displayname="Application" 
	output="false" 
	extends="BaseApplication">
	
	<!---
	APPLICATION SPECIFIC PROPERTIES
	--->
	<cfset this.name = "machbuilder" />
	<cfset this.applicationTimeout = createTimeSpan(0, 0, 30, 0) />
	<cfset this.sessionManagement = true />
	<cfset this.setClientCookies = true />

	<!---
	APPLICATION SPECIFIC EVENTS
	--->
	<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false"
		hint="Fires when the application is first created.">
		
		<cfset super.onApplicationStart() />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="onRequest" access="public" returntype="void" output="true"
		hint="Fires after pre page processing is complete.">
		<cfargument name="targetPage" type="string" required="true"/>
	
		<!--- Define the page request properties. --->
		<cfsetting requesttimeout="20" showdebugoutput="false" enablecfoutputonly="false"/>
		
		<cflog file="machbuilder" type="info" text="Page requested: #arguments.targetpage#" />
	
		<!--- Include the requested page. --->
		<cftry>
			<cfset super.onRequest(arguments.TargetPage) />
			
			<cfinclude template="#arguments.TargetPage#"/>
			<cfcatch type="any">
				<cflog file="machbuilder" type="error" text="#cfcatch.message# || #cfcatch.detail#" />
				<cfrethrow />
			</cfcatch>
		</cftry>
	
	</cffunction>
	
	<cffunction name="onError" access="public" returntype="void" output="true"
		hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="exception" type="any" required="true" />
		<cfargument name="eventName" type="string" required="false" default="" />
	
		<cflog file="machbuilder" type="error" text="#arguments.Exception#" />
		<cflog file="machbuilder" type="error" text="#serializeJSON(arguments.Exception)#" />
		<!--- TODO: HTTP status code 432. Is this correct? If so, please comment this not standard code --->
		<cfheader statuscode="432" statustext="Error: #arguments.Exception#" />
	</cffunction>
	
</cfcomponent>