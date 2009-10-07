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
	<cfset ensureOneByNameList("src,event,route") />
	
	<!--- If the src is not present, then make an URL using event/module/route --->
	<cfif NOT StructKeyExists(attributes, "src")>
		<cfset attributes.src = makeUrl() />
	</cfif>
	
	<!--- Setup optional but requried by the addImage() API --->
	<cfparam name="attributes.width" type="string" 
		default="" />
	<cfparam name="attributes.height" type="string" 
		default="" />
	<cfparam name="attributes.alt" type="string" 
		default="" />
	
	<!---
		Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes
		Normalized namespaced attributes have already been removed.
	--->
	<cfset variables.additionalAttributes = StructNew() />
	<cfset StructAppend(variables.additionalAttributes, attributes) />
	<cfset StructDelete(variables.additionalAttributes, "src", "false") />
	<cfset StructDelete(variables.additionalAttributes, "width", "false") />
	<cfset StructDelete(variables.additionalAttributes, "height", "false") />
	<cfset StructDelete(variables.additionalAttributes, "alt", "false") />
	<cfset StructDelete(variables.additionalAttributes, "output", "false") />
	<cfset StructDelete(variables.additionalAttributes, "event", "false") />
	<cfset StructDelete(variables.additionalAttributes, "module", "false") />
	<cfset StructDelete(variables.additionalAttributes, "route", "false") />
	<cfset StructDelete(variables.additionalAttributes, "p", "false") />
	<cfset StructDelete(variables.additionalAttributes, "q", "false") />
	
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addImage(attributes.src, attributes.width, attributes.height, attributes.alt, variables.additionalAttributes) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />