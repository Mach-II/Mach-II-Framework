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
	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<view:meta type="title" content="Tools - Bean Generator" />
	<!--- By default, all script and style are put in the head --->
	<view:script endpoint="dashboard.serveAsset" p:file="/js/beangenerator.js" />
</cfsilent>
<cfoutput>
<dashboard:displayMessage />

<h1>Bean Generator</h1>

<form:form name="configureForm" id="configureForm" autoFocus="false">
	<table>
		<tr>
			<td style="width:50%;">
				<h2 style="margin-bottom:5px;"><label id="propertyInfo">Bean Template</label></h2>
				<p><form:textarea name="propertyInfo" style="width:100%;height:250px" /></p>
			</td>
			<td style="width:50%;">
				<h2>Bean Options</h2>
				<table>
					<tr>
						<th style="width:25%;"><h3>Bean Name</h3></th>
						<td style="width:75%;"><p><form:input name="beanName" size="35" /></p></td>
					</tr>
					<tr>
						<th><h3>Path to Bean</h3></th>
						<td><p><form:input name="beanPath" size="35" /></p></td>
					</tr>
					<tr>
						<th><h3>Extends</h3></td>
						<td><p><form:input name="cfcextends" size="35" /></p></td>
					</tr>
					<tr>
						<th><h3>Date Format</h3></td>
						<td><p><form:input name="dateFormat" value="MM/DD/YYYY" size="15" onclick="javascript:clearText(this)" /></p></td>
					</tr>
					<tr>
						<th><h3>Options</h3></th>
						<td>
							<p><label><form:checkbox name="callSuper" value="y" />Call super.init()?</label></p>
							<p><label><form:checkbox name="comments" value="y" />Template code in bean?</label> </p>
							<p><label><form:checkbox name="setMemento" value="y" />setMemento()</label></p>
							<p><label><form:checkbox name="getMemento" value="y" />getMemento()</label></p>
							<p><label><form:checkbox name="setStepInstance" value="y" />setStepInstance()</label></p>
							<p><label><form:checkbox name="dump" value="y" />Add dump()</label></p>
							<p><label><form:checkbox name="addTrim" value="y" />Add trim() in setters</label></p>
							<p><label><form:checkbox name="validate" value="y" />validate()</label></p>
							<p><label><form:checkbox name="validateInterior" value="y" />Create boilerplate validate interior?</label></p>
						</td>
					</tr>
				</table>
	
			</td>
		</tr>
	</table>
	<p class="right">
		<form:button value="Execute" name="Execute" />
		<form:button value="Example" name="Example" />
		<form:button onclick="javascript:document.beanResults.results.value=''" type="reset" value="Reset" name="reset" />
	</p>
</form:form>

<p class="clear" style="padding-top:24px;" />

<h2>Generated Bean</h2>
<form:form name="showBeanResults" actionEvent="tools.beanGenerator.saveGeneratedBean" autoFocus="false">
	<p style="margin-top:24px;margin-bottom:24px;">
		<form:textarea name="results" style="width:100%;height:400px;" class="beanResults" />
	</p>
	<table>
		<tr>
			<th style="width:15%;"><h3>Write CFC to file?</h3></th>
			<td style="width:85%;">
				<p><form:input name="fileLocation" size="75" value="" /></p>
				<p>Enter full path and file name in relation to: <pre class="small">#ExpandPath('/')#</pre></p>
			</td>
		</tr>
	</table>
	<p class="right"><form:button name="save" value="Create Bean CFC" /></p>
</form:form>

<view:script outputType="inline">
	Event.observe('Execute', 'click', function(event) {
		Event.stop(event); // stop the form from submitting first in case we encounter an error
		$('results').value = executeRooibos();
	});

	Event.observe('Example', 'click', function(event) {
		Event.stop(event); // stop the form from submitting first in case we encounter an error
		$('results').value = executeExample();
	});
</view:script>
</cfoutput>