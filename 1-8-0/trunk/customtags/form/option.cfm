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
	value		= [string]
- OPTIONAL ATTRIBUTES
	disabled	= disabled|[null]
	selected	= selected|[null]
	label		= [string]
- STANDARD FORM ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/helper.cfm" />		
	<cfset setupTag("option", false) />	

	<!--- Set data --->
	<cfset attributes.checkValue = request._MachIIFormLib.selectCheckValue />
	
	<!--- Set defaults --->
	<cfparam name="attributes.id" type="string"
		default="#getParentTagAttribute("select", "id")#_#replaceSpaces(attributes.value)#" />
	<cfparam name="attributes.label" type="string"  
		default="#attributes.value#" />
	
	<!--- Set required attributes--->
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<cfif ListFindNoCase(attributes.checkValue, attributes.value)>
		<cfset setAttribute("selected", "selected") />
	<cfelse>
		<cfset setAttributeIfDefined("selected", "selected") />
	</cfif>
	<cfset setAttributeIfDefined("disabled", "disabled") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setEventAttributes() />
	
	<cfoutput>#doStartTag()#</cfoutput>
<cfelse>
	<cfif NOT Len(thisTag.GeneratedContent)>
		<!--- Put a non-breaking space if value is nothing so it does not break validation --->
		<cfif NOT Len(attributes.label)>
			<cfset thisTag.GeneratedContent = "&nbsp;" />
		<cfelse>
			<cfset setContent(attributes.label) />
		</cfif>
	</cfif>
	<cfoutput>#doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />