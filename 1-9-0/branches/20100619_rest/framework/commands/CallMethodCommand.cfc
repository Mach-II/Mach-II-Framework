<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
	As a special exception, the copyright holders of this library give you 
	permission to link this library with independent modules to produce an 
	executable, regardless of the license terms of these independent 
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

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
	hint="A Command for calling a method on a bean configured and auto-wired in from an IoC container.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "call-method" />
	<cfset variables.beanId = "" />
	<cfset variables.bean = "" />
	<cfset variables.method = "" />
	<cfset variables.resultArg = "" />
	<cfset variables.args = ArrayNew(1) />
	<cfset variables.argumentList = "" />
	<cfset variables.overwrite = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CallMethodCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="beanId" type="string" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="args" type="string" required="true" />
		<cfargument name="resultArg" type="string" required="true" />
		<cfargument name="overwrite" type="boolean" required="true" />
		
		<!--- Run setters --->
		<cfset setBeanId(arguments.beanId) />
		<cfset setMethod(arguments.method) />
		<cfset setArgumentList(arguments.args) />
		<cfset setResultArg(arguments.resultArg) />
		<cfset setOverwrite(arguments.overwrite) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
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
		<cfset var i = 0 />
		<cfset var evalStatement = "" />
		<cfset var log = getLog() />
		<cfset var propertyManager = arguments.eventContext.getAppManager().getPropertyManager() />
		
		<cfif NOT IsObject(bean)>
			<cfthrow type="MachII.framework.commands.NoBean"
				message="A call-method command in #getParentHandlerType()# named '#getParentHandlerName()#' in module '#arguments.eventContext.getAppManager().getModuleName()#' did not have a bean named '#getBeanId()#' autowired into it."
				detail="Ensure your IoC container such as the 'ColdSpringProperty' is of a version that supports the call-method command." />
		</cfif>
		
		<!---
			Typically we prefer to not short-circuit in a middle of a method, but we want to save 
			some clock cycles by not making the method call of the arg is defined in the event and 
			overwrite is false
		--->
		<cfif arguments.event.isArgDefined(getResultArg()) AND NOT getOverwrite()>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' did not return data in event-arg '#getResultArg()#' as data was already present and 'overwrite' is 'false'.")/>
			</cfif>

			<cfreturn true />
		</cfif>
		
		<cftry>
			<cfloop from="1" to="#ArrayLen(args)#" index="i">
				<cfif args[i].name NEQ "">
					<cfif args[i].isExpression>
						<cfset namedArgs[args[i].name] = variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, propertyManager) />
					<cfelse>
						<cfset namedArgs[args[i].name] = args[i].value />
					</cfif>
				<cfelse>
					<cfif args[i].isExpression>
						<cfset ArrayAppend(argValues, variables.expressionEvaluator.evaluateExpression(args[i].value, arguments.event, propertyManager)) />
					<cfelse>
						<cfset ArrayAppend(argValues, args[i].value) /> 
					</cfif>
				</cfif>
			</cfloop>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception has occurred while trying to evaluate an argument expression '#args[i].value#' in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#' in module '#arguments.eventContext.getAppManager().getModuleName()#'.",  cfcatch) />
				</cfif>
				<cfthrow type="MachII.framework.commands.InvalidExpression"
					message="An exception has occurred while trying to evaluate an argument expression '#args[i].value#' in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#' in module '#arguments.eventContext.getAppManager().getModuleName()#'. See details for more information."
					detail="#cfcatch.message# || #cfcatch.detail#" />
			</cfcatch>
		</cftry>

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
			
			<cfif Len(getResultArg())>
				<cfset arguments.event.setArg(getResultArg(), resultValue) />
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Call-method on bean '#getBeanId()#' invoking method '#getMethod()#' returned data in event-arg '#getResultArg()#.'", resultValue) />
				</cfif>
			</cfif>
			
			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Bean '#getBeanId()#' invoking method '#getMethod()#' in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#' has returned void but a ResultArg has been defined.",  cfcatch) />
					</cfif>
					<cfthrow type="MachII.framework.commands.VoidReturnType"
						message="A ResultArg has been specified in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#' is returning void. This can also happen if your bean method returns a Java null."
						detail="Bean: '#getBeanId()#' Method: '#getMethod()#'" />
				<cfelse>
					<cfif log.isErrorEnabled()>
						<cfset log.error("An exception has occurred in bean '#getBeanId()#' invoking method '#getMethod()#' in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#'. "
								& getUtils().buildMessageFromCfCatch(cfcatch),  cfcatch) />
					</cfif>
					<cfrethrow />
				</cfif>
			</cfcatch>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("An exception has occurred in bean '#getBeanId()#' invoking method '#getMethod()#' in a call-method command in #getParentHandlerType()# named '#getParentHandlerName()#'. "
							& getUtils().buildMessageFromCfCatch(cfcatch),  cfcatch) />
				</cfif>
				<cfrethrow/>
			</cfcatch>
		</cftry>	
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="addArgument" access="public" returntype="void" output="false"
		hint="Adds and argument to an ordered list of arguments to pass to the bean method.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		
		<cfset var arg = StructNew() />
		
		<cfset arg.name = arguments.name />
		
		<cfif isSimpleValue(value)>
			<cfset arg.isExpression = expressionEvaluator.isExpression(value) />
		<cfelse>
			<cfset arg.isExpression = false />
		</cfif>
		
		<cfset arg.value = value /> 
		
		<cfset ArrayAppend(variables.args, arg) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="transformArgumentList" access="private" returntype="void" output="false"
		hint="Transforms the argument list into a more optimized data structure for evaluation.">

		<cfset var arg = "" />
		<cfset var argText = "" />
		
		<cfloop list="#getArgumentList()#" index="argText">
			<cfset arg = StructNew() />
			
			<cfif ListLen(argText, "=") GT 1>
				<cfset arg.name = ListGetAt(argText, 1, "=") />
				<cfset arg.value = ListGetAt(argText, 2, "=") /> 
			<cfelse>
				<cfset arg.name = "" />
				<cfset arg.value = argText /> 
			</cfif>
			
			<cfset addArgument(arg.name, arg.value) />
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
	
	<cffunction name="setOverwrite" access="private" returntype="void" output="false">
		<cfargument name="arg" type="boolean" required="true" />
		<cfset variables.overwrite = arguments.arg />
	</cffunction>
	<cffunction name="getOverwrite" access="private" returntype="boolean" output="false">
		<cfreturn variables.overwrite />
	</cffunction>

</cfcomponent>