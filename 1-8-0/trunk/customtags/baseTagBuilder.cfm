<cfsilent>
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
Helper functions for the Mach-II form tag library.

STANDARD FORM ATTRIBUTES
id			= AUTOMATIC|[string]
class		= [string]
style		= [string]
dir			= ltr|rtl (Sets the text direction)
lang		= [string] (Sets the language code)

EVENT ATTRIBUTES
tabindex	= [numeric]
accesskey	= [string]
onfocus		= [string]
onblur		= [string]
onselect	= [string]
onchange	= [string]
onclick		= [string]
ondblclick	= [string]
onmousedown	= [string]
onmouseup	= [string]
onmouseover	= [string]
onmousemove	= [string]
onmouseout	= [string]
onkeypress	= [string]
onkeydown	= [string]
onkeyup		= [string]
--->

<!---
PROPERTIES
--->
<cfset variables.tagLib = "unknown" />
<cfset variables.tagType = "unknown" />
<cfset variables.selfClosingTag = false />
<cfset variables.attributeCollection = StructNew() />
<cfset variables.content = "" />

<!---
PUBLIC FUNCTIONS
--->
<cffunction name="setupTag" access="public" returntype="void" output="false"
	hint="Sets up a form element tag for use.">
	<cfargument name="tagType" type="string" required="true" />
	<cfargument name="selfClosingTag" type="boolean" required="true" />
	
	<cfset setTagType(arguments.tagType) />
	<cfset setSelfClosingTag(arguments.selfClosingTag) />
	
	<cfif NOT thisTag.hasEndTag>
		<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.endTag"
			message="The '#getTagType()#' in the '#getTagLib()#' tag library must have an end tag." />
	</cfif>
</cffunction>

<cffunction name="getParentTagAttribute" access="public" returntype="string" output="false"
	hint="Gets the parents tag's attribute value (ex: used by option tag to get select tag id)">
	<cfargument name="tagName" type="string" required="true" />
	<cfargument name="attributeName" type="string" required="true" />	
	<cfreturn GetBaseTagData("cf_" & arguments.tagName).attributes[arguments.attributeName] />
</cffunction>

<cffunction name="replaceSpaces" access="public" returntype="string" output="false"
	hint="Replaces all spaces with underscores (_).">
	<cfargument name="value" type="string" required="true" />
	<cfreturn Replace(arguments.value, " ", "_", "all") />
</cffunction>

<cffunction name="doStartTag" access="public" returntype="string" output="false"
	hint="Returns the start tag for this tag type.">
	
	<cfset var result = '<'& getTagType() />
	<cfset var attributeCollection = getAttributeCollection() />
	<cfset var i = "" />
	
	<cfloop collection="#attributeCollection#" item="i">
		<cfif i EQ "value">
			<cfset result = result & ' ' & i & '="' & HTMLEditFormat(attributeCollection[i]) & '"' />
		<cfelse>
			<cfset result = result & ' ' & i & '="' & attributeCollection[i] & '"' />
		</cfif>
	</cfloop>
	
	<cfif NOT isSelfClosingTag()>
		<cfset result = result & '>' />
	<cfelse>
		<cfset result = result & '/>' />
	</cfif>
	
	<cfreturn result />
</cffunction>

<cffunction name="doEndTag" access="public" returntype="string" output="false"
	hint="Returns the end tag for this tag type.">
	
	<cfset var result = "" />	
	
	<cfif Len(getContent())>
		<cfset result = result & getContent() />
	</cfif>
	
	<cfif NOT isSelfClosingTag()>
		<cfset result = result & '</'& getTagType() &'>' />
	</cfif>
	
	<cfreturn result />
</cffunction>

<cffunction name="setAttribute" access="public" returntype="void" output="false"
	hint="Adds an attribute by name if defined.">
	<cfargument name="attributeName" type="string" required="true" />
	<cfargument name="value" type="string" required="false" />
	
	<cfif NOT StructKeyExists(arguments, "value")>
		<cfset arguments.value = attributes[arguments.attributeName] />
	</cfif>

	<cfset variables.attributeCollection[arguments.attributeName] = arguments.value />
</cffunction>

<cffunction name="setAttributes" access="public" returntype="void" output="false"
	hint="Adds attributes.">
	<cfargument name="attributes" type="struct" required="true" />
	<cfset StructAppend(variables.attributeCollection, arguments.attributes, true) />
</cffunction>

<cffunction name="setAttributeIfDefined" access="public" returntype="void" output="false"
	hint="Adds an attribute by name if defined.">
	<cfargument name="attributeName" type="string" required="true" />
	<cfargument name="specialValue" type="string" required="false" />
	
	<cfif StructKeyExists(attributes, arguments.attributeName)>
		<cfif NOT StructKeyExists(arguments, "specialValue")>
			<cfset setAttribute(arguments.attributeName, attributes[arguments.attributeName]) />
		<cfelse>
			<cfset setAttribute(arguments.attributeName, arguments.specialValue) />
		</cfif>
	</cfif>
</cffunction>

<cffunction name="setStandardAttributes" access="public" returntype="void" output="false"
	hint="Adds standard attributes to the tag writer if defined.">

	<cfif StructKeyExists(attributes, "id")>
		<cfset setAttribute("id", attributes.id) />
	</cfif>
	<cfif StructKeyExists(attributes, "class")>
		<cfset setAttribute("class", attributes.class) />
	</cfif>
	<cfif StructKeyExists(attributes, "style")>
		<cfset setAttribute("style", attributes.style) />
	</cfif>
	<cfif StructKeyExists(attributes, "dir")>
		<cfset setAttribute("dir", attributes.dir) />
	</cfif>
	<cfif StructKeyExists(attributes, "lang")>
		<cfset setAttribute("lang", attributes.lang) />
	</cfif>
</cffunction>

<cffunction name="setNonStandardAttributes" access="public" returntype="void" output="false"
	hint="Adds non-standard attributes (namespaced with 'x:' and in the 'x' attribute) to the tag writer if defined.">
	
	<cfset var nonStandardAttributes = normalizeStructByNamespace("x") />	
	
	<cfif StructKeyExists(attributes, "x")>
		<cfset StructAppend(nonStandardAttributes, caller.this.getAppManager().getUtils().parseAttributesIntoStruct(attributes.x), false) />
	</cfif>
	
	<cfset setAttributes(nonStandardAttributes) />
</cffunction>

<cffunction name="setEventAttributes" access="public" returntype="void" output="false"
	hint="Adds event attributes to the tag writer if defined.">

	<!--- The attribute name passed to setAttribute() must be lowercase to be XHTML valid  --->
	<cfif StructKeyExists(attributes, "tabindex")>
		<cfset setAttribute("tabindex", attributes.tabIndex) />
	</cfif>
	<cfif StructKeyExists(attributes, "accesskey")>
		<cfset setAttribute("accesskey", attributes.accessKey) />
	</cfif>
	<cfif StructKeyExists(attributes, "onfocus")>
		<cfset setAttribute("onfocus", attributes.onFocus) />
	</cfif>
	<cfif StructKeyExists(attributes, "onblur")>
		<cfset setAttribute("onblur", attributes.onBlur) />
	</cfif>
	<cfif StructKeyExists(attributes, "onselect")>
		<cfset setAttribute("onselect", attributes.onSelect) />
	</cfif>
	<cfif StructKeyExists(attributes, "onchange")>
		<cfset setAttribute("onchange", attributes.onChange) />
	</cfif>
	<cfif StructKeyExists(attributes, "onclick")>
		<cfset setAttribute("onclick", attributes.onChange) />
	</cfif>
	<cfif StructKeyExists(attributes, "ondblcick")>
		<cfset setAttribute("ondblclick", attributes.onDblClick) />m
	</cfif>
	<cfif StructKeyExists(attributes, "onmousedown")>
		<cfset setAttribute("onmousedown", attributes.onMouseDown) />
	</cfif>
	<cfif StructKeyExists(attributes, "onmouseup")>
		<cfset setAttribute("onmouseup", attributes.onMouseUp) />
	</cfif>
	<cfif StructKeyExists(attributes, "onmouseover")>
		<cfset setAttribute("onmouseover", attributes.onMouseOver) />
	</cfif>
	<cfif StructKeyExists(attributes, "onmousemove")>
		<cfset setAttribute("onmousemove", attributes.onMouseMove) />
	</cfif>
	<cfif StructKeyExists(attributes, "onmouseout")>
		<cfset setAttribute("onmouseout", attributes.onMouseOut) />
	</cfif>
	<cfif StructKeyExists(attributes, "onkeypress")>
		<cfset setAttribute("onkeypress", attributes.onKeyPress) />
	</cfif>
	<cfif StructKeyExists(attributes, "onkeydown")>
		<cfset setAttribute("onkeydown", attributes.onKeyDown) />
	</cfif>
	<cfif StructKeyExists(attributes, "onkeyup")>
		<cfset setAttribute("onkeyup", attributes.onKeyUp) />
	</cfif>
</cffunction>

<!---
PUBLIC FUNCTIONS - UTIL
--->
<cffunction name="getAttributeCollection" access="public" returntype="struct" output="false"
	hint="Gets the attribute collection.">
	<cfreturn variables.attributeCollection />
</cffunction>

<cffunction name="normalizeStructByNamespace" access="public" returntype="struct" output="false">
	<cfargument name="namespace" type="string" required="true" />
	<cfargument name="target" type="struct" required="true" default="#attributes#" />
	
	<cfset var tagAttributes = StructNew() />
	<cfset var key = "" />
	<cfset var namespaceStem = arguments.namespace & ":" />
		
	<cfloop collection="#arguments.target#" item="key">
		<cfif key.toLowercase().startsWith(namespaceStem)>
			<cfset tagAttributes[ReplaceNoCase(key, namespaceStem, "", "one").toLowercase()] = arguments.target[key] />
		</cfif>
	</cfloop>
	
	<cfreturn tagAttributes />
</cffunction>

<cffunction name="evaluateExpressionStruct" access="public" returntype="void" output="false"
	hint="Evaluates a struct for expressions using the Expresion Evaluator.">
	<cfargument name="target" type="struct" required="true" />
	<cfargument name="event" type="MachII.framework.Event" required="false"
		default="#caller.this.getAppManager().getRequestManager().getRequestHandler().getEventContext().getCurrentEvent()#" />
	<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="false"
		default="#caller.this.getPropertyManager()#" />
	<cfargument name="expressionEvaluator" type="MachII.util.ExpressionEvaluator" required="false"
		default="#caller.this.getAppManager().getExpressionEvaluator()#" />
	
	<cfset var key = "" />
	
	<cfloop collection="#arguments.target#" item="key">
		<cfif arguments.expressionEvaluator.isExpression(arguments.target[key])>
			<cfset arguments.target[key] = arguments.expressionEvaluator.evaluateExpression(arguments.target[key], arguments.event, arguments.propertyManager) />
		</cfif>
	</cfloop>
</cffunction>

<!---
ACCESSORS
--->
<cffunction name="setTagLib" access="public" returntype="void" output="false">
	<cfargument name="tagLib" type="string" required="true" />
	<cfset variables.tagLib = arguments.tagLib />
</cffunction>
<cffunction name="getTagLib" access="public" returntype="string" output="false">
	<cfreturn variables.tagLib />
</cffunction>

<cffunction name="setTagType" access="public" returntype="void" output="false">
	<cfargument name="tagType" type="string" required="true" />
	<cfset variables.tagType = arguments.tagType />
</cffunction>
<cffunction name="getTagType" access="public" returntype="string" output="false">
	<cfreturn variables.tagType />
</cffunction>

<cffunction name="setSelfClosingTag" access="public" returntype="void" output="false">
	<cfargument name="selfClosingTag" type="boolean" required="true" />
	<cfset variables.selfClosingTag = arguments.selfClosingTag />
</cffunction>
<cffunction name="isSelfClosingTag" access="public" returntype="boolean" output="false">
	<cfreturn variables.selfClosingTag />
</cffunction>

<cffunction name="setContent" access="public" returntype="void" output="false">
	<cfargument name="content" type="string" required="true" />
	<cfset variables.content = arguments.content />
</cffunction>
<cffunction name="getContent" access="public" returntype="string" output="false">
	<cfreturn variables.content />
</cffunction>

</cfsilent>