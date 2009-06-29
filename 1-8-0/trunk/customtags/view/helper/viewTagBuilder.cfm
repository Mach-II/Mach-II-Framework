<cfsilent>
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
Concrete tag builder for the Mach-II view tag library inherits from base builder.
--->

<cfinclude template="/MachII/customtags/baseTagBuilder.cfm" />

<!---
PROPERTIES
--->
<cfset setTagLib("view") />

<!---
PUBLIC FUNCTIONS
--->
<cffunction name="wrapIEConditionalComment" access="private" returntype="string" output="false"
	hint="Wraps an IE conditional comment around the incoming code.">
	<cfargument name="forIEVersion" type="string" required="true" />
	<cfargument name="code" type="string" required="true" />
	
	<cfset var conditional = Trim(arguments.forIEVersion) />
	<cfset var comment = Chr(13) />
	
	<!--- "all" in the version means all versions of IE --->
	<cfif conditional EQ "all">
		<cfset comment = comment & "<!--[if IE]>" & Chr(13) />
	<!--- No operator (just version number) means EQ for version --->
	<cfelseif IsNumeric(conditional)>
		<cfset comment = comment & "<!--[if IE " & conditional &  "]>" & Chr(13)  />
	<!--- Use operator and version --->
	<cfelseif ListLen(conditional, " ") EQ 2>
		<cfset comment = comment & "<!--[if " & ListFirst(conditional, " ") & " IE " & ListLast(conditional, " ") &  "]>" & Chr(13)  />
	<!--- Throw an exception because of no match for conditional --->
	<cfelse>
		<cfthrow type="MachII.customtags.view.invalidIEConditional"
			message="An IE conditional of '#conditional#' is invalid."
			detail="The conditional value must be 'all', IE version number (numeric) or operator (lt, gte) plus IE version number." />
	</cfif>
	
	<!--- Append the code --->
	<cfset comment = comment & arguments.code & Chr(13) & "<![endif]-->" & Chr(13) />

	<cfreturn comment />
</cffunction>
</cfsilent>