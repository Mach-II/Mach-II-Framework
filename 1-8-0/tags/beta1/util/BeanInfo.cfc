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
	<cfset variables.fields = ArrayNew(1) />
	
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
	
	<cffunction name="setFields" access="public" returntype="void" output="false">
		<cfargument name="fields" type="array" required="true" />
		<cfset variables.fields = arguments.fields />
	</cffunction>
	<cffunction name="getFields" access="public" returntype="array" output="false">
		<cfreturn variables.fields />
	</cffunction>

</cfcomponent>