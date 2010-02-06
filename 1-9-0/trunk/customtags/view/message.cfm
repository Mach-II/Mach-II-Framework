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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:
- REQUIRED ATTRIBUTES
	key					= string
- OPTIONAL ATTRIBUTES
	arguments			= list
	argumentSeparator 	= string
--->

<cfif thisTag.executionMode IS "start">
	<!--- Enforce required attributes --->
	<cfif NOT StructKeyExists(attributes, "key")>
		<cfthrow message="An attributed named 'key' must be defined for this tag." />
	</cfif>
	
	<cfparam name="attributes.argumentSeparator" default="," type="string"/>
	<cfparam name="attributes.defaultString" default="" type="string"/>
	
	<cfif StructKeyExists(attributes, "arguments")>
		<cfset variables.arguments = ListToArray(attributes.arguments, attributes.argumentSeparator)/>
	<cfelse>
		<cfset variables.arguments = ArrayNew(1)/>
	</cfif>
	
	<cfset variables.defaultString = attributes.defaultString/>
	<cfset variables.key = attributes.key/>
	
<cfelse>
	<!--- Output the label message --->
	<cfset ThisTag.GeneratedContent = request.eventContext.getAppManager().getGlobalizationManager().getString(variables.key, getPageContext().getRequest().getLocale(), variables.arguments, variables.defaultString)/>
</cfif>

</cfsilent><cfsetting enablecfoutputonly="false" />