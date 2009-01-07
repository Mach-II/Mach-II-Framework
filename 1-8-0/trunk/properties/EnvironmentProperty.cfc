<!---
License:
Copyright 2008 GreatBizTools, LLC

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
to detect and load the correct environment properties when the application
is loaded.

The property provider a the ability to set properties for four deployment
environments 'development', 'staging', 'qualityAssurance' and 'production'
as supported by the core framework. Also, the proeprty plays nice when used 
in a module by using the environment mode from the parent application when 
this property is defined in a module.

Usage:
<property name="environment" type="MachII.properties.EnvironmentProperty">
	<parameters>
		<!-- Name of default environment to use if no server matches -->
		<parameter name="defaultEnvironment" value="production" />
		
		<!-- List or array of developer servers -->
		<parameter name="developmentServers" value="" />
		
		<!-- Struct of development properties to set -->
		<parameter name="developmentProperties">
			<struct>
				<key name="" value="" />
			</struct>
		</parameter>
		
		<!-- List or array of statging servers -->
		<parameter name="stagingServers" value="" />
		
		<!-- Struct of staging properties to set -->
		<parameter name="stagingProperties">
			<struct>
				<key name="" value="" />
			</struct>
		</parameter>
		
		<!-- List or array of quality assurance servers -->
		<parameter name="qualityAssuranceServers" value="" />
		
		<!-- Struct of quality assurance properties to set -->
		<parameter name="qualitAssuranceProperties">
			<struct>
				<key name="" value="" />
			</struct>
		</parameter>
		
		<!-- List or array of production servers -->
		<parameter name="productionServers" value="" />
		
		<!-- Struct of production properties to set -->
		<parameter name="productionProperties">
			<struct>
				<key name="" value="" />
			</struct>
		</parameter>		
	</parameters>
</property>

The [defaultEnvironment] parameter indicates which environment to load if
there is no server name to another environment when loaded. By design for 
security, this parameter defaults to 'production'.

The [development|staging|qualityAssurance|productionServers] parameter takes 
a list or array of server names that are used to check if the development 
environment is applicable and the corresponding the properties are to be 
set the to the Mach-II property manager.

The [development|staging|qualityAssurance|productionProperies] parameter takes 
a struct of data to be set as Mach-II properties if the environment is selected.  
--->
<cfcomponent 
	displayname="EnvironmentProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets environment mode and properties based on the where the application is deployed.">

	<!---
	PROPERTIES
	--->
	<cfset variables.defaultEnvironment = "production" />
	<cfset variables.servers = StructNew() />
	<cfset variables.properties = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<!--- Load in parameters --->
		<cfset setDefaultEnvironment(getParameter("defaultEnvironment", "production")) />
		<cfset loadEnvironments() />
		
		<!--- Load correct environment --->
		<cfset discoverAndLoadEnvironmentByServer() />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS	
	--->
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="discoverAndLoadEnvironmentByServer" access="private" returntype="void" output="false"
		hint="Dectects the server and loads environment by server name.">
		
		<!--- We are knowningly breaking encapsulation by using the cgi scope --->
		<cfset var deployedServerHash = createHashKey(cgi.SERVER_NAME) />
		<cfset var environment = getDefaultEnvironment() />
		<cfset var properties = StructNew() />
		<cfset var key = "" />
		
		<!--- Check if this is a module since we differ to the environment of the parent application --->
		<cfif IsObject(getAppManager().getParent())>
			<cfset environment = getAppManager().getParent().getEnvironment() />
		<cfelse>
			<cfif StructKeyExists(variables.servers, deployedServerHash)>
				<cfset environment = variables.servers[deployedServerHash] />
				<cfset getAppManager().setEnvironment(environment) />
			</cfif>
		</cfif>
		
		<!---
			Get properties by environment and fail back to default environment if
			no environment match is found (because we might have gotten the environment
			from the parent application and there may not be any corresponding environment)
		--->
		<cfif StructKeyExists(variables.properties, environment)>
			<cfset properties = variables.properties[environment] />
		<cfelse>
			<cfset properties = variables.properties[getDefaultEnvironment()] />
		</cfif>
		
		<!--- Load properties by environment --->
		<cfloop collection="#properties#" item="key">
			<cfset setProperty(key, properties[key]) />
		</cfloop>
	</cffunction>
	
	<cffunction name="loadEnvironments" access="private" returntype="void" output="false"
		hint="Loads all the environment servers.">
		
		<!--- Load environments --->
		<cfset loadServersAndPropertiesByEnvironment("development"
			, getParameter("developmentServers")
			, getParameter("developmentProperties", StructNew())) />
		<cfset loadServersAndPropertiesByEnvironment("staging"
			, getParameter("stagingServers")
			, getParameter("stagingProperties", StructNew())) />
		<cfset loadServersAndPropertiesByEnvironment("qualityAssurance"
			, getParameter("qualityAssuranceServers")
			, getParameter("qualityAssuranceProperties", StructNew())) />
		<cfset loadServersAndPropertiesByEnvironment("production"
			, getParameter("productionServers")
			, getParameter("productionProperties", StructNew())) />
	</cffunction>
	
	<cffunction name="loadServersAndPropertiesByEnvironment" access="private" returntype="void" output="false"
		hint="Loads an environment servers and properties by environment name.">
		<cfargument name="name" type="string" required="true"
			hint="The environment name.">
		<cfargument name="servers" type="any" required="true"
			hint="An list or array of servers.">
		<cfargument name="properties" type="struct" required="true"
			hint="A struct of properties.">
		
		<cfset var i = 0 />
		
		<!--- Transform list to an array of servers --->
		<cfif NOT IsArray(arguments.servers)>
			<cfset arguments.servers = ListToArray(getUtils().trimList(arguments.servers)) />
		</cfif>
		
		<!--- Build server name hashes to lookup table --->
		<cfloop from="1" to="#ArrayLen(arguments.servers)#" index="i">
			<cfset variables.servers[createHashKey(arguments.servers[i])] = arguments.name />
		</cfloop>
		
		<!--- Add the properties to the right environment --->
		<cfset variables.properties[arguments.name] = arguments.properties />
	</cffunction>

	<cffunction name="createHashKey" access="public" returntype="string" output="false"
		hint="Creates a hash key from the passed data by uppercasing the criteria and hashing.">
		<cfargument name="criteria" type="string" required="true"
			hint="A string of criteria to use." />
		<cfreturn Hash(Ucase(arguments.criteria)) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setDefaultEnvironment" access="private" returntype="void" output="false">
		<cfargument name="defaultEnvironment" type="string" required="true" />
		<cfset getAssert().isTrue(ListFindNoCase("development,staging,qualityAssurance,production", arguments.defaultEnvironment)
			, "The 'defaultEnvironment' parameter must be a valid value."
			, "Acceptable values are 'development', 'staging', 'qualityAssurance' and 'production'") />
		<cfset variables.defaultEnvironment = arguments.defaultEnvironment />
	</cffunction>
	<cffunction name="getDefaultEnvironment" access="public" returntype="string" output="false">
		<cfreturn variables.defaultEnvironment />
	</cffunction>
	
</cfcomponent>