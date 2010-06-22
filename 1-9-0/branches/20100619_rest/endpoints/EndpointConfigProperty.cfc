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

Notes:
<property name="Endpoints" type="MachII.endpoints.EndpointConfigProperty">
      <parameters>
            <parameter name="nameOfEndpoint">
                  <struct>
                        <key name="type" value="MachII.endpoints.AbstractEndpoint" />
                        <key name="param1" value="a" />
                        <key name="param2" value="b" />
                  </struct>
            </parameter>
      </parameters>
</property>

--->
<cfcomponent
	displayname="EndpointConfigProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Loads endpoint configurations for the EndpointManager.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the property.">

		<cfset var params = getParameters() />
		<cfset var key = "" />

		<!--- Load defined endpoints --->
		<cfloop collection="#params#" item="key">
			<cfif IsStruct(params[key])>
				<cfset configureEndpoint(key, getParameter(key)) />
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="configureEndpoint" access="public" returntype="void" output="false"
		hint="Configures an endpoint.">
		<cfargument name="endpointName" type="string" required="true"
			hint="Name of the endpoint." />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this endpoint." />

		<cfset var endpointManager = getAppManager().getEndpointManager() />
		<cfset var moduleName = getAppManager().getModuleName() />
		<cfset var key = "" />

		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.endpoints.MissingEndpointType"
				message="You must specify a parameter named 'type' for endpoint named '#arguments.endpointName#' in module named '#moduleName#'." />
		</cfif>

		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset arguments.parameters[key] = bindValue(key, arguments.parameters[key]) />
		</cfloop>

		<!--- Load the endpoint --->
		<cfset endpointManager.loadEndpoint(getAppManager(), arguments.endpointName, arguments.parameters.type, arguments.parameters) />
	</cffunction>

</cfcomponent>