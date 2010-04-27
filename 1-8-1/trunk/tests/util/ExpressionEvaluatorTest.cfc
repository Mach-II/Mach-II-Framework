<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

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
	
	<cffunction name="testConcatinatedExpresion" access="public" returntype="void" output="false"
		hint="Test an expression that contains several expressions combined like ${event.birthMonth}/${event.birthday}/${event.birthyear}.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />
		
		<cfset event.setArg("birthMonth", 3) />
		<cfset event.setArg("birthday", 18) />
		<cfset event.setArg("birthyear", 1979) />

		<cfset result = getExpressionEvaluator().isExpression("${event.birthMonth}/${event.birthday}/${event.birthyear}") />
		<cfset assertTrue(result, "The string '${event.birthMonth}/${event.birthday}/${event.birthyear}' was not considered an expression.") />
		
		<!--- 3/18/1979 --->
		<cfset result = getExpressionEvaluator().evaluateExpression("${event.birthMonth}/${event.birthday}/${event.birthyear}", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "3/18/1979", "The expression did not resolve to '3/18/1979'") />
		
		<!--- Birthday: 3/18/1979 --->
		<cfset result = getExpressionEvaluator().evaluateExpression("Birthday: ${event.birthMonth}/${event.birthday}/${event.birthyear}", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "Birthday: 3/18/1979", "The expression did not resolve to 'Birthday: 3/18/1979'") />
		
		<!--- Birthday: 3/18/1979 fun --->
		<cfset result = getExpressionEvaluator().evaluateExpression("Birthday: ${event.birthMonth}/${event.birthday}/${event.birthyear} fun", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "Birthday: 3/18/1979 fun", "The expression did not resolve to 'Birthday: 3/18/1979 fun'") />

	</cffunction>
	
	<cffunction name="testMixedExpressions" access="public" returntype="void" output="false"
		hint="Test an expression that contains mixed expressions.">
		
		<cfset var result = "" />
		<cfset var event = getEvent() />
		<cfset var propertyManager = getPropertyManager() />
		
		<cfset event.setArg("temp", "***temp***") />
		<cfset propertyManager.setProperty("temp", "***temp***") />

		<cfset result = getExpressionEvaluator().isExpression("this should exist - ${event.temp} - ${properties.temp}") />
		<cfset assertTrue(result, "The string 'this should exist - ${event.temp} - ${properties.temp}' was not considered an expression.") />
		
		<cfset result = getExpressionEvaluator().evaluateExpression("this should exist - ${event.temp} - ${properties.temp}", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "this should exist - ***temp*** - ***temp***", "The expression did not resolve to 'this should exist - ***temp*** - ***temp***'") />
		
		<cfset result = getExpressionEvaluator().evaluateExpression("some string ${event.temp}", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "some string ***temp***", "The expression did not resolve to 'some string ***temp***'") />		
		
		<cfset result = getExpressionEvaluator().evaluateExpression("some string ${event.temp} something", event, propertyManager) />
		<cfset debug(result) />
		<cfset assertTrue(result eq "some string ***temp*** something", "The expression did not resolve to 'some string ***temp*** something'") />
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
	
	<cffunction name="getExpressionEvaluator" access="private" returntype="MachII.util.ExpressionEvaluator" output="false">
		<cfreturn variables.expressionEvaluator />
	</cffunction>

</cfcomponent>