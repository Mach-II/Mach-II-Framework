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