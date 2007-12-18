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
$Id: CFLogAdapter.cfc 584 2007-12-15 08:44:43Z peterfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="GenericChannelFilter"
	output="false"
	hint="">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.filterChannels = ArrayNew(1) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="GenericChannelFilter" output="false"
		hint="Initalizes the filter.">
		<cfargument name="filterCriteria" type="any" required="false"
			hint="Criteria to filter on. Accepts an array or list." />
		
		<cfif StructKeyExists(arguments, "filterCriteria")>
			<cfset loadFilterCriteria(arguments.filterCriteria) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="decide" access="public" returntype="boolean" output="false"
		hint="Decides whether or not the passed channel should be logged.">
		<cfargument name="channel" type="string" required="true" />
		
		<cfset var result = true />
		<cfset var filterChannels = getFilterChannels() />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(filterChannels)#" index="i">
			<!--- Restrict --->
			<cfif filterChannels[i].restrict>
				<!--- Wildcard --->
				<cfif filterChannels[i].wildcard>
					<cfif FindNoCase(filterChannels[i].channel, arguments.channel) EQ 1>
						<cfset result = false />
					</cfif>
				<cfelse>
					<cfif filterChannels[i].channel IS arguments.channel>
						<cfset result = false />
					</cfif>
				</cfif>
			<cfelse>
			
				<!--- Wildcard --->
				<cfif filterChannels[i].wildcard>
					<cfif FindNoCase(filterChannels[i].channel, arguments.channel) EQ 1>
						<cfset result = true />
					</cfif>
				<cfelse>
					<cfif filterChannels[i].channel IS arguments.channel>
						<cfset result = true />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadFilterCriteria" access="private" returntype="void" output="false"
		hint="Loads filter criteria.">
		<cfargument name="filterCriteria" type="any" required="false" />
		
		<cfset var filterChannels = ArrayNew(1) />
		<cfset var temp = "" />
		<cfset var channel = "" />
		<cfset var i = 0 />
		
		<cfif IsSimpleValue(arguments.filterCriteria)>
			<cfset arguments.filterCriteria = ListToArray(arguments.filterCriteria, ",") />
		</cfif>
		
		<cfloop from="1" to="#ArrayLen(arguments.filterCriteria)#" index="i">
			<cfset temp = StructNew() />
			<cfset channel = arguments.filterCriteria[i] />
			
			<!--- Check restriction --->
			<cfif Left(channel, 1)  EQ "!">
				<cfset temp.restrict = true />
				<cfset channel = Right(channel, Len(channel) -1) />
			<cfelse>
				<cfset temp.restrict = false />
			</cfif>
			
			<!--- Check for Wildcard --->
			<cfif Right(channel, 1) EQ "*">
				<cfset temp.wildcard = true />
				<cfif Len(channel) GT 1>
					<cfset channel = Left(channel, Len(channel) -1) />
				<cfelse>
					<cfset channel = "" />
				</cfif>
			<cfelse>
				<cfset temp.wildcard = false />
			</cfif>
			
			<!--- Set channel string --->
			<cfset temp.channel = channel />
			
			<!--- Set to the channel filter array --->
			<cfset ArrayAppend(filterChannels, temp) />
		</cfloop>
		
		<!--- Set the all the filterChannels --->
		<cfset setFilterChannels(filterChannels) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setFilterChannels" access="private" returntype="void" output="false">
		<cfargument name="filterChannels" type="array" required="true" />
		<cfset variables.filterChannels = arguments.filterChannels />
	</cffunction>
	<cffunction name="getFilterChannels" access="private" returntype="array" output="false">
		<cfreturn variables.filterChannels />
	</cffunction>
	
</cfcomponent>