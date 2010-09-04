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

$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="ServeFileFilter" 
	extends="MachII.framework.EventFilter"
	output="false" 
	hint="Serves file via cfcontent">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the filter.">
		<cfset setBasePath(ExpandPath(getParameter("basePath"))) />
		<cfset setContentTypes(getParameter("contentTypes")) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean" output="true"
		hint="Filters the event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="true" />
		
		<!--- We use "@" for "/"  due to the possibility of SES URLs --->
		<cfset var path = Replace(arguments.event.getArg("path"), "@", "/", "all") />
		<cfset var contentType = getContentTypeByFilePath(path) />
		<cfset var fileSize = "" />
		
		<cfif contentType EQ "text/css">
			<cfsetting enablecfoutputonly="true" />
			<cfset arguments.eventContext.addHTTPHeaderByName("Expires", computeHttpDate(DateAdd("h", 8, Now()))) />
			<cfcontent reset="true" type="#contentType#" />
			<cfoutput><cfinclude template="#getParameter("basePath")##Replace(path, ".css", ".cfm", "all")#" /></cfoutput>
		<cfelseif contentType NEQ "unknown">
			<cfdirectory 
				name="fileSize" 
				action="list" 
				directory="#getBasePath()##Replace(path, ListLast(path, "/"), "", "one")#" 
				filter="#ListLast(path, "/")#" />
			<cfset arguments.eventContext.addHTTPHeaderByName("Content-Length", fileSize.size) />
			<cfset arguments.eventContext.addHTTPHeaderByName("Expires", computeHttpDate(DateAdd("h", 8, Now()))) />
			<cfcontent file="#getBasePath()##path#" type="#contentType#" />
		<cfelse>
			<cfabort showerror="Invalid file." />
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getContentTypeByFilePath" access="private" returntype="string" output="false"
		hint="Gets the content type by the file path.">
		<cfargument name="path" type="string" required="true" />
		
		<cfset var extension = ListLast(arguments.path, ".") />
		<cfset var contentTypes = getContentTypes() />
		<cfset var result = "unknown" />
		
		<cfif StructKeyExists(contentTypes, extension)>
			<cfset result = contentTypes[extension] />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="computeHttpDate" access="private" returntype="string" output="false"
		hint="Format a date as required by HTTP specifications">
	    <cfargument name="theDate" type="date" required="false" default="#Now()#" 
	    	hint="Date to format." />
	    
	    <cfset var returnDate = "#DateFormat(arguments.theDate, 'ddd, dd mmm yyyy')# #TimeFormat(arguments.theDate, 'HH:mm:ss')# GMT" />
	    
	    <cfreturn returnDate />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setBasePath" access="public" returntype="void" output="false">
		<cfargument name="basePath" type="string" required="true" />
		<cfset variables.basePath = arguments.basePath />
	</cffunction>
	<cffunction name="getBasePath" access="public" returntype="string" output="false">
		<cfreturn variables.basePath />
	</cffunction>

	<cffunction name="setContentTypes" access="public" returntype="void" output="false">
		<cfargument name="contentTypes" type="struct" required="true" />
		<cfset variables.contentTypes = arguments.contentTypes />
	</cffunction>
	<cffunction name="getContentTypes" access="public" returntype="struct" output="false">
		<cfreturn variables.contentTypes />
	</cffunction>

</cfcomponent>