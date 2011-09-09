<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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

Created version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="AdminApiAdapter"
	output="false"
	hint="Abstract API that adapters a CFML engine API.">

	<!---
	PROPERTIES
	--->
	<cfset variables.matcher = CreateObject("component", "MachII.util.matching.SimplePatternMatcher").init() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AdminApiAdapter" output="false"
		hint="Initializes the adapter.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getScheduledTasks" access="public" returntype="struct" output="false"
		hint="Gets a struct of all scheduled tasks by search pattern.">
		<cfargument name="searchPattern" type="string" required="false"
			default="*"
			hint="Allows you to filter by task name using simple patern matching syntax." />
		<cfabort showerror="This method is abstract and must be overriden." />
	</cffunction>

	<cffunction name="deleteTasks" access="public" returntype="void" output="false"
		hint="Deletes all scheduled tasks by filter pattern.">
		<cfargument name="searchPattern" type="string" required="false"
			default="*"
			hint="Allows you to filter by task name using simple patern matching syntax." />

		<cfset var tasks = getScheduledTasks(arguments.searchPattern) />
		<cfset var key = "" />

		<cfloop collection="#tasks#" item="key">
			<cfschedule action="delete" task="#key#" />
		</cfloop>
	</cffunction>

	<cffunction name="addTask" access="public" returntype="void" output="false"
		hint="Adds a scheduled task.">
		<cfargument name="task" type="string" required="true"
			hint="Name of task." />
		<cfargument name="url" type="string" required="true"
			hint="URL to task." />
		<cfargument name="interval" type="string" required="true"
			hint="The interval to run the task ('once', 'daily', 'weekly', 'monthly' or X seconds)" />
		<cfargument name="startDate" type="date" required="true"
			hint="The date to start the task." />
		<cfargument name="endDate" type="any" required="false"
			hint="The data to end the task. Use '0' for infinity." />
		<cfargument name="timePeriod" type="string" required="false"
			hint="The time perdiod to run the task. Use 24 hour time (ex. run only between 5-7pm 17:00-19:00)" />
		<cfargument name="username" type="string" required="false" default=""
			hint="The username for basic HTTP access authentication." />
		<cfargument name="password" type="string" required="false" default=""
			hint="The password for basic HTTP access authentication." />
		<cfargument name="requestTimeout" type="numeric" required="false"
			default="90"
			hint="The number of seconds for the task to run before timing out." />

		<!--- Convert interval timespan into seconds--->
		<cfif REFindNoCase("([0-9]+,){3}([0-9]+)", arguments.interval)>
			<cfset arguments.interval = convertTimespanStringToSeconds(arguments.interval) />
		</cfif>

		<!--- Convert the dates OpenBD requires dates to be in the mm/dd/yyyy where ACF is more forgiving --->
		<cfset arguments.startDate = DateFormat(arguments.startDate, "mm/dd/yyyy") />

		<!--- Use "text" comparison since this could be 0 or a date --->
		<cfif StructKeyExists(arguments, "endDate") AND arguments.endDate IS "0">
			<cfset StructDelete(arguments, "endDate", false) />
		<cfelseif StructKeyExists(arguments, "endDate") AND arguments.endDate.toLowerCase().startsWith("ts {'")>
			<cfset arguments.endDate = DateFormat(arguments.endDate, "mm/dd/yyyy") />
		</cfif>

		<!--- Convert time period into start/EndTime keys (if required) --->
		<cfif StructKeyExists(arguments, "timePeriod")>
			<cfif REFindNoCase("[0-9]{1,2}:[0-9]{2}(-[0-9]{1,2}:[0-9]{2})?", arguments.timePeriod)>
				<cfset arguments.startTime = ListFirst(arguments.timePeriod, "-") />
				<cfif ListLen(arguments.timePeriod, "-") EQ 2>
					<cfset arguments.endTime = ListLast(arguments.timePeriod, "-") />
				</cfif>
			<cfelse>
				<cfthrow type="MachII.util.cfmlEngine.InvalidTimePeriodFormat" />
			</cfif>
		<cfelse>
			<cfset arguments.startTime = "00:00:00" />
			<cfset arguments.endTime = "23:59:00" />
		</cfif>

		<cfif StructKeyExists(arguments, "endDate")>
			<cfschedule action="update"
				task="#arguments.task#"
				interval="#arguments.interval#"
				operation="HTTPRequest"
				url="#arguments.url#"
				startDate="#arguments.startDate#"
				startTime="#arguments.startTime#"
				endDate="#arguments.endDate#"
				endTime="#arguments.endTime#"
				username="#arguments.username#"
				password="#arguments.password#"
				requestTimeout="#arguments.requestTimeout#" />
		<cfelse>
			<cfschedule action="update"
				task="#arguments.task#"
				interval="#arguments.interval#"
				operation="HTTPRequest"
				url="#arguments.url#"
				startDate="#arguments.startDate#"
				startTime="#arguments.startTime#"
				username="#arguments.username#"
				password="#arguments.password#"
				requestTimeout="#arguments.requestTimeout#" />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="convertTimespanStringToSeconds" access="private" returntype="numeric" output="false"
		hint="Converts a timespan string (e.g. 0,0,0,0) into seconds.">
		<cfargument name="timespanString" type="string" required="true"
			hint="The input timespan string." />

		<cfset var timespan = CreateTimespan(ListGetAt(arguments.timespanString, 1), ListGetAt(arguments.timespanString, 2), ListGetAt(arguments.timespanString, 3), ListGetAt(arguments.timespanString, 4)) />

		<cfreturn Round((timespan * 60) / 0.000694444444444) />
	</cffunction>

</cfcomponent>