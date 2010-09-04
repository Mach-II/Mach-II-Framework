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
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Logging" />
	<cfset copyToScope("${event.loggers}") />
	
	<cfset variables.moduleOrder = StructKeyList(variables.loggers) />
	<cfif ListFindNoCase(variables.moduleOrder, "base")>
		<cfset variables.moduleOrder = ListDeleteAt(variables.moduleOrder, ListFindNoCase(variables.moduleOrder, "base")) />
		<cfset variables.moduleOrder = ListPrepend(variables.moduleOrder, "base") />
	</cfif>
	<cfset variables.moduleOrder = ListToArray(variables.moduleOrder) />
</cfsilent>
<cfoutput>
<dashboard:displayMessage />

<h1>Logging</h1>

<cfif StructCount(variables.loggers) GT 0>
<ul class="pageNavTabs">
 	<li class="green">
		<a href="#BuildUrl("logging.enableDisableAll", "mode=enable")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@accept.png")#" width="16" height="16" alt="Enabled" />
			&nbsp;Enable All
		</a>
	</li>
	<li class="red">
		<a href="#BuildUrl("logging.enableDisableAll", "mode=disable")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@stop.png")#" width="16" height="16" alt="Disabled" />
			&nbsp;Disable All
		</a>
	</li>
</ul>


<cfloop from="1" to="#ArrayLen(variables.moduleOrder)#" index="i">
	<cfset module = variables.moduleOrder[i] />
	<h2 style="margin:1em 0 3px 0;">#UCase(Left(module, 1))##Right(module, Len(module) -1)# Module</h2>
	<table>
		<tr>
			<th style="width:70%;"><h3>Name / Configuration</h3></th>
			<th style="width:15%;"><h3>Level</h3></th>
			<th style="width:15%;"><h3>Status</h3></th>
		</tr>
	<cfset count = 0 />
	<cfloop collection="#variables.loggers[module]#" item="loggerName">
		<cfset logger = variables.loggers[module][loggerName] />
		<cfset configData = logger.getConfigurationData() />
		<cfset count = count + 1 />
		<tr <cfif count MOD 2>class="shade"</cfif>>
			<cfset loggerType = logger.getLoggerType() />
			<td>
				<h4>#loggerName#</h4>
				<p class="small">
				<cfif listGetAt(loggerType, 1, ".") eq "MachII">
					<a href="#getProperty("udfs").getCFCDocUrl(loggerType)#" target="_blank">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@link_go.png")#" width="16" height="16" alt="Link" />
						#logger.getLoggerTypeName()# (#loggerType#)
					</a>
				<cfelse>
					#logger.getLoggerTypeName()# (#loggerType#)
				</cfif>
				</p>
				
				<cfif StructCount(configData)>
					<hr />
					<table class="small">
					<cfloop collection="#configData#" item="propName">
						<cfif NOT listFindNoCase("type,generatedScopeKey,adapter", propName)>
							<tr>
								<td style="width:35%;"><h4>#propName#</h4></td>
								<td style="width:65%;">
								<cfset propValue = configdata[propName] />
								<cfif IsSimpleValue(propValue)>
									<cfif Len(propValue)>
										<p>#propValue#</p>
									<cfelse>
										<p>&nbsp;</p>
									</cfif>
								<cfelse>
									<p><em>[complex value]</em></p>
								</cfif>
								</td>					
							</tr>
						</cfif>
					</cfloop>
					</table>
				</cfif>
			<hr />
			<cfif logger.getLogAdapter().isFilterDefined()>
				<cfset filter = logger.getLogAdapter().getFilter() />
				<cfset filterType = filter.getFilterType() />
				<h4>Filter</h4>
				<p class="small">
				<cfif listGetAt(filterType, 1, ".") eq "MachII">
					<a href="#getProperty("udfs").getCFCDocUrl(filterType)#" target="_blank">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@link_go.png")#" width="16" height="16" alt="Link" /> 
						#filter.getFilterTypeName()# (#filterType#)
					</a>
				<cfelse>
					#filter.getFilterTypeName()# (#filterType#)
				</cfif>
				</p>
				
				<cfset filterCriteria = filter.getFilterCriteria() />
				<hr />
				<cfif IsArray(filterCriteria) AND ArrayLen(filterCriteria)>
					<ul class="small">
					<cfloop from="1" to="#ArrayLen(filterCriteria)#" index="i">
						<li>#filterCriteria[i]#</li>
					</cfloop>
					</ul>
				<cfelseif IsStruct(filterCriteria) AND StructCount(filterCriteria)>
					<table class="small">
					<cfloop collection="#filterCriteria#" item="i">
						<tr>
							<td style="width:35%;"><h4>#i#</h4></td>
							<td style="width:65%;"><p>#filterCriteria[i]#</p></td>
						</tr>
					</cfloop>
					</table>
				<cfelse>
					<p class="small"><em>No criteria defined for this filter</em></p>
				</cfif>
			<cfelse>
				<p class="small"><em>No filter defined for this logger</em></p>
			</cfif>
			</td>
			<cfset variables.level = logger.getLoggingLevel() />
			<td>
				<form:form actionEvent="logging.changeLoggingLevel" id="change_level_#module#_#loggerName#">
					<form:hidden name="moduleName" value="#module#" />
					<form:hidden name="loggerName" value="#loggerName#" />
					<p>
						<form:select name="level" 
							checkValue="#variables.level#" 
							style="width:8em;" 
							onchange="document.getElementById('change_level_#module#_#loggerName#').submit();"
							items="All,Trace,Debug,Info,Warn,Error,Fatal,Off" />
					</p>
				</form:form>
			</td>
			<td>
				<ul class="none">
				<cfif logger.isLoggingEnabled()>
					<li class="green">
						<a href="#BuildUrl("logging.enableDisableLogger", "moduleName=#module#|loggerName=#loggerName#|mode=disable")#" title="Click to Disable">
							<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@accept.png")#" width="16" height="16" alt="Enabled" />
							&nbsp;Enabled
						</a>
					</li>
				<cfelse>
					<li class="red">
						<a href="#BuildUrl("logging.enableDisableLogger", "moduleName=#module#|loggerName=#loggerName#|mode=enable")#" title="Click to Enable">
							<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@stop.png")#" width="16" height="16" alt="Disabled" />
							&nbsp;Disabled
						</a>
					</li>
				</cfif>
				</ul>				
			</td>
		</tr>	
	</cfloop>
	</table>
</cfloop>
<cfelse>
<h4>There are no loggers defined for this application.</h4>
</cfif>
</cfoutput>