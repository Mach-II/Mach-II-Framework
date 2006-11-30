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
$Id: EventArgsInvoker.cfc 100 2005-09-11 19:38:28Z bedwards $

Created version: 1.1.0
Update version: 1.1.1

Notes:
- Added error handling if notified listener method returns void, but a ResultArg/Key 
has been defined. This also fixed the problem if the listener returns a Java null value. (pfarrell)
--->
<cfcomponent 
	displayname="EventArgsInvoker" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="ListenerInvoker that invokes a Listener's method passing the Event's args as an argument collection.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventArgsInvoker" output="false"
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
			hint="The eventArg to set the result in." />
		
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
			<!--- resultArg --->
			<cfif arguments.resultArg NEQ ''>
				<cfset arguments.event.setArg(arguments.resultArg, resultValue) />
			</cfif>

			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfthrow type="MachII.framework.VoidReturnType"
							message="A ResultArg/Key has been specified on a notify command method that is returning void. This can also happen if your listener method returns a Java null."
							detail="Notify method name: '#arguments.method#'" />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>			
			<cfcatch type="Any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>