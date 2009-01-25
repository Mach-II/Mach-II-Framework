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
$Id:$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="URLRoute"
	output="false"
	hint="The URLRoute object represent a possible route for use by the URLRoutesProperty.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.name = "" />
	<cfset variables.moduleName = "" />
	<cfset variables.eventName = "" />
	<cfset variables.urlAlias = "" />
	<cfset variables.requiredArguments = "" />
	<cfset variables.optionalArguments = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="URLRoute" output="false">
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="moduleName" type="string" required="false" default="" />
		<cfargument name="urlAlias" type="string" required="false" default="" />
		<cfargument name="requiredArguments" type="string" required="false" default="" />
		<cfargument name="optionalArguments" type="string" required="false" default="" />
		
		<cfset setName(arguments.name) />
		<cfset setModuleName(arguments.moduleName) />
		<cfset setUrlAlias(arguments.urlAlias) />
		<cfset setRequiredArguments(arguments.requiredArguments) />
		<cfset setOptionalArguments(arguments.optionalArguments) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	
	<!---
	PROTECTED FUNCTIONS
	--->

	<!---
	ACCESSORS
	--->
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>
	
	<cffunction name="getModuleName" access="public" returntype="string" output="false">
		<cfreturn variables.moduleName />
	</cffunction>
	<cffunction name="setModuleName" access="public" returntype="void" output="false">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	
	<cffunction name="getEventName" access="public" returntype="string" output="false">
		<cfreturn variables.eventName />
	</cffunction>
	<cffunction name="setEventName" access="public" returntype="void" output="false">
		<cfargument name="eventName" type="string" required="true" />
		<cfset variables.eventName = arguments.eventName />
	</cffunction>
	
	<cffunction name="getUrlAlias" access="public" returntype="string" output="false">
		<cfreturn variables.urlAlias />
	</cffunction>
	<cffunction name="setUrlAlias" access="public" returntype="void" output="false">
		<cfargument name="urlAlias" type="string" required="true" />
		<cfset variables.urlAlias = arguments.urlAlias />
	</cffunction>
	
	<cffunction name="getRequiredArguments" access="public" returntype="string" output="false">
		<cfreturn variables.requiredArguments />
	</cffunction>
	<cffunction name="setRequiredArguments" access="public" returntype="void" output="false">
		<cfargument name="requiredArguments" type="string" required="true" />
		<cfset variables.requiredArguments = arguments.requiredArguments />
	</cffunction>
	
	<cffunction name="getOptionalArguments" access="public" returntype="string" output="false">
		<cfreturn variables.optionalArguments />
	</cffunction>
	<cffunction name="setOptionalArguments" access="public" returntype="void" output="false">
		<cfargument name="optionalArguments" type="string" required="true" />
		<cfset variables.optionalArguments = arguments.optionalArguments />
	</cffunction>

</cfcomponent>