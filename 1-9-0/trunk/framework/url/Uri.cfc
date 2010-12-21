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

A Uri is a link between a URI pattern and an endpoint method that
will be invoked when an incoming URL matches the pattern. The RestUri
pattern can include tokens that defined variable portions of the
incoming URI.

For example, a uriPattern like "/service/doit/{value}"

--->
<cfcomponent
	displayname="Uri"
	output="false"
	hint="Represents a URI that can be compared against incoming urls to determine matches and retrieve variable tokens.">

	<!---
	CONSTANTS
	--->
	<!--- The ONE_TOKEN_REGEX is what will be used to match an individual token in the URL. Used when generating the full uriRegex value. --->
	<cfset variables.ONE_TOKEN_REGEX ="([^\/\?&\.]+)" />
	<!--- HTTP_METHODS is the list of supported HTTP request methods. --->
	<cfset variables.HTTP_METHODS = "GET,POST,PUT,DELETE" />

	<!---
	PROPERTIES
	--->
	<cfset variables.endpointName = "" />
	<cfset variables.functionName = "" />
	<cfset variables.uriPattern = "" />
	<cfset variables.httpMethod = "" />
	<!--- uriRegex & uriTokenNames are only set internally, generated when setUriPattern() is called --->
	<cfset variables.uriRegex = "" />
	<cfset variables.uriTokenNames = ArrayNew(1) />
	<cfset variables.uriMetadataParameters = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Uri" output="false"
		hint="Initializes the Uri.">
		<cfargument name="uriPattern" type="string" required="false" default=""
			hint="The URI pattern to be used for this endpoint route." />
		<cfargument name="httpMethod" type="string" required="false" default=""
			hint="The HTTP method to be used for this endpoint route." />
		<cfargument name="functionName" type="string" required="false" default=""
			hint="The name of the function to call when this endpoint route is invoked" />
		<cfargument name="uriPrefix" type="string" required="false" default=""
			hint="The name of the URI prefix." />
		<cfargument name="uriMetadataParameters" type="struct" required="false" default="#StructNew()#"
			hint="Any metadata for the URI being defined." />

		<cfset setHttpMethod(arguments.httpMethod) />
		<cfset setFunctionName(arguments.functionName) />
		<cfset setUriPrefix(arguments.uriPrefix) />
		<cfset setUriPattern(arguments.uriPattern) />
		<cfset setUriMetadataParameters(arguments.uriMetadataParameters) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getTokensFromUri" access="public" returntype="struct" output="false"
		hint="Returns a struct with the token names and values from the input PATH_INFO. Returns empty struct on no match.">
		<cfargument name="pathInfo" type="string" required="true"
			hint="The current path info to parse for tokens." />

		<cfset var stcTokens = StructNew() />
		<cfset var stcMatches = REFind(variables.uriRegex, arguments.pathInfo, 1, true) />
		<cfset var intMatchCount = ArrayLen(stcMatches.LEN) />
		<cfset var key = "" />
		<cfset var i = 0 />

		<cfif stcMatches.LEN[1]>
			<!--- If there are possible tokens in the path info, parse for the tokens and put them in stcTokens --->
			<cfif ArrayLen(variables.uriTokenNames) AND intMatchCount GT 2 AND stcMatches.LEN[2]>
				<!---
				There are only tokens if the REFind matches struct has more than
				two items in the LEN array, since the first element in the LEN array
				is the length of the entire string, and the last element is any format,
				which we capture later.
				 --->
				<cfloop from="1" to="#intMatchCount-2#" index="i">
					<cfset stcTokens[variables.uriTokenNames[i]] = Mid(arguments.pathInfo, stcMatches.POS[i+1], stcMatches.LEN[i+1]) />
				</cfloop>
			</cfif>

			<!--- Add format as a token, since it is variable (it is always the last element) --->
			<cfif stcMatches.LEN[intMatchCount] GT 1>
				<cfset stcTokens["format"] = Mid(arguments.pathInfo, stcMatches.POS[intMatchCount]+1, stcMatches.LEN[intMatchCount]) />
			</cfif>
		</cfif>

		<!--- Url decode all the tokens now (we do this here so &2E remains in a token and doesn't get used as a format) --->
		<cfloop collection="#stcTokens#" item="key">
			<cfset stcTokens[key] = UrlDecode(stcTokens[key]) />
		</cfloop>

		<cfreturn stcTokens />
	</cffunction>

	<cffunction name="matchUri" access="public" returntype="boolean" output="false"
		hint="Returns true if the input pathInfo matches the uriPattern of this RestUri, false otherwise.">
		<cfargument name="pathInfo" type="string" required="true" />
		<cfreturn REFind(variables.uriRegex, arguments.pathInfo, 1, false) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="setUriMetadataParameter" access="public" returntype="void" output="false"
		hint="Sets an URI metadata parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" type="any" required="true"
			hint="The parameter value." />
		<cfset variables.uriMetadataParameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getUriMetadataParameter" access="public" returntype="any" output="false"
		hint="Gets an URI metadata parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The URI metadata parameter name." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to return if the parameter is not defined. Defaults to a blank string." />
		<cfif isUriMetadataParameterDefined(arguments.name)>
			<cfreturn variables.uriMetadataParameters[arguments.name] />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>
	<cffunction name="isUriMetadataParameterDefined" access="public" returntype="boolean" output="false"
		hint="Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The URI metadata name." />
		<cfreturn StructKeyExists(variables.uriMetadataParameters, arguments.name) />
	</cffunction>
	<cffunction name="getUriMetadataParameterNames" access="public" returntype="string" output="false"
		hint="Returns a comma delimited list of URI metadata names.">
		<cfreturn StructKeyList(variables.uriMetadataParameters) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="makeUriPatternIntoRegex" access="private" returntype="void" output="false"
		hint="Take an input URI with optional {tokens} and set the uriRegex and uriTokenNames instance variables.">
		<cfargument name="uriPattern" type="string" required="true"
			hint="The URI pattern convert into a regex for matching. The URI will be matched against incoming PATH_INFO, can only be slash delimited, and a token can be used to link a variable to a position in the URI path, e.g. '/service/doit/{value}'" />

		<!--- Going to turn a uriPattern like "/service/doit/{value}" into "^/service/doit/([^\/\?&]+)(\.[^\.\?]+)?$" --->
		<cfset var stcOutput = StructNew() />
		<cfset var urlElements = ListToArray(arguments.uriPattern, "/", false) />
		<cfset var currElement = "" />
		<cfset var currElementStack = ArrayNew(1) />
		<cfset var currPosition = 1 />
		<cfset var newElement = "" />
		<cfset var stcMatches = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<cfset variables.uriTokenNames = ArrayNew(1) />

		<!--- Iterate through the elements in the URI, replacing the tokens with a regex for the match. --->
		<cfloop from="1" to="#ArrayLen(urlElements)#" index="i">
			<cfset currElement = urlElements[i] />
			<cfset newElement = "" />

			<cfset stcMatches = reFindAll("({.*?[^}]})+", currElement) />

			<cfif stcMatches.POS[1] NEQ 0>
				<!--- If first token is not at position 1, then prepend and escape the "pre-text" --->
				<cfif stcMatches.POS[1] GT 1>
					<cfset newElement = newElement & reEscape(Mid(currElement, 1, stcMatches.POS[j] - 1)) />
				</cfif>

				<!--- Loop over the found tokens --->
				<cfloop from="1" to="#ArrayLen(stcMatches.POS)#" index="j">
					<cfset ArrayAppend(variables.uriTokenNames, Mid(currElement, stcMatches.POS[j] + 1, stcMatches.LEN[j] - 2)) />
					<cfset newElement = newElement & variables.ONE_TOKEN_REGEX />

					<!--- Append the text between multiple tokens --->
					<cfif j LT ArrayLen(stcMatches.POS)>
						<cfset newElement = newElement & reEscape(Mid(currElement, stcMatches.POS[j] + stcMatches.LEN[j], stcMatches.POS[j + 1] - (stcMatches.POS[j] + stcMatches.LEN[j]))) />
					</cfif>
				</cfloop>

				<cfset urlElements[i] = newElement />
			</cfif>
		</cfloop>

		<!--- If first element in URI prefix, add it --->
		<cfif NOT urlElements[1] EQ variables.uriPrefix>
			<cfset ArrayInsertAt(urlElements, 1, variables.uriPrefix) />
		</cfif>

		<!--- Set instance variables --->
		<cfset variables.uriRegex = "^/" & ArrayToList(urlElements, "/") & "(\.[^\.\?]+)?(?:/)?$" />
	</cffunction>

	<cffunction name="reEscape" access="private" returntype="string" output="false"
		hint="Escapes all regex control characters.">
		<cfargument name="unescapedText" type="string" required="true" />
		<cfreturn ReplaceList(arguments.unescapedText, "\,+,*,?,.,[,],^,$,(,),{,},|,-", "\\,\+,\*,\?,\.,\[,\],\^,\$,\(,\),\{,\},\|,\-") />
	</cffunction>

	<cffunction name="reFindAll" access="private" returntype="struct" output="false"
		hint="Finds all regex matches and returns the position / length of each match.">
		<cfargument name="regex" type="string" required="true"
			hint="The regex pattern to use." />
		<cfargument name="input" type="string" required="true"
			hint="The text to search and apply the regex pattern to." />

		<!--- Based on a version of ReFindAll() on cflib.org by Ben Forta --->
		<cfset var results = StructNew() />
		<cfset var start = 1 />
		<cfset var match = "" />

		<!--- Setup results --->
		<cfset results.len = ArrayNew(1) />
		<cfset results.pos = ArrayNew(1) />

		<!--- Loop through input text for matches --->
		<cfloop condition="true">

			<!--- Perform search --->
			<cfset match = REFind(arguments.regex, arguments.input, start, TRUE) />

			<!--- Break if nothing matched --->
			<cfif NOT match.len[1]>
				<cfbreak />
			</cfif>

			<cfset ArrayAppend(results.len, match.len[1]) />
			<cfset ArrayAppend(results.pos, match.pos[1]) />

			<!--- Reposition start point --->
			<cfset start = match.pos[1] + match.len[1] />
		</cfloop>

		<!--- If no matches, add 0 to both arrays --->
		<cfif NOT ArrayLen(results.len)>
			<cfset results.len[1] = 0 />
			<cfset results.pos[1] = 0 />
		</cfif>

		<cfreturn results  />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setUriPrefix" access="public" returntype="void" output="false">
		<cfargument name="uriPrefix" type="string" required="true" />
		<cfset variables.uriPrefix = arguments.uriPrefix />
	</cffunction>
	<cffunction name="getUriPrefix" access="public" returntype="string" output="false">
		<cfreturn variables.uriPrefix />
	</cffunction>

	<cffunction name="setFunctionName" access="public" returntype="void" output="false">
		<cfargument name="functionName" type="string" required="true" />
		<cfset variables.functionName = arguments.functionName />
	</cffunction>
	<cffunction name="getFunctionName" access="public" returntype="string" output="false">
		<cfreturn variables.functionName />
	</cffunction>

	<cffunction name="setUriPattern" access="public" returntype="void" output="false"
		hint="Calculates & sets uriRegex based on the input uriPattern.">
		<cfargument name="uriPattern" type="string" required="true" />

		<!--- Require an appropriate URI pattern (pretty loose validation, just require initial slash and almost anything following) --->
		<cfset arguments.uriPattern = Trim(arguments.uriPattern) />

		<cfif REFind("^([\/]*)([^\/\?&]+)", arguments.uriPattern, 1, false) EQ 0>
			<cfthrow type="MachII.framework.url.InvalidUriPattern"
				message="Invalid uriPattern for this URI."
				detail="The uriPattern must be an slash-delimited, valid URL string, with optional {} delimited tokens. '#arguments.uriPattern#' is invalid."  />
		</cfif>

		<cfset variables.uriPattern = arguments.uriPattern />
		<cfset makeUriPatternIntoRegex(variables.uriPattern) />
	</cffunction>
	<cffunction name="getUriPattern" access="public" returntype="string" output="false">
		<cfreturn variables.uriPattern />
	</cffunction>

	<cffunction name="setHttpMethod" access="public" returntype="void" output="false">
		<cfargument name="httpMethod" type="String" required="true" />
		<!--- Validation --->
		<cfif ListFindNoCase(HTTP_METHODS, arguments.httpMethod)>
			<cfset variables.httpMethod = UCase(arguments.httpMethod) />
		<cfelse>
			<cfthrow type="MachII.endpoints.UnsupportedHttpMethod"
					message="The input HTTP method #arguments.httpMethod# is not currently supported.">
		</cfif>
	</cffunction>

	<cffunction name="getHttpMethod" access="public" returntype="string" output="false">
		<cfreturn variables.httpMethod />
	</cffunction>
	<cffunction name="getUriRegex" access="public" returntype="string" output="false">
		<cfreturn variables.uriRegex />
	</cffunction>

	<cffunction name="setUriMetadataParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of URI metadata parameters for this URI.">
		<cfargument name="uriMetadataParameters" type="struct" required="true"
			hint="Struct to set as URI metadata parameters" />

		<cfset var key = "" />

		<cfloop collection="#arguments.uriMetadataParameters#" item="key">
			<cfset setUriMetadataParameter(key, arguments.uriMetadataParameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getUriMetadataParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of URI metadata parameters for this URI.">
		<cfreturn variables.uriMetadataParameters />
	</cffunction>

	<cffunction name="getUriTokenNames" access="public" returntype="array" output="false">
		<cfreturn variables.uriTokenNames />
	</cffunction>

</cfcomponent>