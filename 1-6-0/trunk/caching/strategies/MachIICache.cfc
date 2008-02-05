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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
 	displayname="MachIICache"
	extends="MachII.caching.strategies.AbstractCacheStrategy"
	output="false"
	hint="A default caching strategy.">
	
	<!---
	PROPERTIES
	--->

	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the strategy. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="flush" access="public" returntype="void" output="false">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="keyExists" access="public" returntype="boolean" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="void" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<cffunction name="getCacheStats" access="public" returntype="struct" output="false">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
</cfcomponent>