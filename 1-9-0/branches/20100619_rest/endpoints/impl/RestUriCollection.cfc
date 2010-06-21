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

A RestUriCollection links HTTP METHODs and regex URI matching patterns to the
associated RestUri instances. Each RestEndpoint contains a RestUriCollection
for the REST URIs defined in it, and the EndpointManager contains a RestUriCollection
that combines the REST URIs for all RestEndpoints across this Mach-II application.

--->
<cfcomponent
	displayname="RestUriCollection"
	output="false"
	hint="Represents a collection of RestUris, organized by HTTP method and regex.">

	<!---
	PROPERTIES
	--->
	<!--- This is a struct of structs, where the outer key is the HTTP Method, and the inner key is the urlRegex that points to each RestUri. --->
	<cfset variables.restUris = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RestUriCollection" output="false"
		hint="Initializes the RestUriCollection.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="findRestUri" access="public" returntype="any" output="false"
		hint="Tries to find a RestUri that matches the incoming pathInfo and HttpMethod. Returns it if found, otherwise returns empty string.">
		<cfargument name="pathInfo" type="string" required="true" />
		<cfargument name="httpMethod" type="string" required="true" />

		<cfset var restUri = "" />
		<cfset var currRestUriGroup = "" />
		<cfset var currUriRegex = "" />

		<cfif StructKeyExists(variables.restUris, arguments.httpMethod)>
			<cfset currRestUriGroup = variables.restUris[arguments.httpMethod] />
			<cfloop list="#StructKeyList(currRestUriGroup)#" index="currUriRegex">
				<cfif ReFindNoCase(currUriRegex, arguments.pathInfo, 1, false)>
					<!--- Found a match: get it, and bail out of loop --->
					<cfset restUri = currRestUriGroup[currUriRegex] />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn restUri />
	</cffunction>

	<cffunction name="addRestUri" access="public" returntype="void" output="false"
				hint="Adds a RestUri to the collection, throwing exception for duplicates or unsupported HTTP methods.">
		<cfargument name="restUri" type="MachII.endpoints.impl.RestUri" required="true" />

		<cfif NOT StructKeyExists(variables.restUris, arguments.restUri.getHttpMethod())>
			<!--- Create new inner struct for httpMethod if not present --->
			<cfset StructInsert(variables.restUris, arguments.restUri.getHttpMethod(), StructNew()) />
		</cfif>

		<cfif NOT StructKeyExists(variables.restUris[arguments.restUri.getHttpMethod()], arguments.restUri.getUriRegex())>
			<!--- Add currRestUri to restUris structure, with uriRegex as the key, if not duplicate --->
			<cfset StructInsert(variables.restUris[arguments.restUri.getHttpMethod()], arguments.restUri.getUriRegex(), arguments.restUri) />
		<cfelse>
			<!--- Throw exception if this restUri is already defined here. --->
			<cfthrow type="MachII.endpoints.rest.DuplicateRestUri"
					message="The URI Pattern '#arguments.restUri.getUriPattern()#' for this Rest Endpoint method has already been defined. REST URIs patterns must be unique."
					detail="Currently defined patterns: '#StructKeyList(variables.restUris)#'"  />
		</cfif>
	</cffunction>

	<cffunction name="appendRestUriCollection" access="public" returntype="void" output="false"
				hint="Appends the RestUris in the input RestUriCollection to this RestUriCollection. Throws exception on any duplicates.">
		<cfargument name="restUriColl" type="MachII.endpoints.impl.RestUriCollection" required="true" />

		<cfset var inRestUris = arguments.restUriColl.getRestUris() />
		<cfset var currHttpMethod = "" />
		<cfset var currRestUriGroup = "" />
		<cfset var currUriRegex = "" />

		<!--- Iterate through HTTP methods, get RestUris, call add on each one --->
		<cfloop collection="#inRestUris#" item="currHttpMethod">
			<cfset currRestUriGroup = inRestUris[currHttpMethod] />
			<cfloop collection="#currRestUriGroup#" item="currUriRegex">
				<!--- Add each RestUri to this collection. Throws exception if duplicate. --->
				<cfset this.addRestUri(currRestUriGroup[currUriRegex]) />
			</cfloop>
		</cfloop>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getRestUris" access="public" returntype="struct" output="false">
		<cfreturn variables.restUris />
	</cffunction>

</cfcomponent>