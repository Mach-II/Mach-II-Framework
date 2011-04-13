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
 
<cflog file="machbuilder" type="information" text="#ideEventInfo#" />
<cfheader name="Content-Type" value="text/xml" />

<cfset data = xmlParse(ideeventinfo) />
<cfset application.data = data />
<cfset separator = createObject("java", "java.io.File").separator />
<cfset hostname = data.event.ide.projectview.server.xmlAttributes["hostname"] />
<cfif data.event.ide.projectview.server.xmlAttributes["port"] neq 80>
	<cfset hostname = hostname & ":" & data.event.ide.projectview.server.xmlAttributes["port"] />
</cfif>
<cfset path = data.event.ide.projectview.resource.xmlAttributes["path"] />
<cfset path = listGetAt(path, listLen(path, separator) - 1, separator) />

<cflog file="machbuilder" 
	text="Attempting to open: http://#hostname#/#path#/index.cfm/event/dashboard:builder.index/callbackurl/#urlencodedFormat(data.event.ide.callbackurl.xmlText)#" />

<cfoutput>  
<response showresponse="true"> 
	<ide url="http://#hostname#/#path#/index.cfm/event/dashboard:builder.index/?callbackurl=#urlencodedFormat(data.event.ide.callbackurl.xmlText)#/"> 
		<view id="machiiDashboard" title="Mach II Dashboard" /> 
	</ide> 
</response> 
</cfoutput>