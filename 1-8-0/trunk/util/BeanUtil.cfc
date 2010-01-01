<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

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
		<cfargument name="skipFieldsList" type="string" required="false" default=""
			hint="Comma-delimited list of fields to exclude from populating" />
		
		<cfset var bean = "" />
		<cfset var initData = 0 />
		<cfset var field = "" />

		<cfif StructKeyExists(arguments, "initArgs") AND Len(arguments.skipFieldsList)>
			<cfset initData = StructCopy(arguments.initArgs) />
			<cfloop list="#arguments.skipFieldsList#" index="field">
				<cfset structDelete(initData, field, false) />
			</cfloop> 
		<cfelseif StructKeyExists(arguments, "initArgs")>
			<cfset initData = arguments.initArgs />
		</cfif>	
		
		<cftry>
			<!--- Do not method chain the init() method on to the instantiation of the bean --->
			<cfset bean = CreateObject("component", arguments.beanType) />
			
			<cfif StructKeyExists(arguments, "initArgs")>
				<cfset bean.init(argumentcollection=initData) />
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
		<cfargument name="prefix" type="string" required="false" default=""
			hint="String to append in front of the field name. Example prefix = address, bean.setAddress1(fieldCollection['address.address1'])">
		
		<cfset var field = 0  />
		
		<cfloop list="#arguments.fields#" index="field" delimiters=",">
			<cfif arguments.prefix neq "">
				<cfif StructKeyExists(arguments.fieldCollection, "#prefix#.#field#")>
					<cfset setBeanField(arguments.bean, field, arguments.fieldCollection["#prefix#.#field#"]) />
				</cfif>
			<cfelse>
				<cfif StructKeyExists(arguments.fieldCollection, field)>
					<cfset setBeanField(arguments.bean, field, arguments.fieldCollection[field]) />
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="setBeanAutoFields" access="public" returntype="void" output="false"
		hint="Sets the value of fields in a bean (determined by describeBean()) using method calls setBeanField().">
		<cfargument name="bean" type="any" required="true"
			hint="The bean to populate." />
		<cfargument name="fieldCollection" type="struct" required="true"
			hint="A struct of field names mapped to values." />
		<cfargument name="prefix" type="string" required="false" default=""
			hint="String to append in front of the field name. Example prefix = address, bean.setAddress1(fieldCollection['address.address1'])">
		<cfargument name="skipFieldsList" type="string" required="false" default=""
			hint="Comma-delimited list of fields to exclude from populating" />
		
		<cfset var field = 0 />
		<cfset var map = describeBean(arguments.bean) />
		<!---<cftrace text="bean name: #getMetaData(bean).fullname#" />--->

		<cfloop collection="#map#" item="field">
			<cfif arguments.prefix neq "">
				<cfif NOT ListFindNoCase(arguments.skipFieldsList, field) 
					AND StructKeyExists(arguments.fieldCollection, "#prefix#.#field#")>
					<cfset setBeanField(arguments.bean, field, arguments.fieldCollection["#prefix#.#field#"]) />
					<!---<cftrace text="setBeanField(arguments.bean, field, arguments.fieldCollection[prefix.field]) =
						setBeanField(arguments.bean, #field#, arguments.fieldCollection['#prefix#.#field#']) : 
						'#arguments.fieldCollection['#prefix#.#field#']#'" />--->
				</cfif>
			<cfelse>
				<cfif NOT ListFindNoCase(arguments.skipFieldsList, field) 
					AND StructKeyExists(arguments.fieldCollection, field)>
					<cfset setBeanField(arguments.bean, field, arguments.fieldCollection[field]) />
					<!---<cftrace text="setBeanField(arguments.bean, field, arguments.fieldCollection[field]) = 
						setBeanField(arguments.bean, #field#, arguments.fieldCollection[#field#]) : 
						'#arguments.fieldCollection[field]#'" />--->
				</cfif>
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
		
		<cfinvoke component="#arguments.bean#" 
			method="get#arguments.field#" 
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
			
			<!--- CF 9 does not seem to provide the "access" attribute when auto getters/setters are used --->			
			<cfif NOT structKeyExists(metaFunction, "access")>
				<cfset metaFunction.access = "public" />
			</cfif>
			
			<cfif metaFunction.name.toLowerCase().startsWith("get")
				AND metaFunction.access.equalsIgnoreCase("public")
				AND NOT ArrayLen(metaFunction.parameters)>
				<!--- Get the name without the "get" from the method name --->
				<cfset fieldName = Right(metaFunction.name, Len(metaFunction.name)-3) />
				<!--- Lowercase the first letter of the field name --->
				<cfset fieldName = LCase(Left(fieldName,1)) & Right(fieldName, Len(fieldName)-1) />
				<cfinvoke component="#arguments.bean#" 
					method="#metaFunction.name#" 
					returnVariable="fieldValue" />
				<!--- Adobe CF 9's ORM support returns nulls by default --->
				<cfif isDefined("fieldValue")>
					<cfset map[fieldName] = fieldValue />
				<cfelse>
					<cfset map[fieldName] = "" />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn map />
	</cffunction>
	
</cfcomponent>