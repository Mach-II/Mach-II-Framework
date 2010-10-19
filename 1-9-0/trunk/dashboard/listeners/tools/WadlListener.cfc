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

Copyright: GreatBizTools, LLC
$Id: RegExListener.cfc 2372 2010-09-08 00:17:06Z peterjfarrell $

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="WadlListener"
	extends="MachII.framework.Listener"
	output="false"
	hint="Generates WADL documentation through introspection of endpoints.">

	<!---
	PROPERTIES
	--->
	<cfset variables.introspector = "" />
	<cfset variables.ANNOTATION_REST_BASE = "REST" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the listener.">
		<!--- Does nothing --->
		<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	</cffunction>
<!------>
	<cffunction name="getRestEndpointMetaData" access="public" returntype="struct" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfset var allEndpoints = getAppManager().getEndpointManager().getEndpoints() />
		<cfset var restEndpoints = StructNew() />
		<cfset var endpoint = "" />
		<cfset var endpointKey = "" />
		<cfset var restComponentMetadata = "" />
		<cfset var restMethodMetadata = "" />
		<cfset var stcResult = StructNew() />
		<cfset var item = "" />
		<cfset var itemFunction = "" />
		<cfset var stcTemp = StructNew() />
		<cfset var uri = "" />
		<cfset var httpMethod = "" />

		<cfset stcResult.methodMetadata = StructNew () />
		<cfloop collection="#allEndpoints#" item="endpointKey">
			<cftry>
				<cfset endpoint = allEndpoints[endpointKey]  />
				<cfset restEndpoints[endpointKey] = endpoint />
				<cfset restComponentMetadata = variables.introspector.getComponentDefinition(object:restEndpoints[endpointKey], walkTree:true, walkTreeStopClass:'MachII.endpoints.rest.BaseEndpoint') />
				<cfloop array="#restComponentMetadata#" index="item" >
					<cfset stcResult.componentMetadata[item.component] = item />
				</cfloop>
				<cfset restMethodMetadata = variables.introspector.findFunctionsWithAnnotations(object:restEndpoints[endpointKey], namespace:variables.ANNOTATION_REST_BASE, walkTree:true, walkTreeStopClass:'MachII.endpoints.rest.BaseEndpoint') />
				<cfloop array="#restMethodMetadata#" index="item" >
					<cfloop array="#item.functions#" index="itemFunction">
						<cfset pattern = itemFunction["REST:URI"]/>
						<cfset httpMethod = itemFunction["REST:METHOD"]/>
						<cfset uri = endpoint.getRestUris().getUriByPattern(pattern, httpMethod) />

						<cfif StructKeyExists(stcResult.methodMetadata, pattern)>
							<cfset stcTemp = stcResult.methodMetadata[pattern] />
						<cfelse>
							<cfset stcTemp = StructNew() />
						</cfif>

						<cfset stcTemp[httpMethod] = Duplicate(itemFunction) />
						<cfset stcTemp[httpMethod].COMPONENT = item.component />
						<cfset stcTemp[httpMethod].TOKENS = uri.getUriTokenNames() />
						<cfset stcResult.methodMetadata[pattern] = stcTemp />
					</cfloop>
				</cfloop>
				<cfcatch type="Application">
					<!--- This will fail for non-rest endpoints. --->
				</cfcatch>
			</cftry>
		</cfloop>

		<cfreturn stcResult />
	</cffunction>

	<cffunction name="getWadlDocumentation" access="public" returntype="string" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var strWadl = "" />
		<cfcontent reset="true" />
		<cfset addHTTPHeaderByName("Content-Type", "application/xml") />
		<cfset stylesheet = event.getArg('stylesheet', BuildEndpointUrl("dashboard.serveAsset", "file=/xsl/wadl_documentation-2006-10.xsl")) />
		<cfset event.setArg('stylesheet', stylesheet) />
	</cffunction>
</cfcomponent>