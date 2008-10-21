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
	<cfset variables.aliases = ""/>
	<cfset variables.strategyName = "" />
	<cfset variables.criteria = "" />
	<cfset variables.parentHandlerName = "" />
	<cfset variables.parentHandlerType = "" />
	<cfset variables.cacheStrategy = 0 />
	<cfset variables.cacheOutputBuffer = "" />
	<cfset variables.log = 0 />
	<cfset variables.cachingEnabled = true />
	<cfset variables.aliasKeyLists = StructNew() />
	<cfset variables.expressionEvaluator = 0 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheHandler" output="false"
		hint="Initializes the handler.">
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="aliases" type="string" required="false" default="" />
		<cfargument name="strategyName" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var currentAlias = "" />
	
		<!--- Run setters --->
		<cfset setHandlerId(arguments.id) />
		<cfset setAliases(arguments.aliases) />
		<cfset setStrategyName(arguments.strategyName) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setParentHandlerName(arguments.parentHandlerName) />
		<cfset setParentHandlerType(arguments.parentHandlerType) />

		<!--- Create the known alias key lists --->
		<cfloop list="#arguments.aliases#" index="currentAlias">
			<cfset variables.aliasKeyLists[getKeyHash(currentAlias)] = StructNew() />
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
		<cfset var key = getKeyWithCriteria(arguments.event) />
		<cfset var dataFromCache = "" />
		<cfset var commandResult = StructNew() />
		<cfset var log = getLog() />
		
		<cfif getCacheStrategy().isCacheEnabled()>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Looking for data in the cache for key '#key#'") />
			</cfif>
			
			<cflock name="#key#" type="readonly" timeout="120">
				<cfset dataFromCache = getCacheStrategy().get(key) />
			</cflock>

			<!--- Create the cache since we do not have one --->
			<cfif NOT IsDefined("dataFromCache")>
				<cflock name="#key#" type="exclusive" timeout="120">
					<!--- Get a snapshot of the event before we run the commands
					Used StructAppend so this is not updated by reference when the event is used in the commands --->
					<cfset StructAppend(preCommandEventDataSnapshot, arguments.event.getArgs()) />
					
					<!--- Register observers for HTMLHeadElement and HTTPHeader --->
					<cfset arguments.eventContext.addHTMLHeadElementCallback(this, "observeHTMLHeadElement") />
					<cfset arguments.eventContext.addHTTPHeaderCallback(this, "observeHTTPHeader") />
			
					<!--- Run commands and save output --->
					<cftry>
						<cfset commandResult = executeCommands(arguments.event, arguments.eventContext) />
						<cfcatch type="any">
							<!--- Unregister observers for HTMLHeadElement and HTTPHeader --->
							<cfset arguments.eventContext.removeHTMLHeadElementCallback(this) />
							<cfset arguments.eventContext.removeHTTPHeaderCallback(this) />
							<cfrethrow />
						</cfcatch>
					</cftry>
					
					<cfoutput>#commandResult.output#</cfoutput>
				
					<!--- Unregister observers for HTMLHeadElement and HTTPHeader --->
					<cfset arguments.eventContext.removeHTMLHeadElementCallback(this) />
					<cfset arguments.eventContext.removeHTTPHeaderCallback(this) />
	
					<!--- Build the data to cache structure up  --->
					<cfset dataToCache.output = commandResult.output />
					<cfset dataToCache.data = computeDataToCache(preCommandEventDataSnapshot, arguments.event.getArgs()) />
					<cfset dataToCache.HTMLHeadElements = getObservedHTMLHeadElements() />
					<cfset dataToCache.HTTPHeaders = getObservedHTTPHeaders() />
	
					<!--- Cache the data and output --->
					<cfset getCacheStrategy().put(key, dataToCache) />
					<cfset addKeyToAliases(key) />
					
					<!--- Log messages --->
					<cfif log.isDebugEnabled()>
						<cfset log.debug("Created cache with key '#key#'.") />
						<cfset log.debug("Cached data contained key names of '#StructKeyList(dataToCache.data)#'.") />
					</cfif>
					<cfif log.isTraceEnabled()>
						<cfset log.trace("Cached #ArrayLen(dataToCache.HTMLHeadElements)# HTML head elements.") />
						<cfset log.trace("Cached #ArrayLen(dataToCache.HTTPHeaders)# HTTP headers.") />
					</cfif>
				</cflock>
				
				<cfreturn commandResult.continue />
				
			<!--- Replay the data and output from the cache --->
			<cfelse>
				<cfoutput>#dataFromCache.output#</cfoutput>
				<cfset arguments.event.setArgs(dataFromCache.data) />
				<cfset replayHTMLHeadElements(dataFromCache.HTMLHeadElements, arguments.eventContext) />
				<cfset replayHTTPHeaders(dataFromCache.HTTPHeaders, arguments.eventContext) />
				
				<!--- Log messages --->
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Replayed data and output from cache with key '#key#'.") />
					<cfset log.debug("Cached data contained key names of '#StructKeyList(dataFromCache.data)#'.") />
				</cfif>
				<cfif log.isTraceEnabled()>
					<cfset log.trace("Replayed #ArrayLen(dataFromCache.HTMLHeadElements)# cached HTML head elements.") />
					<cfset log.trace("Replayed #ArrayLen(dataFromCache.HTTPHeaders)# cached HTTP headers.") />
				</cfif>
				
				<cfreturn true />		
			</cfif>
		
		<!--- Caching is disable so run normally --->
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Caching is curently disabled for this cache-handler.") />
			</cfif>
		
			<!--- Run the commands, out the result and continue decision --->
			<cfset commandResult = executeCommands(arguments.event, arguments.eventContext) />
			
			<cfoutput>#commandResult.output#</cfoutput>
			
			<cfreturn commandResult.continue />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCache" access="public" returntype="void" output="false"
		hint="Clears the cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />
		<cfargument name="aliases" type="string" required="false" default="" />

		<cfset var key = getKeyWithCriteria(arguments.event, arguments.criteria) />
		<cfset var currentAlias = "" />
		<cfset var currentKey = "" />
		<cfset var criteriaFromKey = "" />
		
		<!--- If we don't get any criteria passed we want to clear the cache --->
		<cfif Len(arguments.criteria) OR Len(arguments.aliases)>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Cache-handler clearing data from cache using key '#key#', aliases '#arguments.aliases#', criteria '#arguments.criteria#'.") />
			</cfif>
			<cfif Len(arguments.criteria)>
				<!--- Loop through the list of aliases and determine if criteria matches and then if 
					so the key should be removed. --->
				<cfloop list="#arguments.aliases#" index="currentAlias">
					<cfif log.isDebugEnabled()>
						<cfset log.debug("clearCache: currentAlias '#currentAlias#', aliasKeyLists '#StructKeyList(variables.aliasKeyLists)#'") />
					</cfif>
					<cfloop collection="#variables.aliasKeyLists[getKeyHash(currentAlias)]#" item="currentKey">
						<cfif currentKey EQ key>
							<cfset getCacheStrategy().remove(currentKey) />
						</cfif>
					</cfloop>
				</cfloop>
			<cfelse>
				<cfloop list="#arguments.aliases#" index="currentAlias">
					<cfif log.isDebugEnabled()>
						<cfset log.debug("clearCache: currentAlias '#currentAlias#', aliasKeyLists '#StructKeyList(variables.aliasKeyLists)#'") />
					</cfif>
					<cfloop collection="#variables.aliasKeyLists[getKeyHash(currentAlias)]#" item="currentKey">
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
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="observeHTMLHeadElement" access="public" returntype="void" output="false"
		hint="Observes a HTML head element.">
		
		<cfif NOT IsDefined("request._MachIICacheHandler_#getHandlerId()#_HTMLHeadElements")>
			<cfset request["_MachIICacheHandler_#getHandlerId()#_HTMLHeadElements"] = ArrayNew(1) />
		</cfif>
		
		<cfset ArrayAppend(request["_MachIICacheHandler_#getHandlerId()#_HTMLHeadElements"], arguments) />
	</cffunction>
	
	<cffunction name="observeHTTPHeader" access="public" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">
		
		<cfif NOT IsDefined("request._MachIICacheHandler_#getHandlerId()#_HTTPHeaders")>
			<cfset request["_MachIICacheHandler_#getHandlerId()#_HTTPHeaders"] = ArrayNew(1) />
		</cfif>
		
		<cfset ArrayAppend(request["_MachIICacheHandler_#getHandlerId()#_HTTPHeaders"], arguments) />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="executeCommands" access="private" returntype="struct" output="false" 
		hints="Executes a block of commands and returns any output and continue status.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var result = StructNew() />
		<cfset var command = "" />
		<cfset var i = 0 />
		
		<cfset result.continue = true />
		<cfset result.output = "" />
		
		<cfsavecontent variable="result.output">
			<cfloop from="1" to="#ArrayLen(variables.commands)#" index="i">
				<cfset command = variables.commands[i] />
				<cfset result.continue = command.execute(arguments.event, arguments.eventContext) />
				<cfif result.continue IS false>
					<cfbreak />
				</cfif>
			</cfloop>
		</cfsavecontent>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getKeyWithCriteria" access="private" returntype="string" output="false"
		hint="Build a key with the cache handler criteria based off the data from the event object.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="#getCriteria()#"
			hint="If criteria is not passed in, the criteria from the cache handler will be used." />
		
		<cfset var criteriaToUse = "" />
		<cfset var item = "" />
		<cfset var element = "" />
		<cfset var key = "HANDLERID=" & getHandlerId() />
		<cfset var arg = "" />
		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />

		<!--- Criteria can have notation like 'id=${event.product_id},type=print' 
			where product_id is the event arg and type is a string that needs to 
			be part of the key as the id. --->		
		<cfloop list="#criteriaToUse#" index="item">
			<cfif ListLen(item, "=") eq 2>
				<cfset item = ListGetAt(item, 1, "=") />
				<cfset element = ListGetAt(item, 2, "=") />
				<cfif expressionEvaluator.isExpression(element)>
					<cfset arg = expressionEvaluator.evaluateExpression(element, arguments.event, getAppManager().getPropertyManager()) />
				<cfelse>
					<cfset arg = element />
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
	
	<cffunction name="addKeyToAliases" access="private" returntype="void" output="false"
		hint="Addes a cache block key to the the alias key list so it is possible to clear cache blocks by aliases.">
		<cfargument name="key" type="string" required="true">
		
		<cfset var aliases = getAliases() />
		<cfset var hashedAlias = "" />
		<cfset var currentAlias = "" />
		
		<cfif Len(aliases)>
			<cfloop list="#aliases#" index="currentAlias">
				<cfset hashedAlias = getKeyHash(currentAlias) />
				
				<!--- Addd the alias key to the lists in case a new alias was 
					added at runtime and get set during init() --->
				<cfif NOT StructKeyExists(variables.aliasKeyLists, hashedAlias)>
					<cfset variables.aliasKeyLists[hashedAlias] = StructNew() />
				</cfif>
				
				<!--- Add the cache block key to the alias list --->
				<cfset StructInsert(variables.aliasKeyLists[hashedAlias], key, true, true) />
			</cfloop>
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
		<cfset var keyName = "" />
		<cfset var i = "" />
				
		<!--- Compare the pre/post event data --->
		<cfloop from="1" to="#ArrayLen(keys)#" index="i">
			<cfset keyName = keys[i] />
			
			<!--- Add if new arg in post --->
			<cfif NOT StructKeyExists(arguments.preCommandDataSnapshot, keyName) AND StructKeyExists(arguments.postCommandDataSnapshot , keyName)>
				<cfset dataToCache[keyName] = arguments.postCommandDataSnapshot[keyName] />
			<!--- Check equality --->
			<cfelseif StructKeyExists(arguments.preCommandDataSnapshot, keyName) AND StructKeyExists(arguments.postCommandDataSnapshot , keyName)>
				<cfset pre = arguments.preCommandDataSnapshot[keyName] />
				<cfset post = arguments.postCommandDataSnapshot[keyName] />
				
				<!--- Check for objects first because CF evaluates objects as structs as well --->
				<cfif IsObject(pre) AND IsObject(post)>
					<cfif NOT getAppManager().getUtils().assertSame(pre, post)>
						<cfset dataToCache[keyName] = post />
					</cfif>
				<!--- Check for queries and structs
					BD fails with equals() on structs and arrays so use hashCode() --->
				<cfelseif IsQuery(pre) AND IsQuery(post)
					OR (IsStruct(pre) AND IsStruct(post))
					OR (IsArray(pre) AND IsArray(post))>
					<!--- Cannot use equals() because BD does not support it --->
					<cfif pre.hashCode() NEQ post.hashCode()>
						<cfset dataToCache[keyName] = post />
					</cfif>
				<!--- Check for simple datatypes --->
				<cfelseif (IsSimpleValue(pre) AND IsSimpleValue(post))>
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
	
	<cffunction name="getObservedHTMLHeadElements" access="private" returntype="array" output="false"
		hint="Gets observed HTML head elements.">		
		<cfif IsDefined("request._MachIICacheHandler_#getHandlerId()#_HTMLHeadElements")>
			<cfreturn request["_MachIICacheHandler_#getHandlerId()#_HTMLHeadElements"] />
		<cfelse>
			<cfreturn ArrayNew(1) />
		</cfif>
	</cffunction>
	<cffunction name="replayHTMLHeadElements" access="private" returntype="void" output="false"
		hint="Replays cached HTML head elements.">
		<cfargument name="HTMLHeadElements" type="array" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.HTMLHeadElements)#" index="i">
			<cfset arguments.eventContext.addHTMLHeadElement(argumentcollection=arguments.HTMLHeadElements[i]) />
		</cfloop>
	</cffunction>

	<cffunction name="getObservedHTTPHeaders" access="private" returntype="array" output="false"
		hint="Gets observed HTTP headers.">
		<cfif IsDefined("request._MachIICacheHandler_#getHandlerId()#_HTTPHeaders")>
			<cfreturn request["_MachIICacheHandler_#getHandlerId()#_HTTPHeaders"] />
		<cfelse>
			<cfreturn ArrayNew(1) />
		</cfif>
	</cffunction>
	<cffunction name="replayHTTPHeaders" access="private" returntype="void" output="false"
		hint="Replays cached HTTP header.">
		<cfargument name="HTTPHeaders" type="array" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.HTTPHeaders)#" index="i">
			<cfset arguments.eventContext.addHTTPHeader(argumentcollection=arguments.HTTPHeaders[i]) />
		</cfloop>
	</cffunction>
	
	<cffunction name="getKeyHash" access="private" returntype="string" output="false"
		hint="Gets a key name hash (uppercase and hash the key name)">
		<cfargument name="keyName" type="string" required="true" />
		<cfreturn Hash(UCase(arguments.keyName)) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setHandlerId" access="private" returntype="void" output="false"
		hint="Sets the hanlder id and creates an unique id if handler id is NOT len.">
		<cfargument name="handlerId" type="string" required="true" />
		<cfif Len(arguments.handlerId)>
			<cfset variables.handlerId = arguments.handlerId />
		<cfelse>
			<cfset variables.handlerId = createHandlerId() />
		</cfif>
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
	
	<cffunction name="setAliases" access="private" returntype="void" output="false">
		<cfargument name="aliases" type="string" required="true" />
		<cfset variables.aliases = arguments.aliases />
	</cffunction>
	<cffunction name="getAliases" access="public" returntype="string" output="false">
		<cfreturn variables.aliases />
	</cffunction>

	<cffunction name="setStrategyName" access="private" returntype="void" output="false">
		<cfargument name="strategyName" type="string" required="true" />
		<cfset variables.strategyName = arguments.strategyName />
	</cffunction>
	<cffunction name="getStrategyName" access="public" returntype="string" output="false">
		<cfreturn variables.strategyName />
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