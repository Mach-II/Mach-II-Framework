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

Created version: 1.6.0
Updated version: 1.8.1

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
	<cfset variables.utils = "" />
	<cfset variables.uniqueId = createRandomKey() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="LogFactory" output="false"
		hint="Initializes the factory.">

		<cfset setUtils(CreateObject("component", "MachII.util.Utils").init()) />

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

		<cfif hasInCache(arguments.channel)>
			<cfset log = getFromCache(arguments.channel) />
		<cfelse>
			<cflock name="_MachIILogFactory.logFactory_#variables.uniqueId#.channel_#createChannelHash(arguments.channel)#" type="exclusive" timeout="10" throwontimeout="true">
				<cfif hasInCache(arguments.channel)>
					<cfset log = getFromCache(arguments.channel) />
				<cfelse>
					<cfset log = CreateObject("component", "MachII.logging.Log").init(arguments.channel, getLogAdapters()) />
					<cfset putToCache(arguments.channel, log) />
				</cfif>
			</cflock>
		</cfif>

		<cfreturn log />
	</cffunction>

	<cffunction name="addLogAdapter" access="public" returntype="void" output="false"
		hint="Adds a log adapter.">
		<cfargument name="logAdapter" type="MachII.logging.adapters.AbstractLogAdapter" required="true" />
		<cfset variables.logAdapters[createRandomKey()] = arguments.logAdapter />
	</cffunction>

	<cffunction name="removeLogAdapter" access="public" returntype="void" output="false"
		hints="Removes a log adapter by log adapter instance.">
		<cfargument name="logAdapter" type="MachII.logging.adapters.AbstractLogAdapter" required="true"
			hint="The instance of the log adapter to remove" />

		<cfset var utils = getUtils() />
		<cfset var key = "" />

		<cfloop collection="#variables.logAdapters#" item="key">
			<cfif utils.assertSame(variables.logAdapters[key], arguments.logAdapter)>
				<cfset StructDelete(variables.logAdapters, key, false) />
				<cfbreak />
			</cfif>
		</cfloop>
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

	<cffunction name="createRandomKey" access="private" returntype="string" output="false"
		hint="Creates a random key.">
		<cfreturn Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000)) />
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

	<cffunction name="setUtils" access="private" returntype="void" output="false">
		<cfargument name="utils" type="MachII.util.Utils" required="true" />
		<cfset variables.utils = arguments.utils />
	</cffunction>
	<cffunction name="getUtils" access="public" returntype="MachII.util.Utils" output="false">
		<cfreturn variables.utils />
	</cffunction>

</cfcomponent>