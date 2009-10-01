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
$Id: BaseComponentTest.cfc 1799 2009-10-01 01:50:21Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent displayname="DummyListenerForInvokerTests"
	extends="MachII.framework.Listener"
	output="false">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC METHODS
	--->
	<cffunction name="testEventInvoker" access="public" returntype="any" output="false">
		<cfargument name="Event" type="MachII.framework.Event" required="true" />
	</cffunction>
	
	<cffunction name="testEventArgsInvokerWithReturn" access="public" returntype="string" output="false">
		<cfargument name="test1" type="any" required="true" />
		<cfargument name="test2" type="any" required="true" />
		<cfargument name="test3" type="any" required="true" />
		
		<cfreturn arguments.test1 & "_" & arguments.test2 & "_" & arguments.test3 />
	</cffunction>
	
	<cffunction name="testEventArgsInvokerWithoutReturn" access="public" returntype="void" output="false">
		<cfargument name="test1" type="any" required="true" />
		<cfargument name="test2" type="any" required="true" />
		<cfargument name="test3" type="any" required="true" />
		
		<cfif arguments.test1 NEQ "value1"
			AND arguments.test2 NEQ "value2"
			AND arguments.test3 NEQ "value3">
			<cfthrow message="Something is wrong because the values did not match." />
		</cfif>
	</cffunction>
	
	<cffunction name="testEventInvokerWithReturn" access="public" returntype="string" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfreturn arguments.event.getArg("test1") & "_" & arguments.event.getArg("test2") & "_" & arguments.event.getArg("test3") />
	</cffunction>
	
	<cffunction name="testEventInvokerWithoutReturn" access="public" returntype="void" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
				
		<cfif arguments.event.getArg("test1") NEQ "value1"
			AND rguments.event.getArg("test2") NEQ "value2"
			AND arguments.event.getArg("test3") NEQ "value3">
			<cfthrow message="Something is wrong because the values did not match." />
		</cfif>
	</cffunction>
	
	<cffunction name="testDummyException" access="public" returntype="void" output="false">
		<cfthrow message="Test exception" />
	</cffunction>

</cfcomponent>