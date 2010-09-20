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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id: RegExListener.cfc 2346 2010-09-04 05:25:42Z peterjfarrell $

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="ScribbleListener" 
	extends="MachII.framework.Listener"	
	output="false"
	hint="Basic interface for Scribble Pad tool.">

	<!---
	PROPERTIES
	--->
	<cfset variables.renderType = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
			
		<cfset var filePath = "" />
		
		<!--- Figure out if render() is available on this engine (OpenBD) --->
		<cftry>
			<cfset render("#1+1#") />
			<cfset setRenderType("render") />
			<cfcatch type="any">
				<cfset setRenderType("file") />
			</cfcatch>
		</cftry>
		
		<!--- Test if writting to temp director is possible --->
		<cfif getRenderType() EQ "file">
			<cftry>
				<cfset filePath = "/MachII/dashboard/temp/" & CreateUUID() & ".cfm" />		

				<cffile action="write" 
					file="#ExpandPath(filePath)#" 
					output="temp" 
					mode="777" 
					attributes="normal" />
				<cffile action="delete" 
					file="#ExpandPath(filePath)#" />

				<cfcatch type="any">
					<cfset setRenderType("none") />
					<cfset setProperty("scribbleAvailable", false) />
					<cfset setProperty("scribbleAvailableMessage", "Are you sure you can write to: " & cfcatch.message) />
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="processInput" access="public" returntype="string" output="false"
		hint="Process scribble pad form post.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var input = arguments.event.getArg("input") />
		<cfset var filePath = "" />
		
		<cfset arguments.event.setArg("renderType", getRenderType()) />
		
		<!--- This is where we would build an "include" file if needed and announce the right event --->
		<cfif getRenderType() EQ "render">
			<cfset arguments.event.setArg("input", "<cfoutput>" & input & "</cfoutput>") />
		<cfelseif getRenderType() EQ "file">
			<!--- The scribble should be done in a savecontent so if somebody surfs to the temp file no data is disclosed --->
			<cfset input = '<cfsavecontent variable="variables.result"><cfoutput>' & input & '</cfoutput></cfsavecontent>' />
		
			<cfset filePath = "/MachII/dashboard/temp/" & CreateUUID() & ".cfm" />
			<cfset arguments.event.setArg("filePath", filePath) />
			
			<cffile action="write" 
				file="#ExpandPath(filePath)#" 
				output="#input#" 
				mode="777" 
				attributes="normal" />
		</cfif>
	</cffunction>
	
	<cffunction name="cleanup" access="public" returntype="string" output="false"
		hint="Cleans up after a scribble pad form post.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfif getRenderType() EQ "file">
			<cffile action="delete" file="#ExpandPath(arguments.event.getArg("filePath"))#" />
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setRenderType" access="private" returntype="void" output="false">
		<cfargument name="renderType" type="string" required="true" />
		<cfset variables.renderType = arguments.renderType />
	</cffunction>
	<cffunction name="getRenderType" access="private" returntype="string"  output="false">
		<cfreturn variables.renderType />
	</cffunction>
	
</cfcomponent>