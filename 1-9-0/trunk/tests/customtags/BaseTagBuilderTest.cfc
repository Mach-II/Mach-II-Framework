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
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="BaseTagBuilderTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for /MachII/customtags/baseTagBuilder.cfm.">

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
		<cfset var moduleManager = "" />

		<!--- Setup the AppManager with the required collaborators --->
		<cfset variables.appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset variables.appManager.setAppKey("dummy") />

		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset variables.appManager.setPropertyManager(propertyManager) />

		<!--- Setup the RequestManager --->
		<cfset requestManager =  CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		<cfset variables.appManager.setRequestManager(requestManager) />

		<!--- Setup the ModuleManager --->
		<cfset moduleManager =  CreateObject("component", "MachII.framework.ModuleManager").init(appManager, "", "") />
		<cfset variables.appManager.setModuleManager(moduleManager) />

		<!--- Configure the managers --->
		<cfset propertyManager.configure() />
		<cfset requestManager.configure() />

		<!--- Setup a fake request --->
		<cfset requestManager = requestManager.getRequestHandler() />
		<cfset requestManager.getEventContext().setup(appManager) />

		<!--- Include the baseTagBuilder.cfm only once --->
		<cfif NOT variables.included>
			<cfinclude template="/MachII/customtags/baseTagBuilder.cfm" />
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
	<cffunction name="testEnsureByName" access="public" returntype="void" output="false"
		hint="Test 'ensureByName' method.">

		<cfset attributes.test = "test" />

		<cftry>
			<cfset ensureByName('test') />
			<cfcatch>
				<cfset fail("ensureByName() failed.") />
			</cfcatch>
		</cftry>

		<cftry>
			<cfset ensureByName('iWillFail') />

			<!--- If we have gotten here, the function found a key it should not so fail --->
			<cfset fail("ensureByName() failed by saying that a key existed.") />

			<cfcatch type="MachII.customtags.unknown.unknown.noAttribute">
				<!--- Do nothing since an exception is expected --->
			</cfcatch>
			<cfcatch type="any">
				<cfset fail("ensureByName() failed with an unkown exception") />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="testEnsureOneByNameList" access="public" returntype="void" output="false"
		hint="Test 'ensureOneByNameList' method.">

		<cfset attributes["1"] = "test" />
		<cfset attributes["2"] = "test" />
		<cfset attributes["3"] = "test" />

		<cftry>
			<cfset ensureOneByNameList('1,2,3,4') />
			<cfcatch>
				<cfset fail("ensureByName() failed.") />
			</cfcatch>
		</cftry>

		<cftry>
			<cfset ensureOneByNameList('4,5,6') />

			<!--- If we have gotten here, the function found a key it should not so fail --->
			<cfset fail("ensureOneByNameList() failed by saying that a key existed.") />

			<cfcatch type="MachII.customtags.unknown.unknown.noAttribute">
				<!--- Do nothing since an exception is expected --->
			</cfcatch>
			<cfcatch type="any">
				<cfset fail("ensureOneByNameList() failed with an unkown exception", cfcatch) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="testTagAttributeMethods" access="public" returntype="void" output="false"
		hint="Test 'setAttribute' and 'setAttributes' methods.">

		<cfset var tempCollection = StructNew() />
		<cfset var concreteAttributeCollection = "" />

		<!--- Set data --->
		<cfset tempCollection.a = "1" />
		<cfset tempCollection.b = "2" />
		<cfset tempCollection.c = "3" />

		<cfset setAttribute("test", true) />
		<cfset setAttributes(tempCollection) />
		<cfset setAttributeIfDefined("test", false) />

		<!--- Debugging and synchronization --->
		<cfset concreteAttributeCollection = getAttributeCollection() />
		<cfset debug(concreteAttributeCollection) />

		<!--- Run assertions --->
		<cfset assertTrue(concreteAttributeCollection.test, "Wrong value.") />
		<cfset assertTrue(concreteAttributeCollection.a EQ 1, "Wrong value.") />
	</cffunction>

	<cffunction name="testHelperPropertyMethods" access="public" returntype="void" output="false"
		hint="Test 'getProperty' and 'setProperty' methods.">
		<cfset setProperty("monkeys", "eat bananas") />
		<cfset assertEquals(getProperty("monkeys"), "eat bananas") />
		<cfset assertEquals(getProperty("rhinos", "eat people"), "eat people") />
	</cffunction>

	<cffunction name="testNormalizeStructByNamespace" access="public" returntype="void" output="false"
		hint="Test 'normalizeStructByNamespace' method.">

		<cfset var temp = StructNew() />
		<cfset var normalizedStruct = "" />

		<cfset temp["x:a"] = 1 />
		<cfset temp["x:b"] = 2 />
		<cfset temp["x:c"] = 3 />
		<cfset temp["x:d"] = 4 />

		<cfset normalizedStruct = normalizeStructByNamespace("x", temp) />
		<cfset debug(normalizedStruct) />

		<cfset assertTrue(StructKeyExists(normalizedStruct, "a")) />
		<cfset assertTrue(StructKeyExists(normalizedStruct, "b")) />
		<cfset assertTrue(StructKeyExists(normalizedStruct, "c")) />
		<cfset assertTrue(StructKeyExists(normalizedStruct, "d")) />
	</cffunction>

	<cffunction name="testCreateCleanId" access="public" returntype="void" output="false"
		hint="Test 'createCleanId' method.">
		<cfset assertEquals(createCleanId("Valentine's Day"), "Valentines_Day") />
		<cfset assertEquals(createCleanId("C.J. Cregg's Birthday"), "CJ_Creggs_Birthday") />
		<cfset assertEquals(createCleanId("C. Farrell & Sons"), "C_Farrell__Sons") />
	</cffunction>

</cfcomponent>