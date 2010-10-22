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
	displayname="RadioTest"
	extends="FormTestCaseBase"
	hint="Test cases for 'radio' and 'radiogroup' custom tags.">

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">

		<cfset super.setup() />

		<!--- Include the tag library only once and it cannot be done in the inherited CFC --->
		<cfif NOT variables.included>
			<cfimport prefix="form" taglib="/MachII/customtags/form" />
			<cfset variables.included = true />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testRadios" access="public" returntype="void" output="false"
		hint="Test basic 'radio' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />

		<!--- Add data to the the bean and set to the event so we can do binding --->
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:radio path="favoriteColor" value="Red" />
					<form:radio path="favoriteColor" value="Green" />
					<form:radio path="favoriteColor" value="Bad Brown" />
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/input[@type="radio" and @value="Red" and @id="favoriteColor_Red" and @checked="checked"]', xml) />
		<cfset node = assertXPath('/root/form/input[@type="radio" and @value="Green" and @id="favoriteColor_Green"]', xml) />
		<cfset node = assertXPath('/root/form/input[@type="radio" and @value="Bad Brown" and @id="favoriteColor_Bad_Brown"]', xml) />
	</cffunction>

	<cffunction name="testRadiogroupWithLists" access="public" returntype="void" output="false"
		hint="Test 'radiogroup' tag with lists.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />

		<!--- Add data to the the bean and set to the event so we can do binding --->
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:radiogroup path="favoriteColor" items="Red,Green,Blue,Brown,Pink">
						<label for="${output.id}"><span>${output.label}</span> ${output.radio}</label>
					</form:radiogroup>
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Red" and @id="favoriteColor_Red" and @checked="checked"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Green" and @id="favoriteColor_Green"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Brown" and @id="favoriteColor_Brown"]', xml) />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Red"]/span', xml, "Red") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Green"]/span', xml, "Green") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Brown"]/span', xml, "Brown") />
	</cffunction>	

	<cffunction name="testRadiogroupWithStructs" access="public" returntype="void" output="false"
		hint="Test basic 'radiogroup' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />
		<cfset var bean = CreateObject("component", "MachII.tests.dummy.User").init() />
		<cfset var event = variables.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var colors = StructNew() />

		<!--- Build colors data --->
		<cfset colors.Red = "Big Red" />
		<cfset colors.Green = "Giant Green" />
		<cfset colors.Blue = "Beautiful Blue" />
		<cfset colors.Brown = "Bad Brown" />
		<cfset colors.Pink =  "Precious Pink" />

		<!--- Add data to the the bean and set to the event so we can do binding --->
		<cfset bean.setFavoriteColor("red") />
		<cfset event.setArg("user", bean) />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:radiogroup path="favoriteColor" items="#colors#">
						<label for="${output.id}"><span>${output.label}</span> ${output.radio}</label>
					</form:radiogroup>
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Red" and @id="favoriteColor_Red" and @checked="checked"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Green" and @id="favoriteColor_Green"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Brown" and @id="favoriteColor_Brown"]', xml) />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Red"]/span', xml, "Big Red") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Green"]/span', xml, "Giant Green") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Brown"]/span', xml, "Bad Brown") />
	</cffunction>

	<cffunction name="testRadiogroupWithArrays" access="public" returntype="void" output="false"
		hint="Test basic 'radiogroup' tag.">

		<cfset var output = "" />
		<cfset var xml = "" />
		<cfset var node = "" />
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

		<!--- Add data to the the bean and set to the event so we can do binding --->
		<cfset bean.setFavoriteColor("Big Red") />
		<cfset event.setArg("user", bean) />

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:radiogroup path="favoriteColor" items="#colors#">
						<label for="${output.id}"><span>${output.label}</span> ${output.radio}</label>
					</form:radiogroup>
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Big Red" and @id="favoriteColor_Big_Red" and @checked="checked"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Giant Green" and @id="favoriteColor_Giant_Green"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="Bad Brown" and @id="favoriteColor_Bad_Brown"]', xml) />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Big_Red"]/span', xml, "Big Red") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Giant_Green"]/span', xml, "Giant Green") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_Bad_Brown"]/span', xml, "Bad Brown") />
		
		<cfset bean.setFavoriteColor("red") />
		
		<!--- Test with array of structs --->
		<cfset colors = ArrayNew(1) />
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

		<cfsavecontent variable="output">
			<root>
				<form:form actionEvent="something" bind="${event.user}">
					<form:radiogroup path="favoriteColor" items="#colors#" labelKey="l" valueKey="v">
						<label for="${output.id}"><span>${output.label}</span> ${output.radio}</label>
					</form:radiogroup>
				</form:form>
			</root>
		</cfsavecontent>

		<cfset xml = XmlParse(output) />
		<cfset debug(node) />
		<cfset debug(output) />

		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="red" and @id="favoriteColor_red" and @checked="checked"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="green" and @id="favoriteColor_green"]', xml) />
		<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="brown" and @id="favoriteColor_brown"]', xml) />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_red"]/span', xml, "Big Red") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_green"]/span', xml, "Giant Green") />
		<cfset node = assertXPath('/root/form/label[@for="favoriteColor_brown"]/span', xml, "Bad Brown") />	</cffunction>

<cffunction name="testRadiogroupWithQueries" access="public" returntype="void" output="false"
	hint="Test basic 'radiogroup' tag.">

	<cfset var output = "" />
	<cfset var xml = "" />
	<cfset var node = "" />
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
	<cfset QueryAddRow(colors) />
	<cfset QuerySetCell(colors, "v", "brown") />
	<cfset QuerySetCell(colors, "l", "Bad Brown") />

	<cfsavecontent variable="output">
		<root>
			<form:form actionEvent="something" bind="${event.user}">
				<form:radiogroup path="favoriteColor" items="#colors#" labelCol="l" valueCol="v">
					<label for="${output.id}"><span>${output.label}</span> ${output.radio}</label>
				</form:radiogroup>
			</form:form>
		</root>
	</cfsavecontent>

	<cfset xml = XmlParse(output) />
	<cfset debug(node) />
	<cfset debug(output) />

	<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="red" and @id="favoriteColor_red" and @checked="checked"]', xml) />
	<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="green" and @id="favoriteColor_green"]', xml) />
	<cfset node = assertXPath('/root/form/label/input[@type="radio" and @value="brown" and @id="favoriteColor_brown"]', xml) />
	<cfset node = assertXPath('/root/form/label[@for="favoriteColor_red"]/span', xml, "Big Red") />
	<cfset node = assertXPath('/root/form/label[@for="favoriteColor_green"]/span', xml, "Giant Green") />
	<cfset node = assertXPath('/root/form/label[@for="favoriteColor_brown"]/span', xml, "Bad Brown") />
</cffunction>

</cfcomponent>