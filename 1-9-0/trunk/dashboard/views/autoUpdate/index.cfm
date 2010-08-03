<cfsilent>
<!---
User:  derrick_desktop
Date: 5/4/2009 10:00:45 AM
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