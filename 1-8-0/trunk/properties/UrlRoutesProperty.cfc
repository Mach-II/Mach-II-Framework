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
	<parameter name="rewriteConfigFile">
		<!-- Creates file with Apache Rewrite rules for the routes so you can exclude index.cfm -->
		<struct>
			<key name="filePath" value=".htaccess" />
		</struct>
	</parameter>
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
	<cfset variables.routeNames = CreateObject("java", "java.util.HashSet").init() />
	<cfset variables.dummyEvent = CreateObject("component", "MachII.framework.Event").init() />
	<cfset variables.rewriteConfigFile = "" />
	
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
		<cfset var currentModuleName = getAppManager().getModuleName() />
		
		<cfloop list="#parameterNames#" index="parameterName">
			
			<cfset parameter = getParameter(parameterName) />
			
			<cfif parameterName NEQ "rewriteConfigFile">
				
				<cfset route = CreateObject("component", "MachII.framework.UrlRoute").init(parameterName) />
				
				<cfset getAssert().isTrue(StructKeyExists(parameter, "event")
						, "You must provide a struct key for 'event' for route '#parameterName#'") />
				
				<cfset route.setEventName(parameter.event) />
				
				<cfif StructKeyExists(parameter, "module")>
					<cfset route.setModuleName(parameter.module) />
				<cfelse>
					<cfset route.setModuleName(currentModuleName) />
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
			<cfelse>
				<cfif StructKeyExists(parameter, "rewriteFileOn")>
					<cfif parameter.rewriteFileOn>
						<cfif StructKeyExists(parameter, "filePath")>
							<cfset setRewriteConfigFile(parameter.filePath) />
						<cfelse>
							<cfif Len(currentModuleName)>
								<cfset setRewriteConfigFile("rewriteRules_#currentModuleName#.cfm") />
							<cfelse>
								<cfset setRewriteConfigFile("rewriteRules_base.cfm") />
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfif Len(getRewriteConfigFile())>
			<cfset createRewriteConfigFile() />
		</cfif>
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the property by un-registering routes and route aliases.">
		
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var names = "" />
		<cfset var aliases = "" />
		<cfset var i = 0 />
		
		<!--- Removes this property's routes --->
		<cfset names = variables.routeNames.toArray() />
		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<!--- Remove route --->
			<cfset requestManager.removeRoute(names[i]) />
		</cfloop>
		<cfset variables.routeNames.clear() />
	</cffunction>
	
	<!---
	PRPOTECTED FUNCTIONS
	--->
	<cffunction name="evaluateParameters" access="private" returntype="array" output="false"
		hint="Evaluates parameters (required and optional) and returns an evaluated array.">
		<cfargument name="parameters" type="any" required="true"
			hint="A list or array of parameters to evaluate." />
		
		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />
		
		<!--- Convert a list to array (and trim the list just in case) --->
		<cfif isSimpleValue(arguments.parameters)>
			<cfset arguments.parameters = ListToArray(utils.trimList(arguments.parameters)) />
		</cfif>

		<!--- Parse the array of parameters --->
		<cfloop from="1" to="#ArrayLen(arguments.parameters)#" index="i">
			<cfset arguments.parameters[i] = parseParameter(arguments.parameters[i]) />
		</cfloop>
		
		<cfreturn arguments.parameters />
	</cffunction>
	
	<cffunction name="parseParameter" access="private" returntype="string" output="false">
		<cfargument name="param" type="string" required="true" />
		
		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />
		<cfset var parsedParam = arguments.param />
		
		<cfif ListLen(parsedParam, ":") EQ 2>
			<cfif expressionEvaluator.isExpression(ListGetAt(parsedParam, 2, ":"))>
				<cfset parsedParam = ListSetAt(parsedParam, 2, 
					expressionEvaluator.evaluateExpression(ListGetAt(parsedParam, 2, ":"), variables.dummyEvent, getAppManager().getPropertyManager()), ":") />
			</cfif>
		</cfif>
		
		<cfreturn parsedParam />
	</cffunction>
	
	<cffunction name="createRewriteConfigFile" access="private" returntype="void" output="false"
		hint="Creates a rewrite config file.">
		
		<cfset var lf = Chr(10) />
		<cfset var configFilePath = ExpandPath(getRewriteConfigFile()) />
		<cfset var contents = CreateObject("java", "java.lang.StringBuffer") />
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var appRoot = getAppManager().getPropertyManager().getProperty("urlBase") />
		<cfset var moduleName = getAppManager().getModuleName() />
		<cfset var names = variables.routeNames.toArray() />
		<cfset var route = 0 />
		<cfset var i = 0 />

		<!--- Clean up the appRoot --->
		<cfif Right(appRoot, 1) neq "/">
			<cfset appRoot = appRoot & "/" />
		</cfif>
		
		<!--- Build rewrite rules --->
		<cfset contents.append('#### <cfsetting enabledCfoutputOnly="true"/>' & lf) />
		<cfset contents.append("#### Date Generated: #dateFormat(now(), "m/d/yyyy")# #timeFormat(now(), "h:mm tt")#" & lf) />
		<cfset contents.append("#### Module Name: #moduleName#" & lf) />
		<cfset contents.append(lf) />
		<cfset contents.append("RewriteEngine on" & lf) />

		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<cfset route = requestManager.getRoute(names[i]) />
			<cfset contents.append("RewriteRule ^" & appRoot & route.getUrlAlias() & "/(.*)$ " & appRoot & "index.cfm/" & route.getUrlAlias() & "/$1 [PT,L]" & lf) />
		</cfloop>
		
		<cfset contents.append(lf) />
		<cfset contents.append('#### <cfsetting enabledCfoutputOnly="false"/>' & lf) />
		
		<!--- Write to file --->
		<cftry>
			<cffile action="write" 
				file="#configFilePath#" 
				output="#contents.toString()#" 
				fixnewline="yes" />
			<cfcatch type="all">
				<cfthrow type="MachII.properties.UrlRoutesProperty.RulesWritePermissions"
					message="Cannot write rewrite rules file to '#configFilePath#'. Does your CFML engine have write permissions to this directory?"
					detail="Original message: #cfcatch.message#" />
			</cfcatch>
		</cftry>
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
		
		<cfset getAppManager().getRequestManager().addRoute(arguments.routeName, arguments.route) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->

	<!---
	ACCESSORS
	--->
	<cffunction name="setRewriteConfigFile" access="private" returntype="void" output="false">
		<cfargument name="rewriteConfigFile" type="string" required="true" />
		<cfset variables.rewriteConfigFile = arguments.rewriteConfigFile />
	</cffunction>
	<cffunction name="getRewriteConfigFile" access="public" returntype="string" output="false">
		<cfreturn variables.rewriteConfigFile />
	</cffunction>
	
</cfcomponent>