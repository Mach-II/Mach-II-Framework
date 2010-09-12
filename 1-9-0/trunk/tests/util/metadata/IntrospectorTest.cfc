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

Author: Doug Smith (doug.smith@daveramsey.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="IntrospectorTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.metadata.Introspector.">

	<!---
	PROPERTIES
	--->
	<cfset variables.introspector = "" />
	<cfset variables.dummy = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
		<cfset variables.dummy = CreateObject("component", "MachII.tests.dummy.HasAnnotations") />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testFindFunctionsWithAnnotationsNoTree" access="public" returntype="void" output="false"
		hint="Tests retrieving function definition for the immediate object without walking the object hierarchy.">

		<cfset var definition = variables.introspector.findFunctionsWithAnnotations(object:variables.dummy, namespace:"REST") />

		<cfset debug(definition) />

		<cfset assertEquals(1, ArrayLen(definition), "There should only be one item in the array when we don't walk the object hierarchy.") />
		<cfset assertEquals(1, ArrayLen(definition[1].functions), "There should only be one function that includes REST annotations.") />
		<cfset assertEquals('/test/me', definition[1].functions[1]["REST:URI"]) />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />
	</cffunction>

	<cffunction name="testFindFunctionsWithAnnotationsWalkTree" access="public" returntype="void" output="false"
		hint="Tests retrieving function definition for the immediate object without walking the object hierarchy.">

		<cfset var definition = variables.introspector.findFunctionsWithAnnotations(object:variables.dummy, namespace:"REST", walkTree:true) />

		<cfset debug(definition) />

		<cfset assertEquals(3, ArrayLen(definition), "There should be three items in the array when we walk the object hierarchy.") />
		<cfset assertEquals(1, ArrayLen(definition[2].functions), "There should only be one function that includes REST annotations.") />
		<cfset assertEquals('/parent/go', definition[2].functions[1]["REST:URI"]) />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />
	</cffunction>

	<cffunction name="testFindFunctionsWithAnnotationsEmpty" access="public" returntype="void" output="false"
		hint="Tests retrieving function definition for the immediate object without walking the object hierarchy.">

		<cfset var testObj = CreateObject("component", "MachII.tests.dummy.DummyListener") />
		<cfset var definition = variables.introspector.findFunctionsWithAnnotations(object:testObj, namespace:"REST", walkTree:true) />

		<cfset debug(definition) />

		<cfset assertEquals(0, ArrayLen(definition), "Shouldn't be any annotations in this object.") />
	</cffunction>

	<cffunction name="testGetFunctionDefinitionsNoTree" access="public" returntype="void" output="false"
		hint="Tests retrieving function definition for the immediate object without walking the object hierarchy.">

		<cfset var definition = variables.introspector.getFunctionDefinitions(variables.dummy) />

		<cfset debug(definition) />

		<cfset assertEquals(1, ArrayLen(definition), "There should only be one item in the array when we don't walk the object hierarchy.") />
		<cfset assertEquals(2, ArrayLen(definition[1].functions), "There should be two functions in the first component definition.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />
	</cffunction>

	<cffunction name="testGetFunctionDefinitionsWalkTree" access="public" returntype="void" output="false"
		hint="Tests retrieving function definition for the whole object hierarchy.">

		<cfset var definition = variables.introspector.getFunctionDefinitions(object:variables.dummy, walkTree:true) />

		<cfset debug(definition) />

		<cfset assertEquals(3, ArrayLen(definition), "There should be three items in the array when we walk the object hierarchy.") />
		<cfset assertEquals(2, ArrayLen(definition[2].functions), "There should be two functions in the parent component definition.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />

		<!--- Test stopping at first superclass - same results currently since there are no functions in the Component parent class. --->
		<cfset definition = variables.introspector.getFunctionDefinitions(object:variables.dummy, walkTree:true, walkTreeStopClass:"MachII.tests.dummy.HasAnnotationsStopBase") />
		<cfset assertEquals(2, ArrayLen(definition), "There should be two items in the array when we walk the object hierarchy.") />
		<cfset assertEquals(2, ArrayLen(definition[2].functions), "There should be two functions in the parent component definition.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />
	</cffunction>

	<cffunction name="testGetComponentDefinitionNoTree" access="public" returntype="void" output="false"
		hint="Tests retrieving component definition for the immediate object without walking the object hierarchy.">

		<cfset var definition = variables.introspector.getComponentDefinition(dummy) />

		<cfset debug(definition) />

		<cfset assertEquals(1, ArrayLen(definition), "There should only be one item in the array when we don't walk the object hierarchy.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotations", definition[1].component) />
	</cffunction>

	<cffunction name="testGetComponentDefinitionWalkTree" access="public" returntype="void" output="false"
		hint="Tests retrieving component definition for the whole object hierarchy.">

		<cfset var definition = variables.introspector.getComponentDefinition(object:variables.dummy, walkTree:true) />

		<cfset debug(definition) />

		<!--- Test whole tree --->
		<cfset assertEquals(4, ArrayLen(definition), "There should be four items in the array when we walk the whole object hierarchy.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotationsParent", definition[2].component) />

		<!--- Test stopping at first superclass --->
		<cfset definition = variables.introspector.getComponentDefinition(object:variables.dummy, walkTree:true, walkTreeStopClass:"MachII.tests.dummy.HasAnnotationsStopBase") />
		<cfset assertEquals(2, ArrayLen(definition), "There should be two items in the array when we stop at the first parent.") />
		<cfset assertEquals("MachII.tests.dummy.HasAnnotationsParent", definition[2].component) />
	</cffunction>
	
	<cffunction name="testIsObjectInstanceOf" access="public" returntype="void" output="false"
		hint="Test isObjectInstanceOf method.">
		
		<cfset assertTrue(variables.introspector.isObjectInstanceOf(variables.dummy, "MachII.tests.dummy.HasAnnotations")) />
	</cffunction>

</cfcomponent>