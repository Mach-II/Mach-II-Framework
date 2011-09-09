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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
For more information on HTTP basic access authentication:

To use other credential verification schemas, then sub-class this component
and override the checkCredentials() methods with your custom behavior. Other
verfication schemas could include LDAP, database or single sign-on service.

One should note that the authorization header sent by the browser is merely
encoded in base64 and can be easily decoded back into plain text. This encoding
is not used for security but to encode non-ASCII characters in an username or
password into a string that can be passed in an HTTP header.

Team Mach-II highly recommends that you use SSL (https) in conjunction with
basic access authorization because the authorization header is sent over the
wire in plain text.
--->
<cfcomponent
	displayname="Authentication"
	output="false"
	hint="Performs HTTP basic access authentication.">

	<!---
	PROPERTIES
	--->
	<cfset variables.realm = "" />
	<cfset variables.credentials = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Authentication" output="false"
		hint="Initializes the HTTP Basic Authentication security component.">
		<cfargument name="realm" type="string" required="true"
			hint="The HTTP basic authentication realmn name/" />
		<cfargument name="credentialFilePath" type="string" required="false"
			hint="The file path to the credential file. Must use SHA hash format (does not support DES)." />

		<cfset setRealm(arguments.realm) />

		<!--- Conditionally load in the credentials --->
		<cfif StructKeyExists(arguments, "credentialFilePath") AND Len(arguments.credentialFilePath)>
			<cfset variables.credentials = loadCredentialFile(arguments.credentialFilePath) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="authenticate" access="public" returntype="boolean" output="false"
		hint="Authenticates a request.">
		<cfargument name="httpHeaders" type="struct" required="true"
			hint="The HTTP request data to use." >
		<cfargument name="event" type="MachII.framework.Event" required="false"
			hint="Optionally an event object to use." />

		<cfif StructKeyExists(arguments.httpHeaders, "Authorization")>
			<cfset StructAppend(arguments, decodeAuthorizationHeader(arguments.httpHeaders)) />

			<cfif checkCredentials(argumentcollection=arguments)>
				<cfreturn true />
			</cfif>
		</cfif>

		<!--- Must use "Basic" with correct casing and double quotes for realm attribute --->
		<cfheader name="WWW-Authenticate" value='Basic realm="#getRealm()#"' />
		<cfheader statuscode="401" statustext="Authorization Required" />

		<cfreturn false />
	</cffunction>

	<cffunction name="decodeAuthorizationHeader" access="public" returntype="struct" output="false"
		hint="Decodes ann authorization header into realm, username and password.">
		<cfargument name="value" type="any" required="true"
			hint="The authorization header value or a struct of headers with an 'Authorization' key." />

		<cfset var tempUsernamePassword = "" />
		<cfset var result = StructNew() />

		<!--- Convert headers struct into a value we can decode --->
		<cfif IsStruct(arguments.value)>
			<cftry>
				<cfset arguments.value = arguments.value['Authorization'] />
				<cfcatch>
					<cfthrow type="MachII.security.http.InvalidHeader"
						message="The passed headers to 'decodeAuthorizationHeader' does not contain an 'Authorization' key." />
				</cfcatch>
			</cftry>
		</cfif>

		<!--- Setup a default result --->
		<cfset result.username = "" />
		<cfset result.password = "" />

		<!--- Check that we have the realm and the encoded username:password --->
		<cfif ListLen(arguments.value, " ") EQ 2 AND ListFirst(arguments.value, " ") EQ "Basic">
			<!--- Decode the username:password --->
			<cfset tempUsernamePassword = ListLast(arguments.value, " ") />
			<cfset tempUsernamePassword = ToString(ToBinary(tempUsernamePassword)) />

			<cfset result.username = ListFirst(tempUsernamePassword, ":") />
			<cfset result.password = ListLast(tempUsernamePassword, ":") />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="encodeAuthorizationHeader" access="public" returntype="string" output="false"
		hint="Encodes an authorization header value in the proper format.">
		<cfargument name="username" type="string" required="true"
			hint="The username for the header value." />
		<cfargument name="password" type="string" required="true"
			hint="The password for the header value." />
		<!--- Authorization header is of format: "Basic Base64(username:password)" --->
		<cfreturn "Basic " & ToBase64(arguments.username & ":" & arguments.password) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="checkCredentials" access="private" returntype="boolean" output="false"
		hint="Checks the HTTP basic credentials. Override if using other authentication strategies like a database.">
		<cfargument name="username" type="string" required="true"
			hint="The user name." />
		<cfargument name="password" type="string" required="true"
			hint="The password." />
		<cfargument name="event" type="MachII.framework.Event" required="false"
			hint="Optionally an event object to use." />

		<cfif StructKeyExists(variables.credentials, arguments.username) AND Hash(arguments.password, "sha") EQ variables.credentials[arguments.username]>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="loadCredentialFile" access="private" returntype="struct" output="false"
		hint="Loads a credential file into memory.">
		<cfargument name="credentialFilePath" type="string" required="true" />

		<cfset var line = "" />
		<cfset var credentials = StructNew() />

		<cfloop file="#ExpandPath(arguments.credentialFilePath)#" index="line">
			<cfif NOT line.startsWith("##") AND ListLen(line, ":") EQ 2 >
				<cfset credentials[ListFirst(line, ":")] = ListLast(line, ":") />
			</cfif>
		</cfloop>

		<cfreturn credentials />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setRealm" access="private" returntype="void" output="false">
		<cfargument name="realm" type="string" required="true" />
		<cfset variables.realm = arguments.realm />
	</cffunction>
	<cffunction name="getRealm" access="public" returntype="string" output="false">
		<cfreturn variables.realm />
	</cffunction>

	<cffunction name="setCredentials" access="public" returntype="void" output="false">
		<cfargument name="credentials" type="struct" required="true" />
		<cfset variables.credentials = arguments.credentials />
	</cffunction>
	<cffunction name="getCredentials" access="public" returntype="struct" output="false">
		<cfreturn variables.credentials />
	</cffunction>

</cfcomponent>