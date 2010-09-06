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
$Id$

Created version: 1.9.0

Notes:

Information on mod x-sendfile for Apache can be found here:
http://tn123.ath.cx/mod_xsendfile/

Configuration Notes:

<property name="endpoints" type="MachII.endpoints.EndpointConfigProperty">
	<parameters>
		<parameter name="_dashboardFileServe">
			<struct>
				<key name="type" value="MachII.endpoints.file.BaseEndpoint"/>
				<key name="basePath" value="/MachII/dashboard/assets"/>
				<key name="servingEngineType" value="cfcontent|sendfile" />
				<key name="expireHeaderEnabled">
					<struct>
						<key name="group:development" value="true"/>
						<key name="group:production" value="true"/>
					</struct>
				</key>
				<key name="expiresDefault" value="access plus 365,0,0,0" />
				<key name="attachmentDefault" value="false" />
				<key name="fileTypeSettings">
					<struct>
						<key name=".*">
							<struct>
								<key name="expires" value="access plus 8,0,0,0"/>
								<key name="attachment" value="false" />
							</struct>
						</key>
						<key name=".js,.css,.jpg,.gif,.png">
							<struct>
								<key name="expires" value="access plus 365,0,0,0"/>
								<key name="attachment" value="false" />
							</struct>
						</key>
						<key name=".pdf">
							<struct>
								<key name="expires" value="access plus 0,0,0,0"/>
								<key name="attachment" value="true" />
							</struct>
						</key>
					</struct>
				</key>
			</struct>
		</parameter>
	</parameters>
</property>

--->
<cfcomponent
	displayname="FileEndpoint"
	extends="MachII.endpoints.AbstractEndpoint"
	output="false"
	hint="Base endpoint for all file serve endpoints to be exposed directly by Mach-II.">

	<!---
	CONSTANTS
	--->

	<!---
	PROPERTIES
	--->
	<cfset variables.basePath = "" />
	<cfset variables.servingEngineType = "cfcontent" />
	<cfset variables.expiresDefault = StructNew() />
	<cfset variables.attachmentDefault = false />
	<cfset variables.expireMap = StructNew() />
	<cfset variables.attachmentMap = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the file serve endpoint.">

		<cfset setBasePath(getParameter("basePath")) />
		<cfset setServiceEngineType(getParameter("serviceEngineType", "cfcontent")) />
		<cfset setExpiresDefault(getParameter("expiresDefault", "access plus 365,0,0,0")) />
		<cfset setAttachmentDefault(getParameter("attachmentDefault", "false")) />
		
		<!--- Setup the lookup maps --->
		<cfset buildFileSettingsMap() />
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the file serve endpoint.">
		<!--- Does nothing --->
	</cffunction>
	
	<cffunction name="buildFileSettingsMap" access="private" returntype="void" output="false"
		hint="Builds the file settings map for expire and attachment settings by file type.">
		
		<cfset var rawSettings = getParameter("fileTypeSettings", StructNew()) />	
		<cfset var expireMap = StructNew() />
		<cfset var attachmentMap = StructNew() />
		<cfset var fileExtensionsArray = "" />
		<cfset var key = "" />
		<cfset var temp = "" />
		<cfset var fileExtension = "" />
		<cfset var expires = "" />
		<cfset var attachment = "" />
		<cfset var i = 0 />
		
		<cfloop collection="#rawSettings#" item="key">
			
			<cfset temp = StructFind(rawSettings, key) />
			
			<cfif StructKeyExists(temp, "expires")>
				<cfset expires = parseExpiresLanguage(temp.expires) />
			<cfelse>
				<cfset expires = getExpiresDefault() />
			</cfif>
			
			<cfif StructKeyExists(temp, "attachment")>
				<cfset attachment = temp.attachment />
			<cfelse>
				<cfset attachment = getAttachmentDefault() />
			</cfif>

			<cfset fileExtensions = ListToArray(key) />
			
			<cfloop from="1" to="#ArrayLen(fileExtensions)#" index="i">
				<cfset fileExtension = ReplaceNoCase(fileExtensions[i], ".", "", "all") />
				<cfset expireMap[fileExtension] = expires />
				<cfset attachmentMap[fileExtension] = attachment />
			</cfloop>
		</cfloop>
		
		<cfset variables.expireMap = expireMap />
		<cfset variables.attachmentMap = attachmentMap />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var pathInfo = cleanPathInfo() />
		<cfset var filePath = "" />
		<cfset var fileExtension = "" />
		<cfset var pipeExtension = "" />

		<!--- Get file path with support URIs where the file is defined in the pathInfo --->
		<cfif Len(pathInfo)>
			<cfset filePath = ListDeleteAt(pathInfo, 1, "/") />
		<cfelse>
			<cfset filePath = arguments.getArg("file") />
		</cfif>
		
		<!--- Setup the file extension and any piping extension --->
		<cfset fileExtension = ListFirst(ListLast(filePath, "."), ":") />
		<cfset arguments.event.setArg("fileExtension", fileExtension) />
		
		<!--- Clean up any piping extension on the file path --->
		<cfset arguments.event.setArg("file", ListFirst(filePath, ":")) />
		<cfif fileExtension EQ "cfm">
			<cfset arguments.event.setArg("fileFullPath", getBasePath() & ListFirst(filePath, ":")) />
		<cfelse>
			<cfset arguments.event.setArg("fileFullPath", ExpandPath(getBasePath()) & ListFirst(filePath, ":")) />
		</cfif>

		<!--- Set up the piping --->
		<cfif ListLen(filePath, ":") EQ 2>
			<cfset pipeExtension =  ListLast(filePath, ":") />
			<cfif NOT Len(pipeExtension)>
				<cfset pipeExtension = "htm" />
			</cfif>
			<cfset arguments.event.setArg("pipe", pipeExtension) />
		</cfif>

		<!--- Set expiry type and value --->
		<cfif fileExtension EQ "cfm" AND StructKeyExists(variables.expireMap, pipeExtension)>
			<cfset arguments.event.setArg("expires", variables.expireMap[pipeExtension]) />
		<cfelseif StructKeyExists(variables.expireMap, fileExtension)>
			<cfset arguments.event.setArg("expires", variables.expireMap[fileExtension]) />
		<cfelse>
			<cfset arguments.event.setArg("expires", getExpiresDefault()) />
		</cfif>
		
		<!--- Process attachment type --->
		<cfif NOT arguments.event.isArgDefined("attachment")>
			<cfif StructKeyExists(variables.attachmentMap, event.getArg("pipe", fileExtension))>
				<cfset arguments.event.setArg("attachment", getFileFromPath(ReplaceNoCase(arguments.event.getArg("file"), "." & fileExtension, "." & pipeExtension))) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Serves the file request.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfif arguments.event.getArg("fileExtension") EQ "cfm">
			<cfoutput>#serveCfmFile(arguments.event.getArg("fileFullPath"), arguments.event.getArg("expires"), arguments.event.getArg("attachment"), arguments.event.getArg("pipe", "htm"))#</cfoutput>
		<cfelse>
			<cfset serveStaticFile(arguments.event.getArg("fileFullPath"), arguments.event.getArg("expires"), arguments.event.getArg("attachment")) />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="serveCfmFile" access="private" returntype="string" output="false"
		hint="Serves a cfm file.">
		<cfargument name="fileFullPath" type="string" required="true"
			hint="The full path to the file." />
		<cfargument name="expires" type="struct" required="true"
			hint="The expires struct." />
		<cfargument name="attachment" type="string" required="true"
			hint="The name of the file if an attachment. Zero-length string means not to send as attachment." />
		<cfargument name="pipeExtension" type="string" required="true"
			hint="The file extension type to pipe the output to (.cfm -> .css)." />
		
		<cfset var contentType = getContentTypeFromFilePath(arguments.pipeExtension) />
		
		<cfheader name="Content-Type" value="#contentType#" />
		<cfheader name="Expires" value="#GetHttpTimeString(Now() + arguments.expires.amount)#" />

		<cfif Len(arguments.attachment)>
			<cfheader name="Content-Disposition" value="attachment; filename=#arguments.attachment#" />
		</cfif>

		<cfsavecontent variable="output"><cfinclude template="#arguments.fileFullPath#" /></cfsavecontent>
		
		<cfreturn output />
	</cffunction>
	
	<cffunction name="serveStaticFile" access="private" returntype="void" output="false"
		hint="Serves a static file via cfcontent or mod x-sendfile.">
		<cfargument name="fileFullPath" type="string" required="true"
			hint="The full path to the file." />
		<cfargument name="expires" type="struct" required="true"
			hint="The expires struct." />
		<cfargument name="attachment" type="string" required="true"
			hint="The name of the file if an attachment. Zero-length string menas not to send as attachment." />
		
		<cfset var fullFilePath =  arguments.fileFullPath />
		<cfset var contentType = getContentTypeFromFilePath(arguments.fileFullPath) />
		<cfset var fileInfo = "" />
		<cfset var httpRequestHeaders = getHttpRequestData().headers />

		<!--- Read file info for content-length and last-modified headers --->
		<cfdirectory 
			name="fileInfo" 
			action="list" 
			directory="#getDirectoryFromPath(fileFullPath)#" 
			filter="#getFileFromPath(fileFullPath)#" />
		
		<!--- Assert the requested file was found (only throw the relative path for security reasons) --->
		<cfset getAssert().isTrue(fileInfo.recordcount EQ 1
				, "Cannot fetch file information for the request file path because it cannot be located. Check for your file path."
				, "File path: '#arguments.fileFullPath#'") />

		<cfheader name="Content-Length" value="#fileInfo.size#" />
		<cfheader name="Expires" value="#GetHttpTimeString(Now() + arguments.expires.amount)#" />

		<cfif Len(arguments.attachment)>
			<cfheader name="Content-Disposition" value="attachment; file='#arguments.attachment#'" />
		</cfif>

		<cfif getServiceEngineType() EQ "cfcontent">
			<!--- Return a 304 No Modified if the passed header and file modified timestamp are not the same --->
			<cfif StructKeyExists(httpRequestHeaders ,"If-Modified-Since") AND DateCompare(createDatetimeFromHttpTimeString(httpRequestHeaders["If-Modified-Since"]), fileInfo.dateLastModified) NEQ 0>
				<cfcontent reset="true" />
				<cfheader statuscode="304" statustext="Not Modified" />
			<!--- Serve the file using cfcontent --->
			<cfelse>
				<cfheader name="Last-Modified" value="#GetHttpTimeString(fileInfo.dateLastModified)#" />
				<cfcontent file="#fullFilePath#" type="#contentType#" />
			</cfif>
		<cfelse>
			<!--- x-sendfile correctly handles ETags and modified since headers itself --->
			<cfheader name="X-Sendfile" value="#arguments.fullFilePath#" />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="getContentTypeFromFilePath" access="private" returntype="string" output="false"
		hint="Reuturns the MIME type from a file path.">
		<cfargument name="filePath" type="string" required="true"
			hint="The full path to the file." />
		
		<cfset var fileExtension = "." & ListLast(arguments.filePath, ".") />
		
		<!--- Leverage this nicely provided utility method --->
		<cfreturn getUtils().getMimeTypeByFileExtension(fileExtension) />
	</cffunction>
	
	<cffunction name="createDatetimeFromHttpTimeString" access="private" returntype="date" output="false"
		hint="Creates an UTC datetime from an HTTP time string.">
		<cfargument name="httpTimeString" type="string" required="true"
			hint="An HTTP time string in the format of '11 Aug 2010 17:58:48 GMT'." />
	
		<cfset var rawArray = ListToArray(ListLast(arguments.httpTimeString, ","), " ") />
		<cfset var rawTimePart = ListToArray(rawArray[4], ":") />
		
		<cfreturn CreateDatetime(rawArray[3], DateFormat("#rawArray[2]#/1/2000", "m"), rawArray[1], rawTimePart[1], rawTimePart[2], rawTimePart[3]) />
	</cffunction>
	
	<cffunction name="cleanPathInfo" access="private" returntype="string" output="false"
		hint="Cleans the path info to an usable string (IIS6 breaks the RFC specification by inserting the script name into the path info).">

		<cfset var pathInfo = cgi.PATH_INFO />
		<cfset var scriptName = cgi.SCRIPT_NAME />

		<cfif pathInfo.toLowerCase().startsWith(scriptName.toLowerCase())>
			<cfset pathInfo = ReplaceNoCase(pathInfo, scriptName, "", "one") />
		</cfif>

		<cfreturn UrlDecode(pathInfo) />
	</cffunction>
	
	<cffunction name="parseExpiresLanguage" access="private" returntype="struct" output="false"
		hint="Parses expires language into an uniform structure.">
		<cfargument name="inputString" type="string" required="true" />
		
		<cfset var amountRaw = "" />
		<cfset var result = StructNew() />
		
		<cfif REFindNoCase("^((access|modified) plus ([0-9]{1,}\,){3}[0-9]{1,})$", arguments.inputString)>
		
			<cfset amountRaw = ListToArray(ListGetAt(arguments.inputString, 3, " ")) />
			
			<cfset result.type = ListGetAt(arguments.inputString, 1, " ") />
			<cfset result.amount = CreateTimespan(amountRaw[1], amountRaw[2], amountRaw[3], amountRaw[4]) />
		<cfelse>
			<cfthrow type="MachII.endpoint.file.UnableToParseExpiresString"
				message="Unable to parse expires string of '#arguments.inputString#'." />
		</cfif>
		
		<cfreturn result />
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

	<cffunction name="setServiceEngineType" access="public" returntype="void" output="false">
		<cfargument name="serviceEngineType" type="string" required="true" />
		<cfset variables.serviceEngineType = arguments.serviceEngineType />
	</cffunction>
	<cffunction name="getServiceEngineType" access="public" returntype="string" output="false">
		<cfreturn variables.serviceEngineType />
	</cffunction>

	<cffunction name="setExpiresDefault" access="private" returntype="void" output="false">
		<cfargument name="expiresDefaultAsString" type="string" required="true" />
		<cfset variables.expiresDefault = parseExpiresLanguage(arguments.expiresDefaultAsString) />
	</cffunction>
	<cffunction name="getExpiresDefault" access="public" returntype="struct" output="false">
		<cfreturn variables.expiresDefault />
	</cffunction>
	
	<cffunction name="setExpiresDefaultAsString" access="public" returntype="void" output="false">
		<cfargument name="expiresDefaultAsString" type="string" required="true" />
		<cfset variables.expiresDefaultAsString = arguments.expiresDefaultAsString />
		<cfset setExpiresDefault(variables.expiresDefaultAsString) />
	</cffunction>
	<cffunction name="getExpiresDefaultAsString" access="public" returntype="string" output="false">
		<cfreturn variables.expiresDefaultAsString />
	</cffunction>

	<cffunction name="setAttachmentDefault" access="private" returntype="void" output="false">
		<cfargument name="attachmentDefault" type="boolean" required="true" />
		<cfset variables.attachmentDefault = arguments.attachmentDefault />
	</cffunction>
	<cffunction name="getAttachmentDefault" access="public" returntype="boolean" output="false">
		<cfreturn variables.attachmentDefault />
	</cffunction>

</cfcomponent>