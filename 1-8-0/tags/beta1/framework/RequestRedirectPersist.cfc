<!---
License:
Copyright 2009 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
The RequestRedirectPersist abstracts the machinery behind the redirect persist
and provides an interface for other implementations.  This replaces the built-in
machinery for redirect persist in the RequestManager that was added in Mach-II
1.5.0.

Custom redirect persist machinery can be written and overrided by setting an
instantiated version to:

getAppManager().getRequestManager().setRequestRedirectPersist(obj)

This can be accomplished by using a Property.cfc to load in the custom 
machinery.
--->
<cfcomponent
	displayname="RequestRedirectPersist"
	output="false"
	hint="Implements persisting data between redirects.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.redirectPersistParameter = "persistId" />
	<cfset variables.timeSpanCache = "" />
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestRedirectPersist" output="false"
		hint="Initializes the redirect persist machinery.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset var parameters = StructNew() />

		<cfset setAppManager(arguments.appManager) />
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<!--- Setup "persistId" which is used as a cache key --->
		<cfset setRedirectPersistParameter(getAppManager().getPropertyManager().getProperty("redirectPersistParameter")) />
		
		<!--- Setup and configure a time span cache --->
		<cfset parameters.timespan = "0,0,3,0" />
		<cfset parameters.scope = getAppManager().getPropertyManager().getProperty("redirectPersistScope") />
		<cfset parameters.scopeKey = getAppManager().getAppKey() & "._MachIIRequestRedirectPersistStorage" />
		<cfset parameters.cleanupIntervalInMinutes = 1 />
		
		<cfset variables.timeSpanCache = CreateObject("component", "MachII.caching.strategies.TimeSpanCache").init(parameters) />
		
		<!--- The only exception we will usually see here is that the session scope is not enabled --->
		<cftry>
			<cfset variables.timeSpanCache.configure() />
			<cfcatch type="any">
				<cfif FindNoCase("session", cfcatch.message) OR FindNoCase("session", cfcatch.detail)>
					<cfthrow type="MachII.framework.RequestRedirectPersist.UnavailableScope"
						message="The redirect persist feature cannot access the session scope because it has not been enabled in your application."
						detail="The sesion scope is used by default, however it is configurable if you have disabled the session scope in your application. Add (or change if already defined) the 'redirectPersistScope' property to your XML configuration file with a value of 'application' or 'server.'" />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="read" access="public" returntype="struct" output="false"
		hint="Gets a persisted event by id if found in event args.">
		<cfargument name="eventArgs" type="struct" required="true"
			hint="The eventArgs struct is built before MachII.framework.Event is available." />
		
		<cfset var persistId = "" />
		<cfset var persistData = StructNew() />
		<cfset var key = "" />
		<cfset var log = getLog() />
		
		<!--- Check they have a persistId in the event --->
		<cfif StructKeyExists(arguments.eventArgs, getRedirectPersistParameter())>

			<cfset persistId = arguments.eventArgs[getRedirectPersistParameter()] />
			
			<!--- Get the data and cleanup --->
			<cfif variables.timeSpanCache.keyExists(persistId)>
				
				<cfset persistData = variables.timeSpanCache.get(persistId) />

				<!--- get() may return null which deleted the variable
					if for some reason the element is deleted between the 
					keyExists() and the get() --->
				<cfif NOT IsDefined("persistData")>
					<cfreturn StructNew() />
				</cfif>
				
				<cfset variables.timeSpanCache.remove(persistId) />
				
				<cfif log.isDebugEnabled()>
					<cfif StructKeyExists(persistData, "eventArgs")>
						<cfset log.debug("Found redirect persist event data under persist id '#persistId#'.", persistData.eventArgs) />
					<cfelse>
						<cfset log.debug("Found no redirect persist data.") />
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn persistData />
	</cffunction>
	
	<cffunction name="save" access="public" returntype="string" output="false"
		hint="Saves persisted event data and returns the persistId.">
		<cfargument name="data" type="struct" required="true" />
		
		<cfset var persistId = createPersistId() />
		<cfset var log = getLog() />
		
		<!--- Save the persist data --->		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Saving redirect persist event data under persist id '#persistId#'.") />
		</cfif>
		
		<cfset variables.timeSpanCache.put(persistId, arguments.data) />
		
		<cfreturn persistId />
	</cffunction>	
	
	<!---
	PROTECTED FUNCTIONS - UTIL
	--->
	<cffunction name="createPersistId" access="private" returntype="string" output="false"
		hint="Creates a persistId for use.">
		<cfreturn REReplace(CreateUUID(), "[[:punct:]]", "", "ALL") />
	</cffunction>
		
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setRedirectPersistParameter" access="private" returntype="void" output="false">
		<cfargument name="redirectPersistParameter" type="string" required="true" />
		<cfset variables.redirectPersistParameter = arguments.redirectPersistParameter />
	</cffunction>
	<cffunction name="getRedirectPersistParameter" access="public" returntype="string" output="false">
		<cfreturn variables.redirectPersistParameter />
	</cffunction>

	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>