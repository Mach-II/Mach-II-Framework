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

$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="AutoUpdateListener"
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for base Auto Update structure.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<cfset setAutoUpdateService(CreateObject("component", "MachII.dashboard.model.autoUpdate.AutoUpdateService").init(getAppManager().getPropertyManager().getVersion(), getProperty('udfs').getVersionNumber(), getProperty('autoUpdateUrl'))) />
	</cffunction>

	<cffunction name="setAutoUpdateService" access="private" returntype="void" output="false">
		<cfargument name="AutoUpdateService" type="MachII.dashboard.model.autoUpdate.AutoUpdateService" required="true" />
		<cfset variables.AutoUpdateService = arguments.AutoUpdateService />
	</cffunction>
	<cffunction name="getAutoUpdateService" access="private" returntype="MachII.dashboard.model.autoUpdate.AutoUpdateService"  output="false">
		<cfreturn variables.AutoUpdateService />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->	
	<cffunction name="getPackageData" access="public" returntype="void" output="false"
		hint="Gets the data for all the active packages.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var packageData = StructNew() />
		<cfset var message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
		
		<cftry>
			<cfset packageData = getAutoUpdateService().getPackageData() />
			
			<cfcatch>
				<cfset message.setMessage("The Auto Update data could not be retrieved at this time.") />
				<cfset packageData.message = message />
				<cfset packageData.exitEvent = "fail" />	
			</cfcatch>
		</cftry>
		
		<cfset event.setArg("packageData", packageData) />
	</cffunction>
	
</cfcomponent>