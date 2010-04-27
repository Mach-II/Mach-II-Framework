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

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="EventArgCommandTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.commands.EventArgCommand.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventArgCommand = "" />
	<cfset variables.appManager = "" />
	<cfset variables.eventContext = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
			
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		<cfset var requestHandler= "" />
		<cfset var eventContext = "" />
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />
		
		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset appManager.setPropertyManager(propertyManager) />
		<cfset setAppManager(appManager) />
		
		<!--- Setup a clean EventContext --->
		<cfset requestHandler = CreateObject("component", "MachII.framework.RequestHandler").init(
			appManager, "event", "form", ":", 10, "") />
		<cfset eventContext = CreateObject("component", "MachII.framework.EventContext").init(
			requestHandler, 
			CreateObject("component", "MachII.util.SizedQueue").init()) />
		<cfset setEventContext(eventContext) />
		
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- This method left intentionally blank --->
	</cffunction>
	
	<cffunction name="getAppManager" access="private" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	
	<cffunction name="getEventContext" access="private" returntype="MachII.framework.EventContext" output="false">
		<cfreturn variables.eventContext />
	</cffunction>
	<cffunction name="setEventContext" access="private" returntype="void" output="false">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfset variables.eventContext = arguments.eventContext />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testArgWithValueWithOverwrite" access="public" returntype="void" output="false"
		hint="Tests an arg with value with overwrite.">
			
		<cfset var command = "" />
		<cfset var event = "" />
		<cfset var eventContext = getEventContext() />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventArgCommand").init(
							"firstName", "Joseph", "", true) />
		<cfset command.setLog(getAppManager().getLogFactory().getLog("MachII.framework.commands.EventArgCommand")) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		
		<cfset event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset event.setArg("firstname", "Peter") />
		
		<cfset eventContext.setup(getAppManager(), event) />
		
		<cfset command.execute(event, eventContext) />
		
		<cfset assertTrue(event.getArg("firstName") eq "Joseph", "event.getArg('firstName') should return 'Joseph'") />
	</cffunction>

	<cffunction name="testArgWithValueNoOverwrite" access="public" returntype="void" output="false"
		hint="Tests an arg with value no overwrite.">
			
		<cfset var command = "" />
		<cfset var event = "" />
		<cfset var eventContext = getEventContext() />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventArgCommand").init(
							"firstName", "Joseph", "", false) />
		<cfset command.setLog(getAppManager().getLogFactory().getLog("MachII.framework.commands.EventArgCommand")) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		
		<cfset event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset event.setArg("firstname", "Peter") />
		
		<cfset eventContext.setup(getAppManager(), event) />
		
		<cfset command.execute(event, eventContext) />
		
		<cfset assertTrue(event.getArg("firstName") eq "Peter", "event.getArg('firstName') should return 'Peter'") />
	</cffunction>

</cfcomponent>