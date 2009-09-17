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
- OPTIONAL ATTRIBUTES
	outputType	= [string] outputs the code to "head" or "inline"
	media = [string] specifies styles for different media types
	forIEVersion = [string] wraps an IE conditional comment around the incoming code
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("style", false) />

	<!--- Setup defaults --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
	<cfparam name="attributes.forIEVersion" type="string" 
		default="" />
		
	<!--- Set required attributes--->
	<cfset setAttribute("type", "text/css") />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("media") />
	
	<!--- Set standard attributes --->
	<cfset setStandardAttributes() />
		
<cfelse>
	<!--- Setup generation variables --->
	<cfset variables.bodyContent = Trim(thisTag.GeneratedContent) />
	<cfset thisTag.GeneratedContent = "" />
	
	<!--- Ensure attributes if no body content --->
	<cfif NOT Len(variables.bodyContent)>
		<cfset ensureByName("href") />
	</cfif>
	
	<!--- For external files --->
	<cfif StructKeyExists(attributes, "href")>
	
		<!--- Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes --->
		<cfset variables.additionalAttributes = StructNew() />
		<cfset StructAppend(variables.additionalAttributes, attributes) />
		<cfset StructDelete(variables.additionalAttributes, "href", "false") />
		<cfset StructDelete(variables.additionalAttributes, "forIEVersion", "false") />
		<cfset StructDelete(variables.additionalAttributes, "output", "false") />
		<cfset StructDelete(variables.additionalAttributes, "outputType", "false") />

		<cfif attributes.outputType EQ "head">
			<cfset locateHtmlHelper().addStylesheet(attributes.href, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
		<cfelse>
			<cfset thisTag.GeneratedContent = locateHtmlHelper().addStylesheet(attributes.href, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
		</cfif>
	</cfif>
	
	<!--- For body content --->
	<cfif Len(variables.bodyContent)>
		<cfset setContent(Chr(13) & '/* <![CDATA[ */' & Chr(13) & variables.bodyContent & Chr(13) & '/* ]]> */' & Chr(13)) />
		
		<cfset variables.styles = doStartTag() & doEndTag() />
		
		<!--- Wrap in an IE conditional if defined --->
		<cfif Len(attributes.forIEVersion)>
			<cfset variables.styles = wrapIEConditionalComment(attributes.forIEVersion, variables.styles) />
		</cfif>

		<cfif attributes.outputType EQ "head">
			<cfset caller.this.addHTMLHeadElement(variables.styles) />
			<cfset thisTag.GeneratedContent = "" />
		<cfelse>
			<cfset thisTag.GeneratedContent = this.GeneratedContent & variables.styles />
		</cfif>	
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />