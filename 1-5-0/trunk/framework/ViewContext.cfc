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
$Id: ViewContext.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Notes:
- Fixed direct calls to propertyManager variables by adding the appropriate accessors. (pfarrell)
--->
<cfcomponent 
	displayname="ViewContext"
	output="false"
	hint="Handles view display for an EventContext.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.propertyManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewContext" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setPropertyManager(getAppManager().getPropertyManager()) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="displayView" access="public" returntype="void" output="true"
		hint="Displays a view by view name and peforms contentKey, contentArg and append functions.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The current Event object." />
		<cfargument name="viewName" type="string" required="true"
			hint="The view name to display." />
		<cfargument name="contentKey" type="string" required="false" default=""
			hint="The contentKey name if defined." />
		<cfargument name="contentArg" type="string" required="false" default=""
			hint="The contentArg name if defined." />
		<cfargument name="append" type="boolean" required="false" default="false"
			hint="Directive to append event." />	
		
		<cfset var viewPath = getFullPath(arguments.viewName) />
		<cfset var viewContent = "" />
		<cfset request.event = arguments.event />

		<cfif arguments.contentKey NEQ ''>
			<cfsavecontent variable="viewContent">
				<cfinclude template="#viewPath#" />
			</cfsavecontent>
			<cfif arguments.append AND IsDefined(arguments.contentKey)>
				<cfset viewContent = Evaluate(arguments.contentKey) & viewContent />
			</cfif>
			<cfset setVariable(arguments.contentKey, viewContent) />
		</cfif>
		
		<cfif arguments.contentArg NEQ ''>
			<cfsavecontent variable="viewContent">
				<cfinclude template="#viewPath#" />
			</cfsavecontent>
			<cfif arguments.append>
				<cfset viewContent = arguments.event.getArg(arguments.contentArg, "") & viewContent />
			</cfif>
			<cfset arguments.event.setArg(arguments.contentArg, viewContent) />
		</cfif>
		
		<cfif arguments.contentKey EQ '' AND arguments.contentArg EQ ''>
			<cfinclude template="#viewPath#" />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getFullPath" access="private" returntype="string" output="false"
		hint="Gets the full path of a view by view name from the view manager.">
		<cfargument name="viewName" type="string" required="true" />
		<cfset var viewPath = getAppManager().getViewManager().getViewPath(arguments.viewName) />
		
		<cfreturn getAppRoot() & viewPath />
	</cffunction>
	
	<cffunction name="getAppRoot" access="private" returntype="string" output="false"
		hint="Gets the application root from the Mach-II properties.">
		<cfreturn getAppManager().getPropertyManager().getProperty('applicationRoot') />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this ViewContext belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the AppManager instance this ViewContext belongs to.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setPropertyManager" access="private" returntype="void" output="false"
		hint="Sets the components PropertyManager instance.">
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true"
			hint="The PropertyManager instance to set." />
		<cfset variables.propertyManager = arguments.propertyManager />
	</cffunction>
	<cffunction name="getPropertyManager" access="package" returntype="MachII.framework.PropertyManager" output="false"
		hint="Gets the components PropertyManager instance.">
		<cfreturn variables.propertyManager />
	</cffunction>	

	<cffunction name="setProperty" access="public" returntype="any" output="false"
		hint="Sets the specified property - this is just a shortcut for getAppManager().getPropertyManager().setProperty()">
		<cfargument name="propertyName" type="string" required="yes"
			hint="The name of the property to set." />
		<cfargument name="propertyValue" type="any" required="yes" 
			hint="The value to store in the property." />
		<cfreturn getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>	
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getAppManager().getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="yes"
			hint="The name of the property to return." />
		<cfreturn getPropertyManager().getProperty(arguments.propertyName) />
	</cffunction>

</cfcomponent>