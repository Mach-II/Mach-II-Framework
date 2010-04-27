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
	<cfset variables.CHARACTER = CreateObject("java", "java.lang.Character") />
	
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
			<cfset doThrow(arguments.message, arguments.detail) />
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
			<cfset doThrow(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="hasText" access="public" returntype="boolean" output="false"
		hint="Assert that the given string has valid text content; it must not be a zero length string and must contain at least one non-whitespace character.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check if there at least one non-whitespace character." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this text argument must contain valid text content."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
		
		<cfif NOT checkValidTextContent(arguments.text)>
			<cfset doThrow(arguments.message, arguments.detail) />
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
			<cfset doThrow(arguments.message, arguments.detail) />
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
		
		<cfif NOT arguments.expression>
			<cfset doThrow(arguments.message, arguments.detail) />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="notEmpty" access="public" returntype="boolean" output="false"
		hint="Assert that the passed query, struct or array is not empty.">
		<cfargument name="object" type="any" required="true"
			hint="The object (query, struct or array) to check if not empty." />
		<cfargument name="message" type="string" required="false"
			default="[Assertion failed] - this object argument cannot be an empty query, struct or array."
			hint="The message to throw if the assertion fails." />
		<cfargument name="detail" type="string" required="false" default=""
			hint="The detail to throw if the assertion fails." />
				
		<cfif IsArray(arguments.object)>
			<cfif NOT ArrayLen(arguments.object)>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this array must not be empty; it must contain at least one element." />
				</cfif>
				
				<cfset doThrow(arguments.message, arguments.detail) />
			</cfif>
		<cfelseif IsStruct(arguments.object)>
			<cfif NOT StructCount(arguments.object)>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this struct must not be empty; it must contain at least one key." />
				</cfif>
				
				<cfset doThrow(arguments.message, arguments.detail) />
			</cfif>
		<cfelseif IsQuery(arguments.object)>
			<cfif NOT arguments.object.recordcount>
				<cfif NOT StructKeyExists(arguments, "message")>
					<cfset arguments.message = "[Assertion failed] - this query must not be empty; it must contain at least one row." />
				</cfif>
				
				<cfset doThrow(arguments.message, arguments.detail) />
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
	<cffunction name="doThrow" access="private" returntype="void" output="false"
		hint="Throws an exception if an assertion fails.">
		<cfargument name="message" type="string" required="true"
			hint="Message to use in the thrown exception." />
		<cfargument name="detail" type="string" required="true"
			hint="Detail to use in the thrown exception" />
		
		<cfthrow type="MachII.util.IllegalArgument"
			message="#arguments.message#"
			detail="#arguments.detail#" />
	</cffunction>
	
	<cffunction name="checkValidTextContent" access="private" returntype="boolean" output="false"
		hint="Checks if valid text content; it must not be a zero length string and must contain at least one non-whitespace character.">
		<cfargument name="text" type="string" required="true"
			hint="The text to check the length." />
		
		<cfset var textCharArray =  "" />
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
			<cfif NOT variables.CHARACTER.isWhitespace(textCharArray[i])>
				<cfreturn true />	
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

</cfcomponent>