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
Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0
--->
<cfcomponent 
	displayname="EventFilter"
	extends="MachII.framework.BaseComponent"
	output="false"
	hint="Base EventFilter component.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventFilter" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager of the context in which this listener belongs to." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The event-filter configure time parameters." />
		
		<cfset super.init(arguments.appManager, arguments.parameters) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean" output="false"
		hint="Override (be sure to keep the same arguments and returntype) to provide event filtering logic.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The current Event." />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="The current EventContext." />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#"
			hint="A struct of available runtime parameters." />
		
		<cfreturn true />
	</cffunction>
	
</cfcomponent>