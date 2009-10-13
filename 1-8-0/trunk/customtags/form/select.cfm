<cfprocessingdirective  suppresswhitespace="true"><cfsetting enablecfoutputonly="true" /><cfsilent>
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
	name		= AUTOMATIC|[string]
	type		= select
- OPTIONAL ATTRIBUTES
	disabled	= disabled|[null]
	size		= [numeric]
	checkValue	= [string]|[null]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />		
	<cfset setupTag("select", false) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
		
	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.checkValue" type="string" 
			default="#resolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
		<cfparam name="attributes.checkValue" type="string" 
			default="" />
	</cfif>
	
	<!--- Set defaults --->
	<cfparam name="attributes.name" type="string" 
		default="#attributes.path#" />
	<cfparam name="attributes.id" type="string" 
		default="#attributes.name#" />
	<cfparam name="attributes.delimiter" type="string"
		default="," />
	
	<!--- Syncronize check value for option tag --->
	<cfset request._MachIIFormLib.selectCheckValue = attributes.checkValue />
	
	<!--- Set required attributes--->
	<cfset setAttribute("name") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("size") />
	<cfset setAttributeIfDefined("multiple", "multiple") />
	<cfset setAttributeIfDefined("disabled", "disabled") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />
	
<cfelse>
	<!--- Create a crazy outbuffer struct  so we can pass by reference --->
	<cfset variables.outputBuffer = StructNew() />
	<cfset variables.outputBuffer.content = "" />

	<cfif StructKeyExists(attributes, "items")>
		<form:options attributeCollection="#attributes#"
			output="true" 
			outputBuffer="#variables.outputBuffer#"/>
		<cfset variables.outputBuffer.content = Chr(13) & variables.outputBuffer.content />
	</cfif>
	
	<!--- Any options generated from items are append at the end of any nested option tags --->
	<cfset setContent(thisTag.GeneratedContent & variables.outputBuffer.content) />
	
	<cfset thisTag.GeneratedContent = doStartTag() & doEndTag() />
</cfif>
</cfsilent></cfprocessingdirective><cfsetting enablecfoutputonly="false" />