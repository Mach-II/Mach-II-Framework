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
$Id: Event.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.1

Notes:
- Added request event name functionality. (pfarrell)
--->
<cfcomponent 
	displayname="Event"
	output="false"
	hint="The Event object encapsulates the event args.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.name = "" />
	<cfset variables.requestName = "" />
	<cfset variables.args = StructNew() />
	<cfset variables.argTypes = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="name" type="string" required="false" default=""
			hint="The name of the event object." />
		<cfargument name="args" type="struct" required="false" default="#StructNew()#"
			hint="Event args to populate this event object." />
		<cfargument name="requestName" type="string" required="false" default=""
			hint="A request name for this request lifecycle." />
		
		<cfset setName(arguments.name) />
		<cfset setArgs(arguments.args) />
		<cfset setRequestName(arguments.requestName) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setName" access="public" returntype="void" output="false"
		hint="Sets the name of the event object.">
		<cfargument name="name" type="string" required="true"
			hint="A name for this event." />
		<cfset variables.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="string" output="false"
		hint="Returns the name of the event object.">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setRequestName" access="public" returntype="void" output="false"
		hint="Sets the event name that started the request lifecycle.">
		<cfargument name="requestName" type="string" required="true"
			hint="A request name for this event." />
		<cfset variables.requestName = arguments.requestName />
	</cffunction>
	<cffunction name="getRequestName" access="public" returntype="string" output="false"
		hint="Returns the event name that started the request lifecycle.">
		<cfreturn variables.requestName />
	</cffunction>
	
	<cffunction name="setArg" access="public" returntype="void" output="false"
		hint="Sets an arg in the event object.">
		<cfargument name="name" type="string" required="true"
			hint="The name of the arg to set." />
		<cfargument name="value" type="any" required="true"
			hint="The value of the arg to set." />
		<cfargument name="argType" type="string" required="false"
			hint="The type of the arg to set." />
		
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
		hint="Sets the arg type for the specified arg.">
		<cfargument name="argName" type="string" required="true"
			hint="The name of the arg." />
		<cfargument name="argType" type="string" required="true"
			hint="The arg type to set." />
		<cfset variables.argTypes[arguments.argName] = arguments.argType />
	</cffunction>
	<cffunction name="getArgType" access="public" returntype="string" output="false"
		hint="Returns the arg type of the arg name.">
		<cfargument name="argName" type="string" required="true"
			hint="The name of the arg to get the arg type." />
		<cfif StructKeyExists(variables.argTypes, arguments.argName)>
			<cfreturn variables.argTypes[arguments.argName] />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

</cfcomponent>