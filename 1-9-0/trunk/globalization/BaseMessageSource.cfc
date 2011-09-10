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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0
--->

<cfcomponent
	displayname="BaseMessageSource"
	output="false"
	hint="The base class for message sources.">

	<!---
	PROPERTIES
	--->
	<cfset variables.parent = "" />
	<cfset variables.log = "" />
	<cfset variables.uniqueId = createRandomKey() />
	<cfset variables.noArgsJavaCastArray = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BaseMessageSource" output="false"
		hint="Initializes the base class for message sources.">
		<cfargument name="parentMessageSource" type="any" required="false"
			hint="The parent message source if available." />

		<cfif StructKeyExists(arguments, "parentMessageSource")>
			<cfset setParent(arguments.parentMessageSource) />
		</cfif>

		<!--- Test for native JavaCast() with array usage --->
		<cftry>
			<!--- This breaks on OpenBD 1.4 and lower --->
			<cfset JavaCast("java.lang.Object[]", ArrayNew(1)) />

			<cfset variables.javaCastArray = variables.javaCastArray_native />

			<cfcatch type="any">
				<cfset variables.javaCastArray = variables.javaCastArray_cfml />
			</cfcatch>
		</cftry>

		<cfset variables.noArgsJavaCastArray = javaCastArray("java.lang.Object", ArrayNew(1)) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getMessage" access="public" returntype="string" output="false"
		hint="Gets a message with args and locale.">
		<cfargument name="code" type="string" required="true"
			hint="The message code key." />
		<cfargument name="args" type="any" required="true"
			hint="A list or array of message format arguments." />
		<cfargument name="locale" type="any" required="true"
			hint="The locale of the message to retrieve." />
		<cfargument name="defaultMessage" type="string" required="false" default=""
			hint="The default message if the message does not exist." />

		<cfset var message = getMessageInternal(arguments.code, arguments.args, arguments.locale) />

		<cfif Len(message)>
			<cfset getLog().debug("Globalization lookup complete for code '#arguments.code#' (localization: '#arguments.locale.toString()#') with return message: '#message#'") />

			<cfreturn message />
		<cfelse>
			<cfset getLog().debug("Message determined to be empty; returning default message: '#arguments.defaultMessage#'") />

			<cfreturn defaultMessage />
		</cfif>
	</cffunction>

	<cffunction name="resolveLocaleStringToLocaleObject" access="public" returntype="any" output="false"
		hint="Resolves a locale string to a Java locale object.">
		<cfargument name="locale" type="string" required="true" />

		<cfset var localeArray = ListToArray(arguments.locale, "_") />

		<cfif ArrayLen(localeArray) EQ 1>
			<cfset arguments.locale = CreateObject("java", "java.util.Locale").init(localeArray[1]) />
		<cfelseif ArrayLen(localeArray) EQ 2>
			<cfset arguments.locale = CreateObject("java", "java.util.Locale").init(localeArray[1], localeArray[2]) />
		<cfelse>
			<!--- This seems like a sensible default to me; if there is a better default, feel free to use it here --->
			<cfset getLog().warn("No locale or invalid locale given; using default locale")/>
			<cfset arguments.locale = CreateObject("java", "java.util.Locale").getDefault() />
		</cfif>

		<cfreturn arguments.locale />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createRandomKey" access="private" returntype="string" output="false"
		hint="Creates a random key.">
		<cfreturn Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000)) />
	</cffunction>

	<cffunction name="getMessageInternal" access="private" returntype="string" output="false"
		hint="Gets an internal message.">
		<cfargument name="code" type="string" required="true"
			hint="The message code key." />
		<cfargument name="args" type="any" required="true"
			hint="A list or array of message format arguments." />
		<cfargument name="locale" type="any" required="true"
			hint="The locale of the message to retrieve." />

		<cfset var messageFormat = "" />
		<cfset var localeArray = "" />

		<cfif NOT IsArray(arguments.args)>
			<cfset arguments.args = ListToArray(arguments.args) />
		</cfif>

		<cfif NOT Len(arguments.code)>
			<cfset getLog().trace("No code given, returning empty string") />
			<cfreturn "" />
		</cfif>

		<cfif NOT IsObject(arguments.locale)>
			<cfset arguments.locale = resolveLocaleStringToLocaleObject(arguments.locale) />
		</cfif>

		<!--- If the arguments array is empty, assume there is no messageFormat necessary --->
		<cfif NOT ArrayLen(arguments.args)>
			<cfset getLog().trace("No arguments given, resolving code without arguments") />
			<cfreturn resolveCodeWithoutArguments(arguments.code, arguments.locale) />
		</cfif>

		<cfset getLog().trace("Retrieving messageFormat object") />
		<cfset messageFormat = resolveCode(arguments.code, arguments.locale) />

		<cfif IsObject(messageFormat)>
			<cflock name="_MachIIResourceBundleMessageSource_messageFormat_#variables.uniqueId#" type="readonly" timeout="30">
				<cfset getLog().trace("MessageFormat object found and resolving.") />

				<cfreturn messageFormat.format(javaCastArray("java.lang.Object", arguments.args)) />
			</cflock>
		</cfif>

		<!--- Unable to find suitable match; return empty string --->
		<cfset getLog().trace("Unable to find suitable MessageFormat object; returning empty string") />

		<cfreturn "" />
	</cffunction>

	<cffunction name="resolveCode" access="private" returntype="any" output="false">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<cffunction name="resolveCodeWithoutArguments" access="private" returntype="any" output="false">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />

		<cfset var messageFormat = resolveCode(arguments.code, arguments.locale) />

		<cfif IsObject(messageFormat)>
			<cflock name="_MachIIResourceBundleMessageSource_messageFormat_#variables.uniqueId#" type="readonly" timeout="30">
				<cfset getLog().trace("MessageFormat object found and  resolving.") />
				<cfreturn messageFormat.format(variables.noArgsJavaCastArray) />
			</cflock>
		</cfif>

		<cfset getLog().trace("Unable to find suitable MessageFormat object; returning empty string") />

		<cfreturn "" />
	</cffunction>

	<cffunction name="createMessageFormat" access="private" returntype="any" output="false"
		hint="Creates a message format based on the message and locale.">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />

		<cfset getLog().trace("Creating MessageFormat object for message '#arguments.message#', locale '#arguments.locale.toString()#'") />

		<cfreturn CreateObject("java", "java.text.MessageFormat").init(arguments.message, arguments.locale) />
	</cffunction>

	<cffunction name="JavaCastArray_native" access="private" returntype="any" output="false"
		hint="Java casts an array to the correct type using native JavaCast().">
		<cfargument name="class" type="string" required="true" />
		<cfargument name="data" type="array" required="true" />
		<cfreturn JavaCast("java.lang.Object[]", arguments.data) />
	</cffunction>

	<cffunction name="JavaCastArray_cfml" access="private" returntype="any" output="false"
		hint="Java casts an array to the correct type using Java reflection.">
		<cfargument name="class" type="string" required="true" />
		<cfargument name="data" type="array" required="true" />

		<cfset var javaClass = CreateObject("java", arguments.class) />
	 	<cfset var reflectArray = CreateObject("java", "java.lang.reflect.Array") />
	 	<cfset var javaArray = reflectArray.newInstance(javaClass.getClass(), ArrayLen(arguments.data)) />
		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(arguments.data)#" index="i">
			<cfset reflectArray.set(javaArray, JavaCast("int", (i - 1)), arguments.data[i]) />
		</cfloop>

		<cfreturn javaArray />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="parent" type="MachII.globalization.BaseMessageSource" required="true" />
		<cfset variables.parent = arguments.parent />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false">
		<cfreturn variables.parent />
	</cffunction>

	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>