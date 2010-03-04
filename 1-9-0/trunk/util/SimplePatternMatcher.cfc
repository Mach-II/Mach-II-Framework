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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

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
	<cffunction name="isPattern" access="public" returntype="boolean" output="false"
		hint="Does the passed path have a pattern in it (i.e. '*').">
		<cfargument name="pattern" type="string" required="true" />
		<cfreturn Find("*", arguments.pattern) />
	</cffunction>
	
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
			
			<!--- JavaCast() is used for CF7 compatibility with a problem with ambiguous method overloading --->
			<cfset nextAsteriskLoc = arguments.pattern.indexOf(JavaCast("string", "*"), JavaCast("int", firstAsteriskLoc + 1)) />

			<cfif nextAsteriskLoc EQ -1>
				<cfreturn arguments.text.endsWith(arguments.pattern.substring(1)) />
			</cfif>
			
			<cfset part = pattern.substring(1, nextAsteriskLoc) />
			<cfset partIndex = arguments.text.indexOf(part) />
			
			<cfloop condition="#decidePartIndex(partIndex)#">
				<cfif doMatch(arguments.pattern.substring(nextAsteriskLoc), arguments.text.substring(partIndex + part.length()))>
					<cfreturn true />
				</cfif>
				
				<!--- JavaCast() is used for CF7 compatibility with a problem with ambiguous method overloading --->
				<cfset partIndex = arguments.text.indexOf(JavaCast("string", part),  JavaCast("int", partIndex + 1)) />
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