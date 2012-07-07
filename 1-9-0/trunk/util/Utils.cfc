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

Created version: 1.5.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="Utils"
	output="false"
	hint="Utility functions for the framework.">

	<!---
	PROPERTIES
	--->
	<cfset variables.system = CreateObject("java", "java.lang.System") />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.statusCodeShortcutMap = StructNew() />
	<cfset variables.mimeTypeMap = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Utils" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="loadResources" type="boolean" required="false" default="true"
			hint="Directive to load in resource files. Defaults to true." />

		<cfset var temp = "" />

		<cfif arguments.loadResources>
			<cfset variables.statusCodeShortcutMap = loadResourceData("/MachII/util/resources/data/httpStatuscodes.properties") />
			<cfset variables.mimeTypeMap = loadResourceData("/MachII/util/resources/data/mimeTypes.properties") />
		</cfif>

		<!--- Test if native ListItemTrim() is available (OpenBD 1.4 and Railo 3.2) --->
		<cftry>
			<cfset ListItemTrim("temp, temp") />

			<cfset variables.listTrim = variables.trimList_native />
			<cfset this.listTrim = this.trimList_native />

			<cfcatch type="any">
				<!--- Any exception means the BIF is unavailable so ignore this exception --->
			</cfcatch>
		</cftry>

		<!--- Test if native HtmlEditFormat() does not escape already escaped entities --->
		<cfset temp = escapeHtml_native("&lt;&gt;&quot;&amp;") />

		<cfif temp EQ "&lt;&gt;&quot;&amp;">
			<cfset variables.escapeHtml = variables.escapeHtml_native />
			<cfset this.escapeHtml = this.escapeHtml_native />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="recurseComplexValues" access="public" returntype="any" output="false"
		hint="Recurses through complex values by type.">
		<cfargument name="node" type="any" required="true" />

		<cfset var value = "" />
		<cfset var child = "" />
		<cfset var i = "" />

		<cfif StructKeyExists(arguments.node.xmlAttributes, "value")>
			<cfset value = arguments.node.xmlAttributes["value"] />
		<cfelseif ArrayLen(arguments.node.xmlChildren)>
			<cfset child = arguments.node.xmlChildren[1] />
			<cfif child.xmlName EQ "value">
				<cfset value = child.xmlText />
			<cfelseif child.xmlName EQ "struct">
				<cfset value = StructNew() />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">
					<cfset value[child.xmlChildren[i].xmlAttributes["name"]] = recurseComplexValues(child.xmlChildren[i]) />
				</cfloop>
			<cfelseif child.xmlName EQ "array">
				<cfset value = ArrayNew(1) />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">
					<cfset ArrayAppend(value, recurseComplexValues(child.xmlChildren[i])) />
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn value />
	</cffunction>

	<cffunction name="expandRelativePath" access="public" returntype="string" output="false"
		hint="Expands a relative path to an absolute path relative from a base (starting) directory.">
		<cfargument name="baseDirectory" type="string" required="true"
			hint="The starting directory from which relative path is relative." />
		<cfargument name="relativePath" type="string" required="true"
			hint="The relative path to use." />

		<cfset var combinedWorkingPath = arguments.baseDirectory & arguments.relativePath />
		<cfset var pathCollection = 0 />
		<cfset var resolvedPath = "" />
		<cfset var hits = ArrayNew(1) />
		<cfset var offset = 0 />
		<cfset var isUNC = false />
		<cfset var i = 0 />

		<!--- Check if UNC path --->
		<cfif arguments.baseDirectory.startsWith("\\")>
			<cfset isUNC = true />
		</cfif>

		<!--- Unified slashes due to operating system differences and convert ./ to / --->
		<cfset combinedWorkingPath = ReplaceNoCase(combinedWorkingPath, "\", "/", "all") />
		<cfset combinedWorkingPath = ReplaceNoCase(combinedWorkingPath, "/./", "/", "all") />
		<cfset pathCollection = ListToArray(combinedWorkingPath, "/") />

		<!--- Check how many directories we need to move up using the ../ syntax --->
		<cfloop from="1" to="#ArrayLen(pathCollection)#" index="i">
			<cfif pathCollection[i] IS "..">
				<cfset ArrayAppend(hits, i) />
			</cfif>
		</cfloop>
		<cfloop from="1" to="#ArrayLen(hits)#" index="i">
			<cfset ArrayDeleteAt(pathCollection, hits[i] - offset) />
			<cfset ArrayDeleteAt(pathCollection, hits[i] - (offset + 1)) />
			<cfset offset = offset + 2 />
		</cfloop>

		<!--- Rebuild the path from the collection --->
		<cfset resolvedPath = ArrayToList(pathCollection, "/") />

		<!--- Reinsert UNC if that type of path --->
		<cfif isUNC>
			<cfset resolvedPath = "\\" & resolvedPath />
		<!--- Reinsert the leading slash if *nix system --->
		<cfelseif arguments.baseDirectory.startsWith("/")>
			<cfset resolvedPath = "/" & resolvedPath />
		</cfif>

		<!--- Reinsert the trailing slash if the relativePath was just a directory --->
		<cfif arguments.relativePath.endsWith("/")>
			<cfset resolvedPath = resolvedPath & "/" />
		</cfif>

		<cfreturn resolvedPath />
	</cffunction>

	<cffunction name="loadResourceData" access="public" returntype="struct" output="false"
		hint="Loads resource data by path and returns a struct.">
		<cfargument name="resourcePath" type="string" required="true"
			hint="A path to the resource." />
		<cfargument name="expandValueKeys" type="string" required="false"
			hint="A list of keys names to expand value to." />
		<cfargument name="expandValueKeyDelimiters" type="string" required="false" default="|"
			hint="The delimiters to use when expanding value keys." />

		<cfset var resourceMap = StructNew() />
		<cfset var line = "" />
		<cfset var key = "" />
		<cfset var valueKeys = "" />
		<cfset var temp = "" />
		<cfset var values = "" />
		<cfset var i = 0 />

		<!--- Parse the file --->
		<cfloop file="#ExpandPath(arguments.resourcePath)#" index="line">
			<cfif NOT line.startsWith("##") AND ListLen(line, "=") EQ 2 >
				<cfset resourceMap[ListFirst(line, "=")] = ListGetAt(line, 2, "=") />
			</cfif>
		</cfloop>

		<!--- Explode value of the resouce into structs if we have value keys --->
		<cfif StructKeyExists(arguments, "expandValueKeys")>
			<cfset valueKeys = ListToArray(arguments.expandValueKeys) />

			<cfloop collection="#resourceMap#" item="key">
				<cfset values = ListToArray(resourceMap[key], arguments.expandValueKeyDelimiters)  />

				<cfset temp = StructNew() />

				<cfloop from="1" to="#ArrayLen(valueKeys)#" index="i">
				<!--- The values may not be of equal length to the number of value keys so check --->
					<cfif i LTE ArrayLen(values)>
						<cfset temp[valueKeys[i]] = values[i] />
					<cfelse>
						<cfset temp[valueKeys[i]] = "" />
					</cfif>
				</cfloop>

				<!--- Replace the value of the resource key with the exploded struct --->
				<cfset resourceMap[key] = temp />
			</cfloop>
		</cfif>

		<cfreturn resourceMap />
	</cffunction>

	<cffunction name="createThreadingAdapter" access="public" returntype="MachII.util.threading.ThreadingAdapter" output="false"
		hint="Creates a threading adapter if the CFML engine has threading capabilities.">

		<cfset var threadingAvailable = false />
		<cfset var engineInfo = "" />

		<!--- Short-circuit and use the cache version if already loaded --->
		<cfif NOT IsObject(variables.threadingAdapter)>
			<cfset engineInfo = getCfmlEngineInfo() />

			<!--- Adobe ColdFusion 8+ --->
			<cfif FindNoCase("ColdFusion", engineInfo.Name) AND engineInfo.majorVersion GTE 8>
				<cfset variables.threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterCF").init() />
			<!--- OpenBD 1.3+ (BlueDragon 7+ threading engine is not currently compatible) --->
			<cfelseif FindNoCase("BlueDragon", engineInfo.Name) AND  engineInfo.productLevel EQ "GPL" AND ((engineInfo.majorVersion EQ 1 AND engineInfo.minorVersion GTE 3) OR engineInfo.majorVersion GTE 2)>
				<cfset variables.threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterBD").init() />
			<!--- Railo 3 --->
			<cfelseif FindNoCase("Railo", engineInfo.Name) AND engineInfo.majorVersion GTE 3>
				<cfset variables.threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterRA").init() />
			</cfif>

			<!--- Test for threading availability --->
			<cfif IsObject(threadingAdapter)>
				<cfset threadingAvailable = threadingAdapter.testIfThreadingAvailable() />
			</cfif>

			<!---
				Default theading adapter used to check if threading is implemented on this engine or
				threading is disabled on target system due to security sandbox
			--->
			<cfif NOT IsObject(variables.threadingAdapter) OR NOT threadingAvailable>
				<cfset variables.threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapter").init() />
			</cfif>
		</cfif>

		<cfreturn variables.threadingAdapter />
	</cffunction>

	<cffunction name="createAdminApiAdapter" access="public" returntype="MachII.util.cfmlEngine.AdminApiAdapter" output="false"
		hint="Creates an admin api adapter for the CFML engine.">

		<cfset var adminApiAdapter = "" />
		<cfset var engineInfo = getCfmlEngineInfo() />

		<!--- Adobe ColdFusion 8+ --->
		<cfif FindNoCase("ColdFusion", engineInfo.Name) AND engineInfo.majorVersion GTE 8>
			<cfset adminApiAdapter = CreateObject("component", "MachII.util.cfmlEngine.AdminApiAdapterCF").init() />
		<!--- OpenBD 1.3+ (BlueDragon 7+ admin API is not currently implemented) --->
		<cfelseif FindNoCase("BlueDragon", engineInfo.Name) AND  engineInfo.productLevel EQ "GPL" AND engineInfo.majorVersion GTE 1 AND engineInfo.minorVersion GTE 3>
			<cfset adminApiAdapter = CreateObject("component", "MachII.util.cfmlEngine.AdminApiAdapterBD").init() />
		<!--- Railo 3
		<cfelseif FindNoCase("Railo", engineInfo.Name) AND engineInfo.majorVersion GTE 3>
			<cfset adminApiAdapter = CreateObject("component", "MachII.util.cfmlEngine.AdminApiAdapterRA").init() /> --->
		</cfif>

		<!--- Test for admin api availability --->
		<cfif NOT IsObject(adminApiAdapter)>
			<cfthrow type="MachII.utils.NoAdminApiAdapterAvailable"
				message="Cannot create an admin API adapter for the target system. No compatible adapter available."
				detail="Engine Name: '#engineInfo.Name#', Major Version: '#engineInfo.majorVersion#', Minor Version: '#engineInfo.minorVersion#', Product Level: '#engineInfo.productLevel#'" />
		</cfif>

		<cfreturn adminApiAdapter />
	</cffunction>

	<cffunction name="getCfmlEngineInfo" access="public" returntype="struct" output="false"
		hint="Gets normalized information of the CFML engine. Keys: 'name', 'majorVersion', 'minorVersion' and 'productLevel'.">

		<cfset var rawProductVersion = server.coldfusion.productversion />
		<cfset var minorVersionRegex = 0 />
		<cfset var result = StructNew() />

		<cfset result.name = server.coldfusion.productname />
		<cfset result.majorVersion = 0 />
		<cfset result.minorVersion = 0 />
		<cfset result.fullVersion = rawProductVersion />
		<cfset result.productLevel = server.coldfusion.productlevel />
		<cfset result.appServer = server.coldfusion.appServer />

		<!---
			Railo puts a "fake" version number (e.g. 8,0,0,1) in product version number so we need
			to get the real version number of Railo which
		--->
		<cfif FindNoCase("Railo", result.name)>
			<cfset rawProductVersion = server.railo.version />
		</cfif>

		<!--- OpenBD and Railo use "." while CF uses "," as the delimiter for the product version so convert it for consistency --->
		<cfset rawProductVersion = ListChangeDelims(rawProductVersion, ".", ",") />

		<!--- Get major product version --->
		<cfset result.majorVersion = ListFirst(rawProductVersion, ".") />

		<!---
			Make sure we have a minor product version--Open BlueDragon doesn't have one on its initial release
			but this will be added; however, probably not wise to always assume it's there. Set a
			default of 0 in case it doesn't exist.
		--->
		<cfif ListLen(rawProductVersion, ".") GT 1>
			<cfset result.minorVersion = ListGetAt(rawProductVersion, 2, ".") />

			<cfset minorVersionRegex = REFindNoCase("[[:alpha:]]", result.minorVersion) />

			<!--- Remove any trailing sub-number like 1.4a in OpenBD --->
			<cfif minorVersionRegex GT 0>
				<cfset result.minorVersion = Mid(result.minorVersion, 1, minorVersionRegex) />
			</cfif>
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="assertSame" access="public" returntype="boolean" output="false"
		hint="Asserts of the passed objects are the same instance or not.">
		<cfargument name="reference" type="any" required="true"
			hint="A reference to an item you want to use as the main comparison." />
		<cfargument name="comparison" type="any" required="true"
			hint="A reference to an item to use for comparison." />
		<cfreturn variables.system.identityHashCode(arguments.reference) EQ variables.system.identityHashCode(arguments.comparison) />
	</cffunction>

	<cffunction name="trimList" access="public" returntype="string" output="false"
		hint="Trims each list item using Trim() and returns a cleaned list using CFML code.">
		<cfargument name="list" type="string" required="true"
			hint="List to trim each item." />
		<cfargument name="delimiters" type="string" required="false" default=","
			hint="The delimiters of the list. Defaults to ',' when not defined." />

		<cfset var trimmedList = "" />
		<cfset var i = 0 />

		<cfloop list="#arguments.list#" index="i" delimiters="#arguments.delimiters#">
			<cfset trimmedList = ListAppend(trimmedList, Trim(i), arguments.delimiters) />
		</cfloop>

		<cfreturn trimmedList />
	</cffunction>

	<cffunction name="trimList_native" access="public" returntype="string" output="false"
		hint="Trims each list item and returns a cleaned list using the native ListItemTrim() BIF if available on this engine.">
		<cfargument name="list" type="string" required="true"
			hint="List to trim each item." />
		<cfargument name="delimiters" type="string" required="false" default=","
			hint="The delimiters of the list. Defaults to ',' when not defined." />
		<cfreturn ListItemTrim(arguments.list, arguments.delimiters) />
	</cffunction>

	<cffunction name="parseAttributesIntoStruct" access="public" returntype="struct" output="false"
		hint="Parses the a list of name/value parameters into a struct.">
		<cfargument name="attributes" type="any" required="true"
			hint="Takes string of name/value pairs (format of 'name1=value1|name2=value2' where '|' is the delimiter) or a struct.">
		<cfargument name="delimiters" type="string" required="false" default="|"
			hint="The delimiters of the list. Defaults to '|' when not defined (must be '|' for backward compatibility)." />

		<cfset var result = StructNew() />
		<cfset var temp = "" />
		<cfset var i = "" />

		<cfif IsSimpleValue(arguments.attributes)>
			<cfloop list="#arguments.attributes#" index="i" delimiters="#arguments.delimiters#">
				<cfif ListLen(i, "=") EQ 2>
					<cfset temp = ListLast(i, "=") />
				<cfelse>
					<cfset temp = "" />
				</cfif>
				<cfset result[ListFirst(i, "=")] = temp />
			</cfloop>
		<cfelseif IsStruct(arguments.attributes)>
			<cfset result = arguments.attributes />
		<cfelse>
			<cfthrow
				type="MachII.framework.InvalidAttributeType"
				message="The 'parseAttributesIntoStruct' method takes a struct or string." />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="parseAttributesBindToEventAndEvaluateExpressionsIntoStruct" access="public" returntype="struct" output="false"
		hint="Parses the a list of name/value parameters into a struct. If a struct, the struct values are NOT evaluated as expressions.">
		<cfargument name="attributes" type="any" required="true"
			hint="Takes string of name/value pairs (format of 'name1=value1|name2=value2' where '|' is the delimiter) or a struct.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager in the context you want to use (parent/child modules)." />
		<cfargument name="delimiters" type="string" required="false" default="|"
			hint="Defaults to '|' when not defined (must be '|' for backward compatibility)." />

		<cfset var eventContext = arguments.appManager.getRequestManager().getRequestHandler().getEventContext() />
		<cfset var event = "" />
		<cfset var propertyManager = arguments.appManager.getPropertyManager() />
		<cfset var expressionEvaluator = arguments.appManager.getExpressionEvaluator() />
		<cfset var result = StructNew() />
		<cfset var temp = "" />
		<cfset var i = "" />

		<!--- Ff there is no current event, then it is the preProcess so get the next event --->
		<cfif eventContext.hasCurrentEvent()>
			<cfset event = eventContext.getCurrentEvent() />
		<cfelseif eventContext.hasNextEvent()>
			<cfset event = eventContext.getNextEvent() />
		<cfelse>
			<cfthrow
				type="MachII.framework.NoEventAvailable"
				message="The 'parseAttributesBindToEventAndEvaluateExpressionsIntoStruct' method cannot find an available event." />
		</cfif>

		<cfif IsSimpleValue(arguments.attributes)>
			<cfloop list="#arguments.attributes#" index="i" delimiters="#arguments.delimiters#">
				<cfif ListLen(i, "=") EQ 2>
					<cfset temp = ListLast(i, "=") />

					<!--- Check if the value is an expression and if so, evaluate the expression --->
					<cfif expressionEvaluator.isExpression(temp)>
						<cfset temp = expressionEvaluator.evaluateExpression(temp, event, propertyManager) />
					</cfif>
				<cfelse>
					<cfset temp = event.getArg(ListFirst(i, "=")) />
				</cfif>
				<cfset result[ListFirst(i, "=")] = temp />
			</cfloop>
		<cfelseif IsStruct(arguments.attributes)>
			<cfset result = arguments.attributes />
		<cfelse>
			<cfthrow
				type="MachII.framework.InvalidAttributeType"
				message="The 'parseAttributesAndEvaluateExpressionsIntoStruct' method takes a struct or a string." />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="copyToScope" access="public" returntype="void" output="false"
		hint="Copies an evaluation string to a scope.">
		<cfargument name="evaluationString" type="string" required="true"
			hint="The string to evaluate." />
		<cfargument name="scopeReference" type="struct" required="true"
			hint="A reference to the scope in which to place the scope copies." />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager in the context you want to use (parent/child modules)." />`

		<cfset var event = arguments.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var propertyManager = arguments.appManager.getPropertyManager() />
		<cfset var expressionEvaluator = arguments.appManager.getExpressionEvaluator() />
		<cfset var stem = "" />
		<cfset var key = "" />
		<cfset var element = "" />

		<cfloop list="#arguments.evaluationString#" index="stem">
			<!--- Remove any spaces or carriage returns or this will fail --->
			<cfset stem = Trim(stem) />

			<cfif ListLen(stem, "=") EQ 2>
				<cfset element = ListGetAt(stem, 2, "=") />
				<cfset key = ListGetAt(stem, 1, "=") />
				<cfif expressionEvaluator.isExpression(element)>
					<cfset arguments.scopeReference[key] = expressionEvaluator.evaluateExpression(element, event, propertyManager) />
				<cfelse>
					<cfset arguments.scopeReference[key] = element />
				</cfif>
			<cfelse>
				<cfset element = stem />
				<cfset key = stem />
				<cfif expressionEvaluator.isExpression(stem)>
					<!--- It would be better to replace this with RegEx --->
					<cfset key = ListLast(ListFirst(REReplaceNoCase(key, "^\${(.*)}$", "\1", "all"), ":"), ".") />
					<cfset arguments.scopeReference[key] = expressionEvaluator.evaluateExpression(element, event, propertyManager) />
				<cfelse>
					<cfset arguments.scopeReference[key] = stem />
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="escapeHtml" access="public" returntype="string" output="false"
		hint="Escapes special characters '<', '>', '""' and '&' except it leaves already escaped entities alone unlike HtmlEditFormat().">
		<cfargument name="input" type="string" required="true"
			hint="String to escape." />
		<!--- The & is a special case since could be part of an already escaped entity with the RegEx--->
		<!--- Deal with the easy characters with the ReplaceList--->
		<cfreturn ReplaceList(REReplaceNoCase(arguments.input, "&(?!([a-zA-Z][a-zA-Z0-9]*|(##\d+)){2,6};)", "&amp;", "all"), '<,>,"', "&lt;,&gt;,&quot;") />
	</cffunction>

	<cffunction name="escapeHtml_native" access="public" returntype="string" output="false"
		hint="Escapes special characters '<', '>', '""' and '&' with the native HtmlEditFormat() - only use on CFML engines where the double encoding issue has been fixed.">
		<cfargument name="input" type="string" required="true"
			hint="String to escape." />
		<cfreturn HtmlEditFormat(arguments.input) />
	</cffunction>

	<cffunction name="getFileInfo_cfdirectory" access="public" returntype="any" output="false"
		hint="Mocks the getFileInfo() BIF for CFML engines that don't already support it.">
		<cfargument name="path" type="string" required="true" />

		<cfset var fileInfo = "" />

		<cfdirectory action="LIST" directory="#GetDirectoryFromPath(arguments.path)#"
			name="fileInfo" filter="#GetFileFromPath(arguments.path)#" />

		<cfset QueryAddColumn(fileInfo, "lastModified", "varchar", ArrayNew(1)) />

		<cfif fileInfo.recordcount EQ 1>
			<cfset fileInfo.lastModified[1] = fileInfo.dateLastModified[1] />
		</cfif>

		<cfreturn fileInfo />
	</cffunction>

	<cffunction name="translateExceptionType" access="public" returntype="string" output="false"
		hint="Translations exception types into something that can be rethrown.">
		<cfargument name="type" type="string" required="true"
			hint="The type to translation." />

		<cfset var illegalExceptionTypes = "security,expression,application,database,template,missingInclude,expression,lock,searchengine,object" />
		<cfset var exceptionType = arguments.type />

		<!---
			Adobe CF strangely (or more stupidly) disallows you from throwing exception with
			one of the "built-in" exception types. Oddly, it enforces some and not others
			despite what the documenation states. It would be nice to be able to rebundle
			and rethrow an exception with the "original" exception type.
		--->
		<cfif ListFindNoCase(illegalExceptionTypes, exceptionType)>
			<cfset exceptionType = "_" & exceptionType />
		</cfif>

		<cfreturn exceptionType />
	</cffunction>

	<cffunction name="buildMessageFromCfCatch" access="public" returntype="string" output="false"
		hint="Builds a message string from a cfcatch.">
		<cfargument name="caughtException" type="any" required="true"
			hint="A cfcatch to build a message with." />
		<cfargument name="correctTemplatePath" type="string" required="false"
			hint="Used to correct the reported template path and line number." />

		<cfset var message = "" />
		<cfset var i = 0 />

		<!--- Set always available cfcatch data points --->
		<cfset message = "Type: " & arguments.caughtException.type />
		<cfset message = message & " || Message: " & arguments.caughtException.message />
		<cfset message = message & " || Detail: " & arguments.caughtException.detail />

		<!--- Set additional information on missing file name if available --->
		<cfif StructKeyExists(arguments.caughtException, "missingFileName")>
			<cfset message = message & " || Missing File Name: " & arguments.caughtException.missingFileName />
		</cfif>

		<!--- Set additional information on the template if available --->

		<!--- Try to correct the reported template path and line --->
		<cfif StructKeyExists(arguments, "correctTemplatePath")>
			<cfif StructKeyExists(arguments.caughtException, "tagcontext")
				AND IsArray(arguments.caughtException.tagcontext)
				AND ArrayLen(arguments.caughtException.tagcontext) GTE 1>
				<cfloop from="#ArrayLen(arguments.caughtException.tagcontext)#" to="1" step="-1" index="i">
					<!--- Write details if tag context template ends with the requested correct template path --->
					<cfif arguments.caughtException.tagcontext[i].template.endsWith(arguments.correctTemplatePath)>
						<cfset message = message & " || Base Template: " & arguments.caughtException.tagcontext[i].template />
						<cfif StructKeyExists(arguments.caughtException.tagcontext[i], "line")>
							<cfset message = message & " at line " & arguments.caughtException.tagcontext[i].line />
						</cfif>
						<cfbreak />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfif StructKeyExists(arguments.caughtException, "template")>
			<cfset message = message & " || Original Template: " & arguments.caughtException.template />
			<cfif StructKeyExists(arguments.caughtException, "line")>
				<cfset message = message & " at line " & arguments.caughtException.line />
			</cfif>
		<cfelseif StructKeyExists(arguments.caughtException, "tagcontext")
			AND IsArray(arguments.caughtException.tagcontext)
			AND ArrayLen(arguments.caughtException.tagcontext) GTE 1>
			<cfset message = message & " || Original Template: " & arguments.caughtException.tagcontext[1].template />
			<cfif StructKeyExists(arguments.caughtException.tagcontext[1], "line")>
				<cfset message = message & " at line " & arguments.caughtException.tagcontext[1].line />
			</cfif>
		</cfif>

		<!--- Set additional information on the database if available --->
		<cfif arguments.caughtException.type EQ "database">
			<cfif StructKeyExists(arguments.caughtException, "datasource")>
				<cfset message = message & " || Datasource: " & arguments.caughtException.datasource />
			</cfif>
			<cfif StructKeyExists(arguments.caughtException, "sql")>
				<cfset message = message & " || SQL: " & arguments.caughtException.sql />
			</cfif>
			<cfif StructKeyExists(arguments.caughtException, "where")>
				<cfset message = message & " || SQL Were: " & arguments.caughtException.where />
			</cfif>
			<cfif StructKeyExists(arguments.caughtException, "value")>
				<cfset message = message & " || Value: " & arguments.caughtException.value />
			</cfif>
		</cfif>

		<cfreturn message />
	</cffunction>

	<cffunction name="getHTTPHeaderStatusTextByStatusCode" access="public" returntype="string" output="false"
		hint="Gets the HTTP header status text by status code.">
		<cfargument name="statusCode" type="numeric" required="true" />

		<cfif StructKeyExists(variables.statusCodeShortcutMap, arguments.statusCode)>
			<cfreturn variables.statusCodeShortcutMap[arguments.statusCode] />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

	<cffunction name="getMimeTypeByFileExtension" access="public" returntype="string" output="false"
		hint="Gets a MIME type(s) by file extension(s). Ignores any values that do not start with a '.' unless instructed.">
		<cfargument name="input" type="any" required="true"
			hint="A list or array of file extensions.  Ignores any values that do not start with a '.' as a concrete MIME type which allows for mixed input of extensions and MIME types." />
		<cfargument name="customMimeTypes" type="struct" required="false"
			hint="Custom mime-type map (key=file extension, value=mime-type). Keys that conflict with the base mime-type map will be overridden." />
		<cfargument name="evaluateAllAsFileExtensions" type="boolean" required="false" default="false"
			hint="Allows you to evaluate a list as file extensions whether or not they start with '.'." />

		<cfset var output = "" />
		<cfset var mimeTypes= StructNew() />
		<cfset var i = 0 />

		<cfif NOT IsArray(arguments.input)>
			<cfset arguments.input = ListToArray(trimList(arguments.input)) />
		</cfif>

		<!--- Use StructAppend to not pollute base mime-type map via references when "mixing" custom mime types --->
		<cfif StructKeyExists(arguments, "customMimeTypes")>
			<cfset StructAppend(mimeTypes, variables.mimeTypeMap) />
			<cfset StructAppend(mimeTypes, arguments.customMimeTypes) />
		<cfelse>
			<cfset mimeTypes = variables.mimeTypeMap />
		</cfif>

		<cftry>
			<cfloop from="1" to="#ArrayLen(arguments.input)#" index="i">
				<cfif arguments.input[i].startsWith(".")>
					<cfset output = ListAppend(output, StructFind(mimeTypes, Right(arguments.input[i], Len(arguments.input[i]) -1))) />
				<cfelseif arguments.evaluateAllAsFileExtensions AND NOT arguments.input[i].startsWith(".")>
					<cfset output = ListAppend(output, StructFind(mimeTypes, arguments.input[i])) />
				<cfelseif NOT evaluateAllAsFileExtensions>
					<cfset output = ListAppend(output, arguments.input[i]) />
				</cfif>
			</cfloop>
			<cfcatch type="any">
				<cfthrow
					type="MachII.framework.InvalidFileExtensionType"
					message="The 'getMimeTypeByFileExtension' method cannot find a valid MIME type conversion for a file extension of '#arguments.input[i]#' in the input '#arguments.input.toString()#'." />
			</cfcatch>
		</cftry>

		<cfreturn output />
	</cffunction>

	<cffunction name="getMimeTypeMap" access="public" returntype="struct" output="false"
		hint="Returns the base mimeTypeMap for ad-hoc utility use.">
		<cfreturn variables.mimeTypeMap />
	</cffunction>

	<cffunction name="cleanPathInfo" access="public" returntype="string" output="false"
		hint="Cleans the path info to an usable string including UrlDecode().">
		<cfargument name="pathInfo" type="string" required="true"
			hint="The path info to use usually the value from 'cgi.PATH_INFO'." />
		<cfargument name="scriptName" type="string" required="true"
			hint="The script name to use usually the value from 'cgi.SCRIPT_NAME'. This is required to fix IIS6 goofiness with path info." />
		<cfargument name="urlDecode" type="boolean" required="false" default="true"
			hint="Decides if the path info should be Url decoded. Defaults to true." />

		<cfset var cleanPathInfo = arguments.pathInfo />

		<!--- Remove script name from the path info since IIS6 breaks the RFC specification by prepending the script name --->
		<cfif Len(arguments.scriptName) AND cleanPathInfo.toLowerCase().startsWith(arguments.scriptName.toLowerCase())>
			<cfset cleanPathInfo = ReplaceNoCase(cleanPathInfo, arguments.scriptName, "", "one") />
		</cfif>

		<cfif arguments.urlDecode>
			<cfreturn UrlDecode(cleanPathInfo) />
		<cfelse>
			<cfreturn cleanPathInfo />
		</cfif>
	</cffunction>

	<cffunction name="createDatetimeFromHttpTimeString" access="public" returntype="date" output="false"
		hint="Creates an UTC datetime from an HTTP time string.">
		<cfargument name="httpTimeString" type="string" required="true"
			hint="An HTTP time string in the format of '11 Aug 2010 17:58:48 GMT'." />

		<cfset var rawArray = ListToArray(ListLast(arguments.httpTimeString, ","), " ") />
		<cfset var rawTimePart = ListToArray(rawArray[4], ":") />

		<cfreturn CreateDatetime(rawArray[3], DateFormat("#rawArray[2]#/1/2000", "m"), rawArray[1], rawTimePart[1], rawTimePart[2], rawTimePart[3]) />
	</cffunction>

	<cffunction name="convertTimespanStringToSeconds" access="public" returntype="numeric" output="false"
		hint="Converts a timespan string (e.g. 0,0,0,0) into seconds.">
		<cfargument name="timespanString" type="string" required="true"
			hint="The input timespan string." />

		<cfset var timespan = CreateTimespan(ListGetAt(arguments.timespanString, 1), ListGetAt(arguments.timespanString, 2), ListGetAt(arguments.timespanString, 3), ListGetAt(arguments.timespanString, 4)) />

		<cfreturn Round((timespan * 60) / 0.000694444444444) />
	</cffunction>

	<cffunction name="filePathClean" access="public" returntype="string" output="false"
		hint="Clean the file path for directory transversal type attacks.">
		<cfargument name="filePath" type="string" required="true"
			hint="The 'dirty' file path to be cleaned."/>

		<cfset var fileParts = "" />
		<cfset var cleanedFilePath = "" />
		<cfset var i = 0 />
		<cfset var isUNC = false />

		<!--- Check if UNC path --->
		<cfif arguments.filePath.startsWith("\\")>
			<cfset isUNC = true />
		</cfif>

		<!---
		Convert any "\" to  "/" which will work on any OS which allows us to not worry
		about "./", "../", ".\" and "..\" types
		--->
		<cfset arguments.filePath = ReplaceNoCase(arguments.filePath, "\", "/") />

		<!--- Explode the file path into part --->
		<cfset fileParts = ListToArray(arguments.filePath, "/") />

		<!---
		Work through the file parts in reverse in case we have to delete empty parts
		(such as /path/to//file.txt where // ends up being an empty array element) or
		directory transversal indicators such as "." or ".."
		--->
		<cfloop from="#ArrayLen(fileParts)#" to="1" index="i" step="-1">
			<!--- Strip any empty file parts or file parts that are all dots --->
			<cfif NOT Len(fileParts[i]) OR REFindNocase(fileParts[i], "^\.{1,}$")>
				<cfset ArrayDeleteAt(fileParts, i) />
			</cfif>
		</cfloop>

		<!--- Reinsert UNC if that was the in the original path --->
		<cfif isUNC>
			<cfset cleanedFilePath = "\\" & ArrayToList(fileParts, "/") />
		<!--- Reinsert the initial slash if in the original path --->
		<cfelseif arguments.filePath.startsWith("/")>
			<cfset cleanedFilePath = "/" & ArrayToList(fileParts, "/") />
		<cfelse>
			<cfset cleanedFilePath = ArrayToList(fileParts, "/") />
		</cfif>

		<cfreturn cleanedFilePath />
	</cffunction>

</cfcomponent>