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
	<cffunction name="testEventArgDefaultExpression" access="public" returntype="void" output="false"
		hint="Tests non-existent event-args with expression variable defaults.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.argDoesntExist:0}", event, propertyManager) />	
		<cfset assertTrue(result eq "0", "Event arg returned did not equal '0'") />

		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.argDoesntExist:test}", event, propertyManager) />
		<cfset assertTrue(result eq "test", "Event arg returned did not equal 'test'") />
	</cffunction>

	<cffunction name="testEventArgExistsExpression" access="public" returntype="void" output="false"
		hint="Tests existing event-args.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset event.setArg("argExists", "foobar") />
		<cfset event.setArg("dot.argExists", "foobar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.argExists}", event, propertyManager) />	
		<cfset assertTrue(result eq "foobar", "Event arg returned did not equal 'foobar'") />

		<!--- NOT currently support expression should be ${event.['dot.argExists']}
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.dot.argExists}", event, propertyManager) />
		<cfset assertTrue(result eq "foobar", "Event arg returned did not equal 'foobar'") />
		--->
	</cffunction>

	<cffunction name="testGetEventArgsExpression" access="public" returntype="void" output="false"
		hint="Tests existing event-args.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset event.setArg("test1", "foo") />
		<cfset event.setArg("test2", "bar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.getArgs()}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertTrue(IsStruct(result), "The result is not a struct") />
		<cfset assertTrue(StructKeyExists(result, "test1"), "The result does not have 'test1' as a struct key") />
		<cfset assertTrue(result["test1"] eq "foo", "result['test1'] does not eq 'foo'") />
	</cffunction>

	<cffunction name="testPropertyExistsExpression" access="public" returntype="void" output="false"
		hint="Tests existing properties.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset propertyManager.setProperty("argExists", "foobar") />
		<cfset propertyManager.setProperty("dot.argExists", "foobar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${properties.argExists}", event, propertyManager) />	
		<cfset assertTrue(result eq "foobar", "Property returned did not equal 'foobar'") />

		<!--- NOT currently support expression should be ${properties.['dot.argExists']} 
		<cfset result = variables.expressionEvaluator.evaluateExpression("${properties.dot.argExists}", event, propertyManager) />
		<cfset assertTrue(result eq "foobar", "Property returned did not equal 'foobar'") />
		 --->
	</cffunction>
	
	<cffunction name="testBooleanExpresion" access="public" returntype="void" output="false"
		hint="Test boolean evaluation to two variables.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />

		<cfset propertyManager.setProperty("foo", "bar") />
		<cfset event.setArg("foo", "bar") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq properties.foo}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertTrue(result, "Result of event.foo eq properties.foo was not true") />
				
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq 'bar'}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertTrue(result, "Result of event.foo eq 'foo' was not true") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq ''}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertFalse(result, "Result of event.foo eq '' was true") />
		
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.foo eq 1}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertFalse(result, "Result of event.foo eq '' was true") />
		
		<cfset event.setArg("bar", 1) />
		<cfset result = variables.expressionEvaluator.evaluateExpression("${event.bar eq 1}", event, propertyManager) />	
		<cfset debug(result) />
		<cfset assertTrue(result, "Result of event.bar eq 1 was false") />
			
		<cfset result = variables.expressionEvaluator.evaluateExpression("${'bar' eq event.foo}", event, propertyManager) />	
		<cfset debug(result) />
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