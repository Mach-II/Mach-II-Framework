<!---
License:
Copyright 2009 GreatBizTools, LLC

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

Created version: 1.5.0
Updated version: 1.8.0

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


	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Utils" output="false"
		hint="Initialization function called by the framework.">
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
		<cfset var i = 0 />
		
		<!--- Unified slashes due to operating system differences and convert ./ to / --->
		<cfset combinedWorkingPath = Replace(combinedWorkingPath, "\", "/", "all") />
		<cfset combinedWorkingPath = Replace(combinedWorkingPath, "/./", "/", "all") />
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
		
		<!--- Reinsert the leading slash if *nix system --->
		<cfif Left(arguments.baseDirectory, 1) IS "/">
			<cfset resolvedPath = "/" & resolvedPath />
		</cfif>
		
		<!--- Reinsert the trailing slash if the relativePath was just a directory --->
		<cfif Right(arguments.relativePath, 1) IS "/">
			<cfset resolvedPath = resolvedPath & "/" />
		</cfif>
		 
		<cfreturn resolvedPath />
	</cffunction>

	<cffunction name="createThreadingAdapter" access="public" returntype="MachII.util.threading.ThreadingAdapter" output="false"
		hint="Creates a threading adapter if the CFML engine has threading capabilities.">
		
		<cfset var threadingAdapter = "" />
		<cfset var serverName = server.coldfusion.productname />
		<cfset var serverMajorVersion = ListFirst(server.coldfusion.productversion, ",") />
		<cfset var serverMinorVersion = 0 />
		
		<!--- Make sure we have a minor product version--Open BlueDragon doesn't have one on its initial release 
				but this will be added; however, probably not wise to always assume it's there. Set a 
				default of 0 in case it doesn't exist. --->
		<cfif ListLen(server.coldfusion.productversion, ",") gt 1>
			<cfset serverMinorVersion = ListGetAt(server.coldfusion.productversion, 2, ",") />
		</cfif>
		
		<!--- Adobe ColdFusion 8+ --->
		<cfif FindNoCase("ColdFusion", serverName) AND serverMajorVersion GTE 8>
			<cfset threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterCF").init() />
		<!--- Open / NewAtlanta BlueDragon 7+ threading engine is not currently compatible,
			however will be compatiable in future versions
		<cfelseif FindNoCase("BlueDragon", serverName) AND serverMajorVersion GTE 7>
			<cfset threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterBD").init() />
		 --->
		<!--- Railo 3.0 will introduce a threading engine
		<cfelseif FindNoCase("Railo", serverName) AND serverMajorVersion GTE 3>
			<cfset threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapterRA").init() />
		 --->
		<!--- Default theading adapter (used to check if threading is allowed on this engine) --->
		<cfelse>
			<cfset threadingAdapter = CreateObject("component", "MachII.util.threading.ThreadingAdapter").init() />
		</cfif>
		
		<cfreturn threadingAdapter />
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
		hint="Trims each list item using Trim() and returns a cleaned list.">
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

		<cfset var event = arguments.appManager.getRequestManager().getRequestHandler().getEventContext().getCurrentEvent() />
		<cfset var propertyManager = arguments.appManager.getPropertyManager() />
		<cfset var expressionEvaluator = arguments.appManager.getExpressionEvaluator() />		
		<cfset var result = StructNew() />
		<cfset var temp = "" />
		<cfset var i = "" />
		
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
	
	<cffunction name="buildMessageFromCfCatch" access="public" returntype="string" output="false"
		hint="Builds a message string from a cfcatch.">
		<cfargument name="caughtException" type="any" required="true"
			hint="A cfcatch to build a message with." />
		
		<cfset var message = "" />

		<!--- Set always available cfcatch data points --->
		<cfset message = "Type: " & arguments.caughtException.type />
		<cfset message = message & " || Message: " & arguments.caughtException.message />
		<cfset message = message & " || Detail: " & arguments.caughtException.detail />
		
		<!--- Set additional information on missing file name if available --->
		<cfif StructKeyExists(arguments.caughtException, "missingFileName")>
			<cfset message = message & " || Missing File Name: " & arguments.caughtException.missingFileName />
		</cfif>
		
		<!--- Set additional information on the template if available --->
		<cfif StructKeyExists(arguments.caughtException, "template")>
			<cfset message = message & " ||  Template: " & arguments.caughtException.template />
			<cfif StructKeyExists(arguments.caughtException, "line")>
				<cfset message = message & " at line " & arguments.caughtException.line />
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
		</cfif>
		
		<cfreturn message />
	</cffunction>

</cfcomponent>