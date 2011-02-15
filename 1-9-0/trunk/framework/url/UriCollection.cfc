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
A UriCollection links HTTP METHODs and regex URI matching patterns to the
associated Uri instances.
--->
<cfcomponent
	displayname="UriCollection"
	output="false"
	hint="Represents a collection of URIs which are organized by HTTP method and regex.">

	<!---
	PROPERTIES
	--->
	<!--- This is a struct of structs, where the outer key is the HTTP Method, and the inner key is the urlRegex that points to each Uri. --->
	<cfset variables.uris = StructNew() />
	<cfset variables.urisByFunctionName = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="UriCollection" output="false"
		hint="Initializes the UriCollection.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="findUriByPathInfo" access="public" returntype="any" output="false"
		hint="Tries to find an Uri that matches the incoming pathInfo and HttpMethod. Returns it if found, otherwise returns list of available http methods or empty string.">
		<cfargument name="pathInfo" type="string" required="true" />
		<cfargument name="httpMethod" type="string" required="true" />

		<cfset var currUriGroup = "" />
		<cfset var currUriRegex = "" />

		<cfif StructKeyExists(variables.uris, arguments.httpMethod)>
			<cfset currUriGroup = variables.uris[arguments.httpMethod] />

			<cfloop collection="#currUriGroup#" item="currUriRegex">
				<cfif REFindNoCase(currUriRegex, arguments.pathInfo, 1, false)>
					<!--- Found a match: get it, and bail out of loop by returing the object --->
					<cfreturn currUriGroup[currUriRegex] />
				</cfif>
			</cfloop>
		</cfif>
		
		<!---
			If no URI is found, return a list of HTTP methods allowed for this
			pattern (zero-length string means not URI found by any HTTP method)
		--->
		<cfreturn findAvailbleMethodsByUri(arguments.pathInfo) />
	</cffunction>
	
	<cffunction name="findUriByFunctionName" access="public" returntype="any" output="false"
		hint="Tries to find an Uri that matches the incoming function name.">
		<cfargument name="functionName" type="string" required="true" />

		<cfset var currHttpMethod = "" />
		<cfset var currUri = "" />
		
		<cfif StructKeyExists(variables.urisByFunctionName, arguments.functionName)>
			<cfreturn variables.urisByFunctionName[arguments.functionName] />
		</cfif>
		
		<cfreturn "" />
	</cffunction>

	<cffunction name="addUri" access="public" returntype="void" output="false"
		hint="Adds a Uri to the collection, throwing exception for duplicates or unsupported HTTP methods.">
		<cfargument name="uri" type="MachII.framework.url.Uri" required="true" />

		<!--- Create new inner struct for httpMethod if not present --->
		<cfif NOT StructKeyExists(variables.uris, arguments.uri.getHttpMethod())>
			<cfset variables.uris[arguments.uri.getHttpMethod()] = StructNew() />
		</cfif>

		<!--- Add currRestUri to restUris structure, with uriRegex as the key, if not duplicate --->
		<cfif NOT StructKeyExists(variables.uris[arguments.uri.getHttpMethod()], arguments.uri.getUriRegex())>
			<cfset variables.uris[arguments.uri.getHttpMethod()][arguments.uri.getUriRegex()] = arguments.uri />
			<cfset variables.urisByFunctionName[arguments.uri.getFunctionName()] = arguments.uri />
		<cfelse>
			<!--- Throw exception if this Uri is already defined here. --->
			<cfthrow type="MachII.framework.url.DuplicateUri"
					message="The URI Pattern '#arguments.uri.getUriPattern()#' for this UriCollection method has already been defined. URIs patterns must be unique."
					detail="Currently defined patterns: '#StructKeyList(variables.uris)#'"  />
		</cfif>
	</cffunction>

	<cffunction name="isUriDefined" access="public" returntype="boolean" output="false"
		hint="Checks if the specified URI is already defined.">
		<cfargument name="uri" type="MachII.framework.url.Uri" required="true" />
		<cfargument name="comparisonKeys" type="any" required="false"
			default="uriRegex,httpMethod"
			hint="A list or array of URI key names to use for comparison. Defaults to 'uriRegex,httpMethod'" />

		<cfset var comparisonUri = "" />
		<cfset var comparisonUriValue = "" />
		<cfset var uriValue = "">
		<cfset var i = "" />

		<!--- Create new inner struct for httpMethod if not present --->
		<cfif NOT StructKeyExists(variables.uris, arguments.uri.getHttpMethod())>
			<cfset StructInsert(variables.uris, arguments.uri.getHttpMethod(), StructNew()) />
		</cfif>

		<!--- If URI is not available, then false --->
		<cfif NOT StructKeyExists(variables.uris[arguments.uri.getHttpMethod()], arguments.uri.getUriRegex())>
			<cfreturn false />
		</cfif>

		<!--- We have a basic match so check against comparisonKeys --->
		<cfset comparisonUri = variables.uris[arguments.uri.getHttpMethod()][arguments.uri.getUriRegex()] />

		<cfif NOT IsArray(arguments.comparisonKeys)>
			<cfset arguments.comparisonKeys = ListToArray(arguments.comparisonKeys) />
		</cfif>

		<cfloop from="1" to="#ArrayLen(arguments.comparisonKeys)#" index="i">
			<cfinvoke component="#comparisonUri#"
				method="get#arguments.comparisonKeys[i]#"
				returnvariable="comparisonUriValue" />
			<cfinvoke component="#arguments.uri#"
				method="get#arguments.comparisonKeys[i]#"
				returnvariable="uriValue" />

			<!--- We don't have a duplicate (as defined by the comparison keys )if values don't match --->
			<cfif uriValue NEQ comparisonUriValue>
				<cfreturn false />
			</cfif>
		</cfloop>

		<!--- If we have gotten this far, then all the comparison keys matched and we have duplicate --->
		<cfreturn true />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="appendUriCollection" access="public" returntype="void" output="false"
		hint="Appends the Uris in the input UriCollection to this UriCollection. Throws exception on any duplicates.">
		<cfargument name="uriCollection" type="MachII.framework.url.UriCollection" required="true"
			hint="The UriCollection to merge with this collection." />

		<cfset var inUris = arguments.uriCollection.getUris() />
		<cfset var currHttpMethod = "" />
		<cfset var currUriGroup = "" />
		<cfset var currUriRegex = "" />

		<!--- Iterate through HTTP methods, get Uris, call add on each one --->
		<cfloop collection="#inUris#" item="currHttpMethod">
			<cfset currUriGroup = inUris[currHttpMethod] />
			<cfloop collection="#currUriGroup#" item="currUriRegex">
				<!--- Add each Uri to this collection. Throws exception if duplicate. --->
				<cfset this.addUri(currUriGroup[currUriRegex]) />
			</cfloop>
		</cfloop>
	</cffunction>

	<cffunction name="resetUris" access="public" returntype="void" output="false"
		hint="Resets the URI collection.">
		<cfset variables.uris = StructNew() />
	</cffunction>
	
	<cffunction name="findAvailbleMethodsByUri" access="public" returntype="string" output="false"
		hint="Tries to find available HTTP methods by the an Uri that matches the incoming pathInfo. Returns a list of available HTTP methods if found, otherwise returns empty string.">
		<cfargument name="pathInfo" type="string" required="true" />

		<cfset var uriMethods = "" />
		<cfset var currUriGroup = "" />
		<cfset var currUriRegex = "" />
		<cfset var currHttpMethod = "" />

		<cfloop collection="#variables.uris#" item="currHttpMethod">
			<cfset currUriGroup = variables.uris[currHttpMethod] />
	
			<cfloop collection="#currUriGroup#" item="currUriRegex">
				<cfif REFindNoCase(currUriRegex, arguments.pathInfo, 1, false)>
					<!--- Found a match: get it, and bail out of loop --->
					<cfset uriMethods = ListAppend(uriMethods, currHttpMethod) />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn uriMethods />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getUris" access="public" returntype="struct" output="false"
		hint="Gets the URI collection.">
		<cfreturn variables.uris />
	</cffunction>

	<cffunction name="getUriByPattern" access="public" returntype="any" output="false"
		hint="Tries to find an Uri that matches the supplied pattern. Returns it if found, otherwise returns empty string.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="httpMethod" type="string" required="true" />

		<cfset var uri = "" />
		<cfset var currUriGroup = "" />
		<cfset var currUriRegex = "" />

		<cfif StructKeyExists(variables.uris, arguments.httpMethod)>
			<cfset currUriGroup = variables.uris[arguments.httpMethod] />
			<cfloop collection="#currUriGroup#" item="currUriRegex">
				<cfif currUriGroup[currUriRegex].getUriPattern() EQ arguments.pattern >
					<cfset uri = currUriGroup[currUriRegex] />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn uri />
	</cffunction>
	
</cfcomponent>