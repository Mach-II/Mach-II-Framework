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