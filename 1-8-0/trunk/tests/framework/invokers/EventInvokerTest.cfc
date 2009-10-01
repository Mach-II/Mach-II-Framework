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