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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
Mach-II Logging is heavily based on Apache Commons Logging interface but is more flexible as
it allows you attach multiple loggers at once. Thank you to the Apache project for the 
inspiration for our implementation.

Log adapters must be stored as a struct so they can be passed by reference. Otherwise some
logs are requested before adapters have been setup and will not log any messages since they
do not have any adapters.

Implementation Notes:
* Channel names are not case-sensitive as the channel name is converted useable struct key
first [Hash(UCase(arguments.channell))]
--->
<cfcomponent
	displayname="LogFactory"
	output="false"
	hint="A factory that creates log instances.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.logAdapters = StructNew() />
	<cfset variables.logCache = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="LogFactory" output="false"
		hint="Initializes the factory.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets a new log instance. Returns a cached instance if the channel already exists.">
		<cfargument name="channel" type="string" required="true"
			hint="Channel to log. Typically 'getMetadata(this).name'" />
		
		<cfset var log = "" />
		<cfset var channelHash = createChannelHash(arguments.channel) />
		
		<!--- Single thread this since we want to keep the log cache from overwritting an entry --->
		<cflock name="_MachIILogFactory.channel_#channelHash#" type="exclusive" timeout="10" throwontimeout="true">
			<cfif hasInCache(arguments.channel)>
				<cfset log = getFromCache(arguments.channel) />
			<cfelse>
				<cfset log = CreateObject("component", "MachII.logging.Log").init(arguments.channel, getLogAdapters()) />
				<cfset putToCache(arguments.channel, log) />
			</cfif>
		</cflock>
		
		<cfreturn log />
	</cffunction>
	
	<cffunction name="addLogAdapter" access="public" returntype="void" output="false"
		hint="Adds a log adapter.">
		<cfargument name="logAdapterName" type="string" required="true" />
		<cfargument name="logAdapter" type="MachII.logging.adapters.AbstractLogAdapter" required="true" />
		<cfset variables.logAdapters[arguments.logAdapterName] = arguments.logAdapter />
	</cffunction>
	
	<cffunction name="removeLogAdapter" access="public" returntype="void" output="false"
		hints="Removes a log adapter by log adapter name.">
		<cfargument name="logAdapterName" type="string" required="true" />
		<cfset StructDelete(variables.logAdapters, arguments.logAdapterName, false) />	
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="disableLogging" access="public" returntype="void" output="false"
		hint="Disables logging.">
		
		<cfset var key = "" />
		
		<cfloop collection="#variables.logAdapters#" item="key">
			<cfset variables.logAdapters[key].setLoggingEnabled(false) />
		</cfloop>
	</cffunction>
	<cffunction name="enableLogging" access="public" returntype="void" output="false"
		hint="Enables logging.">
			
		<cfset var key = "" />
		
		<cfloop collection="#variables.logAdapters#" item="key">
			<cfset variables.logAdapters[key].setLoggingEnabled(true) />
		</cfloop>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="hasInCache" access="private" returntype="boolean" output="false"
		hint="Checks to see if a log is already in the cache.">
		<cfargument name="channel" type="string" required="true" />
		
		<cfset var result = false />
		
		<cfif StructKeyExists(variables.logCache, createChannelHash(arguments.channel))>
			<cfset result = true />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="putToCache" access="private" returntype="void" output="false"
		hint="Puts a log into the cache.">
		<cfargument name="channel" type="string" required="true" />
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.logCache[createChannelHash(arguments.channel)] = arguments.log />
	</cffunction>
	
	<cffunction name="getFromCache" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets a log from the cache.">
		<cfargument name="channel" type="string" required="true" />
		<cfreturn variables.logCache[createChannelHash(arguments.channel)] />
	</cffunction>
	
	<cffunction name="createChannelHash" access="private" returntype="string" output="false"
		hint="Creates a channel hash.">
		<cfargument name="channel" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.channel)) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setLogAdapters" access="private" returntype="void" output="false"
		hint="Sets the log adapters.">
		<cfargument name="logAdapters" type="struct" required="true" />
		<cfset variables.logAdapters = arguments.logAdapters />
	</cffunction>
	<cffunction name="getLogAdapters" access="public" returntype="struct" output="false"
		hint="Returns the log adapters.">
		<cfreturn variables.logAdapters />
	</cffunction>
	
</cfcomponent>