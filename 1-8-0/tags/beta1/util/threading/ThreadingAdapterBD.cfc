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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="ThreadingAdapter"
	extends="MachII.util.threading.ThreadingAdapter"
	output="false"
	hint="Threading adapter for Railo 3+.">

	<!---
	PROPERTIES
	--->
	<cfset variables.allowThreading = TRUE />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ThreadingAdapter" output="false"
		hint="This initializes the adapter for Railo 3+.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="run" access="public" returntype="string" output="false"
		hint="Runs a thread.">
		<cfargument name="callback" type="any" required="true"
			hint="A CFC to perform the callback on." />
		<cfargument name="method" type="string" required="true"
			hint="Name of method to call on the callback CFC." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="Arguments to pass to the callback method." />
		<cfabort showerror="Unimplemented. Scheduled for Mach-II 1.8.0 if BD has implemented a fix for their limitations." />
	</cffunction>
	
	<cffunction name="join" access="public" returntype="void" output="false"
		hint="Joins a group of threads.">
		<cfargument name="threadIds" type="any" required="true"
			hint="A list, struct or array of thread ids to join." />
		<cfargument name="timeout" type="numeric" required="true"
			hint="How many seconds to wait to join threads. Set to 0 to wait forever (or until request timeout is reached)." />
		<cfabort showerror="Unimplemented. Scheduled for Mach-II 1.8.0 if BD has implemented a fix for their limitations." />
	</cffunction>

</cfcomponent>