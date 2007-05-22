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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.5.0
--->
<cfcomponent 
	displayname="ViewManager"
	output="false"
	hint="Manages registered views for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.viewPaths = StructNew() />
	<cfset variables.parentViewManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentViewManager" type="any" required="false" default=""
			hint="Optional argument for a parent view manager. If there isn't one default to empty string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif isObject(arguments.parentViewManager)>
			<cfset setParent(arguments.parentViewManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
				
		<cfset var viewNodes = "" />
		<cfset var name = "" />
		<cfset var page = "" />
		<cfset var hasParent = isObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		
		<!--- Search for Page-Views --->
		<cfif NOT arguments.override>
			<cfset viewNodes = XMLSearch(arguments.configXML, "mach-ii/page-views/page-view") />
		<cfelse>
			<cfset viewNodes = XMLSearch(arguments.configXML, ".//page-views/page-view") />
		</cfif>
		
		<!--- Setup up each Page-View --->
		<cfloop from="1" to="#ArrayLen(viewNodes)#" index="i">
			<cfset name = viewNodes[i].xmlAttributes["name"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(viewNodes[i].xmlAttributes, "overrideAction")>
				<cfif viewNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset StructDelete(variables.viewPaths, name, false) />
				<cfelseif viewNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(viewNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = viewNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = name />
					</cfif>
					
					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isViewDefined(mapping)>
						<cfthrow type="MachII.framework.overrideViewNotDefined"
							message="An view named '#mapping#' cannot be found in the parent view manager for the override named '#name#' in module '#getAppManager().getModuleName()#'." />
					</cfif>
					
					<cfset variables.viewPaths[name] = mapping />
				</cfif>
			<cfelse>
				<cfset page = viewNodes[i].xmlAttributes["page"] />
			
				<cfset variables.viewPaths[name] = page />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Prepares the manager for use.">
		<!--- DO NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getViewPath" access="public" returntype="string" output="false"
		hint="Gets the view path.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view path to get." />
		
		<cfif isViewDefined(arguments.viewName)>
			<cfreturn getAppManager().getPropertyManager().getProperty('applicationRoot') & variables.viewPaths[arguments.viewName] />
		<cfelseif isObject(getParent()) AND getParent().isViewDefined(arguments.viewName)>
			<cfreturn getParent().getViewPath(arguments.viewName) />
		<cfelse>
			<cfthrow type="MachII.framework.ViewNotDefined" 
				message="View with name '#arguments.viewName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="isViewDefined" access="public" returntype="boolean" output="false"
		hint="Checks if the view is defined.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view to check." />
		<cfreturn StructKeyExists(variables.viewPaths, arguments.viewName) />
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
		hint="Returns the parent ViewManager instance this ViewManager belongs to.">
		<cfargument name="parentViewManager" type="MachII.framework.ViewManager" required="true" />
		<cfset variables.parentViewManager = arguments.parentViewManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent ViewManager instance this ViewManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentViewManager />
	</cffunction>
	
</cfcomponent>