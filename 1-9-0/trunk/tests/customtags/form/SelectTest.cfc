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

Author: Peter J. Farrell(peter@mach-ii.com)
$Id$

Created version: 1.8.1
Updated version: 1.8.1

Notes:
--->
<cfcomponent
	displayname="SelectTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for 'select', 'option' and 'options' custom tags.">
	
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
		
		<!--- Configure the managers --->
		<cfset propertyManager.configure() />
		<cfset requestManager.configure() />
		
		<!--- Setup a fake request --->
		<cfset requestManager = requestManager.getRequestHandler() />
		<cfset request.event = CreateObject("component", "MachII.framework.Event").init() />
		<cfset requestManager.getEventContext().setup(appManager, request.event) />
		
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
	<cffunction name="testSelectWithLists" access="public" returntype="void" output="false"
		hint="Test basic 'select' tag.">
		
		<cfset var output = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		
		<!--- Add data to the the bean and set to the event so we can do binding --->		
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />
		
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor" items="Red,Green,Blue,Brown,Pink" />
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Red</option>', output), "I did not find that 'red' was the selected option.") />
		
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor">
					<form:options items="Red,Green,Blue,Brown,Pink" labels="Big Red,Giant Green,Beautiful Blue,Bad Brown,Precious Pink" />
				</form:select>
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />

		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor">
					<form:option value="Red" label="Big Red" />
					<form:option value="Green" label="Giant Green" />
					<form:option value="Blue" label="Beautiful Blue" />
					<form:option value="Brown" label="Bad Brown" />
					<form:option value="Pink" label="Precious Pink" />
				</form:select>
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />
	</cffunction>

	<cffunction name="testSelectWithStructs" access="public" returntype="void" output="false"
		hint="Test basic 'select' tag.">
		
		<cfset var output = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var colors = StructNew() />
		
		<!--- Build colors data --->
		<cfset colors.Red = "Big Red" />
		<cfset colors.Green = "Gian Green" />
		<cfset colors.Blue = "Beautiful Blue" />
		<cfset colors.Brown = "Bad Brown" />
		<cfset colors.Pink =  "Precious Pink" />
		
		<!--- Add data to the the bean and set to the event so we can do binding --->		
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />
		
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor" items="#colors#" />
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />
	</cffunction>

	<cffunction name="testSelectWithArrays" access="public" returntype="void" output="false"
		hint="Test basic 'select' tag.">
		
		<cfset var output = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var colors = ArrayNew(1) />
		
		<!--- Add data to the the bean and set to the event so we can do binding --->		
		<cfset bean.setFavoriteColor("Big Red") />
		<cfset event.setArg("user", bean) />
		
		<!--- Test with simple array --->
		<cfset colors[1] = "Big Red" />
		<cfset colors[2] = "Giant Green" />
		<cfset colors[3] = "Beautiful Blue" />
		<cfset colors[4] = "Bad Brown" />
		<cfset colors[5] = "Precious Pink" />
		
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor" items="#colors#" />
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_big_red" value="big red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />
		
		<!--- Test with array of structs --->
		<cfset colors[1] = StructNew() />
		<cfset colors[1].l = "Big Red" />
		<cfset colors[1].v = "red" />
		<cfset colors[2] = StructNew() />
		<cfset colors[2].l = "Giant Green" />
		<cfset colors[2].v = "green" />
		<cfset colors[3] = StructNew() />
		<cfset colors[3].l = "Beautiful Blue" />
		<cfset colors[3].v = "blue" />
		<cfset colors[4] = StructNew() />
		<cfset colors[4].l = "Bad Brown" />
		<cfset colors[4].v = "brown" />
		<cfset colors[5] = StructNew() />
		<cfset colors[5].l = "Precious Pink" />
		<cfset colors[5].v = "pink" />

		<cfset bean.setFavoriteColor("red") />
		
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor" items="#colors#" labelKey="l" valueKey="v" />
			</form:form>
		</cfsavecontent>
		
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />
	</cffunction>
	
	<cffunction name="testSelectWithQueries" access="public" returntype="void" output="false"
		hint="Test basic 'select' tag.">
		
		<cfset var output = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var colors = QueryNew("v,l") />
		
		<!--- Add data to the the bean and set to the event so we can do binding --->		
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />
		
		<!--- Test with simple array --->
		<cfset QueryAddRow(colors) />
		<cfset QuerySetCell(colors, "v", "red") />
		<cfset QuerySetCell(colors, "l", "Big Red") />
		<cfset QueryAddRow(colors) />
		<cfset QuerySetCell(colors, "v", "green") />
		<cfset QuerySetCell(colors, "l", "Giant Green") />
				
		<cfsavecontent variable="output">
			<form:form actionEvent="something" bind="${event.user}">
				<form:select path="favoriteColor" items="#colors#" labelCol="l" valueCol="v" />
			</form:form>
		</cfsavecontent>		
		
		<cfset debug(colors) />
		<cfset debug(output) />
		
		<cfset assertTrue(FindNoCase('<option id="favoriteColor_red" value="red" selected="selected">Big Red</option>', output), "I did not find that 'red' was the selected option.") />
	</cffunction>

</cfcomponent>