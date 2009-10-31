<<!---
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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="EventBeanCommandTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.commands.EventBeanCommand.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventBeanCommand = "" />
	<cfset variables.appManager = "" />
	<cfset variables.eventContext = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
			
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		<cfset var requestHandler= "" />
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />
		
		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset appManager.setPropertyManager(propertyManager) />
		<cfset setAppManager(appManager) />
		
		<!--- Setup a clean EventContext --->
		<cfset requestHandler = CreateObject("component", "MachII.framework.RequestHandler").init(
			appManager, "event", "form", ":", 10, "") />
		<cfset eventContext = CreateObject("component", "MachII.framework.EventContext").init(
			requestHandler, 
			CreateObject("component", "MachII.util.SizedQueue").init()) />
		<cfset setEventContext(eventContext) />
		
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- This method left intentionally blank --->
	</cffunction>
	
	<cffunction name="getAppManager" access="private" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	
	<cffunction name="getEventContext" access="private" returntype="MachII.framework.EventContext" output="false">
		<cfreturn variables.eventContext />
	</cffunction>
	<cffunction name="setEventContext" access="private" returntype="void" output="false">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfset variables.eventContext = arguments.eventContext />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testBeanAutoPopulate" access="public" returntype="void">
		<cfset var command = "" />
		<cfset var event = "" />
		<cfset var eventContext = getEventContext() />
		<cfset var user = "" />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(
			beanName="user", beanType="m2harness.model.User", beanFields="", ignoreFields="", 
			reinit=false, beanUtil=CreateObject("component", "MachII.util.BeanUtil").init(), autoPopulate=true) />
		<cfset command.setLog(getAppManager().getLogFactory().getLog("MachII.framework.commands.EventBeanCommand")) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		
		<cfset event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset event.setArg("firstname", "Kurt") />
		<cfset event.setArg("lastname", "Wiersma") />
		<cfset event.setArg("address.address1", "1234 Main Street") />
		<cfset event.setArg("address.country.name", "United States") />
		<cfset event.setArg("address.country.code", "USA") />
		
		<cfset eventContext.setup(getAppManager(), event) />
		
		<cfset command.execute(event, eventContext) />
		
		<cfset user = event.getArg("user") />
		<cfset debug(user) />
		
		<cfset assertTrue(user.getFirstName() eq "Kurt", "user.getFirstName() should return 'Kurt'") />
		<cfset assertTrue(user.getAddress().getAddress1() eq "1234 Main Street", "address1 should be '1234 Main Street'") />
		<cfset assertTrue(user.getAddress().getCountry().getCode() eq "USA", "country.code should be 'USA'") />
	</cffunction>

</cfcomponent>