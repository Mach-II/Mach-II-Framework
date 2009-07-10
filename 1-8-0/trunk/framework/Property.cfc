<!---
License:
Copyright 2009 GreatBizTools, LLC

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

Created version: 1.5.0
Updated version: 1.8.0

Notes:
All user-defined properties extend this base property component.
--->
<cfcomponent
	displayname="Property"
	extends="MachII.framework.BaseComponent"
	output="false"
	hint="Base Property component.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Property" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager of the context in which this listener belongs to." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The property configure time parameters." />
		
		<cfset super.init(arguments.appManager, arguments.parameters) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="announceEvent" access="public" returntype="void" output="false"
		hint="Not available for use in Properties. Announces a new event to the framework.">
		<cfthrow type="MachII.framework.Property.noAccess"
			message="The 'announceEvent' method is not available for use in Properties." />
	</cffunction>
	
	<cffunction name="announceEventInModule" access="public" returntype="void" output="false"
		hint="Not available for use in Properties. Announces a new event to the framework.">
		<cfthrow type="MachII.framework.Property.noAccess"
			message="The 'announceEventInModule' method is not available for use in Properties." />
	</cffunction>

</cfcomponent>