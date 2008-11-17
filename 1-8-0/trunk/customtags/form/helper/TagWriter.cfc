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
--->
<cfcomponent displayname="TagWriter"
	output="false"
	hint="Writes a tag">

	<!---
	PROPERTIES
	--->
	<cfset variables.tagType = "" />
	<cfset variables.selfClosingTag = false />
	<cfset variables.attributeCollection = StructNew() />
	<cfset variables.content = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="TagWriter" output="false"
		hint="Initializes the tag writer.">
		<cfargument name="tagType" type="string" required="true" />
		<cfargument name="selfClosingTag" type="boolean" required="false" default="false" />
		
		<cfset setTagType(arguments.tagType) />
		<cfset setSelfClosingTag(arguments.selfClosingTag) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
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
			<cfset result = result & HtmlEditFormat(getContent()) />
		</cfif>
		
		<cfif NOT isSelfClosingTag()>
			<cfset result = result & '</'& getTagType() &'>' />
		</cfif>
		
		<cfreturn result />
	</cffunction>	
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getAttributeCollection" access="private" returntype="struct" output="false"
		hint="Gets the attribute collection.">
		<cfreturn variables.attributeCollection />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setTagType" access="private" returntype="void" output="false">
		<cfargument name="tagType" type="string" required="true" />
		<cfset variables.tagType = arguments.tagType />
	</cffunction>
	<cffunction name="getTagType" access="public" returntype="string" output="false">
		<cfreturn variables.tagType />
	</cffunction>
	
	<cffunction name="setSelfClosingTag" access="private" returntype="void" output="false">
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
	
	<cffunction name="setAttribute" access="public" returntype="void" output="false"
		hint="Sets an attribute to the tag.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfset variables.attributeCollection[arguments.name] = arguments.value />
	</cffunction>

</cfcomponent>