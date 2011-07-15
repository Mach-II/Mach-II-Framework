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

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="EventArgCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for putting an event arg into the current event.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "event-arg" />
	<cfset variables.argName = "" />
	<cfset variables.argValue = "" />
	<cfset variables.argVariable = "" />
	<cfset variables.overwrite = true />
	<cfset variables.parse = false />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventArgCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="argName" type="string" required="true" />
		<cfargument name="argValue" type="any" required="false" default="" />
		<cfargument name="argVariable" type="string" required="false" default="" />
		<cfargument name="overwrite" type="boolean" required="false" default="true" />
		<cfargument name="parse" type="boolean" required="false" default="false" />

		<cfset setArgName(arguments.argName) />
		<cfset setArgValue(arguments.argValue) />
		<cfset setArgVariable(arguments.argVariable) />
		<cfset setOverwrite(arguments.overwrite) />
		<cfset setParse(arguments.parse) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var value = "" />
		<cfset var log = getLog() />
		<cfset var argValueType = "[complex value]" />

		<!--- Get value (variable attribute and then event-arg) --->
		<cfif isArgVariableDefined()>
			<cfset value = getArgVariableValue() />
		<cfelseif isArgValueDefined()>
			<cfif getParse()>
				<cftry>
					<cfset value = resolveExpressions(getArgValue(), arguments.event, arguments.eventContext) />
					<cfcatch type="any">
						<cfif IsSimpleValue(getArgValue())>
							<cfset argValueType = getArgValue() />
						</cfif>

						<cfif log.isErrorEnabled()>
							<cfset log.error("An exception has occurred while trying to evaluate an value expression '#argValueType#' in an event-arg command in #getParentHandlerType()# named '#getParentHandlerName()#' in module '#arguments.eventContext.getAppManager().getModuleName()#'.", cfcatch) />
						</cfif>
						<cfthrow type="MachII.framework.commands.InvalidExpression"
							message="An exception has occurred while trying to evaluate an value expression '#argValueType#' in an event-arg command in #getParentHandlerType()# named '#getParentHandlerName()#' in module '#arguments.eventContext.getAppManager().getModuleName()#'. See details for more information."
							detail="#getUtils().buildMessageFromCfCatch(cfcatch)#" />
								
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset value = getArgValue() />
			</cfif>
		</cfif>

		<!--- Set event-arg if overwrite is true or if event-arg is not defined
			No need to check if overwrite is false since CF uses short-circuit logic --->
		<cfif getOverwrite() OR NOT arguments.event.isArgDefined(getArgName())>
			<cfif IsSimpleValue(value)>
				<cfset log.debug("Set event-arg named '#getArgName()#' with a value of '#value#'.") />
			<cfelse>
				<cfset log.debug("Set event-arg named '#getArgName()#' (parse='#getParse()#') with a value of:", value) />
			</cfif>

			<cfset arguments.event.setArg(getArgName(), value) />
		<cfelse>
			<cfif IsSimpleValue(value)>
				<cfset log.debug("An event-arg named '#getArgName()#' with overwrite 'false' is already defined. Current value or variable: '#value#'.") />
			<cfelse>
				<cfset log.debug("An event-arg named '#getArgName()#' with overwrite 'false' is already defined.", value) />
			</cfif>
		</cfif>

		<cfreturn true />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getArgVariableValue" access="private" returntype="any" output="false"
		hint="Gets an arg variable value by using evaluate.">

		<cfset var value = "" />
		<cfset var log = getLog() />

		<cfif IsDefined(getArgVariable())>
			<cfset value = Evaluate(getArgVariable()) />
		<cfelse>
			<cfset log.debug("No value found for arg variable named '#getArgVariable()#' for event-arg named '#getArgName()#'.") />
		</cfif>

		<cfreturn value />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setArgName" access="private" returntype="void" output="false">
		<cfargument name="argName" type="string" required="true" />
		<cfset variables.argName = arguments.argName />
	</cffunction>
	<cffunction name="getArgName" access="private" returntype="string" output="false">
		<cfreturn variables.argName />
	</cffunction>

	<cffunction name="setArgValue" access="private" returntype="void" output="false">
		<cfargument name="argValue" type="any" required="true" />
		<cfset variables.argValue = arguments.argValue />
	</cffunction>
	<cffunction name="getArgValue" access="private" returntype="any" output="false">
		<cfreturn variables.argValue />
	</cffunction>
	<cffunction name="isArgValueDefined" access="private" returntype="boolean" output="false">
		<cfreturn (IsSimpleValue(variables.argValue) AND Len(variables.argValue)) OR NOT IsSimpleValue(variables.argValue) />
	</cffunction>

	<cffunction name="setArgVariable" access="private" returntype="void" output="false">
		<cfargument name="argVariable" type="string" required="true" />
		<cfset variables.argVariable = arguments.argVariable />
	</cffunction>
	<cffunction name="getArgVariable" access="private" returntype="string" output="false">
		<cfreturn variables.argVariable />
	</cffunction>
	<cffunction name="isArgVariableDefined" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.argVariable) />
	</cffunction>

	<cffunction name="setOverwrite" access="private" returntype="void" output="false">
		<cfargument name="overwrite" type="string" required="true" />
		<!--- Enforce that overwrite is always true unless 'false' is passed --->
		<cfset variables.overwrite = (arguments.overwrite IS NOT "false") />
	</cffunction>
	<cffunction name="getOverwrite" access="private" returntype="boolean" output="false">
		<cfreturn variables.overwrite />
	</cffunction>

	<cffunction name="setParse" access="private" returntype="void" output="false"
		hint="Sets if the arg should be parsed because it contains M2EL syntax.">
		<cfargument name="parse" type="boolean" required="true" />
		<cfset variables.parse = arguments.parse />
	</cffunction>
	<cffunction name="getParse" access="private" returntype="boolean" output="false"
		hint="Gets if the arg should be parsed because it contains M2EL syntax.">
		<cfreturn variables.parse />
	</cffunction>

</cfcomponent>