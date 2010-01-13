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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent 
	displayname="ViewPageCommand" 
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for processing a view.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "view-page" />
	<cfset variables.viewName = "" />
	<cfset variables.contentKey = "" />
	<cfset variables.contentArg = "" />
	<cfset variables.append = false />
	<cfset variables.prepend = false />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ViewPageCommand" output="false"
		hint="Used by the framework for initialization.">
		<cfargument name="viewName" type="string" required="true" />
		<cfargument name="contentKey" type="string" required="false" default="" />
		<cfargument name="contentArg" type="string" required="false" default="" />
		<cfargument name="append" type="string" required="false" default="false" />
		<cfargument name="prepend" type="string" required="false" default="false" />
		
		<cfset setViewName(arguments.viewName) />
		<cfset setContentKey(arguments.contentKey) />
		<cfset setContentArg(arguments.contentArg) />
		<cfset setAppend(arguments.append) />
		<cfset setPrepend(arguments.prepend) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes the command.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset arguments.eventContext.displayView(arguments.event, getViewName(), getContentKey(), getContentArg(), getAppend(), getPrepend()) />
		
		<cfreturn true />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setViewName" access="private" returntype="void" output="false">
		<cfargument name="viewName" type="string" required="true" />
		<cfset variables.viewName = arguments.viewName />
	</cffunction>
	<cffunction name="getViewName" access="private" returntype="string" output="false">
		<cfreturn variables.viewName />
	</cffunction>
	
	<cffunction name="setContentKey" access="private" returntype="void" output="false">
		<cfargument name="contentKey" type="string" required="true" />
		<cfset variables.contentKey = arguments.contentKey />
	</cffunction>
	<cffunction name="getContentKey" access="private" returntype="string" output="false">
		<cfreturn variables.contentKey />
	</cffunction>
	<cffunction name="hasContentKey" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.contentKey) />
	</cffunction>
	
	<cffunction name="setContentArg" access="private" returntype="void" output="false">
		<cfargument name="contentArg" type="string" required="true" />
		<cfset variables.contentArg = arguments.contentArg />
	</cffunction>
	<cffunction name="getContentArg" access="private" returntype="string" output="false">
		<cfreturn variables.contentArg />
	</cffunction>
	<cffunction name="hasContentArg" access="private" returntype="boolean" output="false">
		<cfreturn Len(variables.contentArg) />
	</cffunction>

	<cffunction name="setAppend" access="private" returntype="void" output="false">
		<cfargument name="append" type="string" required="true" />
		<cfset variables.append = (arguments.append IS "true") />
	</cffunction>
	<cffunction name="getAppend" access="private" returntype="boolean" output="false">
		<cfreturn variables.append />
	</cffunction>
	
	<cffunction name="setPrepend" access="private" returntype="void" output="false">
		<cfargument name="prepend" type="string" required="true" />
		<cfset variables.prepend = (arguments.prepend IS "true") />
	</cffunction>
	<cffunction name="getPrepend" access="private" returntype="boolean" output="false">
		<cfreturn variables.prepend />
	</cffunction>

</cfcomponent>