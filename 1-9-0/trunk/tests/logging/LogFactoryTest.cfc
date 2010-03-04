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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="LogFactoryTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.logging.LogFactory.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.logFactory = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.logFactory = CreateObject("component", "MachII.logging.LogFactory").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testGetLog" access="public" returntype="void" output="false"
		hint="Tests getting a new log instance.">
		
		<cfset var channel = "test" />
		
		<!--- Gets a log (this channel instance will be created since it will no be in the cache) --->
		<cfset variables.logFactory.getLog(channel) />
		
		<!--- Gets a log (this channel instance will be cache since the previous getLog created and cached a log for this channel) --->
		<cfset variables.logFactory.getLog(channel) />
	</cffunction>
	
	<cffunction name="testAddLogAdapter" access="public" returntype="void" output="false"
		hint="Tests adds a log adapter">
		
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.AbstractLogAdapter").init(StructNew()) />
		
		<cfset variables.logFactory.addLogAdapter(adapter) />
	</cffunction>
	
	<cffunction name="testAddRemoveLogAdapter" access="public" returntype="void" output="false"
		hint="Tests adding and removing a log adapter">
		
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.AbstractLogAdapter").init(StructNew()) />
		
		<cfset variables.logFactory.addLogAdapter(adapter) />
		
		<cfset variables.logFactory.removeLogAdapter(adapter) />
		
		<cfset assertTrue(NOT StructCount(variables.logFactory.getLogAdapters()), "A log adapter was added and removed, but that did not work correctly.") />
	</cffunction>
	
	<cffunction name="testDisableLogging" access="public" returntype="void" output="false"
		hint="Tests disabling the logging.">
		
		<!--- Add an adapter so when logging is disabled we have an adapter to disable logging --->
		<cfset testAddLogAdapter() />
		
		<cfset variables.logFactory.disableLogging() />
	</cffunction>

	<cffunction name="testEnableLogging" access="public" returntype="void" output="false"
		hint="Tests enabling the logging.">
		
		<!--- Add an adapter so when logging is disabled we have an adapter to disable logging --->
		<cfset testAddLogAdapter() />
		
		<cfset variables.logFactory.disableLogging() />
	</cffunction>

</cfcomponent>