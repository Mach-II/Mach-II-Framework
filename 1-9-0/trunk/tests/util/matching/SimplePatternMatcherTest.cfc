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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Parts of these tests has been kindly ported from the 
Spring Framework (http://www.springframework.org)
--->
<cfcomponent
	displayname="SimplePatternMatcherTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.matching.SimplePatternMatcher.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.pm = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">		
		<cfset variables.pm = CreateObject("component", "MachII.util.matching.SimplePatternMatcher").init() />
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