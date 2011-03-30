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
					Sets whether to use the value from urlBase or urlBaseSecure which 
					indicates HTTPS/SSL URL base. Defaults to value from property.urlBase
				-->
				<parameter name="secure" value="false" />
				<!--
					Optionally sets the default return format (MIME type) of the request
					if not defined in the url (defaults to html if not defined)
				-->
				<parameter name="defaultFormat" value="html" />
				<!--
					Optionally sets the default return charset of the request. Defaults
					to ISO-8859-1 if not defined (standard HTTP response charset).
				-->
				<parameter name="defaultCharset" value="" />
				<!--
					Optionally sets the event arg name to use as the value to wrap
					JsonP requests. Defaults to 'jsonp'
				-->
				<parameter name="jsonpArgName" value="jsonp" />
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
	<cfset variables.ANNOTATION_REST_AUTHENTICATE = variables.ANNOTATION_REST_BASE & ":AUTHENTICATE" />
	<!--- Other constants --->
	<cfset variables.DEFAULT_FORMAT_LIST = "htm,html,json,xml,txt" />

	<!---
	PROPERTIES
	--->
	<!--- Introspector looks for REST:* annotations in child classes to find REST-enabled methods. --->
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	<!--- UriCollection of REST Uris that match in this endpoint. --->
	<cfset variables.restUris = CreateObject("component", "MachII.framework.url.UriCollection").init() />
	<!---
		The default format returned by an endpoint. Overridden by file extension in URL (/url.json), or
	    it can be overridden by defining the "defaultFormat" parameter.
	--->
	<cfset variables.defaultFormat = "html" />
	<cfset variables.defaultCharset = "" />
	<cfset variables.possibleFormatList = variables.DEFAULT_FORMAT_LIST />
	<cfset variables.authenticateDefault = false />
	<cfset variables.enforceContentLengthDefault =  true />
	<cfset variables.jsonpArgName = "jsonp" />

	<cfset variables.exceptionTypes = StructNew() />
	<cfset variables.exceptionTypes["IncompleteBody"] = "MachII.endpoints.rest.IncompleteBody" />
	<cfset variables.exceptionTypes["MethodNotAllowed"] = "MachII.endpoints.rest.MethodNotAllowed" />
	<cfset variables.exceptionTypes["MissingContentLength"] = "MachII.endpoints.rest.MissingContentLength" />
	<cfset variables.exceptionTypes["NoSuchResource"] = "MachII.endpoints.rest.NoSuchResource" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Child endpoints must call this configure method [i.e. super.configure()] to setup the RESTful methods correctly.">

		<!--- Configure any parameters --->
		<cfif getParameter("secure", false)>
			<cfset setUrlBase(getProperty("urlBaseSecure")) />
		<cfelse>
			<cfset setUrlBase(getProperty("urlBase")) />
		</cfif>
		<cfset setDefaultFormat(getParameter("defaultFormat", variables.defaultFormat)) />
		<cfset setDefaultCharset(getParameter("defaultCharset", variables.defaultCharset)) />
		<cfset setJsonpArgName(getParameter("jsonpArgName", variables.jsonpArgName)) />
		<cfset setPossibleFormatList(getParameter("possibleFormatList", variables.DEFAULT_FORMAT_LIST)) />

		<cfset setupRestComponent() />
		<cfset setupRestMethods() />
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Reset the endpoint to a default state.">
		<cfset variables.restUris.resetUris() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - ENDPOINT REQUEST HANDLING
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<!--- Don't get cleaned path info that is urlDecoded --->
		<cfset var pathInfo = getUtils().cleanPathInfo(cgi.PATH_INFO, cgi.SCRIPT_NAME, false) />
		<cfset var httpMethod = discoverHttpMethod(arguments.event) />
		<cfset var restUri = "" />
		<cfset var headers = "" />
		<cfset var urlTokens = "" />
		<cfset var currToken = "" />

		<!--- Support query string of ?endpoint=<name>&uri=<restUri> --->
		<cfif arguments.event.isArgDefined("uri")>
			<cfset pathInfo = arguments.event.getArg("uri") />
		</cfif>

		<cfset arguments.event.setArg("_requestPathInfo", pathInfo) />
		<cfset arguments.event.setArg("_requestMethod", httpMethod) />

		<!--- Find the REST URI --->
		<cfset restUri = variables.restUris.findUriByPathInfo(pathInfo, httpMethod) />

		<!--- Handle REST object request if we have a URI to process --->
		<cfif IsObject(restUri)>
			<cfset arguments.event.setArg("restUri", restUri) />

			<!--- Add any parsed tokens from the input pathInfo to the event unless they're already there --->
			<cfset urlTokens = restUri.getTokensFromUri(pathInfo) />
			<cfloop collection="#urlTokens#" item="currToken">
				<cfif NOT arguments.event.isArgDefined(currToken)>
					<cfset arguments.event.setArg(currToken, urlTokens[currToken]) />
				</cfif>
			</cfloop>

			<!--- Process data specific to PUT and POST type requests --->
			<cfif ListContainsNoCase("PUT,POST", httpMethod)>
				<cfset arguments.event.setArg("_requestBody", cleanRawContent()) />

				<!--- Perform content-length checks if required --->
				<cfif variables.enforceContentLengthDefault>
					<cfset performContentLengthChecks(arguments.event) />
				</cfif>
			</cfif>
		
		<!--- No URI object for REST request so handle exception --->
		<cfelse>
			<cfif Len(restUri)>
				<cfthrow type="#variables.exceptionTypes["MethodNotAllowed"]#"
					message="A request was made to a REST URI was found for '#pathInfo#' but the httpMethod='#httpMethod#' was incorrect. This resource can only be used with the following HTTP methods '#restUri#'." />
			<cfelse>
				<cfthrow type="#variables.exceptionTypes["NoSuchResource"]#"
					message="A request was made to a REST URI which cannot be found with '#pathInfo#' with httpMethod='#httpMethod#'. No resource can be found that matches with any other HTTP method type either." />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Calls the defined REST Endpoint function and renders the response.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var restUri =  arguments.event.getArg("restUri") />
		<cfset var restResponseBody = callEndpointFunction(restUri, arguments.event) />
		<cfset var format = arguments.event.getArg("format") />

		<cfif NOT Len(format) AND Len(restUri.getUriMetadataParameters().defaultReturnFormat)>
			<cfset format = restUri.getUriMetadataParameters().defaultReturnFormat />
		<cfelse>
			<cfset format = getDefaultFormat() />
		</cfif>

		<cfif format EQ "json" AND arguments.event.isArgDefined(getJsonpArgName())>
			<cfset restResponseBody = arguments.event.getArg(getJsonpArgName()) & "(" & restResponseBody & ")" />
			<cfset format = "jsonp" />
		</cfif>
		
		<cfset arguments.event.setArg("_responseFormat", format) />
		<cfset arguments.event.setArg("_responseContentType", addContentTypeHeaderFromFormat(format)) />

		<cfsetting enablecfoutputonly="false" /><cfoutput>#restResponseBody#</cfoutput><cfsetting enablecfoutputonly="true" />
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true"
		hint="Runs when an exception occurs in the endpoint. Override to provide custom functionality and call super.onException() for basic error handling.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception that was thrown/caught by the endpoint request processor." />

		<cfif exception.getType() EQ variables.exceptionTypes["MethodNotAllowed"]>
			<cfset addHTTPHeaderByStatus(405) />
			<cfset addHTTPHeaderByName("machii.endpoint.error", arguments.exception.getMessage()) />
			<cfsetting enablecfoutputonly="false" /><cfoutput>405 Method Not Allowed - #arguments.exception.getMessage()#</cfoutput><cfsetting enablecfoutputonly="true" />
		<cfelseif exception.getType() EQ variables.exceptionTypes["NoSuchResource"]>
			<cfset addHTTPHeaderByStatus(404) />
			<cfset addHTTPHeaderByName("machii.endpoint.error", arguments.exception.getMessage()) />
			<cfsetting enablecfoutputonly="false" /><cfoutput>404 Not Found - #arguments.exception.getMessage()#</cfoutput><cfsetting enablecfoutputonly="true" />
		<cfelse>
			<cfset super.onException(arguments.event, arguments.exception) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="callEndpointFunction" access="public" returntype="string" output="false"
		hint="Calls the endpoint function linked to the input RestUri (in event arg), passing the parsed URI tokens as arguments to the function.">
		<cfargument name="restUri" type="MachII.framework.url.Uri" required="true" />
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var responseBody = "" />
		<cfset var pathInfo = arguments.event.getArg("_requestPathInfo") />
		<cfset var stcArgs = "" />

		<cfif restUri.matchUri(pathInfo)>
			<cfset stcArgs = arguments.event.getArgs() />
			<cfset stcArgs.event = arguments.event />

			<!--- Call the function --->
			<cfinvoke
				component="#this#"
				method="#restUri.getFunctionName()#"
				returnVariable="responseBody"
				argumentCollection="#stcArgs#" />
		</cfif>

		<cfreturn responseBody />
	</cffunction>

	<cffunction name="buildEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an endpoint specific URL.">
		<cfargument name="method" type="string" required="true"
			hint="The method name used as a reference for REST URI. This argument must be passed if not included in the 'parameters' arguments."/>

		<cfset var restUri = "" />
		<cfset var uriPattern = "" />
		<cfset var uriTokenNames = "" />

		<cfset var builtUrl = getUrlBase() />
		<cfset var params = arguments />
		<cfset var sortedParams = "" />
		<cfset var i = 0 />

		<cfset restUri = variables.restUris.findUriByFunctionName(arguments.method) />

		<cfif IsObject(restUri)>

			<cfif NOT builtUrl.endsWith("/")>
				<cfset builtUrl = builtUrl & "/" />
			</cfif>

			<cfset builtUrl = builtUrl & getParameter("name") />

			<cfset uriPattern = restUri.getUriPattern() />

			<cfif NOT uriPattern.startsWith("/")>
				<cfset builtUrl = builtUrl & "/" />
			</cfif>

			<cfset builtUrl = builtUrl & uriPattern />

			<cfset uriTokenNames = restUri.getUriTokenNames() />

			<cfset StructDelete(params, "method", true) />

			<cftry>
				<cfloop array="#uriTokenNames#" index="i">
					<cfset builtUrl = ReplaceNoCase(builtUrl, "{#i#}",params[i], "one") />
					<cfset StructDelete(params, i, false) />
				</cfloop>
				<cfcatch type="any">
					<cfthrow type="MachII.endpoints.rest.MissingArgument"
						message="The '#uriTokenNames[i]#' parameter cannot be found for this REST method." />
				</cfcatch>
			</cftry>

			<!--- Add additional query string parameters if there are remaining params --->
			<cfif StructCount(params)>
				<cfset sortedParams = StructSort(params, "textnocase", "ASC") />

				<cfif NOT builtUrl.endsWith("/")>
					<cfset builtUrl = builtUrl & "/" />
				</cfif>

				<cfset builtUrl = builtUrl & "?" />

				<cfloop from="1" to="#ArrayLen(sortedParams)#" index="i">
					<cfset builtUrl = builtUrl & LCase(sortedParams[i]) & "=" & params[sortedParams[i]] />
				</cfloop>
			</cfif>
		<cfelse>
			<cfthrow type="MachII.endpoints.rest.InvalidMethod"
				message="The method named '#arguments.method#' is not defined in this REST implementation." />
		</cfif>

		<cfreturn builtUrl />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="addContentTypeHeaderFromFormat" access="private" returntype="string" output="false"
		hint="Adds a Content-Type response header based on the input format.">
		<cfargument name="format" type="string" required="true"
			hint="The incoming format type to add as header." />

		<cfset var contentType = "" />

		<cftry>
			<!--- Leverage this nicely provided utility method and no need to prefix with '.' when using 'evaluateAllAsFileExtensions' set to true --->
			<cfset contentType = getUtils().getMimeTypeByFileExtension(arguments.format, variables.customMimeTypeMap, true) />

			<!--- Add the Content-Type header --->
			<cfif Len(variables.defaultCharset)>
				<cfset contentType = contentType & ";charset=" & getDefaultCharset() />
			</cfif>
			<cfset addHTTPHeaderByName("Content-Type", contentType ) />

			<cfcatch type="any">
				<!--- Log exception --->
				<cfset getLog().error("MachII.endpoints.rest.BaseEndpoint: Could not find Content-Type for input format: '#arguments.format#'.", cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfreturn contentType />
	</cffunction>

	<cffunction name="performContentLengthChecks" access="private" returntype="void" output="false"
		hint="Performs content-length header and body checks.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var headers = GetHttpRequestData().headers />
		<cfset var contentType = "" />
		<cfset var charset = variables.defaultCharset />

		<cfif StructKeyExists(headers, "Content-Type")>
			<cfset contentType = headers["Content-Type"] />

			<!--- Find a charset in example "application/xml; charset=UTF-8"--->
			<cfif ListLen(contentType, ";") GTE 2>
				<cfset charset = Trim(ListGetAt(ListGetAt(contentType, 2, ";"), 2, "=")) />
			</cfif>
		</cfif>

		<!--- Check that the content-length header was sent --->
		<cfif NOT StructKeyExists(headers, "Content-Length")>
			<cfthrow type="#variables.exceptionTypes["MissingContentLength"]#" />
		<!--- Check that the number of bytes in the content-length header of the raw content equals the header value --->
		<cfelseif headers["Content-Length"] NEQ Len(arguments.event.getArg("_requestBody").getBytes(charset))>
			<cfthrow type="#variables.exceptionTypes["IncompleteBody"]#" />
		</cfif>
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
			<cfif IsArray(rawContent) AND ArrayLen(rawContent) OR IsBinary(rawContent)>
				<cfif REFindNoCase('xml|json', contentType)>
					<cfset rawContent = ToString(rawContent) />
				</cfif>
			</cfif>
		</cfif>

		<cfreturn rawContent />
	</cffunction>

	<cffunction name="discoverHttpMethod" access="private" returntype="string" output="false"
		hint="Discovers the http method by event-arg '_method', then 'x-http-method-override' header and finally cgi.REQUEST_METHOD.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var headers = GetHttpRequestData().headers />

		<!--- Order of evaluation is important --->
		<cfif arguments.event.isArgDefined("_method")>
			<cfreturn arguments.event.getArg("_method") />
		<cfelseif StructKeyExists(headers, "x-http-method-override")>
			<cfreturn headers["x-http-method-override"] />
		<cfelse>
			<cfreturn cgi.REQUEST_METHOD />
		</cfif>
	</cffunction>

	<cffunction name="setupRestComponent" access="private" returntyp="void" output="false"
		hint="Setups the REST component by introspecting the metadata. This method is recursive and looks through all the object hierarhcy until the stop base calls.">
		<cfargument name="restComponentMetadata" type="array" required="false"
			default="#variables.introspector.getComponentDefinition(object:this, walkTree:true, walkTreeStopClass:'MachII.endpoints.rest.BaseEndpoint')#"
			hint="An array of metadata to discover any REST component in." />

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(arguments.restComponentMetadata)#" index="i">
			<cfif StructKeyExists(arguments.restComponentMetadata[i], variables.ANNOTATION_REST_AUTHENTICATE)>
				<cfset setAuthenticateDefault(arguments.restComponentMetadata[i][variables.ANNOTATION_REST_AUTHENTICATE]) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setupRestMethods" access="private" returntype="void" output="false"
		hint="Setups the REST methods by introspecting the metadata. This method is recursive and looks through all the object hierarchy until the stop base class.">
		<cfargument name="restMethodMetadata" type="array" required="false"
			default="#variables.introspector.findFunctionsWithAnnotations(object:this, namespace:variables.ANNOTATION_REST_BASE, walkTree:true, walkTreeStopClass:'MachII.endpoints.rest.BaseEndpoint')#"
			hint="An array of metadata to discover any REST methods in." />

		<cfset var currMetadata = "" />
		<cfset var currFunction = "" />
		<cfset var currRestUri = "" />
		<cfset var currHttpMethods = "" />
		<cfset var currRestUriMetadata = StructNew() />
		<cfset var parameter = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var key = "" />

		<cfif ArrayLen(arguments.restMethodMetadata)>
			<cfset currMetadata = arguments.restMethodMetadata[1] />

			<cfif StructKeyExists(currMetadata, "functions")>
				<cfloop from="1" to="#ArrayLen(currMetadata.functions)#" index="i">
					<!--- Iterate through found methods and look for required REST:URI annotation --->
					<cfset currFunction = currMetadata.functions[i] />
					<cfif StructKeyExists(currFunction, variables.ANNOTATION_REST_URI)>

						<!--- Rest data structures --->
						<cfset currRestUriMetadata = StructNew() />

						<!--- Copy in additional "not documented" alternative "rest:" annotations to the metadata struct --->
						<cfloop collection="#currFunction#" item="key">
							<cfif key.toLowerCase().startsWith(variables.ANNOTATION_REST_BASE.toLowerCase() & ":")>
								<cfset currRestUriMetadata[key] = currFunction[key] />
							</cfif>
						</cfloop>

						<!--- Default to GET method --->
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_REST_METHOD)>
							<cfset currHttpMethods = ListToArray(currFunction[variables.ANNOTATION_REST_METHOD]) />
						<cfelse>
							<cfset currHttpMethods = "GET" />
						</cfif>

						<!--- Default to global setting --->
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_REST_AUTHENTICATE)>
							<cfset currRestUriMetadata.authenticate = currFunction[variables.ANNOTATION_REST_AUTHENTICATE] />
						<cfelse>
							<cfset currRestUriMetadata.authenticate = getAuthenticateDefault() />
						</cfif>

						<!--- Check for default return format for the method --->
						<cfset currRestUriMetadata.defaultReturnFormat = "" />
						<cfloop array="#currFunction.parameters#" index="parameter">
							<cfif parameter.name EQ "format">
								<cfif StructKeyExists(parameter, "default")>
									<cfset currRestUriMetadata.defaultReturnFormat = parameter.default />
								</cfif>
								<cfbreak/>
							</cfif>
						</cfloop>
						
						<cfloop from="1" to="#ArrayLen(currHttpMethods)#" index="j">
							<!--- Create instance of Uri and add it to the UriCollection. --->
							<cfset currRestUri = CreateObject("component", "MachII.framework.url.Uri").init(
									currFunction[variables.ANNOTATION_REST_URI]
									, currHttpMethods[j]
									, currFunction.name
									, getParameter("name")
									, currRestUriMetadata
									, getPossibleFormatList()) />
	
							<!---
							Check for already added URI as we do not want to add in duplicates created by inheritance
							We loop from top level object first so super class are of a lesser importance
							Our duplicate check looks at the regex, http method and function name as there could
							easily be duplicate uriRegex and http method with different function names.
							--->
							<cfif NOT variables.restUris.isUriDefined(currRestUri, "uriRegex,httpMethod,functionName")>
								<cfset variables.restUris.addUri(currRestUri) />
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>

			<!--- Pop off the current level of metadata and recurse until the stop class if required --->
			<cfif ArrayDeleteAt(arguments.restMethodMetadata, 1) AND ArrayLen(arguments.restMethodMetadata)>
				<cfset setupRestMethods(arguments.restMethodMetadata) />
			</cfif>
		</cfif>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setUrlBase" access="public" returntype="void" output="false">
		<cfargument name="urlBase" type="string" required="true" />
		<cfset variables.urlBase = arguments.urlBase />
	</cffunction>
	<cffunction name="getUrlBase" access="public" returntype="string" output="false">
		<cfreturn variables.urlBase />
	</cffunction>

	<cffunction name="getRestUris" access="public" returntype="struct" output="false"
		hint="Gets the REST URIs collection object.">
		<cfreturn variables.restUris />
	</cffunction>

	<cffunction name="setDefaultFormat" access="public" returntype="void" output="false"
		hint="Set this to override the defaultFormat.">
		<cfargument name="defaultFormat" type="string" required="true" />

		<cfset var mimeTypeMap = StructNew() />

		<!--- Use StructAppend to not pollute base mime-type map via references when "mixing" custom mime types --->
		<cfset StructAppend(mimeTypeMap, getUtils().getMimeTypeMap()) />
		<cfset StructAppend(mimeTypeMap, variables.customMimeTypeMap) />

		<cfif StructKeyExists(mimeTypeMap, arguments.defaultFormat)>
			<cfset variables.defaultFormat = arguments.defaultFormat />
		<cfelse>
			<cfthrow type="MachII.framework.InvalidFormatType"
				message="Cannot set the defaultFormat to '#arguments.defaultFormat#' and not in the Mach-II mimeTypeMap." />
		</cfif>
	</cffunction>
	<cffunction name="getDefaultFormat" access="public" returntype="string" output="false"
		hint="Gets the default format MIME type.">
		<cfreturn variables.defaultFormat />
	</cffunction>

	<cffunction name="setDefaultCharset" access="public" returntype="void" output="false">
		<cfargument name="defaultCharset" type="string" required="true" />
		<cfset variables.defaultCharset = arguments.defaultCharset />
	</cffunction>
	<cffunction name="getDefaultCharset" access="public" returntype="string" output="false">
		<cfreturn variables.defaultCharset />
	</cffunction>

	<cffunction name="setPossibleFormatList" access="public" returntype="void" output="false">
		<cfargument name="possibleFormatList" type="string" required="true" />

		<cfset arguments.possibleFormatList = ListToArray(getUtils().trimList(arguments.possibleFormatList, ",|"), ",|") />

		<!--- Validate possibleFormatList --->
		<cfif ArrayLen(arguments.possibleFormatList)>
			<cftry>
				<cfset getUtils().getMimeTypeByFileExtension(arguments.possibleFormatList, variables.customMimeTypeMap, true) />
				<cfset variables.possibleFormatList = ArrayToList(arguments.possibleFormatList) />

				<cfcatch type="MachII.framework.InvalidFileExtensionType">
					<cfthrow type="MachII.framework.InvalidFileExtensionType"
						message="URI could not be initialized because one of the formats are invalid and not in the Mach-II mimeTypeMap." />
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	<cffunction name="getPossibleFormatList" access="public" returntype="string" output="false">
		<cfreturn variables.possibleFormatList />
	</cffunction>
	
	<cffunction name="setJsonpArgName" access="public" returntype="void" output="false">
		<cfargument name="jsonpArgName" type="string" required="true" />
		<cfset variables.jsonpArgName = arguments.jsonpArgName />
	</cffunction>
	<cffunction name="getJsonpArgName" access="public" returntype="string" output="false">
		<cfreturn variables.jsonpArgName />
	</cffunction>

	<cffunction name="setAuthenticateDefault" access="public" returntype="void" output="false">
		<cfargument name="authenticateDefault" type="boolean" required="true" />
		<cfset variables.authenticateDefault = arguments.authenticateDefault />
	</cffunction>
	<cffunction name="getAuthenticateDefault" access="public" returntype="boolean" output="false">
		<cfreturn variables.authenticateDefault />
	</cffunction>

</cfcomponent>