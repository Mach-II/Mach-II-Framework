<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.9.0

Notes:


Usage:
<property name="routes" type="MachII.properties.UrlRoutesProperty">
  <parameters>
	<parameter name="rewriteConfigFile">
		<!-- Creates file with Apache Rewrite rules for the routes so you can exclude index.cfm -->
		<struct>
			<key name="rewriteFileOn" value="true|false" />
			<key name="filePath" value=".htaccess" />
		</struct>
	</parameter>
    <parameter name="product">
      <struct>
         <key name="event" value="showProduct" />
         <key name="requiredParameters" value="productId,displayType:fancy" /><!-- You can also use a array here -->
		 <key name="optionalParameters" value="key" /><!-- You can also use a array here -->
     </struct>
    </parameter>
  </parameters>
</property>

Then in your view you can call the new buildRoute() method which, like buildURL(), handling creating the actual URL string
for you based the route configuration.

#BuildRouteUrl("product", "productId=#event.getArg('productId')#|displayType=fancy")#

BuildRoute then produces the following URL:

index.cfm/product/A12345/fancy/
--->
<cfcomponent
	displayname="UrlRoutesProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets up one or more routes which are configurable search engine friendly url schemes.">

	<!---
	PROPERTIES
	--->
	<cfset variables.routeNames = CreateObject("java", "java.util.HashSet").init() />
	<cfset variables.dummyEvent = CreateObject("component", "MachII.framework.Event").init() />
	<cfset variables.rewriteConfigFile = "" />
	<cfset variables.rewriteBaseFileName = "index.cfm" />

	<cfset variables.RESERVED_PARAMETER_NAMES = "rewriteConfigFile,urlParameterFormatters,rewriteBaseFileName" />
	<cfset variables.OWNER_ID = "_" & Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000)) />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property by building the routes.">

		<cfset var parameters = StructNew() />
		<cfset var parameterName = "" />
		<cfset var parameter = 0 />
		<cfset var i = 0 />
		<cfset var route = 0 />
		<cfset var currentModuleName = getAppManager().getModuleName() />
		
		<!--- Use StructAppend() we don't delete directly from the parameters --->
		<cfset StructAppend(parameters, getParameters()) />

		<!--- Process reserved parameters --->
		<cfif isParameterDefined("rewriteConfigFile")>
			<cfset parameter = getParameter("rewriteConfigFile") />

			<!--- Only process if rewriteFileOn is true --->
			<cfif StructKeyExists(parameter, "rewriteFileOn") AND parameter.rewriteFileOn>
				<cfset getAppManager().getRequestManager().setRewriteConfigFileOn(true) />

				<!--- Compute rewrite parameters if base module or base module did not set config file.--->
				<cfif NOT Len(currentModuleName) OR NOT Len(getAppManager().getRequestManager().getRewriteConfigFile())>
					<!--- Setup filePath --->
					<cfif StructKeyExists(parameter, "filePath")>
						<cfset getAppManager().getRequestManager().setRewriteConfigFile(parameter.filePath) />
					</cfif>
				</cfif>

				<cfif NOT Len(currentModuleName)>
					<!--- Setup baseFileName --->
					<cfif StructKeyExists(parameter, "baseFileName")>
						<cfset getAppManager().getRequestManager().setRewriteBaseFileName(parameters.baseFileName) />
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	
		<!--- Setup default url parameter formatter --->
		<cfset loadUrlParameterFormatter("default", "MachII.framework.url.DefaultUrlParameterFormatter") />
		
		<!--- Load url parameter formatters if any are defined --->
		<cfif isParameterDefined("urlParameterFormatters")>
			<cfset parameters = getParameter("urlParameterFormatters") />
			
			<cfloop collection="#parameters#" item="parameterName">
				<cfset loadUrlParameterFormatter(parameterName, parameters[parameterName]) />
			</cfloop>
		</cfif>
		
		<!--- Remove all reserved parameter names from our local reference of parameters --->
		<cfloop list="#variables.RESERVED_PARAMETER_NAMES#" index="i">
			<cfset StructDelete(parameters, i, false) />
		</cfloop>

		<!--- Loop over the url routes --->
		<cfloop collection="#parameters#" item="parameterName">

			<cfset parameter = parameters[parameterName] />

			<cfset getAssert().isTrue(StructKeyExists(parameter, "event")
					, "You must provide a struct key for 'event' for route '#parameterName#'") />

			<!--- Add the route name to the parameters so it can be use as an argument collection --->
			<cfset parameter.routeName = parameterName />

			<cfset addRouteByAttributes(argumentcollection=parameter) />
		</cfloop>

		<!--- This operation must be done if this object was reload manually or the entire module is being reloaded --->
		<cfif NOT getAppManager().isLoading() OR (IsObject(getAppManager().getParent()) AND NOT getAppManager().getParent().isLoading())>
			<cfset getAppManager().getRequestManager().createRewriteConfigFile() />
		</cfif>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the property by un-registering routes and route aliases.">

		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var names = variables.routeNames.toArray() />
		<cfset var aliases = "" />
		<cfset var i = 0 />

		<!--- Removes this property's routes --->
		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<!--- Remove route --->
			<cfset requestManager.removeRoute(names[i], variables.OWNER_ID) />
		</cfloop>

		<!--- Clear route names --->
		<cfset variables.routeNames.clear() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addRoute" access="public" returntype="void" output="false"
		hint="Adds a route by name and UrlRoute object.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="route" type="MachII.framework.url.UrlRoute" required="true" />

		<!--- Insert the owner ID so we can know which routes are managed by this property --->
		<cfset arguments.route.setOwnerId(variables.OWNER_ID) />

		<!---
			We need a local list of names because if the deconfigure() is run we have to remove the routes from
			the RequestManager which is a singleton.

			Lists can be really slow if there are a lot of routes or aliases so a HashSet is used for names and
			aliases as it is consistent speed-wise as the dataset grows (see clearCache() in CacheHandler).
		--->
		<cfset variables.routeNames.add(arguments.routeName) />

		<cfset getAppManager().getRequestManager().addRoute(arguments.routeName, arguments.route, true) />
	</cffunction>
	
	<cffunction name="removeRoute" access="public" returntype="void" output="false"
		hint="Removes a route by name.">
		<cfargument name="routeName" type="string" required="true" />
		
		<cfset variables.routeNames.remove(arguments.routeName) />

		<cfset getAppManager().getRequestManager().removeRoute(arguments.routeName) />
	</cffunction>

	<cffunction name="addRouteByAttributes" access="public" returntype="void" output="false"
		hint="Adds a route by attributes.">
		<cfargument name="routeName" type="string" required="true" />
		<cfargument name="event" type="string" required="true" />
		<cfargument name="module" type="string" required="false" />
		<cfargument name="urlAlias" type="string" required="false" />
		<cfargument name="requiredParameters" type="any" required="false"
			hint="An array or comma-delimited list of required parameters." />
		<cfargument name="optionalParameters" type="any" required="false"
			hint="An array or comma-delimited list of optional parameters." />

		<cfset var route = CreateObject("component", "MachII.framework.url.UrlRoute").init(arguments.routeName) />

		<cfset route.setEventName(arguments.event) />
		<cfset route.setUrlParameterFormatters(getUrlParameterFormatters()) />
		<cfset route.setZeroLengthStringRepresentation(getProperty("urlZeroLengthStringRepresentation")) />

		<cfif  StructKeyExists(arguments, "module")>
			<cfset route.setModuleName(arguments.module) />
		<cfelse>
			<cfset route.setModuleName(getAppManager().getModuleName()) />
		</cfif>

		<cfif StructKeyExists(arguments, "urlAlias")>
			<cfset route.setUrlAlias(arguments.urlAlias) />
		</cfif>

		<cfif StructKeyExists(arguments, "requiredParameters")>
			<cfset route.setRequiredParameters(evaluateParameters(arguments.requiredParameters)) />
		</cfif>

		<cfif StructKeyExists(arguments, "optionalParameters")>
			<cfset route.setOptionalParameters(evaluateParameters(arguments.optionalParameters)) />
		</cfif>

		<cfset addRoute(arguments.routeName, route) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="parseParameter" access="private" returntype="string" output="false">
		<cfargument name="param" type="string" required="true" />

		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />
		<cfset var parsedParam = arguments.param />

		<cfif ListLen(parsedParam, ":") EQ 2>
			<cfif expressionEvaluator.isExpression(ListGetAt(parsedParam, 2, ":"))>
				<cfset parsedParam = ListSetAt(parsedParam, 2,
					expressionEvaluator.evaluateExpression(ListGetAt(parsedParam, 2, ":"), variables.dummyEvent, getAppManager().getPropertyManager()), ":") />
			</cfif>
		</cfif>

		<cfreturn parsedParam />
	</cffunction>

	<cffunction name="evaluateParameters" access="private" returntype="array" output="false"
		hint="Evaluates parameters (required and optional) and returns an evaluated array.">
		<cfargument name="parameters" type="any" required="true"
			hint="A list or array of parameters to evaluate." />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var i = 0 />

		<!--- Convert a list to array (and trim the list just in case) --->
		<cfif isSimpleValue(arguments.parameters)>
			<cfset arguments.parameters = ListToArray(utils.trimList(arguments.parameters)) />
		</cfif>

		<!--- Parse the array of parameters --->
		<cfloop from="1" to="#ArrayLen(arguments.parameters)#" index="i">
			<cfset arguments.parameters[i] = parseParameter(arguments.parameters[i]) />
		</cfloop>

		<cfreturn arguments.parameters />
	</cffunction>

	<cffunction name="loadUrlParameterFormatter" access="private" returntype="void" output="false"
		hint="Loads an URL parameter formatter.">
		<cfargument name="name" type="string" required="true"
			hint="The name of the formatter." />
		<cfargument name="type" type="string" required="true"
			hint="The type of the formatter." />
		
		<cfset var formatter = CreateObject("component", arguments.type).init() />
		
		<cfset variables.urlParameterFormatters[arguments.name] = formatter />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setUrlParameterFormatters" access="private" returntype="void" output="false">
		<cfargument name="urlParameterFormatters" type="struct" required="true" />
		<cfset variables.urlParameterFormatters = arguments.urlParameterFormatters />
	</cffunction>
	<cffunction name="getUrlParameterFormatters" access="public" returntype="struct" output="false">
		<cfreturn variables.urlParameterFormatters />
	</cffunction>

</cfcomponent>