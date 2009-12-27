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

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="TimeSpanCacheTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.caching.strategies.TimeSpanCache.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.cache = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var parameters = StructNew() />

		<cfset parameters.timespan = "0,1,0,0" />
		<cfset parameters.scope = "application" />

		<cfset variables.cache = CreateObject("component", "MachII.caching.strategies.TimeSpanCache").init(parameters) />
		<cfset variables.cache.configure() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testPutExistsGet" access="public" returntype="void"
		hint="Tests put, exist and getting a piece of data from the cache.">

		<cfset var testKey = "productID=1" />
		
		<cfset variables.cache.put(testkey, "testing") />
		
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		<cfset assertTrue(variables.cache.get(testkey) eq "testing") />
	</cffunction>
	
	<cffunction name="testFlush" access="public" returntype="void"
		hint="Tests flushing the cache.">
		
		<cfset var testKey = "productID=1" />

		<cfset variables.cache.put(testkey, "testing") />
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		
		<cfset variables.cache.flush() />
		<cfset assertFalse(variables.cache.keyExists(testkey)) />
	</cffunction>
	
	<cffunction name="testRemove" access="public" returntype="void"
		hint="Tests removing cached data by key.">
		
		<cfset var testKey = "productID=1" />

		<cfset variables.cache.put(testkey, "testing") />
		<cfset assertTrue(variables.cache.keyExists(testkey)) />
		
		<cfset variables.cache.remove(testkey) />
		<cfset assertFalse(variables.cache.keyExists(testkey)) />
	</cffunction>
	
	<cffunction name="testReap" access="public" returntype="void"
		hint="Tests removing cached data by key.">
		
		<cfset var i = 0 />
		<cfset var timestamp = "" />
		<cfset var interval = "" />
		
		<!--- Load the cache --->
		<cfloop from="1" to="2" index="i">
			<cfset variables.cache.put("productID=#i#", "testing #i#") />
		</cfloop>
		
		<!--- "Fake" 55 minutes passing of time and force a reap  --->
		<cfset timestamp = CreateObject("java", "java.math.BigInteger").init(getTickCount()) />
		<cfset interval = CreateObject("java", "java.math.BigInteger").init("3300000") />
		<cfset timestamp = timestamp.add(interval) />
		<cfset variables.cache.setCurrentTickCount(timestamp.toString()) />
		<cfset variables.cache.reap() />
		<cfset variables.cache.setCurrentTickCount("") />
		
		<!--- Check for elements should still be cached --->
		<cfset assertTrue(variables.cache.keyExists("productID=1"), 
			"Check for elements should still be cached (productID=1)") />
		<cfset assertTrue(variables.cache.keyExists("productID=2"), 
			"Check for elements should still be cached (productID=2)") />

		<!--- "Fake" 2 hours passing of time that exceeds cache element timestamps and force a reap --->
		<cfset timestamp = CreateObject("java", "java.math.BigInteger").init(getTickCount()) />
		<cfset interval = CreateObject("java", "java.math.BigInteger").init("72000000")>
		<cfset timestamp = timestamp.add(interval) />
		<cfset variables.cache.setCurrentTickCount(timestamp.toString()) />
		<cfset variables.cache.reap() />
		<cfset variables.cache.setCurrentTickCount("") />
		
		<!--- Check for elements that should have been reaped --->
		<cfset assertFalse(variables.cache.keyExists("productID=1"), 
			"Check for elements that should have been reaped (productID=1)") />
		<cfset assertFalse(variables.cache.keyExists("productID=2"), 
			"Check for elements that should have been reaped (productID=2)") />
	</cffunction>

</cfcomponent>