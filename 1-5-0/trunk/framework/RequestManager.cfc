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
	<cfset variables.requestHandler = "" />
	<cfset variables.redirectPersistParameter = "" />
	<cfset variables.redirectPersistScope = "" />
	<cfset variables.defaultUrlBase = "" />
	<cfset variables.eventParameter = "" />
	<cfset variables.parseSes = "" />
	<cfset variables.queryStringDelimiter = "" />
	<cfset variables.seriesDelimiter ="" />
	<cfset variables.pairDelimiter = "" />
	<cfset varibales.moduleDelimiter = "" />
	<cfset variables.cleanupDifference = -3 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="RequestManager" output="false"
		hint="Initializes the manager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset var urlDelimiters = "" />	
		
		<cfset setAppManager(arguments.appManager) />

		<!--- Setup defaults --->
		<cfset urlDelimiters = getPropertyManager().getProperty("urlDelimiters") />	
		<cfset setRedirectPersistParameter(getPropertyManager().getProperty("redirectPersistParameter")) />
		<cfset setRedirectPersistScope(getPropertyManager().getProperty("redirectPersistScope")) />
		<cfset setDefaultUrlBase(getPropertyManager().getProperty("urlBase")) />
		<cfset setEventParameter(getPropertyManager().getProperty("eventParameter")) />
		<cfset setParseSES(getPropertyManager().getProperty("urlParseSES")) />
		<cfset setModuleDelimiter(getPropertyManager().getProperty("moduleDelimiter")) />
		
		<!--- Parse through the complex list of delimiters --->
		<cfset setQueryStringDelimiter(ListGetAt(urlDelimiters, 1)) />
		<cfset setSeriesDelimiter(ListGetAt(urlDelimiters, 2)) />
		<cfset setPairDelimiter(ListGetAt(urlDelimiters, 3)) />

		<cfset variables.requestHandler = createRequestHandler(getModuleDelimiter()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures nothing.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getRequestHandler" access="public" returntype="MachII.framework.RequestHandler" output="false"
		hint="Returns a new or cached instance of a RequestHandler.">
		<cfargument name="createNew" type="boolean" required="false" default="false"
			hint="Pass true to return a new instance of a RequestHandler." />
		
		<cfif arguments.createNew>
			<cfreturn createRequestHandler() />
		<cfelse>
			<cfreturn variables.requestHandler />
		</cfif>
	</cffunction>
	
	<cffunction name="buildUrl" access="public" returntype="string" output="false"
		hint="Builds a framework specific url.">
		<cfargument name="moduleName" type="string" required="true"
			hint="Name of the module to build the url with." />
		<cfargument name="eventName" type="string" required="true"
			hint="Name of the event to build the url with." />
		<cfargument name="urlParameters" type="any" required="false" default=""
			hint="Name/value pairs (urlArg1=value1|urlArg2=value2) to build the url with or a struct of data." />
		<cfargument name="urlBase" type="string" required="false" default=""
			hint="Base of the url. Defaults to index.cfm." />
		
		<cfset var url = "" />
		<cfset var params = parseBuildUrlParameters(arguments.urlParameters) />
		<cfset var module = "" />
		<cfset var i = "" />
		
		<!--- Append the base url --->
		<cfif NOT Len(arguments.urlBase)>
			<cfset url = getDefaultUrlBase() />
		<cfelse>
			<cfset url = arguments.urlBase />
		</cfif>

		<!--- Attach the event name if defined --->
		<cfif Len(arguments.eventName)>
			<cfif Len(arguments.moduleName)>
				<cfset module = arguments.moduleName & getModuleDelimiter() />
			</cfif>
			<cfset url = url & getQueryStringDelimiter() & getEventParameter() & getPairDelimiter() & module & arguments.eventName />
		</cfif>
		
		<!--- Attach each additional arguments if it exists and is a simple value --->
		<cfloop collection="#params#" item="i">
			<cfif IsSimpleValue(params[i])>
				<cfset url = url & getSeriesDelimiter() & i & getPairDelimiter() & URLEncodedFormat(params[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn url />
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
		<cfset var dataStorage = "" />
		
		<!--- Check they have a persistId in the event --->
		<cfif StructKeyExists(arguments.eventArgs, getRedirectPersistParameter())>
			<cfset persistId = arguments.eventArgs[getRedirectPersistParameter()] />
			<cfset dataStorage = getPersistEventStorage() />
			
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
		
		<!--- Do cleanup --->
		<cfset cleanupPersistEventStorage() />
		
		<!--- Save the data/timestamp --->
		<cfset dataStorage.data[persistId] = arguments.eventArgs />
		<cfset dataStorage.timestamps[timestamp] = persistId />
		
		<cfreturn persistId />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createRequestHandler" access="private" returntype="MachII.framework.RequestHandler" output="false"
		hint="Creates a RequestHandler instance.">
		<cfreturn CreateObject("component", "MachII.framework.RequestHandler").init(getAppManager(), getModuleDelimiter()) />
	</cffunction>
	
	<cffunction name="parseBuildUrlParameters" access="private" returntype="struct" output="false"
		hint="Parses the build url parameters into a useable form.">
		<cfargument name="urlParameters" type="any" required="true"
			hint="Takes string of name/value pairs or a struct.">
		
		<cfset var params = StructNew() />
		<cfset var temp = "" />
		<cfset var i = "" />
		
		<cfif NOT IsStruct(arguments.urlParameters)>
			<cfloop list="#arguments.urlParameters#" index="i" delimiters="|">
				<cfif ListLen(i) EQ 1>
					<cfset temp = ListLast(i, "=") />
				<cfelse>
					<cfset temp = "" />
				</cfif>
				<cfset params[ListFirst(i, "=")] = temp />
			</cfloop>
		<cfelse>
			<cfset params = arguments.urlParameters />
		</cfif>
		
		<cfreturn params />
	</cffunction>
	
	<cffunction name="getPersistEventStorage" access="private" returntype="struct" output="false"
		hint="Helper function to get the event data store for persists.">
		
		<cfset var scope = "" />
		
		<!--- Select the right scope --->
		<cfif getRedirectPersistScope() EQ "session">
			<cfset scope = StructGet("session") />
		<cfelseif  getRedirectPersistScope() EQ "application">
			<cfset scope = StructGet("application") />
		<cfelseif getRedirectPersistScope() EQ "server">
			<cfset scope = StructGet("server") />
		<cfelse>
			<cfthrow type="MachII.framework.UnsupportedRedirectPersistScope"
				message="You can only use session, application or server scopes." />
		</cfif>
		
		<!--- Double check lock if default structure is not defined --->
		<cfif NOT StructKeyExists(scope, "_MachIIPersistEventStorage")>
			<cflock name="_MachIIPersistEventStorageCreate" type="exclusive" timeout="5" throwontimeout="false">
				<cfif NOT StructKeyExists(scope, "_MachIIPersistEventStorage")>
					<cfset scope._MachIIPersistEventStorage = StructNew() />
					<cfset scope._MachIIPersistEventStorage.data = StructNew() />
					<cfset scope._MachIIPersistEventStorage.timestamps = StructNew() />
					<cfset scope._MachIIPersistEventStorage.lastCleanup = createTimestamp() />
				</cfif>
			</cflock>
		</cfif>
		
		<cfreturn scope._MachIIPersistEventStorage />		
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
			<cflock name="_MachIIPersistEventStorageCleanup" type="exclusive" timeout="5" throwontimeout="false">
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

	<cffunction name="setRedirectPersistScope" access="private" returntype="void" output="false">
		<cfargument name="redirectPersistScope" type="string" required="true" />
		<cfset variables.redirectPersistScope = arguments.redirectPersistScope />
	</cffunction>
	<cffunction name="getRedirectPersistScope" access="private" returntype="string" output="false">
		<cfreturn variables.redirectPersistScope />
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
	
	<cffunction name="setModuleDelimiter" access="private" returntype="void" output="false">
		<cfargument name="moduleDelimiter" type="string" required="true" />
		<cfset variables.moduleDelimiter = arguments.moduleDelimiter />
	</cffunction>
	<cffunction name="getModuleDelimiter" access="private" returntype="string" output="false">
		<cfreturn variables.moduleDelimiter />
	</cffunction>

</cfcomponent>