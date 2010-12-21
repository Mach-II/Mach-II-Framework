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
	displayname="FileTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.matching.FileMatcher.">

	<!---
	PROPERTIES
	--->
	<cfset variables.pm = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.pm = CreateObject("component", "MachII.util.matching.FileMatcher") />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testMatchWithRootPathReplacement_withListInfo" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage using root path replacement.">
		
		<cfset var pathResults = "" />
		<cfset var assertResults = "" />

		<!--- Test using listInfo --->
		<cfset variables.pm.init("/", true) />
		<cfset pathResults = variables.pm.match("/views/**/*.cfm", ExpandPath("/MachII/dashboard"), ExpandPath("/MachII/dashboard")) />
		
		<cfset debug(pathResults) />
		
		<cfset assertIsQuery(pathResults) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/tools/scribble/index.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/sys/login.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
	</cffunction>

	<cffunction name="testMatchWithRootPathReplacement_withoutListInfo" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage using root path replacement.">
		
		<cfset var pathResults = "" />
		<cfset var assertResults = "" />
		
		<!--- Test without using listInfo --->
		<cfset variables.pm.init("/", false) />
		<cfset pathResults = variables.pm.match("/views/**/*.cfm", ExpandPath("/MachII/dashboard"), ExpandPath("/MachII/dashboard")) />
		
		<cfset debug(pathResults) />
		
		<cfset assertIsQuery(pathResults) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/tools/scribble/index.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/sys/login.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />	
	</cffunction>

	<cffunction name="testMatchWithoutRootPathReplacement_withListInfo" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage without using root path replacement.">
		
		<cfset var pathResults = "" />
		<cfset var assertResults = "" />
		
		<!--- Test using listInfo --->
		<cfset variables.pm.init("/", true) />
		<cfset pathResults = variables.pm.match(ExpandPath("/MachII/dashboard") & "/views/**/*.cfm", ExpandPath("/MachII/dashboard")) />
		
		<cfset debug(pathResults) />
		
		<cfset assertIsQuery(pathResults) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '#ExpandPath("/MachII/dashboard")#/views/tools/scribble/index.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '#ExpandPath("/MachII/dashboard")#/views/sys/login.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
	</cffunction>
	
	<cffunction name="testMatchWithoutRootPathReplacement_withoutListInfo" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage without using root path replacement.">
		
		<cfset var pathResults = "" />
		<cfset var assertResults = "" />

		<!--- Test using without listInfo --->
		<cfset variables.pm.init("/", false) />
		<cfset pathResults = variables.pm.match(ExpandPath("/MachII/dashboard") & "/views/**/*.cfm", ExpandPath("/MachII/dashboard")) />
		
		<cfset debug(pathResults) />
		
		<cfset assertIsQuery(pathResults) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '#ExpandPath("/MachII/dashboard")#/views/tools/scribble/index.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '#ExpandPath("/MachII/dashboard")#/views/sys/login.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />		
	</cffunction>

	<cffunction name="testMatchWithExcludePatterns" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage using exclude patterns.">
		
		<cfset var excludePatterns = [ '/views/tools/**' ] />
		<cfset var pathResults = variables.pm.match("/views/**/*.cfm", ExpandPath("/MachII/dashboard"), ExpandPath("/MachII/dashboard"), excludePatterns) />
		<cfset var assertResults = "" />
		
		<cfset debug(pathResults) />
		
		<cfset assertIsQuery(pathResults) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/tools/scribble/index.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 0) />
		
		<cfquery dbtype="query" name="assertResults">
			SELECT *
			FROM pathResults
			WHERE modifiedPath = '/views/sys/login.cfm'
		</cfquery>
		
		<cfset assertTrue(assertResults.recordCount EQ 1) />
		
	</cffunction>

</cfcomponent>