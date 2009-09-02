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
	src		= [string] The path or the shortcut to the image
	alt		= [string] The alternative text for the image (if not defined this is included)
- OPTIONAL ATTRIBUTES (BUT REQUIRED BY THE API)
	width	= [string|numeric|null] The width of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used.
	height	= [string|numeric|null] The height of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used.
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("img", true) />
	
	<!--- Setup required --->
	<cfset ensureByName("src")>
	<cfset variables.path = attributes.src />
	
	<!--- Setup optional but requried by the addImage() API --->
	<cfif StructKeyExists(attributes, "width")>
		<cfset variables.width = attributes.width />
	<cfelse>
		<cfset variables.width = "" />
	</cfif>
	<cfif StructKeyExists(attributes, "height")>
		<cfset variables.height = attributes.height />
	<cfelse>
		<cfset variables.height = "" />
	</cfif>
	<cfif StructKeyExists(attributes, "alt")>
		<cfset variables.alt = attributes.alt />
	<cfelse>
		<cfset variables.alt = "" />
	</cfif>
	
	<!--- Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes --->
	<cfset variables.additionalAttributes = StructNew() />
	<cfset StructAppend(variables.additionalAttributes, attributes) />
	<cfset StructDelete(variables.additionalAttributes, "src", "false") />
	<cfset StructDelete(variables.additionalAttributes, "width", "false") />
	<cfset StructDelete(variables.additionalAttributes, "height", "false") />
	<cfset StructDelete(variables.additionalAttributes, "alt", "false") />
	<cfset StructDelete(variables.additionalAttributes, "output", "false") />
	
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addImage(variables.path, variables.width, variables.height, variables.alt, variables.additionalAttributes) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />