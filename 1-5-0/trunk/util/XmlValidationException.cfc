<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
Author: Ben Edwards (ben@ben-edwards.com)
$Id: XmlValidationException.cfc $

Created version: 1.1.0
--->
<cfcomponent displayname="XmlValidationException"
	extends="Exception"
	output="false"
	hint="Encapsulates XML validation exception information.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.errors = ArrayNew(1) />
	<cfset variables.fatalErrors = ArrayNew(1) />
	<cfset variables.warnings = ArrayNew(1) />
	<cfset variables.xmlPath = "" />
	<cfset variables.dtdPath = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="wrapValidationResult" access="public" returntype="XmlValidationException" output="false"
		hint="Wraps the result of a failed XML validation.">
		<cfargument name="validationResult" type="struct" required="true"
			hint="A struct in the format returned by XmlValidate()." />
		<cfargument name="xmlPath" type="string" required="false" default=""
			hint="The full path the XML file that was validated." />
		<cfargument name="dtdPath" type="string" required="false" default=""
			hint="The full path the DTD file used for validation." />
		
		<cfset setFatalErrors(arguments.validationResult.fatalErrors) />
		<cfset setErrors(arguments.validationResult.errors) />
		<cfset setWarnings(arguments.validationResult.warnings) />
		<cfset setXmlPath(arguments.xmlPath) />
		<cfset setDtdPath(arguments.dtdPath) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getFormattedMessage" access="public" returntype="string" output="false"
		hint="Gets a message from the errors/warnings for display.">
		
		<cfset var rawMessage = "" />
		<cfset var formattedMessage = "" />

		<!--- Display error messages in order of important: fatal, error and warning --->
		<cfif ArrayLen(variables.fatalErrors) GT 0>
			<cfset rawMessage = variables.fatalErrors[1] />
		<cfelseif ArrayLen(variables.errors) GT 0>
			<cfset rawMessage = variables.errors[1] />
		<cfelseif ArrayLen(variables.warnings) GT 0>
			<cfset rawMessage = variables.warnings[1] />
		<cfelse>
			<cfthrow type="MachII.framework.NoMessagesDefined"
				message="There are no XML validation error messages defined. Cannot display a formatted message." />
		</cfif>
		
		<cfset formattedMessage = "Error validating XML file: " />
		<cfif getXmlPath() NEQ ''>
			<cfset formattedMessage = formattedMessage & getXmlPath() & ": " />
		</cfif>
		<cfset formattedMessage = formattedMessage & "Line " & ListGetAt(rawMessage,2,':') & ", " />
		<cfset formattedMessage = formattedMessage & "Column " & ListGetAt(rawMessage,3,':') & ": " />
		<cfset formattedMessage = formattedMessage & ListGetAt(rawMessage,4,':') />

		<!--- Gets the optional 5th place message part if it exists --->
		<cfif ListLen(rawMessage, ":") GTE 5>
			<cfset formattedMessage = formattedMessage & " - " & ListGetAt(rawMessage,5,':') />
		</cfif>
		
		<cfreturn formattedMessage />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setXmlPath" access="public" returntype="void" output="false">
		<cfargument name="xmlPath" type="string" required="false" />
		<cfset variables.xmlPath = arguments.xmlPath />
	</cffunction>
	<cffunction name="getXmlPath" access="public" returntype="string" output="false">
		<cfreturn variables.xmlPath />
	</cffunction>
	
	<cffunction name="setDtdPath" access="public" returntype="void" output="false">
		<cfargument name="dtdPath" type="string" required="false" />
		<cfset variables.dtdPath = arguments.dtdPath />
	</cffunction>
	<cffunction name="getDtdPath" access="public" returntype="string" output="false">
		<cfreturn variables.dtdPath />
	</cffunction>
	
	<cffunction name="setErrors" access="public" returntype="void" output="false">
		<cfargument name="errors" type="array" required="false" />
		<cfset variables.errors = arguments.errors />
	</cffunction>
	<cffunction name="getErrors" access="public" returntype="array" output="false">
		<cfreturn variables.errors />
	</cffunction>
	
	<cffunction name="setFatalErrors" access="public" returntype="void" output="false">
		<cfargument name="fatalErrors" type="array" required="false" />
		<cfset variables.fatalErrors = arguments.fatalErrors />
	</cffunction>
	<cffunction name="getFatalErrors" access="public" returntype="array" output="false">
		<cfreturn variables.fatalErrors />
	</cffunction>
	
	<cffunction name="setWarnings" access="public" returntype="void" output="false">
		<cfargument name="warnings" type="array" required="false" />
		<cfset variables.warnings = arguments.warnings />
	</cffunction>
	<cffunction name="getWarnings" access="public" returntype="array" output="false">
		<cfreturn variables.warnings />
	</cffunction>
	
</cfcomponent>