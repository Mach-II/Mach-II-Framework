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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="BaseComponentTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.BaseComponent.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.baseComponent = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
			
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />
		
		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset propertyManager.setProperty("test1", "value1") />
		<cfset propertyManager.setProperty("test2", "value2") />
		<cfset appManager.setPropertyManager(propertyManager) />
					
		<cfset variables.baseComponent = CreateObject("component", "MachII.framework.BaseComponent") />
		<cfset variables.baseComponent.init(appManager) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testParameters" access="public" returntype="void" output="false"
		hint="Tests setParameters(), getParameters(), getParameter(), isParameterDefined() and getParameterNames(). Behind the scenes this test exercises bindValue() and setParameter().">
		
		<cfset var inputParameters = StructNew() />
		<cfset var outputParameters = StructNew() />
		
		<!--- Test for when whe scope prefix of "properties." is not required --->
		<cfset inputParameters.test1 = "${test1}" />
		<!--- Test for the "properites." scope prefix--->
		<cfset inputParameters.test2 = "${properties.test2}" />
		<!--- Test for straight up --->
		<cfset inputParameters.test3 = "value3" />
		
		<!--- Set / get the properties --->
		<cfset variables.baseComponent.setParameters(inputParameters) />
		<!--- Getting parameters will case the bindValue() to be called for each parameter key --->
		<cfset outputParameters = variables.baseComponent.getParameters() />
		
		<!--- Perform assertions from output of getParameters() `--->
		<cfset assertEquals(outputParameters.test1, "value1") />
		<cfset assertEquals(outputParameters.test2, "value2") />
		<cfset assertEquals(outputParameters.test3, "value3") />
		
		<!--- Perform assertions from getParameter() calls --->
		<cfset assertEquals(variables.baseComponent.getParameter("test1"), "value1") />
		<cfset assertEquals(variables.baseComponent.getParameter("test2"), "value2") />
		<cfset assertEquals(variables.baseComponent.getParameter("test3"), "value3") />
		
		<!--- Test isParameterDefined() --->
		<cfset assertTrue(variables.baseComponent.isParameterDefined("test1")) />
		<cfset assertTrue(NOT variables.baseComponent.isParameterDefined("doesNotExist")) />
		
		<!--- Test isParameterNames() --->
		<cfset assertTrue(ListLen(variables.baseComponent.getParameterNames()) EQ 3) />
	</cffunction>
	
</cfcomponent>