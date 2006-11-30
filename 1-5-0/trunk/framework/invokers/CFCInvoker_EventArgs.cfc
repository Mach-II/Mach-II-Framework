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
$Id: CFCInvoker_EventArgs.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Depreciated version: 1.1.0
Updated version: 1.1.0

Notes:
This invoker is depreciated and may not be included with future versions of Mach-II.
Please use EventArgsInvoker.cfc instead.
--->
<cfcomponent 
	displayname="CFCInvoker_EventArgs" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="DEPRECIATED. ListenerInvoker that invokes a Listener's method passing the Event's args as an argument collection.">
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CFCInvoker_EventArgs" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="invokeListener" access="public" returntype="void"
		hint="Invokes the Listener.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The Event triggering the invocation." />
		<cfargument name="listener" type="MachII.framework.Listener" required="true"
			hint="The Listener to invoke." />
		<cfargument name="method" type="string" required="true"
			hint="The name of the Listener's method to invoke." />
		<cfargument name="resultKey" type="string" required="false" default=""
			hint="The variable to set the result in." />
		<cfargument name="resultArg" type="string" required="false" default=""
			hint="Not supported." />
		
		<cfset var resultValue = "" />
		<cftry>
			<cfinvoke 
				component="#arguments.listener#" 
				method="#arguments.method#" 
				argumentcollection="#arguments.event.getArgs()#" 
				returnvariable="resultValue" />
			
			<!--- resultKey --->
			<cfif arguments.resultKey NEQ ''>
				<cfset "#arguments.resultKey#" = resultValue />
			</cfif>
			<!--- resultArg not supported. --->
			
			<cfcatch type="Any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>
