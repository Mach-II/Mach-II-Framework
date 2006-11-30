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
$Id: EventBeanCommand.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.3
Updated version: 1.1.0
--->
<cfcomponent 
	displayname="EventBeanCommand" 
	extends="MachII.framework.EventCommand"
	output="false"
	hint="An EventCommand for creating and populating a bean in the current event.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.beanName = "" />
	<cfset variables.beanType = "" />
	<cfset variables.beanFields = "" />
	<cfset variables.beanUtil = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventBeanCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanType" type="string" required="true" />
		<cfargument name="beanFields" type="string" required="true" />
		
		<cfset setBeanName(arguments.beanName) />
		<cfset setBeanType(arguments.beanType) />
		<cfset setBeanFields(arguments.beanFields) />
		
		<cfset setBeanUtil( CreateObject('component','MachII.util.BeanUtil').init() ) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var bean = "" />
		
		<cfif isBeanFieldsDefined()>
			<cfset bean = getBeanUtil().createBean(getBeanType()) />
			<cfset getBeanUtil().setBeanFields(bean, getBeanFields(), arguments.event.getArgs()) />
		<cfelse>
			<cfset bean = getBeanUtil().createBean(getBeanType(), arguments.event.getArgs()) />
		</cfif>
		
		<cfset arguments.event.setArg(getBeanName(), bean, getBeanType()) />
		
		<cfreturn true />
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
		<cfreturn NOT getBeanFields() EQ '' />
	</cffunction>
	
	<cffunction name="setBeanUtil" access="private" returntype="void" output="false">
		<cfargument name="beanUtil" type="MachII.util.BeanUtil" required="true" />
		<cfset variables.beanUtil = arguments.beanUtil />
	</cffunction>
	<cffunction name="getBeanUtil" access="private" returntype="MachII.util.BeanUtil" output="false">
		<cfreturn variables.beanUtil />
	</cffunction>

</cfcomponent>