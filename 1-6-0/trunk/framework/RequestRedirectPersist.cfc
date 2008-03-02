<!---
License:
Copyright 2008 GreatBizTools, LLC

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
--->
<cfcomponent
	displayname="RequestRedirectPersist"
	output="false"
	hint="Implements persisting data between redirects.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.redirectPersistParameter = "" />
	<cfset variables.redirectPersistScope = "" />
	<cfset variables.cleanupDifference = -3 />
	<cfset variables.threadingAdapter = "" />
	<cfset variables.log = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestRedirectPersist" output="false"
		hint="Initializes the redirect persist machinery.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<cfset setRedirectPersistParameter(getAppManager().getPropertyManager().getProperty("redirectPersistParameter")) />
		<cfset setRedirectPersistScope(getAppManager().getPropertyManager().getProperty("redirectPersistScope")) />
		<cfset setThreadingAdapter(getAppManager().getUtils().createThreadingAdapter()) />

		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="read" access="public" returntype="struct" output="false"
		hint="Gets a persisted event by id if found in event args.">
		<cfargument name="eventArgs" type="struct" required="true" />
		
		<cfset var persistId = "" />
		<cfset var persistedData = StructNew() />
		<cfset var dataStorage = "" />
		<cfset var key = "" />
		<cfset var log = getLog() />
		
		<!--- Check they have a persistId in the event --->
		<cfif StructKeyExists(arguments.eventArgs, getRedirectPersistParameter())>
			<cfset persistId = arguments.eventArgs[getRedirectPersistParameter()] />
			<cfset dataStorage = getStorage() />
			
			<!--- Get the data and cleanup --->
			<cfif StructKeyExists(dataStorage.data, persistId)>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Found redirect persist event data under persist id '#persistId#'.") />
				</cfif>
				
				<cftry>
					<!--- Get the data and delete it from the dataStorage --->
					<cfset persistedData = dataStorage.data[persistId]>
					<cfset StructDelete(dataStorage.data, persistId, false) />
					<cfset key = StructFindValue(dataStorage.timestamps, persistId, "one") />
					<cfset StructDelete(dataStorage.timestamps, key[1].key, false) />
					<cfcatch type="any">
						<!--- Ingore this error --->
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		
		<cfreturn persistedData />
	</cffunction>
	
	<cffunction name="save" access="public" returntype="string" output="false"
		hint="Saves persisted event data and returns the persistId.">
		<cfargument name="data" type="struct" required="true" />
		
		<cfset var persistId = createPersistId() />
		<cfset var dataStorage = getStorage() />
		<cfset var log = getLog() />
		
		<!--- Do cleanup --->
		<cfset shouldCleanup() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Saving redirect persist event data under persist id '#persistId#'.") />
		</cfif>
		
		<!--- Save the data/timestamp --->
		<cfset dataStorage.data[persistId] = arguments.data />
		<cfset dataStorage.timestamps[createTimestamp() & "_" & persistId] = persistId />
		
		<cfreturn persistId />
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false"
		hint="Reaps the storage of old redirect persists.">
		
		<cfset var diffTimestamp = createTimestamp(DateAdd("n", variables.cleanupDifference, now())) />
		<cfset var dataStorage = getPersistEventStorage() />
		<cfset var dataTimestampArray = "" />
		<cfset var key = "" />
		<cfset var i = "" />
		<cfset var log = getLog() />
		
		<cflock name="_MachIIRequestRedirectPersistCleanup" type="exclusive" timeout="5" throwontimeout="false">
			
			<cfif log.isTraceEnabled()>
				<cfset log.trace("Reaping old redirect persists.") />
			</cfif>
			
			<!--- Reset the timestamp of the last cleanup --->
			<cfset dataStorage.lastCleanup = createTimestamp() />
				
			<!--- Get array of timestamps and sort --->
			<cfset dataTimestampArray = StructKeyArray(dataStorage.timestamps) />
			<cfset ArraySort(dataTimestampArray, "textnocase", "asc") />
			
			<!--- Cleanup --->
			<cfloop from="1" to="#ArrayLen(dataTimestampArray)#" index="i">
				<cftry>
					<cfif (diffTimestamp - ListFirst(dataTimestampArray[i], "_")) GTE 0>
						<!--- The order of the deletes is important as the timestamp may be
							around, but the data already deleted --->
						<cfset key = dataTimestampArray[i] />
						<cfset StructDelete(dataStorage.timestamps, key, false) />
						<cfset StructDelete(dataStorage.data, ListLast(key, "_"), false) />
					<cfelse>
						<cfbreak />
					</cfif>
					<cfcatch type="any">
						<!--- Ingore this error --->
					</cfcatch>
				</cftry>
			</cfloop>
		</cflock>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getStorage" access="private" returntype="struct" output="false"
		hint="Helper function to get the event data store for persists.">
		
		<cfset var scope = "" />
		
		<!--- Select the right scope --->
		<cfif getRedirectPersistScope() EQ "application">
			<cfset scope = StructGet("application") />
		<cfelseif  getRedirectPersistScope() EQ "session">
			<cfset scope = StructGet("session") />
		<cfelseif getRedirectPersistScope() EQ "server">
			<cfset scope = StructGet("server") />
		<cfelse>
			<cfthrow type="MachII.framework.RequestRedirectPersist.UnsupportedRedirectPersistScope"
				message="You can only use session, application or server scopes." />
		</cfif>
		
		<!--- Double check lock if default structure is not defined --->
		<cfif NOT StructKeyExists(scope, "_MachIIRequestRedirectPersistStorage")>
			<cflock name="_MachIIRequestRedirectPersistCreate" type="exclusive" timeout="5" throwontimeout="false">
				<cfif NOT StructKeyExists(scope, "_MachIIRequestRedirectPersistStorage")>
					<cfset scope._MachIIRequestRedirectPersistStorage = StructNew() />
					<cfset scope._MachIIRequestRedirectPersistStorage.data = StructNew() />
					<cfset scope._MachIIRequestRedirectPersistStorage.timestamps = StructNew() />
					<cfset scope._MachIIRequestRedirectPersistStorage.lastCleanup = createTimestamp() />
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn scope._MachIIRequestRedirectPersistStorage />		
	</cffunction>
	
	<cffunction name="shouldCleanup" access="private" returntype="void" output="false"
		hint="Cleanups the data storage.">
		
		<cfset var diffTimestamp = createTimestamp(DateAdd("n", variables.cleanupDifference, now())) />
		<cfset var dataStorage = getStorage() />
		<cfset var threadingAdapter = "" />
		
		<cfif (diffTimestamp - dataStorage.lastCleanup) GTE 0>
		
			<cfset threadingAdapter = getThreadingAdapter() />
			
			<cflock name="_MachIIRequestRedirectPersistCleanup" type="exclusive" timeout="5" throwontimeout="false">
				<cfif (diffTimestamp - dataStorage.lastCleanup) GTE 0>
					<cfif threadingAdapter.allowThreading()>
						<cfset threadingAdapter.run(this, "reap") />
					<cfelse>
						<cfset reap() />
					</cfif>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>
	
	<cffunction name="createPersistId" access="private" returntype="string" output="false"
		hint="Creates a persistId for use.">
		<cfreturn REReplace(CreateUUID(), "[[:punct:]]", "", "ALL") />
	</cffunction>
	
	<cffunction name="createTimestamp" access="private" returntype="string" output="false"
		hint="Creates a timestamp for use.">
		<cfargument name="time" type="date" required="false" default="#Now()#" />
		<cfreturn REReplace(arguments.time, "[ts[:punct:][:space:]]", "", "ALL") />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="private" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setRedirectPersistParameter" access="private" returntype="void" output="false">
		<cfargument name="redirectPersistParameter" type="string" required="true" />
		<cfset variables.redirectPersistParameter = arguments.redirectPersistParameter />
	</cffunction>
	<cffunction name="getRedirectPersistParameter" access="private" returntype="string" output="false">
		<cfreturn variables.redirectPersistParameter />
	</cffunction>

	<cffunction name="setRedirectPersistScope" access="private" returntype="void" output="false">
		<cfargument name="redirectPersistScope" type="string" required="true" />
		<cfset variables.redirectPersistScope = arguments.redirectPersistScope />
	</cffunction>
	<cffunction name="getRedirectPersistScope" access="private" returntype="string" output="false">
		<cfreturn variables.redirectPersistScope />
	</cffunction>

	<cffunction name="setThreadingAdapter" access="private" returntype="void" output="false">
		<cfargument name="threadingAdapter" type="MachII.util.threading.ThreadingAdapter" required="true" />
		<cfset variables.threadingAdapter = arguments.threadingAdapter />
	</cffunction>
	<cffunction name="getThreadingAdapter" access="private" returntype="MachII.util.threading.ThreadingAdapter" output="false">
		<cfreturn variables.threadingAdapter />
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