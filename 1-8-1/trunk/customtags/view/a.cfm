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
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	event	= [string] the event name to build the URL with
	- OR -
	route	= [string] the route name to build the URL with
- OPTIONAL ATTRIBUTES
	module	= [string] the module name to build the URL with (not valid with route attribute)
	label	= [string] the value between the start and closing <a> tags
	p		= [string|struct] name / value pair list or struct of URL parameters to build the URL with
	q		= [string|struct] name / value pair list or struct of query string parameters to append to the end of a route (only valid with route attribute)
	x		= [string|struct] name / value pair list or struct of additional non-standard attribute to insert into the rendered tag output
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
- NAMESPACES
	p:key	= Indicates that the attribute "key" name should be used as
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("a", false) />

	<!--- This tag requires one of these attributes: 'href', 'event', 'route' or 'useCurrentUrl'
		or an exception will be thrown. ensureOneByList() is not used for performance. --->

	<!--- If the href is not present, then make an URL using event/module/route --->
	<cfif StructKeyExists(attributes, "href")>
		<cfset setAttribute("href", attributes.href) />
	<cfelse>
		<cfset setAttribute("href", makeUrl()) />
	</cfif>

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("charset") />
	<cfset setAttributeIfDefined("coords") />
	<cfset setAttributeIfDefined("hreflang") />
	<cfset setAttributeIfDefined("name") />
	<cfset setAttributeIfDefined("rel") />
	<cfset setAttributeIfDefined("rev") />
	<cfset setAttributeIfDefined("shape") />
	<cfset setAttributeIfDefined("target") />
	<cfset setAttributeIfDefined("type") />

	<!--- Set standard, non-standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />
<cfelse>
	<!--- Use the label attribute value if defined otherwise default to the nested content --->
	<cfif StructKeyExists(attributes, "label")>
		<cfset setContent(attributes.label, true) />
	<cfelse>
		<cfset setContent(Trim(thisTag.GeneratedContent)) />
	</cfif>

	<cfset thisTag.GeneratedContent = doStartTag() & doEndTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />