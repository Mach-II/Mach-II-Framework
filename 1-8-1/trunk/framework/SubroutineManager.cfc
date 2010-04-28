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

Created version: 1.5.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="SubroutineManager"
	extends="MachII.framework.CommandLoaderBase"
	output="false"
	hint="Manages registered SubroutineHandlers for the framework.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentSubroutineManager = "" />
	<cfset variables.handlers = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="SubroutineManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getSubroutineManager()) />
		</cfif>

		<cfset super.init() />

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var subroutineNodes = ArrayNew(1) />
		<cfset var subroutineHandler = "" />
		<cfset var subroutineName = "" />

		<cfset var commandNode = "" />
		<cfset var command = "" />

		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for subroutines --->
		<cfif NOT arguments.override>
			<cfset subroutineNodes = XMLSearch(arguments.configXML, "mach-ii/subroutines/subroutine") />
		<cfelse>
			<cfset subroutineNodes = XMLSearch(arguments.configXML, ".//subroutines/subroutine") />
		</cfif>

		<!--- Setup each subroutine --->
		<cfloop from="1" to="#ArrayLen(subroutineNodes)#" index="i">
			<cfset subroutineName = subroutineNodes[i].xmlAttributes["name"] />

			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(subroutineNodes[i].xmlAttributes, "overrideAction")>
				<cfif subroutineNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeSubroutine(subroutineName) />
				<cfelseif subroutineNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(subroutineNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = subroutineNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = subroutineName />
					</cfif>

					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isSubroutineDefined(mapping)>
						<cfthrow type="MachII.framework.overrideSubroutineNotDefined"
							message="An subroutine named '#mapping#' cannot be found in the parent subroutine manager for the override named '#subroutineName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>

					<cfset addSubroutineHandler(subroutineName, getParent().getSubroutineHandler(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<cfset subroutineHandler = CreateObject("component", "MachII.framework.SubroutineHandler").init() />

				<cfloop from="1" to="#ArrayLen(subroutineNodes[i].XMLChildren)#" index="j">
				    <cfset commandNode = subroutineNodes[i].XMLChildren[j] />
					<cfset command = createCommand(commandNode, subroutineName, "subroutine") />
					<cfset subroutineHandler.addCommand(command) />
				</cfloop>

				<cfset addSubroutineHandler(subroutineName, subroutineHandler, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered SubroutineHandlers.">
		<cfset super.configure() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addSubroutineHandler" access="public" returntype="void" output="false"
		hint="Registers a SubroutineHandler by name.">
		<cfargument name="subroutineName" type="string" required="true" />
		<cfargument name="subroutineHandler" type="MachII.framework.SubroutineHandler" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />

		<cfif NOT arguments.overrideCheck>
			<cftry>
				<cfset StructInsert(variables.handlers, arguments.subroutineName, arguments.subroutineHandler, false) />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.SubroutineHandlerAlreadyDefined"
						message="A SubroutineHandler with name '#arguments.subroutineName#' is already registered." />
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset variables.handlers[arguments.subroutineName] = arguments.subroutineHandler />
		</cfif>
	</cffunction>

	<cffunction name="getSubroutineHandler" access="public" returntype="MachII.framework.SubroutineHandler" output="false"
		hint="Returns the SubroutineHandler for the named Subroutine. Checks parent.">
		<cfargument name="subroutineName" type="string" required="true"
			hint="The name of the Subroutine to handle." />

		<cfif isSubroutineDefined(arguments.subroutineName)>
			<cfreturn variables.handlers[arguments.subroutineName] />
		<cfelseif IsObject(getParent()) AND getParent().isSubroutineDefined(arguments.subroutineName)>
			<cfreturn getParent().getSubroutineHandler(arguments.subroutineName) />
		<cfelse>
			<cfthrow type="MachII.framework.SubroutineHandlerNotDefined"
				message="SubroutineHandler for subroutine '#arguments.subroutineName#' is not defined." />
		</cfif>
	</cffunction>

	<cffunction name="removeSubroutine" access="public" returntype="void" output="false"
		hint="Removes a subroutine. Does NOT remove from a parent.">
		<cfargument name="subroutineName" type="string" required="true"
			hint="The name of the Subroutine to handle." />
		<cfset StructDelete(variables.handlers, arguments.subroutineName, false) />
	</cffunction>

	<cffunction name="isSubroutineDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a subroutine is defined. Does not check parent.">
		<cfargument name="subroutineName" type="string" required="true"
			hint="The name of the Subroutine to handle." />
		<cfreturn StructKeyExists(variables.handlers, arguments.subroutineName) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getSubroutineNames" access="public" returntype="array" output="false"
		hint="Returns an array of subroutine names.">
		<cfreturn StructKeyArray(variables.handlers) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent SubroutineManager instance this SubroutineManager belongs to.">
		<cfargument name="parentSubroutineManager" type="MachII.framework.SubroutineManager" required="true" />
		<cfset variables.parentSubroutineManager = arguments.parentSubroutineManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent SubroutineManager instance this SubroutineManager belongs to. Return empty string if no parent is defined.">
		<cfreturn variables.parentSubroutineManager />
	</cffunction>

</cfcomponent>