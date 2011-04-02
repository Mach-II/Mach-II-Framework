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
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<view:meta type="title" content="Tools - Bean Generator" />
</cfsilent>
<cfoutput>

<cfsavecontent variable="beanHeaderData">
	<view:script endpoint="dashboard.serveAsset" p:file="/js/rooibos.js" outputType="inline" />
	<style>
		table { font-size: 100%; /* another IE hack */ }
		input, textarea, select {	font-size: 90%;	font-family: Arial, Helvetica, sans-serif;}
	</style>
</cfsavecontent>

<cfhtmlhead text="#beanHeaderData#" />
<dashboard:displayMessage />
<h1>Bean Generator</h1>

<table border="0">
	<tr>
		<td width="40%">
			<form:form name="configureForm" id="configureForm" autoFocus="propertyInfo" method="post">
			<table border="0">
				<tr>
					<td>
						<h2 style="margin-bottom:5px;"><label id="propertyInfo">Bean Template</label></h2>
						<form:textarea name="propertyInfo" rows="30" cols="70" />
					</td>
				</tr>
				<tr class="shade">
					<td>
						<h2>Bean Options</h2>
						<table border="0">
							<tr>
								<td colspan="2"><label>Bean Name<br/><form:input name="beanName" size="50" /></label></td>
							</tr>
							<tr>
								<td colspan="2">
									<label>Path to Bean (full path if generating flex stub)<br/><form:input name="beanPath" size="50" /></label>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<label>Extends<br/><form:input name="cfcextends" size="50" /></label>
								</td>
							</tr>
							<tr>
								<td>
									<label><form:checkbox name="callSuper" value="y" />Call super.init()?</label>
									<label><form:checkbox name="comments" value="y" />Template code in bean?</label> 
									<label><form:checkbox name="setMemento" value="y" />setMemento()</label> 
									<label><form:checkbox name="getMemento" value="y" />getMemento()</label>
									<label><form:checkbox name="setStepInstance" value="y" />setStepInstance()</label>
								</td>
								<td>
									<label><form:checkbox name="addTrim" value="y" />Add trim() in setters?</label>
									<label><form:checkbox name="validate" value="y" />validate()</label> 
									<label><form:checkbox name="validateInterior" value="y" />Create boilerplate validate interior?</label>
									<label><form:checkbox name="dump" value="y" />Add dump()</label>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<label>Date Format<br/><form:input name="dateFormat" value="MM/DD/YYYY" size="15" onclick="javascript:clearText(this)" /></label>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<h2 style="margin-bottom:5px;">LTO Options</h2>
						<table border="1">
							<tr class="shade">
								<td>
									<form:checkbox name="generateLTO" value="y" />Generate LTO?&nbsp;&nbsp;
									<form:checkbox name="createLTOMethods" value="y" />LTO methods<br/>
									<span style="margin-left:8px;">
										Path to LTO<br/><input name="toName" type="text" id="toPath" size="50" />
									</span>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<h2>Flex Options</h2>
						<table border="1">
							<tr class="shade">
								<td>
									<label><form:checkbox name="generateStub" value="y" />Generate Flex stub?</label>
									<label><form:checkbox  name="createProperties" value="y" />Create cfproperties?</label> 
									<label>Flex AS Package<br/><form:input  name="flexAlias" size="50" /></label>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<input type="button" onclick="javascript:executeRooibos();" value="Execute" name="Execute" class="button" />
						<input type="button" onclick="javascript:executeExample();" value="Example" name="Example" class="button" />
						<input onclick="javascript:document.beanResults.results.value='';document.transferObjectResults.results.value='';document.stubResults.results.value='';" type="reset" value="Reset" name="reset" class="button" />
						<input type="button" onclick="javascript:alert('Please view the source of this page and read the HTML comments. Your ad clicks support my involement in free software projects like Rooibos Generator and Mach-II.');" value="Help"  class="button" />
					</td>
				</tr>
			</table>
			</form:form>
		</td>
		<td valign="top" width="60%">
			<table border="0">
				<tr>
					<td>
						<form:form name="beanResults" action="#BuildURL('tools.beanGenerator.saveGeneratedBean')#" method="post">
							<h2 style="margin-bottom:5px;">Generated Bean</h2>
							<form:textarea name="results" rows="30" cols="110" class="beanResults" onclick="javascript:this.focus();this.select()" />
							Write CFC to file?<br/>Enter full path and file name in relation to: #ExpandPath('/')#<br/><form:input name="fileLocation" size="75" value="" /><br/>
							<form:button name="save" value="Create Bean CFC" />
						</form:form>
					</td>
				</tr>
				<tr>
					<td>
						<form:form name="transferObjectResults" action="rooibos.htm" method="post">
						<h2 style="margin-bottom:5px;">Generated Lightweight Tranfer Object</h2>
						<form:textarea name="results" rows="21" cols="110" class="ltoResults" onclick="javascript:this.focus();this.select()" />
					</form:form>
					</td>
				</tr>
				<tr>
					<td>
						<form:form name="stubResults" action="rooibos.htm" method="post">
						<h2 style="margin-bottom:5px;">Generated Stub</h2>
						<form:textarea name="results" rows="21" cols="110" class="stubResults" onclick="javascript:this.focus();this.select()"/>
					</form:form>
					</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>



</cfoutput>