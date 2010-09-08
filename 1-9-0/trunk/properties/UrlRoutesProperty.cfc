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
Updated version: 1.8.1

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
	<cfset variables.rewriteStandardUrls = false />

	<cfset variables.RESERVED_PARAMETER_NAMES = "rewriteConfigFile" />
	<cfset variables.OWNER_ID = "_" & REReplaceNoCase(CreateUUID(), "[[:punct:]]", "", "ALL") />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property by building the routes.">

		<cfset var parameters = getParameters() />
		<cfset var parameterName = "" />
		<cfset var parameter = 0 />
		<cfset var i = 0 />
		<cfset var route = 0 />
		<cfset var currentModuleName = getAppManager().getModuleName() />

		<cfloop collection="#parameters#" item="parameterName">

			<cfset parameter = parameters[parameterName] />

			<cfif NOT ListFindNoCase(variables.RESERVED_PARAMETER_NAMES, parameterName)>

				<cfset getAssert().isTrue(StructKeyExists(parameter, "event")
						, "You must provide a struct key for 'event' for route '#parameterName#'") />

				<!--- Add the route name to the parameters so it can be use as an argument collection --->
				<cfset parameter.routeName = parameterName />

				<cfset addRouteByAttributes(argumentcollection=parameter) />
			</cfif>
		</cfloop>

		<!--- Process reserved parameters --->
		<cfif isParameterDefined("rewriteConfigFile")>
			<cfset parameter = getParameter("rewriteConfigFile") />

			<!--- Only process if rewriteFileOn is true --->
			<cfif StructKeyExists(parameter, "rewriteFileOn") AND parameter.rewriteFileOn>

				<!--- Compute filePath --->
				<cfif StructKeyExists(parameter, "filePath")>
					<cfset setRewriteConfigFile(parameter.filePath) />
				<cfelse>
					<cfif Len(currentModuleName)>
						<cfset setRewriteConfigFile("rewriteRules_#currentModuleName#.cfm") />
					<cfelse>
						<cfset setRewriteConfigFile("rewriteRules_base.cfm") />
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<!--- This operation must be done after all routes have been added --->
		<cfif Len(getRewriteConfigFile())>
			<cfset createRewriteConfigFile() />
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

		<cfif  StructKeyExists(arguments, "optionalParameters")>
			<cfset route.setOptionalParameters(evaluateParameters(arguments.optionalParameters)) />
		</cfif>

		<cfset addRoute(arguments.routeName, route) />
	</cffunction>

	<cffunction name="createRewriteConfigFile" access="public" returntype="void" output="false"
		hint="Creates a rewrite config file.">

		<cfset var lf = Chr(10) />
		<cfset var configFilePath = ExpandPath(getRewriteConfigFile()) />
		<cfset var contents = CreateObject("java", "java.lang.StringBuffer") />
		<cfset var requestManager = getAppManager().getRequestManager() />
		<cfset var eventParameter = getProperty("eventParameter") />
		<cfset var urlBase = getProperty("urlBase") />
		<cfset var rewriteBase = "" />
		<cfset var moduleName = getAppManager().getModuleName() />
		<cfset var names = variables.routeNames.toArray() />
		<cfset var route = 0 />
		<cfset var i = 0 />

		<!--- Clean up the appRoot --->
		<cfif Right(urlBase, 1) neq "/">
			<cfset urlBase = urlBase & "/" />
		</cfif>

		<!--- Build rewrite rules --->
		<!--- Some CFML engines do no obey enable cfouput only use cfsilent is required as well --->
		<cfset contents.append('#### <cfsilent><cfsetting enablecfoutputonly="true"/>' & lf) />
		<cfset contents.append("#### Date Generated: #dateFormat(now(), "m/d/yyyy")# #timeFormat(now(), "h:mm tt")#" & lf) />
		<cfset contents.append("#### Module Name: #moduleName#" & lf) />
		<cfset contents.append(lf) />
		<cfset contents.append("RewriteEngine on" & lf) />
		<cfset contents.append(lf) />

		<!---
			RewriteBase cannot be located in a basic http.conf or virtual host so only write
			it if the Mach-II application does not live in the root of the host.
		--->
		<cfif urlBase NEQ "/">

			<cfset contents.append("RewriteBase " & urlBase & lf) />
			<cfset contents.append(lf) />
			<cfset rewriteBase = "" />
		<cfelse>
			<cfset rewriteBase = "/" />
		</cfif>

		<!---
			Check if requested file name is a real file, directory or symbolic link before
			evaluating all the rewrite rules. This is for performance.
			
			We use document_root and request_uri because request_filename does not work unless nested in a <directory>
			node in Apache.  When nesting in a <directory> node and using a proxy to a servlet engine like Tomcat,
			none of the rewrite rules are checked.
		--->
		<cfset contents.append("#### Check if the requested file name is a real file for performance" & lf) />
		<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]" & lf) />
		<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d [OR]" & lf) />
		<cfset contents.append("RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -l" & lf) />	
		<cfset contents.append("RewriteRule ^(.*)$ - [PT,L]" & lf) />
		<cfset contents.append(lf) />

		<!--- Add standard url rule (e.g. with event parameter) --->
		<cfset contents.append("#### Rewrite any URIs that start with the event parameter" & lf) />
		<cfset contents.append("RewriteRule ^" & rewriteBase & eventParameter & "(/.*)?$ " & rewriteBase & "index.cfm/" & eventParameter & "/$1 [PT,L]" & lf) />
		<cfset contents.append(lf) />

		<!--- Add all the routes --->
		<cfset contents.append("#### Rewrite all URL routes" & lf) />
		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<cfset route = requestManager.getRoute(names[i]) />
			<!---
			 Because the base has been defined we dont use it here. Additionally we can end the rule without the
			 trailing forward slash as many users may not type this. If a slash is found then we can also grab any
			 other params that may or may not be following it. This allows us to match the following type of urls:

			 news
			 news/
			 news/1
			 news/1/
			 newsArticle
			 newsArticle/
			 newsArticle/1
			 newsArticle/1/

			 And if someone happened to type in: newss they would be routed to index.cfm/event/newss where the
			 exception handling of the framework could divert the missing event name (provided newss didnt exist)
			 --->
			<cfset contents.append("RewriteRule ^" & rewriteBase & route.getUrlAlias() & "(/.*)?$ " & rewriteBase & "index.cfm/" & route.getUrlAlias() & "$1 [PT,L]" & lf) />
		</cfloop>
		<cfset contents.append(lf) />
		
		<!--- Add a catch all to run all request through Mach-II if it's not a real file and there is not index.cfm in the URL  --->
		<cfif getProperty("urlExcludeEventParameter", false)>
			<cfset contents.append("#### Catch all for all requests if not a real file and does not contain index.cfm" & lf) />
			<cfset contents.append("RewriteCond $1 !^index\.cfm" & lf) />
			<cfset contents.append("RewriteRule ^" & rewriteBase & "(.*)?$ " & rewriteBase & "index.cfm$1 [PT,L]" & lf) />
			<cfset contents.append(lf) />
		</cfif>

		<!--- The ampersand in the middle of the append is so that CFEclipse does think this is invalid code --->
		<cfset contents.append('#### <cfsetting enablecfoutputonly="false"/></' & 'cfsilent>' & lf) />

		<!--- Write to file --->
		<cftry>
			<cffile action="write"
				file="#configFilePath#"
				output="#contents.toString()#"
				fixnewline="true" />
			<cfcatch type="any">
				<cfthrow type="MachII.properties.UrlRoutesProperty.RulesWritePermissions"
					message="Cannot write rewrite rules file to '#configFilePath#'. Does your CFML engine have write permissions to this directory?"
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>
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


	<!---
	ACCESSORS
	--->
	<cffunction name="setRewriteConfigFile" access="private" returntype="void" output="false">
		<cfargument name="rewriteConfigFile" type="string" required="true" />
		<cfset variables.rewriteConfigFile = arguments.rewriteConfigFile />
	</cffunction>
	<cffunction name="getRewriteConfigFile" access="public" returntype="string" output="false">
		<cfreturn variables.rewriteConfigFile />
	</cffunction>

</cfcomponent>