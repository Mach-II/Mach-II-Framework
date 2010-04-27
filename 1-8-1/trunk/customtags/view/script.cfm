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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.1

Notes:
- OPTIONAL ATTRIBUTES
	src			= [string|list|array] A single string, comma-delimited list or array of web accessible hrefs to .js files.
	outputType	= [string] Indicates the output type for the generated HTML code (head, inline).

External files are *always* outputted inline first or appended to the head first before
any inline javascript code.
--->

<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("script", false) />

	<!--- Setup defaults --->
	<cfparam name="attributes.outputType" type="string"
		default="head" />
	<cfparam name="attributes.forIEVersion" type="string"
		default="" />

	<!--- Set required attributes--->
	<cfset setAttribute("type", "text/javascript") />

<cfelse>
	<!--- Setup generation variables --->
	<cfset variables.bodyContent = Trim(thisTag.GeneratedContent) />
	<cfset thisTag.GeneratedContent = "" />

	<!--- Ensure attributes if no body content --->
	<cfif NOT Len(variables.bodyContent)>
		<cfset ensureOneByNameList("src,event,route") />
	</cfif>

	<!--- If the src is not present, then make an URL using event/module/route --->
	<cfif NOT StructKeyExists(attributes, "src")
		AND (StructKeyExists(attributes, "event") OR StructKeyExists(attributes, "route"))>
		<cfset attributes.src = "external:" & makeUrl() />
	</cfif>

	<!--- For external files --->
	<cfif StructKeyExists(attributes, "src")>
		<cfif attributes.outputType EQ "head">
			<cfset locateHtmlHelper().addJavascript(attributes.src, attributes.outputType, attributes.forIEVersion) />
		<cfelse>
			<cfset thisTag.GeneratedContent = locateHtmlHelper().addJavascript(attributes.src, attributes.outputType, attributes.forIEVersion) />
		</cfif>
	</cfif>

	<!--- For body content --->
	<cfif Len(variables.bodyContent)>
		<cfset setContent(Chr(13) & '//<![CDATA[' & Chr(13) & variables.bodyContent & Chr(13) & '//]]>' & Chr(13)) />

		<cfset variables.js = doStartTag() & doEndTag() />

		<!--- Wrap in an IE conditional if defined --->
		<cfif Len(attributes.forIEVersion)>
			<cfset variables.js = wrapIEConditionalComment(attributes.forIEVersion, variables.js) />
		</cfif>

		<cfif attributes.outputType EQ "head">
			<cfset request.eventContext.addHTMLHeadElement(variables.js) />
		<cfelse>
			<cfset thisTag.GeneratedContent = thisTag.GeneratedContent & variables.js />
		</cfif>
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />