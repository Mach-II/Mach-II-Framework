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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="XmlValidationExceptionTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.XmlValidationException.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.xmlValidationException = "" />
	<cfset variables.testData = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		
		<cfsavecontent variable="variables.testData">{"errors":["[Error] :3:30: cvc-datatype-valid.1.2.1: 'aa' is not a valid value for 'integer'. ","[Error] :3:30: cvc-attribute.3: The value 'aa' of attribute 'id' on element 'assessmentBattery' is not valid with respect to its type, 'unsignedInt'. ","[Error] :10:20: cvc-pattern-valid: Value '12\/aa' is not facet-valid with respect to pattern '\\d{2}\/\\d{2}' for type 'null'. ","[Error] :10:20: cvc-type.3.1.3: The value '12\/aa' of element 'dob' is not valid. "],"status":false,"warnings":[],"fatalerrors":[]}</cfsavecontent>
		
		<cfset variables.testData = DeserializeJson(variables.testData) />
			
		<cfset variables.xmlValidationException = CreateObject("component", "MachII.util.XmlValidationException").init() />
		<cfset variables.xmlValidationException.wrapValidationResult(variables.testData, "test.xml", "test.dtd") />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testGetFormattedMessage" access="public" returntype="void" output="false"
		hint="Test getFormattedMessage() of the XmlValidationException.">
		
		<cfset var rawMessages = "" />
		<cfset var formattedMessage = "" />
		<cfset var testMessage = "" />

		<cfset debug(testData) />
		
		<!--- Test getting most severe --->
		<cfset formattedMessage = variables.xmlValidationException.getFormattedMessage() />
		<cfset testMessage = "Error validating XML file: test.xml: Line 3, Column 30: cvc-datatype-valid.1.2.1 - 'aa' is not a valid value for 'integer'." />

		<cfset debug(formattedMessage) />
		<cfset debug(testMessage) />
		<cfset assertEquals(0, CompareNoCase(testMessage, formattedMessage), "1") />

		<!--- Test getting by passed in value --->
		<cfset rawMessages = variables.xmlValidationException.getErrors() />
		<cfset formattedMessage = variables.xmlValidationException.getFormattedMessage(rawMessages[4]) />
		<cfset testMessage = "Error validating XML file: test.xml: Line 10, Column 20: cvc-type.3.1.3 - The value '12/aa' of element 'dob' is not valid." />

		<cfset debug(formattedMessage) />
		<cfset debug(testMessage) />
		<cfset assertEquals(0, CompareNoCase(testMessage, formattedMessage), "2") />
	</cffunction>

	<cffunction name="testGetPartedMessage" access="public" returntype="void" output="false"
		hint="Test getPartedMessage() of the XmlValidationException.">
		
		<cfset var partedMessage = "" />

		<cfset debug(testData) />
		
		<!--- Test getting most severe --->
		<cfset partedMessage = variables.xmlValidationException.getPartedMessage() />
		<cfset debug(partedMessage) />

		<!--- Test getting by passed in value --->
		<cfset assertEquals(3, partedMessage.line) />
		<cfset assertEquals(30, partedMessage.column) />
		<cfset assertEquals("'aa' is not a valid value for 'integer'.", partedMessage.detail) />
	</cffunction>

</cfcomponent>