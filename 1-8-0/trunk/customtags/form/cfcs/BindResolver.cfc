<!---
License:
Copyright 2008 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent displayname="BindResolver"
	output="false"
	hint="Resolves any binding.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BindResolver" output="false"
		hint="Initializes the resolver.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="resolvePath" access="public" returntype="any" output="true"
		hint="Resolves a path and returns a value.">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="bind" type="any" required="false" default="#request._MachIIFormLib.bind#" />
		
		<cfset var value = "" />
		<cfset var method = ListFirst(arguments.path, ".") />
		
		<cfif getMetaData(arguments.bind).name NEQ "MachII.framework.Event">
			<cfinvoke component="#arguments.bind#"
				method="get#method#"
				returnvariable="value" />
		<cfelse>
			<cfinvoke component="#arguments.bind#"
				method="getArg"
				returnvariable="value">
				<cfinvokeargument name="name" value="#method#" />
			</cfinvoke>
		</cfif>
		
		<cfset arguments.path = ListDeleteAt(arguments.path, 1, ".") />

		<cfif ListLen(arguments.path, ".") GT 0>
			<cfset value = resolvePath(arguments.path, value) />
		</cfif>
		
		<cfreturn value />
	</cffunction>
	
	<cffunction name="getNameFromPath" access="public" returntype="string" output="false"
		hint="Gets a name from a binding path.">
		<cfargument name="path" type="string" required="true" />
		
		<cfset var name = "" />
		
		<cfif FindNoCase(".", arguments.path)>
			<cfset name = ListLast(arguments.path, ".") />
		<cfelse>
			<cfset name = arguments.path />
		</cfif>
		
		<cfreturn name />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->

</cfcomponent>