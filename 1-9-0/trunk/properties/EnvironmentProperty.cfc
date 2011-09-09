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

Created version: 1.8.0
Updated version: 1.9.0

Notes:
Sets Mach-II properties based on the environment and uses the server name
to detect and load the correct environment properties based on where the
application is loaded.

The property allows for an unlimited number of environments to be setup.
Each environment can be named anything except for a short list of reserved
names as they conflict with other parameter names used by environment property.

The names are reserved and cannot be used as names for environments:

  * defaultEnvironmentName
  * serverPropertyName

The property provides the ability to set properties for five deployment
environment groups 'local', 'development', 'staging', 'qa' and 'production'
as supported by the core framework for each environment. This allows modules
allow for change in behavior based on the environment group.

Environments are resolved by server name (default: cgi.SERVER_NAME). Since the
property allows for environment resolution with server patterns, the server lists
are ordered by environment groups and searched in the following order:

  * production
  * qa
  * staging
  * development
  * local

The search order driven by the environment groups (which by default "production"
environments should be more "secure" than development environment groups).

Parameters:

The [defaultEnvironment] parameter optionally indicates which environment to
load if there is no server name to another environment when loaded. For
security, if no parameter is defined the environment property will throws an
exception if no environment can be resolved.  If the [defaultEnvironment]
parameter is defined, the default environment will be loaded if no server
can be resolved against the defined server names in all environments.

The [serverPropertyName] parameter optionally sets the name of the property used
to populate the name of the server found when resolving environments. Defaults to
'serverName'.

Usage:
<property name="environment" type="MachII.properties.EnvironmentProperty">
	<parameters>
		<!-- Optional: Name of default environment to use if no server matches -->
		<parameter name="defaultEnvironmentName" value="production" />

		<!-- Optional: Name of property to place in name of the resolved server -->
		<parameter name="serverPropertyName" value="serverName" />

		<!-- Optional: Name of the key containing the server name -->
		<parameter name="serverNameKey" value="cgi.SERVER_NAME" />

		<!--
			Optional: Use the resolved parent environment name from base application if in an module
				This parameter only applies when EnvironmentProperty is defined in a module
			Defaults to "true"
		-->
		<parameter name="useResolvedEnvironmentNameFromParent" value="true" />

		<!-- Name of environment (can be any name as 'development' is an example) -->
		<parameter name="development">
			<struct>
				<!-- Name of generic environment group to assign this environment to -->
				<key name="environmentGroup" value="local|development|staging|qa|production" />

				<!-- List or array of developer servers -->
				<key name="servers" value="dev01.example.com,dev02.example.com" />
				- or -
				<key name="servers">
					<array>
						<element value="dev01.example.com" />
						<element value="dev02.example.com" />
					</array>
				</key>

				<!-- Struct of development properties to set -->
				<key name="properties">
					<struct>
						<key name="property1" value="value1" />
						<key name="property2" value="value2" />
					</struct>
				</key>
			</struct>
		</parameter>

	</parameters>
</property>

Required Keys for Each Environment:

The [environmentGroup] key takes a value from the list
[local|development|staging|qa|productionServers] that is used to indicate
the environment group in which the environment belongs to. This allows for
modules, filters, plugins, etc. to change their behavior based on which
'generic' environment the resolved and loaded environment belongs to.

The [servers] key takes a list or array of server names that
are designated for the named environment. This key supports basic pattern matching
using the * wilcard which is useful if you deploy to a cluster (i.e.
web*.cluster.example.com would match web01.cluster.example.com)

The [properties] key takes an struct of properties to be set. Each key in the
properties struct can take complex datatypes like structs and arrays.
--->
<cfcomponent
	displayname="EnvironmentProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets environment mode and properties based on the where the application is deployed.">

	<!---
	CONSTANTS
	--->
	<cfset variables.RESERVED_PARAMETER_NAMES = "defaultEnvironmentName,serverPropertyName,serverNameKey" />
	<cfset variables.REQUIRED_ENVIRONMENT_KEY_NAMES = "environmentGroup,servers,properties" />
	<cfset variables.ENVIRONMENT_GROUP_NAMES = "" />

	<!---
	PROPERTIES
	--->
	<cfset variables.defaultEnvironment = "" />
	<cfset variables.serverPropertyName = "serverName" />
	<cfset variables.serverNameKey = "cgi.SERVER_NAME" />
	<cfset variables.useResolvedEnvironmentNameFromParent = true />
	<cfset variables.throwIfEnvironmentUnresolved = false />
	<cfset variables.serverMap = StructNew() />
	<cfset variables.environments = StructNew() />
	<cfset variables.matcher = CreateObject("component", "MachII.util.matching.SimplePatternMatcher").init() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">

		<cfset var i = "" />

		<cfset variables.ENVIRONMENT_GROUP_NAMES = getAppManager().getEnvironmentGroupNames() />

		<!--- Load in parameters --->
		<cfset setDefaultEnvironment(getParameter("defaultEnvironmentName", "")) />
		<cfset setServerPropertyName(getParameter("serverPropertyName", "serverName")) />
		<cfset setServerNameKey(getParameter("serverNameKey", "cgi.SERVER_NAME")) />
		<cfset setUseResolvedEnvironmentNameFromParent(getParameter("useResolvedEnvironmentNameFromParent", true)) />

		<!--- Set additional settings --->
		<cfif NOT Len(getDefaultEnvironment())>
			<cfset setThrowIfEnvironmentUnresolved(true) />
		</cfif>

		<!--- Build empty server map --->
		<cfloop list="#variables.ENVIRONMENT_GROUP_NAMES#" index="i">
			<cfset variables.serverMap[i] = ArrayNew(1) />
		</cfloop>

		<!--- Build server reference  and resolve environment by server name --->
		<cfset resolveServerName() />
		<cfset buildEnvironments() />
		<cfset resolveEnvironmentByServer() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="resolveEnvironmentByServer" access="private" returntype="void" output="false"
		hint="Dectects the server and loads environment by server name.">

		<cfset var environmentName = "" />
		<cfset var environmentNameInherited = false />
		<cfset var properties = StructNew() />

		<!---
			Check if this is a module since we defer to the environment name of
			the parent application unless otherwise directed
		--->
		<cfif getAppManager().inModule()
			AND getUseResolvedEnvironmentNameFromParent()
			AND getAppManager().getParent().getEnvironmentName() NEQ "_default_">
			<cfset environmentName = getAppManager().getParent().getEnvironmentName() />
			<cfset environmentNameInherited = true />
		<cfelse>
			<cfset environmentName = matchServerToEnvironmentName() />
		</cfif>

		<!--- Get properties by environment --->
		<cfif isEnvironmentDefined(environmentName)>
			<cfset loadPropertiesByEnvironmentName(environmentName) />
		<!--- Fail back to default environment if no environment match is found --->
		<cfelse>
			<!--- Do some checks --->
			<cfif getThrowIfEnvironmentUnresolved()>
				<cfset getAssert().isTrue(NOT environmentNameInherited
						, "The environment name of '#environmentName#' was inherited from the base application environment property. No environment with that name is available in this module named '#getAppManager().getModuleName()#'."
						, "Please define a default environment for this module or add defined an environment with the name of '#environmentName#'.") />
				<cfset getAssert().isTrue(Len(getDefaultEnvironment())
						, "No environment can be resolved for server named '#getServerName()#' and no default environment has been defined in this module named '#getAppManager().getModuleName()#'."
						, "Please define a default environment to use or add this server to a defined environment.") />
			</cfif>

			<cfset loadPropertiesByEnvironmentName(getDefaultEnvironment()) />
		</cfif>
	</cffunction>

	<cffunction name="buildEnvironments" access="private" returntype="void" output="false"
		hint="Builds all the environments.">

		<cfset var parameters = getParameters() />
		<cfset var key = "" />

		<!--- Discover environments --->
		<cfloop collection="#parameters#" item="key">
			<cfif NOT ListFindNoCase(variables.RESERVED_PARAMETER_NAMES, key)>
				<cfset getAssert().isTrue(IsStruct(parameters[key])
							, "The value for an environment named '#key#' is not a struct for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
							, "Please check your configuration.") />
				<cfset loadEnvironment(key, parameters[key]) />
			</cfif>
		</cfloop>

		<!--- Ensure default environment exists (if parameter is defined) --->
		<cfif Len(getDefaultEnvironment())>
			<cfset getAssert().isTrue(ListFindNoCase(StructKeyList(variables.environments), getDefaultEnvironment())
						, "The 'defaultEnvironment' named '#getDefaultEnvironment()#' does not corespond to a defined environment for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
						, "Available environments: #StructKeyList(variables.environments)#") />
		</cfif>
	</cffunction>

	<cffunction name="loadEnvironment" access="private" returntype="void" output="false"
		hint="Loads an environment servers and properties by environment name.">
		<cfargument name="environmentName" type="string" required="true"
			hint="The name of the environment">
		<cfargument name="environmentData" type="struct" required="true"
			hint="The raw data for the named environment.">

		<cfset var temp = StructNew() />
		<cfset var i = 0 />

		<!--- Assert the environment has not already been defined --->
		<cfset getAssert().isTrue(NOT isEnvironmentDefined(arguments.environmentName)
					, "An environment named '#arguments.environmentName#' has already been defined for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
					, "Current environment names (may not be complete depending on when this exception occurred in the loading sequence): #StructKeyList(variables.environments)#") />

		<!--- Assert that the required keys are available in the environment data --->
		<cfloop list="#variables.REQUIRED_ENVIRONMENT_KEY_NAMES#" index="i">
			<cfif getUseResolvedEnvironmentNameFromParent() AND i NEQ "servers">
				<cfset getAssert().isTrue(StructKeyExists(arguments.environmentData, i)
							, "An environment named '#arguments.environmentName#' is missing a required key named '#i#' for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
							, "All environments require these keys: #variables.REQUIRED_ENVIRONMENT_KEY_NAMES#") />
			</cfif>
		</cfloop>

		<!--- Assert the environment group name --->
		<cfset getAssert().isTrue(ListFindNoCase(variables.ENVIRONMENT_GROUP_NAMES, arguments.environmentData.environmentGroup)
					, "The 'environmentGroup' value is not a valid group name for environment named '#arguments.environmentName#' for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
					, "Valid environment groups: #variables.ENVIRONMENT_GROUP_NAMES#") />

		<!--- Transform list to an array of servers --->
		<cfif NOT IsArray(arguments.environmentData.servers)>
			<cfset arguments.environmentData.servers = ListToArray(getUtils().trimList(arguments.environmentData.servers)) />
		</cfif>

		<!--- Build server name array by environment group --->
		<cfloop from="1" to="#ArrayLen(arguments.environmentData.servers)#" index="i">
			<cfset temp = StructNew() />
			<cfset temp.server = arguments.environmentData.servers[i] />
			<cfset temp.environmentName = arguments.environmentName />
			<cfset appendToServerMapByEnvironmentGroup(arguments.environmentData.environmentGroup, temp)/>
		</cfloop>

		<!--- Add the environment --->
		<cfset setEnvironmentByName(arguments.environmentName, arguments.environmentData) />
	</cffunction>

	<!---
	PROCTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="matchServerToEnvironmentName" access="private" returntype="string" output="false"
		hint="Matches the current server to an environment name.">

		<cfset var thisServer = getServerName() />
		<cfset var environmentName = "" />
		<cfset var environmentGroupServerMap = "" />
		<cfset var resolvedEnvironment = false />
		<cfset var key = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Loop through the environment groups in order --->
		<cfloop list="#variables.ENVIRONMENT_GROUP_NAMES#" index="i">
			<cfset environmentGroupServerMap = variables.serverMap[i] />

			<cfloop from="1" to="#ArrayLen(environmentGroupServerMap)#" index="j">
				<cfif variables.matcher.match(environmentGroupServerMap[j].server, thisServer)>
					<cfset environmentName = environmentGroupServerMap[j].environmentName />
					<cfset resolvedEnvironment = true />
					<cfbreak />
				</cfif>
			</cfloop>

			<cfif resolvedEnvironment>
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn environmentName />
	</cffunction>

	<cffunction name="loadPropertiesByEnvironmentName" access="private" returntype="void" output="false"
		hint="Loads environment properties by environment name. Does not check if the environment is available so be sure the isEnvironmentDefined() is true.">
		<cfargument name="environmentName" type="string" required="true" />

		<cfset var environment = variables.environments[arguments.environmentName] />
		<cfset var properties = environment.properties />
		<cfset var key = "" />

		<!--- Load properties by environment --->
		<cfloop collection="#properties#" item="key">
			<cfset setProperty(key, properties[key]) />
		</cfloop>

		<!--- Set the server name to the property --->
		<cfset setProperty(getServerPropertyName(), getServerName()) />

		<cfset getAppManager().setEnvironmentName(environmentName) />
		<cfset getAppManager().setEnvironmentGroup(environment.environmentGroup) />
	</cffunction>

	<cffunction name="setEnvironmentByName" access="private" returntype="void" output="false"
		hint="Sets an environment and data by name.">
		<cfargument name="environmentName" type="string" required="true" />
		<cfargument name="environmentData" type="struct" required="true" />
		<cfset variables.environments[arguments.environmentName] = arguments.environmentData />
	</cffunction>

	<cffunction name="isEnvironmentDefined" access="private" returntype="boolean" output="false"
		hint="Checks if the environment is defined.">
		<cfargument name="environmentName" type="string" required="true"
			hint="Name of environment to check for." />
		<cfreturn StructKeyExists(variables.environments, arguments.environmentName) />
	</cffunction>

	<cffunction name="appendToServerMapByEnvironmentGroup" access="private" returntype="void" output="false"
		hint="Appends a server / environment name lookup entry by environment group to the server map.">
		<cfargument name="environmentGroup" type="string" required="true" />
		<cfargument name="serverMapData" type="struct" required="true" />
		<cfset ArrayAppend(variables.serverMap[arguments.environmentGroup], arguments.serverMapData) />
	</cffunction>

	<cffunction name="resolveServerName" access="private" returntype="void" output="false"
		hint="Resolves the server name from either properties.*, headers.* or cgi.* based data.">

		<cfset var key = getServerNameKey() />
		<cfset var name = "" />
		<cfset var parsedKeyName = "" />
		<cfset var parsedColName = "" />
		<cfset var collection = StructNew() />

		<cfset getAssert().isTrue(ReFindNoCase("^(properties|headers|cgi)\..+", key)
					, "The 'serverNameKey' must be one of the following: 'properties.*' (Mach-II properties), 'headers.*' (HTTP request headers), or 'cgi.*' (CGI scope).") />
		<cfset parsedColName = LCase(ListGetAt(key, 1, ".")) />
		<cfset parsedKeyName = ListDeleteAt(key, 1, ".") />

		<cfif parsedColName EQ "properties">
			<cfif isPropertyDefined(parsedKeyName)>
				<cfset name = getProperty(parsedKeyName) />
			</cfif>
		<cfelseif parsedColName EQ "headers">
			<cfset collection = GetHttpRequestData().headers />
			<cfif StructKeyExists(collection, parsedKeyName)>
				<cfset name = collection[parsedKeyName] />
			</cfif>
		<cfelseif parsedColName EQ "cgi">
			<cfif StructKeyExists(cgi, parsedKeyName)>
				<cfset name = cgi[parsedKeyName] />
			</cfif>
		</cfif>

		<cfset setServerName(name) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setDefaultEnvironment" access="private" returntype="void" output="false">
		<cfargument name="defaultEnvironment" type="string" required="true" />
		<cfset variables.defaultEnvironment = arguments.defaultEnvironment />
	</cffunction>
	<cffunction name="getDefaultEnvironment" access="public" returntype="string" output="false">
		<cfreturn variables.defaultEnvironment />
	</cffunction>

	<cffunction name="setUseResolvedEnvironmentNameFromParent" access="private" returntype="void" output="false">
		<cfargument name="useResolvedEnvironmentNameFromParent" type="string" required="true" />
		<cfset variables.useResolvedEnvironmentNameFromParent = arguments.useResolvedEnvironmentNameFromParent />
	</cffunction>
	<cffunction name="getUseResolvedEnvironmentNameFromParent" access="public" returntype="string" output="false">
		<cfreturn variables.useResolvedEnvironmentNameFromParent />
	</cffunction>

	<cffunction name="setThrowIfEnvironmentUnresolved" access="private" returntype="void" output="false">
		<cfargument name="throwIfEnvironmentUnresolved" type="boolean" required="true" />
		<cfset variables.throwIfEnvironmentUnresolved = arguments.throwIfEnvironmentUnresolved />
	</cffunction>
	<cffunction name="getThrowIfEnvironmentUnresolved" access="public" returntype="boolean" output="false">
		<cfreturn variables.throwIfEnvironmentUnresolved />
	</cffunction>

	<cffunction name="setServerPropertyName" access="private" returntype="void" output="false">
		<cfargument name="serverPropertyName" type="string" required="true" />
		<cfset getAssert().hasText(arguments.serverPropertyName
			, "The 'serverPropertyName' parameter must contain a value.") />
		<cfset variables.serverPropertyName = arguments.serverPropertyName />
	</cffunction>
	<cffunction name="getServerPropertyName" access="public" returntype="string" output="false">
		<cfreturn variables.serverPropertyName />
	</cffunction>

	<cffunction name="setServerNameKey" access="private" returntype="void" output="false">
		<cfargument name="serverNameKey" type="string" required="true" />
		<cfset variables.serverNameKey = arguments.serverNameKey />
	</cffunction>
	<cffunction name="getServerNameKey" access="public" returntype="string" output="false">
		<cfreturn variables.serverNameKey />
	</cffunction>

	<cffunction name="setServerName" access="private" returntype="void" output="false">
		<cfargument name="serverName" type="string" required="true" />
		<cfset variables.serverName = arguments.serverName />
	</cffunction>
	<cffunction name="getServerName" access="public" returntype="string" output="false">
		<cfreturn variables.serverName />
	</cffunction>

</cfcomponent>