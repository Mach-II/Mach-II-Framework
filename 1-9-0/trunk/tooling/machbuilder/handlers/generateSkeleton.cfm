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

$Id: mach-ii.cfc 2608 2010-12-20 23:25:18Z peterjfarrell $

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfsetting showdebugoutput="no" />
<cflog file="storm" text="#timeFormat(now())# -- Starting generateSkeleton.cfm">

<!--- Grab the event info from the IDE --->
<cfparam name="ideeventinfo">
<cfif not isXML(ideeventinfo)>
	<cfexit>
</cfif>
<cfset data = xmlParse(ideeventinfo)>

<cfset projectLocation = data.event.ide.projectview.resource.xmlAttributes.path />
<cfset wwwroot = Trim(XMLSearch(data, "/event/user/input[@name='webroot']")[1].XMLAttributes.value) />
<cfset pathWithinWebroot = Replace(projectLocation, wwwroot, "", "ALL") />
<cfif NOT Len(pathWithinWebroot)>
	<cfset pathWithinWebroot = "/" />
</cfif>


<!--- Set up string variables that will be used when rewriting skeleton files based on customer input --->
<cfset resultMsg = "" />
<cfset csPropertyLoc = "<include file=" & Chr(34) & "./mach-ii_coldspringProperty.xml" & Chr(34) & " />" />
<cfsavecontent variable="sesInfo"><cfoutput><!-- URL Rewriting Properties -->#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<property name="urlBase" value="<cfif pathWithinWebroot IS NOT "/">#pathWithinWebroot#</cfif>/index.cfm" />#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<property name="urlParseSES" value="true" />#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<property name="urlDelimiters" value="/|/|/" /></cfoutput></cfsavecontent>
<cfsavecontent variable="loggingPropertyString"><cfoutput><!-- This turns on basic, on-screen logging -->#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<property name="Logging" type="MachII.logging.LoggingProperty" /></cfoutput></cfsavecontent>
<cfsavecontent variable="loggingInfoComments"><cfoutput>#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<!-- LOGGING RELATED -->#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<!-- this will log to the screen -->#Chr(13)##Chr(10)##Chr(9)##Chr(9)#<!-- <property name="logging" type="MachII.logging.LoggingProperty" /> -->#Chr(13)##Chr(10)##Chr(9)##Chr(9)#</cfoutput></cfsavecontent>


<!--- --->
<!--- Copy the skeleton --->
<!--- --->
<cfset skeletonLocation = expandPath('../includes') />
<cfzip action="unzip" destination="#projectLocation#" file="#skeletonLocation#/skeleton.zip" />
<cfset resultMsg = "A new copy of the Mach-II skeleton was created in " & projectLocation />

<!--- --->
<!--- Put the application name in the proper places --->
<!--- --->
<cfset appName = XMLSearch(data, "/event/user/input[@name='appName']")[1].XMLAttributes.value />
<cfset appName = replace(appName, " ", "", "All") />
<cfset appCFCLocation="#projectLocation#/Application.cfc" />
<cffile action="read" file="#appCFCLocation#" variable="appCFC" />
<cfset appCFC = replace(appCFC,"%AppName%",appName,"All") />
<cffile action="write" file="#appCFCLocation#" output="#appCFC#" nameconflict="replace"> 

<!--- --->
<!--- Rewrite the config file to include options selected by the customer --->
<!--- --->
<cfset m2xmlConfigFile="#projectLocation#/config/mach-ii.xml" />
<cffile action="read" file="#m2xmlConfigFile#" variable="m2ConfigFileData" />

<!--- --->
<!--- Put the application root in the proper places --->
<!--- --->
<cfset m2ConfigFileData=replace(m2ConfigFileData,"%ARPATH%",pathWithinWebroot,"All") />

<!--- --->
<!--- Write the event parameter name --->
<!--- --->
<cfset eventParamName = Trim(XMLSearch(data, "/event/user/input[@name='eventParamName']")[1].XMLAttributes.value) />
<cfif NOT Len(eventParamName)>
	<cfset eventParamName = "event" />
</cfif>
<cfset m2ConfigFileData=replace(m2ConfigFileData,"%EPN%",eventParamName,"All") />

<!--- --->
<!--- Write config for SES (Search Engine Safe) URLS --->
<!--- --->
<cfset useSESURLs = XMLSearch(data, "/event/user/input[@name='useSESURLs']")[1].XMLAttributes.value />
<cfif useSESURLs>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%SES%",sesInfo,"All") />
<cfelse>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%SES%","","All") />
</cfif>

<!--- --->
<!--- Write config for ColdSpring --->
<!--- --->
<cfset useColdSpring = XMLSearch(data, "/event/user/input[@name='useColdSpring']")[1].XMLAttributes.value />
<cfif useColdSpring>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%CSP%",csPropertyLoc,"All") />
<cfelse>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%CSP%","<!-- Point to other Mach-II XML config files here. -->","All") />
	<cffile action="delete" file="#projectLocation#/config/mach-ii_coldspringProperty.xml" />
	<cffile action="delete" file="#projectLocation#/config/coldspring.xml" />
</cfif>

<!--- --->
<!--- Write config for basic, on-screen M2 logging --->
<!--- --->
<cfset enableBasicLogging = XMLSearch(data, "/event/user/input[@name='basicLogging']")[1].XMLAttributes.value />
<cfif enableBasicLogging>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%LOG%",loggingPropertyString,"All") />
<cfelse>
	<cfset m2ConfigFileData=replace(m2ConfigFileData,"%LOG%",loggingInfoComments,"All") />
</cfif>

<!--- --->
<!--- Write the Mach-II Dashboard password --->
<!--- --->
<cfset dashPassword = Trim(XMLSearch(data, "/event/user/input[@name='dashPassword']")[1].XMLAttributes.value) />
<cfif NOT Len(dashPassword)>
	<cfset dashPassword = "admin" />
</cfif>
<cfset m2ConfigFileData=replace(m2ConfigFileData,"%DASHP%",dashPassword,"All") />


<!--- --->
<!--- Write the M2 config file back to disk with all changes --->
<!--- --->
<cffile action="write" file="#m2xmlConfigFile#" output="#m2ConfigFileData#" nameconflict="replace"> 



<!--- --->
<!--- Grab the project name in the IDE so we can refresh it --->
<!--- --->
<cfset projectNode = xmlSearch(data, "//projectview[ position() = 1 ]/@projectname") />

<!--- --->
<!--- Results out to the IDE and refresh the project listing with all the new files --->
<!--- --->
<cfheader name="Content-Type" value="text/xml">
<cfoutput>
<response showresponse="false">
<ide message="#resultMsg#">
<dialog />
<commands>
	<command type="refreshproject">
	<params>
	<cfoutput>
	<param key="projectname" value="#projectNode[1].xmlValue#" />
	</cfoutput>
	</params>
	</command>
</commands>
</ide>
</response></cfoutput>			