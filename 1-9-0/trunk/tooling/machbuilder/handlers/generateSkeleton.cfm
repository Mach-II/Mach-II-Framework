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