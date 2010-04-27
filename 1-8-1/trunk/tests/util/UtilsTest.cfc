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
		<!--- For some reason, not using quotes around the values causes the test case to fail on Open BD --->
		<cfset comparison.a = "1" />
		<cfset comparison.b = "2" />
		
		<cfset assertTrue(comparison.equals(variables.utils.recurseComplexValues(xml.root))) />
	</cffunction>

	<cffunction name="testRecurseComplexValuesWithArray" access="public" returntype="void" output="false"
		hint="Tests recurseComplexValues() with array syntax.">
		
		<cfset var xml = XmlParse('<root><array name="test"><element value="1"/><element><value>2</value></element></array></root>') />
		<cfset var comparison = ArrayNew(1) />
		
		<!--- Create comparison data --->
		<!--- For some reason, not using quotes around the values causes the test case to fail on Open BD --->
		<cfset comparison[1] = "1" />
		<cfset comparison[2] = "2" />
		
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
		<cfset var comparison = StructNew() />

		<!--- Create comparison data --->
		<!--- For some reason, not using quotes around the values causes the test case to fail on Open BD --->
		<cfset comparison.a = "1" />
		<cfset comparison.b = ArrayNew(1) />
		<cfset comparison.b[1] = "1" />
		<cfset comparison.b[2] = "2" />
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
	
	<cffunction name="testTrimList" access="public" returntype="void" output="false"
		hint="Test trimList().">
		
		<cfset var comparisonList = "apples,oranges,pears" />
		<cfset var returnedList = variables.utils.trimList(" apples, oranges ,pears ") />
		
		<cfset assertTrue(returnedList EQ comparisonList) />
	</cffunction>
	
	<cffunction name="testEscapeHtml" access="public" returntype="void" output="false"
		hint="Test escapeHtml().">
		<cfset assertTrue(Compare(variables.utils.escapeHtml("< > Planchers de bambou, li&egrave;ge, ch&ecirc;ne FSC, &eacute;rable FSC, pin et eucalyptus &eacute;cologiques et durables &&& Peter&Matt"), "&lt; &gt; Planchers de bambou, li&egrave;ge, ch&ecirc;ne FSC, &eacute;rable FSC, pin et eucalyptus &eacute;cologiques et durables &amp;&amp;&amp; Peter&amp;Matt") EQ 0) />
	</cffunction>

</cfcomponent>