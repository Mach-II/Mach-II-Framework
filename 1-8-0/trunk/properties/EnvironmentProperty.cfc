<!---
License:
Copyright 2009 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

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

Environments are resolved by server name (cgi.server_name). Since the property
allows for environment resolution with server patterns, the server lists are 
ordered by environment groups and searched in the following order:

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
						<key name="" value="" />
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

The [servers] key takes a list or array of server names (cgi.server_name) that
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
	PROPERTIES
	--->
	<cfset variables.defaultEnvironment = "" />
	<cfset variables.serverPropertyName = "serverName" />
	<cfset variables.throwIfEnvironmentUnresolved = false />
	<cfset variables.serverMap = StructNew() />
	<cfset variables.environments = StructNew() />
	<cfset variables.matcher = CreateObject("component", "MachII.util.SimplePatternMatcher").init() />
	
	<cfset variables.RESERVED_PARAMETER_NAMES = "defaultEnvironmentName,serverPropertyName" />
	<cfset variables.REQUIRED_ENVIRONMENT_KEY_NAMES = "environmentGroup,servers,properties" />
	<cfset variables.ENVIRONMENT_GROUP_NAMES = "production,qa,staging,development,local" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var appManager = getAppManager() />
		<cfset var i = "" />
		
		<!--- Synchronize environment group names --->
		<cfif appManager.inModule()>
			<!--- Only use the environment group names if they are available from the parent --->
			<cfif Len(appManager.getEnvironmentGroupNames())>
				<cfset variables.ENVIRONMENT_GROUP_NAMES = appManager.getEnvironmentGroupNames() />
			</cfif>
		<cfelse>
			<cfset appManager.setEnvironmentGroupNames(variables.ENVIRONMENT_GROUP_NAMES) />
		</cfif>
		
		<!--- Load in parameters --->
		<cfset setDefaultEnvironment(getParameter("defaultEnvironmentName", "")) />
		<cfset setServerPropertyName(getParameter("serverPropertyName", "serverName")) />

		<!--- Set additional settings --->
		<cfif NOT Len(getDefaultEnvironment())>
			<cfset setThrowIfEnvironmentUnresolved(true) />
		</cfif>
		
		<!--- Build empty server map --->
		<cfloop list="#variables.ENVIRONMENT_GROUP_NAMES#" index="i">
			<cfset variables.serverMap[i] = ArrayNew(1) />	
		</cfloop>
		
		<!--- Discover environments and resolve environment by server name --->
		<cfset discoverEnvironments() />
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
		
		<!--- We are knowningly breaking encapsulation by using the cgi scope --->
		<cfset var thisServer = cgi.SERVER_NAME />
		<cfset var environmentName = "" />
		<cfset var properties = StructNew() />
		<cfset var environmentGroupServerMap = "" />
		<cfset var resolvedEnvironment = false />
		<cfset var key = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Check if this is a module since we differ to the environment of the parent application --->
		<cfif IsObject(getAppManager().getParent())>
			<cfset environmentName = getAppManager().getParent().getEnvironmentName() />
		<cfelse>
			<!--- Loop through the environment groups in order --->
			<cfloop list="#variables.ENVIRONMENT_GROUP_NAMES#" index="i">
				<cfset environmentGroupServerMap = variables.serverMap[i] />
				
				<cfloop from="1" to="#ArrayLen(environmentGroupServerMap)#" index="j">
					<cfif variables.matcher.match(environmentGroupServerMap[j].server, thisServer)>
						<cfset environmentName = environmentGroupServerMap[j].environmentName />
						<cfset getAppManager().setEnvironmentName(environmentName) />
						<cfset getAppManager().setEnvironmentGroup(i) />
						<cfset resolvedEnvironment = true />
						<cfbreak />
					</cfif>
				</cfloop>
				
				<cfif resolvedEnvironment>
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
		
		<!---
			Get properties by environment and fail back to default environment if
			no environment match is found (because we might have gotten the environment
			from the parent application and there may not be any corresponding environment)
		--->
		<cfif StructKeyExists(variables.environments, environmentName)>
			<cfset properties = variables.environments[environmentName].properties />
		<cfelse>
			<cfset getAssert().isTrue(NOT getThrowIfEnvironmentUnresolved()
						, "No environment can be resolved for '#thisServer#' and no default environment has been defined."
						, "Please define a default environment or add this server to a defined environment.") />
			<cfset properties = variables.environments[getDefaultEnvironment()].properties />
		</cfif>

		<!--- Set the server name to the property --->
		<cfset setProperty(getServerPropertyName(), thisServer) />
		
		<!--- Load properties by environment --->
		<cfloop collection="#properties#" item="key">
			<cfset setProperty(key, properties[key]) />
		</cfloop>
	</cffunction>
	
	<cffunction name="discoverEnvironments" access="private" returntype="void" output="false"
		hint="Loads all the environment servers.">
			
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
			<cfset getAssert().isTrue(StructKeyExists(arguments.environmentData, i)
						, "An environment named '#arguments.environmentName#' is missing a required key named '#i#' for the EnvironmentProperty in module '#getAppManager().getModuleName()#'."
						, "All environments require these keys: #variables.REQUIRED_ENVIRONMENT_KEY_NAMES#") />
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
	
</cfcomponent>