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

$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="Message"
	output="false"
	hint="A bean which models the Message form.">


	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Message" output="false">
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="info"
			hint="Sets the level of the message. 'info', 'warn' or 'exception'." />
		<cfargument name="caughtException" type="struct" required="false" default="#StructNew()#" />

		<!--- run setters --->
		<cfset setMessage(arguments.message) />
		<cfset setType(arguments.type) />
		<cfset setCaughtException(arguments.caughtException) />

		<cfreturn this />
 	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="hasCaughtException" access="public" returntype="boolean" output="false"
		hint="Checks if there is a caught exception.">
		<cfreturn StructCount(getCaughtException()) />
	</cffunction>
	
	<cffunction name="isExceptionOfType" access="public" returntype="boolean" output="false"
		hint="Checks if the current exception type is specified type.">
		<cfargument name="types" type="any" required="true" />
		
		<cfset var i = 0 />
		
		<cfif NOT IsSimplevalue(arguments.types)>
			<cfset arguments.types = ArrayTolist(arguments.types) />
		</cfif>
		
		<cfif ListFindNoCase(arguments.types, getType())>
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setMessage" access="public" returntype="void" output="false">
		<cfargument name="message" type="string" required="true" />
		<cfset variables.instance.message = trim(arguments.message) />
	</cffunction>
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfreturn variables.instance.message />
	</cffunction>

	<cffunction name="setType" access="public" returntype="void" output="false"
		hint="Sets the level of the message. 'info', 'warn' or 'exception'." >
		<cfargument name="type" type="string" required="true" />
		<cfset variables.instance.type = trim(arguments.type) />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.type />
	</cffunction>

	<cffunction name="setCaughtException" access="public" returntype="void" output="false">
		<cfargument name="caughtException" type="any" required="true" />
		<cfset variables.instance.caughtException = arguments.caughtException />
	</cffunction>
	<cffunction name="getCaughtException" access="public" returntype="any" output="false">
		<cfreturn variables.instance.caughtException />
	</cffunction>

</cfcomponent>