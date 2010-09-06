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

Created version: 1.1.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfset variables.memoryData = getProperty("udfs").getMemoryData() />
</cfsilent>
<cfoutput>
<table>
	<tr>
		<th colspan="3"><h3>JVM Memory Information^</h3></th>
	</tr>
	<tr>
		<td colspan="3">
		<cfif getProperty("chartProvider") EQ "cfchart">
			<div style="width:435px;height:435px;">
			<cfchart format="png" 
				show3d="true" 
				chartwidth="435" 
				chartheight="435" 
				pieslicestyle="sliced"
				tipstyle="none"  
				title="Memory Usage (in MB)">
				<cfchartseries type="pie" 
					colorList="green,red,blue" 
					paintstyle="light">
					<cfchartdata item="Free Memory" 
						value="#getProperty("udfs").byteConvert(memoryData["JVM - Free Memory"], "MB", false)#" />
					<cfchartdata item="Used Memory" 
						value="#getProperty("udfs").byteConvert(memoryData["JVM - Used Memory"], "MB", false)#" />
					<cfchartdata item="Unallocated Memory" 
						value="#getProperty("udfs").byteConvert(memoryData["JVM - Unallocated Memory"], "MB", false)#" />
				</cfchartseries>
			</cfchart>
			</div>
		<cfelseif getProperty("chartProvider") EQ "googlecharts">
			<view:img src="http://chart.apis.google.com/chart?cht=p3&chd=t:#memoryData["JVM - Free Memory"]#,#memoryData["JVM - Used Memory"]#,#memoryData["JVM - Unallocated Memory"]#&chds=0,#memoryData["JVM - Max Memory"]#&chs=435x250&chl=#getProperty("udfs").byteConvert(memoryData["JVM - Free Memory"], "MB", false)# MB|#getProperty("udfs").byteConvert(memoryData["JVM - Used Memory"], "MB", false)# MB|#getProperty("udfs").byteConvert(memoryData["JVM - Unallocated Memory"], "MB", false)# MB&chco=0000FF,FF0000,00FF00&chtt=Memory%20Usage&chdl=Free|Used|Unallocated&chdlp=b&chts=000000"
				width="435"
				height="250" />
		<cfelse>
			<h4 class="center">Charting Not Enabled</h4>
		</cfif>
		</td>
	</tr>
	<tr>
		<td style="width:33%;">
			<h4>Allocated</h4>
		</td>
		<td style="width:33%;">
			<p>#getProperty("udfs").formatMB(memoryData["JVM - Total Memory"])#</p>
		</td>
		<td style="width:33%;">
			<p>#getProperty("udfs").getPercentage(memoryData["JVM - Total Memory"], memoryData["JVM - Max Memory"], "1")#%</p>
		</td>
	</tr>
	<tr class="shade">
		<td>
			<p class="small"><strong>Used Allocated</strong></p>
			<p class="small"><strong>Free Allocated</strong></p>
		</td>
		<td>
			<p class="small">#getProperty("udfs").formatMB(memoryData["JVM - Used Memory"])#</p>	
			<p class="small">#getProperty("udfs").formatMB(memoryData["JVM - Free Memory"])#</p>
		</td>
		<td>
			<p class="small">#getProperty("udfs").getPercentage(memoryData["JVM - Used Memory"], memoryData["JVM - Total Memory"], "1")#% of Allocated</p>
			<p class="small">#getProperty("udfs").getPercentage(memoryData["JVM - Free Memory"], memoryData["JVM - Total Memory"], "1")#% of Allocated</p>
		</td>
	</tr>
	<tr>
		<td><h4>Unallocated</h4></td>
		<td><p>#getProperty("udfs").formatMB(memoryData["JVM - Unallocated Memory"])#</p></td>
		<td><p>#getProperty("udfs").getPercentage(memoryData["JVM - Unallocated Memory"], memoryData["JVM - Max Memory"], "1")#%</p></td>
	</tr>
	<tr class="shade">
		<td><h4>Max</h4></td>
		<td><p>#getProperty("udfs").formatMB(memoryData["JVM - Max Memory"])#</p></td>
		<td><p>100%</p></td>
	</tr>
</table>
<p class="small">^ Totals and percents may not add up exactly due to rounding</p>
<p class="small">The memory information automatically updates every 30 seconds</p>
</cfoutput>