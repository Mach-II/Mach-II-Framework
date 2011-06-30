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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent displayname="ApiEndpoint"
	extends="MachII.endpoints.rest.BaseEndpoint"
	hint="An endpoint that provides a REST API to dashboard functionality."
	output="false"
	rest:authenticate="false">

	<!---
	PROPERTIES
	--->
	<cfset variables.authentication = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the API endpoint.">
		
		<cfset variables.authentication = CreateObject("component", "MachII.security.http.basic.Authentication").init("Dashboard API", getParameter("apiCredentialFilePath")) />
				
		<cfset super.configure() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - REQUEST
	--->
	<cffunction name="onAuthenticate" access="public" returntype="void" output="false"
		hint="Runs authentication.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var restUri = arguments.event.getArg("restUri") />
		
		<!--- Authenticate the request via HTTP basic authentication --->
		<cfif restUri.getUriMetadataParameter("authenticate", getAuthenticateDefault()) AND NOT variables.authentication.authenticate(getHTTPRequestData().headers)>
			<cfthrow type="MachII.dashboard.endpoints.notAuthorized"
				message="Bad credentials." />
		</cfif>
	</cffunction>
	
	<cffunction name="onException" access="public" returntype="void" output="true"
		hint="Runs when an exception occurs in the endpoint.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception that was thrown/caught by the endpoint request processor." />
		
		<!--- Handle notAuthorized --->
		<cfif arguments.exception.getType() EQ "MachII.dashboard.endpoints.notAuthorized">
			<cfset addHTTPHeaderByStatus(401) />
			<cfset addHTTPHeaderByName("machii.endpoint.error", arguments.exception.getMessage()) />
			<cfsetting enablecfoutputonly="false" /><cfoutput><cfinclude template="/MachII/security/http/basic/defaultUnauthorized.cfm" /></cfoutput><cfsetting enablecfoutputonly="true" />
		<!--- Default exception handling --->
		<cfelse>
			<cfset super.onException(arguments.event, arguments.exception) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - REST
	--->
	<cffunction name="temp" access="public" returntype="string" output="false"
		hint="Temp testing method. To be removed"
		rest:uri="/temp/{email}"
		rest:method="GET">
		<cfargument name="event">
		
		<cfreturn event.getArg("email") />
	</cffunction>

</cfcomponent>