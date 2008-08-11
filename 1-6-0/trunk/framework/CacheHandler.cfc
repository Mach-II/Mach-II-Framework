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
Author: Kurt Wiersma (kurt@mach-ii.com)
$Id: CacheHandler.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheHandler"
	output="false"
	hint="Holds configuration and cache data.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.commands = ArrayNew(1) />
	<cfset variables.handlerId = "" />
	<cfset variables.alias = ""/>
	<cfset variables.cacheName = "" />
	<cfset variables.criteria = "" />
	<cfset variables.parentHandlerName = "" />
	<cfset variables.parentHandlerType = "" />
	<cfset variables.cacheStrategy = 0 />
	<cfset variables.cacheOutputBuffer = "" />
	<cfset variables.log = 0 />
	<cfset variables.cachingEnabled = true />
	<cfset variables.aliasKeyLists = structNew() />
	<cfset variables.expressionEvaluator = 0 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheHandler" output="false"
		hint="Initializes the handler.">
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="cacheName" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var currentAlias = "" />
	
		<!--- Run setters --->
		<cfset setAlias(arguments.alias) />
		<cfset setCacheName(arguments.cacheName) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setParentHandlerName(arguments.parentHandlerName) />
		<cfset setParentHandlerType(arguments.parentHandlerType) />
		<cfif len(arguments.id)>
			<cfset setHandlerId(arguments.id) />
		<cfelse>
			<cfset setHandlerId(createHandlerId()) />
		</cfif>
		<cfset setExpressionEvaluator(CreateObject("component", "MachII.util.ExpressionEvaluator").init()) />
		
		<cfloop list="#arguments.alias#" index="currentAlias">
			<cfset variables.aliasKeyLists[hash(currentAlias)] = "" />
		</cfloop>
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="handleCache" access="public" returntype="boolean" output="true"
		hint="Handles a cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />

		<cfset var preCommandEventDataSnapshot = StructNew() />
		<cfset var dataToCache = StructNew() />
		<cfset var key = getKeyFromCriteria(arguments.event) />
		<cfset var dataFromCache = "" />
		<cfset var command = "" />
		<cfset var continue = true />
		<cfset var i = 0 />
		<cfset var log = getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Looking for data in the cache for key '#key#'") />
		</cfif>
		
		<cfset dataFromCache = getCacheStrategy().get(key) />
		
		<!--- Create the cache since we do not have one --->
		<cfif NOT IsDefined("dataFromCache") OR NOT getCacheStrategy().isCacheEnabled()>

			<!--- Get a snapshot of the event before we run the commands
				Used StructAppend so this is not updated by reference when the event is used in the commands --->
			<cfset StructAppend(preCommandEventDataSnapshot, arguments.event.getArgs()) />
		
			<!--- Run commands and save output --->
			<cfsavecontent variable="dataToCache.output">
				<cfloop from="1" to="#ArrayLen(variables.commands)#" index="i">
					<cfset command = variables.commands[i] />
					<cfset continue = command.execute(arguments.event, arguments.eventContext) />
					<cfif continue IS false>
						<cfbreak />
					</cfif>
				</cfloop>
			</cfsavecontent>
			
			<!--- Run only if caching is enabled --->
			<cfif getCacheStrategy().isCacheEnabled()>
				<!--- Compare pre-command event data snapshot to current event data  --->
				<cfset dataToCache.data = computeDataToCache(preCommandEventDataSnapshot, arguments.event.getArgs()) />

				<!--- Cache the data and output --->
				<cfset getCacheStrategy().put(key, dataToCache) />
				<cfset addKeyToAlias(key) />
				
				<!--- Log messages --->
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Creating cache with key '#key#'.") />
					<cfset log.debug("Set cache data with key names of '#StructKeyList(dataToCache.data)#'.") />
				</cfif>
			<cfelse>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Caching is curently disabled for this cache-handler.") />
				</cfif>
			</cfif>

			<!--- Output the saved output from the commands --->
			<cfoutput>#dataToCache.output#</cfoutput>
		<cfelse>
			<!--- Replay the data and output from the cache --->
			<cfoutput>#dataFromCache.output#</cfoutput>
			<cfset arguments.event.setArgs(dataFromCache.data) />
			
			<!--- Log messages --->
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Using data and output from cache with key '#key#'.") />
				<cfset log.debug("Using cache data with key names of '#StructKeyList(dataFromCache.data)#'.") />
			</cfif>
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<cffunction name="clearCache" access="public" returntype="void" output="false"
		hint="Clears the cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />

		<cfset var key = "" />
		<cfset var currentAlias = "" />
		<cfset var currentKey = "" />
		
		<cfif arguments.criteria neq "">
			<cfset key = getKeyFromCriteria(arguments.event, arguments.criteria) />
		<cfelse>
			<cfset key = getKey() />
		</cfif>
		
		<!--- If we don't get any criteria passed we want to clear the whole cache --->
		<cfif arguments.criteria neq "" or arguments.alias neq "">
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Cache-handler clearing data from cache using key '#key#', alias '#arguments.alias#'.") />
			</cfif>
			<cfif arguments.criteria neq "">
				<cfset getCacheStrategy().remove(key) />
			<cfelse>
				<cfloop list="#arguments.alias#" index="currentAlias">
					<cfloop list="#variables.aliasKeyLists[currentAlias]#" index="currentKey">
						<cfset getCacheStrategy().remove(currentKey) />
					</cfloop>
				</cfloop>
			</cfif>
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Cache-handler flushing data from cache since no criteria was defined.") />
			</cfif>
			<cfset getCacheStrategy().flush() />
		</cfif>
	</cffunction>

	<cffunction name="addCommand" access="public" returntype="void" output="false"
		hint="Adds a Command.">
		<cfargument name="command" type="MachII.framework.Command" required="true" />
		<cfset ArrayAppend(variables.commands, arguments.command) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->	
	<cffunction name="getKey" access="private" returntype="string" output="false">
		<cfreturn "handlerId=" & getHandlerId() />
	</cffunction>
	<cffunction name="getKeyFromCriteria" access="private" returntype="string" output="false"
		hint="Build a key from the cache handler criteria with data from the event object.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default=""
			hint="If criteria is not passed in the criteria from the cache command will be used." />
		
		<cfset var criteriaToUse =  ""/>
		<cfset var item = "" />
		<cfset var element = "" />
		<cfset var key = getKey() />
		<cfset var arg = "" />
		
		<!--- The criteria from the cache command will be used if criteria passed in is empty string. --->
		<cfif arguments.criteria eq "">
			<cfset criteriaToUse = getCriteria() />
		<cfelse>
			<cfset criteriaToUse = arguments.criteria />
		</cfif>

		<!--- Criteria can have notation like 'id=${event.product_id},type=print' where product_id is the event arg and type is a string 
			that needs to be part of the key as the id. --->		
		<cfloop list="#criteriaToUse#" index="item">
			<cfif listLen(item, "=") eq 2>
				<cfset element = listGetAt(item, 2, "=") />
				<cfset item = listGetAt(item, 1, "=") />
				<cfif getExpressionEvaluator().isExpression(element)>
					<cfset arg = getExpressionEvaluator().evaluateExpression(element, arguments.event, getAppManager().getPropertyManager()) />
				</cfif>
			<cfelse>
				<cfset arg = arguments.event.getArg(item, "") />
			</cfif>
			
			<!--- Accept only simple values and ignore complex values --->	
			<cfif IsSimpleValue(arg)>
				<cfset key = ListAppend(key, item & "=" & arg, "&") />
			<cfelse>
				<cfset key = ListAppend(key, item & "=", "&") />
			</cfif>
		</cfloop>
		
		<cfreturn key />
	</cffunction>
	
	<cffunction name="addKeyToAlias" access="private" returntype="void" output="false">
		<cfargument name="key" type="string" required="true">
		<cfset var hashedAlias = "">
		<cfif len(getAlias())>
			<cfset hashedAlias = hash(getAlias())>
			<cfif NOT listFindNoCase(variables.aliasKeyLists[hashedAlias], key)>
				<cfset variables.aliasKeyLists[hashedAlias] = listAppend(variables.aliasKeyLists[hashedAlias], key, "|")>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="computeDataToCache" access="private" returntype="struct" output="false"
		hint="Computes event data to cache based on the pre-command and post-command event data snapshots.">
		<cfargument name="preCommandDataSnapshot" type="struct" required="true" />
		<cfargument name="postCommandDataSnapshot" type="struct" required="true" />
		
		<cfset var keys = mergeStructKeys(arguments.preCommandDataSnapshot, arguments.postCommandDataSnapshot) />
		<cfset var dataToCache = StructNew() />
		<cfset var pre = "" />
		<cfset var post = "" />
		<cfset var objTest = StructNew() />
		<cfset var keyName = "" />
		<cfset var i = "" />
				
		<!--- Compare the pre/post event data --->
		<cfloop from="1" to="#ArrayLen(keys)#" index="i">
			<cfset keyName = keys[i] />
			
			<!--- Add if new arg in post --->
			<cfif NOT StructKeyExists(arguments.preCommandDataSnapshot, keyName) AND StructKeyExists(arguments.postCommandDataSnapshot , keyName)>
				<cfset dataToCache[keyName] = arguments.postCommandDataSnapshot [keyName] />
			<!--- Check equality --->
			<cfelseif StructKeyExists(arguments.preCommandDataSnapshot, keyName) AND StructKeyExists(arguments.postCommandDataSnapshot , keyName)>
				<cfset pre = arguments.preCommandDataSnapshot[keyName] />
				<cfset post = arguments.postCommandDataSnapshot[keyName] />
				
				<!--- Check for objects first because CF evaluates objects as structs as well --->
				<cfif IsObject(pre) AND IsObject(post)>
					<cfset objTest = ArrayNew(1) />
					<cfset ArrayAppend(objTest, pre) />
					<cfif NOT objTest.contains(post)>
						<cfset dataToCache[keyName] = post />
					</cfif>
				<!--- Check for queries --->
				<cfelseif IsQuery(pre) AND IsQuery(post)>
					<!--- Cannot use equals() because BD does not support it --->
					<cfif pre.hashCode() NEQ post.hashCode()>
						<cfset dataToCache[keyName] = post />
					</cfif>
				<!--- Check for simple datatypes, arrays and structs --->
				<cfelseif (IsSimpleValue(pre) AND IsSimpleValue(post))
					OR (IsArray(pre) AND IsArray(post))
					OR (IsStruct(pre) AND IsStruct(post))>
					<cfif NOT pre.equals(post)>	
						<cfset dataToCache[keyName] = post />
					</cfif>
				<!--- Since nothing else has evaluated to true then datatype has changed --->
				<cfelse>
					<cfset dataToCache[keyName] = post />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn dataToCache />
	</cffunction>
	
	<cffunction name="mergeStructKeys" access="private" returntype="array" output="false"
		hint="Returns an array of struct keys with duplicates deleted.">
		<cfargument name="struct1" type="struct" required="true" />
		<cfargument name="struct2" type="struct" required="true" />

		<cfset var mergedKeys = StructKeyList(arguments.struct1) & "," & StructKeyList(arguments.struct2) />
		<cfset var cleanedKeys = "" />
		<cfset var item = "" />
		
		<!--- Remove duplicates in the merged keys --->
		<cfloop list="#mergedKeys#" index="item">
			<cfif NOT ListFindNoCase(cleanedKeys, item)>
				<cfset cleanedKeys = ListAppend(cleanedKeys, item) />
			</cfif>
		</cfloop>

		<cfreturn ListToArray(cleanedKeys) />
	</cffunction>
	
	<cffunction name="createHandlerId" access="private" returntype="string" output="false"
		hint="Creates a random handler id. Does not use UUID for performance reasons.">
		<cfreturn Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000)) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setHandlerId" access="private" returntype="void" output="false">
		<cfargument name="handlerId" type="string" required="true" />
		<cfset variables.handlerId = arguments.handlerId />
	</cffunction>
	<cffunction name="getHandlerId" access="public" returntype="string" output="false"
		hint="Returns the handler id.">
		<cfreturn variables.handlerId />
	</cffunction>
	
	<cffunction name="setCacheStrategy" access="public" returntype="void" output="false">
		<cfargument name="cacheStrategy" type="MachII.caching.strategies.AbstractCacheStrategy" required="true" />
		<cfset variables.cacheStrategy = arguments.cacheStrategy />
	</cffunction>
	<cffunction name="getCacheStrategy" access="public" returntype="MachII.caching.strategies.AbstractCacheStrategy" output="false">
		<cfreturn variables.cacheStrategy />
	</cffunction>
	
	<cffunction name="setAlias" access="private" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="public" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>

	<cffunction name="setCacheName" access="private" returntype="void" output="false">
		<cfargument name="cacheName" type="string" required="true" />
		<cfset variables.cacheName = arguments.cacheName />
	</cffunction>
	<cffunction name="getCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.cacheName />
	</cffunction>

	<cffunction name="setCriteria" access="private" returntype="void" output="false"
		hint="Automatically converts to uppercase and sorts the criteria list.">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = ListSort(UCase(arguments.criteria), "text") />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false"
		hint="Returns an uppercase and sorted criteria list.">
		<cfreturn variables.criteria />
	</cffunction>
	
	<cffunction name="setParentHandlerName" access="private" returntype="void" output="false">
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfset variables.parentHandlerName = arguments.parentHandlerName />
	</cffunction>
	<cffunction name="getParentHandlerName" access="public" returntype="string" output="false">
		<cfreturn variables.parentHandlerName />
	</cffunction>
	
	<cffunction name="setParentHandlerType" access="private" returntype="void" output="false">
		<cfargument name="parentHandlerType" type="string" required="true" />
		<cfset variables.parentHandlerType = arguments.parentHandlerType />
	</cffunction>
	<cffunction name="getParentHandlerType" access="public" returntype="string" output="false">
		<cfreturn variables.parentHandlerType />
	</cffunction>
	
	<cffunction name="setExpressionEvaluator" access="private" returntype="void" output="false">
		<cfargument name="expressionEvaluator" type="MachII.util.ExpressionEvaluator" required="true" />
		<cfset variables.expressionEvaluator = arguments.expressionEvaluator />
	</cffunction>
	<cffunction name="getExpressionEvaluator" access="public" returntype="MachII.util.ExpressionEvaluator" output="false">
		<cfreturn variables.expressionEvaluator />
	</cffunction>
	
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>
	
</cfcomponent>