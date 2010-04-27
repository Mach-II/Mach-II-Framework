<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
	<cffunction name="decide" access="public" returntype="boolean" output="false"
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