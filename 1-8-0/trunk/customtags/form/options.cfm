<cfsetting enablecfoutputonly="true" />
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
- REQUIRED ATTRIBUTES
	items		= [struct]|[array]
--->
<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("options", true) />

	<cfif IsStruct(attributes.items)>
		<cfset variables.itemOrder = StructSort(attributes.items, "text") />
		
		<cfloop from="1" to="#ArrayLen(variables.itemOrder)#" index="i">
			<cfoutput><form:option value="#variables.itemOrder[i]#" label="#attributes.items[variables.itemOrder[i]]#" /></cfoutput>
		</cfloop>
	<cfelseif IsArray(attributes.items)>
		<cfloop from="1" to="#ArrayLen(attributes.items)#" index="i">
			<cfoutput><form:option value="#attributes.items[i]#" /></cfoutput>
		</cfloop>		
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />