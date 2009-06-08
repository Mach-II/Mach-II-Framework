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
	displayname="UrlRoute"
	output="false"
	hint="The UrlRoute object represent a possible route for use by the UrlRoutesProperty.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.name = "" />
	<cfset variables.moduleName = "" />
	<cfset variables.eventName = "" />
	<cfset variables.urlAlias = "" />
	<cfset variables.requiredParameters = "" />
	<cfset variables.optionalParameters = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="UrlRoute" output="false"
		hint="Initializes the route.">
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="moduleName" type="string" required="false" default="" />
		<cfargument name="eventName" type="string" required="false" default="" />
		<cfargument name="urlAlias" type="string" required="false" default="" />
		<cfargument name="requiredParameters" type="string" required="false" default="" />
		<cfargument name="optionalParameters" type="string" required="false" default="" />
		
		<cfset setName(arguments.name) />
		<cfset setModuleName(arguments.moduleName) />
		<cfset setEventName(arguments.eventName) />
		<cfset setUrlAlias(arguments.urlAlias) />
		<cfset setRequiredParameters(arguments.requiredParameters) />
		<cfset setOptionalParameters(arguments.optionalParameters) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	<cffunction name="parseRoute" access="public" returntype="struct" output="false"
		hint="Parses route to event and module name with incoming url elements to name/value pairs.">
		<cfargument name="urlElements" type="array" required="true" />
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfargument name="eventParameter" type="string" required="true" />
		
		<cfset var params = parseRouteParams(arguments.urlElements) />

		<cfif getModuleName() eq "">
			<cfset params[arguments.eventParameter] = getEventName() />
		<cfelse>
			<cfset params[arguments.eventParameter] = getModuleName() & arguments.moduleDelimiter & getEventName() />
		</cfif>
		
		 <!---
		 Debugging code: Please do not uncommment
		 <cfdump var="#getRequiredParameters()#" label="required params">
		 <cfdump var="#getOptionalParameters()#" label="optional params">
		 <cfdump var="#params#" />
		 <cfabort />
		 --->   
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="parseRouteParams" access="public" returntype="struct" output="false"
		hint="Used in the RequestManager to form the current route url for buildCurrentUrl().">
		<cfargument name="urlElements" type="array" required="true" />
		
		<cfset var params = StructNew() />
		<cfset var i = 0 />
		<cfset var totalArgCount = ListLen(getRequiredParameters()) + ListLen(getOptionalParameters()) />
		<cfset var totalArgsProcessed = 0 />
		<cfset var element = "" />
		
		<!---
		Debugging code: Please do not uncomment
		<cfdump var="#arguments.urlElements#" />
		<cfabort />
		--->
		
		<cfif ArrayLen(arguments.urlElements) GT 1>
			
			<!--- Start at position 2 since position 1 was the route name --->
			<cfloop from="2" to="#ArrayLen(arguments.urlElements)#" index="i">
				<cfif ListLen(getRequiredParameters()) gte i - 1>
					<cfset params[ListGetAt(ListGetAt(getRequiredParameters(), i - 1), 1, ":")] = arguments.urlElements[i] />
				<cfelse>
					<!--- <cftrace text="element #i#, ListLen(getRequiredParameters()) = #ListLen(getRequiredParameters())#" /> --->
					<cfset params[ListGetAt(ListGetAt(getOptionalParameters(), (i - ListLen(getRequiredParameters()) - 1)), 1, ":")] = arguments.urlElements[i] />
				</cfif>
				<!--- <cftrace text="i = #i#"> --->
			</cfloop>
			
			<!--- Hold total number of url args processed not counting the route name --->
			<cfset totalArgsProcessed = i - 2 />
	
			<!---
			Debugging code: Please do not uncomment
			<cftrace text="totalArgsProcessed = #totalArgsProcessed#, totalArgCount = #totalArgCount#"/>
			--->
	
			<!--- Handle optionalArguments and add in defaults --->	
			<cfif totalArgsProcessed lt totalArgCount>
				<cfloop from="#totalArgsProcessed#" to="#totalArgCount - 1#" index="i">
					<!--- <cftrace text="optional element #i# at #(totalArgCount - i)# " />  --->
					<cfset element = ListGetAt(getOptionalParameters(), (totalArgCount - i)) />
					<cfif ListLen(element, ":") gt 1>
						<cfset params[ListGetAt(element, 1, ":")] = ListGetAt(element, 2, ":") />
					</cfif>
				</cfloop>
			</cfif>
		
		</cfif>
		
		<!---
		Debugging code: Please do not uncomment
		<cfdump var="#params#" />
		<cfabort />
		--->
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="buildRouteUrl" access="public" returntype="string" output="false"
		hint="Builds a URL that matches this route definition.">
		<cfargument name="urlParameters" type="struct" required="true"
			hint="Name/value pairs to build the url with a struct of data." />
		<cfargument name="queryStringParameters" type="struct" required="false" default="#StructNew()#"
			hint="Name/value pairs to build the query string with a struct of data." />
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
		<cfloop list="#getRequiredParameters()#" index="i">
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
		
		<cfloop list="#getOptionalParameters()#" index="i">
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
				<cfset queryString = queryString & "/" & URLEncodedFormat(orderedParams[i].value) />
			</cfif>
		</cfloop>
		
		<!--- Prepend the urlBase and add trailing series delimiter --->
		<cfif Len(queryString)>
			<cfset builtUrl = arguments.urlBase & "/" & queryString />
			<cfif arguments.seriesDelimiter NEQ "&">
				<cfset builtUrl = builtUrl & arguments.seriesDelimiter />
			</cfif>
		<cfelse>
			<cfset builtUrl = arguments.urlBase />
		</cfif>
		
		<!--- Add any additional query string parameters from arguments.queryStringParameters --->
		<cfif StructKeyList(arguments.queryStringParameters) neq "">
			<cfset builtUrl = builtUrl & "?" />
			<cfset i = 1>
			<cfloop collection="#arguments.queryStringParameters#" item="param">
				<cfif i gt 1><cfset builtUrl = builtUrl & "&" /></cfif>
				<cfset builtUrl = builtUrl & param & "=" & URLEncodedFormat(arguments.queryStringParameters[param]) />
				<cfset i = i + 1 />
			</cfloop>
		</cfif>
		
		<cfreturn builtUrl />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->

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

	<cffunction name="setModuleName" access="public" returntype="void" output="false">
		<cfargument name="moduleName" type="string" required="true" />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>	
	<cffunction name="getModuleName" access="public" returntype="string" output="false">
		<cfreturn variables.moduleName />
	</cffunction>

	<cffunction name="setEventName" access="public" returntype="void" output="false">
		<cfargument name="eventName" type="string" required="true" />
		<cfset variables.eventName = arguments.eventName />
	</cffunction>	
	<cffunction name="getEventName" access="public" returntype="string" output="false">
		<cfreturn variables.eventName />
	</cffunction>

	<cffunction name="setUrlAlias" access="public" returntype="void" output="false">
		<cfargument name="urlAlias" type="string" required="true" />
		<cfset variables.urlAlias = arguments.urlAlias />
	</cffunction>	
	<cffunction name="getUrlAlias" access="public" returntype="string" output="false">
		<cfreturn variables.urlAlias />
	</cffunction>

	<cffunction name="setRequiredParameters" access="public" returntype="void" output="false">
		<cfargument name="requiredParameters" type="string" required="true" />
		<cfset variables.requiredParameters = arguments.requiredParameters />
	</cffunction>	
	<cffunction name="getRequiredParameters" access="public" returntype="string" output="false">
		<cfreturn variables.requiredParameters />
	</cffunction>

	<cffunction name="setOptionalParameters" access="public" returntype="void" output="false">
		<cfargument name="optionalParameters" type="string" required="true" />
		
		<cfset var param = "" />
		
		<!--- Verify that all optional parameters have a default defined --->
		<cfloop list="#arguments.optionalParameters#" index="param">
			<cfif NOT ListLen(param, ":") eq 2>
				<cfthrow type="MachII.properties.UrlRoute.InvalidOptionalParams"
					message="The optional URL Route '#getName()#' with parameter '#listGetAt(param, 1, ":")#' does not have default defined.">
			</cfif>
		</cfloop>
		
		<cfset variables.optionalParameters = arguments.optionalParameters />
	</cffunction>	
	<cffunction name="getOptionalParameters" access="public" returntype="string" output="false">
		<cfreturn variables.optionalParameters />
	</cffunction>

</cfcomponent>