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
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	src		= [string] The path or the shortcut to the image
	alt		= [string] The alternative text for the image (if not defined this is included)
- OPTIONAL ATTRIBUTES (BUT REQUIRED BY THE API)
	width	= [string|numeric|null] The width of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used.
	height	= [string|numeric|null] The height of the image in pixels or percentage if a percent sign `%` is defined. A value of '-1' will cause this attribute to be omitted. Auto dimension are applied when zero-length string is used.
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("img", true) />
	
	<!--- This tag requires one of these attributes: 'src', 'event'or  'route'
		or an exception will be thrown. ensureOneByList() is not used for performance. --->
	
	<!--- If the src is not present, then make an URL using event/module/route --->
	<cfif NOT StructKeyExists(attributes, "src")>
		<cfset attributes.src = makeUrl() />
	</cfif>
	
	<!--- Setup optional but requried by the addImage() API --->
	<cfparam name="attributes.width" type="string" 
		default="" />
	<cfparam name="attributes.height" type="string" 
		default="" />
	<cfparam name="attributes.alt" type="string" 
		default="" />
	
	<!---
		Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes
		Normalized namespaced attributes have already been removed.
	--->
	<cfset variables.additionalAttributes = StructNew() />
	<cfset StructAppend(variables.additionalAttributes, attributes) />
	<cfset StructDelete(variables.additionalAttributes, "src", "false") />
	<cfset StructDelete(variables.additionalAttributes, "width", "false") />
	<cfset StructDelete(variables.additionalAttributes, "height", "false") />
	<cfset StructDelete(variables.additionalAttributes, "alt", "false") />
	<cfset StructDelete(variables.additionalAttributes, "output", "false") />
	<cfset StructDelete(variables.additionalAttributes, "event", "false") />
	<cfset StructDelete(variables.additionalAttributes, "module", "false") />
	<cfset StructDelete(variables.additionalAttributes, "route", "false") />
	<cfset StructDelete(variables.additionalAttributes, "p", "false") />
	<cfset StructDelete(variables.additionalAttributes, "q", "false") />
	
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addImage(attributes.src, attributes.width, attributes.height, attributes.alt, variables.additionalAttributes) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />