<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id: CacheHandler.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.8.0

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
	<cfset variables.keySet = CreateObject("java", "java.util.HashSet").init() />
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
	
		<!--- Run setters --->
		<cfset setHandlerId(arguments.id) />
		<cfset setAliases(arguments.aliases) />
		<cfset setStrategyName(arguments.strategyName) />
		<cfset setCriteria(arguments.criteria) />
		<cfset setParentHandlerName(arguments.parentHandlerName) />
		<cfset setParentHandlerType(arguments.parentHandlerType) />
		
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
							
							<!--- Should not be counted as a miss if the cache block unencounters an exception --->
							<cfset getCacheStrategy().getCacheStats().decrementCacheMisses() />
							
							<cfrethrow />
						</cfcatch>
					</cftry>
					
					<cfsetting enablecfoutputonly="false" /><cfoutput>#commandResult.output#</cfoutput><cfsetting enablecfoutputonly="true" />
				
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
					<cfset variables.keySet.add(key) />
					
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
				<cfsetting enablecfoutputonly="false" /><cfoutput>#dataFromCache.output#</cfoutput><cfsetting enablecfoutputonly="true" />
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
			
			<cfsetting enablecfoutputonly="false" /><cfoutput>#commandResult.output#</cfoutput><cfsetting enablecfoutputonly="true" />
			
			<cfreturn commandResult.continue />
		</cfif>
	</cffunction>
	
	<cffunction name="clearCache" access="public" returntype="void" output="false"
		hint="Clears the cache.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="" />

		<cfset var key = getKeyWithCriteria(arguments.event, arguments.criteria) />
		<cfset var keyIds = "" />
		<cfset var i = 0 />
		
		<!--- Clear by key with criteria --->
		<cfif Len(arguments.criteria)>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Cache-handler clearing data from cache using key '#key#' with criteria '#arguments.criteria#'") />
			</cfif>
			
			<cfset getCacheStrategy().remove(key) />
			<cfset variables.keySet.remove(key) />
		<!---Clear by keys associated with this handler (clear by id without criteria or by alias) --->
		<cfelse>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Cache-handler clearing all data from cache that start with id '#getHandlerId()#'") />
			</cfif>
			
			<!--- Get a copy of the key ids and then clear --->
			<cfset keyIds = variables.keySet.toArray() />
			<cfset variables.keySet.clear() />
			
			<!--- Clear the cache block from the array of key ids --->
			<cfloop from="1" to="#ArrayLen(keyIds)#" index="i">
				<cfset getCacheStrategy().remove(keyIds[i]) />
			</cfloop>
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

		<!--- Individual arguments are not passed in so we just observe the argument collection --->
		
		<cfif NOT IsDefined("request._MachIICacheHandler_#getHandlerId()#_HTMLHeadElements")>
			<cfset request["_MachIICacheHandler_#getHandlerId()#_HTMLHeadElements"] = ArrayNew(1) />
		</cfif>
		
		<cfset ArrayAppend(request["_MachIICacheHandler_#getHandlerId()#_HTMLHeadElements"], arguments) />
	</cffunction>
	
	<cffunction name="observeHTTPHeader" access="public" returntype="void" output="false"
		hint="Adds a HTTP header. You must use named arguments or addHTTPHeaderByName/addHTTPHeaderByStatus helper methods.">

		<!--- Individual arguments are not passed in so we just observe the argument collection --->
		
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
		<cfset var output = "" />
		<cfset var command = "" />
		<cfset var i = 0 />
		
		<cfset result.continue = true />
		<cfset result.output = "" />
		
		<cfsavecontent variable="output">
			<cfloop from="1" to="#ArrayLen(variables.commands)#" index="i">
				<cfset command = variables.commands[i] />
				<cfset result.continue = command.execute(arguments.event, arguments.eventContext) />
				<cfif result.continue IS false>
					<cfbreak />
				</cfif>
			</cfloop>
		</cfsavecontent>
		
		<!--- Suppress some whitespace --->
		<cfset result.output = Trim(output) />
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getKeyWithCriteria" access="private" returntype="string" output="false"
		hint="Build a key with the cache handler criteria based off the data from the event object.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="criteria" type="string" required="false" default="#getCriteria()#"
			hint="If criteria is not passed in, the criteria from the cache handler will be used." />
		
		<cfset var item = "" />
		<cfset var element = "" />
		<cfset var key = "HANDLERID=" & getHandlerId() />
		<cfset var arg = "" />
		<cfset var expressionEvaluator = getAppManager().getExpressionEvaluator() />

		<!--- Criteria can have notation like 'id=${event.product_id},type=print' 
			where product_id is the event arg and type is a string that needs to 
			be part of the key as the id. --->		
		<cfloop list="#arguments.criteria#" index="item">
			<cfif ListLen(item, "=") eq 2>
				<cfset element = ListGetAt(item, 2, "=") />
				<cfset item = ListGetAt(item, 1, "=") />
				<cfif expressionEvaluator.isExpression(element)>
					<cfset arg = expressionEvaluator.evaluateExpression(element, arguments.event, getAppManager().getPropertyManager()) />
				<cfelse>
					<cfset arg = element />
				</cfif>
			<cfelse>
				<cfif expressionEvaluator.isExpression(item)>
					<cfset arg = expressionEvaluator.evaluateExpression(item, arguments.event, getAppManager().getPropertyManager()) />
				<cfelse>
					<cfset arg = arguments.event.getArg(item, "") />
				</cfif>
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
		hint="Sets the log.">
		<cfargument name="log" type="MachII.logging.Log" required="true" />
		<cfset variables.log = arguments.log />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>
	
</cfcomponent>