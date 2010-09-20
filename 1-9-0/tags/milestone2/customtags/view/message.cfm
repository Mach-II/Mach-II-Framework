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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:
- REQUIRED ATTRIBUTES
	key					= [string] The key of the message to get
- OPTIONAL ATTRIBUTES
	arguments			= [list|array] A list or array of argument to substitute in the message
	argumentSeparator 	= [string] The list separater to use when converting the 'arguments' attribute to an array (if a list is used)
	var					= [string] The name of the variable to set the message to 
	display				= [boolean] Sets if the message should be outputted / displayed. If the 'var' attribute is not used, the message will be 
							displayed. If the 'var' is defined, then the message will not be displayed unless 'display="true"' is set
--->

<cfif thisTag.executionMode IS "start">

	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />

	<!--- Enforce required attributes --->
	<cfset ensureByName("key") />
	
	<!--- Setup defaults --->
	<cfparam name="attributes.argumentSeparator" type="string"
		default="," />
	<cfparam name="attributes.text" type="string" 
		default="" />
	<cfparam name="attributes.var" type="string" 
		default="" />
	<cfparam name="attributes.display" type="boolean" 
		default="#attributes.var EQ ''#" />
	<cfparam name="attributes.arguments" type="any"
		default="#ArrayNew(1)#" />
	
	<!--- Convert to array if list is passed --->
	<cfif IsSimpleValue(attributes.arguments)>
		<cfset attributes.arguments = ListToArray(attributes.arguments, attributes.argumentSeparator) />
	</cfif>
	
<cfelse>
	<cfset variables.output = getAppManager().getGlobalizationManager().getString(attributes.key, getAppManager().getRequestManager().getRequestHandler().getCurrentLocale(), attributes.arguments, attributes.text) />

	<!--- Store the output to whatever variable 'var' is pointing to --->
	<cfif Len(attributes.var)>
		<cfset SetVariable(attributes.var, variables.output) />
	</cfif>
	
	<!--- Output the label message or reset the output buffer if nothing is to be outputted --->
	<cfif attributes.display>
		<cfset ThisTag.GeneratedContent = variables.output />
	<cfelse>
		<cfset ThisTag.GeneratedContent = "" />
	</cfif>
</cfif>

</cfsilent><cfsetting enablecfoutputonly="false" />