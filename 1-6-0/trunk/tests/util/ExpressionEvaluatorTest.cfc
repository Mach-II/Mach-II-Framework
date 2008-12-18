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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent 
	displayname="ExpressionEvaluatorTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.ExpressionEvaluator.">

	<!---
	PROPERTIES
	--->
	<cfset variables.expressionEvaluator = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.expressionEvaluator = CreateObject("component", "MachII.util.ExpressionEvaluator").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testEventArgExistsExpressionWithEvent" access="public" returntype="void" output="false">
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset event.setArg("argExists", "foobar") />
		<cfset event.setArg("dot.argExists", "foobar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.argExists}", event, propertyManager) />	
		<cfset assertTrue(result eq "foobar", "Event arg returned did not equal 'foobar'") />

		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.dot.argExists}", event, propertyManager) />
		<cfset assertTrue(result eq "foobar", "Event arg returned did not equal 'foobar'") />
	</cffunction>

	<cffunction name="testEventArgExistsExpressionWithProperty" access="public" returntype="void" output="false">
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset propertyManager.setProperty("argExists", "foobar") />
		<cfset propertyManager.setProperty("dot.argExists", "foobar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${properties.argExists}", event, propertyManager) />	
		<cfset assertTrue(result eq "foobar", "Property returned did not equal 'foobar'") />

		<cfset result = variables.expressionEvaluator.evaluateExpression("${properties.dot.argExists}", event, propertyManager) />
		<cfset assertTrue(result eq "foobar", "Property returned did not equal 'foobar'") />
	</cffunction>
	
	
	<cffunction name="testBooleanExpresion" access="public" returntype="void" output="false">
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset propertyManager.setProperty("foo", "bar") />
		<cfset event.setArg("foo", "bar") />
		<cfset event.setArg("boolean", 1) />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq properties.foo}", event, propertyManager) />	
		<cfset debug(result)>
		<cfset assertTrue(result, "Result of event.foo eq properties.foo was not true") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.boolean eq 1}", event, propertyManager) />	
		<cfset debug(result)>
		<cfset assertTrue(result, "Result of 'boolean' eq 1 was not true") />
				
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq 'bar'}", event, propertyManager) />	
		<cfset debug(result)>
		<cfset assertTrue(result, "Result of event.foo eq 'foo' was not true") />
			
		<cfset result = variables.expressionEvaluator.evaluateExpression("${'bar' eq event.foo}", event, propertyManager) />	
		<cfset debug(result)>
		<cfset assertTrue(result, "Result of 'foo' eq event.foo was not true") />
	</cffunction>
	
	<!---
	PROTECTED FUNTIONS - UTIL
	--->
	<cffunction name="getEvent" access="private" returntype="MachII.framework.Event" output="false">
		<cfreturn CreateObject("component", "MachII.framework.Event").init() />
	</cffunction>
	
	<cffunction name="getPropertyManager" access="private" returntype="MachII.framework.PropertyManager" output="false">
		<cfset var appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset var propertyManager = 0 />
		
		<cfset appManager.setUtils(CreateObject("component", "MachII.util.Utils").init()) />
		<cfset appManager.setLogFactory(CreateObject("component", "MachII.logging.LogFactory").init()) />
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		
		<cfreturn propertyManager />
	</cffunction>

</cfcomponent>