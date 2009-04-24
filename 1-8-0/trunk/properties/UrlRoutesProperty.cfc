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
         <key name="requiredParameters" value="productId,displayType:fancy" /><!-- You can also use a array here -->
		 <key name="optionalParameters" value="key" /><!-- You can also use a array here -->
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
	hint="Sets up one or more routes which are configurable search engine friendly url schemes.">

	<!---
	PROPERTIES
	--->
	<cfset variables.routes = StructNew() />
	<cfset variables.routeNames = CreateObject("java", "java.util.HashSet").init() />
	<cfset variables.routeAliases = CreateObject("java", "java.util.HashSet").init() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property by building the routes.">
		
		<cfset var parameterNames = getParameterNames() />
		<cfset var parameterName = "" />
		<cfset var parameter = 0 />
		<cfset var i = 0 />
		<cfset var route = 0 />
		
		<cfloop list="#parameterNames#" index="parameterName">
			<cfset route = CreateObject("component", "MachII.framework.UrlRoute").init(parameterName) />
			
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

			<cfif StructKeyExists(parameter, "requiredParameters")>
				<cfset route.setRequiredParameters(evaluateParameters(parameter.requiredParameters)) />
			</cfif>
			<cfif StructKeyExists(parameter, "optionalParameters")>
				<cfset route.setOptionalParameters(evaluateParameters(parameter.optionalParameters)) />
			</cfif>	
			
			<cfset addRoute(parameterName, route) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the property by un-registering routes and route aliases.">
		
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var names = "" />
		<cfset var aliases = "" />
		<cfset var i = 0 />
		
		<!--- Cleanup this property's routes --->
		<cfset names = variables.routeNames.toArray() />
		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<!--- Remove route --->
			<cfset requestManager.removeRoute(names[i]) />
		</cfloop>
		<cfset variables.routeNames.clear() />
		
		<cfset aliases = variables.routeAliases.toArray() />
		<cfloop from="1" to="#ArrayLen(aliases)#" index="i">
			<!--- Remove route alias --->
			<cfset requestManager.removeRouteAlias(aliases[i]) />
		</cfloop>
		<cfset variables.routeAliases.clear() />
		
	</cffunction>
	
	<cffunction name="evaluateParameters" access="private" returntype="string" output="false">
		<cfargument name="parameters" type="any" required="true" />
		
		<cfset var param = "" />
		<cfset var parsedParameters = "" />
		<cfset var i = 0 />
		
		<cfif isSimpleValue(arguments.parameters)>
			<cfloop list="#arguments.parameters#" index="param">
				<cfset parsedParameters = ListAppend(parsedParameters, parseParameter(param)) />
			</cfloop>
		<cfelseif isArray(arguments.parameters)>
			<!--- handle passing in an array of parameters --->
			<cfloop from="1" to="#ArrayLen(arguments.parameters)#" index="i">
				<cfset parsedParameters = ListAppend(parsedParameters, parseParameter(arguments.parameters[i])) />
			</cfloop>
		</cfif>
		
		<cfreturn parsedParameters />
	</cffunction>
	
	<cffunction name="parseParameter" access="private" returntype="string" output="false">
		<cfargument name="param" type="string" required="true" />
		
		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />
		<cfset var event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset var parsedParam = arguments.param />
		
		<cfif ListLen(parsedParam, ":") eq 2>
			<cfif expressionEvaluator.isExpression(ListGetAt(parsedParam, 2, ":"))>
				<cfset parsedParam = ListSetAt(parsedParam, 2, 
					expressionEvaluator.evaluateExpression(ListGetAt(parsedParam, 2, ":"), event, getAppManager().getPropertyManager()), ":") />
			</cfif>
		</cfif>
		
		<cfreturn parsedParam />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	<cffunction name="addRoute" access="public" returntype="void" output="false">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="route" type="MachII.framework.UrlRoute" required="true" />
		
		<!---
			Lists can be really slow if there are a lot of routes or aliases so a HashSet is used for names and aliases
			as it is consistent speed-wise as the dataset grows (see clearCache() in CacheHandler)
		--->
		
		<cfset variables.routeNames.add(arguments.routeName) />
		<cfif arguments.route.getUrlAlias() neq "">
			<cfset variables.routeAliases.add(arguments.route.getUrlAlias()) />
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