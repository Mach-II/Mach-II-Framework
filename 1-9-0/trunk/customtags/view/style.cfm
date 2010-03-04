<cfsetting enablecfoutputonly="true" /><cfsilent>
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
Updated version: 1.9.0

Notes:
- OPTIONAL ATTRIBUTES
	href			= [string|list|array] A single string, comma-delimited list or array of web accessible hrefs to .css files.
	outputType		= [string] Indicates the output type for the generated HTML code ('head', 'body', 'inline').
	media 			= [string] specifies styles for different media types
	forIEVersion 	= [string] wraps an IE conditional comment around the incoming code
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("style", false) />

	<!--- Setup defaults --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
	<cfparam name="attributes.forIEVersion" type="string" 
		default="" />
		
	<!--- Set required attributes--->
	<cfset setAttribute("type", "text/css") />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("media") />
	
	<!--- Set standard attributes --->
	<cfset setStandardAttributes() />
		
<cfelse>
	<!--- Setup generation variables --->
	<cfset variables.bodyContent = Trim(thisTag.GeneratedContent) />
	<cfset thisTag.GeneratedContent = "" />
	
	<!--- Ensure attributes if no body content --->
	<cfif NOT Len(variables.bodyContent)>
		<cfset ensureOneByNameList("href,event,route") />
	</cfif>
	
	<!--- If the href is not present, then make an URL using event/module/route --->
	<cfif NOT StructKeyExists(attributes, "href")
		AND (StructKeyExists(attributes, "event") OR StructKeyExists(attributes, "route"))>
		<cfset attributes.href = makeUrl() />
	</cfif>
  
  <!--- Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes --->
  <cfset variables.additionalAttributes = StructNew() />
  <cfset StructAppend(variables.additionalAttributes, attributes) />
  <cfset StructDelete(variables.additionalAttributes, "href", "false") />
  <cfset StructDelete(variables.additionalAttributes, "forIEVersion", "false") />
  <cfset StructDelete(variables.additionalAttributes, "output", "false") />
  <cfset StructDelete(variables.additionalAttributes, "outputType", "false") />
  <cfset StructDelete(variables.additionalAttributes, "event", "false") />
  <cfset StructDelete(variables.additionalAttributes, "module", "false") />
  <cfset StructDelete(variables.additionalAttributes, "route", "false") />
  <cfset StructDelete(variables.additionalAttributes, "p", "false") />
  <cfset StructDelete(variables.additionalAttributes, "q", "false") />
	
	<!--- For external files --->
	<cfif StructKeyExists(attributes, "href")>
		<cfif attributes.outputType NEQ "inline">
			<cfset locateHtmlHelper().addStylesheet(attributes.href, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
		<cfelse>
			<cfset thisTag.GeneratedContent = locateHtmlHelper().addStylesheet(attributes.href, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
		</cfif>
	</cfif>
	
	<!--- For body content --->
	<cfif Len(variables.bodyContent)>
    <cfif attributes.outputType NEQ "inline">
      <cfset locateHtmlHelper().addStylesheetBody(variables.bodyContent, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
    <cfelse>
      <cfset thisTag.GeneratedContent = thisTag.GeneratedContent & locateHtmlHelper().addStylesheetBody(variables.bodyContent, variables.additionalAttributes, attributes.outputType, attributes.forIEVersion) />
    </cfif>
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />