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
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	name		= AUTOMATIC|[string]
- OPTIONAL ATTRIBUTES
	rows		= [numeric] 
	cols		= [numeric]
	value		= [string]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />		
	<cfset setupTag("textarea", false) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	
	<!--- Set defaults --->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.value" type="string" 
			default="#resolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
	</cfif>
	<cfparam name="attributes.name" type="string" 
		default="#attributes.path#" />

	<!--- Set required attributes--->
	<cfset setAttribute("name") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("rows") />
	<cfset setAttributeIfDefined("cols") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />
<cfelse>
	<!--- Use the value (or resolved value) if defined otherwise default to the nested content --->
	<cfif StructKeyExists(attributes, "value")>
		<cfset setContent(attributes.value, true) />
	<cfelse>
		<cfset setContent(thisTag.GeneratedContent) />
	</cfif>
	
	<cfset thisTag.GeneratedContent = doStartTag() & doEndTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />