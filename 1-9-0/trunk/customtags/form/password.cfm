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
	name		= AUTOMATIC|[string]
	value		= AUTOMATIC|[string]
	type		= password
- OPTIONAL ATTRIBUTES
	disabled	= disabled|[null]
	readonly	= readonly|[null]
	maxlength	= [numeric] 
	size		= [numeric]
- STANDARD TAG ATTRIBUTES
- EVENT ATTRIBUTES
--->
<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />	
	<cfset setupTag("input", true) />
	
	<!--- Ensure certain attributes are defined --->
	<cfset ensurePathOrName() />
	
	<!--- Resolve path if defined --->
	<cfif StructKeyExists(attributes, "path")>
		<!--- Only populate with value if showPassowrd --->
		<cfif StructKeyExists(attributes, "showPassword") 
			AND attributes.showPassword>
			<cfparam name="attributes.value" type="string" 
				default="#wrapResolvePath(attributes.path)#" />
		</cfif>
	<cfelse>
		<cfset attributes.path = "" />
	</cfif>
	
	<!--- Set defaults --->
	<cfset attributes.name = resolveName() />
	<cfparam name="attributes.value" type="string" 
		default="" />
	<cfparam name="attributes.id" type="string" 
		default="#attributes.name#" />
	
	<cfset setFirstElementId(attributes.id) />
	
	<!--- Set required attributes--->
	<cfset setAttribute("type", "password") />
	<cfset setAttribute("name") />
	<cfset setAttribute("value") />

	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("size") />
	<cfset setAttributeIfDefined("maxLength") />
	<cfset setAttributeIfDefinedAndTrue("readOnly", "readOnly") />
	<cfset setAttributeIfDefinedAndTrue("disabled", "disabled") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />

<cfelse>
	<cfset thisTag.GeneratedContent = doStartTag() />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />