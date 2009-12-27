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
$Id: form.cfm 1664 2009-07-10 00:21:50Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- REQUIRED ATTRIBUTES
	bind		= the path to use to bind to process this form (default to event object)

- OPTIONAL ATTRIBUTES
--->
<cfif thisTag.ExecutionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/form/helper/formTagBuilder.cfm" />		
	<cfset setupTag("bind", false) />

	<!--- Store a reference to the original bind if available --->
	<cfif IsDefined("request._MachIIFormLib.bind")>
		<cfset variables.originalBind = request._MachIIFormLib.bind />
	</cfif>
	
	<!--- Store a reference to the original prefix if available --->
	<cfif IsDefined("request._MachIIFormLib.prefix")>
		<cfset variables.originalPrefix = request._MachIIFormLib.prefix />
	</cfif>
	
	<!--- Setup the bind --->
	<cfif StructKeyExists(attributes, "target")>
		<cfif Len(attributes.target)>
			<cfset setupBind(attributes.target) />
		<cfelse>
			<cfset setupBind() />
		</cfif>
	</cfif>
	
	<!--- Setup prefix --->
	<cfif StructKeyExists(attributes, "prefix")>
		<cfset request._MachIIFormLib.prefix = attributes.prefix />
	</cfif>
<cfelse>
	<!--- Restore the original bind --->
	<cfif StructKeyExists(variables, "originalBind")>
		<cfset request._MachIIFormLib.bind = variables.originalBind />
	</cfif>
	
	<cfif StructKeyExists(variables, "originalPrefix")>
		<cfset request._MachIIFormLib.prefix = variables.originalPrefix />
	<cfelse>
		<cfset request._MachIIFormLib.prefix = "" />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />