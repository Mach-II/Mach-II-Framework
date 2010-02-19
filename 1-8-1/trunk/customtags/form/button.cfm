<cfsetting enablecfoutputonly="true" /><cfsilent>
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

Author: Matt Woodward (matt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	name		= AUTOMATIC|[string]
	value		= AUTOMATIC|[string]
- OPTIONAL ATTRIBUTES
	type 	 	= button|reset|submit|[submit]
	src 		= string|[null]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("input", true) />

	<!--- if there's a src attribute provided and the type is anything other than 
			submit, throw an error --->
	<cfif StructKeyExists(attributes, "src")>
		<cfif StructKeyExists(attributes, "type") AND 
				CompareNoCase(attributes.type, "submit") neq 0>
			<cfthrow type="MachII.customtags.form.button" 
					message="The 'src' attribute may only be used with a button of type 'submit'" 
					detail="When using the 'src' attribute to provide an image to be used as a button, the button must be a submit button. Types of 'button' and 'reset' are not supported with an image input." />
		<cfelse>
			<cfset attributes.type = "image" />
		</cfif>
		
		<!--- Translate the src path and append timestamp using the HtmlHelper if available --->
		<cfif isHtmlHelperAvailable()>
			<cfset attributes.src = locateHtmlHelper().computeAssetPath("img", attributes.src) />
		</cfif>
	</cfif>
	
	<!--- Resolve path if defined--->
	<cfif StructKeyExists(attributes, "path")>
		<cfparam name="attributes.value" type="string" 
			default="#wrapResolvePath(attributes.path)#" />
	<cfelse>
		<cfset attributes.path = "submit" />
	</cfif>
	
	<!--- Set defaults --->
	<cfset attributes.name = resolveName() />
	<cfparam name="attributes.id" type="string" 
		default="#attributes.name#" />
	<cfparam name="attributes.value" type="string" 
		default="submit" />
	<cfparam name="attributes.type" type="string" 
		default="submit" />
		
	<cfset setFirstElementId(attributes.id) />
			
	<!--- if this is an image input and they don't provide an alt attribute, 
			use value as alt --->
	<cfif attributes.type eq "image" and NOT StructKeyExists(attributes, "alt")>
		<cfset attributes.alt = attributes.value />
	</cfif>
	
	<!--- Set required attributes--->
	<cfset setAttribute("name") />
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("alt") />
	<cfset setAttributeIfDefined("src") />
	<cfset setAttributeIfDefined("type") />
	<cfset setAttributeIfDefinedAndTrue("disabled", "disabled") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />

<cfelse>	
	<cfset thisTag.generatedContent = doStartTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />