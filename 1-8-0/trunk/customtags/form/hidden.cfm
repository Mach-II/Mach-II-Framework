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
	value		= AUTOMATIC|[string]
	type		= hidden
- OPTIONAL ATTRIBUTES 
	none
- STANDARD FORM ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/helper.cfm" />		
	<cfset setupTag("hidden", true) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	
	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.value" type="string" 
			default="#variables.bindResolver.resolvePath(attributes.path)#" />
		<cfparam name="attributes.name" type="string" 
			default="#variables.bindResolver.getNameFromPath(attributes.path)#" />
	</cfif>
	
	<!--- Set defaults --->
	<cfparam name="attributes.id" type="string" 
		default="#attributes.name#" />
	<cfparam name="attributes.value" type="string" 
		default="" />
	
	<!--- Set required attributes--->
	<cfset setAttribute("type", "hidden") />
	<cfset setAttribute("name") />
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<!--- none --->
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setEventAttributes() />
	
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />