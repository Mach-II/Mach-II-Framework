<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.1.0
Updated version: 1.1.0

Notes:
--->
<cfcomponent
	displayname="FrameworkListener"
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for base framework structures.">

	<!---
	PROPERTIES
	--->
	<cfset variables.sys = CreateObject("java", "java.lang.System") />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="suggestGarbageCollection" access="public" returntype="void" output="false"
		hint="Suggests to the JVM to do a garbage collection.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var preGCMemoryData = getProperty("udfs").getMemoryData() />
		<cfset var postGCMemoryData = "" />
		<cfset var recoveredMemory = "" />
		
		<cfset variables.sys.gc() />
		<cfset variables.sys.runFinalization() />

		<!--- Compute recovered memory --->
		<cfset postGCMemoryData = getProperty("udfs").getMemoryData() />
		<cfset recoveredMemory = preGCMemoryData["JVM - Used Memory"] - postGCMemoryData["JVM - Used Memory"] />
		<cfif recoveredMemory GT 0>
			<cfset addHTTPHeaderByName("recoveredMemory", getProperty("udfs").byteConvert(recoveredMemory, "MB", false) & " MB") />
		<cfelse>
			<cfset addHTTPHeaderByName("recoveredMemory", "0 MB") />
		</cfif>
	</cffunction>
	
</cfcomponent>