<cfsetting enablecfoutputonly="true" /><cfsilent>
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
$Id: form.cfm 1664 2009-07-10 00:21:50Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	bind		= the path to use to bind to process this form (default to event object)

- OPTIONAL ATTRIBUTES
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />		
	<cfset setupTag("bind", false) />

	<!--- Store a reference to the original bind if available --->
	<cfif IsDefined("request._MachIIFormLib.bind")>
		<cfset variables.originalBind = request._MachIIFormLib.bind />
	</cfif>
	
	<!--- Setup the bind --->
	<cfif StructKeyExists(attributes, "target")>
		<cfset setupBind(attributes.target) />
	<cfelse>
		<cfset setupBind() />
	</cfif>
<cfelse>
	<!--- Restore the original bind --->
	<cfif StructKeyExists(variables, "originalBind")>
		<cfset request._MachIIFormLib.bind = variables.originalBind />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />