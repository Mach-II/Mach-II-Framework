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
	src			= [string|list|array] A single string, comma-delimited list or array of web accessible hrefs to .js files.
	outputType	= [string] Indicates the output type for the generated HTML code (head, inline).
	
External files are *always* outputted inline first or appended to the head first before
any inline javascript code.
--->

<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("script", false) />

	<!--- Setup defaults --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
		
	<!--- Set required attributes--->
	<cfset setAttribute("type", "text/javascript") />

<cfelse>
	<!--- Setup generation variables --->
	<cfset variables.bodyContent = Trim(thisTag.GeneratedContent) />
	<cfset thisTag.GeneratedContent = "" />

	<!--- For external files --->
	<cfif StructKeyExists(attributes, "src")>
		<cfif attributes.outputType EQ "head">
			<cfset locateHtmlHelper().addJavascript(attributes.src, attributes.outputType) />
		<cfelse>
			<cfset thisTag.GeneratedContent = locateHtmlHelper().addJavascript(attributes.src, attributes.outputType) />
		</cfif>
	</cfif>
	
	<!--- For body content --->
	<cfif Len(variables.bodyContent)>
		<cfset setContent(Chr(13) & '//<![CDATA[' & Chr(13) & variables.bodyContent & Chr(13) & '//]]>' & Chr(13)) />
		
		<cfset variables.js = doStartTag() & doEndTag() />

		<cfif attributes.outputType EQ "head">
			<cfset caller.this.addHTMLHeadElement(variables.js) />
		<cfelse>
			<cfset thisTag.GeneratedContent = thisTag.GeneratedContent & variables.js />
		</cfif>
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />