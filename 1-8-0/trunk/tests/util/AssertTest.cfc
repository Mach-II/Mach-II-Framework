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