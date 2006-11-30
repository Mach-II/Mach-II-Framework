<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
$Id: FilterManager.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="FilterManager"
	output="false"
	hint="Manages registered EventFilters for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.filters = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset var filterNodes = "" />
		<cfset var filterParams = "" />
		<cfset var name = "" />
		<cfset var type = "" />
		<cfset var paramNodes = "" />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var filter = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfset setAppManager(arguments.appManager) />

		<!--- Setup up each EventFilter. --->
		<cfset filterNodes = XMLSearch(configXML,"//event-filters/event-filter") />
		<cfloop from="1" to="#ArrayLen(filterNodes)#" index="i">
			<cfset name = filterNodes[i].xmlAttributes['name'] />
			<cfset type = filterNodes[i].xmlAttributes['type'] />
		
			<!--- Set the EventFilter's parameters. --->
			<cfset filterParams = StructNew() />
			<cfset paramNodes = XMLSearch(filterNodes[i], "./parameters/parameter") />
			<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
				<cfset paramName = paramNodes[j].xmlAttributes['name'] />
				<cfset paramValue = paramNodes[j].xmlAttributes['value'] />
				<cfset filterParams[paramName] = paramValue />
			</cfloop>
			
			<cfset filter = CreateObject('component', type) />
			<cfset filter.init(arguments.appManager, filterParams) />
			
			<cfset addFilter(name, filter) />
		</cfloop> 
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered EventFilters.">
		<cfset var key = "" />
		<cfloop collection="#variables.filters#" item="key">
			<cfset getFilter(key).configure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addFilter" access="public" returntype="void" output="false"
		hint="Registers an EventFilter by name.">
		<cfargument name="filterName" type="string" required="true" />
		<cfargument name="filter" type="MachII.framework.EventFilter" required="true" />
		
		<cfif isFilterDefined(arguments.filterName)>
			<cfthrow type="MachII.framework.FilterAlreadyDefined"
				message="An EventFilter with name '#arguments.filterName#' is already registered." />
		<cfelse>
			<cfset variables.filters[arguments.filterName] = arguments.filter />
		</cfif>
	</cffunction>
	
	<cffunction name="getFilter" access="public" returntype="MachII.framework.EventFilter" output="false">
		<cfargument name="filterName" type="string" required="true" />
		
		<cfif isFilterDefined(arguments.filterName)>
			<cfreturn variables.filters[arguments.filterName] />
		<cfelse>
			<cfthrow type="MachII.framework.FilterNotDefined" 
				message="Filter with name '#arguments.filterName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="isFilterDefined" access="public" returntype="boolean" output="false">
		<cfargument name="filterName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.filters, arguments.filterName) />
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
	
	<cffunction name="getFilterNames" access="public" returntype="array" output="false"
		hint="Returns an array of filter names.">
		<cfreturn StructKeyArray(variables.filters) />
	</cffunction>
	
</cfcomponent>