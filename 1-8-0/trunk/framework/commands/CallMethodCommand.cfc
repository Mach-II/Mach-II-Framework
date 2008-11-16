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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="CallMethodCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="An Command for calling a method on a bean configured from the ColdSpringProperty.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.beanId = "" />
	<cfset variables.method = "" />
	<cfset variables.resultArg = "" />
	<cfset variables.args = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CallMethodCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="beanId" type="string" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
		<cfargument name="resultArg" type="string" required="true" />
		
		<cfset setBeanId(arguments.beanId) />
		<cfset setMethod(arguments.method) />
		<cfset setArguments(arguments.args) />
		<cfset setResultArg(arguments.resultArg) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var resultValue = "" />
		<cfset var beanFactory = getPropertyManager().getProperty(getPropertyManager().getProperty("beanFactoryName")) />
		<cfset var bean = beanFactory.getBean(getBeanId()) />
		<cfset var namedArgs = structNew() />
		<cfset var args = "" />
		<cfset var unEvaluatedArgs = getArguments() />
		<cfset var i = "" />
		<cfset var log = getLog() />
		
		<cfloop list="#getArguments()#" index="i">
			<cfif listLen(i, "=") gt 1>
				<cfif variables.expressionEvaluator.isExpression(listGetAt(i, 2, '='))>
					<cfset namedArgs["#listGetAt(i, 1, '=')#"] = 
						variables.expressionEvaluator.evaluateExpression(listGetAt(i, 2, '='), arguments.event, getPropertyManager()) />
				<cfelse>
					<cfset namedArgs["#listGetAt(i, 1, '=')#"] = listGetAt(i, 2, '=') />
				</cfif>
			<cfelse>
				<cfif variables.expressionEvaluator.isExpression(i)>
					<cfset args = ListAppend(args, variables.expressionEvaluator.evaluateExpression(i, arguments.event, getPropertyManager())) />
				<cfelse>
					<cfset args = ListAppend(args, i) />
				</cfif>	
			</cfif>
		</cfloop>
		
		<!--- TODO: need more error handling like the EventInvoker has --->	
		<cfif Len(args) gt 0>
			<cfset resultValue = evaluate("bean.#getMethod()#(#args#)") />
		<cfelse>	
			<cfinvoke 
				component="#bean#" 
				method="#getMethod()#" 
				argumentcollection="#namedArgs#"
				returnvariable="resultValue" />
		</cfif>
				
		<cfif getResultArg() NEQ ''>
			<cfset arguments.event.setArg(getResultArg(), resultValue) />
		</cfif>	
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setBeanId" access="private" returntype="void" output="false">
		<cfargument name="beanId" type="string" required="true" />
		<cfset variables.beanId = arguments.beanId />
	</cffunction>
	<cffunction name="getBeanId" access="private" returntype="string" output="false">
		<cfreturn variables.beanId />
	</cffunction>
	
	<cffunction name="setMethod" access="private" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset variables.method = arguments.method />
	</cffunction>
	<cffunction name="getMethod" access="private" returntype="string" output="false">
		<cfreturn variables.method />
	</cffunction>
	
	<cffunction name="setArguments" access="private" returntype="void" output="false">
		<cfargument name="args" type="string" required="true" />
		<cfset variables.args = arguments.args />
	</cffunction>
	<cffunction name="getArguments" access="private" returntype="string" output="false">
		<cfreturn variables.args />
	</cffunction>
	<cffunction name="hasArguments" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.args) />
	</cffunction>
	
	<cffunction name="setResultArg" access="private" returntype="void" output="false">
		<cfargument name="resultArg" type="string" required="true" />
		<cfset variables.resultArg = arguments.resultArg />
	</cffunction>
	<cffunction name="getResultArg" access="private" returntype="string" output="false">
		<cfreturn variables.resultArg />
	</cffunction>
	<cffunction name="hasResultArg" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.resultArg) />
	</cffunction>

</cfcomponent>