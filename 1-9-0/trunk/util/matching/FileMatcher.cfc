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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="FileMatcher"
	extends="AntPathMatcher"
	output="false"
	hint="Provides path matching using ANT style path selectors on a file system.">

	<!---
	PROPERTIES
	--->
	<cfset variables.useListInfo = false />
	<cfset variables.utils = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="FileMatcher" output="false"
		hint="Initializes the path pattern matcher.">
		<cfargument name="pathSeparator" type="string" required="false" default="/"
			hint="The path separator to use. Defaults to '/'."/>
		<cfargument name="useListInfo" type="boolean" required="false"
			hint="Allows you to indicate if you want to use the listInfo attribute of cfdirectory for faster performance. listInfo does not return file size or date last modified." />
		
		<cfset var temp = "" />
		<cfset var engineInfo = "" />
		
		<cfset variables.utils = CreateObject("component", "MachII.util.Utils").init("false") />
		
		<!--- Determine if _queryDeleteRow_java should be used and reassign to common function --->
		<cftry>
			<cfset temp = QueryNew("name", "VarChar") />
			<cfset QueryAddRow(temp, 2) />
			<!--- Use two rows of data or QueryDeleteRow fails on OpenBD 1.3 --->
			<cfset QuerySetCell(temp, "name", "Mach-II", 1) />
			<cfset QuerySetCell(temp, "name", "Framework", 2) />
			<cfset QueryDeleteRow(temp, 1) />
			
			<cfcatch type="any">
				<cfset variables.queryDeleteRow = variables._queryDeleteRow_java />
			</cfcatch>
		</cftry>
		
		<!--- Determine if we should use cfdirectory listInfo --->
		<cfif StructKeyExists(arguments, "useListInfo")>
			<cfset variables.useListInfo = arguments.useListInfo />
		<cfelse>
			<cfset engineInfo = variables.utils.getCfmlEngineInfo() />
			<cfif ((FindNoCase("ColdFusion", engineInfo.Name) AND engineInfo.majorVersion GTE 7)
				OR (FindNoCase("BlueDragon", engineInfo.Name) AND engineInfo.majorVersion GTE 1 AND engineInfo.minorVersion GTE 4 AND engineInfo.productLevel EQ "GPL")
				OR (FindNoCase("Railo", engineInfo.Name) AND engineInfo.majorVersion GTE 3)
				)>
				<cfset variables.useListInfo = true />
			</cfif>
		</cfif>
		
		<cfset super.init(argumentCollection=arguments) />

		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="match" access="public" returntype="query" output="false"
		hint="Matches the passed path against the pattern according to the matching strategy.">
		<cfargument name="pattern" type="string" required="true"
			hint="The pattern to use for the matching. Must be a full absolute path or use './' to be relative from the value in the path argument." />
		<cfargument name="path" type="string" required="true" 
			hint="The base path directory to run a cfdirectory call against. This path cannot have any patterns in it." />
		<cfargument name="removeRootPath" type="string" required="false" default="" 
			hint="A path to remove from the computed results. This is most useful when looking for .cfm files to be used with cfincludes as those paths cannot be absolute paths." />
		<cfargument name="excludePatterns" type="array" required="false" default="#ArrayNew(1)#" 
			hint="An array of patterns to exclude from the final results. This is useful if you want to cast a wide net with your pattern and filter those results further." />
		
		<cfset var pathResults = "" />
		<cfset var pathResultsRecordCount = 0 />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Clean up the paths and pattern --->
		<cfset arguments.path = pathClean(arguments.path) />
		<cfset arguments.removeRootPath = pathClean(arguments.removeRootPath) />
		<cfset arguments.pattern = pathClean(arguments.pattern) />		
		
		<!--- If the pattern is relative, then resolve to an absolute path --->
		<cfif arguments.pattern.startsWith(".")>
			<cfset arguments.pattern = pathClean(arguments.path & "/" & Right(arguments.pattern, Len(arguments.pattern) - 1)) />
		</cfif>
		
		<cfif variables.useListInfo>
			<cfset pathResults = findFilesWithListInfo(arguments.pattern, arguments.path, arguments.removeRootPath) />
		<cfelse>
			<cfset pathResults = findFiles(arguments.pattern, arguments.path, arguments.removeRootPath) />
		</cfif>
		
		<!--- N.B. At this point, all paths use "/" as the path separator regardless of OS --->
		
		<!--- Remove page view paths that match exclude paths or patterns 
			(except go in reverse because we may delete from the query)--->
		<cfif ArrayLen(arguments.excludePatterns)>
			<cfset arguments.excludePatterns = cleanExcludePatterns(arguments.excludePatterns) />
			
			<cfloop from="#pathResults.recordcount#" to="1" index="i" step="-1">
				<cfloop from="1" to="#ArrayLen(arguments.excludePatterns)#" index="j">
					<!--- If pattern and pattern matches or if exact path --->
					<cfif arguments.excludePatterns[j] EQ pathResults.fullPath[i]
						OR (isPattern(arguments.excludePatterns[j]) 
						AND super.match(arguments.excludePatterns[j], pathResults.fullPath[i]))>
						<!---
						If a pattern is found, delete and break out of the inner loop (short-circuit)
						We're using the underlying Java method or built-in method if available
						--->
						<cfset queryDeleteRow(pathResults, i) />
						<cfbreak />
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfset pathResultsRecordCount = pathResults.recordcount />
		
		<!---
			Looks for all the results that match the input pattern
			Loop from last to row 2 since we have to get around a QueryDeleteRow() bug in OpenBD 1.3
			when only one row of data remains in the query.
		--->
		<cfif pathResults.recordCount GTE 2>
			<cfloop from="#pathResults.recordCount#" to="2" index="i" step="-1">
				<cfif NOT super.match(arguments.pattern, pathResults.fullPath[i])>
					<cfset queryDeleteRow(pathResults, i) />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- Get around a QueryDeleteRow() bug in OpenBD 1.3 when only one row of data remains in the query. --->
		<cfif pathResults.recordCount GTE 1 AND NOT super.match(arguments.pattern, pathResults.modifiedPath[1])>
			<cfif pathResults.recordCount EQ 1>
				<cfset pathResults = QueryNew("name,size,type,directory,dateLastModified,attributes,modifiedPath,fullPath") />
			<cfelse>
				<cfset queryDeleteRow(pathResults, 1) />
			</cfif>
		</cfif>
		
		<cfreturn pathResults />
	</cffunction>

	<cffunction name="matchStart" access="public" returntype="void" output="false"
		hint="Not planned for implementation.">
		<cfabort showerror="This method is not planned to be implemented." />
	</cffunction>

	<cffunction name="pathClean" access="public" returntype="string" output="false"
		hint="Cleans paths so all paths use an uniform path separator.">
		<cfargument name="path" type="string" required="true"
			hint="The path to clean and convert to an uniform path separator."/>
		<cfreturn REReplaceNoCase(arguments.path, "(\\{1,}|\/{1,})", "/", "all") />
	</cffunction>
	
	<cffunction name="extractPathWithoutPattern" access="public" returntype="string" output="false"
		hint="Extract the path base (the part before the pattern starts) from a string and automatically cleans the path via pathClean().">
		<cfargument name="path" type="string" required="true"
			hint="The path to remove a pattern from."/>
		
		<cfset var parts = "" />
		<cfset var result = "" />
		<cfset var i = 0 />
		
		<!--- Ensure that the path has a uniform path separate to work with --->
		<cfset arguments.path = pathClean(arguments.path) />

		<cfset parts = ListToArray(arguments.path, "/") />
		
		<cfloop from="1" to="#ArrayLen(parts)#" index="i">
			<cfif NOT isPattern(parts[i])>
				<cfset result = ListAppend(result, parts[i], "/") />
			</cfif>
		</cfloop>
		
		<cfif arguments.path.startsWith("/")>
			<cfset result = "/" & result />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="_queryDeleteRow_java" access="private" returntype="void" output="false"
		hint="Deletes a row from a query.">
		<cfargument name="query" type="query" required="true" />
		<cfargument name="rowNumber" type="numeric" required="true" />
		<!--- Query rows in the Java methods start at 0 so we need to offset the row number to delete --->
		<cfset arguments.query.removeRows(arguments.rowNumber - 1,  1) />
	</cffunction>
	
	<cffunction name="cleanExcludePatterns" access="private" returntype="array" output="false"
		hint="Cleans the exclude pattern paths.">
		<cfargument name="excludePatterns" type="array" required="true"
			hint="The exclude patterns to clean." />
		<cfargument name="path" type="string" required="true"
			hint="The base path to use for relative path expanding" />
			
		<cfset var cleanedExcludePatterns = ArrayNew(1) />
		<cfset var pattern = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.excludePatterns)#" index="i">
			<cfset pattern = pathClean(arguments.excludePatterns[i]) />
			
			<!--- If the pattern is relative, then resolve to an absolute path --->
			<cfif temp.startsWith(".")>
				<cfset pattern = pathClean(arguments.path & "/" & Right(pattern, Len(pattern) - 1)) />
			</cfif>
			
			<cfset ArrayAppend(cleanedExcludePatterns, pattern) />
		</cfloop>
		
		<cfreturn cleanedExcludePatterns />
	</cffunction>
	
	<cffunction name="findFiles" access="private" returntype="query" output="false"
		hint="Finds all files by pattern without using 'listInfo'.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfargument name="removeRootPath" type="string" required="true" />
		
		<cfset var pathResults = "" />
		<cfset var i = "" />
		
		<!--- Find possible candidates and only recurse if there is a ** in the pattern to save on performance --->
		<cfdirectory name="pathResults" 
			action="list" 
			directory="#arguments.path#"
			recurse="#FindNoCase("**", arguments.pattern)#" />
		
		<!--- Add modified path columns --->
		<cfset QueryAddColumn(pathResults, "modifiedPath", "VarChar", ArrayNew(1)) />
		<cfset QueryAddColumn(pathResults, "fullPath", "VarChar", ArrayNew(1)) />
		
		<!---
		Build possible paths by removing the root path if requested. This option 
		is offered because cfinclude cannot use absolute file paths
		I know two loop that are similar is harder to maintain, but it's better performance
		--->
		<cfif Len(arguments.removeRootPath)>
			<cfloop from="#pathResults.recordcount#" to="1" index="i" step="-1">
				<cfif pathResults.type[i] EQ "file">
					<cfset pathResults.directory[i] =  REReplaceNoCase(pathResults.directory[i], "(\\{1,}|\/{1,})", "/", "all") />
					<cfset pathResults.fullPath[i] = pathResults.directory[i] & "/" & pathResults.name[i] />
					<cfset pathResults.modifiedPath[i] =  ReplaceNoCase(pathResults.directory[i], arguments.removeRootPath, "", "one") & "/" & pathResults.name[i] />
				<cfelse>
					<cfset queryDeleteRow(pathResults, i) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop from="#pathResults.recordcount#" to="1" index="i" step="-1">
				<cfif pathResults.type[i] EQ "file">
					<cfset pathResults.directory[i] =  REReplaceNoCase(pathResults.directory[i], "(\\{1,}|\/{1,})", "/", "all") />
					<cfset pathResults.fullPath[i] = pathResults.directory[i] & "/" & pathResults.name[i] />
					<cfset pathResults.modifiedPath[i] = pathResults.fullPath[i] />
				<cfelse>
					<cfset queryDeleteRow(pathResults, i) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn pathResults />
	</cffunction>

	<cffunction name="findFilesWithListInfo" access="private" returntype="query" output="false"
		hint="Finds all files by pattern without using 'listInfo'.">
		<cfargument name="pattern" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfargument name="removeRootPath" type="string" required="true" />
		
		<cfset var pathResults = "" />
		<cfset var i = "" />
		
		<!--- Find possible candidates and only recurse if there is a ** in the pattern to save on performance --->
		<cfdirectory name="pathResults" 
			action="list" 
			directory="#arguments.path#"
			listInfo="name"
			type="file"
			recurse="#FindNoCase("**", arguments.pattern)#" />

		<!--- Add modified path columns --->
		<cfset QueryAddColumn(pathResults, "modifiedPath", "VarChar", ArrayNew(1)) />
		<cfset QueryAddColumn(pathResults, "fullPath", "VarChar", ArrayNew(1)) />

		<!--- ACF does not include all the required columns while BD provided blanks --->
		<cfif NOT ListFindNoCase(pathResults.columnList, "directory")>
			<cfset QueryAddColumn(pathResults, "directory", "VarChar", ArrayNew(1)) />
		</cfif>

		<!---
		Build possible paths by removing the root path if requested. This option 
		is offered because cfinclude cannot use absolute file paths
		I know two loop that are similar is harder to maintain, but it's better performance
		--->
		<cfif Len(arguments.removeRootPath)>
			<cfloop from="1" to="#pathResults.recordcount#" index="i">
				<cfset pathResults.directory[i] = REReplaceNoCase(arguments.path & "/" & GetDirectoryFromPath(pathResults.name[i]), "(\\{1,}|\/{1,})", "/", "all") />
				<cfset pathResults.name[i] = GetFileFromPath(pathResults.name[i]) />
				<cfset pathResults.fullPath[i] = pathResults.directory[i] & pathResults.name[i] />
				<cfset pathResults.modifiedPath[i] = ReplaceNoCase(pathResults.fullPath[i], arguments.removeRootPath, "", "one") />
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#pathResults.recordcount#" index="i">
				<cfset pathResults.directory[i] = REReplaceNoCase(arguments.path & "/" & GetDirectoryFromPath(pathResults.name[i]), "(\\{1,}|\/{1,})", "/", "all") />
				<cfset pathResults.name[i] = GetFileFromPath(pathResults.name[i]) />
				<cfset pathResults.fullPath[i] = pathResults.directory[i] & pathResults.name[i] />
				<cfset pathResults.modifiedPath[i] = pathResults.fullPath[i] />
			</cfloop>
		</cfif>
		
		<cfreturn pathResults />
	</cffunction>

</cfcomponent>