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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0
--->

<cfcomponent
	displayname="BaseMessageSource"
	output="false"
	hint="">
	
	<cfset variables.log = ""/>
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BaseMessageSource" output="false">
		<cfreturn this/>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfargument name="code" type="string" required="true"/>
		<cfargument name="args" type="array" required="true"/>
		<cfargument name="locale" type="any" required="true"/>
		<cfargument name="defaultMessage" type="string" required="false" default=""/>

		<cfset var message = getInternalMessage(code, args, locale)/>
		
		<cfif message EQ "">
			<cfset getLog().debug("Message determined to be empty; returning default message")/>
			<cfreturn defaultMessage/>
		</cfif>
		
		<cfset getLog().debug("Globalization lookup complete for code #arguments.code# (localization #arguments.locale.toString()#). Return message below.", message)/>
		<cfreturn message/>
	</cffunction>
	
	<!---
	PRIVATE FUNCTIONS
	--->
	<cffunction name="getInternalMessage" access="private" returntype="string" output="false">
		<cfargument name="code" type="string" required="true"/>
		<cfargument name="args" type="array" required="true"/>
		<cfargument name="locale" type="any" required="true"/>
		
		<cfset var messageFormat = ""/>
		<cfset var argsToUse = JavaCast("String[]", arguments.args)/>
		
		<cfif arguments.code EQ "">
			<cfset getLog().trace("No code given, returning empty string")/>
			<cfreturn ""/>
		</cfif>

		<cfif NOT IsObject(arguments.locale)>
			<cfset getLog().trace("No locale given, creating default locale")/>
			<cfset locale = CreateObject("java", "java.util.Locale").getDefault()/>
		</cfif>
		
		<!--- If the arguments array is empty, assume there is no messageFormat necessary --->
		<cfif ArrayLen(arguments.args) EQ 0>
			<cfset getLog().trace("No arguments given, resolving code without arguments")/>
			<cfreturn resolveCodeWithoutArguments(arguments.code, arguments.locale)/>
		</cfif>
		
		<cfset getLog().trace("Retrieving messageFormat object")/>
		<cfset messageFormat = resolveCode(arguments.code, arguments.locale)/>
		
		<cfif IsObject(messageFormat)>
			<cflock name="messageFormat" timeout="30">
				<cfset getLog().trace("MessageFormat object found; resolving...")/>
				<cfreturn messageFormat.format(argsToUse)/>
			</cflock>
		</cfif>
		
		<!--- unable to find suitable match; return empty string --->
		<cfset getLog().trace("Unable to find suitable MessageFormat object; returning empty string")/>
		<cfreturn ""/>
	</cffunction>
	
	<cffunction name="resolveCode" access="private" returntype="any" output="false">
		<cfargument name="code" type="string" required="true"/>
		<cfargument name="locale" type="any" required="true"/>
		
		<!---
			This function is empty. You must supply a 'resolveCode' function
			in the extending class
		--->
		<cfreturn ""/>
	</cffunction>
	
	<cffunction name="resolveCodeWithoutArguments" access="private" returntype="any" output="false">
		<cfargument name="code" type="string" required="true"/>
		<cfargument name="locale" type="any" required="true"/>
		
		<cfset var messageFormat = resolveCode(arguments.code, arguments.locale)/>

		<cfif IsObject(messageFormat)>
			<cflock name="messageFormat" timeout="30">
				<cfset getLog().trace("MessageFormat object found; resolving...")/>
				<cfreturn messageFormat.format(JavaCast("string[]", ArrayNew(1)))/>
			</cflock>
		</cfif>
		
		<cfset getLog().trace("Unable to find suitable MessageFormat object; returning empty string")/>
		<cfreturn ""/>
	</cffunction>
	
	<cffunction name="createMessageFormat" access="private" returntype="any" output="false">
		<cfargument name="message" type="string" required="true"/>
		<cfargument name="locale" type="any" required="true"/>
		
		<cfset getLog().trace("Creating MessageFormat object for message '#arguments.message#', locale #arguments.locale.toString()#")/>
		<cfreturn CreateObject("java", "java.text.MessageFormat").init(arguments.message, arguments.locale)/>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
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