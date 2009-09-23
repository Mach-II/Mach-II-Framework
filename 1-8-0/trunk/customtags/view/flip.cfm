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
	value	= [numeric] value to evaluate against
	items	= [string] a list of items to use when evaluating the value
--->
<cfif thisTag.ExecutionMode IS "end">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("flip", true) />

	<!--- Setup required --->
	<cfset ensureByName("value") />
	<cfset ensureByName("items", "Must be a list or an array.") />

	<!--- Convert a "string" boolean to a number --->
	<cfset attributes.value = booleanize(attributes.value, "value") />
	
	<!--- Convert items array to list --->
	<cfif IsSimpleValue(attributes.items)>
		<cfset attributes.items = ListToArray(attributes.items) />
	</cfif>
	
	<!--- We can't zebra stripe if there is only one item so assume nothing for the second item --->
	<cfif ArrayLen(attributes.items) EQ 1>
		<cfset ArrayAppend(attributes.items, "") />
	</cfif>
	
	<cfset variables.modResult = attributes.value MOD ArrayLen(attributes.items) />
	<cfset variables.output = "" />
	
	<cfif variables.modResult EQ 0>
		<cfset variables.output = attributes.items[ArrayLen(attributes.items)] />
	<cfelse>
		<cfset variables.output = attributes.items[variables.modResult] />
	</cfif>
	
	<cfset thisTag.GeneratedContent = Trim(variables.output) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />