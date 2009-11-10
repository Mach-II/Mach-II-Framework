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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	type		= The type of link. Supports type shortcuts 'icon', 'rss', 'atom' and 'html', otherwise a complete MIME type is required.
	href		= The href of the link tag.
- OPTIONAL ATTRIBUTES
	outputType	= Indicates the output type for the generated HTML code ('head', 'inline'). Link tags must be in the HTML head section according to W3C specification. Use the value of inline with caution.
	
N.B. Links to CSS files should use the <style> tag's "src" attribute.
--->
<cfif thisTag.ExecutionMode IS "start">
	
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("link", true) />
	
	<!--- Setup required --->
	<!--- This tag requires one of these attributes: 'src', 'event'or  'route'
		or an exception will be thrown. ensureOneByList() is not used for performance. --->
	
	<!--- If the src is not present, then make an URL using event/module/route --->
	<cfparam name="attributes.href" type="string"
		default="#makeUrl()#" />
	<cfset ensureByName("type") />
	
	<!--- Setup optional --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
		
	<!---
		Cleanup additional tag attributes so additional attributes is not polluted with duplicate attributes
		Normalized namespaced attributes have already been removed.
	--->
	<cfset variables.additionalAttributes = StructNew() />
	<cfset StructAppend(variables.additionalAttributes, attributes) />
	<cfset StructDelete(variables.additionalAttributes, "href", "false") />
	<cfset StructDelete(variables.additionalAttributes, "type", "false") />
	<cfset StructDelete(variables.additionalAttributes, "outputType", "false") />
	<cfset StructDelete(variables.additionalAttributes, "output", "false") />
	<cfset StructDelete(variables.additionalAttributes, "event", "false") />
	<cfset StructDelete(variables.additionalAttributes, "module", "false") />
	<cfset StructDelete(variables.additionalAttributes, "route", "false") />
	<cfset StructDelete(variables.additionalAttributes, "p", "false") />
	<cfset StructDelete(variables.additionalAttributes, "q", "false") />
	
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addLink(attributes.type, attributes.href, variables.additionalAttributes, attributes.outputType) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />