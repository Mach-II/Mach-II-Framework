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
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="AutoUpdateService"
	output="false"
	hint="Auto Update Service for the Auto Update Dashboard Tab">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.m2Version = "" />
	<cfset variables.dashboardVersion = "" />
	
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" output="false" returntype="AutoUpdateService"
		hint="Initializes the service.">
		<cfargument name="m2Version" type="string" required="true" />
		<cfargument name="dashboardVersion" type="string" required="true" />
		<cfargument name="autoUpdateUrl" type="string" required="true" />
		
		<cfset setM2Version(arguments.m2Version) />
		<cfset setDashboardVersion(arguments.dashboardVersion) />
		<cfset setAutoUpdateUrl(arguments.autoUpdateUrl) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setM2Version" access="private" returntype="void" output="false">
		<cfargument name="m2Version" type="string" required="true" />
		<cfset variables.m2Version = arguments.m2Version />
	</cffunction>
	<cffunction name="getM2Version" access="private" returntype="string" output="false">
		<cfreturn variables.m2Version />
	</cffunction>
	
	<cffunction name="setDashboardVersion" access="private" returntype="void" output="false">
		<cfargument name="dashboardVersion" type="string" required="true" />
		<cfset variables.dashboardVersion = arguments.dashboardVersion />
	</cffunction>
	<cffunction name="getDashboardVersion" access="private" returntype="string" output="false">
		<cfreturn variables.dashboardVersion />
	</cffunction>
	
	<cffunction name="setAutoUpdateUrl" access="private" returntype="void" output="false">
		<cfargument name="autoUpdateUrl" type="string" required="true" />
		<cfset variables.autoUpdateUrl = arguments.autoUpdateUrl />
	</cffunction>
	<cffunction name="getAutoUpdateUrl" access="private" returntype="string" output="false">
		<cfreturn variables.autoUpdateUrl />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getPackageData" access="public" returntype="any" output="false" 
		hint="Gets the data for all the active packages.">
		
		<cfset var exitEvent = "success" />
		<cfset var message = "" />
		<cfset var frameworkData = "" />
		<cfset var dashboardData = "" />
		<cfset var packageData = "" />
		<cfset var packageData_Formatted = "" />
		<cfset var packageDataStruct = StructNew() />
		
		<cfhttp url="#getAutoUpdateUrl()#" 
			result="packageData" 
			method="get" />
		
		<cfif packageData.ResponseHeader.status_code NEQ 200>
			<cfset exitEvent = "fail" />
			<cfset message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
			<cfset message.setMessage("The Auto Update data could not be retrieved at this time.") />
		<cfelse>
			<cfwddx action="wddx2cfml" 
				input="#packageData.fileContent#" 
				output="packageData_Formatted" />
			
			<!---Get Framework Data --->
			<cfquery dbtype="query" name="frameWorkData">
				SELECT		filelocation, version, build, releaseType, dateReleased
				FROM		packageData_Formatted
				WHERE		packageName = 'framework'
				  AND		packageStatus = 1
				   OR		version = '#ListDeleteAt(getM2Version(),ListLen(getM2Version(),"."),".")#'
				ORDER BY		releaseType, dateReleased DESC
			</cfquery>
			
			<cfset packageDataStruct.framework = frameworkData />
				
			<!---Get Dashboard Data--->
			<cfquery dbtype="query" name="dashboardData">
				SELECT		filelocation, version, build, releaseType, dateReleased
				FROM		packageData_Formatted
				WHERE		packageName = 'dashboard'
				AND			packageStatus = 1
				   OR		version = '#ListDeleteAt(getDashboardVersion(),ListLen(getDashboardVersion(),"."),".")#'
				ORDER BY		releaseType, dateReleased DESC
			</cfquery>
			
			<cfset packageDataStruct.dashboard = dashboardData />
		</cfif>
		
		<cfset packageDataStruct.message = message />
		<cfset packageDataStruct.exitEvent = exitEvent />		
		
		<cfreturn packageDataStruct />
	</cffunction>

</cfcomponent>