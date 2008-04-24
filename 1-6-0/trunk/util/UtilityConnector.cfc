<!---
License:
Copyright 2008 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="UtilityConnector"
	output="false"
	hint="">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.moduleName = "" />

	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="UtilityConnector" output="false"
		hint="Initializes the connector.">
		<cfargument name="moduleName" type="string" required="false"
			hint="Name of module you want to use. Otherwise it defaults to base application." />
		<cfargument name="appKey" type="string" required="false"
			hint="Used to manually set the appKey if you use this feature of Mach-II. " />
	
		<!--- Set the module name if defined --->
		<cfif StructKeyExists(arguments, "moduleName")>
			<cfset setModuleName(arguments.moduleName) />
		</cfif>
		<!--- Use reference placed by ColdspringProperty when framework is loading --->
		<cfset setAppManager(request._MachIIAppManager) />

		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getLogFactory" access="public" returntype="MachII.logging.LogFactory" output="false"
		hint="Gets the LogFactory.">
		<cfreturn getAppManager().getLogFactory() />
	</cffunction>

	<cffunction name="getCacheStrategyManager" access="public" returntype="MachII.caching.CacheStrategyManager" output="false"
		hint="Gets the CacheStrategyManager.">
		<cfreturn getAppManager().getCacheManager().getCacheStrategyManager() />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setModuleName" access="private" returntype="void" output="false">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="public" returntype="string" output="false">
		<cfreturn variables.moduleName />
	</cffunction>
	
</cfcomponent>