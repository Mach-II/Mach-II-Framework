<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
Author: Ben Edwards (ben@ben-edwards.com)
$Id: ListenerInvoker.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Created version: 1.1.0

Notes:
The argument.target variable is mismatched and probably should be arguments.listener. This
has been logged as a non-critical bug. Schedule to be fixed in 1.1.1. (pfarrell)
--->
<cfcomponent 
	displayname="ListenerInvoker"
	output="false"
	hint="Base Invoker component.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ListenerInvoker" output="false"
		hint="Initialization function called by the framework.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="invokeListener" access="public" returntype="void"
		hint="Invokes the target Listener with the Event.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The Event triggering the invocation." />
		<cfargument name="listener" required="true"
			hint="The Listener to invoke." />
		<cfargument name="method" type="string" required="true"
			hint="The name of the Listener's method to invoke." />
		<cfargument name="resultKey" type="string" required="false" default=""
			hint="The result key." />
		
		<!--- Overwrite in Sub-Type --->
	</cffunction>

</cfcomponent>