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
<property name="routes" type="MachII.properties.FriendlyRoutesProperty">
  <parameters>
    <parameter name="product">
      <struct>
         <key name="event" value="showProduct" />
         <key name="argumentOrder" value="productId,displayType" />
     </struct>
    </parameter>
  </parameters>
</property>

Then in your view you can call the new buildRoute() method which, like buildURL(), handling creating the actual URL string 
for you based the route configuration.

#BuildRoute("product", "productId=#event.getArg('productId')#|displayType=fancy")#

BuildRoute then produces the following URL:

index.cfm/product/A12345/fancy/
--->
<cfcomponent 
	displayname="FriendlyRoutesProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets up one or more route which are configurable search engine friendly url schemes.">

	<!---
	PROPERTIES
	--->
	<cfset variables.routes = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var parameterNames = getParameterNames() />
		<cfset var parameterName = "" />
		<cfset var parameter = 0 />
		<cfset var i = 0 />
		<cfset var route = structNew() />
		
		<cfloop list="#parameterNames#" index="parameterName">
			<cfset parameter = getParameter(parameterName) />
			<cfset getAssert().isTrue(StructKeyExists(parameter, "event"), 
				"You must provide a struct key for 'event' for route '#parameterName#'") />	
			<cfset route.event = parameter.event />
			<cfif StructKeyExists(parameter, "argumentOrder")>
				<cfset route.eventargs = parameter.argumentOrder />
			</cfif>	
			<cfset addRoute(parameterName, route) />
		</cfloop>
		
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	<cffunction name="addRoute" access="public" returntype="void" output="false">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="route" type="struct" required="true" />
		
		<cfset getAppManager().addRoute(arguments.routeName, arguments.route) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->

	<!---
	ACCESSORS
	--->
	
	
</cfcomponent>