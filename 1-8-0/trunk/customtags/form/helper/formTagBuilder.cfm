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
<cffunction name="setupFormTag" access="public" returntype="void" output="false"
	hint="Sets up the form tag for use.">
	
	<cfset setTagType("form") />
	<cfset setSelfClosingTag(false) />
		
	<cfset request._MachIIFormLib.bind = request.event />
	
	<cfif StructKeyExists(attributes, "bind")>
		<!--- Passed in path --->
		<cfif IsSimpleValue(attributes.bind)>
			<cfif request.event.isArgDefined(ListFirst(attributes.bind, "."))>
				<cfset request._MachIIFormLib.bind = resolvePath(attributes.bind) />
			<cfelse>
				<cfthrow type="MachII.customtags.form.form.noBindInEvent"
					message="A bind path named '#attributes.bind#' is not available the current event object." />
			</cfif>
		<!--- Passed in bean --->
		<cfelse>
			<cfset request._MachIIFormLib.bind = attributes.bind />
		</cfif>
	</cfif>
	
	<cfif NOT thisTag.hasEndTag>
		<cfthrow type="MachII.customtags.form.#getTagType()#"
			message="The #getTagType()# must have an end tag." />
	</cfif>
</cffunction>

<cffunction name="ensurePathOrName" acces="public" returntype="void" output="false"
	hint="Ensures a path or name is available in the attributes.">
	<cfif NOT StructKeyExists(attributes, "path") 
		AND NOT StructKeyExists(attributes, "name")>
		<cfthrow type="MachII.customtags.form.#variables.tagData.tagName#.noPath"
			message="This tag must have an attribute named 'path' or 'name' or both." />
	</cfif>
</cffunction>

<cffunction name="ensureByName" acces="public" returntype="void" output="false"
	hint="Ensures a key is available by name in the attributes.">
	<cfargument name="name" type="string" required="true"
		hint="The name of the key to look up." />
	<cfif NOT StructKeyExists(attributes, arguments.name) >
		<cfthrow type="MachII.customtags.form.#variables.tagData.tagName#.noPath"
			message="This tag must have an attribute named '#arguments.name#." />
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