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
<cfcomponent 
	displayname="ApplicationProperty" 
	extends="MachII.framework.Property" 
	output="false" 
	hint="Performs on module start operations.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Performs on module start operations.">
			
		<cfset var serverInfo = server.coldfusion />
		
		<cfif getAppManager().getPropertyManager().getVersion() LT "1.8.0.0">
			<cfthrow type="MachII.dashboard.unsupportedFrameworkVersion"
				message="The Mach-II Dashboard supports Mach-II 1.8.0 and higher. The current version is reported as: '#getAppManager().getPropertyManager().getVersion()#'" />
		</cfif>
		
		<!--- Setup if we use sessions or client --->
		<cfset discoverSessionManagement() />
		<!--- Setup if login should be disabled on this environment --->
		<cfset discoverEnableLoginByEnvironment() />
		
		<!--- Ensure that the password has been set if login is enabled --->
		<cfif getProperty("enableLogin")
			AND (NOT getPropertyManager().isPropertyDefined("password") 
			OR NOT Len(getProperty("password")))>
			<cfthrow type="MachII.dashboard.ApplicationProperty.noPasswordSet" 
				message="You must set a password when defining the dashboard module. See README." />
		</cfif>
		
		<cfset discoverLogoutPromptTimeoutByEnvironment() />
		
		<!--- Set charting provider --->
		<cfif StructKeyExists(serverInfo, "productLevel") AND serverInfo.productLevel EQ "Google App Engine">
			<cfset setProperty("chartProvider", "googlecharts")>
		</cfif>
		
		<!--- Set module name to the properties for use by the exception viewer --->
		<cfset setProperty("moduleName", getAppManager().getModuleName()) />
		<cfset setProperty("appKey", getAppManager().getAppKey()) />
		<cfset setProperty("metaTitleSuffix", " | Dashboard (" & cgi.SERVER_NAME & ")") />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="discoverSessionManagement" access="private" returntype="void" output="false"
		hint="Discovers how the session management is setup for this application.">
		
		<cfset var scope = "" />
		<cfset var foundScope = false />
		
		<cfif NOT foundScope>
			<cftry>
				<cfset scope = StructGet(getProperty("sessionManagementScope")) />
				
				<cfset foundScope = true />
				<cfcatch type="any">
					<!--- Do nothing --->
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfif NOT foundScope>
			<cftry>
				<cfset scope = StructGet("session") />
				
				<cfset setProperty("sessionManagementScope", "session") />
				<cfset foundScope = true />
				<cfcatch type="any">
					<!--- Do nothing --->
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfif NOT foundScope>
			<cftry>
				<cfset scope = StructGet("client") />
				
				<cfset setProperty("sessionManagementScope", "client") />
				<cfset foundScope = true />
				<cfcatch type="any">
					<!--- Do nothing --->
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- No session management is on so throw an error --->
		<cfif NOT foundScope>
			<cfthrow type="MachII.dashboard.LoginPlugin.noSessionManagement"
				message="The dashboard needs the session or client scopes for session management."
				detail="Please enabled session or client scope in your Application.cfc." />
		</cfif>
	</cffunction>
	
	<cffunction name="discoverEnableLoginByEnvironment" access="private" returntype="void" output="false"
		hint="Decides of login should be enabled by environment.">
		
		<cfset var environments = getProperty("enableLogin", true) />
		
		<cfif IsStruct(environments)>
			<cfset setProperty("enableLogin", resolveValueByEnvironment(environments, true)) />	
		</cfif>
	</cffunction>
	
	<cffunction name="discoverLogoutPromptTimeoutByEnvironment" access="private" returntype="void" output="false"
		hint="Decides of login should be enabled by environment.">
		
		<cfset var result = getProperty("logoutPromptTimeout", "forever") />
		
		<cfif IsStruct(result)>
			<cfset result = resolveValueByEnvironment(result, "30") />
		</cfif>
		
		<cfif result EQ "forever" OR NOT getProperty("enableLogin", "true")>
			<cfset result = 0 />
		<cfelse>
			<!--- Convert from minutes to milliseconds --->
			<cfset result = result * 1000 * 60 />
		</cfif>
		
		<cfset setProperty("logoutPromptTimeout", result) />	
	</cffunction>

</cfcomponent>