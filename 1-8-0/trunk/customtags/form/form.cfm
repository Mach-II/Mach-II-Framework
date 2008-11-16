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
REQUIRED ATTRIBUTES
- 'actionEvent'

OPTIONAL ATTRIBUTES
- 'actionModule'
- 'actionUrlParams'
- 'encType' specifies the encType of the form
	default: multipart/form-data
- 'method' specifies the type of form post to make (allowed values: post, get)
	default: post
- 'bind' specifies the name of the object in the event object to bind the form to
--->
<!--- This tag requires an end tag --->
<cfif NOT thisTag.hasEndTag>
	<cfthrow type="MachII.FormLib.form.noEndTag"
		message="This tag must have an end tag." />
</cfif>

<cfif thisTag.ExecutionMode IS "start">
	<cfsilent>
		<!--- Check for required attributes --->
		<cfif NOT StructKeyExists(attributes, "actionEvent")>
			<cfthrow type="lightpost.cftags.from.form.noActionEvent"
				message="This tag must have an attribute named 'actionEvent'." />
		</cfif>
		
		<!--- Set defaults --->
		<cfparam name="attributes.actionUrlParams" type="any" default="#StructNew()#" />
		<cfparam name="attributes.encType" type="string" default="multipart/form-data" />
		<cfparam name="attributes.method" type="string" default="post" />
		
		<!--- Set up required data --->
		<cfif NOT StructKeyExists(attributes, "actionModule")>
			<cfset attributes.action = caller.this.buildUrl(attributes.actionEvent, attributes.actionUrlParams) />
		<cfelse>
			<cfset attributes.action = caller.this.buildUrlToModule(attributes.actionModule, attributes.actionEvent, attributes.actionUrlParams) />
		</cfif>

		<cfset request._MachIIFormLib.bind = request.event />
		
		<cfif StructKeyExists(attributes, "bind") AND IsSimpleValue(attributes.bind)>
			<cfif request.event.isArgDefined(ListFirst(attributes.bind, "."))>
				<cfset variables.bindResolver = CreateObject("component", "cfcs.BindResolver").init() />
				<cfset request._MachIIFormLib.bind = variables.bindResolver.resolvePath(attributes.bind) />
			<cfelse>
				<cfthrow type="lightpost.cftags.form.form.noBindInEvent"
					message="A bind named '#attributes.bind#' is not available the event." />
			</cfif>
		</cfif>
		
		<!--- Create a tag writer and set atrributes--->
		<cfset variables.tagWriter = CreateObject("component", "cfcs.TagWriter").init("form") />
		<cfset variables.tagWriter.setAttribute("action", attributes.action) />
		<cfset variables.tagWriter.setAttribute("method", attributes.method) />
		<cfset variables.tagWriter.setAttribute("encType", attributes.encType) />
		<cfif StructKeyExists(attributes, "id")>
			<cfset variables.tagWriter.setAttribute("id", attributes.id) />
		</cfif>
	</cfsilent>
	<cfoutput>#variables.tagWriter.doStartTag()#</cfoutput>
<cfelse>
	<cfoutput>#variables.tagWriter.doEndTag()#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />