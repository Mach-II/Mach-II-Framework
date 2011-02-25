<cfsetting showdebugoutput="no" />
<cflog file="storm" text="#timeFormat(now())# -- Starting skeletonConfig.cfm">
<cfparam name="ideeventinfo">
<cfif not isXML(ideeventinfo)>
	<cfexit>
</cfif>
<cfset data = xmlParse(ideeventinfo)>

<cfheader name="Content-Type" value="text/xml">  
<cfoutput>  
	<response>  
		<ide handlerfile="generateSkeleton.cfm"> 
			<dialog width="500" height="425" title="Provide Application Defaults and Select Core Mach-II Options" image="includes/images/MachIILogo.png">  
				<body>
					<input name="appName" label="Application Name" type="string" tooltip="The name that Mach-II will call your application internally." required="true" />
					<input name="eventParamName" label="Event Parameter Name" type="string" tooltip="The name of the event parameter that appears in all URLs" default="event" />
					<input name="useColdSpring" label="Use ColdSpring?" tooltip="Select this option if you want the ColdSpring property for Mach-II to be turned on." type="boolean" checked="true" />
					<input name="useSESURLs" label="Use SES URLs?" tooltip="Select this option if you want to use Search Engine Safe URLs in this application." type="boolean" checked="true" />
					<input name="basicLogging" label="Turn on basic, on-screen logging?" tooltip="Select this option if you want to turn on the default, on-screen logging of Mach-II events." type="boolean" checked="true" />
					<input name="dashPassword" label="Dashboard Password" type="string" tooltip="The password to access the Mach-II Dashboard, included as part of Mach-II 1.9+" default="admin" />
					<input name="webroot" label="Server wwwroot:" default="{$wwwroot}" type="dir" />
				</body>			
			</dialog>
		</ide>
	</response>  
</cfoutput> 

