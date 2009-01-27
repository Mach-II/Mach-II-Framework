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
	<cffunction name="parseRoute" access="public" returntype="struct" output="false">
		<cfargument name="urlElements" type="array" required="true" />
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfargument name="eventParameter" type="string" required="true" />
		
		<cfset var params = structNew() />
		<cfset var i = 1 />
		<cfset var element = "" />
		<cfset var totalArgCount = ListLen(getRequiredArguments()) + ListLen(getOptionalArguments()) />
		<cfset var totalArgsProcessed = 0 />
		
		<cfif getModuleName() eq "">
			<cfset params[arguments.eventParameter] = getEventName() />
		<cfelse>
			<cfset params[arguments.eventParameter] = getModuleName() & arguments.moduleDelimiter & getEventName() />
		</cfif>
		
		<!--- <cfdump var="#arguments.urlElements#" /><cfabort /> --->
		
		<!--- Start at position 2 since position 1 was the route name --->
		<cfloop from="2" to="#arrayLen(arguments.urlElements)#" index="i">
			<cfif ListLen(getRequiredArguments()) lte i + 1>
				<cfset params[ListGetAt(ListGetAt(getRequiredArguments(), i - 1), 1, ":")] = arguments.urlElements[i] />
			</cfif>
		</cfloop>
		<cfset totalArgsProcessed = i - 2 /><!--- Hold total number of url args processed not counting the route name --->

		<!--- handle optionalArguments --->	
		<cfif totalArgsProcessed lt totalArgCount>
			<cfloop from="#totalArgsProcessed#" to="#totalArgCount - 1#" index="i">
				<cfset element = ListGetAt(getOptionalArguments(), totalArgCount - i) />
				<cfif ListLen(element, ":") gt 1>
					<cfset params[ListGetAt(element, 1, ":")] = ListGetAt(element, 2, ":") />
				</cfif>
			</cfloop>
		</cfif>
		
		  <!--- <cfdump var="#params#" /><cfabort />  ---> 
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with." />
		<cfargument name="urlParameters" type="struct" required="true"
			hint="Name/value pairs to build the url with a struct of data." />
		<cfargument name="urlBase" type="string" required="true" 
			hint="Base of the url." />
		<cfargument name="seriesDelimiter" type="string" required="true" />
		<cfargument name="queryStringDelimiter" type="string" required="true" />
	
		<cfset var builtUrl = "" />
		<cfset var queryString = "" />
		<cfset var params = arguments.urlParameters />
		<cfset var value = "" />
		<cfset var i = "" />
		<cfset var defaultValue = "" />	
		<cfset var element = "" />
		<cfset var param = 0 />
		<cfset var orderedParams = arrayNew(1) />
		
		<cfif getUrlAlias() neq "">
			<cfset queryString = queryString & getUrlAlias() />		
		<cfelse>
			<cfset queryString = queryString & getName() />
		</cfif>		
		
		<!--- Check to see if all required arguments were passed in --->
		<cfloop list="#getRequiredArguments()#" index="i">
			<cfset defaultValue = "" />
			<cfif ListLen(i, ":") gt 1>
				<cfset defaultValue = ListGetAt(i, 2, ":") />
				<cfset element = ListGetAt(i, 1, ":") />
			<cfelse>
				<cfset element = i />
			</cfif>
			<cfif NOT structKeyExists(params, element) AND defaultValue eq "">
				<cfthrow type="MachII.framework.UrlRoute.RouteArgumentMissing"
					message="When attempting to build a url for the route '#getName()#' required argument '#element#' was not specified.">
			<cfelseif NOT structKeyExists(params, element)>
				<cfset params[element] = defaultValue />
				<cfset param = StructNew() />
				<cfset param.name = element />
				<cfset param.value = defaultValue />
				<cfset ArrayAppend(orderedParams, param)>
			<cfelse>
				<!--- Parameter is in params with a value already set so we just need to put in the ordered array --->
				<cfset param = StructNew() />
				<cfset param.name = element />
				<cfset param.value = params[element] />
				<cfset ArrayAppend(orderedParams, param)>
			</cfif>
		</cfloop>
		
		<cfloop list="#getOptionalArguments()#" index="i">
			<cfset defaultValue = "" />
			<cfif ListLen(i, ":") gt 1>
				<cfset defaultValue = ListGetAt(i, 2, ":") />
				<cfset element = ListGetAt(i, 1, ":") />
			<cfelse>
				<cfset element = i />
			</cfif>
			<cfif structKeyExists(params, element)>
				<cfset param = StructNew() />
				<cfset param.name = element />
				<cfset param.value = params[element] />
				<cfset ArrayAppend(orderedParams, param)>
			</cfif>
		</cfloop>
		
		<cfloop from="1" to="#ArrayLen(orderedParams)#" index="i">
			<cfif IsSimpleValue(orderedParams[i].value)>
				<cfset queryString = queryString & arguments.seriesDelimiter & URLEncodedFormat(orderedParams[i].value) />
			</cfif>
		</cfloop>
		
		<!--- Prepend the urlBase and add trailing series delimiter --->
		<cfif Len(queryString)>
			<cfset builtUrl = arguments.urlBase & arguments.queryStringDelimiter & queryString />
			<cfif arguments.seriesDelimiter NEQ "&">
				<cfset builtUrl = builtUrl & arguments.seriesDelimiter />
			</cfif>
		<cfelse>
			<cfset builtUrl = arguments.urlBase />
		</cfif>
		
		<cfreturn builtUrl />
	</cffunction>
	
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