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
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
This component evaluates expressions using the syntax below. Currently it 
supports expressions that refer to the current event object (${event.argName})
and simple properties from the property manager (${properties.propName}). I can also
evaluate simple boolean operand.

Examples:
${scope.key}
${scope.key EQ "foobar"}
${scope.key NEQ scope.key2}
--->
<cfcomponent 
	output="false"
	hint="Evaluates expressions and returns data.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.operandList = "eq,neq,gt,gte,lt,lte" />
	
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
		<cfset var result = "" />
		
		<cfif isExpression(arguments.expression)>
			<cfset body = Mid(arguments.expression, 3, Len(arguments.expression) - 3) />
			<cfset result = evaluateExpressionBody(body, arguments.event, arguments.propertyManager)>
		<cfelse>
			<cfthrow type="MachII.util.InvalidExpression" 
				message="The following expression does not appear to be valid '#arguments.expressions#' Expressions must be in the form of '${scope.key}' Where scope can be either event or properties." />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="evaluateExpressionBody" access="public" returntype="any" output="false">
		<cfargument name="expressionBody" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
		
		<cfset var body = arguments.expressionBody />
		<cfset var result = "" />
		<cfset var rightParam = "" />
		<cfset var leftParam = "" />
		<cfset var expDetails = structNew() />
		<cfset var temp = 0 />

		<cfif listLen(body, " ") eq 1>
			<!--- Must be a simple expression with no operands (example: event.foobar) --->
			<cfset result = evaluateExpressionElement(body, arguments.event, arguments.propertyManager) />	
		<cfelse>
			<!--- Must be an expression that contains spaces (examples: "foo bar", event.foo eq 'foobar') --->
			<cfif left(body, 1) neq '"' AND left(body, 1) neq  "'">
				<cfset expDetails.leftParam = evaluateExpressionElement(listGetAt(body, 1, " "), arguments.event, arguments.propertyManager)>
				<cfset body = listDeleteAt(body, 1, " ") />
			<cfelseif left(body, 1) eq '"' OR left(body, 1) eq  "'">	
				<!--- Must be an expression which starts with  ' or " (example "foobar") --->
				<cfset temp = parseOutParam(body) />
				<cfset body = temp.body />
				<cfset expDetails.leftParam = temp.param />
			</cfif>
			<cfif len(body)>
				<cfset expDetails.operand = listGetAt(body, 1, " ") />
				<cfif NOT listFindNoCase(variables.operandList, expDetails.operand)>
					<cfthrow type="MachII.util.InvalidExpression" 
						message="The operand '#operand#' from the expression '#arguments.expressionBody#' is not one of the following supported operands. (#variables.operandList#)" />
				</cfif>
				<cfset body = listDeleteAt(body, 1, " ") />
				<cfif len(body)>
					<cfif left(body, 1) eq '"' OR left(body, 1) eq  "'">
						<cfset temp = parseOutParam(body) />
						<cfset body = temp.body />
						<cfset expDetails.rightParam = temp.param />
					<cfelse>
						<cfset expDetails.rightParam = evaluateExpressionElement(listGetAt(body, 1, " "), arguments.event, arguments.propertyManager)>
					</cfif>
				<cfelse>
					<cfthrow type="MachII.util.InvalidExpression" 
						message="The expression '#arguments.expressionBody#' does not have a right operand." />
				</cfif>
			<cfelse>
				<cfset result = expDetails.leftParam />
			</cfif>
		</cfif>
		
		<cfif structKeyExists(expDetails, "leftParam") AND structKeyExists(expDetails, "rightParam")>
			<cfset result = evaluate('"#expDetails.leftParam#" #expDetails.operand# "#expDetails.rightParam#"') />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="parseOutParam" access="private" returntype="struct" output="false">
		<cfargument name="body" type="string" required="true" />
		
		<cfset var result = structNew() />
		<cfset var leftParam = "" />
		
		<cfset leftParam = right(arguments.body, len(arguments.body) - 1) />
		<cfif left(arguments.body, 1) eq  "'">
			<cfset leftParam = listGetAt(leftParam, 1, "'") />
			<cfset arguments.body = trim(ListDeleteAt(right(arguments.body, len(arguments.body) - 1), 1, "'")) />
		<cfelse>
			<cfset leftParam = listGetAt(leftParam, 1, '"') />
			<cfset arguments.body = trim(ListDeleteAt(right(arguments.body, len(arguments.body) - 1), 1, '"')) />
		</cfif>
		
		<cfset result.param = leftParam />
		<cfset result.body = arguments.body />
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="evaluateExpressionElement" access="private" returntype="any" output="false">
		<cfargument name="expressionElement" type="string" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true" />
	
		<cfset var scope = "" />
		<cfset var key = "" />
		<cfset var result = "" />
		<cfset var body = arguments.expressionElement />
		
		<cfif listLen(body, ".") gt 1>
			<!--- Scope is always up to the first dot --->
			<cfset scope = listGetAt(body, 1, ".") />
			<!--- Keys can contain dots so just remove the scope --->
			<cfset key = Right(body, Len(body) - Len(scope) - 1) />
			
			<cfswitch expression="#scope#">
				<cfcase value="event">
					<cfif arguments.event.isArgDefined(key)>
						<cfset result = arguments.event.getArg(key) />
					<cfelse>
						<cfthrow type="MachII.util.InvalidExpression" 
							message="The event argument '#key#' from the expression '#arguments.expression#' does not exist in the current event." />
					</cfif>
				</cfcase>
				<cfcase value="properties">
					<cfif arguments.propertyManager.isPropertyDefined(key) 
						OR (IsObject(arguments.propertyManager.getParent()) 
							AND arguments.propertyManager.getParent().isPropertyDefined(key))>
						<cfset result = arguments.propertyManager.getProperty(key) />
					<cfelse>
						<cfthrow type="MachII.util.InvalidExpression" 
							message="The property '#key#' from the expression '#arguments.expression#' was not found as a valid property name." />
					</cfif>
				</cfcase>
			</cfswitch>
		<cfelse>
			<cfthrow type="MachII.util.InvalidExpression" 
				message="The following expression does not appear to be valid '#arguments.expressions#' Expressions must be in the form of '${scope.key}' Where scope can be either event or properties." />
		</cfif>
	
		<cfreturn result />
	</cffunction>
	
	<cffunction name="isExpression" access="public" returntype="boolean" output="false"
		hint="Checks if passed argument is a valid expression.">
		<cfargument name="expression" type="string" required="true" />
		<cfreturn REFindNoCase("\${(.)*?}", arguments.expression) />
	</cffunction>
	
</cfcomponent>