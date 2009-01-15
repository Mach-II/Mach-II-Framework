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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
This command can be used to call a method from an object configured through the ColdSpringProperty.

<call-method bean="fantasyTeamService" method="getFantasyTeam" 
	arguments="fantasyteam_id=${event.id}" resultArg="fantasyTeam" />
or
<call-method bean="fantasyTeamService" method="getFantasyTeams" 
	resultArg="fantasyTeams" />
or
<call-method bean="fantasyTeamService" method="getFantasyTeams" 
	arguments="${event.id:0}" resultArg="fantasyTeams" />
or
<call-method bean="fantasyTeamService" method="searchFantasyTeams" 
	arguments="argumentCollection=${event.getArgs()}" resultArg="fantasyTeams" />
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
	<cfset variables.bean = "" />
	<cfset variables.method = "" />
	<cfset variables.resultArg = "" />
	<cfset variables.args = ArrayNew(1) />
	<cfset variables.argumentList = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CallMethodCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="beanId" type="string" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
		<cfargument name="resultArg" type="string" required="true" />
		
		<!--- Run setters --->
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
		<cfset var bean = getBean() />
		<cfset var namedArgs = StructNew() />
		<cfset var args = getArguments() />
		<cfset var argValues = ArrayNew(1) />
		<cfset var unEvaluatedArgs = getArguments() />
		<cfset var i = 0 />
		<cfset var evalStatement = "" />
		<cfset var log = getLog() />
		
		<cfloop from="1" to="#ArrayLen(args)#" index="i">
			<cfif args[i].name NEQ "">
				<cfif args[i].isExpression>
					<cfset namedArgs[args[i].name] = variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, getPropertyManager()) />
				<cfelse>
					<cfset namedArgs[args[i].name] = args[i].value />
				</cfif>
			<cfelse>
				<cfif args[i].isExpression>
					<cfset ArrayAppend(argValues, variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, getPropertyManager())) />
				<cfelse>
					<cfset ArrayAppend(argValues, args[i].value) /> 
				</cfif>
			</cfif>
		</cfloop>

		<cftry>
		
			<cfif ArrayLen(argValues) GT 0>
				<cfset evalStatement = evalStatement & 'bean.#getMethod()#(' />
				
				<cfloop from="1" to="#ArrayLen(argValues)#" index="i">
					<cfif i GT 1>
						<cfset evalStatement = evalStatement & "," />
					</cfif>
					<!--- Just give areference to the argValues array instead of 
						outputing the value which fails if the value is a complex arg --->
					<cfset evalStatement = evalStatement & "argValues[" & i & "]" />
				</cfloop>
				
				<cfset evalStatement = evalStatement & ')' />

				<cfif log.isDebugEnabled()>
					<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' with arguments '#getArgumentList()#'. Resolved positional arguments:", argValues) />
				</cfif>	

				<cfset resultValue = Evaluate(evalStatement) />
			<cfelse>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' with arguments '#getArgumentList()#'. Resolve named arguments:", namedArgs) />
				</cfif>	
				<cfinvoke 
					component="#bean#" 
					method="#getMethod()#" 
					argumentcollection="#namedArgs#"
					returnvariable="resultValue" />
			</cfif>
			
			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has returned void but a ResultArg has been defined.",  cfcatch) />
					</cfif>
					<cfthrow type="MachII.framework.VoidReturnType"
						message="A ResultArg has been specified on a call-method command method that is returning void. This can also happen if your bean method returns a Java null."
						detail="Bean: '#getMetadata(getBean).name#' Method: '#getMethod()#'" />
				<cfelse>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has caused an exception.",  cfcatch) />
					</cfif>
					<cfrethrow />
				</cfif>
			</cfcatch>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' has caused an exception.",  cfcatch) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
				
		<cfif getResultArg() NEQ ''>
			<cfset arguments.event.setArg(getResultArg(), resultValue) />
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' returned data in event-arg '#getResultArg()#.'", resultValue) />
			</cfif>
		</cfif>	
		
		<cfreturn true />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="transformArgumentList" access="private" returntype="void" output="false"
		hint="Transforms the argument list into a more optimized data structure for evaluation.">

		<cfset var argText = "" />
		<cfset var arg = "" />
		<cfset var expressionEvaluator = getExpressionEvaluator() />
		
		<cfloop list="#getArgumentList()#" index="argText">
			<cfset arg = StructNew() />
			
			<cfif ListLen(argText, "=") GT 1>
				<cfset arg.name = ListGetAt(argText, 1, "=") />
				<cfset arg.isExpression = expressionEvaluator.isExpression(listGetAt(argText, 2, '=')) />
				<cfset arg.value = ListGetAt(argText, 2, "=") /> 
			<cfelse>
				<cfset arg.name = "" />
				<cfset arg.isExpression = expressionEvaluator.isExpression(argText) />
				<cfset arg.value = argText /> 
			</cfif>
			
			<cfset ArrayAppend(variables.args, arg) />
		</cfloop>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setExpressionEvaluator" access="public" returntype="void" output="false"
		hint="Overrides the inherited method and automatically calls transFormArgumentList().">
		<cfargument name="expressionEvaluator" type="MachII.util.ExpressionEvaluator" required="true" />
		
		<cfset super.setExpressionEvaluator(arguments.expressionEvaluator) />
		
		<cfset transformArgumentList() />
	</cffunction>
	
	<cffunction name="setBeanId" access="private" returntype="void" output="false">
		<cfargument name="beanId" type="string" required="true" />
		<cfset variables.beanId = arguments.beanId />
	</cffunction>
	<cffunction name="getBeanId" access="public" returntype="string" output="false">
		<cfreturn variables.beanId />
	</cffunction>
	
	<cffunction name="setBean" access="public" returntype="void" output="false">
		<cfargument name="bean" type="any" required="true" />
		<cfset variables.bean = arguments.bean />
	</cffunction>
	<cffunction name="getBean" access="public" returntype="any" output="false">
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