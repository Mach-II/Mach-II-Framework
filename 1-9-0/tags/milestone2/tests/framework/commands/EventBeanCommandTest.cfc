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

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="EventBeanCommandTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.commands.EventBeanCommand.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.eventBeanCommand = "" />
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
	<cffunction name="testBeanAutoPopulate" access="public" returntype="void" output="false"
		hint="Tests the event-bean autopopulate attribute.">

		<cfset var command = "" />
		<cfset var event = "" />
		<cfset var eventContext = getEventContext() />
		<cfset var user = "" />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(
			beanName="user", beanType="MachII.tests.dummy.User", beanFields="", ignoreFields="", 
			reinit=false, beanUtil=CreateObject("component", "MachII.util.BeanUtil").init(), autoPopulate=true) />
		<cfset command.setLog(getAppManager().getLogFactory().getLog("MachII.framework.commands.EventBeanCommand")) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		<cfset command.addFieldWithValue("birthdate", "${event.birthmonth}/${event.birthday}/${event.birthyear}") />
		
		<cfset event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset event.setArg("firstname", "Kurt") />
		<cfset event.setArg("lastname", "Wiersma") />
		<cfset event.setArg("birthMonth", 3) />
		<cfset event.setArg("birthday", 18) />
		<cfset event.setArg("birthyear", 1979) />
		<cfset event.setArg("address.address1", "1234 Main Street") />
		<cfset event.setArg("address.country.name", "United States") />
		<cfset event.setArg("address.country.code", "USA") />
		
		<cfset eventContext.setup(getAppManager(), event) />
		
		<cfset command.execute(event, eventContext) />
		
		<cfset user = event.getArg("user") />
		<cfset debug(user) />
		
		<cfset assertTrue(user.getFirstName() eq "Kurt", "user.getFirstName() should return 'Kurt'") />
		<cfset assertTrue(user.getAddress().getAddress1() eq "1234 Main Street", "address1 should be '1234 Main Street'") />
		<cfset assertTrue(user.getAddress().getCountry().getCode() eq "USA", "country.code should be 'USA'") />
		<cfset assertTrue(user.getBirthDate() eq "3/18/1979", "user.getBirthdate() should return '3/18/1979'") />
	</cffunction>

</cfcomponent>