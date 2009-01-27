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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:


Usage:
<property name="routes" type="MachII.properties.UrlRoutesProperty">
  <parameters>
    <parameter name="product">
      <struct>
         <key name="event" value="showProduct" />
         <key name="requiredArguments" value="productId,displayType:fancy" />
		 <key name="optionalArguments" value="key" />
     </struct>
    </parameter>
  </parameters>
</property>

Then in your view you can call the new buildRoute() method which, like buildURL(), handling creating the actual URL string 
for you based the route configuration.

#BuildRouteUrl("product", "productId=#event.getArg('productId')#|displayType=fancy")#

BuildRoute then produces the following URL:

index.cfm/product/A12345/fancy/
--->
<cfcomponent 
	displayname="UrlRoutesProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets up one or more route which are configurable search engine friendly url schemes.">

	<!---
	PROPERTIES
	--->
	<cfset variables.routes = StructNew() />
	<cfset variables.routeNames = "" />
	<cfset variables.routeAliases = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var parameterNames = getParameterNames() />
		<cfset var parameterName = "" />
		<cfset var parameter = 0 />
		<cfset var i = 0 />
		<cfset var route = 0 />
		
		<cfloop list="#parameterNames#" index="parameterName">
			<cfset route = createObject("component", "MachII.framework.UrlRoute").init() />
			<cfset parameter = getParameter(parameterName) />
			<cfset getAssert().isTrue(StructKeyExists(parameter, "event"), 
				"You must provide a struct key for 'event' for route '#parameterName#'") />	
			<cfset route.setEventName(parameter.event) />
			<cfif StructKeyExists(parameter, "module")>
				<cfset route.setModuleName(parameter.module) />
			</cfif>
			<cfif StructKeyExists(parameter, "urlAlias")>
				<cfset route.setUrlAlias(parameter.urlAlias) />
			</cfif>
			<cfif StructKeyExists(parameter, "requiredArguments")>
				<cfset route.setRequiredArguments(parameter.requiredArguments) />
			</cfif>
			<cfif StructKeyExists(parameter, "optionalArguments")>
				<cfset route.setOptionalArguments(parameter.optionalArguments) />
			</cfif>	
			<cfset addRoute(parameterName, route) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false">
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var name = "" />
		
		<!--- Cleanup this property's routes --->
		<cfloop list="#variables.routeNames#" index="name">
			<!--- Remove route --->
			<cfset requestManager.removeRoute(name) />
		</cfloop>
		
		<cfloop list="#variables.routeAliases#" index="name">
			<!--- Remove route alias --->
			<cfset requestManager.removeRouteAlias(name) />
		</cfloop>
		
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	<cffunction name="addRoute" access="public" returntype="void" output="false">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="route" type="MachII.framework.UrlRoute" required="true" />
		
		<cfset variables.routeNames = ListAppend(variables.routeNames, arguments.routeName) />
		<cfif arguments.route.getUrlAlias() neq "">
			<cfset variables.routeAliases = ListAppend(variables.routeAliases, arguments.route.getUrlAlias()) />
		</cfif>
		
		<cfset getAppManager().getRequestManager().addRoute(arguments.routeName, arguments.route) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->

	<!---
	ACCESSORS
	--->
	
	
</cfcomponent>