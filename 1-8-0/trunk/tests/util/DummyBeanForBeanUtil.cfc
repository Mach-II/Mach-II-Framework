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
Updated version: 1.6.0

Notes:
This is a test bean for the BeanUtilTest.cfc test case.
--->
<cfcomponent
	displayname="BeanUtilTestBean"
	output="false"
	hint="A bean which models the BeanUtilTestBean form.">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="DummyBeanForBeanUtil" output="false">
		<cfargument name="firstName" type="string" required="false" default="" />
		<cfargument name="lastName" type="string" required="false" default="" />

		<!--- run setters --->
		<cfset setFirstName(arguments.firstName) />
		<cfset setLastName(arguments.lastName) />

		<cfreturn this />
 	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setFirstName" access="public" returntype="void" output="false">
		<cfargument name="firstName" type="string" required="true" />
		<cfset variables.instance.firstName = trim(arguments.firstName) />
	</cffunction>
	<cffunction name="getFirstName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.firstName />
	</cffunction>

	<cffunction name="setLastName" access="public" returntype="void" output="false">
		<cfargument name="LastName" type="string" required="true" />
		<cfset variables.instance.LastName = trim(arguments.LastName) />
	</cffunction>
	<cffunction name="getLastName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.LastName />
	</cffunction>

</cfcomponent>