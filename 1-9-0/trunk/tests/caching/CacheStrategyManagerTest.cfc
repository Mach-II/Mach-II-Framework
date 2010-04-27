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

Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="CacheStrategyManagerTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.caching.CacheStrategyManager.">

	<!---
	PROPERTIES
	--->
	<cfset variables.cacheStrategyManager = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.cacheStrategyManager = CreateObject("component", "MachII.caching.CacheStrategyManager").init() />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testLoadConfigureGet" access="public" returntype="void" output="false"
		hint="Tests load(), configure() and get() routines.">

		<cfset var strategy = "" />

		<!--- Load in a strategy to test with --->
		<cfset variables.cacheStrategyManager.loadStrategy("default", "MachII.caching.strategies.TimeSpanCache") />

		<!--- Configure all the strategies --->
		<cfset variables.cacheStrategyManager.configure() />

		<!--- Get the strategy --->
		<cfset strategy = variables.cacheStrategyManager.getCacheStrategyByName("default") />

		<!--- Assert we got a strategy back --->
		<cfset assertTrue(IsObject(strategy)) />
	</cffunction>

	<cffunction name="testGenerateScopeKey" access="public" returntype="void" output="false"
		hint="Tests generateScopeKey() in a multitude of ways.">

		<cfset assertTrue(variables.cacheStrategyManager.generateScopeKey("name")
				EQ "_MachIICaching._B068931CC450442B63F5B3D276EA4297"
				, "Failed with no additional arguments.") />
		<cfset assertTrue(variables.cacheStrategyManager.generateScopeKey("name", "lightpost")
				EQ "lightpost._MachIICaching._B068931CC450442B63F5B3D276EA4297"
				, "Failed with only 'appKey'.") />
		<cfset assertTrue(variables.cacheStrategyManager.generateScopeKey("name", "lightpost", "")
				EQ "lightpost._MachIICaching._0BD4AEB7F2399D0058D587D20D1BD358"
				, "Failed with both appKey and moduleName (base module of '')") />
		<cfset assertTrue(variables.cacheStrategyManager.generateScopeKey("name", "lightpost", "blog")
				EQ "lightpost._MachIICaching._995AA76C09C5691B2E690FAA7C8B35FE"
				, "Failed with both appKey and moduleName (based module of 'blog')") />
	</cffunction>

</cfcomponent>