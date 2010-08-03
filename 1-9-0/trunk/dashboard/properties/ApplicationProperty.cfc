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