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
Helper functions for the Mach-II form tag library.

STANDARD ATTRIBUTES
id			= AUTOMATIC|[string]
class		= [string]
style		= [string]
dir			= ltr|rtl (Sets the text direction)
lang		= [string] (Sets the language code)
title		= [string]
accesskey	= [string]
tabindex	= [string]

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
<cfset variables.utils = request.eventContext.getAppManager().getUtils() />

<!---
PUBLIC FUNCTIONS
--->
<cffunction name="setupTag" access="public" returntype="void" output="false"
	hint="Sets up a form element tag for use.">
	<cfargument name="tagType" type="string" required="true" />
	<cfargument name="selfClosingTag" type="boolean" required="true" />
	
	<cfset setTagType(arguments.tagType) />
	<cfset setSelfClosingTag(arguments.selfClosingTag) />
	
	<!--- This is used by output buffers of the options, radioGroup and checkboxGroup tags --->
	<cfparam name="attributes.output" default="false" 
		type="boolean" />
	
	<cfif NOT thisTag.hasEndTag>
		<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.endTag"
			message="The '#getTagType()#' in the '#getTagLib()#' tag library must have an end tag." />
	</cfif>
</cffunction>

<cffunction name="ensureByName" access="public" returntype="void" output="false"
	hint="Ensures a key is available by name in the attributes.">
	<cfargument name="name" type="string" required="true"
		hint="The name of the key to look up." />
	<cfargument name="detail" type="string" required="false" default="No additional details."
		hint="Additional details to use in the exception." />
	<cfif NOT StructKeyExists(attributes, arguments.name) >
		<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.noAttribute"
			message="The '#variables.tagType#' tag must have an attribute named '#arguments.name#."
			detail="#arguments.detail#" />
	</cfif>
</cffunction>

<cffunction name="ensureOneByNameList" access="public" returntype="void" output="false"
	hint="Ensures at least *one* of the keys is available by name in the attributes.">
	<cfargument name="nameList" type="string" required="true"
		hint="The name of the key to look up." />
	<cfargument name="detail" type="string" required="false" default="No additional details."
		hint="Additional details to use in the exception." />
	
	<cfset var i = "" />
	
	<cfloop list="#arguments.nameList#" index="i">
		<cfif StructKeyExists(attributes, i)>
			<!--- Short-circuit and exit since we ensured at least one of the attributes --->
			<cfreturn />
		</cfif>
	</cfloop>
	
	<!--- If we've gotten to this point, then none of the required attributes were found --->
	<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.noAttribute"
		message="The '#variables.tagType#' tag must have an attribute named of one of the following: '#arguments.nameList#."
		detail="#arguments.detail#" />
</cffunction>

<cffunction name="getParentTagAttribute" access="public" returntype="string" output="false"
	hint="Gets the parents tag's attribute value (ex: used by option tag to get select tag id)">
	<cfargument name="parentTagName" type="string" required="true" />
	<cfargument name="attributeName" type="string" required="true" />	
	<cfreturn GetBaseTagData("cf_" & arguments.parentTagName).attributes[arguments.attributeName] />
</cffunction>

<cffunction name="appendGeneratedContentToBuffer" access="public" returntype="void" output="false"
	hint="Appends the passed generated content to the parent tag output buffer struct.">
	<cfargument name="generatedContent" type="string" required="true" />
	<cfargument name="outputBuffer" type="struct" required="true" />
	<cfset arguments.outputBuffer.content = arguments.outputBuffer.content & arguments.generatedContent & Chr(13) />
</cffunction>

<cffunction name="replaceSpaces" access="public" returntype="string" output="false"
	hint="Replaces all spaces with underscores (_).">
	<cfargument name="value" type="string" required="true" />
	<cfreturn ReplaceNoCase(arguments.value, " ", "_", "all") />
</cffunction>

<cffunction name="doStartTag" access="public" returntype="string" output="false"
	hint="Returns the start tag for this tag type.">
	
	<cfset var result = '<'& getTagType() />
	<cfset var attributeCollection = getAttributeCollection() />
	<cfset var i = "" />
	
	<cfloop collection="#attributeCollection#" item="i">
		<cfif i EQ "value">
			<cfset result = result & ' ' & i & '="' & variables.utils.escapeHtml(attributeCollection[i]) & '"' />
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

<cffunction name="setAttributeIfDefinedAndTrue" access="public" returntype="void" output="false"
	hint="Adds an attribute by name if defined and true (boolean).">
	<cfargument name="attributeName" type="string" required="true" />
	<cfargument name="specialValue" type="string" required="true" />
	
	<cfif StructKeyExists(attributes, arguments.attributeName) 
		AND IsBoolean(attributes[arguments.attributeName]) 
		AND attributes[arguments.attributeName]>
		<cfset setAttribute(arguments.attributeName, arguments.specialValue) />
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
	<cfif StructKeyExists(attributes, "title")>
		<cfset setAttribute("title", attributes.title) />
	</cfif>
	<cfif StructKeyExists(attributes, "accesskey")>
		<cfset setAttribute("accesskey", attributes.accesskey) />
	</cfif>
	<cfif StructKeyExists(attributes, "tabindex")>
		<cfset setAttribute("tabindex", attributes.tabindex) />
	</cfif>
</cffunction>

<cffunction name="setNonStandardAttributes" access="public" returntype="void" output="false"
	hint="Adds non-standard attributes (namespaced with 'x:' and in the 'x' attribute) to the tag writer if defined.">
	
	<cfset var nonStandardAttributes = normalizeStructByNamespace("x") />	
	
	<cfif StructKeyExists(attributes, "x")>
		<cfset StructAppend(nonStandardAttributes, request.eventContext.getAppManager().getUtils().parseAttributesIntoStruct(attributes.x), false) />
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
		<cfset setAttribute("onclick", attributes.onClick) />
	</cfif>
	<cfif StructKeyExists(attributes, "ondblcick")>
		<cfset setAttribute("ondblclick", attributes.onDblClick) />
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
<cffunction name="locateHtmlHelper" access="public" returntype="MachII.properties.HtmlHelperProperty" output="false"
	hint="Locates the HtmlHelperProperty for use by certain view library custom tags.">
	
	<cfset var htmlHelper = request.eventContext.getAppManager().getPropertyManager().getProperty("_HTMLHelper", "") />
	
	<cfif IsObject(htmlHelper)>
		<cfreturn htmlHelper />
	<cfelse>
		<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.htmlHelperUnavailable"
			message="The '#getTagType()#' in the '#getTagLib()#' tag library cannot locate an HtmlHelperProperty configured for this application."
			detail="Do you have an HtmlHelperProperty setup for in this application?" />
	</cfif>
</cffunction>
<cffunction name="isHtmlHelperAvailable" access="public" returntype="boolean" output="false"
	hint="Checks if the HtemloHelperProperty is available for use.">
	<cfreturn request.eventContext.getAppManager().getPropertyManager().isPropertyDefined("_HTMLHelper") />
</cffunction>

<cffunction name="getAttributeCollection" access="public" returntype="struct" output="false"
	hint="Gets the attribute collection.">
	<cfreturn variables.attributeCollection />
</cffunction>

<cffunction name="normalizeStructByNamespace" access="public" returntype="struct" output="false">
	<cfargument name="namespace" type="string" required="true"
		hint="A string that is the namespace prefix. The ':' is appended automatically." />
	<cfargument name="target" type="struct" required="true" default="#attributes#"
		hint="A reference to the struct that holds the namespaced keys. Defaults to 'attributes' scope." />
	
	<cfset var tagAttributes = StructNew() />
	<cfset var key = "" />
	<cfset var namespaceStem = arguments.namespace & ":" />
		
	<cfloop collection="#arguments.target#" item="key">
		<cfif key.toLowercase().startsWith(namespaceStem)>
			<cfset tagAttributes[ReplaceNoCase(key, namespaceStem, "", "one").toLowercase()] = arguments.target[key] />
			<!--- Clean up and remove from the target struct --->
			<cfset StructDelete(arguments.target,  key, "false") />	
		</cfif>
	</cfloop>
	
	<!---
		Commercial versions of BlueDragon does not handle namespace prefixes and normalizes 
		automatically by putting the key names in all uppercase and adding a key p="true"
	--->
	<cfif StructKeyExists(arguments.target, arguments.namespace) 
		AND IsBoolean(arguments.target[arguments.namespace])
		AND arguments.target[arguments.namespace]>
		<cfloop collection="#arguments.target#" item="key">
			<cfif Compare(key, key.toUppercase()) EQ 0>
				<cfset tagAttributes[key.toLowercase()] = arguments.target[key] />
				<cfset StructDelete(arguments.target,  key, "false") />	
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn tagAttributes />
</cffunction>

<cffunction name="evaluateExpressionStruct" access="public" returntype="void" output="false"
	hint="Evaluates a struct for expressions using the Expresion Evaluator.">
	<cfargument name="targets" type="struct" required="true"
		hint="A struct of targets to evaluate for expressions." />
	<cfargument name="event" type="MachII.framework.Event" required="false"
		default="#request.event#" />
	<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="false"
		default="#request.eventContext.getAppManager().getPropertyManager()#" />
	<cfargument name="expressionEvaluator" type="MachII.util.ExpressionEvaluator" required="false"
		default="#request.eventContext.getAppManager().getExpressionEvaluator()#" />
	
	<cfset var key = "" />
	
	<cfloop collection="#arguments.targets#" item="key">
		<cfif arguments.expressionEvaluator.isExpression(arguments.targets[key])>
			<cfset arguments.targets[key] = arguments.expressionEvaluator.evaluateExpression(arguments.targets[key], arguments.event, arguments.propertyManager) />
		</cfif>
	</cfloop>
</cffunction>

<cffunction name="createCleanId" access="public" returntype="string" output="false"
	hint="Creates a cleaned version to be used as an 'id'. Changes spaces to '_' and removes most punctuation (that conforms to RegEx '[[:punct:]]').">
	<cfargument name="dirtyId" type="string" required="true"  />
	
	<cfset var cleanedId = arguments.dirtyId />
	
	<cfset cleanedId = REReplaceNoCase(cleanedId, "[[:punct:]]", "", "all") />
	<cfset cleanedId = ReplaceNoCase(cleanedId, " ", "_", "all") />
	
	<cfreturn cleanedId />
</cffunction>

<cffunction name="makeUrl" access="public" returntype="string" output="false"
	hint="Makes URLs for custom tags.">
	<cfargument name="attributeNameForEvent" type="string" default="event" />
	<cfargument name="attributeNameForModule" type="string" default="module" />
	<cfargument name="attributeNameForRoute" type="string" default="route" />
	<cfargument name="attributeNameForUrlParameters" type="string" default="p" />

	<!--- Build url parameters --->
	<cfset var urlParameters = normalizeStructByNamespace("p") />
	<cfset var queryStringParameters = "" />
	<cfset var builtUrl = "" />
	
	<!--- Convert and merge the "string" version of the URL parameters into a struct --->
	<cfif StructKeyExists(attributes, arguments.attributeNameForUrlParameters)>
		<cfset StructAppend(urlParameters, variables.utils.parseAttributesIntoStruct(attributes[arguments.attributeNameForUrlParameters]), false) />
	</cfif>

	<!--- Evaluate the url parameters --->
	<cfif StructCount(urlParameters)>
		<cfset evaluateExpressionStruct(urlParameters) />
	</cfif>
	
	<!--- Set required attributes--->
	<cfif StructKeyExists(attributes, arguments.attributeNameForEvent)>
		<cfif StructKeyExists(attributes, arguments.attributeNameForModule)>
			<cfset builtUrl = request.eventContext.getAppManager().getRequestManager().buildUrl(attributes[arguments.attributeNameForModule], attributes[attributeNameForEvent], urlParameters) />
		<cfelse>
			<cfset builtUrl = request.eventContext.getAppManager().getRequestManager().buildUrl(request.eventContext.getAppManager().getModuleName(), attributes[arguments.attributeNameForEvent], urlParameters) />
		</cfif>
	<cfelseif StructKeyExists(attributes, arguments.attributeNameForRoute)>
		<!--- Build query string parameters --->
		<cfset queryStringParameters = normalizeStructByNamespace("q") />

		<!--- Convert and merge the "string" version of the query string parameters into a struct --->
		<cfif StructKeyExists(attributes, "q")>
			<cfset StructAppend(queryStringParameters, variables.utils.parseAttributesIntoStruct(attributes.q), false) />
		</cfif>
		
		<!--- Evaluate the query string parameters --->
		<cfif StructCount(queryStringParameters)>
			<cfset evaluateExpressionStruct(queryStringParameters) />
		</cfif>

		<cfset builtUrl = request.eventContext.getAppManager().getRequestManager().buildRouteUrl(attributes[arguments.attributeNameForRoute], urlParameters, queryStringParameters) />
	<cfelse>
		<cfif getTagLib() EQ "view" AND getTagType() EQ "a">
			<cfif StructKeyExists(attributes, "useCurrentUrl")>
				<cfset builtUrl = request.eventContext.getAppManager().getRequestManager().buildCurrentUrl(urlParameters) />
			<cfelse>
				<cfthrow type="MachII.customtags.view.a.noEventRouteOrUseCurrentUrlAttribute"
					message="The 'a' tag must have an attribute named 'event', 'route' or 'useCurrentUrl'." />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.noEventOrRouteAttribute"
				message="The '#getTagType()#' tag must have an attribute named '#arguments.attributeNameForEvent#' or '#arguments.attributeNameForRoute#'." />
		</cfif>
	</cfif>
	
	<cfreturn variables.utils.escapeHtml(builtUrl) />
</cffunction>

<cffunction name="booleanize" access="public" returntype="numeric" output="false"
	hint="Converts 'Yes/No' and 'True/False' strings to 'true' boolean. Leaves numerics alone.">
	<cfargument name="input" type="any" required="true" 
		hint="Input to convert." />
	<cfargument name="attributeName" type="string" required="true" 
		hint="Name of the attribute." />

	<cfif IsNumeric(arguments.input)>
		<cfreturn arguments.input />	
	<cfelseif IsSimpleValue(arguments.input)>
		<cfif REFindNoCase("yes|true", arguments.input)>
			<cfreturn 1 />
		<cfelseif REFindNoCase("no|false", arguments.input)>
			<cfreturn 0 />
		<cfelse>
			<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.#arguments.attributeName#.UnableToBooleanize"
				message="Unable to booleanize an attribute named '#arguments.attributeName#' in the '#variables.tagType#' library."
				detail="Incoming value: #arguments.input#" />
		</cfif>
	<cfelse>
		<cfthrow type="MachII.customtags.#getTagLib()#.#getTagType()#.#arguments.attributeName#.UnableToBooleanize"
			message="Unable to booleanize an attribute named '#arguments.attributeName#' in the '#variables.tagType#' library."
			detail="Incoming value is a struct, array or object." />	
	</cfif>
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
	<cfargument name="content" type="string" required="true"
		hint="Inner body content." />
	<cfargument name="escapeHtml" type="boolean" required="false" default="false"
		hint="Escapes special HTML characters." />
	
	<cfif arguments.escapeHtml>
		<cfset arguments.content = variables.utils.escapeHtml(arguments.content) />
	</cfif>
	<cfset variables.content = arguments.content />
</cffunction>
<cffunction name="getContent" access="public" returntype="string" output="false">
	<cfreturn variables.content />
</cffunction>

</cfsilent>