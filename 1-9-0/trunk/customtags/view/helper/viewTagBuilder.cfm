<cfsilent>
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
Concrete tag builder for the Mach-II view tag library inherits from base builder.
--->

<cfinclude template="/MachII/customtags/baseTagBuilder.cfm" />

<!---
PROPERTIES
--->
<cfset setTagLib("view") />

<!---
PUBLIC FUNCTIONS
--->
<cffunction name="wrapIEConditionalComment" access="public" returntype="string" output="false"
	hint="Wraps an IE conditional comment around the incoming code.">
	<cfargument name="forIEVersion" type="string" required="true" />
	<cfargument name="code" type="string" required="true" />
	
	<cfset var conditional = Trim(arguments.forIEVersion) />
	<cfset var comment = Chr(13) />
	
	<!--- "all" in the version means all versions of IE --->
	<cfif conditional EQ "all">
		<cfset comment = comment & "<!--[if IE]>" & Chr(13) />
	<!--- No operator (just version number) means EQ for version --->
	<cfelseif IsNumeric(conditional)>
		<cfset comment = comment & "<!--[if IE " & conditional &  "]>" & Chr(13)  />
	<!--- Use operator and version --->
	<cfelseif ListLen(conditional, " ") EQ 2>
		<cfset comment = comment & "<!--[if " & ListFirst(conditional, " ") & " IE " & ListLast(conditional, " ") &  "]>" & Chr(13)  />
	<!--- Throw an exception because of no match for conditional --->
	<cfelse>
		<cfthrow type="MachII.customtags.view.invalidIEConditional"
			message="An IE conditional of '#conditional#' is invalid."
			detail="The conditional value must be 'all', IE version number (numeric) or operator (lt, gte) plus IE version number." />
	</cfif>
	
	<!--- Append the code --->
	<cfset comment = comment & arguments.code & Chr(13) & "<![endif]-->" & Chr(13) />

	<cfreturn comment />
</cffunction>

</cfsilent>