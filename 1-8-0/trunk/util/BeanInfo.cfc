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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="BeanInfo"
	output="false"
	hint="A class which holds meta data about bean components.">

	<cfset variables.name = "" />
	<cfset variables.prefix = "" />
	<cfset variables.fieldsWithValues = StructNew() />
	<cfset variables.beanType = "" />
	<cfset variables.includeFields = "" />
	<cfset variables.ignoreFields = "" />
	<cfset variables.innerBeans = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BeanInfo" output="false"
		hint="Used by the framework for initialization.">
		<cfreturn this />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn variables.name />
	</cffunction>
	
	<cffunction name="setPrefix" access="public" returntype="void" output="false">
		<cfargument name="prefix" type="string" required="true" />
		<cfset variables.prefix = arguments.prefix />
	</cffunction>
	<cffunction name="getPrefix" access="public" returntype="string" output="false">
		<cfreturn variables.prefix />
	</cffunction>
	
	<cffunction name="setFieldsWithValues" access="public" returntype="void" output="false">
		<cfargument name="fieldsWithValues" type="struct" required="true" />
		<cfset variables.fieldsWithValues = arguments.fieldsWithValues />
	</cffunction>
	<cffunction name="getFieldsWithValues" access="public" returntype="struct" output="false">
		<cfreturn variables.fieldsWithValues />
	</cffunction>
	<cffunction name="addFieldWithValue" access="public" returntype="void" output="false">
		<cfargument name="fieldName" type="string" required="true" />
		<cfargument name="fieldValue" type="string" required="true" />
		<cfset variables.fieldsWithValues[arguments.fieldName] = arguments.fieldValue />
	</cffunction>

	<cffunction name="addInnerBean" access="public" returntype="void" output="false">
		<cfargument name="innerBean" type="MachII.util.BeanInfo" required="true" />
		<cfset variables.innerBeans[arguments.innerBean.getName()] = arguments.innerBean />
	</cffunction>
	<cffunction name="getInnerBean" access="public" returntype="MachII.util.BeanInfo" output="false">
		<cfargument name="innerBeanName" type="string" required="true" />
		<cfif StructKeyExists(variables.innerBeans, arguments.innerBeanName)>
			<cfreturn variables.innerBeans[arguments.innerBeanName] />
		<cfelse>
			<cfthrow type="MachII.util.BeanInfo.InnerBeanNotFound"
				message="The inner-bean named '#arguments.innerBeanName#' was not found in the configured list." />
		</cfif>
	</cffunction>
	<cffunction name="getInnerBeans" access="public" returntype="struct" output="false">
		<cfreturn variables.innerBeans />
	</cffunction>
	<cffunction name="getInnerBeanNames" access="public" returntype="string" output="false">
		<cfreturn StructKeyList(variables.innerBeans) />
	</cffunction>
	
	<cffunction name="setBeanType" access="public" returntype="void" output="false">
		<cfargument name="beanType" type="string" required="true" />
		<cfset variables.beanType = arguments.beanType />
	</cffunction>
	<cffunction name="getBeanType" access="public" returntype="string" output="false">
		<cfreturn variables.beanType />
	</cffunction>

	<cffunction name="setIncludeFields" access="public" returntype="void" output="false">
		<cfargument name="includeFields" type="string" required="true" />
		<cfset variables.includeFields = arguments.includeFields />
	</cffunction>
	<cffunction name="getIncludeFields" access="public" returntype="string" output="false">
		<cfreturn variables.includeFields />
	</cffunction>
	<cffunction name="hasIncludeFields" access="public" returntype="boolean" output="false">
		<cfreturn Len(variables.includeFields) gt 0 />
	</cffunction>
	<cffunction name="addIncludeField" access="public" returntype="void" output="false">
		<cfargument name="includeFields" type="string" required="true" />
		<cfset variables.includeFields = ListAppend(variables.includeFields, arguments.includeFields) />
	</cffunction>
	
	<cffunction name="setIgnoreFields" access="public" returntype="void" output="false">
		<cfargument name="ignoreFields" type="string" required="true" />
		<cfset variables.ignoreFields = arguments.ignoreFields />
	</cffunction>
	<cffunction name="getIgnoreFields" access="public" returntype="string" output="false">
		<cfreturn variables.ignoreFields />
	</cffunction>
	<cffunction name="hasIgnoreFields" access="public" returntype="boolean" output="false">
		<cfreturn Len(variables.ignoreFields) gt 0 />
	</cffunction>
	<cffunction name="addIgnoreField" access="public" returntype="void" output="false">
		<cfargument name="ignoreField" type="string" required="true" />
		<cfset variables.ignoreFields = ListAppend(variables.ignoreFields, arguments.ignoreField) />
	</cffunction>

</cfcomponent>