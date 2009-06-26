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
The algorithm that drives this CFC has been kindly ported from the 
Spring Framework (http://www.springframework.org)
--->
<cfcomponent 
	displayname="SimplePatternMatcher"
	output="false"
	hint="Performs simple pattern matchings.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="SimplePatternMatcher" output="false"
		hint="Initializes the utilty.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="match" access="public" returntype="boolean" output="false"
		hint="Performs a match of simple a pattern or array of patterns against the text.">
		<cfargument name="pattern" type="any" required="true"
			hint="A pattern or array of patterns to perform the match with." />
		<cfargument name="text" type="string" required="true"
			hint="The text to check the pattern against." />
		
		<cfset var i = 0 />
		
		<cfif IsSimpleValue(arguments.pattern)>
			<cfreturn doMatch(arguments.pattern, arguments.text) />
		<cfelseif IsArray(arguments.pattern)>
			<!--- Short-circuit to true if a pattern match is found --->
			<cfloop from="1" to="#ArrayLen(arguments.pattern)#" index="i">
				<cfif doMatch(arguments.pattern[i], arguments.text)>
					<cfreturn true />
				</cfif>
			</cfloop>
			
			<!--- No matches against any patterns found --->
			<cfreturn false />
		<cfelse>
			<cfthrow type="MachII.util.SimplePatternMatcher.invalidArgument"
				message="The passed 'pattern' argument must be a string or array." />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="doMatch" access="private" returntype="boolean" output="false"
		hint="Performs the match.">
		<cfargument name="pattern" type="string" required="true"
			hint="The pattern to perform the match with." />
		<cfargument name="text" type="string" required="true"
			hint="The text to apply the pattern against." />
		
		<cfset var firstAsteriskLoc = arguments.pattern.indexOf("*") />
		<cfset var nextAsteriskLoc = "" />
		<cfset var part = "" />
		<cfset var partIndex = "" />
		
		<!--- Zero length strings for pattern and text does not constitute a match --->
		<cfif NOT Len(arguments.pattern) AND NOT Len(arguments.text)>
			<cfreturn false />
		</cfif>
		
		<!--- Try an equals comparison if no wildcard in pattern --->
		<cfif firstAsteriskLoc EQ -1>
			<cfreturn arguments.pattern EQ arguments.text />
		</cfif>
		
		<!--- If fist asterisk is in the first position (i.e. "*test") --->
		<cfif firstAsteriskLoc EQ 0>
			<!--- If pattern is only "*" --->
			<cfif Len(arguments.pattern)  EQ 1>
				<cfreturn true />
			</cfif>
			
			<cfset nextAsteriskLoc = arguments.pattern.indexOf("*", firstAsteriskLoc + 1) />

			<cfif nextAsteriskLoc EQ -1>
				<cfreturn arguments.text.endsWith(arguments.pattern.substring(1)) />
			</cfif>
			
			<cfset part = pattern.substring(1, nextAsteriskLoc) />
			<cfset partIndex = arguments.text.indexOf(part) />
			
			<cfloop condition="#decidePartIndex(partIndex)#">
				<cfif doMatch(arguments.pattern.substring(nextAsteriskLoc), arguments.text.substring(partIndex + part.length()))>
					<cfreturn true />
				</cfif>
				
				<cfset partIndex = arguments.text.indexOf(part, partIndex + 1) />
			</cfloop>
			
			<cfreturn false />	
		</cfif>
		
		<cfreturn arguments.text.length() GTE firstAsteriskLoc 
			AND arguments.pattern.substring(0, firstAsteriskLoc) EQ arguments.text.substring(0, firstAsteriskLoc)
			AND doMatch(arguments.pattern.substring(firstAsteriskLoc), arguments.text.substring(firstAsteriskLoc)) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->	
	<cffunction name="decidePartIndex" access="private" returntype="boolean" output="false"
		hint="Decides the partIndex condition -- only used because partIndex NEQ -1 expression makes the VarsSoper barf.">
		<cfargument name="partIndex" type="numeric" required="true">
		<cfreturn arguments.partIndex NEQ -1 />
	</cffunction>
	
</cfcomponent>