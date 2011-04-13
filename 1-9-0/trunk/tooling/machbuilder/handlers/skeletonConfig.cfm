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
<cfsetting showdebugoutput="false" />
<cflog file="storm" text="#timeFormat(now())# -- Starting skeletonConfig.cfm" />
<cfparam name="ideeventinfo" />
<cfif NOT isXML(ideeventinfo)>
	<cfexit />
</cfif>

<cfset data = xmlParse(ideeventinfo) />

<cfheader name="Content-Type" value="text/xml" />  
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

