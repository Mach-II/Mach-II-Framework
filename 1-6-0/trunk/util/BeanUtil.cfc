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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.6
Updated version: 1.6.0

Notes:
Beans are expected to follow the standard Java bean pattern of having
a no argument constuctor (an init() function with no required arguments) 
and setter functions with name setXyz() (with a single argument named xyz) 
for field xyz and getters functions with name getXyz() (that accept no 
arguments).

This utility is thread-safe (no instance data) and can be used as a singleton.
--->
<cfcomponent
	displayname="BeanUtil"
	output="false"
	hint="A utility class for working with bean components.">
	
	<!---
	PROPERTIES
	--->
	
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
		
		<cfset var bean = "" />
		
		<cftry>
			<!--- Do not method chain the init() method on to the instantiation of the bean --->
			<cfset bean = CreateObject("component", arguments.beanType) />
			
			<cfif StructKeyExists(arguments, "initArgs")>
				<cfset bean.init(argumentcollection=arguments.initArgs) />
			<cfelse>
				<cfset bean.init() />
			</cfif>
		
			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName")>
					<cfthrow type="MachII.framework.CannotFindBean"
						message="Cannot find a bean CFC with type of '#beanType#'."
						detail="Please check that a CFC exists at this dot path location." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn bean />
	</cffunction>
	
	<cffunction name="setBeanFields" access="public" returntype="void" output="false"
		hint="Sets the value of fields in a bean using method calls setBeanField().">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to populate." />
		<cfargument name="fields" type="string" required="true"
			hint="A comma-delimited list of fields to set in the bean." />
		<cfargument name="fieldCollection" type="struct" required="true"
			hint="A struct of field names mapped to values." />
		
		<cfset var field = 0  />
		
		<cfloop list="#arguments.fields#" index="field" delimiters=",">
			<cfif StructKeyExists(arguments.fieldCollection, field)>
				<cfset setBeanField(arguments.bean, field, arguments.fieldCollection[field]) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="setBeanAutoFields" access="public" returntype="void" output="false"
		hint="Sets the value of fields in a bean (determined by describeBean()) using method calls setBeanField().">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to populate." />
		<cfargument name="fieldCollection" type="struct" required="true"
			hint="A struct of field names mapped to values." />
		
		<cfset var field = 0 />
		<cfset var map = describeBean(arguments.bean) />
		
		<cfloop collection="#map#" item="field">
			<cfif StructKeyExists(arguments.fieldCollection, field)>
				<cfset setBeanField(arguments.bean, field, arguments.fieldCollection[field]) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="setBeanField" access="public" returntype="void" output="false"
		hint="Sets the value of a field in a bean using method call setBeanField(beanField=value).">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to populate." />
		<cfargument name="field" type="string" required="true"
			hint="The field name to populate." />
		<cfargument name="value" type="any" required="true"
			hint="The value to populate the field name with." />
		
		<cfinvoke component="#arguments.bean#" method="set#arguments.field#">
			<cfinvokeargument name="#arguments.field#" value="#arguments.value#" />
		</cfinvoke>
	</cffunction>
	
	<cffunction name="getBeanField" access="public" returntype="any" output="false"
		hint="Returns the value of a field in a bean using method call getBeanField().">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to get the data from." />
		<cfargument name="field" type="string" required="true"
			hint="The field to get the data from." />
		
		<cfset var fieldValue = "" />
		
		<cfinvoke component="#arguments.bean#" method="get#arguments.field#" 
			returnvariable="fieldValue" />
			
		<cfreturn fieldValue />
	</cffunction>
	
	<cffunction name="describeBean" access="public" returntype="struct" output="false"
		hint="Returns a struct of bean properties/values based on getters.">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to find all getters on." />
		
		<cfset var map = StructNew() />
		<cfset var meta = GetMetaData(arguments.bean) />
		<cfset var metaFunctions = meta.functions />
		<cfset var metaFunction = "" /> 
		<cfset var fieldName = "" />
		<cfset var fieldValue = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(metaFunctions)#" index="i">
			<cfset metaFunction = metaFunctions[i] />
			<cfif metaFunction.name.toLowerCase().startsWith("get")
				AND metaFunction.access.equalsIgnoreCase("public")
				AND NOT ArrayLen(metaFunction.parameters)>
				<!--- Get the name without the "get" from the method name --->
				<cfset fieldName = Right(metaFunction.name, Len(metaFunction.name)-3) />
				<!--- Lowercase the first letter of the field name --->
				<cfset fieldName = LCase(Left(fieldName,1)) & Right(fieldName, Len(fieldName)-1) />
				<cfinvoke component="#arguments.bean#" method="#metaFunction.name#" 
					returnVariable="fieldValue" />
				<cfset map[fieldName] = fieldValue />
			</cfif>
		</cfloop>
		
		<cfreturn map />
	</cffunction>
	
</cfcomponent>