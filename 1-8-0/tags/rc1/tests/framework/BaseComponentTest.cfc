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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="BaseComponentTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.BaseComponent.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.baseComponent = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
			
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		
		<!--- Setup the AppManager with the required collaborators --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey("dummy") />
		
		<!--- Setup the PropertyManager with the required collaboration data --->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
		<cfset propertyManager.setProperty("test1", "value1") />
		<cfset propertyManager.setProperty("test2", "value2") />
		<cfset appManager.setPropertyManager(propertyManager) />
					
		<cfset variables.baseComponent = CreateObject("component", "MachII.framework.BaseComponent") />
		<cfset variables.baseComponent.init(appManager) />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testParameters" access="public" returntype="void" output="false"
		hint="Tests setParameters(), getParameters(), getParameter(), isParameterDefined() and getParameterNames(). Behind the scenes this test exercises bindValue() and setParameter().">
		
		<cfset var inputParameters = StructNew() />
		<cfset var outputParameters = StructNew() />
		
		<!--- Test for when whe scope prefix of "properties." is not required --->
		<cfset inputParameters.test1 = "${test1}" />
		<!--- Test for the "properites." scope prefix--->
		<cfset inputParameters.test2 = "${properties.test2}" />
		<!--- Test for straight up --->
		<cfset inputParameters.test3 = "value3" />
		
		<!--- Set / get the properties --->
		<cfset variables.baseComponent.setParameters(inputParameters) />
		<!--- Getting parameters will case the bindValue() to be called for each parameter key --->
		<cfset outputParameters = variables.baseComponent.getParameters() />
		
		<!--- Perform assertions from output of getParameters() `--->
		<cfset assertEquals(outputParameters.test1, "value1") />
		<cfset assertEquals(outputParameters.test2, "value2") />
		<cfset assertEquals(outputParameters.test3, "value3") />
		
		<!--- Perform assertions from getParameter() calls --->
		<cfset assertEquals(variables.baseComponent.getParameter("test1"), "value1") />
		<cfset assertEquals(variables.baseComponent.getParameter("test2"), "value2") />
		<cfset assertEquals(variables.baseComponent.getParameter("test3"), "value3") />
		
		<!--- Test isParameterDefined() --->
		<cfset assertTrue(variables.baseComponent.isParameterDefined("test1")) />
		<cfset assertTrue(NOT variables.baseComponent.isParameterDefined("doesNotExist")) />
		
		<!--- Test isParameterNames() --->
		<cfset assertTrue(ListLen(variables.baseComponent.getParameterNames()) EQ 3) />
	</cffunction>
	
</cfcomponent>