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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

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
	
	<cffunction name="setModuleName" access="private" returntype="void" output="false">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="public" returntype="string" output="false">
		<cfreturn variables.moduleName />
	</cffunction>
	
</cfcomponent>