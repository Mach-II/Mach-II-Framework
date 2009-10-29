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
	actionEvent		= name of event to process this form

- OPTIONAL ATTRIBUTES
	actionModule	= name of module to use with the event to process this form
	actionUrlParams	= name value pairs in pipe (|) list of url params or struct
	encType			= specifies the encType of the form (defaults to "multipart/form-data")
	method			= specifies the type of form post to make (defaults to "post")
	bind			= the path to use to bind to process this form (default to event object)
--->
</cfsilent>
<cfif thisTag.ExecutionMode IS "start">
	<cfsilent>

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("form", false) />
	
	<!--- Setup the bind --->
	<cfif StructKeyExists(attributes, "bind")>
		<cfset setupBind(attributes.bind) />
	<cfelse>
		<cfset setupBind() />
	</cfif>
	
	<!--- Setup the base for the auto focus --->
	<cfset request._MachIIFormLib.firstElementId = "" />

	<!--- Set defaults --->
	<cfparam name="attributes.encType" type="string" 
		default="multipart/form-data" />
	<cfparam name="attributes.method" type="string" 
		default="post" />
	<cfparam name="attributes.autoFocus" type="string"
		default="" />

	<cfset setAttribute("action", makeUrl("actionEvent", "actionModule", "actionRoute", "actionUrlParams")) />
	<cfset setAttribute("method") />
	<cfset setAttribute("encType") />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("name") />
	<cfset setAttributeIfDefined("target") />
	<cfset setAttributeIfDefined("accept") />
	<cfset setAttributeIfDefined("accept-charset") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />
	
	<!--- Add event attributes specific to form tag --->
	<cfset setAttributeIfDefined("onsubmit") />
	<cfset setAttributeIfDefined("onreset") />
	
	</cfsilent>
	<cfoutput>#doStartTag()#</cfoutput>
<cfelse>

	<cfimport prefix="view" taglib="/MachII/customtags/view" />

	<!--- Clean up bind as this serves as a "check" by other tags to ensure bind is available --->
	<cfset StructDelete(request, "_MachIIFormLib.bind", false) />
	<cfset StructDelete(request, "_MachIIFormLib.firstElementId", false) />
	
	<cfoutput>#doEndTag()#</cfoutput>
	<cfif NOT IsBoolean(attributes.autoFocus) OR (IsBoolean(attributes.autoFocus) AND attributes.autoFocus)>
		
		<!--- Figure out which id to auto focus to if there is no id supplied --->
		<cfif NOT Len(attributes.autoFocus)>
			<cfset attributes.autoFocus = request._MachIIFormLib.firstElementId />
		</cfif>
		
		<cfoutput><view:script outputType="inline">
			if (window.MachIIFormLib_autoFocusOccurred !== 'undefined') {
				document.getElementById('#attributes.autoFocus#').focus();
				MachIIFormLib_autoFocusOccurred = true;
			}
		</view:script></cfoutput>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />