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
--->
<cfcomponent
	displayname="PatternViewLoader"
	extends="MachII.framework.viewLoaders.AbstractViewLoader" 
	output="false" 
	hint="Loads views that match an ANT-style path pattern.">

	<!---
	PROPERTIES
	--->
	<cfset variables.applicationRoot = "" />
	<cfset variables.pattern = "" />
	<cfset variables.prefix = "" />
	<cfset variables.nameDelimiter = "" />
	<cfset variables.exclude = ArrayNew(1) />
	<cfset variables.pathMatcher = CreateObject("component", "MachII.util.AntPathMatcher").init() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the view loader.">			
		<cfset setApplicationRoot(getAppManager().getPropertyManager().getProperty("applicationRoot")) />		
		<cfset setPattern(getParameter("pattern", "/views/**/*.cfm")) />
		<cfset setPrefix(getParameter("prefix" ,"")) />
		<cfset setNameDelimiter(getParameter("nameDelimiter", ".")) />
		<cfset setExclude(getParameter("exclude", ArrayNew(1))) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="discoverViews" access="public" returntype="struct" output="false"
		hint="Loads views based on the defined parameters.">
			
		<cfset var appRootPath = ExpandPath(getApplicationRoot()) />
		<cfset var pattern = getPattern() />
		<cfset var exclude = getExclude() />
		<cfset var pageViewQuery = "" />
		<cfset var pageViewPaths = ArrayNew(1) />
		<cfset var results = StructNew() />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Get all the possible page views --->
		<cfdirectory name="pageViewQuery" 
			action="list" 
			directory="#appRootPath#/#extractSearchPathBaseFromPattern(pattern)#" 
			recurse="true" />
		
		<!---
		Build possible page view paths by removing the applicationRoot 
		(because cfinclude cannot use absolute file path) and then clean the paths
		--->
		<cfloop from="1" to="#pageViewQuery.recordcount#" index="i">
			<cfif pageViewQuery.type[i] EQ "file">
				<cfset ArrayAppend(pageViewPaths, cleanPath(ReplaceNoCase(pageViewQuery.directory[i], appRootPath, "", "one")) & "/" & pageViewQuery.name[i]) />
			</cfif>
		</cfloop>
		
		<!--- N.B. At this point, all paths use "/" as the path separator regardless of OS --->
		
		<!--- Remove page view paths that match exclude paths or patterns 
			(except go in reverse because we may delete from the array)--->
		<cfloop from="#ArrayLen(pageViewPaths)#" to="1" index="i" step="-1">
			<cfloop from="1" to="#ArrayLen(exclude)#" index="j">
				<!--- If pattern and pattern matches or if exact path --->
				<cfif (variables.pathMatcher.isPattern(exclude[j]) 
					AND variables.pathMatcher.match(exclude[j], pageViewPaths[i]))
					OR exclude[j] EQ pageViewPaths[i]>
					<cfset ArrayDeleteAt(pageViewPaths, i) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- Build page-views that match patterns --->
		<cfloop from="1" to="#ArrayLen(pageViewPaths)#" index="i">
			<cfif variables.pathMatcher.match(pattern, pageViewPaths[i])>
				<cfset results[buildPageViewName(pattern, pageViewPaths[i])] = getApplicationRoot() & pageViewPaths[i] />
			</cfif>
		</cfloop>
		
		<cfreturn results />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="cleanPath" access="private" returntype="string" output="false"
		hint="Cleans paths so all paths use a uniform delimiter.">
		<cfargument name="path" type="string" required="true" />
		<cfreturn Replace(arguments.path, "\", "/", "all") />
	</cffunction>
	
	<cffunction name="buildPageViewName" access="private" returntype="string" output="false"
		hint="Builds page view name based on the path and pattern.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		
		<cfset var prefix = getPrefix() />
		<cfset var fileName = ListLast(arguments.path, "/") />
		<cfset var fileExtension = "" />
		<cfset var result = "" />
		
		<!--- Append name delimiter to prefix if a prefix is defined--->
		<cfif Len(prefix)>
			<cfset prefix = prefix & getNameDelimiter() />	
		</cfif>
		
		<!--- Replace all path separators with name delimiter --->
		<cfset result = Replace(variables.pathMatcher.extractPathWithinPattern(arguments.pattern, arguments.path), "/", getNameDelimiter(), "all") />
		
		<!---
		Remove file extension if defined
		(some directories have periods in them so we have to look at the file name)
		--->
		<cfif Find(".", fileName)>
			<cfset fileExtension = "." & ListLast(fileName, ".") />
			<cfif fileName.endsWith(fileExtension)>
				<!---
				In case the file name period with the value of the
				file extension as the file name, remove the extenions
				by using only the left portion of the path
				--->
				<cfset result = Left(result, Len(result) - Len(fileExtension)) />
			</cfif>
		</cfif>
		
		<cfreturn prefix & result />
	</cffunction>
	
	<cffunction name="extractSearchPathBaseFromPattern" access="private" returntype="string" output="false"
		hint="Extract the search path base (the part before the pattern starts) from a pattern.">
		<cfargument name="pattern" type="string" required="true" />
		
		<cfset var patternParts = ListToArray(arguments.pattern, "/") />
		<cfset var patternBase = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(patternParts)#" index="i">
			<cfif NOT variables.pathMatcher.isPattern(patternParts[i])>
				<cfset patternBase = ListAppend(patternBase, patternParts[i], "/") />
			</cfif>
		</cfloop>
		
		<cfreturn patternBase />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setApplicationRoot" access="private" returntype="void" output="false">
		<cfargument name="applicationRoot" type="string" required="true" />
		<cfset variables.applicationRoot = arguments.applicationRoot />
	</cffunction>
	<cffunction name="getApplicationRoot" access="public" returntype="string" output="false">
		<cfreturn variables.applicationRoot />
	</cffunction>
	
	<cffunction name="setPattern" access="private" returntype="void" output="false">
		<cfargument name="pattern" type="string" required="true" />
		
		<cfset var cleanedPath = cleanPath(arguments.pattern) />
		
		<!--- Ensure the passed value is really a pattern --->
		<cfif NOT variables.pathMatcher.isPattern(arguments.pattern)>
			<cfthrow type="MachII.framework.viewLoaders.PatternViewLoader.notPattern"
				message="The value of the parameter 'pattern' is not a valid path pattern (ex. '/views/**/*.cfm')."
				detail="pattern='#arguments.pattern#'" />
		</cfif>
		
		<cfset variables.pattern = cleanedPath />
	</cffunction>
	<cffunction name="getPattern" access="public" returntype="string" output="false"
		hint="Gets the pattern array.">
		<cfreturn variables.pattern />
	</cffunction>

	<cffunction name="setPrefix" access="private" returntype="void" output="false">
		<cfargument name="prefix" type="string" required="true" />
		<cfset variables.prefix = arguments.prefix />
	</cffunction>
	<cffunction name="getPrefix" access="public" returntype="string" output="false">
		<cfreturn variables.prefix />
	</cffunction>

	<cffunction name="setNameDelimiter" access="private" returntype="void" output="false">
		<cfargument name="nameDelimiter" type="string" required="true" />
		<cfset variables.nameDelimiter = arguments.nameDelimiter />
	</cffunction>
	<cffunction name="getNameDelimiter" access="public" returntype="string" output="false">
		<cfreturn variables.nameDelimiter />
	</cffunction>

	<cffunction name="setExclude" access="private" returntype="void" output="false"
		hint="Set the exclude paths and converts to an array if necessary. Accepts a list or an array.">
		<cfargument name="exclude" type="any" required="true" />
		
		<cfset var cleanedExclude = ArrayNew(1) />
		<cfset var i = 0 />
		
		<!--- Convert to array --->
		<cfif IsSimpleValue(arguments.exclude)>
			<cfset arguments.exclude = ListToArray(variables.utils.trimList(arguments.exclude)) />
		<cfelseif NOT IsArray(arguments.exclude)>
			<cfthrow type="MachII.framework.viewLoaders.PatternViewLoader.invalidType"
				message="The value of the parameter 'exclude' is not a list or an array." />
		</cfif>
		
		<!--- Clean paths --->
		<cfloop from="1" to="#ArrayLen(arguments.exclude)#" index="i">
			<cfset ArrayAppend(cleanedExclude, cleanPath(arguments.exclude[i])) />
		</cfloop>
		
		<cfset variables.exclude = cleanedExclude />
	</cffunction>
	<cffunction name="getExclude" access="public" returntype="array" output="false">
		<cfreturn variables.exclude />
	</cffunction>

</cfcomponent>