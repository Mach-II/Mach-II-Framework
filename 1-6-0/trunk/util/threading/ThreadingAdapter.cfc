<!---
License:
Copyright 2008 GreatBizTools, LLC

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
$Id: MessageHandler.cfc 549 2007-11-11 22:19:47Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent displayname="ThreadingAdapter"
	output="false"
	hint="Base threading adapter component. This is a base class. Please instantiate a concrete adapter.">

	<!---
	PROPERTIES
	--->
	<cfset variables.allowThreading = FALSE />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ThreadingAdapter" output="false"
		hint="This is the base class. Please instantiate a concrete adapter.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="run" access="public" returntype="void" output="false"
		hint="Runs a thread.">
		<cfargument name="threadIds" type="struct" required="true" />
		<cfargument name="callback" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#" />
		<cfabort showerror="This is the base class. Please instantiate a concrete adapter." />
	</cffunction>
	
	<cffunction name="join" access="public" returntype="void" output="false"
		hint="Joins a group of threads.">
		<cfargument name="threadIds" type="struct" required="true" />
		<cfabort showerror="This is the base class. Please instantiate a concrete adapter." />
	</cffunction>
	
	<cffunction name="allowThreading" access="public" returntype="boolean" output="false"
		hint="Returns a boolean if threading is allowed.">
		<cfreturn variables.allowThreading />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createThreadId" access="private" returntype="string" output="false"
		hint="Creates a thread id.">
		<cfreturn "_MachIIThreadingAdapter_" & Replace(CreateUUID(), "-", "", "all") />
	</cffunction>

</cfcomponent>