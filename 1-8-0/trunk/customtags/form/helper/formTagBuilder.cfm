<cfsilent>
<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
Concrete tag builder for the Mach-II form tag library inherits from base builder.
--->

<cfinclude template="/MachII/customtags/baseTagBuilder.cfm" />

<!---
PROPERTIES
--->
<cfset setTagLib("form") />

<!---
PUBLIC FUNCTIONS
--->
<cffunction name="setupBind" access="public" returntype="void" output="false"
	hint="Sets up a bind by target path.">
	<cfargument name="target" type="any" required="false"
		hint="A target dot path, evaluator expression or object." />

	<cfset var appManager = request.eventContext.getAppManager() />
	<cfset var expressionEvaluator = appManager.getExpressionEvaluator() />
	<cfset var event = request.event />	
	<cfset var propertyManager = appManager.getPropertyManager() />
	
	<cfset request._MachIIFormLib.bind = event />

	<cfif StructKeyExists(arguments, "target")>
		<!--- Target is an unkown path type --->
		<cfif IsSimpleValue(arguments.target)>
			<cftry>
				<!--- Target is a M2 EL expression --->
				<cfif expressionEvaluator.isExpression(arguments.target)>
					<cfset request._MachIIFormLib.bind = expressionEvaluator.evaluateExpression(arguments.target, event, propertyManager) />
				<!--- Target is a simple shortcut path --->
				<cfelse>
					<cfset request._MachIIFormLib.bind = expressionEvaluator.evaluateExpressionBody("event." & arguments.target, event, propertyManager) />
				</cfif>
				<cfcatch>
					<cfthrow type="MachII.customtags.form.#getTagType()#.noBindInEvent"
						message="A bind path with the value of '#arguments.target#' is not available the current event object."
						detail="#cfcatch.message# || #cfcatch.detail#" />
				</cfcatch>
			</cftry>
		<!--- Target is a bean --->
		<cfelse>
			<cfset request._MachIIFormLib.bind = arguments.target />
		</cfif>
	</cfif>
</cffunction>

<cffunction name="setFirstElementId" access="public" returntype="void" output="false"
	hint="Sets the first form element id if not already defined.">
	<cfargument name="id" type="string" required="true" />
	
	<cfif NOT IsDefined("request._MachIIFormLib.firstElementId") OR NOT Len(request._MachIIFormLib.firstElementId)>
		<cfset request._MachIIFormLib.firstElementId = arguments.id />
	</cfif>
</cffunction>

<cffunction name="ensurePathOrName" access="public" returntype="void" output="false"
	hint="Ensures a path or name is available in the attributes.">
	<cfif NOT StructKeyExists(attributes, "path") 
		AND NOT StructKeyExists(attributes, "name")>
		<cfthrow type="MachII.customtags.form.#variables.tagType#.noPath"
			message="This '#variables.tagType#' tag must have an attribute named 'path' or 'name' or both." />
	</cfif>
</cffunction>

<cffunction name="wrapResolvePath" access="public" returntype="any" output="false"
	hint="Wraps the 'resolvePath' method so we can provide good exceptions if needed.">
	<cfargument name="path" type="string" required="true" />
	<cfargument name="bind" type="any" required="false" />
	
	<cftry>
		<cfreturn resolvePath(argumentCollection=arguments) />
		<cfcatch type="any">
			<cfthrow type="MachII.customtags.form.#getTagType()#.unableToBindToPath"
				message="Unable to bind to path '#arguments.path#'. This could be because the path was incorrect or the target CFC caused an exception. This could also be caused because the form element is not wrapped inside a Mach-II form custom tag. See details for more information."
				detail="#cfcatch.message# || #cfcatch.detail#" />
		</cfcatch>
	</cftry>	
</cffunction>

<cffunction name="resolvePath" access="private" returntype="any" output="false"
	hint="Resolves a path and returns a value.">
	<cfargument name="path" type="string" required="true" />
	<cfargument name="bind" type="any" required="false" default="#request._MachIIFormLib.bind#" />
	
	<cfset var value = "" />
	<cfset var key = ListFirst(arguments.path, ".") />
	
	<cfif IsObject(arguments.bind)>
		<cfif getMetaData(arguments.bind).name NEQ "MachII.framework.Event">
			<cfinvoke component="#arguments.bind#"
				method="get#key#"
				returnvariable="value" />
		<cfelse>
			<cfinvoke component="#arguments.bind#"
				method="getArg"
				returnvariable="value">
				<cfinvokeargument name="name" value="#key#" />
			</cfinvoke>
		</cfif>
	<cfelseif IsStruct(arguments.bind)>
		<cfset value = arguments.bind[key] />
	</cfif>
	
	<cfset arguments.path = ListDeleteAt(arguments.path, 1, ".") />

	<cfif FindNoCase(".", arguments.path)>
		<cfset value = resolvePath(arguments.path, value) />
	</cfif>
	
	<cfreturn value />
</cffunction>

<cffunction name="translateCheckValue" access="public" returntype="string" output="false"
	hint="Translates a check value into a usable datatype for certain form tags to use.">
	<cfargument name="checkValue" type="any" required="true"
		hint="The check value to translate." />
	<cfargument name="checkValueCol" type="any" required="false"
		hint="The column name of use with the checkValue is query." />

	<!--- checkValue can be a list, array, or struct, but ultimately 
			we'll use a list to do the comparisons as we build the output --->
	<cfset var checkValues = "" />
	<cfset var i = "" />
	<cfset var item = "" />
	
	<cfif IsSimpleValue(arguments.checkValue)>
		<cfset checkValues = arguments.checkValue />
	<cfelseif IsArray(arguments.checkValue) AND IsSimpleValue(arguments.checkValue[1])>
		<cfloop from="1" to="#ArrayLen(arguments.checkValue)#" index="i">
			<cfset checkValues = ListAppend(checkValues, arguments.checkValue[i]) />
		</cfloop>
	<cfelseif IsStruct(arguments.checkValue)>
		<cfloop collection="#arguments.checkValue#" item="item">
			<cfif StructFind(arguments.checkValue, item)>
				<cfset checkValues = ListAppend(checkValues, item) />
			</cfif>
		</cfloop>
	<cfelseif IsQuery(arguments.checkValue)>
		<cfloop query="arguments.checkValue">
			<cfset checkValues = ListAppend(checkValues, arguments.checkValue[arguments.checkValueCol]) />
		</cfloop>
	<cfelse>
		<cfthrow type="MachII.customtags.form.#getTagType()#.unsupportedCheckValueDatatype" 
				message="Unsupported Data Type for Check Value Attribute" 
				detail="The '#getTagType()#' form tag only supports lists, one-dimensional arrays, queries and structs for the check value attribute." />
	</cfif>
	
	<cfreturn checkValues />
</cffunction>

<cffunction name="sortStructByDisplayOrder" access="public" returntype="array" output="false"
	hint="Sorts an items struct based of the 'displayOrder' attribute.">
	<cfargument name="items" type="struct" required="true" />
	<cfargument name="displayOrder" type="string" required="true" />
	
	<cfset var modifiedItems = StructCopy(arguments.items) />
	<cfset var sortedKeys = ArrayNew(1) />
	<cfset var insertAt = 1 />
	<cfset var hasStar = false />
	<cfset var hasStarOccurred = false />
	<cfset var element = "" />
	<cfset var i = "" />
	
	<cfset arguments.displayOrder = ListToArray(arguments.displayOrder) />
	
	<cfif ArrayLen(arguments.displayOrder)>
		
		<!--- Remove display order keys that do not exist --->
		<cfloop from="#ArrayLen(arguments.displayOrder)#" to="1" step="-1" index="i">
			<cfset element = arguments.displayOrder[i] />
			<cfif element NEQ "*" AND NOT StructKeyExists(arguments.items, element)>
				<cfset ArrayDeleteAt(arguments.displayOrder, i) />
			<cfelseif element EQ "*">
				<cfset hasStar = true />
			</cfif>
		</cfloop>
		
		<!--- We now of a valid display order list with references to keys that exists in the items --->
		
		
		<!--- Remove keys from modified items --->
		<cfloop from="1" to="#ArrayLen(arguments.displayOrder)#" index="i">
			<cfset StructDelete(modifiedItems, arguments.displayOrder[i], false) />
		</cfloop>
		
		<!---
			Create the sorted keys for the "*" part which doesn't have any other display 
			order keys because the modified items structs have had those keys removed
		--->
		<cfif hasStar>
			<cfset sortedKeys = StructSort(modifiedItems, "text") />
		</cfif>
	
		<cfloop from="1" to="#ArrayLen(arguments.displayOrder)#" index="i">
			<cfif arguments.displayOrder[i] EQ "*">
				<cfset hasStarOccurred = true />
			<cfelse>
				<!--- For elements before "*" --->
				<cfif NOT hasStarOccurred>
					<!--- We cannot use ArrayPrepend because the order of the pre "*" would be reversed --->
					<cfset ArrayInsertAt(sortedKeys, insertAt, arguments.displayOrder[i]) />
					<cfset insertAt = insertAt + 1 />
				<!--- For elements after "*" --->
				<cfelse>
					<cfset ArrayAppend(sortedKeys, arguments.displayOrder[i])>
				</cfif>
			</cfif>

		</cfloop>
	<!--- Use this if no displayOrder is specified --->
	<cfelse>
		<cfset sortedKeys = StructSort(items, "text") />
	</cfif>

	<cfreturn sortedKeys />
</cffunction>

</cfsilent>