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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfset variables.exception = event.getArg("exception") />
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
 "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">
<html>
	<head>
		<title>Mach-II Endpoint Exception</title>
    	<meta http-equiv="Content-Type" content="text/html" />
	</head>
	<body>
		<h3>Mach-II Endpoint Exception</h3>

		<table>
			<tr>
				<td valign="top"><h4>Endpoint</h4></td>
				<td valign="top"><p>#getParameter("name")#</p></td>
			</tr>
			<tr>
				<td valign="top"><h4>Type</h4></td>
				<td valign="top"><p>#variables.exception.getType()#</p></td>
			</tr>
			<tr>
				<td valign="top"><h4>Message</h4></td>
				<td valign="top"><p>#variables.exception.getMessage()#</p></td>
			</tr>
			<tr>
				<td valign="top"><h4>Detail</h4></td>
				<td valign="top"><p>#variables.exception.getDetail()#</p></td>
			</tr>
			<tr>
				<td valign="top"><h4>Extended Info</h4></td>
				<td valign="top"><p>#variables.exception.getExtendedInfo()#</p></td>
			</tr>
			<tr>
				<td valign="top"><h4>Tag Context</h4></td>
				<td valign="top">
					<cfset variables.tagCtxArr = variables.exception.getTagContext() />
					<cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
						<cfset variables.tagCtx = variables.tagCtxArr[i] />
						<p>#variables.tagCtx['template']# (#variables.tagCtx['line']#)</p>
					</cfloop>
				</td>
			</tr>
			<tr>
				<td valign="top"><h4>Caught Exception</h4></td>
				<td valign="top"><cfdump var="#variables.exception.getCaughtException()#" expand="false" /></td>
			</tr>
			<tr>
				<td valign="top"><h4>Event</h4></td>
				<td valign="top"><cfdump var="#event.getArgs()#" expand="false" /></td>
			</tr>
		</table>
	</body>
</html>
</cfoutput>