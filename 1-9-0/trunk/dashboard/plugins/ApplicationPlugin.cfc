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
<cfcomponent
	displayname="ApplicationPlugin"
	extends="MachII.framework.Plugin"
	output="false"
	hint="Performs login check and other application level plugin point events.">

	<!---
	PROPERTIES
	--->
	<cfset variables.unprotectedEvents = ArrayNew(1) />
	<cfset variables.loginIPsEnabled = false />
	<cfset variables.loginIPs = ArrayNew(1) />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Performs configuration logic.">

		<cfset var unprotectedEvents = getParameter("unprotectedEvents") />
		<cfset var loginIPs = getParameter("loginIPs") />

		<!--- Add the exception event --->
		<cfset ArrayAppend(unprotectedEvents, getProperty("exceptionEvent")) />
		<cfset setUnprotectedEvents(unprotectedEvents) />

		<!--- Setup the login IPs --->
		<cfif IsSimpleValue(loginIps)>
			<cfset loginIPs = ListToArray(loginIPs) />
		</cfif>
		<cfset setLoginIPs(loginIPs) />

		<cfif ArrayLen(loginIPs)>
			<cfset setLoginIPsEnabled(true) />
		</cfif>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - PLUGIN POINTS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="PreProcess plugin point that checks if the user is logged in.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var event = arguments.eventContext.getNextEvent() />
		<cfset var requestEventName = event.getRequestName() />
		<cfset var message = "" />
		<cfset var httpRequestData = "" />

		<cfif event.isArgDefined("logout")>
			<cfset setLoggedIn(false) />
			<cfset message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
			<cfset message.setMessage("You have been logged out.") />
		</cfif>
		
		<!--- Check to see if CF Builder passed a call back url in the url --->
		<cfif event.isArgDefined("callbackurl")>
			<cfset getProperty("application").setSessionItem("callbackUrl", event.getArg("callbackurl")) />
		</cfif>

		<!--- Check if this event even exists --->
		<cfif NOT getAppManager().getEventManager().isEventDefined(requestEventName)>
			<cfset redirectEvent("info.index") />
		</cfif>

		<!--- Check if login is restricted by IP --->
		<cfif getLoginIPsEnabled() AND NOT isLoginIP() AND isProtectedEvent(requestEventName)>
			<cfset arguments.eventContext.clearEventQueue() />
			<cfset announceEvent("sys.loginRestricted", event.getArgs()) />
		<!--- Check login --->
		<cfelseif getProperty("enableLogin") AND NOT isLoggedIn()>
			<cfif isProtectedEvent(requestEventName)>
				<cfset message = CreateObject("component", "MachII.dashboard.model.sys.Message").init() />
				<cfset message.setType("exception") />

				<cfif event.isArgDefined("password")>
					<cfif event.getArg("password") EQ getProperty("password")>
						<cfset setLoggedIn(true) />
						<cfset redirectEvent(requestEventName) />
					<cfelse>
						<cfset message.setMessage("Incorrect password. Please try again.") />
						<cfset event.setArg("message", message) />
						<cfset arguments.eventContext.clearEventQueue() />
						<cfset announceEvent("sys.login", event.getArgs()) />
					</cfif>
				<cfelse>
					<cfset arguments.eventContext.clearEventQueue() />

					<cfset httpRequestData = GetHttpRequestData() />

					<!--- Check to see if this is an AJAX request --->
					<cfif StructKeyExists(httpRequestData.headers, "X-Prototype-Version")>
						<cfset addHTTPHeaderByStatus(403) />
						<cfabort>
					<cfelse>
						<cfset message.setType("info") />
						<cfset message.setMessage("You must login before you can gain access to this feature.") />
						<cfset event.setArg("message", message) />
						<cfset announceEvent("sys.login", event.getArgs()) />
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="preEvent" access="public" returntype="void" output="false"
		hint="PreEvent plugin point that disables debugging output amount things.">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var event = arguments.eventContext.getCurrentEvent() />

		<cfset event.setArg("suppressDebug", true) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="isLoggedIn" access="private" returntype="boolean" output="false"
		hint="Checks if the user is logged in.">
			
		<cfset var sessionFacade = getProperty("application")>

		<cfif NOT sessionFacade.isSessionItemDefined("loginStatus")>
			<cfset sessionFacade.setSessionItem("loginStatus", false) />
		</cfif>

		<cfreturn sessionFacade.getSessionItem("loginStatus") />
	</cffunction>

	<cffunction name="setLoggedIn" access="private" returntype="void" output="false"
		hint="Checks if the user is logged in.">
		<cfargument name="loggedIn" type="boolean" required="true" />

		<cfset var sessionFacade = getProperty("application")>

		<cfset sessionFacade.setSessionItem("loginStatus", arguments.loggedIn) />
	</cffunction>

	<cffunction name="isProtectedEvent" access="private" returntype="boolean" output="false"
		hint="Checks if the passed event is protected and requires login.">
		<cfargument name="requestEventName" type="string" required="true" />

		<cfset var unprotectedEvents = getUnprotectedEvents() />
		<cfset var i = "" />
		<cfset var result = true />

		<cfloop from="1" to="#ArrayLen(unprotectedEvents)#" index="i">
			<cfif arguments.requestEventName EQ unprotectedEvents[i]>
				<cfset result = false />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn result />
	</cffunction>

	<cffunction name="isLoginIP" access="private" returntype="boolean" output="false"
		hint="Returns true if the current cgi.remote_addr exists within the provided list.">

		<cfset var loginIPs = getLoginIPs() />
		<cfset var i = 0 />

		<!--- Loop through the provided login IPs to see if they equate the cgi.remote_addr value --->
		<cfloop from="1" to="#ArrayLen(loginIPs)#" index="i">
			<cfif getProperty("udfs").isIPInRange(cgi.remote_addr, loginIPs[i])>
				<!--- Found the IP --->
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setUnprotectedEvents" access="private" returntype="void" output="false">
		<cfargument name="unprotectedEvents" type="array" required="true" />
		<cfset variables.unprotectedEvents = arguments.unprotectedEvents />
	</cffunction>
	<cffunction name="getUnprotectedEvents" access="private" returntype="array" output="false">
		<cfreturn variables.unprotectedEvents />
	</cffunction>

	<cffunction name="setLoginIPsEnabled" access="private" returntype="void" output="false">
		<cfargument name="loginIPsEnabled" type="boolean" required="true" />
		<cfset variables.loginIPsEnabled = arguments.loginIPsEnabled />
	</cffunction>
	<cffunction name="getLoginIPsEnabled" access="private" returntype="boolean" output="false">
		<cfreturn variables.loginIPsEnabled />
	</cffunction>

	<cffunction name="setLoginIPs" access="private" returntype="void" output="false">
		<cfargument name="loginIPs" type="array" required="true" />
		<cfset variables.loginIPs = arguments.loginIPs />
	</cffunction>
	<cffunction name="getLoginIPs" access="private" returntype="array" output="false">
		<cfreturn variables.loginIPs />
	</cffunction>

</cfcomponent>