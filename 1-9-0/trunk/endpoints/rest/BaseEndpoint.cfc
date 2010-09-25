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
$Id$

Created version: 1.9.0

Notes:

All user-defined REST Endpoints must extend this base component. REST endpoints
define a URL and HTTP Request method (GET, POST, PUT, DELETE) through annotations
attached to functions in the subclasses of RestEndpoint.

REST Endpoint URLs bypass most of the Mach-II request lifecycle and quickly
execute the called method.

To Test it out, do the following:

1. 	In a new Mach-II app, add this to the Mach-II config:

	<endpoints>
		<endpoint name="test" type" value="MachII.tests.dummy.DummyRestEndpoint">
			<parameters>
				<!--
					Optionally sets the default return format (MIME type) of the request 
					if not defined in the url (defaults to html if not defined)
				-->
				<parameter name="defaultFormat" value="json" />
			</parameters>
		</endpoint>
	</endpoints>

2. 	Setup a web server like Apache to route all non-file URLs to your CFML app.

	RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
	RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-d
	RewriteRule "^/(.*)$" "/index.cfm/$1" [C,QSA]

3. 	Setup your CFML app to route all requests to /index.cfm/* so the PATH_INFO
	from all requests will be routed to Mach-II. On Adobe CF, you can use:

	<servlet-mapping id="coldfusion_mapping_7">
		<servlet-name>CfmServlet</servlet-name>
		<url-pattern>/index.cfm/*</url-pattern>
	</servlet-mapping>
	
	You can all other mapping in other servlet engines like Tomcat by looking in
	the web.xml file in the servlet roo base path.

4.	Start the app, and test these URLs:

	* http://<yourapp>/content/item/blah - should return HTML content, and 'blah' can be changed.
	* http://<yourapp>/content/item/something-else.json - returns a JSON structure.
	* http://<yourapp>/content/item/notfound - throws a 404.

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
	<!--- Introspector looks for REST:* annotations in child classes to find REST-enabled methods. --->
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	<!--- UriCollection of rest.Uris that match in this endpoint. --->
	<cfset variables.restUris = CreateObject("component", "MachII.endpoints.rest.UriCollection").init() />
	<!--- The default format returned by an endpoint. Overridden by file extension in URL (/url.json), or
	      it can be overridden in a subclass using setDefaultFormat(). --->
	<cfset variables.defaultFormat = "html" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Child endpoints must call this configure method [i.e. super.configure()] to setup the RESTful methods correctly.">
		
		<!--- Configure any parameters --->
		<cfset setDefaultFormat(getParameter("defaultFormat", "html")) />	
		
		<cfset setupRestMethods() />
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

		<cfset var pathInfo = getUtils().cleanPathInfo(cgi.PATH_INFO, cgi.SCRIPT_NAME) />

		<cfif NOT Len(pathInfo) AND arguments.event.isArgDefined("uri")>
			<!--- Support URI without pathInfo, but with query string of ?endpoint=<name>&uri=<restUri> --->
			<cfset arguments.event.setArg("pathInfo", arguments.event.getArg("uri")) />
		<cfelse>
			<cfset arguments.event.setArg("pathInfo", pathInfo) />
		</cfif>

		<cfset arguments.event.setArg("httpMethod", CGI.REQUEST_METHOD) />

		<cfif ListContainsNoCase("PUT,POST", CGI.REQUEST_METHOD)>
			<cfset arguments.event.setArg("rawContent", cleanRawContent()) />
		</cfif>
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Calls the defined REST Endpoint function and renders the response.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var pathInfo = arguments.event.getArg("pathInfo", "") />
		<cfset var httpMethod = arguments.event.getArg("httpMethod", "") />
		<cfset var restUri = variables.restUris.findRestUri(pathInfo, httpMethod) />
		<cfset var restResponseBody = "" />

		<cfif IsObject(restUri)>
			<cfset restResponseBody = callEndpointFunction(restUri, event) />
			<cfset addContentTypeHeaderFromFormat(event.getArg("format", "")) />
			<cfsetting enablecfoutputonly="false" /><cfoutput>#restResponseBody#</cfoutput><cfsetting enablecfoutputonly="true" />
		<cfelse>
			<cfthrow type="MachII.endpoints.EndpointNotDefined"
				message="No REST URI was found for '#pathInfo#', httpMethod='#httpMethod#'."
				detail="" />
		</cfif>

	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="callEndpointFunction" access="public" returntype="string" output="false"
		hint="Calls the endpoint function linked to the input RestUri (in event arg), passing the parsed URI tokens as arguments to the function.">
		<cfargument name="restUri" type="MachII.endpoints.rest.Uri" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var responseBody = "" />
		<cfset var pathInfo = arguments.event.getArg("pathInfo") />
		<cfset var urlTokens = arguments.restUri.getTokensFromUri(pathInfo) />
		<cfset var currToken = "" />

		<!--- Add any parsed tokens from the input pathInfo to the event unless they're already there --->
		<cfloop collection="#urlTokens#" item="currToken">
			<cfif NOT event.isArgDefined(currToken)>
				<cfset event.setArg(currToken, urlTokens[currToken]) />
			</cfif>
		</cfloop>

		<cfif restUri.matchUri(pathInfo)>
			<!--- Call the function --->
			<cfinvoke
				component="#this#"
				method="#restUri.getFunctionName()#"
				returnVariable="responseBody">
				<cfinvokeargument name="event" value="#arguments.event#" />
			</cfinvoke>
		</cfif>

		<cfreturn responseBody />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="addContentTypeHeaderFromFormat" access="private" returntype="void" output="false"
		hint="Adds a Content-Type response header based on the input format.">
		<cfargument name="format" type="string" required="true"
			hint="The incoming format type to add as header." />

		<cfset var contentType = "" />

		<cftry>
			<!--- Default content type: html --->
			<cfif NOT Len(arguments.format)>
				<cfset arguments.format = variables.defaultFormat />
			</cfif>
			<cfif NOT(arguments.format.startsWith("."))>
				<cfset arguments.format = ".#arguments.format#" />
			</cfif>
			<!--- Leverage this nicely provided utility method --->
			<cfset contentType = getUtils().getMimeTypeByFileExtension(arguments.format) />

			<!--- Add the Content-Type header --->
			<cfheader name="Content-Type" value="#contentType#" />

			<cfcatch type="any">
				<!--- Log exception --->
				<cfset getLog().error("MachII.endpoints.rest.BaseEndpoint: Could not find Content-Type for input format: '#arguments.format#'.", cfcatch) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="cleanRawContent" access="private" returntype="any" output="false"
		hint="Processes the raw request content and returns it. Sometimes the content is received as a byte array, when it is a valid string. Uses the Content-Type header to try and discern whether to cast the body as a String.">

		<cfset var headers = GetHttpRequestData().headers />
		<cfset var rawContent = GetHttpRequestData().content />
		<cfset var contentType = "" />

		<!--- If the content type is present, and is a text type, and is an array, cast it to a String. --->
		<!--- Comprehensive list of content-type header values: http://www.iana.org/assignments/media-types/index.html --->
		<cfif StructKeyExists(headers, "Content-Type")>
			<cfset contentType = headers["Content-Type"] />
			<cfif IsArray(rawContent) AND ArrayLen(rawContent)>
				<cfif REFindNoCase('text\/|xml|json', contentType)>
					<cfset rawContent = ToString(rawContent) />
				</cfif>
			</cfif>
		</cfif>

		<cfreturn rawContent />
	</cffunction>
	
	<cffunction name="setupRestMethods" access="private" returntype="void" output="false"
		hint="Setups the REST methods by introspecting the metadata. This method is recursive and look through all the object hierarchy until the stop base class.">
		<cfargument name="restMethodMetadata" type="array" required="false"
			default="#variables.introspector.findFunctionsWithAnnotations(object:this, namespace:variables.ANNOTATION_REST_BASE, walkTree:true, walkTreeStopClass:'MachII.endpoints.rest.BaseEndpoint')#"
			hint="An array of metadata to discover any REST methods in." />
		
		<cfset var currMetadata = "" />
		<cfset var currFunction = "" />
		<cfset var currRestUri = "" />
		<cfset var currHttpMethod = "" />
		<cfset var i = 0 />

		<cfif ArrayLen(arguments.restMethodMetadata)>
			<cfset currMetadata = arguments.restMethodMetadata[1] />

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
			
			<!--- Pop off the current level of metadata and recurse until the stop class if required --->
			<cfset ArrayDeleteAt(arguments.restMethodMetadata, 1) />
			
			<cfif ArrayLen(arguments.restMethodMetadata)>
				<cfset setupRestMethods(arguments.restMethodMetadata) />
			</cfif>
		</cfif>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getRestUris" access="public" returntype="struct" output="false"
		hint="Gets the REST URIs collection object.">
		<cfreturn variables.restUris />
	</cffunction>

	<cffunction name="setDefaultFormat" access="public" returntype="void" output="false"
		hint="Set this to override the defaultFormat.">
		<cfargument name="defaultFormat" type="string" required="true" />
		
		<cfset var mimeTypeMap = getUtils().getMimeTypeMap() />
		
		<cfif StructKeyExists(mimeTypeMap, arguments.defaultFormat)>
			<cfset variables.defaultFormat = arguments.defaultFormat />
		<cfelse>
			<cfthrow type="MachII.framework.InvalidFormatType"
				message="Cannot set the defaultFormat to '#arguments.defaultFormat#', not in the Mach-II mimeTypeMap." />
		</cfif>
	</cffunction>
	<cffunction name="getDefaultFormat" access="public" returntype="string" output="false"
		hint="Gets the default format MIME type.">
		<cfreturn variables.defaultFormat />
	</cffunction>

</cfcomponent>