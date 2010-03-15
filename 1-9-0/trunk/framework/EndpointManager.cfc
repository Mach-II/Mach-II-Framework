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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:

--->
<cfcomponent
	displayname="EndpointManager"
	output="false"
	hint="Manages endpoints.">

	<!---
	PROPERTIES
	--->
	<cfset variables.endpoints = StructNew() />

	<cfset variables.ENDPOINT_SHORTCUTS = StructNew() />
	<cfset variables.ENDPOINT_SHORTCUTS["ShortcutName"] = "MachII.endpoints.impl.NameOfEndpoint" />
	
	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EndpointManager" output="false"
		hint="Initializes the manager.">
			
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures all the endpoints.">
		
		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />
		
		<cfloop collection="#endpoints#" item="key">
			<cfset endpoints[key].configure() />
		</cfloop>
	</cffunction>
	
	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures all the endpoints.">
		
		<cfset var endpoints = getEndpoints() />
		<cfset var key = "" />
		
		<cfloop collection="#endpoints#" item="key">
			<cfset endpoints[key].deconfigure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - REQUEST HANDLING
	--->
	<cffunction name="handleRequest" access="public" returntype="void" output="false"
		hint="Handles an endpoint request.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint for this request." />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#"
			hint="Any runtime parameter args are needed to complete the request." />
		
		<cfset var endpoint = "" />
		
		<cftry>
			<cfset endpoint = getEndpointByName(arguments.endpointName) />
			
			
					
			<cfcatch type="MachII.endpoints.EndpointNotDefined">
				<!--- Debating which statuscode to send? --->
				<cfheader statuscode="404" statustext="Not Found" />
				<cfheader name="rest.error" value="Enpoint named '#arguments.endpointName#' not available." />
			</cfcatch>
			<cfcatch type="any">
				
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="getEndpointByName" access="public" returntype="MachII.endpoints.impl.AbstractEndpoint" output="false"
		hint="Gets a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to get." />
		
		<cfif isEndpointDefined(arguments.endpointName)>
			<cfreturn variables.endpoints[arguments.endpointName] />
		<cfelse>
			<cfthrow type="MachII.endpoints.EndpointNotDefined" 
				message="Endpoints with name '#arguments.endpointName#' is not defined."
				detail="Available endpoints: '#ArrayToList(getEndpointNames())#'" />
		</cfif>
	</cffunction>

	<cffunction name="addEndpoint" access="public" returntype="void" output="false"
		hint="Registers a endpoint with the specified name.">
		<cfargument name="endpointName" type="string" required="true"
			hint="The name of the endpoint to add." />
		<cfargument name="endpoint" type="MachII.endpoints.impl.AbstractEndpoint" required="true"
			hint="A reference to the endpoint." />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false"
			hint="A boolean to allow an already managed endpoint to be overrided with a new one. Defaults to false." />
		
		<cfif NOT arguments.overrideCheck AND isEndpointDefined(arguments.endpointName)>
			<cfthrow type="MachII.endpoints.EndpointAlreadyDefined"
				message="An endpoint with name '#arguments.endpointName#' is already registered." />
		<cfelse>
			<cfset variables.endpoints[arguments.endpointName] = arguments.endpoint />
		</cfif>
	</cffunction>

	<cffunction name="isEndpointDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a endpoint is registered with the specified name. Does NOT check parent.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint to check." />		
		<cfreturn StructKeyExists(variables.endpoints, arguments.endpointName) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="loadEndpoint" access="public" returntype="void" output="false"
		hint="Loads an endpoint and adds the endpoint to the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager the endpoint was loaded from." />
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of endpoint." />
		<cfargument name="endpointType" type="string" required="true"
			hint="Dot path to the endpoint." />
		<cfargument name="endpointParameters" type="struct" required="false" default="#StructNew()#"
			hint="Configuration parameters for the endpoint." />
		
		<cfset var endpoint = "" />
		
		<!--- Resolve if a shortcut --->
		<cfset arguments.endpointType = resolveEndTypeShortcut(arguments.endpointType) />
		<!--- Ensure type is correct in parameters (where it is duplicated) --->
		<cfset arguments.endpointParameters.type = arguments.endpointType />
		
		<!--- Create the endpoint --->
		<cftry>
			<cfset endpoint = CreateObject("component", arguments.endpointType).init(arguments.appManager, this, arguments.endpointParameters) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ arguments.endpointType>
					<cfthrow type="MachII.endpoints.CannotFindEndpoint"
						message="Cannot find an endpoint CFC with type of '#arguments.endpointType#' for the endpoint named '#arguments.endpointName#'."
						detail="Please check that the endpoints exists and that there is not a misconfiguration." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfset addEndpoint(arguments.endpointName, endpoint) />
	</cffunction>
	
	<cffunction name="resolveEndTypeShortcut" access="public" returntype="string" output="false"
		hint="Resolves an endpoint type shorcut and returns the passed value if no match is found.">
		<cfargument name="endpointType" type="string" required="true"
			hint="Dot path to the endpoint." />
		
		<cfif StructKeyExists(variables.ENDPOINT_SHORTCUTS, arguments.endpointType)>
			<cfreturn variables.ENDPOINT_SHORTCUTS[arguments.endpointType] />
		<cfelse>
			<cfreturn arguments.endpointType />
		</cfif>
	</cffunction>
	
	<cffunction name="getEndpoints" access="public" returntype="struct" output="false"
		hint="Gets all registered endpoints for this manager.">
		<cfreturn variables.endpoints />
	</cffunction>

	<cffunction name="getEndpointNames" access="public" returntype="array" output="false"
		hint="Returns an array of endpoint names.">
		<cfreturn StructKeyArray(variables.endpoints) />
	</cffunction>
	
	<cffunction name="containsEndpoints" access="public" returntype="boolean" output="false"
		hint="Returns a boolean of on whether or not there are any registered endpoints.">
		<cfreturn StructCount(variables.endpoints) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	
</cfcomponent>