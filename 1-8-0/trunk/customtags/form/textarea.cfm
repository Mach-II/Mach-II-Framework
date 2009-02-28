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
	name		= AUTOMATIC|[string]
- OPTIONAL ATTRIBUTES
	rows		= [numeric] 
	cols		= [numeric]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />		
	<cfset setupTag("textarea", true) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	
	<!--- Set defaults --->
	<cfparam name="attributes.path" type="string" 
		default="" />
	<cfparam name="attributes.name" type="string" 
		default="#attributes.path#" />

	<!--- Set required attributes--->
	<cfset setAttribute("name") />
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("rows") />
	<cfset setAttributeIfDefined("cols") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />

	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
<cfelse>
	<!--- Add content of text area if bindable --->
	<cfif StructKeyExists(attributes, "path")>
		<cfset thisTag.GeneratedContent = resolvePath(attributes.path) />
	</cfif>
	
	<cfset setContent(thisTag.GeneratedContent) />
	<cfoutput>#doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />