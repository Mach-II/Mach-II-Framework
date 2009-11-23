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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="AbstractFilter"
	output="false"
	hint="A logging filter. This is abstract and must be extend by a concrete filter implementation.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />
	<cfset variables.instance.filterTypeName = "undefined" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractFilter" output="false"
		hint="Initalizes the filter.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="decide" access="public" returntype="boolean" output="false"
		hint="Decides whether or not the log message elements meet the filter criteria and should be logged.">
		<cfargument name="logMessageElements" type="struct" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getFilterTypeName" access="public" returntype="string" output="false"
		hint="Returns the type of the filter. Required for Dashboard integration.">
		<cfreturn variables.instance.filterTypeName />
	</cffunction>
	<cffunction name="getFilterType" access="public" returntype="string" output="false"
		hint="Returns the dot path type of the filter. Required for Dashboard integration.">
		<cfreturn GetMetadata(this).name />
	</cffunction>
	
	<cffunction name="getFilterCriteriaData" access="public" returntype="any" output="false"
		hint="Gets a struct of filter criteria. Return struct or array with strings as values. Required for dashboard integration.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
		
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadFilterCriteria" access="private" returntype="void" output="false"
		hint="Loads filter criteria.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	
</cfcomponent>