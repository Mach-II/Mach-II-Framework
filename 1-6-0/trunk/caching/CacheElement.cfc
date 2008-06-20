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
$Id: CacheStats.cfc 701 2008-03-22 22:07:01Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheElement"
	output="false"
	hint="Represents elements inside a cache.">

	<!---
	PROPERTIES
	--->
	<cfset variables.data = "" />
	<cfset variables.isStale = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheElement" output="false"
		hint="Initializes the cache element.">
		
		<cfreturn this />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setData" access="public" returntype="void" output="false"
		hint="Returns the data that is part of the CacheElement.">
		<cfargument name="data" type="any" required="true" />
		<cfset variables.data = arguments.data />
	</cffunction>
	<cffunction name="getData" access="public" returntype="any" output="false"
		hint="Gets the data which will be inside this CacheElement.">
		<cfreturn variables.data />
	</cffunction>
	
	<cffunction name="setIsStale" access="public" returntype="void" output="false"
		hint="If the stale attribute is set to true the element has expired from the cache.">
		<cfargument name="isStale" type="boolean" required="true" />
		<cfset variables.isStale = arguments.isStale />
	</cffunction>
	<cffunction name="getIsStale" access="public" returntype="any" output="false"
		hint="If the stale attribute is set to true the element has expired from the cache.">
		<cfreturn variables.isStale />
	</cffunction>

</cfcomponent>