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
Updated version: 1.6.0

Notes:
<property name="Logging" type="MachII.logging.LoggingProperty">
	<parameters>
		<parameter name="CFLog">
			<struct>
				<key name="type" value="MachII.logging.loggers.CFLog.Logger" />
				<!-- Optional and defaults to true -->
				<key name="loggingEnabled" value="true|false" />
				- OR - 
	            <key name="loggingEnabled">
	            	<struct>
	            		<key name="development" value="false"/>
	            		<key name="production" value="true"/>
	            	</struct>
	            </key>
				<!-- Optional and defaults to 'fatal' -->
				<key name="loggingLevel" value="all|trace|debug|info|warn|error|fatal|off" />
				<!-- Optional and defaults to the application.log if not defined -->
				<key name="logFile" value="nameOfCFLogFile" />
				<!-- Optional and defaults to 'false'
					logs messages only if CF's debug mode is enabled -->
				<key name="debugModeOnly" value="false" />
				<!-- Optional -->
				<key name="filter" value="list,of,filter,criteria" />
				- OR -
				<key name="filter">
					<array>
						<element value="array" />
						<element value="of" />
						<element value="filter" />
						<element value="criteria" />
					</array>
				</key>
			</struct>
		</parameter>
	</parameters>
</property>

Uses the generic channel filter (MachII.logging.filters.GenericChannelFilter)for filtering.
See that file header for configuration of filter criteria.
--->
<cfcomponent
	displayname="Logger for CFLog"
	extends="MachII.logging.loggers.AbstractLogger"
	output="false"
	hint="Concrete CFLog logger implementation for Mach-II logging.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance.loggerTypeName = "CFLog" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the logger.">
		
		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init(getParameter("filter", "")) />
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.CFLogAdapter").init(getParameters()) />
		
		<!--- For better peformance, set the filter to the adapter only we have something to filter --->
		<cfif ArrayLen(filter.getFilterChannels())>
			<cfset adapter.setFilter(filter) />
		</cfif>
		
		<!--- Configure and set the adapter --->
		<cfset adapter.configure() />
		<cfset setLogAdapter(adapter) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets the configuration data for this logger including adapter and filter.">
		
		<cfset var data = StructNew() />
		
		<cfset data["Log File Name"] = getLogAdapter().getLogFile() />
		<cfset data["Logging Enabled"] = YesNoFormat(isLoggingEnabled()) />
		
		<cfreturn data />
	</cffunction>
	
</cfcomponent>