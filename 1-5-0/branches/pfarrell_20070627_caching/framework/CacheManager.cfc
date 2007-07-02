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
	displayname="CacheManager"
	output="false"
	hint="Performs an unified API for caching in Mach-II.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentCacheManager = "" />
	<cfset variables.handlers = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheManager" output="false"
		hint="Initializaes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentCacheManager" type="any" required="false" default=""
			hint="Optional argument for a parent cache manager. If not defined, default to zero-length string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif IsObject(arguments.parentCacheManager)>
			<cfset setParent(arguments.parentCacheManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures manager.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addCacheHandler" access="public" returntype="void" output="false"
		hint="Adds a cache handler.">
		<cfargument name="cacheHandler" type="MachII.framework.CacheHandler" required="true" />		
		<cfset variables.handlers[arguments.cacheHandler.getHandlerId()] = arguments.cacheHandler />
	</cffunction>
	
	<cffunction name="getCacheHandler" access="public" returntype="MachII.framework.CacheHandler" output="false"
		hint="Gets a cache handler.">
		<cfargument name="handlerId" type="uuid" required="true" />
		<cfreturn variables.handlers[arguments.handlerId] />
	</cffunction>
	
	<cffunction name="removeCacheHandler" access="public" returntype="void" output="false"
		hint="Removes a cache handler.">
		<cfargument name="handlerId" type="uuid" required="true"
			hint="Handler id of the cache handler you want to remove." />
		<cfset StructDelete(variables.handlers, arguments.handlerId, false) />
	</cffunction>
		
	<cffunction name="isCacheHandlerDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a cache handler is defined.">
		<cfargument name="handlerId" type="uuid" required="true" 
			hint="Handler if of the cache handler you want to check if it is defined." />
		<cfreturn StructKeyExists(variables.handlers, arguments.handlerId) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent CacheManager instance this CacheManager belongs to.">
		<cfargument name="parentCacheManager" type="MachII.framework.CacheManager" required="true" />
		<cfset variables.parentCacheManager = arguments.parentCacheManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent CacheManager instance this CacheManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentCacheManager />
	</cffunction>
	
</cfcomponent>