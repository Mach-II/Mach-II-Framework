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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.1.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent 
	displayname="EventInvoker" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="ListenerInvoker that invokes a Listener's method passing the Event as the sole argument.">
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventInvoker" output="false"
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
		<cfset var log = arguments.listener.getLog() />
		
		<cftry>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Listener '#arguments.listener.getComponentNameForLogging()#' invoking method '#arguments.method#'.") />
			</cfif>
			
			<cfinvoke 
				component="#arguments.listener#" 
				method="#arguments.method#" 
				event="#arguments.event#" 
				returnvariable="resultValue" />
			
			<!--- resultKey --->
			<cfif arguments.resultKey NEQ ''>
				<cfif log.isWarnEnabled()>
					<cfset log.warn("DEPRECATED: The ResultKey attribute has been deprecated. This was called by listener '#arguments.listener.getComponentNameForLogging()#' invoking method '#arguments.method#'.") />
				</cfif>
				<cfset "#arguments.resultKey#" = resultValue />
			</cfif>
			<!--- resultArg --->
			<cfif arguments.resultArg NEQ ''>
				<cfset arguments.event.setArg(arguments.resultArg, resultValue) />
			</cfif>

			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Listener '#arguments.listener.getComponentNameForLogging()#' method '#arguments.method#' has returned void but a ResultArg/Key has been defined.",  cfcatch) />
					</cfif>
					<cfthrow type="MachII.framework.VoidReturnType"
							message="A ResultArg/Key has been specified on a notify command method that is returning void. This can also happen if your listener method returns a Java null."
							detail="Listener: '#getMetadata(listener).name#' Method: '#arguments.method#'" />
				<cfelse>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Listener '#arguments.listener.getComponentNameForLogging()#' method '#arguments.method#' has caused an exception.",  cfcatch) />
					</cfif>
					<cfrethrow />
				</cfif>
			</cfcatch>
			<cfcatch type="Any">
					<cfif log.isErrorEnabled()>
						<cfset log.error("Listener '#arguments.listener.getComponentNameForLogging()#' method '#arguments.method#' has caused an exception.",  cfcatch) />
					</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>