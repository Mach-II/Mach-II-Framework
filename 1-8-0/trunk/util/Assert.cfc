<!---
License:
Copyright 2008 GreatBizTools, LLC

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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Loosely based off the same class from the Spring Framework 
(http://www.springframework.org)

All assertions must return 'true' because returning is like returning
null and can cause null pointer exceptions when assertions are used in
complex conditionals.

Example of null pointer if 'true' is not returned:
<cfif isParameterDefined("timespan")
	AND getAssert().isTrue(getParameter("timespan") EQ "forever" OR ListLen(getParameter("timespan")) EQ 4
		, "Invalid timespan of '#getParameter("timespan")#'."
		, "Timespan must be set to 'forever' or a list of 4 numbers (days, hours, minutes, seconds).")>
	<cfset setTimespanString(getParameter("timespan")) />
</cfif>

The second conditional in the state returns as null and thus the exception.
--->
<cfcomponent 
	displayname="Assert"
	output="false"
	hint="Provides assertion utility methods to aid in the validation of arguments.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Assert" output="false"
		hint="Initializes the utility.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="doesNotContain" access="public" returntype="boolean" output="false"
		hint="Assert that the given text does not contain the given substring (case-senstive).">
		<cfargument name="text" type="string" required="true"
			hint="The text to check the substring against." />
		<cfargument name="substring" type="string" required="true"
			hint="The substring to find within the text." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this text argument must not contain the substring '#arguments.substring#'."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
				
		<cfif FindNoCase(arguments.substring, arguments.text)>
			<cfset throw(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>

	<cffunction name="hasLength" access="public" returntype="boolean" output="false"
		hint="Assert that the given text is not empty.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check the length." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this text argument must have length; it cannot be empty."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
				
		<cfif NOT Len(arguments.text)>
			<cfset throw(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="hasText" access="public" returntype="boolean" output="false"
		hint="Assert that the given string has valid text content; it must not be a zero length string and must contain at least one non-whitespace character.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check the length." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this text argument must contain valid text content."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
		
		<cfif NOT checkValidTextContent(arguments.text)>
			<cfset throw(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="isNumber" access="public" returntype="boolean" output="false"
		hint="Assert that the given text is a number.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check if number." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this text argument must be numeric."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
		
		<cfif NOT IsNumeric(arguments.text)>
			<cfset throw(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="isTrue" access="public" returntype="boolean" output="false"
		hint="Assert that the given expression is true.">
		<cfargument name="expression" type="boolean" required="true"
			hint="The expression to check if not true." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this expression argument must be true."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
		
		<cfset request.temp = arguments />
		
		<cfif NOT arguments.expression>
			<cfset throw(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="notEmpty" access="public" returntype="boolean" output="false"
		hint="Assert that the given expression is true.">
		<cfargument name="object" type="any" required="true"
			hint="The object (query, struct or array) to check if not empty." />
		<cfargument name="message" type="string" required="false"
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
				
		<cfif IsArray(arguments.object)>
			<cfif NOT ArrayLen(arguments.object)>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this array must not be empty; it must contain at least one element." />
				</cfif>
				
				<cfset throw(arguments.message, arguments.detail) />
			</cfif>
		<cfelseif IsStruct(arguments.object)>
			<cfif NOT StructCount(arguments.object)>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this struct must not be empty; it must contain at least one key." />
				</cfif>
				
				<cfset throw(arguments.message, arguments.detail) />
			</cfif>
		<cfelseif IsQuery(arguments.object)>
			<cfif NOT arguments.object.recordcount>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this query must not be empty; it must contain at least one row." />
				</cfif>
				
				<cfset throw(arguments.message, arguments.detail) />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.util.IllegalDatatype"
				message="The passed argument is not of datatype 'struct', 'array' or 'query' and therefore an assertion cannot be performed." />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="throw" access="private" returntype="void" output="false"
		hint="Throws an exception if an assertion fails.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="detail" type="string" required="true" />
		
		<cfthrow type="MachII.util.IllegalArgument"
			message="#arguments.message#"
			detail="#arguments.detail#" />
	</cffunction>
	
	<cffunction name="checkValidTextContent" access="private" returntype="boolean" output="false"
		hint="Checks if valid text content; it must not be a zero length string and must contain at least one non-whitespace character.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check the length." />
		
		<cfset var textCharArray =  "" />
		<cfset var char = CreateObject("java", "java.lang.Character") />
		<cfset var i = 0 />
		
		<!--- Check for length --->
		<cfif NOT Len(arguments.text)>
			<cfreturn false />
		</cfif>
		
		<!--- Length of input text needs to be checked first or a null pointer will occur --->
		<cfset textCharArray = arguments.text.toCharArray() />
		
		<!---
		Check for at least one non-whitespace character 
		and short-circuit to true if a non-whitespace character is found
		--->
		<cfloop from="1" to="#ArrayLen(textCharArray)#" index="i">
			<cfif NOT char.isWhitespace(textCharArray[i])>
				<cfreturn true />	
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

</cfcomponent>