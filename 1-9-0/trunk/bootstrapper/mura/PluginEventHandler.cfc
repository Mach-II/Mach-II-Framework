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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
This file provides the 'plugin' for the open source Mura CMS (http://getmura.com/).
--->
<cfcomponent
	displayname="MuraPluginEventHandler"
	extends="mura.plugin.pluginGenericEventHandler"
	output="false"
	hint="This CFC represents the events that integrate Mach-II as a plugin into Mura.">

	<!---
	PROPERTIES
	--->
	<!---
	Inherited variables from the super class:
	 * variables.pluginConfig
	 * variables.configBean
	--->

	<cfset variables.eventParameter = "" />
	<cfset variables.moduleDelimiter = "" />

	<!--- Disable resetting the response buffer at the beginning of the request --->
	<cfset MACHII_ONREQUESTSTART_CONTENT_RESET = false />

	<cfinclude template="/MachII/bootstrapper/common.cfm" />

	<!---
	INITIALIZATION / CONFIGRUATION
	--->
	<!--- init() in the super class --->

	<!---
	PUBLIC FUNCTIONS - MURA SPECIFIC EVENTS
	--->
	<cffunction name="onApplicationLoad" access="public" returntype="void" output="false"
		hint="Loads the Mach-II application when Mura loads up.">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<!--- Set the bootstrapper settings --->


		<!--- Load the Mach-II application up --->
		<cfset loadFramework() />

		<!--- Get framework specific settings --->
		<cfset variables.eventParameter = getProperty("eventParameter") />
		<cfset variables.moduleDelimiter = getProperty("moduleDelimiter") />

		<!--- Add this event handler to this Mura instance --->
		<cfset variables.pluginConfig.addEventHandler(this) />
	</cffunction>

	<!---
	An onApplicationUnload() method is not currently supported in Mura, but has been requested:
	http://www.getmura.com/forum/messages.cfm?threadid=292D1591-93B5-47BD-A5905DCF36625EC0

	<cffunction name="onApplicationUnload" access="public" returntype="void" output="false"
		hint="Unloads the Mach-II application when Mura unloads.">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<!--- Access to the application and session scopes are in the Mura scope in so you cannot use 'getAppManager()' --->
		<cfset var applicationScope = arguments.$.getValue("applicationScope") />

		<cfset applicationScope[getAppKey()].appLoader.getAppManager().onApplicationEnd() />
	</cffunction>
	--->

	<cffunction name="onSiteRequestStart" access="public" returntype="void" output="false"
		hint="Sets a reference to this Mach-II application into the Mura scope for use. Such as $.{muraScopeNamespace}.methodName(argumentCollection=args)">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<cfset arguments.$[variables.pluginConfig.getSetting("muraScopeNamespace")] = this />
	</cffunction>

	<cffunction name="onRenderStart" access="public" returntype="void" output="false"
		hint="Sets a reference to this Mach-II application into the Mura scope for use. Such as $.{muraScopeNamespace}.methodName(argumentCollection=args)">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<cfset arguments.$[variables.pluginConfig.getSetting("muraScopeNamespace")] = this />
	</cffunction>

	<cffunction name="onGlobalSessionStart" access="public" returntype="void" output="false"
		hint="Calls the onSessionStart Mach-II plugin points when a Mura session starts.">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<cfset ensureLoadedFramework() />
		<cfset getAppManager().onSessionStart() />
	</cffunction>

	<cffunction name="onGlobalSessionEnd" access="public" returntype="void" output="false"
		hint="Calls the onSessionEnd Mach-II plugin points when a Mura session starts.">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />

		<!--- Access to the application and session scopes are in the Mura scope in so you cannot use 'getAppManager()' --->
		<cfset var applicationScope = arguments.$.getValue("applicationScope") />

		<cfset applicationScope[getAppKey()].appLoader.getAppManager().onSessionEnd(arguments.$.getValue("sessionScope")) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - MACH-II INTEGRATION
	--->
	<cffunction name="handleRequest" access="public" returntype="string" output="false"
		hint="Handles a request to the Mach-II application.">
		<cfargument name="$" type="any" required="true"
			hint="Contains the Mura event." />
		<cfargument name="moduleName" type="string" required="true"
			hint="The name of the Mach-II module. Use '' for base module." />
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the Mach-II event." />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="Additional event-args to append to standard event-args that is build by this plugin." />

		<cfset var result = "" />
		<cfset var args = StructNew() />

		<!--- Build up initial Mach-II event args --->
		<cfset args["mura"] = arguments.$ />
		<cfset args["$"] = arguments.$ />
		<cfset StructAppend(args, arguments.$.event.getValues()) />
		<cfset StructAppend(args, arguments.eventArgs) />

		<!--- Set the event / module to the event args --->
		<cfif Len(arguments.moduleName)>
			<cfset args[variables.eventParameter] = arguments.moduleName & variables.moduleDelimiter & arguments.eventName  />
		<cfelse>
			<cfset args[variables.eventParameter] = arguments.eventName />
		</cfif>

		<!--- Run the Mach-II request and save the output for Mura --->
		<cfsavecontent variable="result"><cfset handleRequest(args) /></cfsavecontent>

		<cfreturn result />
	</cffunction>

</cfcomponent>