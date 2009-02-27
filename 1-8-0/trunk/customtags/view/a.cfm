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
	event	= [string] the event name to build the URL with
- OPTIONAL ATTRIBUTES
	module	= [string] the module name to build the URL with
	label	= [string] the value between the start and closing <a> tags
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("a", false) />
	
	<!--- Build url parameters --->
	<cfset variables.urlParameters = normalizeStructByNamespace("p") />
	
	<!--- Build non-standard attributes --->
	<cfset variables.nonStandardAttributes = normalizeStructByNamespace("x") />
	
	<!--- Build a route or an URL --->
	<cfif StructKeyExists(attributes, "event")>
		<cfif StructKeyExists(attributes, "module")>
			<cfset variables.href = caller.this.buildUrlToModule(attributes.module, attributes.event, variables.urlParameters) />
		<cfelse>
			<cfset variables.href = caller.this.buildUrl(attributes.event, variables.urlParameters) />
		</cfif>
	<cfelseif StructKeyExists(attributes, "route")>
		<!--- Build query string parameters --->
		<cfset variables.queryStringParameters = normalizeStructByNamespace("q") />
		
		<cfset variables.href = caller.this.buildRoute(attributes.route, variables.urlParameters, variables.queryStringParameters) />
	<cfelse>
		<cfthrow type="MachII.customtags.view.a.noEventOrRoute"
			message="The 'a' tag must have an attribute named 'event' or 'route'." />
	</cfif>
	
	<!--- Set required attributes--->
	<cfset setAttribute("href", variables.href) />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("charset") />
	<cfset setAttributeIfDefined("coords") />
	<cfset setAttributeIfDefined("hreflang") />
	<cfset setAttributeIfDefined("name") />
	<cfset setAttributeIfDefined("rel") />
	<cfset setAttributeIfDefined("rev") />
	<cfset setAttributeIfDefined("shape") />
	<cfset setAttributeIfDefined("target") />
	<cfset setAttributeIfDefined("type") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setEventAttributes() />
	
	<!--- Set non-standard attributes --->
	<cfset setAttributes(variables.nonStandardAttributes) />
	
	<cfoutput>#doStartTag()#</cfoutput>
<cfelse>
	<cfif StructKeyExists(attributes, "label")>
		<cfset thisTag.GeneratedContent = HTMLEditFormat(attributes.label) />
	</cfif>
	
	<cfoutput>#doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />