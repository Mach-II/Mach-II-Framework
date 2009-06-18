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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Parts of these tests has been kindly ported from the 
Spring Framework (http://www.springframework.org)
--->
<cfcomponent
	displayname="SimplePatternMatcherTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.SimplePatternMatcher.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.pm = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">		
		<cfset variables.pm = CreateObject("component", "MachII.util.SimplePatternMatcher").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testBasic" access="public" returntype="void" output="false"
		hint="Tests basic matching.">
		<cfset doTest("", "", false) />
		<cfset doTest("1", "", false) />
		<cfset doTest("*", "123", true) />
		<cfset doTest("123", "123", true) />
	</cffunction>
	
	<cffunction name="testStartsWith" access="public" returntype="void" output="false"
		hint="Tests matches based on startsWith.">
		<cfset doTest("get*", "getMe", true) />
		<cfset doTest("get*", "setMe", false) />
	</cffunction>

	<cffunction name="testEndsWith" access="public" returntype="void" output="false"
		hint="Tests matches based on endsWith.">
		<cfset doTest("*Test", "getMeTest", true) />
		<cfset doTest("*Test", "setMe", false) />
	</cffunction>
	
	<cffunction name="testBetween" access="public" returntype="void" output="false"
		hint="Tests matches based on patterns *XYZ*.">
		<cfset doTest("*stuff*", "getMeTest", false) />
		<cfset doTest("*stuff*", "getstuffTest", true) />
		<cfset doTest("*stuff*", "stuffTest", true) />
		<cfset doTest("*stuff*", "getstuff", true) />
		<cfset doTest("*stuff*", "stuff", true) />
	</cffunction>

	<cffunction name="testStartsEnds" access="public" returntype="void" output="false"
		hint="Tests matches based on patterns with a single * in the middle.">
		<cfset doTest("3*3", "3", false) />
		<cfset doTest("3*3", "33", true) />
		<cfset doTest("on*Event", "onEvent", true) />
		<cfset doTest("on*Event", "onMyEvent", true) />
	</cffunction>
	
	<cffunction name="testStartsEndsBetween" access="public" returntype="void" output="false"
		hint="Tests matches based on patterns with a double *'s in the middle.">
		<cfset doTest("12*45*78", "12345678", true) />
		<cfset doTest("12*45*78", "123456789", false) />
		<cfset doTest("12*45*78", "012345678", false) />
		<cfset doTest("12*45*78", "124578", true) />
		<cfset doTest("12*45*78", "1245457878", true) />
		<cfset doTest("3*3*3", "33", false) />
		<cfset doTest("3*3*3", "333", true) />
	</cffunction>

	<cffunction name="testInsane" access="public" returntype="void" output="false"
		hint="Tests insane patterns.">
		<cfset doTest("*1*2*3*", "0011002001010030020201030", true) />
		<cfset doTest("1*2*3*4", "10300204", false) />
		<cfset doTest("1*2*3*3", "10300203", false) />
		<cfset doTest("*1*2*3*", "123", true) />
		<cfset doTest("*1*2*3*", "132", false) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="doTest" access="private" returntype="void" output="false"
		hint="Helper method to perform a test.">
		<cfargument name="pattern" type="any" required="true" />
		<cfargument name="text" type="string" required="true" />
		<cfargument name="shouldMatch" type="boolean" required="true" />
		
		<cfif arguments.shouldMatch>
			<cfset assertTrue(variables.pm.match(arguments.pattern, arguments.text), "Failed with pattern '#arguments.pattern#' and text '#arguments.text#'.") />
		<cfelse>
			<cfset assertFalse(variables.pm.match(arguments.pattern, arguments.text), "Failed with pattern '#arguments.pattern#' and text '#arguments.text#'.") />
		</cfif>
	</cffunction>

</cfcomponent>