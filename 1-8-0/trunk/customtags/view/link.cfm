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
	type		= The type of link. Supports type shortcuts 'icon', 'rss', 'atom' and 'html', otherwise a complete MIME type is required.
	href		= The href of the link tag.
- OPTIONAL ATTRIBUTES
	outputType	= Indicates the output type for the generated HTML code ('head', 'inline'). Link tags must be in the HTML head section according to W3C specification. Use the value of inline with caution.
	
N.B. Links to CSS files should use the <style> tag's "src" attribute.
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("link", true) />
	
	<!--- Setup required --->
	<cfset ensureOneByNameList("href,event,route") />
	<cfset ensureByName("type") />
	
	<!--- If the href is not present, then make an URL using event/module/route --->
	<cfif NOT StructKeyExists(attributes, "href")>
		<cfset attributes.href = makeUrl() />
	</cfif>
	
	<!--- Setup optional --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
		
	<!---
		Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes
		Normalized namespaced attributes have already been removed.
	--->
	<cfset variables.additionalAttributes = StructNew() />
	<cfset StructAppend(variables.additionalAttributes, attributes) />
	<cfset StructDelete(variables.additionalAttributes, "href", "false") />
	<cfset StructDelete(variables.additionalAttributes, "type", "false") />
	<cfset StructDelete(variables.additionalAttributes, "outputType", "false") />
	<cfset StructDelete(variables.additionalAttributes, "output", "false") />
	<cfset StructDelete(variables.additionalAttributes, "event", "false") />
	<cfset StructDelete(variables.additionalAttributes, "module", "false") />
	<cfset StructDelete(variables.additionalAttributes, "route", "false") />
	<cfset StructDelete(variables.additionalAttributes, "p", "false") />
	<cfset StructDelete(variables.additionalAttributes, "q", "false") />
	
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addLink(attributes.type, attributes.href, variables.additionalAttributes, attributes.outputType) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />