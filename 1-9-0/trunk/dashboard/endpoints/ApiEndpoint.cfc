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
	output="false">

	<!---
	PROPERTIES
	--->
	<cfset variables.loginCredentials = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the API endpoint.">
		
		<!--- Configure parameters --->
		<cfset setLoginCredentials(getParameter("loginCredentials", StructNew())) />
				
		<cfset super.configure() />
	</cffunction>

	<!---
	PUBLIC METHODS - REQUEST
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset super.preProcess(arguments.event) />
		
		<!--- Authenticate the request --->
		<cfif NOT authenticate(arguments.event.getArg("username"), arguments.event.getArg("password"))>
			<cfthrow type="MachII.endpoints.EndpointNotDefined"
				message="Not authenticated for '#arguments.event.getArg('pathInfo')#', httpMethod='#arguments.event.getArg('httpMethod')#'."
				detail="Please check your credientials and try again." />
		</cfif>
	</cffunction>

	<!---
	PUBLIC METHODS - REST
	--->
	<cffunction name="reloadApp" access="public" returntype="string" output="false"
		hint="Reloads an app by module. Use 'base' as the module name if you want to reload the entire application."
		rest:uri="/reloadApp/{module}"
		rest:method="POST">

		<cfset var key = arguments.event.getArg("module", "") />
		<cfset var format = arguments.event.getArg("format") />
		
		<cfreturn "temp" />
	</cffunction>
	
	<!---
	PROTECTED METHODS
	--->
	<cffunction name="authenticate" access="private" returntype="boolean" output="false"
		hint="Authenticates an API call against the login credentials.">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var credentials = getLoginCredentials() />
		
		<cfif StructKeyExists(credentials, arguments.username) AND Compare(credentials[arguments.username], arguments.password) EQ 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLoginCredentials" access="private" returntype="void" output="false">
		<cfargument name="loginCredentials" type="struct" required="true" />
		<cfset variables.loginCredentials = arguments.loginCredentials />
	</cffunction>
	<cffunction name="getLoginCredentials" access="private" returntype="struct" output="false">
		<cfreturn variables.loginCredentials />
	</cffunction>

</cfcomponent>