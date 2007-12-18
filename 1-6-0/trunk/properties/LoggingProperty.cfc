<!---
License:
Copyright 2007 GreatBizTools, LLC

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
$Id: Log.cfc 584 2007-12-15 08:44:43Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:

Configuring for Mach-II loging only:
<property name="Logging" type="MachII.properties.LoggingProperty" />

This will turn on the MachIILogAdapter and display the log message 
in the request output.

Configuring multiple logging adapters:
<property name="Logging" type="MachII.properties.LoggingProperty">
	<parameters>
		<parameter name="CFLog">
			<struct>
				<key name="type" value="MachII.logging.adapters.CFLogAdapter" />
				<key name="loggingEnabled" value="false" />
				<key name="loggingLevel" value="warn" />
			</struct>
		</parameter>
		<parameter name="MachIILog">
			<struct>
				<key name="type" value="MachII.logging.adapters.MachIILogAdapter" />
				<key name="loggingEnabled" value="true" />
				<key name="loggingLevel" value="debug" />
			</struct>
		</parameter>
	</parameters>
</property>

See individual logging adapter for more information on configuration.
--->
<cfcomponent
	displayname="LoggingProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Connects Mach-II Logging to the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.enableLogging = true />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">
		
		<cfset var params = getParameters() />
		<cfset var configured = false />
		<cfset var i = 0 />
		
		<!--- Set if logging is enabled (which is by default true) --->
		<cfif isParameterDefined("enableLogging")>
			<cfset setEnableLogging(getParameter("enableLogging")) />
		</cfif>
		
		<!--- Determine if we should load adapters or use the default 
			adapter (e.g. MachII.logging.adapters.MachIILogAdapter) --->
		<cfloop collection="#params#" item="i">
			<cfif i NEQ "enableLogging" AND IsStruct(params[i])>
				<cfset configureAdapter(i, getParameter(i)) />
				<cfset configured = true />
			</cfif>
		</cfloop>
		
		<!--- Configure the default adapter since no adapters were set --->
		<cfif NOT configured>
			<cfset configureDefaultAdapter() />
		</cfif>
		
		<!--- Set logging enabled/disabled --->
		<cfif NOT getEnableLogging()>
			<cfset getAppManager().getLogFactory().disableLogging() />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="disableLogging" access="public" returntype="void" output="false"
		hint="Disables logging.">
		<cfset getAppManager().getLogFactory().disableLogging() />
	</cffunction>
	
	<cffunction name="enableLogging" access="public" returntype="void" output="false"
		hint="Enables logging.">
		<cfset getAppManager().getLogFactory().enableLogging() />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="configureDefaultAdapter" access="private" returntype="void" output="false"
		hint="Configures the default logging adapter (e.g. MachII.logging.adapters.MachIILogAdapter).">
		
		<cfset var adapter = "" />
		<cfset var parameters = StructNew() />
		
		<cfset adapter = CreateObject("component", "MachII.logging.adapters.MachIILogAdapter").init(parameters) />
		<cfset adapter.configure() />

		<!--- Set the adapter to the LogFactory --->
		<cfset getAppManager().getLogFactory().addLogAdapter("default", adapter) />		
	</cffunction>
	
	<cffunction name="configureAdapter" access="private" returntype="void" output="false"
		hint="Configures an adapter.">
		<cfargument name="name" type="string" required="true"
			hint="Name of the adapter" />
		<cfargument name="parameters" type="struct" required="true"
			hint="Parameters for this adapter.">
		
		<cfset var type = "" />
		<cfset var adapter = "" />
		<cfset var i = 0 />
		
		<!--- Check and make sure the type is available otherwise there is not an adapter to create --->
		<cfif NOT StructKeyExists(arguments.parameters, "type")>
			<cfthrow type="MachII.properties.LoggingProperty"
				message="You must specify a 'type' for log adapter named '#arguments.name#'." />
		</cfif>
		
		<!--- Bind values in parameters struct since Mach-II only binds parameters at the root level --->
		<cfloop collection="#arguments.parameters#" item="i">
			<cfset arguments.parameters[i] = bindValue(i, arguments.parameters[i]) />
		</cfloop>
		
		<!--- Create the adapter --->
		<cfset adapter = CreateObject("component", arguments.parameters.type).init(arguments.parameters) />
		<cfset adapter.configure() />
		
		<!--- Set the adapter to the LogFactory --->
		<cfset getAppManager().getLogFactory().addLogAdapter(arguments.name, adapter) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setEnableLogging" access="public" returntype="void" output="false"
		hint="Sets if logging is enabled.">
		<cfargument name="enableLogging" type="boolean" required="true" />
		<cfset variables.enableLogging = arguments.enableLogging />
	</cffunction>
	<cffunction name="getEnableLogging" access="public" returntype="boolean" output="false"
		hint="Gets the value if logging is enabled.">
		<cfreturn variables.enableLogging />
	</cffunction>
	
	
</cfcomponent>