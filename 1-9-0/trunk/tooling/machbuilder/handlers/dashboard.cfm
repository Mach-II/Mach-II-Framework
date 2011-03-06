<!--- 
<event>
	<ide version=""2.0"" >
		<callbackurl>http://192.168.1.2:58709/index.cfm?extension=Mach II Builder Extension</callbackurl>
		<projectview projectname=""cfdev"" projectlocation=""/Users/kurt/Projects/DW Sites/cfdev"" >
			<server name=""localhost-cfdev"" hostname=""cfdev"" port=""80"" wwwroot=""/Users/kurt/Projects/DW Sites/cfdev"" />
			<resource path=""/Users/kurt/Projects/DW Sites/cfdev/ModelGlue Assistant/handlers/Application.cfm"" type=""file"" />
		</projectview>
	</ide>
	<user></user>
</event>
 --->
 
<cflog file="machbuilder" type="information" text="#ideEventInfo#">
 
<cfheader name="Content-Type" value="text/xml">

<cfset data = xmlParse(ideeventinfo)>
<cfset application.data = data>
<cfset separator = createObject("java", "java.io.File").separator>
<cfset hostname = data.event.ide.projectview.server.xmlAttributes["hostname"]>
<cfif data.event.ide.projectview.server.xmlAttributes["port"] neq 80>
	<cfset hostname = hostname & ":" & data.event.ide.projectview.server.xmlAttributes["port"]>
</cfif>
<cfset path = data.event.ide.projectview.resource.xmlAttributes["path"]>
<cfset path = listGetAt(path, listLen(path, separator) - 1, separator)>

<cflog file="machbuilder" 
	text="attempt to open: http://#hostname#/#path#/index.cfm/event/dashboard:builder.index/callbackurl/#urlencodedFormat(data.event.ide.callbackurl.xmlText)#" >

<cfoutput>  
<response showresponse="true"> 
	<ide url="http://#hostname#/#path#/index.cfm/event/dashboard:builder.index/?callbackurl=#urlencodedFormat(data.event.ide.callbackurl.xmlText)#/"> 
		<view id="machiiDashboard" title="Mach II Dashboard" /> 
	</ide> 
</response> 
</cfoutput>