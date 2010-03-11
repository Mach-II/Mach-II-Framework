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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.9.0

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
		
		<cfset var channelHash = Hash(UCase(arguments.channel)) />
		
		<!--- It is not necessary to lock since a few extra logs will not hurt memory as much as a lock hurts performance --->
		<cfif NOT StructKeyExists(variables.logCache, channelHash)>
			<cfset variables.logCache[channelHash] = CreateObject("component", "MachII.logging.Log").init(arguments.channel, variables.logAdapters) />
		</cfif>
		
		<cfreturn variables.logCache[channelHash] />
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