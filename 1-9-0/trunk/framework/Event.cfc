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

Author: Peter J. Farrell  (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="Event"
	output="false"
	hint="The Event object encapsulates the event args.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.name = "" />
	<cfset variables.moduleName = "" />
	<cfset variables.requestName = "" />
	<cfset variables.requestModuleName = "" />
	<cfset variables.args = StructNew() />
	<cfset variables.argTypes = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Event" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="name" type="string" required="false" default=""
			hint="The name of the event object." />
		<cfargument name="args" type="struct" required="false" default="#StructNew()#"
			hint="Event args to populate this event object." />
		<cfargument name="requestName" type="string" required="false" default=""
			hint="The request event name for this request lifecycle." />
		<cfargument name="requestModuleName" type="string" required="false" default=""
			hint="The request module name for this request lifecycle." />
		<cfargument name="moduleName" type="string" required="false" default=""
			hint="The module name of the event object." />
		
		<cfset setName(arguments.name) />
		<cfset setArgs(arguments.args) />
		<cfset setRequestName(arguments.requestName) />
		<cfset setRequestModuleName(arguments.requestModuleName) />
		<cfset setModuleName(arguments.moduleName) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setName" access="public" returntype="void" output="false"
		hint="Sets the name of the event object. (Not for public use.)">
		<cfargument name="name" type="string" required="true"
			hint="A name for this event." />
		<cfset variables.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="string" output="false"
		hint="Returns the name of the event object.">
		<cfreturn variables.name />
	</cffunction>
	
	<cffunction name="setModuleName" access="public" returntype="void" output="false"
		hint="Sets the module name of the event object. (Not for public use.)">
		<cfargument name="moduleName" type="string" required="true"
			hint="A module name for this event." />
		<cfset variables.moduleName = arguments.moduleName />
	</cffunction>
	<cffunction name="getModuleName" access="public" returntype="string" output="false"
		hint="Returns the module name of the event object.">
		<cfreturn variables.moduleName />
	</cffunction>

	<cffunction name="setRequestName" access="public" returntype="void" output="false"
		hint="Sets the event name that started the request lifecycle. (Not for public use.)">
		<cfargument name="requestName" type="string" required="true"
			hint="A request name for this event." />
		<cfset variables.requestName = arguments.requestName />
	</cffunction>
	<cffunction name="getRequestName" access="public" returntype="string" output="false"
		hint="Returns the event name that started the request lifecycle.">
		<cfreturn variables.requestName />
	</cffunction>
	
	<cffunction name="setRequestModuleName" access="public" returntype="void" output="false"
		hint="Sets the module name that started the request lifecycle. (Not for public use.)">
		<cfargument name="requestModuleName" type="string" required="true"
			hint="A request name for this event." />
		<cfset variables.requestModuleName = arguments.requestModuleName />
	</cffunction>
	<cffunction name="getRequestModuleName" access="public" returntype="string" output="false"
		hint="Returns the module name that started the request lifecycle.">
		<cfreturn variables.requestModuleName />
	</cffunction>
	
	<cffunction name="setArg" access="public" returntype="void" output="false"
		hint="Sets an arg in the event object.">
		<cfargument name="name" type="string" required="true"
			hint="The name of the arg to set." />
		<cfargument name="value" type="any" required="true"
			hint="The value of the arg to set." />
		<cfargument name="argType" type="string" required="false"
			hint="DEPRECATED: The type of the arg to set." />
		
		<cfset variables.args[arguments.name] = arguments.value />
		<cfif StructKeyExists(arguments, 'argType')>
			<cfset setArgType(arguments.name, arguments.argType) />
		</cfif>
	</cffunction>
	<cffunction name="getArg" access="public" returntype="any" output="false"
		hint="Returns the value of an arg or the default value if the arg is not defined.">
		<cfargument name="name" type="string" required="true"
			hint="Name of arg to get in the event object." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="Used to return a default value if the arg does not exist in the event object." />
		
		<cfif StructKeyExists(variables.args, arguments.name)>
			<cfreturn variables.args[arguments.name] />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>

	<cffunction name="isArgDefined" access="public" returntype="boolean" output="false"
		hint="Checks if an arg is defined in the event object.">
		<cfargument name="name" type="string" required="true"
			hint="Name of arg to check." />
		<cfreturn StructKeyExists(variables.args, arguments.name) />
	</cffunction>
	
	<cffunction name="removeArg" access="public" returntype="void" output="false"
		hint="Deletes an arg from the even object.">
		<cfargument name="name" type="string" required="true"
			hint="Name of arg to delete from the event object." />
		<cfset StructDelete(variables.args, arguments.name) />
	</cffunction>
	
	<cffunction name="setArgs" access="public" returntype="void" output="false"
		hint="Sets a structure of args to the event object.">
		<cfargument name="args" type="struct" required="true"
			hint="A structure of args to set." />
		<cfset var key = "" />

		<cfloop collection="#arguments.args#" item="key">
			<cfset setArg(key, arguments.args[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getArgs" access="public" returntype="struct" output="false"
		hint="Returns all args in this event.">
		<cfreturn variables.args />
	</cffunction>
	
	<cffunction name="setArgType" access="public" returntype="void" output="false"
		hint="DEPRECATED: Sets the arg type for the specified arg.">
		<cfargument name="argName" type="string" required="true"
			hint="The name of the arg." />
		<cfargument name="argType" type="string" required="true"
			hint="The arg type to set." />
		<cfset variables.argTypes[arguments.argName] = arguments.argType />
	</cffunction>
	<cffunction name="getArgType" access="public" returntype="string" output="false"
		hint="DEPRECATED: Returns the arg type of the arg name.">
		<cfargument name="argName" type="string" required="true"
			hint="The name of the arg to get the arg type." />
		<cfif StructKeyExists(variables.argTypes, arguments.argName)>
			<cfreturn variables.argTypes[arguments.argName] />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

</cfcomponent>