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

Wildcards for patterns:
*	= Matches zero or more characters.
?	= Matches exactly one character.
**	= Matches zero or more directories.

<page-views>
    <view-loader type="MachII.framework.viewLoaders.PatternViewLoader">
        <parameters>
			<!-- An ANT-style patterns using wildcards to find views to load -->
            <parameter name="pattern" value="/views/**/*.cfm" />
            <!-- A string to prefix the <page-view> name with (matches only 
				starts after first pattern character is detected). 
				Optional, showing default value if attribute is omitted -->
            <parameter name="prefix" value="" />
            <!-- Character to use when building the <page-view> names.
				Optional, showing default value if attribute is omitted -->
            <parameter name="nameDelimiter" value="." />
            <!-- A list or array of ANT-style patterns or static paths to 
				exclude from the pattern search routine.
				Optional, takes a list or an array -->
            <parameter name="exclude" value="/views/includes/**,/views/otherDir/**" />
            - or -
            <parameter name="exclude">
                <array>
                    <element value="/views/includes/**"/>
                    <element value="/views/otherDir/**"/>
                </array>
            </parameter>
			<!-- Boolean indicator to throw an exception if no matches are found
				Optional, takes a boolean and defaults to "true" -->
			 <parameter name="throwIfNoMatches" value="true"/>
        </parameters>
    </view-loader>

    <!-- Normal static page-view nodes are allowed or additional view-loaders -->
    <page-view name="someView" page="/views/someView.cfm"/>
</page-views>

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
	<cfset variables.throwIfNoMatches = "" />
	<cfset variables.pathMatcher = CreateObject("component", "MachII.util.matching.FileMatcher").init() />

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
		<cfset setThrowIfNoMatches(getParameter("throwIfNoMatches", true)) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="discoverViews" access="public" returntype="struct" output="false"
		hint="Loads views based on the defined parameters.">
		
		<cfset var appRoot = getApplicationRoot() />	
		<cfset var appRootPath = variables.pathMatcher.pathClean(ExpandPath(appRoot)) />
		<cfset var searchPath = "" />
		<cfset var pattern = getPattern() />
		<cfset var pageViewPaths = "" />
		<cfset var results = StructNew() />
		<cfset var viewData = "" />
		<cfset var i = 0 />

		<!--- Trailing slashes are bad on the appRootPath--->
		<cfif appRootPath.endsWith("/")>
			<cfset appRootPath = Left(appRootPath, Len(appRootPath) -1) />
		</cfif>
		
		<!--- Decide if we need to resolve a relative pattern path   --->
		<cfif pattern.startsWith(".")>
			<cfset searchPath = getUtils().expandRelativePath(appRootPath, variables.pathMatcher.extractPathWithoutPattern(pattern)) />
			<!--- Clean up pattern --->
			<cfset appRoot = appRoot & Replace(pattern, removeRelativePartsFromPattern(pattern), "", "one") />
			<cfset pattern = removeRelativePartsFromPattern(pattern) />
			<cfset appRootPath = ReplaceNoCase(searchPath, variables.pathMatcher.extractPathWithoutPattern(pattern), "") />
		<cfelse>
			<cfset searchPath = appRootPath & "/" & variables.pathMatcher.extractPathWithoutPattern(pattern) />
		</cfif>
		
		<cfset pageViewPaths = variables.pathMatcher.match(pattern, searchPath, appRootPath, getExclude()) />

		<!--- Build page-views that match patterns --->
		<cfloop from="1" to="#pageViewPaths.recordcount#" index="i">
			<cfset viewData = StructNew() />
			<cfset viewData.page = pageViewPaths.modifiedPath[i] />
			<cfset viewData.appRoot = appRoot />
			<cfset viewData.appRootType = "local" />
			<cfset results[buildPageViewName(pattern, viewData.page)] = viewData />
		</cfloop>
		
		<!--- Throw an exception if there are not matches --->
		<cfif getThrowIfNoMatches() AND NOT StructCount(results)>
			<cfthrow type="MachII.framework.viewLoaders.PatternViewLoader.noMatches"
				message="No matches found for pattern '#getPattern()#' in module '#getAppManager().getModuleName()#'."
				detail="App root '#appRoot#, App root path '#appRootPath#, 'Search path '#searchPath#', Total view paths found '#pageViewPaths.recordcount#'." />
		</cfif>
		
		<cfreturn results />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - UTILS
	--->	
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
	
	<cffunction name="removeRelativePartsFromPattern" access="private" returntype="string" output="false"
		hint="Removes the relative parts form the pattern.">
		<cfargument name="pattern" type="string" required="true" />
		
		<cfset var patternParts = ListToArray(arguments.pattern, "/") />
		<cfset var patternBase = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(patternParts)#" index="i">
			<cfif NOT ListFindNoCase(".|..", patternParts[i], "|")>
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
		
		<!--- Ensure the passed value is really a pattern --->
		<cfset getAssert().isTrue(variables.pathMatcher.isPattern(arguments.pattern)
				, "The value of the parameter 'pattern' is not a valid path pattern (ex. '/views/**/*.cfm')."
				, "The passed pattern is '#arguments.pattern#'.") />
		
		<cfset variables.pattern = arguments.pattern />
	</cffunction>
	<cffunction name="getPattern" access="public" returntype="string" output="false">
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
			<cfset arguments.exclude = ListToArray(getUtils().trimList(arguments.exclude)) />
		</cfif>
		
		<cfset getAssert().isTrue(IsArray(arguments.exclude)
				, "The value of the parameter 'exclude' is must be a list or an array.") />
		
		<cfset variables.exclude = arguments.exclude />
	</cffunction>
	<cffunction name="getExclude" access="public" returntype="array" output="false">
		<cfreturn variables.exclude />
	</cffunction>
	
	<cffunction name="setThrowIfNoMatches" access="private" returntype="void" output="false">
		<cfargument name="throwIfNoMatches" type="boolean" required="true" />
		<cfset variables.throwIfNoMatches = arguments.throwIfNoMatches />
	</cffunction>
	<cffunction name="getThrowIfNoMatches" access="public" returntype="boolean" output="false">
		<cfreturn variables.throwIfNoMatches />
	</cffunction>

</cfcomponent>