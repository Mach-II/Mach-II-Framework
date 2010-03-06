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
The algorithm that drives this CFC has been kindly barrowed from Apache 
Ant (http://ant.apache.org) and the Spring Framework (http://www.springframework.org)
--->
<cfcomponent
	displayname="AntPathMatcher"
	output="false"
	hint="Provides path matching using ANT style path selectors.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.DEFAULT_PATH_SEPARATOR = "/" />
	<cfset variables.pathSeparator = variables.DEFAULT_PATH_SEPARATOR />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AntPathMatcher" output="false"
		hint="Initializes the path pattern matcher.">
		<cfargument name="pathSeparator" type="string" required="false" />
		
		<cfif StructKeyExists(arguments, "pathSeparator")>
			<cfset setPathSeparator(arguments.pathSeparator) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="isPattern" access="public" returntype="boolean" output="false"
		hint="Does the passed path have a pattern in it (i.e. contains one or more of '?' and/or '*').">
		<cfargument name="pattern" type="string" required="true" />
		<cfreturn Find("*", arguments.pattern) OR Find("?", arguments.pattern) />
	</cffunction>
	
	<cffunction name="match" access="public" returntype="boolean" output="false"
		hint="Matches the passed path against the pattern according to the matching strategy.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfreturn doMatch(arguments.pattern, arguments.path, true) />
	</cffunction>
	
	<cffunction name="matchStart" access="public" returntype="boolean" output="false"
		hint="Match the given path against the corresponding part of the given pattern according 
			to the matching strategy. Determines whether the pattern at least matches as far as the 
			given base path goes, assuming that a full path may then match as well.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfreturn doMatch(arguments.pattern, arguments.path, false) />
	</cffunction>
	
	<cffunction name="extractPathWithinPattern" access="public" returntype="string" output="false"
		hint="Given a pattern and a full path, determine the pattern-mapped part.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		
		<cfset var patternParts = ListToArray(arguments.pattern, getPathSeparator()) />
		<cfset var pathParts = ListToArray(arguments.path, getPathSeparator()) />
		<cfset var part = "" />
		<cfset var puts = 0 />
		<cfset var i = 0 />
		<cfset var pathSeparator = getPathSeparator() />
		<cfset var result = CreateObject("java", "java.lang.StringBuffer") />

		<!--- Add any path parts that have a wildcarded pattern part --->
		<cfloop from="1" to="#ArrayLen(patternParts)#" index="i">
			<cfset part = patternParts[i] />
			<cfif (Find("*", part) OR Find("?", part)) AND ArrayLen(pathParts) GTE i>
				<cfif puts GT 0 OR (i EQ 1 AND NOT Left(arguments.pattern, 1) EQ pathSeparator)>
					<cfset result.append(pathSeparator) />
				</cfif>
				<cfset result.append(pathParts[i]) />
				<cfset puts = puts + 1 />
			</cfif>
		</cfloop>

		<!--- Append any trailing path parts --->
		<cfloop from="#ArrayLen(patternParts) + 1#" to="#ArrayLen(pathParts)#" index="i">
			<cfif puts GT 0 OR i GT 1>
				<cfset result.append(pathSeparator) />
			</cfif>
			<cfset result.append(pathParts[i]) />
		</cfloop>

		<cfreturn result.toString() />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="doMatch" access="private" returntype="boolean" output="false"
		hint="Performs a match against the given path against the given pattern.">
		<cfargument name="pattern" type="string" required="true"
			hint="The pattern to perform the match with." />
		<cfargument name="path" type="string" required="true"
			hint="The string in which apply the pattern against." />
		<cfargument name="fullMatch" type="boolean" required="true"
			hint="Whether a full pattern match is required">
		
		<cfset var patternDirectory = "" />
		<cfset var patternTemp = -1 />
		<cfset var patternDirectories = ArrayNew(1) />
		<cfset var pathDirectories = ArrayNew(1) />
		<cfset var patternStart = 1 />
		<cfset var patternEnd = "" />
		<cfset var pathStart = 1 />
		<cfset var pathEnd = "" />
		<cfset var patternLength = "" />
		<cfset var stringLength = "" />
		<cfset var foundIdx = -1 />
		<cfset var subPattern = "" />
		<cfset var subString = "" />
		<cfset var pathSeparator = getPathSeparator() />
		<cfset var continueOutterLoop = false />
		<cfset var continueInnerLoop = false />
		<cfset var i = 1 />
		<cfset var j = 1 />
		
		<cfif arguments.path.startsWith(pathSeparator) NEQ arguments.pattern.startsWith(pathSeparator)>
			<cfreturn false />
		</cfif>
		
		<!--- ListToArray may have problems with some path separators --->
		<cfset patternDirectories = ListToArray(arguments.pattern, pathSeparator) />
		<cfset pathDirectories = ListToArray(arguments.path, pathSeparator) />
		<cfset patternEnd = ArrayLen(patternDirectories) />
		<cfset pathEnd = ArrayLen(pathDirectories) />
		
		<!--- Match all elements up to the first ** --->
		<cfloop condition="patternStart LTE patternEnd AND pathStart LTE pathEnd">
			<cfset patternDirectory = patternDirectories[patternStart] />
			<cfif patternDirectory EQ '**'>
				<cfbreak />
			</cfif>
			<cfif NOT matchStrings(patternDirectory, pathDirectories[pathStart])>
				<cfreturn false />
			</cfif>
			<cfset patternStart = patternStart + 1 />
			<cfset pathStart = pathStart + 1 />
		</cfloop>

		<!--- Path is exhausted, only match if rest of pattern is * or **'s --->		
		<cfif pathStart GT pathEnd>

			<cfif patternStart GT patternEnd>
				<cfif arguments.pattern.endsWith(pathSeparator)>
					<cfreturn true />
				<cfelseif NOT arguments.path.endsWith(pathSeparator)>
					<cfreturn true />
				<cfelse>
					<cfreturn false />
				</cfif>
			</cfif>
			
			<cfif NOT arguments.fullMatch>
				<cfreturn true />
			</cfif>
			
			<cfif patternStart EQ patternEnd AND patternDirectories[patternStart] EQ '*' AND arguments.path.endsWith(pathSeparator)>
				<cfreturn true />
			</cfif>
			
			<cfloop from="#patternStart#" to="#patternEnd#" index="i">
				<cfif NOT patternDirectories[i] EQ "**">
					<cfreturn false />
				</cfif>
			</cfloop>
			
			<cfreturn true />
		<!--- String not exhausted, but pattern is so fail --->
		<cfelseif patternStart GT patternEnd>
			<cfreturn false />
		<!--- Path start definitely matches due to "**" part in pattern --->
		<cfelseif NOT fullMatch AND patternDirectories[patternStart] EQ "**">
			<cfreturn true />
		</cfif>
		
		<!--- Up to last ** --->
		<cfloop condition="patternStart LTE patternEnd AND pathStart LTE pathEnd">
			<cfset patternDirectory = patternDirectories[patternEnd] />
			<cfif patternDirectory EQ "**">
				<cfbreak />
			</cfif>
			<cfif NOT matchStrings(patternDirectory, pathDirectories[pathEnd])>
				<cfreturn false />
			</cfif>
			<cfset patternEnd = patternEnd - 1 />
			<cfset pathEnd = pathEnd - 1 />
		</cfloop>
		
		<!--- String is exhausted --->
		<cfif pathStart GT pathEnd>
			<cfloop from="#patternStart#" to="#patternEnd#" index="i">
				<cfif NOT patternDirectories[i] EQ "**">
					<cfreturn false />
				</cfif>
			</cfloop>
			
			<cfreturn true />
		</cfif>

		<cfloop condition="patternStart NEQ patternEnd AND pathStart LTE pathEnd">
			<cfset patternTemp = -1 />
			<cfset continueOutterLoop = false />

			<cfloop from="#patternStart + 1#" to="#patternEnd#" index="i">
				<cfif patternDirectories[i]  EQ "**">
					<cfset patternTemp = i />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<!---  "**/**" situation, so skip one --->
			<cfif patternTemp EQ patternStart + 1>
				<cfset patternStart = patternStart + 1 />
				<cfset continueOutterLoop = true />
			</cfif>
			
			<cfif NOT continueOutterLoop>
				<!--- Find the pattern between padIdxStart & padIdxTmp in str between strIdxStart and strIdxEnd --->
				<cfset patternLength = patternTemp - patternStart />
				<cfset stringLength = pathEnd - pathStart + 1 />
				<cfset foundIdx = -1 />
				
				<cfloop from="1" to="#stringLength - patternLength + 1#" index="i">
					<cfset continueInnerLoop = false />

					<cfloop from="1" to="#patternLength#" index="j">
						<cfset subPattern = patternDirectories[patternStart + j] />
						<cfset subString = pathDirectories[pathStart + i + j - 1] />
						
						<cfif NOT matchStrings(subPattern, subString)>
							<cfset continueInnerLoop = true />
							<cfbreak />
						</cfif>
					</cfloop>
					
					<cfif NOT continueInnerLoop>
						<cfset foundIdx = pathStart + i />
						<cfbreak />
					</cfif>
				</cfloop>
				
				<cfif foundIdx EQ -1>
					<cfreturn false />
				</cfif>
				
				<cfset patternStart = patternTemp />
				<cfset pathStart = foundIdx + patternLength />
			</cfif>
		</cfloop>
		
		<cfloop from="#patternStart#" to="#patternEnd#" index="i">
			<cfif patternDirectories[i] NEQ "**">
				<cfreturn false />
			</cfif>
		</cfloop>

		<cfreturn true />
	</cffunction>
	
	<cffunction name="matchStrings" access="private" returntype="boolean" output="false"
		hint="Tests whether or not a string matches against a pattern.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="string" type="string" required="true" />

		<cfset var patternArray = arguments.pattern.toCharArray() />
		<cfset var stringArray = arguments.string.toCharArray() />
		<cfset var patternStart = 1 />
		<cfset var patternEnd = ArrayLen(patternArray) />
		<cfset var patternLength = 0 />
		<cfset var stringStart = 1 />
		<cfset var stringEnd = ArrayLen(stringArray) />
		<cfset var stringLength = 0 />
		<cfset var containsStar = false />
		<cfset var ch = "" />
		<cfset var patternTemp = -1 />
		<cfset var foundIdx = 0 />
		<cfset var continueILoop = false />
		<cfset var i = 0 />
		<cfset var j = 0 />	
		
		<!--- We typically try not to shortcircuit using returns in the
			middle of a method, but here it's much easier --->

		<!--- Check for any '*'s in the pattern --->
		<cfloop from="1" to="#ArrayLen(patternArray)#" index="i">
			<cfif patternArray[i] EQ "*">
				<cfset containsStar = true />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<!--- No stars so check to see if '?' match against the string --->
		<cfif NOT containsStar>
			<!--- No '*'s, so we make a shortcut --->
			<cfif patternEnd NEQ stringEnd>
				<!--- a pattern  with only '?'s will have the same size as string --->
				<cfreturn false />
			</cfif>
			
			<cfloop from="1" to="#patternEnd#" index="i">
				<cfset ch = patternArray[i] />
				<!--- Character mismatch --->
				<cfif ch NEQ '?' AND ch NEQ stringArray[i]>
					<cfreturn false />
				</cfif>
			</cfloop>
			
			<!--- String matches against pattern --->
			<cfreturn true />
		</cfif>

		<!--- Pattern contains only '*', which matches anything --->
		<cfif arguments.pattern IS "*">
			<cfreturn true />
		</cfif>

		<!---
		Process characters before first star
		Does not process if the first character is a star
		--->
		<cfloop condition="patternArray[patternStart] NEQ '*' AND stringStart LTE stringEnd">
			<cfset ch = patternArray[patternStart] />
			<!--- Character mismatch --->
			<cfif ch NEQ '?' AND ch NEQ stringArray[stringStart]>
				<cfreturn false />
			</cfif>
			<cfset patternStart = patternStart + 1 />
			<cfset stringStart = stringStart + 1 />
		</cfloop>

		<!---
		All characters in the string are used. Check if only '*'s are
		left in the pattern. If so, we succeeded. Otherwise failure.
		--->
		<cfif stringStart GT stringEnd>
			<cfloop from="#patternStart#" to="#patternEnd#" index="i">
				<cfif patternArray[i] NEQ '*'>
					<cfreturn false />
				</cfif>
			</cfloop>
			
			<cfreturn true />
		</cfif>

		<!---
		Process characters after last star
		Does not process if the last character is a star
		--->
		<cfloop condition="patternArray[patternEnd] NEQ '*' AND stringStart LTE stringEnd">
			<cfset ch = patternArray[patternEnd] />
			<!--- Character mismatch --->
			<cfif ch NEQ '?' AND ch NEQ stringArray[stringEnd]>
				<cfreturn false />
			</cfif>
			<cfset patternEnd = patternEnd - 1 />
			<cfset stringEnd = stringEnd - 1 />
		</cfloop>

		<!---
		All characters in the string are used. Check if only '*'s are
		left in the pattern. If so, we succeeded. Otherwise failure.
		--->
		<cfif stringStart GT stringEnd>
			<cfloop from="#patternStart#" to="#patternEnd#" index="i">
				<cfif patternArray[i] NEQ '*'>
					<cfreturn false />
				</cfif>
			</cfloop>
			<cfreturn true />
		</cfif>

		<!--- Process pattern between stars. padIdxStart and patternEnd point always to a '*'. --->
		<cfloop condition="patternStart NEQ patternEnd AND stringStart LTE stringEnd">
			<cfset patternTemp = -1 />
			
			<cfloop from="#patternStart + 1#" to="#patternEnd#" index="i">
				<cfif patternArray[i] EQ '*'>
					<cfset patternTemp = i />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<!--- Two stars next to each other, skip the first one --->
			<cfif patternTemp EQ patternStart + 1>
				<cfset patternStart = patternStart + 1 />
			<cfelse>
				<!--- Find the pattern between padIdxStart & patternTemp in str between stringStart & stringEnd --->	
				<cfset patternLength = patternTemp - patternStart />
				<cfset stringLength = stringEnd - stringStart + 1 />
				<cfset foundIdx = -1 />
				
				<cfloop from="1" to="#stringLength - patternLength + 1#" index="i">

					<cfset continueILoop = false />
					<cfloop from="1" to="#patternLength -1#" index="j">
						<cfset ch = patternArray[patternStart + j] />
						<cfif ch NEQ '?' AND ch NEQ stringArray[stringStart + i + j - 1]>
							<cfset continueILoop = true />
						</cfif>
					</cfloop>
					
					<cfif NOT continueILoop>
						<cfset foundIdx = stringStart + i />
						<cfbreak />
					</cfif>
				</cfloop>

				<cfif foundIdx EQ -1>
					<cfreturn false />
				</cfif>

				<cfset patternStart = patternTemp />
				<cfset stringStart = foundIdx + patternLength />
			</cfif>
		</cfloop>

		<!--- All characters in the string are used. Check if only '*'s are
			left in the pattern. If so, we succeeded. Otherwise failure. --->
		<cfloop from="#patternStart#" to="#patternEnd#" index="i">
			<cfif patternArray[i] NEQ '*'>
				<cfreturn false />
			</cfif>
		</cfloop>

		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setPathSeparator" access="public" returntype="void" output="false">
		<cfargument name="pathSeparator" type="string" required="true" />
		<cfset variables.pathSeparator = arguments.pathSeparator />
	</cffunction>
	<cffunction name="getPathSeparator" access="public" returntype="string" output="false">
		<cfreturn variables.pathSeparator />
	</cffunction>
	
</cfcomponent>