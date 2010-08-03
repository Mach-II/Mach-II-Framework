<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License s distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="RegExListener" 
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for RegEx tool.">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="processRegex" access="public" returntype="array" output="false"
		hint="Process RegEx form post.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var type = arguments.event.getArg("type") />
		<cfset var input = arguments.event.getArg("input") />
		<cfset var patterns = ArrayNew(1) />
		<cfset var replaces = ArrayNew(1) />
		<cfset var caseSensitive = arguments.event.getArg("caseSensitive") />
		<cfset var results = "" />
		
		<cfset patterns[1] = arguments.event.getArg("pattern1") />
		<cfset patterns[2] = arguments.event.getArg("pattern2") />
		<cfset patterns[3] = arguments.event.getArg("pattern3") />
		
		<cfset replaces[1] = arguments.event.getArg("replace1") />
		<cfset replaces[2] = arguments.event.getArg("replace2") />
		<cfset replaces[3] = arguments.event.getArg("replace3") />

		
		<cfif type EQ "refind">
			<cfset results = processREFind(input, patterns, caseSensitive) />
		<cfelseif type EQ "rereplace">
			<cfset results = processREReplace(input, patterns, replaces, caseSensitive) />
		</cfif>
		
		<cfreturn results />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="processREFind" access="public" returntype="array" output="false"
		hint="Process REFind form post.">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="patterns" type="array" required="true" />
		<cfargument name="caseSensitive" type="boolean" required="true" />
		
		<cfset var results = ArrayNew(1) />
		<cfset var i = 0 />
		<cfset var pos = 1 />
		<cfset var inputLen = Len(arguments.input) />
		<cfset var temp = "" />
		<cfset var matches = "" />
		<cfset var result = StructNew() />
		
		<cfloop from="1" to="3" index="i">
			<cfset matches = ArrayNew(1) />
			<cfif Len(arguments.patterns[i])>
				<cfloop condition="pos LTE inputLen">
					<cfif arguments.caseSensitive>
						<cfset temp = REFInd(arguments.patterns[i], arguments.input, pos, true) />
					<cfelse>
						<cfset temp = REFIndNoCase(arguments.patterns[i], arguments.input, pos, true) />
					</cfif>

					<cfif temp.pos[1] NEQ 0>
						<cfset result = StructNew() />
						<cfset result.position = temp.pos[1] />
						<cfset result.length = temp.len[1] />
						<cfset result.text = arguments.input.substring(result.position -1, result.position -1 + result.length) />
						
						<cfset ArrayAppend(matches, result) />
						<cfset pos = result.position + result.length />
					<cfelse>
						<cfbreak />
					</cfif>
				</cfloop>
				<cfset results[i] = matches />
			<cfelse>
				<cfset results[i] = ArrayNew(1) />
			</cfif>
		</cfloop>
		
		<cfreturn results />
	</cffunction>

	<cffunction name="processREReplace" access="public" returntype="array" output="false"
		hint="Process REFind form post.">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="patterns" type="array" required="true" />
		<cfargument name="replaces" type="array" required="true" />
		<cfargument name="caseSensitive" type="boolean" required="true" />
		
		<cfset var results = ArrayNew(1) />
		<cfset var i = 0 />
		
		<cfloop from="1" to="3" index="i">
			<cfif Len(arguments.patterns[i])>
				<cfif arguments.caseSensitive>
					<cfset results[i] = REReplace(arguments.input, arguments.patterns[i], arguments.replaces[i], "all") />
				<cfelse>
					<cfset results[i] = REReplaceNoCase(arguments.input, arguments.patterns[i], arguments.replaces[i], "all") />
				</cfif>
			<cfelse>
				<cfset results[i] = "" />
			</cfif>
		</cfloop>
		
		<cfreturn results />
	</cffunction>
</cfcomponent>