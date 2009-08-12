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

Created version: 1.6.0
Updated version: 1.8.0

Notes:
FilterCriteria can be an comma delimited list or an array.
-----------------------------------------------------------------------------------------
|	Pattern				|	Matches Channels											|
-----------------------------------------------------------------------------------------
|	*					|	Matches everything (unless you have another pattern that	| 
|						|		specifies not to match a channel name) 					|
|	!*					|	Nothing (unless you have another pattern that matches)		|
|	MachII.*			|	Matches all channels that start with 'MachII.'				|
|	!myApp.model.*		|	Does not match any channels that start with 'myApp.model.'	|
|	MachII				|	Matches only 'MachII' literal not 'MachII.framework.etc'	|
----------------------------------------------------------------------------------------|

! 			= Do not match (can only occur at the beginning of a pattern string)
no ! or *	= Indicates that you should match exact channel name
* 			= Wildcard (can only occur at the end of a pattern string)

Pattern matches are not case sensitive.
--->
<cfcomponent
	displayname="GenericChannelFilter"
	extends="MachII.logging.filters.AbstractFilter"
	output="false"
	hint="Makes decisions on whether to log or not based on channel name and known criteria.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.filterChannels = ArrayNew(1) />
	<cfset variables.matcher = CreateObject("component", "MachII.util.SimplePatternMatcher").init() />
	<cfset variables.instance.filterTypeName = "Channel" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="GenericChannelFilter" output="false"
		hint="Initalizes the filter.">
		<cfargument name="filterCriteria" type="any" required="false" default=""
			hint="Criteria to filter on. Accepts an array or list." />
		
		<cfset loadFilterCriteria(arguments.filterCriteria) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="decide" access="public" returntype="boolean" output="true"
		hint="Decides whether or not the passed channel should be logged.">
		<cfargument name="logMessageElements" type="struct" required="true" />
		
		<cfset var channel = arguments.logMessageElements.channel />
		<cfset var result = "" />
		<cfset var noRestrictMatch = 0 />
		<cfset var restrictMatch = 0 />
		<cfset var filterChannels = getFilterChannels() />
		<cfset var filterChannelLength = 0 />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(filterChannels)#" index="i">
			<cfset result = variables.matcher.match(filterChannels[i].channel, channel) />
			
			<cfset filterChannelLength = Len(filterChannels[i].channel) />
			
			<cfif NOT filterChannels[i].restrict AND result>
				<cfif filterChannelLength GT noRestrictMatch>
					<cfset noRestrictMatch = filterChannelLength />
				</cfif>
			<cfelseif filterChannels[i].restrict AND result>
				<cfif filterChannelLength GT restrictMatch>
					<cfset restrictMatch = filterChannelLength />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- More specific no restricted matches have a longer length if they match more exactly --->
		<cfif noRestrictMatch GT restrictMatch>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getFilterCriteria" access="public" returntype="array" output="false"
		hint="Gets a struct of filter criteria.">
		
		<cfset var criteria = getFilterChannels() />
		<cfset var result = ArrayNew(1) />
		<cfset var temp = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(criteria)#" index="i">
			<cfset temp = criteria[i].channel />
			
			<cfif criteria[i].restrict>
				<cfset temp = "!" & temp />
			</cfif>
			
			<cfset ArrayAppend(result, temp) />
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

		<!--- Convert to an arry if the criteria is a list --->
		<cfif IsSimpleValue(arguments.filterCriteria)>
			<cfset arguments.filterCriteria = ListToArray(arguments.filterCriteria, ",") />
		</cfif>
		
		<!--- Only convert criteria data structure if there are criteria --->
		<cfif ArrayLen(arguments.filterCriteria)>
			<cfloop from="1" to="#ArrayLen(arguments.filterCriteria)#" index="i">
				<cfset temp = StructNew() />
				<cfset channel = arguments.filterCriteria[i] />
				
				<!--- Check restriction (will always be the first character)--->
				<cfif Left(channel, 1)  EQ "!">
					<cfset temp.restrict = true />
					
					<!--- If there is no channel and only a directive of ! --->
					<cfif Len(channel) GT 1>
						<cfset channel = Right(channel, Len(channel) -1) />
					<cfelse>
						<cfset channel = "" />
					</cfif>
				<cfelse>
					<cfset temp.restrict = false />
				</cfif>
				
				<!--- Set channel string --->
				<cfset temp.channel = channel />
				
				<!--- Set to the channel filter array --->
				<cfset ArrayAppend(filterChannels, temp) />
			</cfloop>
		</cfif>
		
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
	<cffunction name="getFilterChannels" access="public" returntype="array" output="false">
		<cfreturn variables.filterChannels />
	</cffunction>
	
</cfcomponent>