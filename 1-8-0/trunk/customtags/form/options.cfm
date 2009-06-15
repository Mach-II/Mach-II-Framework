<cfsetting enablecfoutputonly="true" /><cfsilent>
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
	items		= [struct]|[array]
--->
<cfimport prefix="form" taglib="/MachII/customtags/form/" />

<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("options", true) />
	
	<!--- Set optional attributes --->
	<cfparam name="attributes.delimiter" type="string"
		default="," />

<cfelse>
	<!---
		In order to keep whitespace down to a minimum, a lot of 
		stuff has to stay on a single line 
	--->
	<cfif IsSimpleValue(attributes.items)>
		<cfsavecontent variable="variables.content"><cfloop list="#attributes.items#" index="i" delimiters="#attributes.delimiter#"><cfoutput><form:option value="#Trim(i)#" /></cfoutput></cfloop></cfsavecontent>
	<cfelseif IsStruct(attributes.items)>
		<cfset variables.itemOrder = StructSort(attributes.items, "text") />
		<cfsavecontent variable="variables.content"><cfloop from="1" to="#ArrayLen(variables.itemOrder)#" index="i"><cfoutput><form:option value="#LCase(variables.itemOrder[i])#" label="#attributes.items[variables.itemOrder[i]]#" /></cfoutput></cfloop></cfsavecontent>
	<cfelseif IsArray(attributes.items)>
		<cfsavecontent variable="variables.content"><cfloop from="1" to="#ArrayLen(attributes.items)#" index="i"><cfoutput><form:option value="#attributes.items[i]#" /></cfoutput></cfloop></cfsavecontent>
	<cfelse>
		<cfthrow type="MachII.customtags.form.#getTagType()#"
			message="The 'items' attribute for #getTagType()# custom tag does not support the passed datatype."
			detail="The 'items' attribute only supports lists, structs and arrays." />
	</cfif>
	
	<cfset thisTag.GeneratedContent = variables.content />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />