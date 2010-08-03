<cfsilent>
<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
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
					paintstyle="light" >
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