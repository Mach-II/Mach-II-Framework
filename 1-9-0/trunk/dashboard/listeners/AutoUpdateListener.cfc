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
	displayname="AutoUpdateListener"
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for base Auto Update structure.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<cfset setAutoUpdateService(CreateObject("component", "MachII.dashboard.model.autoUpdate.AutoUpdateService").init(getAppManager().getPropertyManager().getVersion(), getProperty('udfs').getVersionNumber(), getProperty('autoUpdateUrl'))) />
	</cffunction>

	<cffunction name="setAutoUpdateService" access="private" returntype="void" output="false">
		<cfargument name="AutoUpdateService" type="MachII.dashboard.model.autoUpdate.AutoUpdateService" required="true" />
		<cfset variables.AutoUpdateService = arguments.AutoUpdateService />
	</cffunction>
	<cffunction name="getAutoUpdateService" access="private" returntype="MachII.dashboard.model.autoUpdate.AutoUpdateService"  output="false">
		<cfreturn variables.AutoUpdateService />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->	
	<cffunction name="getPackageData" access="public" returntype="void" output="false"
		hint="Gets the data for all the active packages.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var packageData = StructNew() />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
		
		<cftry>
			<cfset packageData = getAutoUpdateService().getPackageData() />
			
			<cfcatch>
				<cfset message.setMessage("The Auto Update data could not be retrieved at this time.") />
				<cfset packageData.message = message />
				<cfset packageData.exitEvent = "fail" />	
			</cfcatch>
		</cftry>
		
		<cfset event.setArg("packageData", packageData) />
	</cffunction>
	
</cfcomponent>