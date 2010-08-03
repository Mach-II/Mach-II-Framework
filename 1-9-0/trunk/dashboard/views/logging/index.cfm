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