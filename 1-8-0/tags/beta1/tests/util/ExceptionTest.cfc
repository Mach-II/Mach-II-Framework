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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="ExceptionTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.Exception.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.exception = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.exception = CreateObject("component", "MachII.util.Exception") />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testInit" access="public" returntype="void" output="false"
		hint="Tests default way to use Exception.">
		
		<cfset var tagContext = ArrayNew(1) />
		
		<cfset tagContext[1] = "Test 1" />
		<cfset tagContext[2] = "Test 2" />
		<cfset tagContext[3] = "Test 3" />
		
		<!--- Populate Exception with test data --->
		<cfset variables.exception.init("type"
											, "message"
											, 100
											, "detail"
											, "extended"
											, tagContext) />
		
		<cfset assertEquals(variables.exception.getType(), "type") />
		<cfset assertEquals(variables.exception.getMessage(), "message") />
		<cfset assertEquals(variables.exception.getDetail(), "detail") />
		<cfset assertEquals(variables.exception.getErrorCode(), 100) />
		<cfset assertEquals(variables.exception.getExtendedInfo(), "extended") />
		<cfset assertTrue(IsArray(variables.exception.getTagContext())) />
	</cffunction>

	<cffunction name="testWrapException" access="public" returntype="void" output="false"
		hint="Tests default way to use Exception.">
		
		<cfset var cfcatch = StructNew() />

		<cfset cfcatch.type = "type" />
		<cfset cfcatch.message = "message" />
		<cfset cfcatch.errorcode = 100 />
		<cfset cfcatch.detail = "detail" />
		<cfset cfcatch.extendedInfo = "extended" />
		<cfset cfcatch.TagContext = ArrayNew(1) />		
		<cfset cfcatch.tagContext[1] = "Test 1" />
		<cfset cfcatch.tagContext[2] = "Test 2" />
		<cfset cfcatch.tagContext[3] = "Test 3" />
		
		<!--- Populate Exception with fake cfcatch --->
		<cfset variables.exception.wrapException(cfcatch) />
		
		<cfset assertEquals(variables.exception.getType(), "type") />
		<cfset assertEquals(variables.exception.getMessage(), "message") />
		<cfset assertEquals(variables.exception.getDetail(), "detail") />
		<cfset assertEquals(variables.exception.getErrorCode(), 100) />
		<cfset assertEquals(variables.exception.getExtendedInfo(), "extended") />
		<cfset assertTrue(IsArray(variables.exception.getTagContext())) />
	</cffunction>

</cfcomponent>