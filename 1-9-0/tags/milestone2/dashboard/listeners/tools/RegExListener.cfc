<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

	As a special exception, the copyright holders of this library give you
	permission to link this library with independent modules to produce an
	executable, regardless of the license terms of these independent
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

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