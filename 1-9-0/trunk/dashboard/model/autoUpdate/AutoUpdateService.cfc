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