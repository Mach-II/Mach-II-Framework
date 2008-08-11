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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id: $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
This component evaluates expressions using the syntax below. Currently it 
supports expressions that refer to the current event object (${event.argName})
and simple properties from the property manager (${properties.propName}).

${scope.key}
--->
<cfcomponent output="false">
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ExpressionEvaluator" output="false"
		hint="Used by the framework for initialization.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="evaluateExpression" access="public" returntype="any" output="false">
		<cfargument name="expression" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		
		<cfset var body = "" />
		<cfset var scope = "" />
		<cfset var key = "" />
		<cfset var result = "" />
		
		<cfif isExpression(arguments.expression)>
			<cfset body = Mid(arguments.expression, 3, Len(arguments.expression) - 3) />
			<cfif listLen(body, ".") gt 1>
				<cfset scope  = listGetAt(body, 1, ".") />
				<cfset key = listGetAt(body, 2, ".") />
				<cfswitch expression="#scope#">
					<cfcase value="event">
						<cfif arguments.event.isArgDefined(key)>
							<cfset result = event.getArg(key) />
						<cfelse>
							<cfthrow type="MachII.util.InvalidExpression" 
								message="The event argument '#arguments.key#' from the expression '#arguments.expression#' does not exist in the current event." />
						</cfif>
					</cfcase>
					<cfcase value="properties">
						<cfif arguments.propertyManager.isPropertyDefined(key) 
							OR (IsObject(getAppManager().getParent()) 
								AND getAppManager().getParent().getPropertyManager().isPropertyDefined(key))>
							<cfset result = getProperty(key) />
						<cfelse>
							<cfthrow type="MachII.util.InvalidExpression" 
								message="The property '#arguments.key#' from the expression '#arguments.expression#' was not found as a valid property name." />
						</cfif>
					</cfcase>
				</cfswitch>
			<cfelse>
				<cfthrow type="MachII.util.InvalidExpression" 
					message="The following expression does not appear to be valid '#arguments.expressions#' Expressions must be in the form of '${scope.key}' Where scope can be either event or properties." />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.util.InvalidExpression" 
				message="The following expression does not appear to be valid '#arguments.expressions#' Expressions must be in the form of '${scope.key}' Where scope can be either event or properties." />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="isExpression" access="public" returntype="boolean" output="false">
		<cfargument name="expression" type="string" required="true" />
		<cfset var expressionFound = false />
		<cfif REFindNoCase("\${(.)*?}", arguments.expression)>
			<cfset expressionFound = true />
		</cfif>
		<cfreturn expressionFound />
	</cffunction>
	
</cfcomponent>