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

Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="FileButtonTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for 'button' and 'file' custom tags.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<!--- This is a fake attributes scope --->
	<cfset variables.attributes = StructNew() />
	<cfset variables.included = false />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset var propertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var requestHandler = "" />
		<cfset var moduleManager = "" />
		<cfset var endpointManager = "" />

		<!--- Setup the AppManager with the required collaborators --->
		<cfset variables.appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset variables.appManager.setAppKey("dummy") />

		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset variables.appManager.setPropertyManager(propertyManager) />

		<!--- Insert properties if needed here --->
		<cfset propertyManager.setProperty("urlExcludeEventParameter", false) />
		<cfset propertyManager.setProperty("urlDelimiters", "?|&|=") />
		<cfset propertyManager.setProperty("redirectPersistScope", "application") />
		<cfset propertyManager.setProperty("maxEvents", 10) />
		<cfset propertyManager.setProperty("eventParameter", "event") />

		<!--- Setup the RequestManager --->
		<cfset requestManager =  CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		<cfset variables.appManager.setRequestManager(requestManager) />

		<!--- Setup the ModuleManager --->
		<cfset moduleManager =  CreateObject("component", "MachII.framework.ModuleManager").init(appManager, "", "") />
		<cfset variables.appManager.setModuleManager(moduleManager) />

		<!--- Setup the EndpointManager --->
		<cfset endpointManager =  CreateObject("component", "MachII.framework.EndpointManager").init(appManager, "", "") />
		<cfset variables.appManager.setEndpointManager(endpointManager) />

		<!--- Configure the managers --->
		<cfset propertyManager.configure() />
		<cfset requestManager.configure() />

		<!--- Setup a fake request --->
		<cfset request.event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset requestHandler = requestManager.getRequestHandler() />
		<!--- Setup the EventContext --->
		<cfset makePublic(requesthandler, "setEventQueue") />
		<cfset makePublic(requesthandler, "getEventQueue") />
		<cfset makePublic(requesthandler, "setEventContext") />
		<cfset requestHandler.setEventQueue(CreateObject("component", "MachII.util.SizedQueue").init(10)) />
		<cfset requestHandler.setEventContext(CreateObject("component", "MachII.framework.EventContext").init(requestHandler, requestHandler.getEventQueue())) />

		<!--- Set the EventContext into the request scope for backwards compatibility --->
		<cfset request.eventContext = requestHandler.getEventContext() />

		<cfset requestHandler.getEventContext().setup(appManager, request.event) />

		<!--- Include the tag library only once --->
		<cfif NOT variables.included>
			<cfimport prefix="form" taglib="/MachII/customtags/form" />
			<cfset variables.included = true />
		</cfif>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Reset the fake attributes struct --->
		<cfset variables.attributes = StructNew() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testButton" access="public" returntype="void" output="false"
		hint="Test basic 'button' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something">
					<form:button name="submit1"/>
					<form:button name="submit2" src="/temp.png"/>
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/input[@type="submit" and @id="submit1"]', xml) />
		<cfset node = assertXPath('/root/form/input[@type="image" and @src="/temp.png" and @id="submit2"]', xml) />
	</cffunction>

	<cffunction name="testFile" access="public" returntype="void" output="false"
		hint="Test basic 'file' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something">
					<form:file path="filePath" disabled />
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/input[@type="file" and @id="filePath" and @disabled="disabled"]', xml) />
	</cffunction>
	
</cfcomponent>