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
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Exception" />
	
	<cfset variables.exception = event.getArg("exception") />
</cfsilent>
<cfoutput>

<h1>Exception</h1>
	
<h2 style="margin:1em 0 3px 0">Information</h2>
<table>
	<tr>
		<th style="width:15%;"><h3>Request Name</h3></th>
		<td style="width:85%;"><p><cfif Len(event.getRequestModuleName())>#event.getRequestModuleName()##getProperty("moduleDelimiter")#</cfif>#event.getRequestName()#</p></td>
	</tr>
	<tr>
		<th><h3>Message</h3></th>
		<td><p>#variables.exception.getMessage()#</p></td>
	</tr>
	<tr>
		<th><h3>Detail</h3></th>
		<td><p><cfif NOT Len(variables.exception.getDetail())>&nbsp;<cfelse>#variables.exception.getDetail()#</cfif></p></td>
	</tr>
	<tr>
		<th><h3>Extended Info</h3></th>
		<td><p><cfif NOT Len(variables.exception.getExtendedInfo())>&nbsp;<cfelse>#variables.exception.getExtendedInfo()#</cfif></p></td>
	</tr>
	<tr>
		<th><h3>Caught Exception</h3></th>
		<td><cfdump var="#variables.exception.getCaughtException()#" expand="false" label="Caught Exception" /></td>
	</tr>
</table>

<h2 style="margin:1em 0 3px 0">Tag Context</h2>
<cfset variables.tagCtxArr = variables.exception.getTagContext() />
<table>
	<tr>
		<th style="width:15%;"><h3>Line</h3></th>
		<th style="width:85%;"><h3>Template / Raw Trace</h3></th>
	</tr>
<cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
	<cfset variables.tagCtx = variables.tagCtxArr[i] />
	<tr class="<view:flip value="#i#" items="shade" />">
		<td><p>#variables.tagCtx["line"]#</p></td>
		<td>
			<p>#variables.tagCtx["template"]#</p>
		<cfif StructKeyExists(variables.tagCtx, "raw_trace")>
			<p class="small">#ReplaceNoCase(variables.tagCtx["raw_trace"], variables.tagCtx["template"] & ":" & variables.tagCtx["line"], "...")#</p>
		</cfif>
		</td>
	</tr>
</cfloop>
</table>
</cfoutput>