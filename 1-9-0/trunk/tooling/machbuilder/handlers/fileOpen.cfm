<!--- 
<event>
	<ide>
		<projectview projectname="cfdev" projectlocation="/Users/kurt/Projects/DW Sites/cfdev" >
			<resource path="/Users/kurt/Projects/DW Sites/cfdev/machbolt/handlers/Application.cfc" type="file" />
		</projectview>
	</ide>
	<user></user>
</event>

<response> 
    <ide> 
        <commands> 
            <command name="openfile"> 
            <params> 
            <param key="filename" value="[valid file name/location]" /> 
            <param key="projectname" value="[valid project name/location]" /> 
            </params> 
            </command> 
        </commands> 
    </ide> 
</response>
 --->
 
<cfheader name="Content-Type" value="text/xml">
<cfsetting showdebugoutput="false">
 
<cfparam name="ideeventinfo">
<cfset data = xmlParse(ideeventinfo)>
<cfset myFile = data.event.ide.projectview.resource.xmlAttributes.path>
<cfset projectName = data.event.ide.projectview.xmlAttributes.projectname>
 
<cflog file="machbuilder" type="information" text="#ideEventInfo#">
<cflog file="machbuilder" type="information" text="file: '#myFile#', project: '#projectName#'">
 
 
 <!--- /Users/kurt/Projects/DW Sites/cfdev/machbolt/test.cfm
 	cfdev
  --->
 
 <cfoutput>
 <response> 
    <ide> 
        <commands> 
            <command type="openfile"> 
	            <params> 
	         		<param key="filename" value="#myFile#" /> 
	           		<!---<param key="projectname" value="#projectName#" />---> 
	            </params> 
            </command> 
        </commands> 
    </ide> 
</response>
</cfoutput>