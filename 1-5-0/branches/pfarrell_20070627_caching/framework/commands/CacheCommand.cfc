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
$Id$

Created version: 1.5.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent
	displayname="CacheCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for performing caching.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "cache" />
	<cfset variables.action = "" />
	<cfset variables.handlerId = "" />
	<cfset variables.alias = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="action" type="string" required="true" />
		<cfargument name="handlerId" type="uuid" required="false" default="#CreateUUID()#" />
		<cfargument name="alias" type="string" required="false" default="" />

		<cfset setAction(arguments.action) />
		<cfset setHandlerId(arguments.handlerId) />
		<cfset setAlias(arguments.alias) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var action = getAction() />
		<cfset var continue = true />
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<cfset var cacheHandler = "" />
		
		<!--- Run by the command action type --->
		<cfif action EQ "cache">
			<cfset cacheHandler = cacheManager.getCacheHandler(getHandlerId()) />
			<cfset contine = cacheHandler.handleCache(arguments.event, arguments.eventContext) />
		<cfelseif action EQ "clear">
			<cfset cacheManager.clearCachesByAlias(getAlias()) />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAction" access="public" returntype="void" output="false">
		<cfargument name="action" type="string" required="true" />
		<cfset variables.action = arguments.action />
	</cffunction>
	<cffunction name="getAction" access="public" returntype="string" output="false">
		<cfreturn variables.action />
	</cffunction>
	
	<cffunction name="setHandlerId" access="public" returntype="void" output="false">
		<cfargument name="handlerId" type="uuid" required="true" />
		<cfset variables.handlerId = arguments.handlerId />
	</cffunction>
	<cffunction name="getHandlerId" access="public" returntype="uuid" output="false">
		<cfreturn variables.handlerId />
	</cffunction>
	
	<cffunction name="setAlias" access="public" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="public" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>

</cfcomponent>