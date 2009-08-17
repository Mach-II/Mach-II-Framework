<cfsilent>
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

	<cfset var expressionEvaluator = caller.this.getAppManager().getExpressionEvaluator() />
	<cfset var event = request.event />	
	<cfset var propertyManager = caller.this.getPropertyManager() />
	
	<cfset request._MachIIFormLib.bind = event />

	<cfif StructKeyExists(arguments, "target")>
		<!--- Target is an unkown path type --->
		<cfif IsSimpleValue(attributes.target)>
			<cftry>
				<!--- Target is a M2 EL expression --->
				<cfif expressionEvaluator.isExpression(attributes.target)>
					<cfset request._MachIIFormLib.bind = expressionEvaluator.evaluateExpression(attributes.target, event, propertyManager) />
				<!--- Target is a simple shortcut path --->
				<cfelse>
					<cfset request._MachIIFormLib.bind = expressionEvaluator.evaluateExpressionBody("event." & attributes.target, event, propertyManager) />
				</cfif>
				<cfcatch>
					<cfthrow type="MachII.customtags.form.#getTagType()#.noBindInEvent"
						message="A bind path named '#attributes.target#' is not available the current event object." />
				</cfcatch>
			</cftry>
		<!--- Target is a bean --->
		<cfelse>
			<cfset request._MachIIFormLib.bind = attributes.target />
		</cfif>
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

<cffunction name="ensureByName" access="public" returntype="void" output="false"
	hint="Ensures a key is available by name in the attributes.">
	<cfargument name="name" type="string" required="true"
		hint="The name of the key to look up." />
	<cfif NOT StructKeyExists(attributes, arguments.name) >
		<cfthrow type="MachII.customtags.form.#variables.tagType#.noAttribute"
			message="The '#variables.tagType#' tag must have an attribute named '#arguments.name#." />
	</cfif>
</cffunction>

<cffunction name="resolvePath" access="public" returntype="any" output="false"
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

	<cfif ListLen(arguments.path, ".") GT 0>
		<cfset value = resolvePath(arguments.path, value) />
	</cfif>
	
	<cfreturn value />
</cffunction>

</cfsilent>