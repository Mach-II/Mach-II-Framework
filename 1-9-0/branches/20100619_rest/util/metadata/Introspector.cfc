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

Author: Doug Smith (doug.smith@daveramsey.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
Class to introspect components and functions, primarily to find annotations that
are used to declare Mach-II functionality without requiring separate definitions
in an XML config file.
--->
<cfcomponent
	displayname="Introspector"
	output="false"
	hint="Class to introspect definitions of components and functions, primarily to find annotations.">

	<!---
	PROPERTIES
	--->
	<cfset variables.matcher = CreateObject("component", "MachII.util.matching.SimplePatternMatcher").init() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Introspector" output="false"
		hint="Constructor for the Introspector.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="findFunctionsWithAnnotations" access="public" returntype="Array" output="false"
		hint="Returns the definition of all of the functions in the input Component instance that have an annotation with the input namespace. An annotation attribute has a namespace and a colon delimiter, like 'rest:uri'. An Array of Structs is used so that if walkTree is true, each object in the hierarchy is listed in reverse order.">
		<cfargument name="object" type="Component" required="true"
			hint="The component to introspect for its definition." />
		<cfargument name="namespace" type="String" required="true"
			hint="The namespace of the annotations. Searches for '<namespace>:' in function attributes." />
		<cfargument name="walkTree" type="boolean" required="false" default="false"
			hint="When true, search for function definitions up the inheritance hierarchy of the input object." />
		<cfargument name="walkTreeStopClass" type="string" required="false" default=""
			hint="When walkTree is true, optionally pass in the full CFC dot path of the superclass to stop the search. If not included, searches until there are no more superclasses." />

		<cfset var searchPattern = arguments.namespace & ":*"/>
		<cfset var definitions = getFunctionDefinitions(object:arguments.object,
										searchPattern:searchPattern,
										walkTree:arguments.walkTree,
										walkTreeStopClass:arguments.walkTreeStopClass) />

		<cfreturn definitions />
	</cffunction>

	<cffunction name="getFunctionDefinitions" access="public" returntype="Array" output="false"
		hint="Returns the definition of all of the functions in the input Component instance. An Array of Structs is used so that if walkTree is true, each object in the hierarchy is listed in order. The key of the struct is the fully qualified path name of the component.">
		<cfargument name="object" type="Component" required="true"
			hint="The component to introspect for its definition." />
		<cfargument name="searchPattern" type="String" required="false" default=""
			hint="An optional search pattern. When present, only functions that have at least one attribute that matches the searchPattern will be returned." />
		<cfargument name="walkTree" type="boolean" required="false" default="false"
			hint="When true, search for function definitions up the inheritance hierarchy of the input object." />
		<cfargument name="walkTreeStopClass" type="string" required="false" default=""
			hint="When walkTree is true, optionally pass in the full CFC dot path of the superclass to stop the search. If not included, searches until there are no more superclasses." />

		<cfset var definitions = ArrayNew(1) />
		<cfset var metadata = GetMetadata(object) />
		<cfset var currDefinition = getThisComponentFunctionDefinitions(metadata:metadata, searchPattern:arguments.searchPattern) />

		<!--- Append the definition of the input object first --->
		<cfif NOT StructIsEmpty(currDefinition)>
			<cfset ArrayAppend(definitions, currDefinition) />
		</cfif>

		<cfif arguments.walkTree EQ true >
			<!--- Walk up the object hierarchy and retrieve function definitions from any superclasses --->
			<cfloop condition="#StructKeyExists(metadata, "extends")#">
				<cfset metadata = metadata.extends />
				<cfset currDefinition = getThisComponentFunctionDefinitions(metadata:metadata, searchPattern:arguments.searchPattern) />
				<cfif NOT StructIsEmpty(currDefinition)>
					<cfset ArrayAppend(definitions, currDefinition) />
					<cfif currDefinition.component EQ walkTreeStopClass>
						<!--- Bail out if we're at the requested stop class --->
						<cfbreak />
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn definitions />
	</cffunction>

	<cffunction name="getComponentDefinition" access="public" returntype="Array" output="false"
		hint="Returns the definition of the input component instance. An Array of Structs is used so that if walkTree is true, each object in the hierarchy is listed in order. (When walkTree is false, only one Struct will be in the Array.)">
		<cfargument name="object" type="Component" required="true"
			hint="The component to introspect for its definition." />
		<cfargument name="walkTree" type="boolean" required="false" default="false"
			hint="When true, search for component definitions up the inheritance hierarchy of the input object." />
		<cfargument name="walkTreeStopClass" type="string" required="false" default=""
			hint="When walkTree is true, optionally pass in the full CFC dot path of the superclass to stop the search. If not included, searches until there are no more superclasses." />

		<cfset var definitions = ArrayNew(1) />
		<cfset var metadata = GetMetadata(object) />
		<cfset var currDefinition = getThisComponentDefinition(metadata) />

		<!--- Append the definition of the input object first --->
		<cfset ArrayAppend(definitions, currDefinition) />

		<cfif arguments.walkTree>
			<!--- Walk up the object hierarchy and retrieve superclass definitions --->
			<cfloop condition="#StructKeyExists(metadata, "extends")#">
				<cfset metadata = metadata.extends />
				<cfset currDefinition = getThisComponentDefinition(metadata) />
				<cfset ArrayAppend(definitions, currDefinition) />
				<cfif currDefinition.component EQ walkTreeStopClass>
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn definitions />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getThisComponentDefinition" access="private" returntype="Struct" output="false"
		hint="Returns the definition for the input component metadata. Returned struct just includes data directly related to the component, not the functions or any superclasses.">
		<cfargument name="metadata" type="Struct" required="true"
			hint="The component to introspect for its definition." />

		<cfset var definition = StructNew() />
		<cfset var keys = StructKeyArray(arguments.metadata) />
		<cfset var currKey = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(keys)#" index="i">
			<cfset currKey = keys[i] />

			<!--- We don't need the extends or functions structs in this context --->
			<cfif NOT ListFindNoCase("extends,functions", currKey)>
				<cfset definition[currKey] = arguments.metadata[currKey] />
			</cfif>
		</cfloop>

		<!--- Add the fully qualified path name of the superclass to the definition --->
		<cfif StructKeyExists(arguments.metadata, "extends")>
			<cfset definition.superclass = arguments.metadata.extends.name />
		</cfif>
		<!--- Add alias of fullname called "component" to make API consistent --->
		<cfset definition.component = arguments.metadata.name />

		<cfreturn definition />
	</cffunction>

	<cffunction name="getThisComponentFunctionDefinitions" access="private" returntype="Struct" output="false"
		hint="Returns the definition of the functions for the input component metadata. The returned struct has the fully qualified path name of the component as the key, and an array of function definition structs as the value.">
		<cfargument name="metadata" type="Struct" required="true"
			hint="The component to introspect for its function definitions." />
		<cfargument name="searchPattern" type="String" required="false" default=""
			hint="An optional search pattern. When present, only functions that have at least one attribute that matches the searchPattern will be returned." />

		<cfset var definition = StructNew() />
		<cfset var matchedFunctions = "" />
		<cfset var currFunction = "" />
		<cfset var currKey = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<cfif StructKeyExists(arguments.metadata, "name") AND StructKeyExists(arguments.metadata, "functions")>
			<cfif Len(arguments.searchPattern) GT 0>
				<cfset matchedFunctions = ArrayNew(1) />

				<cfloop from="1" to="#ArrayLen(arguments.metadata.functions)#" index="i">
					<cfset currFunction = arguments.metadata.functions[i] />

					<!--- Loop through each function attribute, and if any match, then add the function to the returned array and break. --->
					<cfloop collection="#currFunction#" item="currKey">
						<cfif variables.matcher.match(arguments.searchPattern, currKey)>
							<cfset ArrayAppend(matchedFunctions, currFunction) />
							<cfbreak />
						</cfif>
					</cfloop>
				</cfloop>
			<cfelse>
				<cfset matchedFunctions = arguments.metadata.functions />
			</cfif>
		</cfif>

		<!--- Only add data if we have functions --->
		<cfif IsArray(matchedFunctions) AND ArrayLen(matchedFunctions) GT 0>
			<cfset definition.component = arguments.metadata.name />
			<cfset definition.functions = matchedFunctions />
		</cfif>

		<cfreturn definition />
	</cffunction>

</cfcomponent>