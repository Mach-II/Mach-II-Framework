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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="ViewManager"
	output="false"
	hint="Manages registered views for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentViewManager = "" />
	<cfset variables.viewData = StructNew() />
	<cfset variables.viewLoaders = ArrayNew(1) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getViewManager()) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
				
		<cfset var viewNodes = ArrayNew(1) />
		<cfset var name = "" />
		<cfset var viewData = StructNew() />

		<cfset var viewLoaderNodes = ArrayNew(1) />		
		<cfset var viewLoaderParams = StructNew() />
		<cfset var viewLoaderType = "" />
		<cfset var viewLoader = "" />
		
		<cfset var paramNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Search for Page-Views --->
		<cfif NOT arguments.override>
			<cfset viewNodes = XMLSearch(arguments.configXML, "mach-ii/page-views/page-view") />
		<cfelse>
			<cfset viewNodes = XMLSearch(arguments.configXML, ".//page-views/page-view") />
		</cfif>
		
		<!--- Setup each Page-View --->
		<cfloop from="1" to="#ArrayLen(viewNodes)#" index="i">
			<cfset name = viewNodes[i].xmlAttributes["name"] />
			
			<cfset viewData = StructNew() />
			<cfset viewData.appRoot = "" />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(viewNodes[i].xmlAttributes, "overrideAction")>
				<cfif viewNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset StructDelete(variables.viewData, name, false) />
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
					
					<cfset variables.viewData[name] = getParent().getView(mapping) />
				</cfif>
			<cfelse>
				<cfset viewData.page = viewNodes[i].xmlAttributes["page"] />
				
				<!--- Use a different appRoot if defined --->
				<cfif StructKeyExists(viewNodes[i].xmlAttributes, "useParentAppRoot") AND viewNodes[i].xmlAttributes["useParentAppRoot"]>
					<cfset viewData.appRootType = "parent" />
				<cfelse>
					<cfset viewData.appRootType = "local" />
				</cfif>
			
				<cfset variables.viewData[name] = viewData />
			</cfif>
		</cfloop>
		
		<!--- Search for View-Loaders --->
		<cfif NOT arguments.override>
			<cfset viewLoaderNodes = XMLSearch(arguments.configXML, "mach-ii/page-views/view-loader") />
		<cfelse>
			<cfset viewLoaderNodes = XMLSearch(arguments.configXML, ".//page-views/view-loader") />
		</cfif>
		
		<!--- Setup each View-Loader --->
		<cfloop from="1" to="#ArrayLen(viewLoaderNodes)#" index="i">
			<cfset viewLoaderType = viewLoaderNodes[i].xmlAttributes["type"] />
			
			<!--- View-Loaders do not support overrideAction --->
			
			<!--- Get the View-Loader's parameters --->
			<cfset viewLoaderParams = StructNew() />
			
			<!--- Parse all the parameters --->
			<cfif StructKeyExists(viewLoaderNodes[i], "parameters")>
				<cfset paramNodes = viewLoaderNodes[i].parameters.xmlChildren />
				<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
					<cfset paramName = paramNodes[j].xmlAttributes["name"] />						
					<cftry>
						<cfset paramValue = utils.recurseComplexValues(paramNodes[j]) />
						<cfcatch type="any">
							<cfthrow type="MachII.framework.InvalidParameterXml"
								message="Xml parsing error for the parameter named '#paramName#' for view-loader in module '#getAppManager().getModuleName()#'." />
						</cfcatch>
					</cftry>
					<cfset viewLoaderParams[paramName] = paramValue />
				</cfloop>
			</cfif>
		
			<!--- Setup the View-Loader --->
			<cftry>
				<!--- Do not method chain the init() on the instantiation
					or objects that have their init() overridden will
					cause the variable the object is assigned to will 
					be deleted if init() returns void --->
				<cfset viewLoader = CreateObject("component", viewLoaderType) />
				<cfset viewLoader.init(getAppManager(), viewLoaderParams) />
				
				<cfcatch type="any">
					<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ viewLoaderType>
						<cfthrow type="MachII.framework.CannotFindViewLoader"
							message="Cannot find a view-loader CFC with type of '#viewLoaderType#' for a view-loader in module named '#getAppManager().getModuleName()#'."
							detail="Please check that this view-loader exists and that there is not a misconfiguration in the XML configuration file." />
					<cfelse>
						<cfthrow type="MachII.framework.ViewLoaderSyntaxException"
							message="Mach-II could not register a view-loader with type of '#viewLoaderType#' for a view-loader in module named '#getAppManager().getModuleName()#'."
							detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
					</cfif>						
				</cfcatch>
			</cftry>
			
			<!--- Add the View-Loader to the manager --->
			<cfset ArrayAppend(variables.viewLoaders, viewLoader) />
		</cfloop>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Prepares the manager for use.">
		
		<cfset var viewLoaders = variables.viewLoaders />
		<cfset var views = StructNew() />
		<cfset var viewData = "" />
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var localAppRoot = getAppManager().getPropertyManager().getProperty("applicationRoot") />
		<cfset var parentAppRoot =  ""/>
		
		<!--- Get parent app root if in module  --->
		<cfif getAppManager().inModule()>
			<cfset parentAppRoot = getAppManager().getPropertyManager().getParent().getProperty("applicationRoot") />
		</cfif>
		
		<!--- Resolve app roots for local views --->
		<cfloop collection="#variables.viewData#" item="key">
			<cfset viewData = variables.viewData[key] />
			
			<cfif viewData.appRootType EQ "local">
				<cfset viewData.appRoot = localAppRoot />
			<cfelse>
				<cfset viewData.appRoot = parentAppRoot />
			</cfif>
		</cfloop>
		
		<!--- Configure and resolve view loaders --->
		<cfloop from="1" to="#ArrayLen(viewLoaders)#" index="i">
			<cfset viewLoaders[i].configure() />
			<cfset views = viewLoaders[i].discoverViews() />
			<cfset StructAppend(variables.viewData, views, false) />
		</cfloop>
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the manager for use.">
		
		<cfset var viewLoaders = variables.viewLoaders />
		<cfset var i = 0 />
		
		<!--- Deconfigureview loaders --->
		<cfloop from="1" to="#ArrayLen(viewLoaders)#" index="i">
			<cfset viewLoaders[i].deconfigure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getViewPath" access="public" returntype="string" output="false"
		hint="Gets a resolved view path by view name.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view path to get." />
		
		<cfset var viewData = getView(arguments.viewName) />
		
		<cfreturn viewData.appRoot & viewData.page />
	</cffunction>
	
	<cffunction name="getUnresolvedViewPath" access="public" returntype="string" output="false"
		hint="Gets a resolved view path by view name.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view path to get." />
		
		<cfset var viewData = getView(arguments.viewName) />
		
		<cfreturn viewData.page />
	</cffunction>
	
	<cffunction name="getView" access="public" returntype="struct" output="false"
		hint="Gets view data information. Checks parent if child manager.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view path to get." />
		
		<cfif isViewDefined(arguments.viewName)>
			<cfreturn variables.viewData[arguments.viewName] />
		<cfelseif IsObject(getParent())>
			<cfreturn getParent().getView(arguments.viewName) />
		<cfelse>
			<cfthrow type="MachII.framework.ViewNotDefined" 
				message="View with name '#arguments.viewName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="isViewDefined" access="public" returntype="boolean" output="false"
		hint="Checks if the view is defined.">
		<cfargument name="viewName" type="string" required="true"
			hint="Name of the view to check. Does not check parent ViewManager." />
		<cfreturn StructKeyExists(variables.viewData, arguments.viewName) />
	</cffunction>
	
	<cffunction name="getViewData" access="public" returntype="struct" output="false"
		hint="Gets the view data. Used for internal debugging purposes.">
		<cfreturn variables.viewData />
	</cffunction>
	
	<cffunction name="getViewLoaders" access="public" returntype="array" output="false"
		hint="Gets all view loader for this context.">
		<cfreturn variables.viewLoaders />
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