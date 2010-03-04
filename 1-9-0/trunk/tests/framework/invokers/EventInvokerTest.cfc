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
	displayname="BaseComponentTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.BaseComponent.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.listener = "" />
	<cfset variables.invoker = "" />
	<cfset variables.event = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
			
		<cfset var appManager = "" />
		<cfset var eventArgs = StructNew() />
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />
		
		<!--- Setup the Invoker, Listener and Event --->
		<cfset variables.invoker = CreateObject("component", "MachII.framework.invokers.EventInvoker").init() />
		<cfset variables.listener = CreateObject("component", "MachII.tests.dummy.DummyListener").init(appManager, StructNew(), variables.invoker) />
		<cfset variables.listener.configure() />
		
		<cfset eventArgs.test1 = "value1" />
		<cfset eventArgs.test2 = "value2" />
		<cfset eventArgs.test3 = "value3" />
		
		<cfset variables.event = CreateObject("component", "MachII.framework.Event").init("dummy", eventArgs) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testEventInvokerWithReturn" access="public" returntype="void" output="false"
		hint="Tests the listener method testEventArgsInvokerWithReturn().">
		
		<cfset variables.invoker.invokeListener(variables.event
									, variables.listener
									, "testEventInvokerWithReturn"
									, ""
									, "result") />
		
		<cfset assertEquals(variables.event.getArg("result"), "value1_value2_value3") />
	</cffunction>
	
	<cffunction name="testEventInvokerWithoutReturn" access="public" returntype="void" output="false"
		hint="Tests the listener method testEventArgsInvokerWithoutReturn().">
		
		<cfset variables.invoker.invokeListener(variables.event
									, variables.listener
									, "testEventInvokerWithoutReturn"
									, ""
									, "") />
		
	</cffunction>
	
	<cffunction name="testDummyException" access="public" returntype="void" output="false"
		hint="Tests the listener method testDummyException().">
		
		<cfset var failed = false />
		
		<cftry>
			<cfset variables.invoker.invokeListener(variables.event
										, variables.listener
										, "testDummyException"
										, ""
										, "") />
			<cfcatch type="any">
				<cfset failed = true />
			</cfcatch>
		</cftry>
		
		<cfset assertTrue(failed) />
	</cffunction>

</cfcomponent>