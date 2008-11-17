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
	actionEvent		= name of event to process this form

- OPTIONAL ATTRIBUTES
	actionModule	= name of module to use with the even to process this form
	actionUrlParams	= name value pairs in pipe (|) list of url params or struct
	encType			= specifies the encType of the form (defaults to "multipart/form-data")
	method			= specifies the type of form post to make (defaults to "post")
	bind			= specifies the name of the event arg to try to bind to (default to event object)
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/helper.cfm" />	
	<cfset setupFormTag() />

	<!--- Set defaults --->
	<cfparam name="attributes.actionUrlParams" type="any" 
		default="#StructNew()#" />
	<cfparam name="attributes.encType" type="string" 
		default="multipart/form-data" />
	<cfparam name="attributes.method" type="string" 
		default="post" />
	
	<!--- Set required attributes--->
	<cfif NOT StructKeyExists(attributes, "actionModule")>
		<cfset setAttribute("action", caller.this.buildUrl(attributes.actionEvent, attributes.actionUrlParams)) />
	<cfelse>
		<cfset setAttribute("action", caller.this.buildUrlToModule(attributes.actionModule, attributes.actionEvent, attributes.actionUrlParams)) />
	</cfif>
	<cfset setAttribute("method") />
	<cfset setAttribute("encType") />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("name") />
	<cfset setAttributeIfDefined("target") />
	<cfset setAttributeIfDefined("accept") />
	<cfset setAttributeIfDefined("accept-charset") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setEventAttributes() />
		
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
<cfelse>
	<cfoutput>#variables.tagWriter.doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />