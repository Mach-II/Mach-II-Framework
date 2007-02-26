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
$Id$

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
	<cfset variables.parentFilterManager = "">
	<cfset variables.utils = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="FilterManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentFilterManager" type="any" required="false" default=""
			hint="Optional argument for a parent filter manager. If there isn't one default to empty string." />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset variables.utils = getAppManager().getUtils() />
		
		<cfif isObject(arguments.parentFilterManager)>
			<cfset setParent(arguments.parentFilterManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
					
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

		<!--- Setup up each EventFilter. --->
		<cfset filterNodes = XMLSearch(arguments.configXML, "//event-filters/event-filter") />
		<cfloop from="1" to="#ArrayLen(filterNodes)#" index="i">
			<cfset name = filterNodes[i].xmlAttributes["name"] />
			<cfset type = filterNodes[i].xmlAttributes["type"] />
		
			<!--- Set the EventFilter's parameters. --->
			<cfset filterParams = StructNew() />
			<cfset paramNodes = XMLSearch(filterNodes[i], "./parameters/parameter") />
			<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
				<cfset paramName = paramNodes[j].xmlAttributes["name"] />
				<cfset paramValue = variables.utils.recurseComplexValues(paramNodes[j]) />
				<cfset filterParams[paramName] = paramValue />
			</cfloop>
			
			<cfset filter = CreateObject("component", type) />
			<cfset filter.init(getAppManager(), filterParams) />
			
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
		<cfelseif isObject(getParent()) AND getParent().isFilterDefined(arguments.filterName)>
			<cfreturn getParent().getFilter(arguments.filterName) />
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
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent FilterManager instance this FilterManager belongs to.">
		<cfargument name="parentFilterManager" type="MachII.framework.FilterManager" required="true" />
		<cfset variables.parentFilterManager = arguments.parentFilterManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent FilterManager instance this FilterManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentFilterManager />
	</cffunction>
	
	<cffunction name="getFilterNames" access="public" returntype="array" output="false"
		hint="Returns an array of filter names.">
		<cfreturn StructKeyArray(variables.filters) />
	</cffunction>
	
</cfcomponent>