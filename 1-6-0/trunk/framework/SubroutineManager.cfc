<!---
License:
Copyright 2007 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
$Id$

Created version: 1.5.0
Updated version: 1.5.0

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
	<cfset variables.handlers = StructNew() />
	<cfset variables.parentSubroutineManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="SubroutineManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentSubroutineManager" type="any" required="false" default=""
			hint="Optional argument for a parent subroutine manager. If there isn't one default to empty string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif isObject(arguments.parentSubroutineManager)>
			<cfset setParent(arguments.parentSubroutineManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
				
		<cfset var subroutineNodes = "" />
		<cfset var subroutineHandler = "" />
		<cfset var subroutineName = "" />
		<cfset var commandNode = "" />
		<cfset var command = "" />
		<cfset var hasParent = isObject(getParent()) />
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
		<!--- DO NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addSubroutineHandler" access="public" returntype="void" output="false"
		hint="Registers a SubroutineHandler by name.">
		<cfargument name="subroutineName" type="string" required="true" />
		<cfargument name="subroutineHandler" type="MachII.framework.SubroutineHandler" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isSubroutineDefined(arguments.subroutineName)>
			<cfthrow type="MachII.framework.SubroutineHandlerAlreadyDefined"
				message="A SubroutineHandler with name '#arguments.subroutineName#' is already registered." />
		<cfelse>
			<cfset variables.handlers[arguments.subroutineName] = arguments.subroutineHandler />
		</cfif>
	</cffunction>
	
	<cffunction name="getSubroutineHandler" access="public" returntype="MachII.framework.SubroutineHandler"
		hint="Returns the SubroutineHandler for the named Subroutine.">
		<cfargument name="subroutineName" type="string" required="true"
			hint="The name of the Subroutine to handle." />
		
		<cfif isSubroutineDefined(arguments.subroutineName)>
			<cfreturn variables.handlers[arguments.subroutineName] />
		<cfelseif isObject(getParent()) AND getParent().isSubroutineDefined(arguments.subroutineName)>
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
		hint="Returns true if a SubroutineHandler for the named Subroutine is defined; otherwise false.">
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