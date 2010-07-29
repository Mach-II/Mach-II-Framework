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

Author: Doug Smith (doug.smith@daveramsey.com)
$Id: HasAnnotations.cfc 2204 2010-04-27 07:36:11Z peterfarrell $

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent displayname="TestRestEndpoint"
	extends="MachII.endpoints.rest.BaseEndpoint"
	hint="Test Rest Endpoint."
	output="false">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfset super.configure() />
	</cffunction>

	<!---
	PUBLIC METHODS
	--->

	<cffunction name="testGetContent"
				access="public" returntype="String" output="false"
				rest:uri="/content/item/{key}"
				rest:method="GET"
				hint="Test GET method with variable {key} token.">

		<cfset var key = event.getArg("key", "") />
		<cfset var addHtml = event.getArg("addHtml", false) />
		<cfset var format = event.getArg("format", "html") />
		<cfset var version = event.getArg("version", "approved") />
		<cfset var contentItemBean = "" />

		<cftry>

			<cfif key EQ 'notfound'>
				<!--- Test fake 404. --->
				<cfthrow type="contentitem.load.failed" />
			</cfif>

			<cfif format EQ "json">
				<cfreturn '{key: #key#, value: "I''m a test of the REST endpoint in JSON format."}' />
			<cfelse>
				<!--- Defaults to HTML format --->
				<cfreturn '<p>I''m test content rendered in HTML format with key: ''#key#''.</p>' />
			</cfif>
			<cfcatch type="contentitem.load.failed">
				<cfheader statuscode="404" statustext="Not Found" />
				<cfheader name="machii.endpoint.error.notfound" value="Content item named '#key#' not available." />
				<cfreturn "" />
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>