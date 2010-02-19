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
$Id: BaseComponentTest.cfc 1892 2009-11-05 05:01:27Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="BaseComponentTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.BaseComponent.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset variables.appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset variables.appManager.setAppKey("dummy") />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testInModule" access="public" returntype="void" output="false"
		hint="Tests inModule() method.">
		<cfset assertTrue(NOT variables.appManager.inModule()) />
	</cffunction>
	
	<cffunction name="testOnObjectReloadMethods" access="public" returntype="void" output="false"
		hint="Tests add, remove and get methods for the on object reload functionality.">
		
		<!--- While it's not a true object for call backs, we're using the 'User' object as dummy one --->
		<cfset var user = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var callbacks = "" />
		<cfset var appManager = variables.appManager />
		
		<!--- Add callback object --->
		<cfset appManager.addOnObjectReloadCallback(user, "temp") />
		
		<!--- Get callback object --->
		<cfset callbacks = appManager.getOnObjectReloadCallbacks() />
		<cfset assertTrue(ArrayLen(callbacks) eq 1, "The total number of on reload callbacks after adding one should be one.") />
		<cfset assertTrue(callbacks[1].method eq "temp", "The name of the callback method should have been 'temp'.") />
		
		<!--- Remove the callback object --->
		<cfset appManager.removeOnObjectReloadCallback(user) />
		<cfset callbacks = appManager.getOnObjectReloadCallbacks() />
		<cfset assertTrue(ArrayLen(callbacks) eq 0, "The total number of on reload callbacks after removing one should be zero.") />		
	</cffunction>
	
</cfcomponent>