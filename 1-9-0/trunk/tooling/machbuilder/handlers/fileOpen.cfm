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
 
<cfheader name="Content-Type" value="text/xml" />
<cfsetting showdebugoutput="false" />
 
<cfparam name="ideeventinfo" />
<cfset data = xmlParse(ideeventinfo) />
<cfset myFile = data.event.ide.projectview.resource.xmlAttributes.path />
<cfset projectName = data.event.ide.projectview.xmlAttributes.projectname />
 
<cflog file="machbuilder" type="information" text="#ideEventInfo#" />
<cflog file="machbuilder" type="information" text="file: '#myFile#', project: '#projectName#'" />
 
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