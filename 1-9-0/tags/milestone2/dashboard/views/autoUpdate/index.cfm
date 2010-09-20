<cfsilent>
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

$Id$ 

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Auto Update Information" />

	<cfset autoUpdateReleaseTypes = getProperty("autoUpdateReleaseTypes") />
	<cfset theStatus = event.getArg('packageData').exitEvent />

	<cfif theStatus NEQ 'fail'>
		<cfset theStatus = "success" />
		<cfset statusMessage = "">
		
		<cfset packageData = event.getArg("packageData") />
		<cfset frameworkData = packageData.framework />
		<cfset dashboardData = packageData.dashboard />
	<cfelse>
		<cfset statusMessage = event.getArg('packageData').message.getMessage() />
	</cfif>
</cfsilent>

<cfoutput>
<dashboard:displayMessage />
<h1>Auto Update Information</h1>
<table>
	<tr>
		<th colspan="2"><h3>Mach-II Framework Information</h3></th>
	</tr>
	<tr>
		<td style="width:15%;"><h4>Current Version</h4></td>
		<td style="width:85%;"><p>#getProperty("udfs").getMachIIVersionString()#</p></td>
	</tr>
	<tr class="shade">
		<td><h4>Available Version(s)</h4></td>
		<td>
			<p>
				<cfif theStatus EQ 'success'>
					<table border="0">
						<tr>
							<td width="20%"><strong>Version</strong></td>
							<td width="20%"><strong>Release Type</strong></td>
							<td width="20%"><strong>Build</strong></td>
							<td width="20%"><strong>Release Date</strong></td>
							<td width="20%"><strong>Download Zip</strong></td>
						</tr>
						<cfloop query="frameworkData">
						<tr>
							<td>#frameworkData.version#</td>
							<td>#autoUpdateReleaseTypes['P#frameworkData.releaseType#']#</td>
							<td>#frameworkData.build#</td>
							<td>#DateFormat(frameworkData.dateReleased,"mm/dd/yyyy")#</td>
							<td><a href="#frameWorkData.filelocation#">Mach-II #frameWorkData.version#</a></td>
						</tr>
						</cfloop>
					</table>
				<cfelse>
					#statusMessage#
				</cfif>
			</p>
		</td>
	</tr>
</table>
<br/>
<table>
	<tr>
		<th colspan="2"><h3>Dashboard Information</h3></th>
	</tr>
	<tr>
		<td style="width:15%;"><h4>Current Version</h4></td>
		<td style="width:85%;"><p>#getProperty("udfs").getVersionString()#</p></td>
	</tr>
	<tr class="shade">
		<td><h4>Available Version(s)</h4></td>
		<td>
			<p>
				<cfif theStatus EQ 'success'>
					<table border="0">
						<tr>
							<td width="20%"><strong>Version</strong></td>
							<td width="20%"><strong>Release Type</strong></td>
							<td width="20%"><strong>Build</strong></td>
							<td width="20%"><strong>Release Date</strong></td>
							<td width="20%"><strong>Download ZIP</strong></td>
						</tr>
						<cfloop query="dashboardData">
						<tr>
							<td>#dashboardData.version#</td>
							<td>#autoUpdateReleaseTypes['P#dashboardData.releaseType#']#</td>
							<td>#dashboardData.build#</td>
							<td>#DateFormat(dashboardData.dateReleased,"mm/dd/yyyy")#</td>
							<td><a href="#dashboardData.filelocation#">Mach-II Dasboard #dashboardData.version#</a></td>
						</tr>
						</cfloop>
					</table>
				<cfelse>
					#statusMessage#
				</cfif>
			</p>
		</td>
	</tr>
</table>
</cfoutput>