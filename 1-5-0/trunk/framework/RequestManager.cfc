<!---
License:
Copyright 2007 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0

Notes:
--->
<cfcomponent 
	displayname="RequestManager"
	output="false"
	hint="Manages request functionality for the framework.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.redirectPersistParameter = "" />
	<cfset variables.defaultUrlBase = "" />
	<cfset variables.eventParameter = "" />
	<cfset variables.parseSes = "" />
	<cfset variables.queryStringDelimiter = "" />
	<cfset variables.seriesDelimiter ="" />
	<cfset variables.pairDelimiter = "" />
	<cfset variables.cleanupDifference = -3 />

	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures nothing.">
		
		<cfset var urlDelimiters = getPropertyManager().getProperty("urlDelimiters") />	
			
		<!--- Setup defaults --->
		<cfset setRedirectPersistParameter(getPropertyManager().getProperty("redirectPersistParameter")) />
		<cfset setDefaultUrlBase(getPropertyManager().getProperty("urlBase")) />
		<cfset setEventParameter(getPropertyManager().getProperty("eventParameter")) />
		<cfset setParseSES(getPropertyManager().getProperty("urlParseSES")) />
		
		<!--- Parse through the complex --->
		<cfset setQueryStringDelimiter(ListGetAt(urlDelimiters, 1)) />
		<cfset setSeriesDelimiter(ListGetAt(urlDelimiters, 2)) />
		<cfset setPairDelimiter(ListGetAt(urlDelimiters, 3)) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1,urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to index.cfm." />
		
		<cfset var builtUrl = "" />
		<cfset var params = parseBuildUrlParameters(arguments.urlParameters) />
		<cfset var i = "" />
		
		<!--- Append the base url --->
		<cfif NOT Len(arguments.urlBase)>
			<cfset builtUrl = getDefaultUrlBase() />
		<cfelse>
			<cfset builtUrl = arguments.urlBase />
		</cfif>

		<!--- Attach the event name if defined --->
		<cfif Len(arguments.eventName)>
			<cfset builtUrl = builtUrl & getQueryStringDelimiter() & getEventParameter() & getPairDelimiter() & arguments.eventName />
		</cfif>
		
		<!--- Attach each additional arguments if it exists and is a simple value --->
		<cfloop collection="#params#" item="i">
			<cfif IsSimpleValue(params[i])>
				<cfset builtUrl = builtUrl & getSeriesDelimiter() & i & getPairDelimiter() & URLEncodedFormat(params[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn builtUrl />
	</cffunction>
	
	<cffunction name="parseSesParameters" access="public" returntype="struct" output="false"
		hint="Parse SES parameters.">
		<cfargument name="pathInfo" type="string" required="true" />
		
		<cfset var names = "" />
		<cfset var i = "" />
		<cfset var value = "" />
		<cfset var params = StructNew() />

		<!--- Parse SES if necessary --->
		<cfif getParseSes() AND Len(arguments.pathInfo)>
			<cfset arguments.pathInfo = Right(arguments.pathInfo, Len(arguments.pathInfo) -1) />
			
			<cfset names = ListToArray(arguments.pathInfo, getUrlSeriesDelimiter()) />
			
			<cfif getSeriesDelimiter() EQ getPairDelimiter()>
				<cfloop from="1" to="#ArrayLen(names)#" index="i" step="2">
					<cfset value = "" />
					<cfif i + 1 LT ArrayLen(names)>
						<cfset value = names[i+1] />
					</cfif>
					<cfset params[names[i]] = value />
				</cfloop>
			<cfelse>
				<cfloop from="1" to="#ArrayLen(names)#" index="i">
					<cfset value = "" />
					<cfif ArrayLen(names[i]) EQ 2>
						<cfset value = ListGetAt(names[i], 2, getPairDelimiter()) />
					</cfif>
					<cfset params[ListGetAt(names[i], 1, getPairDelimiter())] =  value />
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn params />
	</cffunction>

	<cffunction name="readPersistEventData" access="public" returntype="struct" output="false"
		hint="Gets a persisted event by id if found in event args.">
		<cfargument name="eventArgs" type="struct" required="true" />
		
		<cfset var persistId = "" />
		<cfset var persistedData = StructNew() />
		<cfset var dataStorage = getPersistEventStorage() />
		
		<!--- Check they have a persistId in the event --->
		<cfif StructKeyExists(arguments.eventArgs, getRedirectPersistParameter())>
			<cfset persistId = arguments.eventArgs[getRedirectPersistParameter()] />
			
			<!--- Get the data and cleanup --->
			<cfif StructKeyExists(dataStorage.data, persistId)>
				<cftry>
					<!--- Get the data and delete it from the dataStorage --->
					<cfset persistedData = dataStorage.data[persistId]>
					<cfset StructDelete(dataStorage.data, persistId, false) />
					<cfcatch type="any">
						<!--- Ingore this error --->
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		
		<cfreturn persistedData />
	</cffunction>
	
	<cffunction name="savePersistEventData" access="public" returntype="string" output="false"
		hint="Saves persisted event data and returns the persistId.">
		<cfargument name="eventArgs" type="struct" required="true" />
		
		<cfset var persistId = createPersistId() />
		<cfset var timestamp = createTimestamp() />
		<cfset var dataStorage = getPersistEventStorage() />
		
		<!--- Save the data/timestamp --->
		<cfset dataStorage.data[persistId] = arguments.eventArgs />
		<cfset dataStorage.timestamps[timestamp] = persistId />
		
		<!--- Do cleanup --->
		<cfset cleanupPersistEventStorage() />
		
		<cfreturn persistId />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="parseBuildUrlParameters" access="private" returntype="struct" output="false"
		hint="Parses the build url parameters into a useable form.">
		<cfargument name="urlParameters" type="any" required="true"
			hint="Takes string of name/value pairs or a struct.">
		
		<cfset var params = StructNew() />
		<cfset var i = "" />
		
		<cfif NOT IsStruct(arguments.urlParameters)>
			<cfloop list="#arguments.urlParameters#" index="i" delimiters=",">
				<cfset params[ListFirst(i, "=")] = ListLast(i, "=") />
			</cfloop>
		<cfelse>
			<cfset params = arguments.urlParameters />
		</cfif>
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="getPersistEventStorage" access="private" returntype="struct" output="false"
		hint="Helper function to get the event data store for persists.">

		<!--- Double check lock if default structure is not defined --->
		<cfif NOT StructKeyExists(session, "_MachIIPersistEventStorage")>
			<cflock name="_MachIIPersistEventStorageCreate" type="exclusive" timeout="5" throwontimeout="false">
				<cfif NOT StructKeyExists(session, "_MachIIPersistEventStorage")>
					<cfset session._MachIIPersistEventStorage = StructNew() />
					<cfset session._MachIIPersistEventStorage.data = StructNew() />
					<cfset session._MachIIPersistEventStorage.timestamps = StructNew() />
					<cfset session._MachIIPersistEventStorage.lastCleanup = createTimestamp() />
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn session._MachIIPersistEventStorage />		
	</cffunction>
	
	<cffunction name="cleanupPersistEventStorage" access="private" returntype="void" output="false"
		hint="Cleanups the persist event data storage.">
		
		<cfset var timestamp = createTimestamp() />
		<cfset var diffTimestamp = DateAdd("n", variables.cleanupDifference, timestamp) />
		<cfset var dataStorage = getPersistEventStorage() />
		<cfset var dataTimestampArray = "" />
		<cfset var i = "" />
		
		<!--- Do cleanup --->
		<cfif DateCompare(dataStorage.lastCleanup, diffTimestamp) EQ 1>
			<cflock name="_MachIIPersistEventStorageCreateCleanup" type="exclusive" timeout="5" throwontimeout="false">
				<cfif DateCompare(dataStorage.lastCleanup, diffTimestamp) EQ 1>
					<cfset dataStorage.lastCleanup = timestamp />
					
					<!--- Get array of timestamps and sort --->
					<cfset dataTimestampArray = StructKeyArray(dataStorage.timestamps) />
					<cfset ArraySort(dataTimestampArray, "numeric", "asc") />
					
					<!--- Cleanup --->
					<cfloop from="1" to="#ArrayLen(dataTimestampArray)#" index="i">
						<cftry>
							<cfif DateCompare(dataTimestampArray[i], diffTimestamp) EQ 1>
								<cfset StructDelete(dataStorage.data, dataStorage.timestamps[dataTimestampArray[i]], false) />
								<cfset StructDelete(dataStorage.timestamps, dataTimestampArray[i], false) />
							<cfelse>
								<cfbreak />
							</cfif>
							<cfcatch type="any">
								<!--- Ingore this error --->
							</cfcatch>
						</cftry>
					</cfloop>
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
		<cfreturn REReplace(Now(), "[ts[:punct:][:space:]]", "", "ALL") />
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
	
	<cffunction name="getPropertyManager" access="private" returntype="MachII.framework.PropertyManager" output="false">
		<cfreturn getAppManager().getPropertyManager() />
	</cffunction>
	
	<cffunction name="setRedirectPersistParameter" access="private" returntype="void" output="false">
		<cfargument name="redirectPersistParameter" type="string" required="true" />
		<cfset variables.redirectPersistParameter = arguments.redirectPersistParameter />
	</cffunction>
	<cffunction name="getRedirectPersistParameter" access="private" returntype="string" output="false">
		<cfreturn variables.redirectPersistParameter />
	</cffunction>
	
	<cffunction name="setEventParameter" access="private" returntype="void" output="false">
		<cfargument name="eventParameter" type="string" required="true" />
		<cfset variables.eventParameter = arguments.eventParameter />
	</cffunction>
	<cffunction name="getEventParameter" access="private" returntype="string" output="false">
		<cfreturn variables.eventParameter />
	</cffunction>
	
	<cffunction name="setParseSes" access="private" returntype="void" output="false">
		<cfargument name="parseSes" type="string" required="true" />
		<cfset variables.parseSes = arguments.parseSes />
	</cffunction>
	<cffunction name="getParseSes" access="private" returntype="string" output="false">
		<cfreturn variables.parseSes />
	</cffunction>
	
	<cffunction name="setDefaultUrlBase" access="private" returntype="void" output="false">
		<cfargument name="defaultUrlBase" type="string" required="true" />
		<cfset variables.defaultUrlBase = arguments.defaultUrlBase />
	</cffunction>
	<cffunction name="getDefaultUrlBase" access="private" returntype="string" output="false">
		<cfreturn variables.defaultUrlBase />
	</cffunction>
	
	<cffunction name="setQueryStringDelimiter" access="private" returntype="void" output="false">
		<cfargument name="queryStringDelimiter" type="string" required="true" />
		<cfset variables.queryStringDelimiter = arguments.queryStringDelimiter />
	</cffunction>
	<cffunction name="getQueryStringDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.queryStringDelimiter />
	</cffunction>

	<cffunction name="setSeriesDelimiter" access="private" returntype="void" output="false">
		<cfargument name="seriesDelimiter" type="string" required="true" />
		<cfset variables.seriesDelimiter = arguments.seriesDelimiter />
	</cffunction>
	<cffunction name="getSeriesDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.seriesDelimiter />
	</cffunction>
	
	<cffunction name="setPairDelimiter" access="private" returntype="void" output="false">
		<cfargument name="pairDelimiter" type="string" required="true" />
		<cfset variables.pairDelimiter = arguments.pairDelimiter />
	</cffunction>
	<cffunction name="getPairDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.pairDelimiter />
	</cffunction>

</cfcomponent>