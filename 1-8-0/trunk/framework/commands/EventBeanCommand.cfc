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

Created version: 1.0.6
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="EventBeanCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for creating and populating a bean in the current event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "event-bean" />
	<cfset variables.beanName = "" />
	<cfset variables.beanType = "" />
	<cfset variables.beanFields = "" />
	<cfset variables.ignoreFields = "" />
	<cfset variables.reinit = "" />
	<cfset variables.beanUtil = "" />
	<cfset variables.innerBeans = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventBeanCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanType" type="string" required="true" />
		<cfargument name="beanFields" type="string" required="true" />
		<cfargument name="ignoreFields" type="string" required="true" />
		<cfargument name="reinit" type="boolean" required="true" />
		<cfargument name="beanUtil" type="MachII.util.BeanUtil" required="true" />
		
		<cfset setBeanName(arguments.beanName) />
		<cfset setBeanType(arguments.beanType) />
		<cfset setBeanFields(arguments.beanFields) />
		<cfset setIgnoreFields(arguments.ignoreFields) />
		<cfset setReinit(arguments.reinit) />
		<cfset setBeanUtil(arguments.beanUtil) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var bean = "" />
		<cfset var innerBean = "" />
		<cfset var log = getLog() />
		<cfset var innerBeanName = "" />
		<cfset var innerBeanInfo = "" />
		<cfset var fieldNames = "" />
		<cfset var fieldName = "" />
		<cfset var i = 0 />
		<cfset var fields = "" />
		<cfset var fieldNamesWithValues = "" />
		<cfset var fieldValues = "" />
		<cfset var ignoreFields = "" />
		<cfset var expEvaluator = getExpressionEvaluator()	/>
				
		<!--- If reinit is FALSE, get the bean from the event --->
		<cfif NOT getReinit() AND arguments.event.isArgDefined(getBeanName()) AND IsObject(arguments.event.getArg(getBeanName()))>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Event-bean '#getBeanName()#' already in event. Repopulated with data. Fields: '#getBeanFields()#', Ignored Fields: '#getIgnoreFields()#'") />
			</cfif>
			
			<cfset bean = arguments.event.getArg(getBeanName()) />
			
			<cfif isBeanFieldsDefined()>
				<cfset getBeanUtil().setBeanFields(bean, getBeanFields(), arguments.event.getArgs()) />
			<cfelse>
				<cfset getBeanUtil().setBeanAutoFields(bean, arguments.event.getArgs(), getIgnoreFields()) />
			</cfif>
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Event-bean '#getBeanName()#' created and populated with data. Fields:'#getBeanFields()#', Ignored Fields: '#getIgnoreFields()#'") />
			</cfif>

			<cfif isBeanFieldsDefined()>
				<cfset bean = getBeanUtil().createBean(getBeanType()) />
				<cfset getBeanUtil().setBeanFields(bean, getBeanFields(), arguments.event.getArgs()) />
			<cfelse>
				<cfset bean = getBeanUtil().createBean(getBeanType(), arguments.event.getArgs(), getIgnoreFields()) />
			</cfif>			

			<cfset arguments.event.setArg(getBeanName(), bean, getBeanType()) />
		</cfif>
		
		<!--- populate any inner-beans --->
		<cfloop list="#StructKeyList(variables.innerBeans)#" index="innerBeanName">
			<cfset innerBeanInfo = variables.innerBeans[innerBeanName] />
			<cfinvoke component="#bean#" method="get#innerBeanName#" returnvariable="innerBean" />
			
			<cfset fields = innerBeanInfo.getFields() />
			<cfset fieldNamesWithValues = StructNew() />
			<cfset ignoreFields = "" />

			<!--- Handle specific fields for the inner-bean --->
			<cfloop from="1" to="#ArrayLen(fields)#" index="i">
				<cfif fields[i].value eq "" AND NOT fields[i].ignore>
					<cfset fieldNames = ListAppend(fieldNames, fields[i].name) />
				<cfelseif NOT fields[i].ignore>
					<cfset fieldNamesWithValues[fields[i].name] = fields[i].value />
				<cfelse>
					<cfset ignoreFields = ListAppend(ignoreFields, fields[i].name) />
				</cfif>
			</cfloop>
			<cfif Len(fieldNames) eq 0 AND Len(StructKeyList(fieldNamesWithValues)) eq 0>
				<cfset getBeanUtil().setBeanAutoFields(innerBean, arguments.event.getArgs(), innerBeanInfo.getPrefix(), ignoreFields) />
			<cfelse>
				<!--- Populate bean with fields which do not have value expression to be evaluated --->
				<cfset getBeanUtil().setBeanFields(innerBean, fieldNames, arguments.event.getArgs(), innerBeanInfo.getPrefix()) />
				
				<!--- TODO: handle expressions which concat fields together (${event.birthmonth}/${birthday}/${birthyear}) in the innerBean fields --->
				<cfset fieldNames = "" />
				<cfset fieldValues = StructNew() />
				<cfloop list="#StructKeyList(fieldNamesWithValues)#" index="fieldName">
					<cfset fieldNames = ListAppend(fieldNames, fieldName) />
					<cfif expEvaluator.isExpression(fieldNamesWithValues[fieldName])>
						<cfset fieldValues[fieldName] = expEvaluator.evaluateExpression(
							fieldNamesWithValues[fieldName], arguments.event, arguments.eventContext.getAppManager().getPropertyManager()) />					
					<cfelse>
						<cfset fieldValues[fieldName] = fieldNamesWithValues[fieldName] />	
					</cfif>		
				</cfloop>
				<cfset getBeanUtil().setBeanFields(innerBean, fieldNames, fieldValues, innerBeanInfo.getPrefix()) />				
			</cfif>
			
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Inner-bean '#innerBeanInfo.getName()#' with prefix '#innerBeanInfo.getPrefix()#' from event-bean '#getBeanName()#' populated with data.") />
			</cfif>
		</cfloop>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="addInnerBean" access="public" returntype="void" output="false">
		<cfargument name="innerBean" type="MachII.util.BeanInfo" required="true" />
		<cfset variables.innerBeans[arguments.innerBean.getName()] = arguments.innerBean />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setBeanName" access="private" returntype="void" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset variables.beanName = arguments.beanName />
	</cffunction>
	<cffunction name="getBeanName" access="private" returntype="string" output="false">
		<cfreturn variables.beanName />
	</cffunction>
	
	<cffunction name="setBeanType" access="private" returntype="void" output="false">
		<cfargument name="beanType" type="string" required="true" />
		<cfset variables.beanType = arguments.beanType />
	</cffunction>
	<cffunction name="getBeanType" access="private" returntype="string" output="false">
		<cfreturn variables.beanType />
	</cffunction>
	
	<cffunction name="setBeanFields" access="private" returntype="void" output="false">
		<cfargument name="beanFields" type="string" required="true" />
		<cfset variables.beanFields = arguments.beanFields />
	</cffunction>
	<cffunction name="getBeanFields" access="private" returntype="string" output="false">
		<cfreturn variables.beanFields />
	</cffunction>
	<cffunction name="isBeanFieldsDefined" access="public" returntype="boolean" output="false">
		<cfreturn Len(variables.beanFields) gt 0 />
	</cffunction>
	<cffunction name="addBeanField" access="public" returntype="void" output="false">
		<cfargument name="beanField" type="string" required="true" />
		<cfset variables.beanFields = ListAppend(variables.beanFields, arguments.beanField) />
	</cffunction>
	
	<cffunction name="setIgnoreFields" access="private" returntype="void" output="false">
		<cfargument name="ignoreFields" type="string" required="true" />
		<cfset variables.ignoreFields = arguments.ignoreFields />
	</cffunction>
	<cffunction name="getIgnoreFields" access="private" returntype="string" output="false">
		<cfreturn variables.ignoreFields />
	</cffunction>
	<cffunction name="hasIgnoreFields" access="public" returntype="boolean" output="false">
		<cfreturn Len(variables.ignoreFields) gt 0 />
	</cffunction>
	<cffunction name="addIgnoreField" access="public" returntype="void" output="false">
		<cfargument name="ignoreField" type="string" required="true" />
		<cfset variables.ignoreFields = ListAppend(variables.ignoreFields, arguments.ignoreField) />
	</cffunction>
	
	<cffunction name="setReinit" access="private" returntype="void" output="false">
		<cfargument name="reinit" type="boolean" required="true" />
		<cfset variables.reinit = arguments.reinit />
	</cffunction>
	<cffunction name="getReinit" access="private" returntype="boolean" output="false">
		<cfreturn variables.reinit />
	</cffunction>
	
	<cffunction name="setBeanUtil" access="private" returntype="void" output="false">
		<cfargument name="beanUtil" type="MachII.util.BeanUtil" required="true" />
		<cfset variables.beanUtil = arguments.beanUtil />
	</cffunction>
	<cffunction name="getBeanUtil" access="private" returntype="MachII.util.BeanUtil" output="false">
		<cfreturn variables.beanUtil />
	</cffunction>

</cfcomponent>