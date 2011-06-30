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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent 
	displayname="BuilderListener"
	extends="MachII.framework.Listener" 
	output="false">
	
	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="config" access="public" output="false" returntype="void">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="openFile" access="public" returntype="String" output="false"
		hint="Generates a CFBuilder callback for opening a file.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var commandXML = "" />
		<cfset var fullFilePath = convertCFCPathToFilePath(event.getArg("fileName")) />
		<cfset var callbackUrl = cleanCallbackUrl(getProperty("application").getSessionItem("callbackurl")) />
		<cfset var callbackResult = "" />
		
		<cfsavecontent variable="commandXML">
			<cfoutput>
			<response> 
			    <ide> 
			        <commands> 
			            <command type="openfile"> 
				            <params> 
				         		<param key="filename" value="#fullFilePath#" /> 
				           		<!---<param key="projectname" value="#projectName#" />---> 
				            </params> 
			            </command> 
			        </commands> 
			    </ide> 
			</response>
			</cfoutput>
		</cfsavecontent>
		
		<cflog file="machbuilder" text="CallbackUrl: #callbackUrl#" />
		<cflog file="machbuilder" text="Command: #commandxml#" />
		
		<cfhttp result="callbackResult" 
			url="#callbackUrl#" 
			method="post">
			<cfhttpparam type="body" value="#commandXML#" />
			<cfhttpparam type="header" name="mimetype" value="text/xml" />
		</cfhttp>
		
		<cflog file="machbuilder" text="CallbackResult: #serializeJSON(callbackResult)#" />
	</cffunction>
	
	<!--- 
	PROTECTED FUNCTIONS	
	 --->
	 <cffunction name="convertCFCPathToFilePath" access="private" returntype="string" output="false">
	 	<cfargument name="cfcPath" type="string" required="true" />
		<cfreturn ExpandPath("/" & ReplaceNoCase(arguments.cfcPath, ".", "/", "ALL") & ".cfc") />
	 </cffunction>

	 <cffunction name="cleanCallbackUrl" access="private" returntype="string" output="false">
	 	<cfargument name="callbackUrl" type="string" required="true" />
		<cfreturn ReplaceNoCase(arguments.callbackurl, " ", "%20", "ALL") />
	 </cffunction>

</cfcomponent>