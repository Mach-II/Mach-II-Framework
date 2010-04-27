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
		<cfargument name="urlParameters" type="any" required="false"
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildUrl(argumentcollection=arguments) />
	</cffunction>
	
	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="routeName" type="string" required="true"
			hint="Name or Url alias of the route to build the url with." />
		<cfargument name="urlParameters" type="any" required="false"
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="queryStringParameters" type="any" required="false"
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of query string parameters to append to end of the route." />
		<cfargument name="urlBase" type="string" required="false"
			hint="Base of the url. Defaults to the value of the urlBase property." />
		<cfreturn getAppManager().getRequestManager().buildRouteUrl(argumentcollection=arguments) />
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