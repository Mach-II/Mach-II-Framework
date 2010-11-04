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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="AuthenticationTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.security.http.basic.Authentication">

	<!---
	PROPERTIES
	--->
	<cfset variables.authentication = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.authentication = CreateObject("component", "MachII.security.http.basic.Authentication").init("Dashboard API", "/MachII/tests/dummy/Credentials") />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testAuthorization" access="public" returntype="void" output="false"
		hint="Tests the 'authorization' method.">
		
		<cfset var httpHeaders = getHTTPRequestData().headers />
		<cfset var response = getPageContext().getResponse() />
		<cfset var thisThread = "" />
		
		<!--- Insert Fake credentials --->
		<cfset httpHeaders["Authorization"] = variables.authentication.encodeAuthorizationHeader("peter", "peter") />
		<cfset debug(httpHeaders) />
		
		<!--- Test with authorization --->
		<cfset assertTrue(variables.authentication.authenticate(httpHeaders)) />
		
		<!--- Test without authorization --->
		<cfset StructDelete(httpHeaders, "Authorization") />
		
		<cfset request.object = variables.authentication />
		<cfset request.result = "" />
		
		<!--- The only way to test the failure without polluting the response headers is in a thread --->
		<cfthread action="run" name="thisThread">
			<cftry>
				<cfset thread.result = request.object.authenticate(StructNew()) />
				<cfcatch>
					<cfset thread.result = "exception" />
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfthread>

		<cfthread action="join" name="thisThread" />
		<cfset debug(cfthread.thisThread) />		

		<cfset assertFalse(cfthread.thisThread.result) /> 
	</cffunction>
	
	<cffunction name="testEncodeDecodeAuthorizationHeader" access="public" returntype="void" output="false"
		hint="Tests 'encodeAuthorizationHeader' and 'decodeAuthorizationHeader' methods.">
		
		<cfset var fakeHeader = variables.authentication.encodeAuthorizationHeader("peter", "peter") />
		<cfset var result = "" />
	
		<!--- Get results --->
		<cfset result = variables.authentication.decodeAuthorizationHeader(fakeHeader) />	
		
		<!--- Run assertions --->
		<cfset debug(result) />
		<cfset assertEquals("peter", result.username) />
		<cfset assertEquals("peter" , result.password) />
	</cffunction>
	
	<cffunction name="testLoadCredentialFile" access="public" returntype="void" ouput="false"
		hint="Test 'loadCredentialFile' method which is private.">
		
		<cfset var credentials = "" />
		
		<!--- Make the method public --->
		<cfset makePublic(variables.authentication, "loadCredentialFile") />

		<cfset credentials = variables.authentication.loadCredentialFile("/MachII/tests/dummy/Credentials") />
		
		<!--- Run assertions --->
		<cfset debug(credentials) />
		<cfset assertEquals(credentials["matt"], "1fa2ef4755a9226cb9a0a4840bd89b158ac71391") />
		<cfset assertTrue(StructCount(credentials) EQ 2) />
	</cffunction>
	
</cfcomponent>