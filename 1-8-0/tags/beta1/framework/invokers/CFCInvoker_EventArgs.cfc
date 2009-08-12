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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Deprecated in version: 1.1.0
Updated version: 1.6.0

Notes:
This invoker is DEPRECATED and may not be included with future versions of Mach-II.
Please use EventArgsInvoker.cfc instead.
--->
<cfcomponent 
	displayname="CFCInvoker_EventArgs" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="DEPRECATED. ListenerInvoker that invokes a Listener's method passing the Event's args as an argument collection.">
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CFCInvoker_EventArgs" output="false"
		hint="DEPRECATED. Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="invokeListener" access="public" returntype="void"
		hint="DEPRECATED. Invokes the Listener.">
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
		<cfset var log = arguments.listener.getLog() />
		
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
			
			<cfif log.isWarnEnabled()>
				<cfset log.warn("DEPRECATED: Listener '#arguments.listener.getComponentNameForLogging()#' is using the CFCInvoker_Event which has been deprecated. Please use the EventInvoker.") />
			</cfif>
			
			<cfcatch type="Any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>