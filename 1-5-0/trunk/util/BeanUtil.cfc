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
$Id: BeanUtil.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Notes:
Beans are expected to follow the standard Java bean pattern of having
a no argument constuctor (an init() function with no required arguments) 
and setter functions with name setXyz() (with a single argument named xyz) 
for field xyz and getters functions with name getXyz() (that accept no 
arguments).
--->
<cfcomponent
	displayname="BeanUtil"
	hint="A utility class for working with bean components.">
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BeanUtil" output="false"
		hint="Used by the framework for initialization.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="createBean" access="public" returntype="any" output="false"
		hint="Creates a bean and calls its init() function.">
		<cfargument name="beanType" type="string" required="true"
			hint="A fully qualified path to the bean CFC." />
		<cfargument name="initArgs" type="struct" required="false" 
			hint="Optional. The set of arguments to pass to the init() function as an argument collection." />
		
		<cfset var bean = CreateObject('component', arguments.beanType) />
		
		<cfif IsDefined('arguments.initArgs') EQ true>
			<cfinvoke component="#bean#" method="init" argumentCollection="#arguments.initArgs#" />
		<cfelse>
			<cfset bean.init() />
		</cfif>

		<cfreturn bean />
	</cffunction>
	
	<cffunction name="setBeanFields" access="public" returntype="void" output="false"
		hint="Sets the value of a fields in a bean using method calls setBeanField(beanField=value).">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to populate." />
		<cfargument name="fields" type="string" required="true"
			hint="A comma-delimited list of fields to set in the bean." />
		<cfargument name="fieldCollection" type="struct" required="true"
			hint="A struct of field names mapped to values." />
		
		<cfset var field = 0  />
		
		<cfloop index="field" list="#arguments.fields#" delimiters=",">
			<cfif StructKeyExists(arguments.fieldCollection, field)>
				<cfset setBeanField(arguments.bean, field, arguments.fieldCollection[field]) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="setBeanField" access="public" returntype="void" output="false"
		hint="Sets the value of a field in a bean using method call setBeanField(beanField=value).">
		<cfargument name="bean" type="any" required="true" />
		<cfargument name="field" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		
		<cfinvoke component="#arguments.bean#" method="set#arguments.field#">
			<cfinvokeargument name="#arguments.field#" value="#arguments.value#" />
		</cfinvoke>
	</cffunction>
	
	<cffunction name="getBeanField" access="public" returntype="any" output="false"
		hint="Returns the value of a field in a bean using method call getBeanField().">
		<cfargument name="bean" type="any" required="true" />
		<cfargument name="field" type="string" required="true" />
		
		<cfset var fieldValue = "" />
		<cfinvoke component="#arguments.bean#" method="get#arguments.field#" 
			returnvariable="fieldValue" />
		<cfreturn fieldValue />
	</cffunction>
	
	<cffunction name="describeBean" access="public" returntype="struct" output="false"
		hint="Returns a struct of bean properties/values based on getters.">
		<cfargument name="bean" type="any" required="true" />
		
		<cfset var map = StructNew() />
		<cfset var meta = GetMetaData(arguments.bean) />
		<cfset var metaFunctions = meta.functions />
		<cfset var metaFunction = '' /> 
		<cfset var fieldName = '' />
		<cfset var fieldValue = '' />
		<cfset var i = 0 />
		
		<cfloop index="i" from="1" to="#ArrayLen(metaFunctions)#">
			<cfset metaFunction = metaFunctions[i] />
			<cfif metaFunction.name.toLowerCase().startsWith('get')
				AND metaFunction.access.equalsIgnoreCase("public")
				AND ArrayLen(metaFunction.parameters) EQ 0>
				<cfset fieldName = Right(metaFunction.name, Len(metaFunction.name)-3) />
				<cfset fieldName = LCase(Left(fieldName,1)) & Right(fieldName, Len(fieldName)-1) />
				<cfinvoke component="#arguments.bean#" method="#metaFunction.name#" 
					returnVariable="fieldValue" />
				<cfset map[fieldName] = fieldValue />
			</cfif>
		</cfloop>
		
		<cfreturn map />
	</cffunction>
	
</cfcomponent>