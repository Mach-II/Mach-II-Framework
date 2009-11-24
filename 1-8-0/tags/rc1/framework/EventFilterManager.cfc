<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="EventFilterManager"
	output="false"
	hint="Manages registered EventFilters for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentFilterManager = "" />
	<cfset variables.filterProxies = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventFilterManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getFilterManager()) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
					
		<cfset var filterNodes = ArrayNew(1) />
		<cfset var filterParams = "" />
		<cfset var filterName = "" />
		<cfset var filterType = "" />
		<cfset var filter = "" />
		
		<cfset var paramNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var baseProxy = "" />
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for EventFilters --->
		<cfif NOT arguments.override>
			<cfset filterNodes = XMLSearch(arguments.configXML, "mach-ii/event-filters/event-filter") />
		<cfelse>
			<cfset filterNodes = XMLSearch(arguments.configXML, ".//event-filters/event-filter") />
		</cfif>
		
		<!--- Setup up each EventFilter --->
		<cfloop from="1" to="#ArrayLen(filterNodes)#" index="i">
			<cfset filterName = filterNodes[i].xmlAttributes["name"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(filterNodes[i].xmlAttributes, "overrideAction")>
				<cfif filterNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeFilter(filterName) />
				<cfelseif filterNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(filterNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = filterNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = filterName />
					</cfif>
					
					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isFilterDefined(mapping)>
						<cfthrow type="MachII.framework.overrideFilterNotDefined"
							message="An filter named '#mapping#' cannot be found in the parent event filter manager for the override named '#filterName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>
					
					<cfset addFilter(filterName, getParent().getFilter(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<cfset filterType = filterNodes[i].xmlAttributes["type"] />
			
				<!--- Set the EventFilter's parameters. --->
				<cfset filterParams = StructNew() />
				
				<!--- For each filter, parse all the parameters --->
				<cfif StructKeyExists(filterNodes[i], "parameters")>
					<cfset paramNodes = filterNodes[i].parameters.xmlChildren />
					<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
						<cfset paramName = paramNodes[j].xmlAttributes["name"] />
						<cftry>
							<cfset paramValue = utils.recurseComplexValues(paramNodes[j]) />
							<cfcatch type="any">
								<cfthrow type="MachII.framework.InvalidParameterXml"
									message="Xml parsing error for the parameter named '#paramName#' for event-filter '#filterName#' in module '#getAppManager().getModuleName()#'." />
							</cfcatch>
						</cftry>
						<cfset filterParams[paramName] = paramValue />
					</cfloop>
				</cfif>
				
				<cftry>
					<!--- Do not method chain the init() on the instantiation
						or objects that have their init() overridden will
						cause the variable the object is assigned to will 
						be deleted if init() returns void --->
					<cfset filter = CreateObject("component", filterType) />
					<cfset filter.init(getAppManager(), filterParams) />

					<cfcatch type="any">
						<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ filterType>
							<cfthrow type="MachII.framework.CannotFindEventFilter"
								message="Cannot find a CFC with the type of '#filterType#' for the event-filter named '#filterName#' in module named '#getAppManager().getModuleName()#'."
								detail="Please check that a event-filter exists and that there is not a misconfiguration in the XML configuration file." />
						<cfelse>
							<cfthrow type="MachII.framework.EventFilterSyntaxException"
								message="Mach-II could not register an event-filter with type of '#filterType#' for the event-filter named '#filterName#' in module named '#getAppManager().getModuleName()#'."
								detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
						</cfif>
					</cfcatch>
				</cftry>

				<cfset baseProxy = CreateObject("component",  "MachII.framework.BaseProxy").init(filter, filterType, filterParams) />
				<cfset filter.setProxy(baseProxy) />
				
				<cfset addFilter(filterName, filter, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered EventFilters.">
		
		<cfset var appManager = getAppManager() />
		<cfset var aFilter = 0 />
		<cfset var i = 0 />
		
		<cfloop collection="#variables.filterProxies#" item="i">
			<cfset aFilter = variables.filterProxies[i].getObject() />
			<cfset appManager.onObjectReload(aFilter) />
			<cfset aFilter.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Performs deconfiguration logic.">
		
		<cfset var aFilter = 0 />
		<cfset var i = 0 />
		
		<cfloop collection="#variables.filterProxies#" item="i">
			<cfset aFilter = variables.filterProxies[i].getObject() />
			<cfset aFilter.deconfigure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addFilter" access="public" returntype="void" output="false"
		hint="Registers an EventFilter by name.">
		<cfargument name="filterName" type="string" required="true" />
		<cfargument name="filter" type="MachII.framework.EventFilter" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isFilterDefined(arguments.filterName)>
			<cfthrow type="MachII.framework.FilterAlreadyDefined"
				message="An EventFilter with name '#arguments.filterName#' is already registered." />
		<cfelse>
			<cfset variables.filterProxies[arguments.filterName] = arguments.filter.getProxy() />
		</cfif>
	</cffunction>
	
	<cffunction name="getFilter" access="public" returntype="MachII.framework.EventFilter" output="false">
		<cfargument name="filterName" type="string" required="true" />
		
		<cfif isFilterDefined(arguments.filterName)>
			<cfreturn variables.filterProxies[arguments.filterName].getObject() />
		<cfelseif IsObject(getParent()) AND getParent().isFilterDefined(arguments.filterName)>
			<cfreturn getParent().getFilter(arguments.filterName) />
		<cfelse>
			<cfthrow type="MachII.framework.FilterNotDefined" 
				message="Filter with name '#arguments.filterName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="removeFilter" access="public" returntype="void" output="false"
		hint="Removes a filter. Does NOT remove from a parent.">
		<cfargument name="filterName" type="string" required="true" />
		<cfset StructDelete(variables.filterProxies, arguments.filterName, false) />
	</cffunction>
	
	<cffunction name="isFilterDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a filter is defined in this event filter manager. Does NOT check the parent.">
		<cfargument name="filterName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.filterProxies, arguments.filterName) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getFilterNames" access="public" returntype="array" output="false"
		hint="Returns an array of filter names.">
		<cfreturn StructKeyArray(variables.filterProxies) />
	</cffunction>
	
	<cffunction name="reloadFilter" access="public" returntype="void" output="false"
		hint="Reloads an event-filter.">
		<cfargument name="filterName" type="string" required="true" />
		
		<cfset var newFilter = "" />
		<cfset var currentFilter = getFilter(arguments.filterName) />
		<cfset var baseProxy = currentFilter.getProxy() />
		
		<!--- Setup the Filter --->
		<cftry>
			<!--- Do not method chain the init() on the instantiation
				or objects that have their init() overridden will
				cause the variable the object is assigned to will 
				be deleted if init() returns void --->
			<cfset newFilter = CreateObject("component", baseProxy.getType()) />
			<cfset newFilter.init(getAppManager(), baseProxy.getOriginalParameters()) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ baseProxy.getType()>
					<cfthrow type="MachII.framework.CannotFindEventFilter"
						message="Cannot find a CFC with the type of '#baseProxy.getType()#' for the event-filter named '#arguments.filterName#' in module named '#getAppManager().getModuleName()#'."
						detail="Please check that a event-filter exists and that there is not a misconfiguration in the XML configuration file." />
				<cfelse>
					<cfthrow type="MachII.framework.EventFilterSyntaxException"
						message="Mach-II could not register an event-filter with type of '#baseProxy.getType()#' for the event-filter named '#arguments.filterName#' in module named '#getAppManager().getModuleName()#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfif>
			</cfcatch>
		</cftry>

		<!--- Run deconfigure in the current Filter 
			which must take place before configure is
			run in the new Filter --->
		<cfset currentFilter.deconfigure() />
		
		<!--- Continue setup on the Filter --->
		<cfset baseProxy.setObject(newFilter) />
		<cfset newFilter.setProxy(baseProxy) />
		
		<!--- Configure the Filter --->
		<cfset getAppManager().onObjectReload(newFilter) />
		<cfset newFilter.configure() />

		<!--- Add the Filter to the manager --->
		<cfset addFilter(arguments.filterName, newFilter, true) />
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
		<cfargument name="parentFilterManager" type="MachII.framework.EventFilterManager" required="true" />
		<cfset variables.parentFilterManager = arguments.parentFilterManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent FilterManager instance this FilterManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentFilterManager />
	</cffunction>
	
</cfcomponent>