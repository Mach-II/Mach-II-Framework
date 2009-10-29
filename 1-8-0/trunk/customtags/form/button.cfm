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
Author: Matt Woodward (matt@mach-ii.com)
$Id:  $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	name		= AUTOMATIC|[string]
	value		= AUTOMATIC|[string]
- OPTIONAL ATTRIBUTES
	type 	 	= button|reset|submit|[submit]
	src 		= string|[null]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />


	<!--- if there's a src attribute provided and the type is anything other than 
			submit, throw an error --->
	<cfif StructKeyExists(attributes, "src")>
		<cfif StructKeyExists(attributes, "type") AND 
				CompareNoCase(attributes.type, "submit") neq 0>
			<cfthrow type="MachII.customtags.form.button" 
					message="The 'src' attribute may only be used with a button of type 'submit'" 
					detail="When using the 'src' attribute to provide an image to be used as a button, the button must be a submit button. Types of 'button' and 'reset' are not supported with an image input." />
		<cfelse>
			<cfset attributes.type = "image" />
		</cfif>
	</cfif>
	
	<cfset setupTag("input", true) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	
	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.value" type="string" 
			default="#wrapResolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "" />
	</cfif>
	
	<!--- Set defaults --->
	<cfparam name="attributes.name" type="string" 
		default="#attributes.path#" />
	<cfparam name="attributes.id" type="string" 
		default="#attributes.name#" />
	<cfparam name="attributes.value" type="string" 
		default="" />
	<cfparam name="attributes.type" type="string" 
		default="submit" />
			
	<!--- if this is an image input and they don't provide an alt attribute, 
			use value as alt --->
	<cfif attributes.type eq "image" and NOT StructKeyExists(attributes, "alt")>
		<cfset attributes.alt = attributes.value />
	</cfif>
	
	<!--- Set required attributes--->
	<cfset setAttribute("name") />
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("alt") />
	<cfset setAttributeIfDefined("disabled", "disabled") />
	<cfset setAttributeIfDefined("src") />
	<cfset setAttributeIfDefined("type") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />

<cfelse>	
	<cfset thisTag.generatedContent =  doStartTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />