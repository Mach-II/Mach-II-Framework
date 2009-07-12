<!---
License:
Copyright 2009 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

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
		<cfset bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean") />

		<!--- Test wihtout initArgs --->
		<cfset bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean", initArgs) />
	</cffunction>
	
	<cffunction name="testSetBeanFields" access="public" returntype="void" output="false"
		hint="Tests seting bean fields.">
	
		<cfset var bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean") />
		<cfset var testData = StructNew() />
		
		<!--- Setup test data --->
		<cfset testData.firstName = "Mach-II" />
		<cfset testData.lastName = "Framework" />
		<cfset testData.dummy = false />

		<!--- Set only the firstName --->
		<cfset variables.beanUtil.setBeanFields(bean, "firstName", testData) />
		
		<!--- Assert that only firstName was populated --->
		<cfset assertSame(bean.getFirstName(), "Mach-II", "The value from 'getFirstName()' is '#bean.getFirstName()#' which does not match expected 'Mach-II'.") />
		<cfset assertSame(bean.getLastName(), "", "The value from 'getLastName()' is '#bean.getLastName()#' which does not match expected ''.") />
	</cffunction>

	<cffunction name="testSetAutoBeanFields" access="public" returntype="void" output="false"
		hint="Tests seting bean fields automatically mapped from the bean accessors.">
	
		<cfset var bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean") />
		<cfset var testData = StructNew() />
		
		<!--- Setup test data --->
		<cfset testData.firstName = "Mach-II" />
		<cfset testData.lastName = "Framework" />
		<cfset testData.dummy = false />

		<!--- Set only the firstName --->
		<cfset variables.beanUtil.setBeanAutoFields(bean, testData) />
		
		<!--- Assert that both firstName and lastName was populated --->
		<cfset assertSame(bean.getFirstName(), "Mach-II", "The value from 'getFirstName()' is '#bean.getFirstName()#' which does not match expected 'Mach-II'.") />
		<cfset assertSame(bean.getLastName(), "Framework", "The value from 'getLastName()' is '#bean.getLastName()#' which does not match expected 'Framework'.") />
	</cffunction>

	<cffunction name="testSetGetBeanField" access="public" returntype="void" output="false"
		hint="Tests setting and getting bean fields.">
	
		<cfset var bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean") />
		
		<!--- Set a bean field --->
		<cfset variables.beanUtil.setBeanField(bean, "firstName", "Mach-II") />
		
		<!--- Assert that the set and get works --->
		<cfset AssertSame(variables.beanUtil.getBeanField(bean, "firstName"), "Mach-II") />
	</cffunction>

	<cffunction name="testDescribeBean" access="public" returntype="void" output="false"
		hint="Tests describeBean() mapping util.">
	
		<cfset var bean = variables.beanUtil.createBean("MachII.tests.util.BeanUtilTestBean") />
		<cfset var map = StructNew() />
		
		<!--- Populate the bean with some dummy datat --->
		<cfset bean.setFirstName("Mach-II") />
		<cfset bean.setLastName("Framework") />
		
		<!--- Get the description of the bean with the current values --->
		<cfset map = variables.beanUtil.describeBean(bean) />
		
		<!--- Assert that the map is correct --->
		<cfset assertEquals(StructCount(map), 2) />
		<cfset assertSame(map.firstName, "Mach-II") />
		<cfset assertSame(map.lastName, "Framework") />
	</cffunction>

</cfcomponent>