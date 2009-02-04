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
- REQUIRED ATTRIBUTES
	value	= [numeric] value to evaluate against
	items	= [string] a list of items to use when evaluating the value
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<cfset variables.modResult = attributes.value MOD ListLen(attributes.items) />
	<cfset variables.output = "" />
	
	<cfif variables.modResult EQ 0>
		<cfset variables.output = ListGetAt(attributes.items, ListLen(attributes.items)) />
	<cfelse>
		<cfset variables.output = ListGetAt(attributes.items, variables.modResult) />
	</cfif>
	<cfoutput>#Trim(variables.output)#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />