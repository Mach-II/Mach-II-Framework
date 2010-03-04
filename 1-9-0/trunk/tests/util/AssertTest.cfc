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
--->
<cfcomponent
	displayname="AssertTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.Assert.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.assert = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">		
		<cfset variables.assert = CreateObject("component", "MachII.util.Assert").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testDoesNotContain" access="public" returntype="void" output="false"
		hint="Tests doesNotContain().">		
		
		<cfset var testText = "The quick brown fox jumps over the lazy dog" />
		
		<!--- These should all pass assertion without throwing any exceptions --->
		<cftry>
			<cfset variables.assert.doesNotContain(testText, "jjump") />
			<cfset variables.assert.doesNotContain(testText, "dogs") />
			<cfset variables.assert.doesNotContain(testText, "foxes jump") />
			<cfset variables.assert.doesNotContain(testText, "with the lazy dog") />
			
			<cfcatch type="any">
				<cfset fail("Assert method doesNotContain() failed.", cfcatch) />	
			</cfcatch>
		</cftry>
		
		<!--- These should all fail assertion by throwing an exception --->
		<cftry>
			<cfset variables.assert.doesNotContain(testText, "jump") />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method doesNotContain() failed assert and catch should have caught.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfset variables.assert.doesNotContain(testText, "lazy dog") />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method doesNotContain() failed assert and catch should have caught.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfset variables.assert.doesNotContain(testText, "The q") />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method doesNotContain() failed assert and catch should have caught.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testHasLength" access="public" returntype="void" output="false"
		hint="Tests hasLength().">
		
		<cfset variables.assert.hasLength("abc123") />
		<cfset variables.assert.hasLength("   ") />
		
		<cftry>
			<cfset variables.assert.hasLength("") />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method hasLength() failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testHasText" access="public" returntype="void" output="false"
		hint="Tests hasText().">
		
		<cfset variables.assert.hasText("abc123") />
		<cfset variables.assert.hasText("   a     ") />
		
		<cftry>
			<cfset variables.assert.hasText("   " & Chr(10) & Chr(13)) />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method hasText() failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsNumber" access="public" returntype="void" output="false"
		hint="Tests isNumber().">
		
		<cfset variables.assert.isNumber("60.00231") />
		<cfset variables.assert.isNumber("12000.00") />
		
		<cftry>
			<cfset variables.assert.isNumber("12,000.00") />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method isNumber() failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsTrue" access="public" returntype="void" output="false"
		hint="Tests isTrue().">
		
		<cfset variables.assert.isTrue(0 LT 1) />
		<cfset variables.assert.isTrue(1000 EQ 1000) />
		<cfset variables.assert.isTrue((100 / 10) EQ 10) />
		
		<cftry>
			<cfset variables.assert.isTrue(0 EQ 1) />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method isTrue() failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testNotEmpty_struct" access="public" returntype="void" output="false"
		hint="Tests notEmpty() with a struct.">
	
		<cfset var testStruct = StructNew() />
		
		<cfset testStruct.a = 1 />
		<cfset testStruct.b = 2 />
		
		<cfset variables.assert.notEmpty(testStruct) />
		<cfset variables.assert.notEmpty(testStruct, "Test message.") />
		
		<cftry>
			<cfset variables.assert.notEmpty(StructNew()) />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method notEmpty() with struct failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testNotEmpty_array" access="public" returntype="void" output="false"
		hint="Tests notEmpty() with an array.">
	
		<cfset var testArray = ArrayNew(1) />
		
		<cfset testArray[1] = "a" />
		<cfset testArray[2] = "b" />
		
		<cfset variables.assert.notEmpty(testArray) />
		<cfset variables.assert.notEmpty(testArray, "Test message.") />
		
		<cftry>
			<cfset variables.assert.notEmpty(ArrayNew(1)) />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method notEmpty() with array failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testNotEmpty_query" access="public" returntype="void" output="false"
		hint="Tests notEmpty() with a query.">
	
		<cfset var testQuery = QueryNew("a,b,c") />
		
		<cfset QueryAddRow(testQuery) />
		<cfset QuerySetCell(testQuery, "a", 1, 1) />
		<cfset QuerySetCell(testQuery, "b", 2, 1) />
		<cfset QuerySetCell(testQuery, "c", 3, 1) />
		
		<cfset variables.assert.notEmpty(testQuery) />
		<cfset variables.assert.notEmpty(testQuery, "Test message.") />
		
		<cftry>
			<cfset variables.assert.notEmpty(QueryNew("a,b,c")) />
			
			<!--- The catch should have occurred; otherwise fail --->
			<cfset fail("Method notEmpty() with query failed.") />
			
			<cfcatch type="MachII.util.IllegalArgument">
				<!--- Do nothing --->	
			</cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>