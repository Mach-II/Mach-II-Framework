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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.1.0
Updated version: 1.1.1

Notes:
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
	<!--- Inherited from base class --->

	<!---
	PUBLIC FUNCTIONS
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
		<cfset setExceptionStatus(NOT arguments.validationResult.status) />
		<cfset setXmlPath(arguments.xmlPath) />
		<cfset setDtdPath(arguments.dtdPath) />

		<cfreturn this />
	</cffunction>
	
	<cffunction name="getFormattedMessage" access="public" returntype="string" output="false"
		hint="Gets a message from the errors/warnings for display.">
		<cfargument name="rawMessage" type="string" required="false" default="#findMostSevereMessage()#"
			hint="A raw message or this method will select the most severe message available." />

		<cfset var formattedMessage = "Error validating XML file: " />
		<cfset var partedMessage = getPartedMessage(arguments.rawMessage)/>

		<cfif getXmlPath() NEQ ''>
			<cfset formattedMessage = formattedMessage & getXmlPath() & ": " />
		</cfif>		

		<cfset formattedMessage = formattedMessage & "Line " & partedMessage.line & ", " />
		<cfset formattedMessage = formattedMessage & "Column " & partedMessage.column />
		<cfif Len(partedMessage.message)>
			<cfset formattedMessage = formattedMessage & ": " & partedMessage.message />
		</cfif>
		<cfif Len(partedMessage.detail)>
			<cfset formattedMessage = formattedMessage & " - " & partedMessage.detail />
		</cfif>

		<cfreturn formattedMessage />
	</cffunction>
	
	<cffunction name="getPartedMessage" access="public" returntype="struct" output="false"
		hint="Takes a message breaks it into a parted message struct.">
		<cfargument name="rawMessage" type="string" required="false" default="#findMostSevereMessage()#"
			hint="A raw message or this method will select the most severe message available." />

		<cfset var partedMessage = StructNew() />
		
		<!---
			ACF stupidly uses ":" for list when namespaces are being used.
			This causes issues because ";" is the list delim. Change all:
			'{"": to '{"";;;;
			'{namespace; to '{namespace;;;;
			Then we convert back.
		--->
		<cfset arguments.rawMessage = REReplaceNoCase(arguments.rawMessage, "\'\{(""|.*):(.*?)}", "'{\1;;;;\2?}", "all") />
		
		<cfset partedMessage.line = "" />
		<cfset partedMessage.column = "" />
		<cfset partedMessage.message = "" />
		<cfset partedMessage.detail = "" />
		
		<cfset partedMessage.severity = REReplaceNoCase(ListGetAt(arguments.rawMessage, 1, ":"), "\[(.*)\]", "\1", "all") />
		
		<cfif ListLen(arguments.rawMessage, ":") GTE 2>
			<cfset partedMessage.line = ListGetAt(arguments.rawMessage, 2, ':') />
		</cfif>
		<cfif ListLen(arguments.rawMessage, ":") GTE 3>
			<cfset partedMessage.column = ListGetAt(arguments.rawMessage, 3, ':')/>
		</cfif>
		<cfif ListLen(arguments.rawMessage, ":") GTE 4>
			<cfset partedMessage.message = REReplaceNoCase(Trim(ListGetAt(arguments.rawMessage, 4, ':')), "\'\{(""|.*?);;;;(.*?)}", "'{\1:.\2}", "all") />
		</cfif>
		<cfif ListLen(arguments.rawMessage, ":") GTE 5>
			<cfset partedMessage.detail = REReplaceNoCase(Trim(ListGetAt(arguments.rawMessage, 5, ':')), "\'\{(""|.*?);;;;(.*?)}", "'{\1:.\2}", "all") />
		</cfif>
		
		<cfreturn partedMessage />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="findMostSevereMessage" access="private" returntype="string" output="false"
		hint="Find most severe message available.">

		<!--- Display error messages in order of important: fatal, error and warning --->
		<cfif ArrayLen(variables.fatalErrors) GT 0>
			<cfreturn variables.fatalErrors[1] />
		<cfelseif ArrayLen(variables.errors) GT 0>
			<cfreturn variables.errors[1] />
		<cfelseif ArrayLen(variables.warnings) GT 0>
			<cfreturn variables.warnings[1] />
		<cfelse>
			<cfthrow type="MachII.framework.NoMessagesDefined"
				message="There are no XML validation error messages defined." />
		</cfif>		
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

	<cffunction name="setExceptionStatus" access="public" returntype="void" output="false">
		<cfargument name="exceptionStatus" type="boolean" required="false" />
		<cfset variables.exceptionStatus = arguments.exceptionStatus />
	</cffunction>
	<cffunction name="getExceptionStatus" access="public" returntype="boolean" output="false">
		<cfreturn variables.exceptionStatus />
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