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
	actionEvent		= name of event to process this form

- OPTIONAL ATTRIBUTES
	actionModule	= name of module to use with the event to process this form
	actionUrlParams	= name value pairs in pipe (|) list of url params or struct
	encType			= specifies the encType of the form (defaults to "multipart/form-data")
	method			= specifies the type of form post to make (defaults to "post")
	bind			= the path to use to bind to process this form (default to event object)
--->
</cfsilent>
<cfif thisTag.ExecutionMode IS "start">
	<cfsilent>

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />
	<cfset setupTag("form", false) />
	
	<!--- Setup the bind --->
	<cfif StructKeyExists(attributes, "bind")>
		<cfset setupBind(attributes.bind) />
	<cfelse>
		<cfset setupBind() />
	</cfif>

	<!--- Set defaults --->
	<cfparam name="attributes.encType" type="string" 
		default="multipart/form-data" />
	<cfparam name="attributes.method" type="string" 
		default="post" />
	<cfparam name="attributes.autoFocus" type="string"
		default="" />

	<cfset setAttribute("action", makeUrl("actionEvent", "actionModule", "actionRoute", "actionUrlParams")) />
	<cfset setAttribute("method") />
	<cfset setAttribute("encType") />
	
	<!--- Set optional attributes --->
	<cfset setAttributeIfDefined("name") />
	<cfset setAttributeIfDefined("target") />
	<cfset setAttributeIfDefined("accept") />
	<cfset setAttributeIfDefined("accept-charset") />
	
	<!--- Set standard and event attributes --->
	<cfset setStandardAttributes() />
	<cfset setNonStandardAttributes() />
	<cfset setEventAttributes() />
	
	<!--- Add event attributes specific to form tag --->
	<cfset setAttributeIfDefined("onsubmit") />
	<cfset setAttributeIfDefined("onreset") />
	
	</cfsilent>
	<cfoutput>#doStartTag()#</cfoutput>
<cfelse>
	<cfoutput>#doEndTag()#</cfoutput>
	<cfif NOT IsBoolean(attributes.autoFocus)
		OR (IsBoolean(attributes.autoFocus) AND attributes.autoFocus)>
		
		<!--- Figure out which id to auto focus to if there is no id supplied --->
		<cfif IsDefined("request._MachIIFormLib.firstElementId") 
			AND (NOT Len(attributes.autoFocus) OR NOT IsBoolean(attributes.autoFocus))>
			<cfset attributes.autoFocus = request._MachIIFormLib.firstElementId />
		</cfif>
		
		<!---
			We use the window._MachIIFormLib_autoFocusOccurred so two 
			forms on a page won't steal an auto-focus
		--->
		<cfimport prefix="view" taglib="/MachII/customtags/view" />
		<cfoutput><view:script outputType="inline">
			if (window._MachIIFormLib_autoFocusOccurred !== 'undefined') {
				document.getElementById('#attributes.autoFocus#').focus();
				window._MachIIFormLib_autoFocusOccurred = true;
			}
		</view:script></cfoutput>
	</cfif>
	
	<!--- Clean up bind as this serves as a "check" by other tags to ensure bind is available --->
	<cfset StructDelete(request, "_MachIIFormLib", false) />
</cfif>
<cfsetting enablecfoutputonly="false" />