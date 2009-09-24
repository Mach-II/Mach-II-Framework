<!---
License:
Copyright 2009 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
Connects Mach-II managed components for use in ColdSpring.

Define the connector:
<bean id="utilityConnector"
	class="MachII.util.UtilityConnector"/>

Get the LogFactory:
<bean id="logFactory"
	factory-bean="utilityConnector"
	factory-method="getLogFactory" />

Using the LogFactory:
<bean id="someBean"
	type="dot.path.to.SomeBean">
	<property name="logFactory"><ref bean="logFactory"/></property>
</bean>

Get the CacheStrategyManager:
<bean id="cacheStrategyManager"
	factory-bean="utilityConnector"
	factory-method="getCacheStrategyManager" />

Using the CacheStrategyManager:
<bean id="someBean"
	type="dot.path.to.SomeBean">
	<property name="cacheStrategyManager"><ref bean="cacheStrategyManager"/></property>
</bean>

Do not inject the UtilityConnector into beans, use the 'factory' like methods instead.
--->
<cfcomponent
	displayname="UtilityConnector"
	output="false"
	hint="Connects Mach-II managed components for use in ColdSpring.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="UtilityConnector" output="false"
		hint="Initializes the connector.">
		
		<!--- Use reference placed by ColdspringProperty when framework is loading --->
		<cfif StructKeyExists(request, "_MachIIAppManager")>
			<cfset setAppManager(request._MachIIAppManager) />
		<cfelse>
			<cfthrow type="MachII.util.UtilityConnector"
				message="Cannot find the temporary AppManager reference in request._MachIIAppManager."
				detail="Please be sure that you are using the ColdspringProperty located in 'MachII.properties.ColdspringProperty'." />
		</cfif>

		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getEnvironmentName" access="public" returntype="string" output="false"
		hint="Gets the environment name.">
		<cfreturn getAppManager().getEnvironmentName() />
	</cffunction>
	
	<cffunction name="getEnvironmentGroup" access="public" returntype="string" output="false"
		hint="Gets the environment group.">
		<cfreturn getAppManager().getEnvironmentGroup() />
	</cffunction>
	
	<cffunction name="getLogFactory" access="public" returntype="MachII.logging.LogFactory" output="false"
		hint="Gets the LogFactory.">
		<cfreturn getAppManager().getLogFactory() />
	</cffunction>
	
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hints="Returns a log with the specified channel.">
		<cfargument name="channelName" type="string" required="true"
			hint="Channel to log. Usually the dot path to the CFC." />
		<cfreturn getLogFactory.getLog(arguments.channelName) />
	</cffunction>

	<cffunction name="getCacheStrategyManager" access="public" returntype="MachII.caching.CacheStrategyManager" output="false"
		hint="Gets the CacheStrategyManager.">
		<cfreturn getAppManager().getCacheManager().getCacheStrategyManager() />
	</cffunction>
	
	<cffunction name="getCacheStrategyByName" access="public" returntype="MachII.caching.strategies.AbstractCacheStrategy" output="false"
		hint="Gets a cache strategy with the specified name.">
		<cfargument name="name" type="string" required="true"
			hint="Name of the cache strategy to get." />
		<cfargument name="checkParent" type="boolean" required="false" default="false"
			hint="Flag to check parent strategy manager." />
		<cfreturn getCacheStrategyManager().getCacheStrategyByName(arguments.name, arguments.checkParent) />
	</cffunction>
	
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default="#getDefaultUrlBase()#"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		
		<cfset var builtUrl = "" />
		<cfset var queryString = "" />
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var value = "" />
		<cfset var i = "" />
		<cfset var keyList = StructKeyList(params) />
		<cfset var seriesDelimiter = getSeriesDelimiter() />
		<cfset var pairDelimiter = getPairDelimiter() />
		<cfset var parseSes = getParseSes() />

		<!--- Nested the appending of the event parameter inside the next block
			Moving it causes redirect commands with just urls to wrongly append
			the event parameter on the end of the url --->

		<!--- Attach the module/event name if defined --->
		<cfif Len(arguments.moduleName) AND Len(arguments.eventName)>
			<!--- Attach event parameter only if it not supposed to be excluded --->
			<cfif NOT getUrlExcludeEventParameter() OR isQueryStringUrls()>
				<cfset queryString = getEventParameter() & pairDelimiter />
			</cfif>
			<cfset queryString = queryString & arguments.moduleName & getModuleDelimiter() & arguments.eventName />
		<cfelseif NOT Len(arguments.moduleName) AND Len(arguments.eventName)>
			<!--- Attach event parameter only if it not supposed to be excluded --->
			<cfif NOT getUrlExcludeEventParameter() OR isQueryStringUrls()>
				<cfset queryString = getEventParameter() & pairDelimiter />
			</cfif>
			<cfset queryString = queryString & arguments.eventName />
		</cfif>
		
		<!--- Sort the list of url args to keep them in a consistent order --->
		<cfset keyList = ListSort(keyList, "textnocase") />
		
		<!--- Attach each additional arguments if it exists and is a simple value --->
		<cfloop list="#keyList#" index="i">
			<cfif IsSimpleValue(params[i])>
				<!--- Encode all ';' to 'U+03B' (unicode) which is part of the fix for the path info truncation bug #78782 in Adobe ColdFusion --->
				<cfif parseSes>
					<cfset params[i] = Replace(params[i], ";", "U_03B", "all") />
				</cfif>
				<cfif NOT Len(params[i]) AND seriesDelimiter EQ pairDelimiter AND parseSes>
					<cfset params[i] = "_-_NULL_-_" />
				</cfif>
				<cfset queryString = queryString & seriesDelimiter & i & pairDelimiter & URLEncodedFormat(params[i]) />
			</cfif>
		</cfloop>
		
		<!--- Prepend the urlBase and add trailing series delimiter --->
		<cfif Len(queryString)>
			<cfset builtUrl = arguments.urlBase & getQueryStringDelimiter() & queryString />
			<cfif seriesDelimiter NEQ "&">
				<cfset builtUrl = builtUrl & seriesDelimiter />
			</cfif>
		<cfelse>
			<cfset builtUrl = arguments.urlBase />
		</cfif>
		
		<cfreturn builtUrl />
	</cffunction>
	
	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name or Url alias of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="queryStringParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of query string parameters to append to end of the route." />
		<cfargument name="urlBase" type="string" required="false" default="#getDefaultUrlBase()#"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		
		<cfset var params = getUtils().parseAttributesIntoStruct(arguments.urlParameters) />
		<cfset var parsedQueryStringParams = getUtils().parseAttributesIntoStruct(arguments.queryStringParameters) />
		<cfset var route = getRoute(arguments.routeName) />	
		
		<cfreturn route.buildRouteUrl(params, parsedQueryStringParams, arguments.urlBase, getSeriesDelimiter(), getQueryStringDelimiter()) />
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
	
</cfcomponent>