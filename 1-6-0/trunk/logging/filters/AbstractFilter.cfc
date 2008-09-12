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
	displayname="AbstractFilter"
	output="false"
	hint="A logging filter. This is abstract and must be extend by a concrete filter implementation.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />
	<cfset variables.instance.filterType = "undefined" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractFilter" output="false"
		hint="Initalizes the filter.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="decide" access="public" returntype="boolean" output="false"
		hint="Decides whether or not the log message elements meet the filter criteria and should be logged.">
		<cfargument name="logMessageElements" type="struct" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getFilterType" access="public" returntype="string" output="false"
		hint="Returns the type of the filter. Required for Dashboard integration.">
		<cfreturn variables.instance.filterType />
	</cffunction>
	
	<cffunction name="getFilterCriteriaData" access="public" returntype="any" output="false"
		hint="Gets a struct of filter criteria. Return struct or array with strings as values. Required for dashboard integration.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadFilterCriteria" access="private" returntype="void" output="false"
		hint="Loads filter criteria.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	
</cfcomponent>