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

Author: Doug Smith (doug.smith@daveramsey.com)
$Id: $

Created version: 1.9.0

Notes:

All user-defined REST Endpoints must extend this base component. REST endpoints
define a URL and HTTP Request method (GET, POST, PUT, DELETE) through annotations
attached to functions in the subclasses of RestEndpoint.

REST Endpoint URLs bypass most of the Mach-II request lifecycle and quickly
execute the called method.

To Test it out, do the following:

1. 	In a new Mach-II app, add this to the Mach-II config:

	<properties>
		<property name="endpoint" type="MachII.endpoints.EndpointConfigProperty">
			<parameters>
				<parameter name="test">
					<struct>
						<key name="type" value="MachII.tests.dummy.DummyRestEndpoint"/>
					</struct>
				</parameter>
			</parameters>
		</property>
	</properties>

2. 	Setup a web server like Apache to route all non-file URLs to your ColdFusion app:

	RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
	RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-d
	RewriteRule "^/(.*)$" "/index.cfm/$1" [C,QSA]

3. 	Setup your Coldfusion app to route all requests to /index.cfm/* so the PATH_INFO
	from all requests will be routed to Mach-II. On Adobe CF, you can use:

	<servlet-mapping id="coldfusion_mapping_7">
		<servlet-name>CfmServlet</servlet-name>
		<url-pattern>/index.cfm/*</url-pattern>
	</servlet-mapping>

4.	Start the app, and test these URLs:

	* http://<yourapp>/content/item/blah - should return HTML content, and 'blah' can be changed.
	* http://<yourapp>/content/item/something-else.json - returns a JSON structure.
	* http://<yourapp>/content/item/notfound - throws a 404.

TODO: Write more about REST Endpoints, including good API design, expectation
to return good responses and response codes, use of format (.json), etc.

--->
<cfcomponent
	displayname="RestEndpoint"
	extends="MachII.endpoints.AbstractEndpoint"
	output="false"
	hint="Base endpoint for all RESTful endpoints to be exposed directly by Mach-II.">

	<!---
	CONSTANTS
	--->
	<!--- Constants for the annotations we allow in RestEndpoint sub-classes --->
	<cfset variables.ANNOTATION_REST_BASE = "REST" />
	<cfset variables.ANNOTATION_REST_URI = variables.ANNOTATION_REST_BASE & ":URI" />
	<cfset variables.ANNOTATION_REST_METHOD = variables.ANNOTATION_REST_BASE & ":METHOD" />

	<!---
	PROPERTIES
	--->
	<!--- RestUriCollection of URLs that match in this endpoint. --->
	<cfset variables.restUris = "" />
	<!--- Introspector looks for REST:* annotations in child classes to find REST-enabled methods. --->
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector") />
	<cfset variables.restUris = CreateObject("component", "MachII.endpoints.rest.UriCollection").init() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Child endpoints must call this configure method to setup the RESTful methods correctly.">

		<cfset var restMethodMetadata = variables.introspector.findFunctionsWithAnnotations(object:this, namespace:variables.ANNOTATION_REST_BASE) />
		<cfset var currMetadata = "" />
		<cfset var currFunction = "" />
		<cfset var currRestUri = "" />
		<cfset var currHttpMethod = "" />
		<cfset var i = 0 />

		<cfif ArrayLen(restMethodMetadata)>
			<!--- TODO: Limiting to the base component for now, not following whole object hierarchy yet. --->
			<cfset currMetadata = restMethodMetadata[1] />

			<cfif StructKeyExists(currMetadata, "functions")>
				<cfloop from="1" to="#ArrayLen(currMetadata.functions)#" index="i">
					<!--- Iterate through found methods and look for required REST:URI annotation --->
					<cfset currFunction = currMetadata.functions[i] />
					<cfif StructKeyExists(currFunction, variables.ANNOTATION_REST_URI)>
						<!--- Default to GET method --->
						<cfif StructKeyExists(currFunction, ANNOTATION_REST_METHOD)>
							<cfset currHttpMethod = currFunction[variables.ANNOTATION_REST_METHOD] />
						<cfelse>
							<cfset currHttpMethod = "GET" />
						</cfif>
						<!--- Create instance of RestUri and add it to the RestUriCollection. --->
						<cfset currRestUri = CreateObject("component", "MachII.endpoints.rest.Uri").init(
								currFunction[variables.ANNOTATION_REST_URI]
								, currHttpMethod
								, currFunction.name
								, getParameter("name")
							) />
						<cfset variables.restUris.addRestUri(currRestUri) />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Reset the endpoint to a default state.">
		<cfset variables.restUris.resetRestUris() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Calls the defined REST Endpoint function and renders the response.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var restResponseBody = callEndpointFunction(event) />

		<cfsetting enablecfoutputonly="false" /><cfoutput>#restResponseBody#</cfoutput><cfsetting enablecfoutputonly="true" />
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request end. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overridden." />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="callEndpointFunction" access="public" returntype="String" output="true"
		hint="Calls the endpoint function linked to the input RestUri (in event arg), passing the parsed URI tokens as arguments to the function.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var responseBody = "" />
		<cfset var restUri = event.getArg("restUri") />
		<cfset var pathInfo = event.getArg("pathInfo") />
		<cfset var endpoint = getEndpointManager().getEndpointByName(restUri.getEndpointName()) />
		<cfset var urlTokens = restUri.getTokensFromUri(pathInfo) />
		<cfset var currToken = "" />

		<!--- Add any parsed tokens from the input pathInfo to the event unless they're already there. --->
		<cfloop collection="#urlTokens#" item="currToken">
			<cfif NOT event.isArgDefined(currToken)>
				<cfset event.setArg(currToken, urlTokens[currToken]) />
			</cfif>
		</cfloop>

		<cfif restUri.matchUri(pathInfo)>
			<!--- Call the function --->
			<cfinvoke
				component="#endpoint#"
				method="#restUri.getFunctionName()#"
				returnVariable="responseBody"
				event="#event#" />
		</cfif>

		<cfreturn responseBody />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->

	<cffunction name="addContentTypeHeaderFromFormat" access="private" returntype="void" output="false"
		hint="Adds a Content-Type response header based on the input format.">
		<cfargument name="format" type="String" required="true" />

		<!--- Would have used a struct literal but unsure of CFML engine compatibility --->
		<!--- TODO: More to add here. --->
		<cfswitch expression="#arguments.format#">
			<cfcase value="json">
				<cfheader name="Content-Type" value="application/json" />
			</cfcase>
			<cfcase value="txt">
				<cfheader name="Content-Type" value="text/plain" />
			</cfcase>
			<cfdefaultcase>
				<cfheader name="Content-Type" value="text/html" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getRestUris" access="public" returntype="Struct" output="false">
		<cfreturn variables.restUris />
	</cffunction>

</cfcomponent>