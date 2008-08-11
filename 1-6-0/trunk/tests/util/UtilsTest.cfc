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
--->
<cfcomponent
	displayname="Utils"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.Utils.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.utils = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.utils = CreateObject("component", "MachII.util.Utils").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testExpandRelativePath" access="public" returntype="void" output="false"
		hint="Test expandRelativePath().">

		<!--- Test move up directory with file--->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "../../Test.cfc"), "/a/b/c/Test.cfc") />
		<!--- Test same directory with file --->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "./1/2/3/Test.cfc"), "/a/b/c/d/e/1/2/3/Test.cfc") />
		
		<!--- Test move up directory with just a directory and trailing slash --->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "../../Test/"), "/a/b/c/Test/") />
		<!--- Test same directory with just a directory and trailing slash --->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "./1/2/3/Test/"), "/a/b/c/d/e/1/2/3/Test/") />

		<!--- Test move up directory with just a directory and no trailing slash --->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "../../Test"), "/a/b/c/Test") />
		<!--- Test same directory with just a directory and no trailing slash --->
		<cfset assertEquals(variables.utils.expandRelativePath("/a/b/c/d/e/", "./1/2/3/Test"), "/a/b/c/d/e/1/2/3/Test") />
	</cffunction>
	
	<cffunction name="testRecurseComplexValuesWithStruct" access="public" returntype="void" output="false"
		hint="Tests recurseComplexValues() with struct syntax.">
		
		<cfset var xml = XmlParse('<root><struct name="test"><key name="a" value="1"/><key name="b"><value>2</value></key></struct></root>') />
		<cfset var comparison = StructNew() />
		
		<!--- Create comparison data --->
		<cfset comparison.a = 1 />
		<cfset comparison.b = 2 />
		
		<cfset assertTrue(comparison.equals(variables.utils.recurseComplexValues(xml.root))) />
	</cffunction>

	<cffunction name="testRecurseComplexValuesWithArray" access="public" returntype="void" output="false"
		hint="Tests recurseComplexValues() with array syntax.">
		
		<cfset var xml = XmlParse('<root><array name="test"><element value="1"/><element><value>2</value></element></array></root>') />
		<cfset var comparison = ArrayNew(1) />
		
		<!--- Create comparison data --->
		<cfset comparison[1] = 1 />
		<cfset comparison[2] = 2 />
		
		<cfset assertTrue(comparison.equals(variables.utils.recurseComplexValues(xml.root))) />
	</cffunction>
	
	<cffunction name="testRecurseComplexValuesWithSimple" access="public" returntype="void" output="false"
		hint="Tests recurseComplexValues() with simple value syntax.">
		
		<cfset var xml = XmlParse('<root><value>simple</value></root>') />
		
		<cfset assertEquals(variables.utils.recurseComplexValues(xml.root), "simple") />
	</cffunction>
	
	<cffunction name="testRecurseComplexValuesWithNested" access="public" returntype="void" output="false"
		hint="Tests recurseComplexValues() with struct syntax.">
		
		<cfset var xml = XmlParse('<root><struct name="test"><key name="a" value="1"/><key name="b"><array name="test"><element value="1"/><element><value>2</value></element></array></key><key name="c"><value>simple</value></key></struct></root>') />

		<!--- Create comparison data --->
		<cfset comparison.a = 1 />
		<cfset comparison.b = ArrayNew(1) />
		<cfset comparison.b[1] = 1 />
		<cfset comparison.b[2] = 2 />
		<cfset comparison.c = "simple" />
		
		<cfset assertTrue(comparison.equals(variables.utils.recurseComplexValues(xml.root))) />
	</cffunction>
	
	<cffunction name="testAssertSame" access="public" returntype="void" output="false"
		hint="Tests assertSame().">
		
		<cfset var obj1 = CreateObject("component", "MachII.framework.Event").init() />
		<cfset var obj2 = CreateObject("component", "MachII.framework.Event").init() />
		
		<!--- Compare the same object instance which usually would be a different variable name --->
		<cfset assertTrue(variables.utils.assertSame(obj1, obj1)) />
		
		<!--- This should fail because it's not the same object instance --->
		<cfset assertFalse(variables.utils.assertSame(obj1, obj2)) />
	</cffunction>

</cfcomponent>