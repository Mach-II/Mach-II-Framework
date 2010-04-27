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
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="BeanUtilTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.BeanUtil.">

	<!---
	PROPERTIES
	--->
	<cfset variables.beanUtil = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<cfset variables.beanUtil = CreateObject("component", "MachII.util.BeanUtil").init() />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testCreateBean" access="public" returntype="void" output="false"
		hint="Tests creating a bean.">

		<cfset var bean = "" />
		<cfset var initArgs = StructNew() />

		<!--- Setup the initArgs --->
		<cfset initArgs.firstName = "Mach-II" />
		<cfset initArgs.lastName = "Framework" />

		<!--- Test wihtout initArgs --->
		<cfset bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />

		<!--- Test wihtout initArgs --->
		<cfset bean = variables.beanUtil.createBean("MachII.tests.dummy.User", initArgs) />
	</cffunction>

	<cffunction name="testSetBeanFields" access="public" returntype="void" output="false"
		hint="Tests seting bean fields.">

		<cfset var bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />
		<cfset var testData = StructNew() />

		<!--- Setup test data --->
		<cfset testData.firstName = "Mach-II" />
		<cfset testData.lastName = "Framework" />
		<cfset testData.dummy = false />

		<!--- Set only the firstName --->
		<cfset variables.beanUtil.setBeanFields(bean, "firstName", testData) />

		<!--- Assert that only firstName was populated --->
		<cfset assertEquals(bean.getFirstName(), "Mach-II", "The value from 'getFirstName()' is '#bean.getFirstName()#' which does not match expected 'Mach-II'.") />
		<cfset assertEquals(bean.getLastName(), "", "The value from 'getLastName()' is '#bean.getLastName()#' which does not match expected ''.") />
	</cffunction>

	<cffunction name="testSetBeanFieldsWithPrefix" access="public" returntype="void" output="false"
		hint="Tests seting bean fields.">

		<cfset var bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />
		<cfset var testData = StructNew() />

		<!--- Setup test data --->
		<cfset testData["test.firstName"] = "Mach-II" />
		<cfset testData["test.lastName"] = "Framework" />
		<cfset testData["test.dummy"] = false />

		<!--- Set only the firstName --->
		<cfset variables.beanUtil.setBeanFields(bean, "firstName", testData, "test") />

		<!--- Assert that only firstName was populated --->
		<cfset assertEquals(bean.getFirstName(), "Mach-II", "The value from 'getFirstName()' is '#bean.getFirstName()#' which does not match expected 'Mach-II'.") />
		<cfset assertEquals(bean.getLastName(), "", "The value from 'getLastName()' is '#bean.getLastName()#' which does not match expected ''.") />
	</cffunction>

	<cffunction name="testSetAutoBeanFieldsWithPrefix" access="public" returntype="void" output="false"
		hint="Tests seting bean fields automatically mapped from the bean accessors with a prefix.">

		<cfset var bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />
		<cfset var testData = StructNew() />

		<!--- Setup test data --->
		<cfset testData["test.firstName"] = "Mach-II" />
		<cfset testData["test.lastName"] = "Framework" />
		<cfset testData["test.dummy"] = false />

		<!--- Set only the firstName --->
		<cfset variables.beanUtil.setBeanAutoFields(bean, testData, "test") />

		<!--- Assert that both firstName and lastName was populated --->
		<cfset assertEquals(bean.getFirstName(), "Mach-II", "The value from 'getFirstName()' is '#bean.getFirstName()#' which does not match expected 'Mach-II'.") />
		<cfset assertEquals(bean.getLastName(), "Framework", "The value from 'getLastName()' is '#bean.getLastName()#' which does not match expected 'Framework'.") />
	</cffunction>

	<cffunction name="testSetGetBeanField" access="public" returntype="void" output="false"
		hint="Tests setting and getting bean fields.">

		<cfset var bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />

		<!--- Set a bean field --->
		<cfset variables.beanUtil.setBeanField(bean, "firstName", "Mach-II") />

		<!--- Assert that the set and get works --->
		<cfset assertEquals(variables.beanUtil.getBeanField(bean, "firstName"), "Mach-II") />
	</cffunction>

	<cffunction name="testDescribeBean" access="public" returntype="void" output="false"
		hint="Tests describeBean() mapping util.">

		<cfset var bean = variables.beanUtil.createBean("MachII.tests.dummy.User") />
		<cfset var map = StructNew() />

		<!--- Populate the bean with some dummy datat --->
		<cfset bean.setFirstName("Mach-II") />
		<cfset bean.setLastName("Framework") />

		<!--- Get the description of the bean with the current values --->
		<cfset map = variables.beanUtil.describeBean(bean) />

		<!--- Assert that the map is correct --->
		<cfset assertEquals(StructCount(map), 9) /><!--- 8 getters and 1 getMemento() --->
		<cfset assertEquals(map.firstName, "Mach-II") />
		<cfset assertEquals(map.lastName, "Framework") />
	</cffunction>

</cfcomponent>