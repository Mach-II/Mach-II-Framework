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

<call-method bean="fantasyteamService" method="getFantasyTeam" arguments="fantasyteam_id=${event.id}" resultArg="fantasyTeam" />
or
<call-method bean="fantasyteamService" method="getFantasyTeams" resultArg="fantasyteams" />
or
<call-method bean="fantasyteamService" method="getFantasyTeams" arguments="${event.id:0}"" resultArg="fantasyteams" />
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
	<cfset variables.args = arrayNew(1) />
	<cfset variables.argumentList = "" />
	<cfset variables.bean = "" />
	
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
		<cfset setArgumentList(arguments.args) />
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

		<cfset var pm = "" />
		<cfset var beanFactory = "" />
		<cfset var resultValue = "" />
		<cfset var bean = "" />
		<cfset var namedArgs = structNew() />
		<cfset var args = getArguments() />
		<cfset var argList = "" />
		<cfset var unEvaluatedArgs = getArguments() />
		<cfset var i = 0 />
		<cfset var log = getLog() />
		
		<cfif NOT isObject(variables.bean)>
			<cfset pm = getPropertyManager() />
			<cfset beanFactory = pm.getProperty(pm.getProperty("beanFactoryName")) />
			<cfset setBean(beanFactory.getBean(getBeanId())) />
		</cfif>
		<cfset bean = getBean() />
		
		<cfloop from="1" to="#arrayLen(args)#" index="i">
			<cfif args[i].name neq "">
				<cfif args[i].isExpression>
					<cfset namedArgs[args[i].name] = variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, getPropertyManager()) />
				<cfelse>
					<cfset namedArgs[args[i].name] = args[i].value />
				</cfif>
			<cfelse>
				<cfif args[i].isExpression>
					<cfset argList = ListAppend(argList, variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, getPropertyManager())) />
				<cfelse>
					<cfset argList = ListAppend(argList, args[i].value) /> 
				</cfif>
			</cfif>
		</cfloop>

		<cftry>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' with arguments '#getArgumentList()#'.") />
			</cfif>
		
			<cfif Len(argList) gt 0>
				<cfset resultValue = evaluate("bean.#getMethod()#(#argList#)") />
			<cfelse>	
				<cfinvoke 
					component="#bean#" 
					method="#getMethod()#" 
					argumentcollection="#namedArgs#"
					returnvariable="resultValue" />
			</cfif>
			
			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has returned void but a ResultArg/Key has been defined.",  cfcatch) />
					</cfif>
					<cfthrow type="MachII.framework.VoidReturnType"
						message="A ResultArg/Key has been specified on a call-method command method that is returning void. This can also happen if your bean method returns a Java null."
						detail="Bean: '#getMetadata(getBean).name#' Method: '#getMethod()#'" />
				<cfelse>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has caused an exception.",  cfcatch) />
					</cfif>
					<cfrethrow />
				</cfif>
			</cfcatch>
			<cfcatch type="Any">
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has caused an exception.",  cfcatch) />
					</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
				
		<cfif getResultArg() NEQ ''>
			<cfset arguments.event.setArg(getResultArg(), resultValue) />
		</cfif>	
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setExpressionEvaluator" access="public" returntype="void" output="false">
		<cfargument name="expressionEvaluator" type="MachII.util.ExpressionEvaluator" required="true" />
		
		<cfset var argText = "" />
		<cfset var arg = "" />
		
		<cfset super.setExpressionEvaluator(arguments.expressionEvaluator) />
		
		<cfloop list="#getArgumentList()#" index="argText">
			<cfset arg = structNew() />
			
			<cfif listLen(argText, "=") gt 1>
				<cfset arg.name = listGetAt(argText, 1, '=') />
				<cfset arg.isExpression = arguments.expressionEvaluator.isExpression(listGetAt(argText, 2, '=')) />
				<cfset arg.value = listGetAt(argText, 2, "=") /> 
			<cfelse>
				<cfset arg.name = "" />
				<cfset arg.isExpression = arguments.expressionEvaluator.isExpression(argText) />
				<cfset arg.value = argText /> 
			</cfif>
			
			<cfset ArrayAppend(variables.args, arg) />
		</cfloop>
	</cffunction>
	
	<cffunction name="setBeanId" access="private" returntype="void" output="false">
		<cfargument name="beanId" type="string" required="true" />
		<cfset variables.beanId = arguments.beanId />
	</cffunction>
	<cffunction name="getBeanId" access="private" returntype="string" output="false">
		<cfreturn variables.beanId />
	</cffunction>
	
	<cffunction name="setBean" access="private" returntype="void" output="false">
		<cfargument name="bean" type="any" required="true" />
		<cfset variables.bean = arguments.bean />
	</cffunction>
	<cffunction name="getBean" access="private" returntype="any" output="false">
		<cfreturn variables.bean />
	</cffunction>
	
	<cffunction name="setMethod" access="private" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset variables.method = arguments.method />
	</cffunction>
	<cffunction name="getMethod" access="private" returntype="string" output="false">
		<cfreturn variables.method />
	</cffunction>
	
	<cffunction name="setArgumentList" access="private" returntype="void" output="false">
		<cfargument name="argumentList" type="string" required="true" />
		<cfset variables.argumentList = arguments.argumentList />
	</cffunction>
	<cffunction name="getArgumentList" access="private" returntype="string" output="false">
		<cfreturn variables.argumentList />
	</cffunction>
	
	<cffunction name="setArguments" access="private" returntype="void" output="false">
		<cfargument name="args" type="array" required="true" />
		<cfset variables.args = arguments.args />
	</cffunction>
	<cffunction name="getArguments" access="private" returntype="array" output="false">
		<cfreturn variables.args />
	</cffunction>
	<cffunction name="hasArguments" access="private" returntype="boolean" output="false">
		<cfreturn ArrayLen(variables.args) />
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