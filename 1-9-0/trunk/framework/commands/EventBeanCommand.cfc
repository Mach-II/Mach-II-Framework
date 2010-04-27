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
	<cfset variables.reinit = "" />
	<cfset variables.beanUtil = "" />
	<cfset variables.autoPopulate = false />
	<!--- TODO: refactor EventBeanCommand to use BeanInfo with the new members below --->
	<cfset variables.beanInfo = CreateObject("component", "MachII.util.BeanInfo").init() />

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
		<cfargument name="autoPopulate" type="boolean" required="true" />

		<cfset setBeanName(arguments.beanName) />
		<cfset setBeanType(arguments.beanType) />
		<cfset setBeanFields(arguments.beanFields) />
		<cfset setIgnoreFields(arguments.ignoreFields) />
		<cfset setReinit(arguments.reinit) />
		<cfset setBeanUtil(arguments.beanUtil) />
		<cfset setAutoPopulate(arguments.autoPopulate) />

		<cfif arguments.autoPopulate>
			<cfset setupAutoPopulate() />
		</cfif>

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

		<!--- If reinit is FALSE, get the bean from the event --->
		<cfif NOT getReinit() AND arguments.event.isArgDefined(getBeanName()) AND IsObject(arguments.event.getArg(getBeanName()))>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Event-bean '#getBeanName()#' already in event. Repopulated with data. Fields: '#getBeanFields()#', Ignored Fields: '#getIgnoreFields()#'") />
			</cfif>

			<cfset bean = arguments.event.getArg(getBeanName()) />

			<cfif isBeanFieldsDefined()>
				<cfset getBeanUtil().setBeanFields(bean, getBeanFields(), arguments.event.getArgs()) />
			<cfelse>
				<cfset getBeanUtil().setBeanAutoFields(bean, arguments.event.getArgs(), "", getIgnoreFields()) />
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

		<!--- Populate any fields that have values defined --->
		<cfset processFieldsWithValues(bean, getBeanInfo(), arguments.event, arguments.eventContext) />

		<!--- populate any inner-beans --->
		<cfloop list="#getBeanInfo().getInnerBeanNames()#" index="innerBeanName">
			<cfinvoke component="#bean#" method="get#innerBeanName#" returnvariable="innerBean" />
			<cfset processInnerBean(innerBean, getBeanInfo().getInnerBean(innerBeanName), arguments.event, arguments.eventContext) />
		</cfloop>

		<cfreturn true />
	</cffunction>

	<cffunction name="processFieldsWithValues" access="private" returntype="void" output="false">
		<cfargument name="bean" type="any" required="true" />
		<cfargument name="beanInfo" type="MachII.util.BeanInfo" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var fieldNames = "" />
		<cfset var fieldNamesWithValues = arguments.beanInfo.getFieldsWithValues() />
		<cfset var fieldValues = "" />
		<cfset var fieldName = "" />
		<cfset var expEvaluator = getExpressionEvaluator()	/>

		<cfif Len(StructKeyList(fieldNamesWithValues)) gt 0>
			<cfset fieldNames = "" />
			<cfset fieldValues = StructNew() />
			<cfloop list="#StructKeyList(fieldNamesWithValues)#" index="fieldName">
				<cfset fieldNames = ListAppend(fieldNames, fieldName) />
				<!--- handle expressions which concat fields together (${event.birthmonth}/${event.birthday}/${event.birthyear}) --->
				<cfif expEvaluator.isExpression(fieldNamesWithValues[fieldName])>
					<cfset fieldValues[fieldName] = expEvaluator.evaluateExpression(
						fieldNamesWithValues[fieldName], arguments.event, arguments.eventContext.getAppManager().getPropertyManager()) />
				<cfelse>
					<cfset fieldValues[fieldName] = fieldNamesWithValues[fieldName] />
				</cfif>
			</cfloop>
			<cfset getBeanUtil().setBeanFields(arguments.bean, fieldNames, fieldValues, arguments.beanInfo.getPrefix()) />
		</cfif>
	</cffunction>

	<cffunction name="processInnerBean" access="private" returntype="void" output="false">
		<cfargument name="innerBean" type="any" required="true" />
		<cfargument name="innerBeanInfo" type="MachII.util.BeanInfo" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var fieldNames = arguments.innerBeanInfo.getIncludeFields() />
		<cfset var fieldNamesWithValues = arguments.innerBeanInfo.getFieldsWithValues() />
		<cfset var ignoreFields = arguments.innerBeanInfo.getIgnoreFields() />
		<cfset var innerBeanName = "" />
		<cfset var nextInnerBean = 0 />
		<cfset var log = getLog() />

		<cfif Len(fieldNames) eq 0 AND Len(StructKeyList(fieldNamesWithValues)) eq 0>
			<cfset getBeanUtil().setBeanAutoFields(innerBean, arguments.event.getArgs(), innerBeanInfo.getPrefix(), ignoreFields) />
		<cfelse>
			<!--- Populate bean with fields which do not have value expression to be evaluated --->
			<cfset getBeanUtil().setBeanFields(arguments.innerBean, fieldNames, arguments.event.getArgs(), innerBeanInfo.getPrefix()) />
			<cfset processFieldsWithValues(innerBean, innerBeanInfo, arguments.event, arguments.eventContext) />
		</cfif>

		<cfif log.isDebugEnabled()>
			<cfset log.debug("Inner-bean '#innerBeanInfo.getName()#' with prefix '#innerBeanInfo.getPrefix()#' from event-bean '#getBeanName()#' populated with data.") />
		</cfif>

		<!--- Handle innerBeans which have innerBeans --->
		<cfloop list="#arguments.innerBeanInfo.getInnerBeanNames()#" index="innerBeanName">
			<cfinvoke component="#arguments.innerBean#" method="get#innerBeanName#" returnvariable="nextInnerBean" />
			<cfset processInnerBean(nextInnerBean, innerBeanInfo.getInnerBean(innerBeanName), arguments.event, arguments.eventContext) />
		</cfloop>
	</cffunction>

	<cffunction name="addInnerBean" access="public" returntype="void" output="false">
		<cfargument name="innerBean" type="MachII.util.BeanInfo" required="true" />
		<cfset variables.beanInfo.addInnerBean(arguments.innerBean) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="setupAutoPopulate" access="private" returntype="void" output="false">
		<cfset var bean = getBeanUtil().createBean(getBeanType()) />

		<cfset autoConfigureBeanInfo(variables.beanInfo, bean) />
	</cffunction>

	<cffunction name="autoConfigureBeanInfo" access="private" returntype="void" output="false">
		<cfargument name="beanInfo" type="MachII.util.BeanInfo" required="true" />
		<cfargument name="bean" type="any" required="true" />
		<cfset var field = "" />
		<cfset var beanInfoStruct = getBeanUtil().describeBean(arguments.bean) />
		<cfset var innerBean = 0 />

		<cfloop list="#StructKeyList(beanInfoStruct)#" index="field">
			<cfif isObject(beanInfoStruct[field])>
				<cfset innerBean = CreateObject("component", "MachII.util.BeanInfo").init() />
				<cfset innerBean.setName(field) />
				<cfif beanInfo.getPrefix() neq "">
					<cfset innerBean.setPrefix("#beanInfo.getPrefix()#.#field#") />
				<cfelse>
					<cfset innerBean.setPrefix(field) />
				</cfif>
				<cfset autoConfigureBeanInfo(innerBean, beanInfoStruct[field])>
				<cfset arguments.beanInfo.addInnerBean(innerBean) />
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getBeanInfo" access="private" returntype="MachII.util.BeanInfo" output="false">
		<cfreturn variables.beanInfo />
	</cffunction>

	<cffunction name="setBeanName" access="private" returntype="void" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset variables.beanInfo.setName(arguments.beanName) />
	</cffunction>
	<cffunction name="getBeanName" access="private" returntype="string" output="false">
		<cfreturn variables.beanInfo.getName() />
	</cffunction>

	<cffunction name="setBeanType" access="private" returntype="void" output="false">
		<cfargument name="beanType" type="string" required="true" />
		<cfset variables.beanInfo.setBeanType(arguments.beanType) />
	</cffunction>
	<cffunction name="getBeanType" access="private" returntype="string" output="false">
		<cfreturn variables.beanInfo.getBeanType() />
	</cffunction>

	<cffunction name="setAutoPopulate" access="private" returntype="void" output="false">
		<cfargument name="autoPopulate" type="boolean" required="true" />
		<cfset variables.autoPopulate = arguments.autoPopulate />
	</cffunction>
	<cffunction name="getAutoPopulate" access="private" returntype="boolean" output="false">
		<cfreturn variables.autoPopulate />
	</cffunction>

	<cffunction name="setBeanFields" access="private" returntype="void" output="false">
		<cfargument name="beanFields" type="string" required="true" />
		<cfset variables.beanInfo.setIncludeFields(arguments.beanFields) />
	</cffunction>
	<cffunction name="getBeanFields" access="private" returntype="string" output="false">
		<cfreturn variables.beanInfo.getIncludeFields() />
	</cffunction>
	<cffunction name="isBeanFieldsDefined" access="public" returntype="boolean" output="false">
		<cfreturn variables.beanInfo.hasIncludeFields() />
	</cffunction>
	<cffunction name="addBeanField" access="public" returntype="void" output="false">
		<cfargument name="beanField" type="string" required="true" />
		<cfset variables.beanInfo.addIncludeField(arguments.beanField) />
	</cffunction>

	<cffunction name="setIgnoreFields" access="private" returntype="void" output="false">
		<cfargument name="ignoreFields" type="string" required="true" />
		<cfset variables.beanInfo.setIgnoreFields(arguments.ignoreFields) />
	</cffunction>
	<cffunction name="getIgnoreFields" access="private" returntype="string" output="false">
		<cfreturn variables.beanInfo.getIgnoreFields() />
	</cffunction>
	<cffunction name="hasIgnoreFields" access="public" returntype="boolean" output="false">
		<cfreturn variables.beanInfo.hasIgnoreFields() />
	</cffunction>
	<cffunction name="addIgnoreField" access="public" returntype="void" output="false">
		<cfargument name="ignoreField" type="string" required="true" />
		<cfset variables.beanInfo.addIgnoreField(arguments.ignoreField) />
	</cffunction>

	<cffunction name="setFieldsWithValues" access="public" returntype="void" output="false">
		<cfargument name="fieldsWithValues" type="struct" required="true" />
		<cfset variables.beanInfo.setFieldsWithValues(arguments.fieldsWithValues) />
	</cffunction>
	<cffunction name="getFieldsWithValues" access="public" returntype="struct" output="false">
		<cfreturn variables.beanInfo.getFieldsWithValues() />
	</cffunction>
	<cffunction name="addFieldWithValue" access="public" returntype="void" output="false">
		<cfargument name="fieldName" type="string" required="true" />
		<cfargument name="fieldValue" type="string" required="true" />
		<cfset variables.beanInfo.addFieldWithValue(arguments.fieldName, arguments.fieldValue) />
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