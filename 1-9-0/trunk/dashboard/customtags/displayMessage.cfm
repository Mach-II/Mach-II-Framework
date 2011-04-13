<cfsetting enablecfoutputonly="true" />
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
Updated version: 1.0.0

Notes:
--->
<cfimport prefix="view" taglib="/MachII/customtags/view" />
<cfif thisTag.ExecutionMode IS "start">

	<cfset variables.event = request.event />
	<cfparam name="attributes.message" default="#variables.event.getArg("message")#" >
	<cfset variables.message = attributes.message />

	<cfif isObject(variables.message)>

		<cfset variables.unique = getTickCount() />
	
	
		<cfparam name="attributes.refresh" default="true" />
	
		<cfoutput>
		<div id="messageBox_#variables.unique#">
		<div class="#variables.message.getType()#">
			<p>#variables.message.getMessage()#</p>
		</div>
	
		<cfif variables.message.hasCaughtException()>
			<cfset variables.exception = variables.message.getCaughtException() />
		
			<table>
				<tr>
					<th style="width:15%;">
						<h3>Message</h3>
					</th>
					<td style="width:85%;">
						<p>#variables.exception.message#</p>
					</td>
				</tr>
				<tr>
					<th>
						<h3>Detail</h3>
					</th>
					<td>
						<p>#variables.exception.detail#</p>
					</td>
				</tr>
				<tr>
					<th>
						<h3>Type</h3>
					</th>
					<td>
						<p>#variables.exception.type#</p>
					</td>
				</tr>
				<tr>
					<th>
						<h3>Full Catch</h3>
					</th>
					<td>
						<p><cfdump var="#variables.exception#" expand="false" /></p>
					</td>
				</tr>
			</table>
		</cfif>
		</div>

		<view:script outputType="inline">
			function flashTitle(newTitle) {
				var state = false;
				originalTitle = document.title;  // save old title
				titleTimerId = setInterval(flash, 1500);
			
				function flash() {
					// switch between old and new titles
			   		document.title = state ? originalTitle : newTitle;
					state = !state;
			  	}
			}
			
			function clearTitleFlash() {
				if (typeof titleTimerId !== 'undefined') {
					clearInterval(titleTimerId);
					document.title = originalTitle;
				}
			}
			
			clearTitleFlash();

			<cfif variables.message.isExceptionOfType("exception")>
				flashTitle('Exception Occurred');
			</cfif>
		</view:script>
	
		<cfif NOT variables.message.isExceptionOfType("exception") AND  attributes.refresh>
			<view:script outputType="inline">
				timeoutId = setInterval(function() { new Effect.BlindUp('messageBox_#variables.unique#', { queue: 'end' }); clearTimeout(timeoutId);}, 5000);
			</view:script>
		</cfif>
		</cfoutput>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />