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

Created version: 1.5.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="CommandLoaderBase"
	output="false"
	hint="Base component to load commands for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.beanUtil = "" />
	<cfset variables.utils = "" />
	<cfset variables.expressionEvaluator = "" />
	<cfset variables.configurableCommandTargets = ArrayNew(1) />
	<cfset variables.cacheClearCommandLog = "" />
	<cfset variables.cacheCommandLog = "" />
	<cfset variables.callMethodCommandLog = "" />
	<cfset variables.eventArgCommandLog = "" />
	<cfset variables.eventBeanCommandLog = "" />
	<cfset variables.redirectCommandlog = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<cfset variables.beanUtil = CreateObject("component", "MachII.util.BeanUtil").init() />
		<cfset variables.utils = getAppManager().getUtils() />
		<cfset variables.expressionEvaluator = getAppManager().getExpressionEvaluator() />

		<!--- Grab local references to increase performance because constantly getting a the 
			same log when computing the channel name via getMetadata is expensive --->
		<cfset variables.cacheClearCommandLog = getAppManager().getLogFactory().getLog("MachII.framework.commands.CacheClearCommand") />
		<cfset variables.cacheCommandLog = getAppManager().getLogFactory().getLog("MachII.framework.commands.CacheCommand") />
		<cfset variables.callMethodCommandLog = getAppManager().getLogFactory().getLog("MachII.framework.commands.CallMethodCommand") />
		<cfset variables.eventArgCommandLog = getAppManager().getLogFactory().getLog("MachII.framework.commands.EventArgCommand") />
		<cfset variables.eventBeanCommandLog = getAppManager().getLogFactory().getLog("MachII.framework.commands.EventBeanCommand") />
		<cfset variables.redirectCommandlog = getAppManager().getLogFactory().getLog("MachII.framework.commands.RedirectCommand") />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Call on object reload for all configurable commands.">
		
		<cfset var appManager = getAppManager() />
		<cfset var aCommand = 0 />
		<cfset var i = 0 />
		
		<!--- Loop through the configurable commands --->
		<cfloop from="1" to="#ArrayLen(variables.configurableCommandTargets)#" index="i">
			<cfset aCommand = variables.configurableCommandTargets[i] />
			<cfset appManager.onObjectReload(aCommand) />
		</cfloop>
	</cffunction>
		
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createCommand" access="private" returntype="MachII.framework.Command" output="false"
		hint="Loads and instantiates a command from an XML fragment.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var command = "" />

		<!--- Optimized: If/elseif blocks are faster than switch/case --->
		<!--- view-page --->
		<cfif arguments.commandNode.xmlName EQ "view-page">
			<cfset command = setupViewPage(arguments.commandNode) />
		<!--- notify --->
		<cfelseif arguments.commandNode.xmlName EQ "notify">
			<cfset command = setupNotify(arguments.commandNode) />
		<!--- announce --->
		<cfelseif arguments.commandNode.xmlName EQ "announce">
			<cfset command = setupAnnounce(arguments.commandNode) />
		<!--- publish --->
		<cfelseif arguments.commandNode.xmlName EQ "publish">
			<cfset command = setupPublish(arguments.commandNode) />
		<!--- event-mapping --->
		<cfelseif arguments.commandNode.xmlName EQ "event-mapping">
			<cfset command = setupEventMapping(arguments.commandNode) />
		<!--- execute --->
		<cfelseif arguments.commandNode.xmlName EQ "execute">
			<cfset command = setupExecute(arguments.commandNode) />
		<!--- filter --->
		<cfelseif arguments.commandNode.xmlName EQ "filter">
			<cfset command = setupFilter(arguments.commandNode) />
		<!--- event-bean --->
		<cfelseif arguments.commandNode.xmlName EQ "event-bean">
			<cfset command = setupEventBean(arguments.commandNode) />
		<!--- redirect --->
		<cfelseif arguments.commandNode.xmlName EQ "redirect">
			<cfset command = setupRedirect(arguments.commandNode) />
		<!--- event-arg --->
		<cfelseif arguments.commandNode.xmlName EQ "event-arg">
			<cfset command = setupEventArg(arguments.commandNode) />
		<!--- cache --->
		<cfelseif arguments.commandNode.xmlName EQ "cache">
			<cfset command = setupCache(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType, arguments.override) />
		<!--- cache-clear --->
		<cfelseif arguments.commandNode.xmlName EQ "cache-clear">
			<cfset command = setupCacheClear(arguments.commandNode) />
		<!--- call-method --->
		<cfelseif arguments.commandNode.xmlName EQ "call-method">
			<cfset command = setupCallMethod(arguments.commandNode) />
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset command = setupDefault(arguments.commandNode) />
		</cfif>
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCache" access="private" returntype="MachII.framework.commands.CacheCommand" output="false"
		hint="Sets up a cache command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var command = "" />
		<cfset var aliases = "" />
		<cfset var handlerId = "" />
		<cfset var criteria = "" />
		<cfset var name = "" />
		
		<cfset handlerId = getAppManager().getCacheManager().loadCacheHandlerFromXml(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType, arguments.override) />
		
		<cfif StructKeyExists(arguments.commandNode, "xmlAttributes") >
			<!--- We cannot get the default cache strategy name because it has not been set
				by the CachingProperty yet. We deal with getting the default cache strategy
				in the configure() method of the CachingManager. --->
			<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "strategyName")>
				<cfset name = arguments.commandNode.xmlAttributes["strategyName"] />
			</cfif>
			<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "aliases")>
				<cfset aliases = variables.utils.trimList(arguments.commandNode.xmlAttributes["aliases"]) />
			</cfif>
			<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "criteria")>
				<cfset criteria = variables.utils.trimList(arguments.commandNode.xmlAttributes["criteria"]) />
			</cfif>
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.CacheCommand").init(handlerId, name, aliases, criteria) />
		<cfset command.setLog(variables.cacheCommandLog) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCacheClear" access="private" returntype="MachII.framework.commands.CacheClearCommand" output="false"
		hint="Sets up a CacheClear command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var ids = "" />
		<cfset var aliases = "" />
		<cfset var strategyNames = "" />
		<cfset var criteria = "" />
		<cfset var condition = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "ids")>
			<cfset ids = variables.utils.trimList(arguments.commandNode.xmlAttributes["ids"]) />	
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "aliases")>
			<cfset aliases = variables.utils.trimList(arguments.commandNode.xmlAttributes["aliases"]) />	
		</cfif>		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "strategyNames")>
			<cfset strategyNames = arguments.commandNode.xmlAttributes["strategyNames"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "criteria")>
			<cfset criteria = variables.utils.trimList(arguments.commandNode.xmlAttributes["criteria"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "condition")>
			<cfset condition = arguments.commandNode.xmlAttributes["condition"] />	
		</cfif>

		<cfset command = CreateObject("component", "MachII.framework.commands.CacheClearCommand").init(
			ids, aliases, strategyNames, criteria, condition) />
		<cfset command.setLog(variables.cacheClearCommandLog) />
		<cfset command.setExpressionEvaluator(variables.expressionEvaluator) />
		<cfset command.setPropertyManager(getAppManager().getPropertyManager()) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCallMethod" access="private" returntype="MachII.framework.commands.CallMethodCommand" output="false"
		hint="Sets up a CallMethodCommand command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var bean = "" />
		<cfset var resultArg = "" />
		<cfset var method = "" />
		<cfset var args = "" />
		<cfset var i = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "bean")>
			<cfset bean = arguments.commandNode.xmlAttributes["bean"] />	
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultArg")>
			<cfset resultArg = arguments.commandNode.xmlAttributes["resultArg"] />	
		</cfif>	
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "method")>
			<cfset method = arguments.commandNode.xmlAttributes["method"] />	
		</cfif>	
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "args")>
			<cfset args = arguments.commandNode.xmlAttributes["args"] />	
		</cfif>		

		<!--- support adding arguments tags inside call-method --->
		<cfloop from="1" to="#arrayLen(arguments.commandNode.xmlChildren)#" index="i">
			<cfif arguments.commandNode.xmlChildren[i].xmlName eq "argument">
				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "name")>
					<cfset args = ListAppend(args, 
						"#arguments.commandNode.xmlChildren[i].xmlAttributes["name"]#=#arguments.commandNode.xmlChildren[i].xmlAttributes["value"]#") />
				<cfelse>
					<cfset args = ListAppend(args, #arguments.commandNode.xmlChildren[i].xmlAttributes["value"]#) />
				</cfif>
			</cfif>
		</cfloop>

		<cfset command = CreateObject("component", "MachII.framework.commands.CallMethodCommand").init(bean, method, args, resultArg) />
		<cfset command.setLog(variables.callMethodCommandLog) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		<cfset command.setPropertyManager(getAppManager().getPropertyManager()) />
		
		<cfset addConfigurableCommandTarget(command) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupViewPage" access="private" returntype="MachII.framework.commands.ViewPageCommand" output="false"
		hint="Sets up a view-page command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var viewName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var contentKey = "" />
		<cfset var contentArg = "" />
		<cfset var appendContent = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentKey")>
			<cfset contentKey = commandNode.xmlAttributes["contentKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentArg")>
			<cfset contentArg = commandNode.xmlAttributes["contentArg"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "append")>
			<cfset appendContent = arguments.commandNode.xmlAttributes["append"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.ViewPageCommand").init(viewName, contentKey, contentArg, appendContent) />
		
		<cfreturn command />
	</cffunction>

	<cffunction name="setupNotify" access="private" returntype="MachII.framework.commands.NotifyCommand" output="false"
		hint="Sets up a notify command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var notifyListener = arguments.commandNode.xmlAttributes["listener"] />
		<cfset var notifyMethod = arguments.commandNode.xmlAttributes["method"] />
		<cfset var notifyResultKey = "" />
		<cfset var notifyResultArg = "" />
		<cfset var listenerProxy = getAppManager().getListenerManager().getListener(notifyListener).getProxy() />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultKey")>
			<cfset notifyResultKey = arguments.commandNode.xmlAttributes["resultKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultArg")>
			<cfset notifyResultArg = arguments.commandNode.xmlAttributes["resultArg"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.NotifyCommand").init(listenerProxy, notifyMethod, notifyResultKey, notifyResultArg) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupPublish" access="private" returntype="MachII.framework.commands.PublishCommand" output="false"
		hint="Sets up a publish command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var message = arguments.commandNode.xmlAttributes["message"] />
		<cfset var messageHandler = getAppManager().getMessageManager().getMessageHandler(message) />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.PublishCommand").init(message, messageHandler) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupAnnounce" access="private" returntype="MachII.framework.commands.AnnounceCommand" output="false"
		hint="Sets up an announce command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var copyEventArgs = true />
		<cfset var moduleName = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "copyEventArgs")>
			<cfset copyEventArgs = arguments.commandNode.xmlAttributes["copyEventArgs"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "module")>
			<cfset moduleName = arguments.commandNode.xmlAttributes["module"] />
		<cfelse>
			<cfset moduleName = getAppManager().getModuleName() />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.AnnounceCommand").init(eventName, copyEventArgs, moduleName) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventMapping" access="private" returntype="MachII.framework.commands.EventMappingCommand" output="false"
		hint="Sets up an event-mapping command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var mappingName = arguments.commandNode.xmlAttributes["mapping"] />
		<cfset var mappingModule = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "mappingModule")>
			<cfset mappingModule = arguments.commandNode.xmlAttributes["mappingModule"] />
		<cfelse>
			<cfset mappingModule = getAppManager().getModuleName() />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventMappingCommand").init(eventName, mappingName, mappingModule) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupExecute" access="private" returntype="MachII.framework.commands.ExecuteCommand" output="false"
		hint="Sets up an execute command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var subroutine = arguments.commandNode.xmlAttributes["subroutine"] />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.ExecuteCommand").init(subroutine) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupFilter" access="private" returntype="MachII.framework.commands.FilterCommand" output="false"
		hint="Sets up a filter command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var filterName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var filterParams = StructNew() />
		<cfset var paramNodes = arguments.commandNode.xmlChildren />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var filterProxy = getAppManager().getFilterManager().getFilter(filterName).getProxy() />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(paramNodes)#" index="i">
			<cfset paramName = paramNodes[i].xmlAttributes["name"] />
			<cfif NOT StructKeyExists(paramNodes[i].xmlAttributes, "value")>
				<cfset paramValue = getAppManager().getUtils().recurseComplexValues(paramNodes[i]) />
			<cfelse>
				<cfset paramValue = paramNodes[i].xmlAttributes["value"] />
			</cfif>
			<cfset filterParams[paramName] = paramValue />
		</cfloop>

		<cfset command = CreateObject("component", "MachII.framework.commands.FilterCommand").init(filterProxy, filterParams) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventBean" access="private" returntype="MachII.framework.commands.EventBeanCommand" output="false"
		hint="Sets up a event-bean command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var beanName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var beanType = arguments.commandNode.xmlAttributes["type"] />
		<cfset var beanFields = "" />
		<cfset var reinit = true />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "fields")>
			<cfset beanFields = variables.utils.trimList(arguments.commandNode.xmlAttributes["fields"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "reinit")>
			<cfset reinit = arguments.commandNode.xmlAttributes["reinit"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(beanName, beanType, beanFields, reinit, variables.beanUtil) />
		
		<cfset command.setLog(variables.eventBeanCommandLog) />

		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupRedirect" access="private" returntype="MachII.framework.commands.RedirectCommand" output="false"
		hint="Sets up a redirect command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = "" />
		<cfset var redirectUrl = getAppManager().getPropertyManager().getProperty("urlBase", "index.cfm") />
		<cfset var moduleName = "" />
		<cfset var args = "" />
		<cfset var persist = false />
		<cfset var persistArgs = "" />
		<cfset var persistArgsIgnore = "" />
		<cfset var statusType = "temporary" />
		<cfset var eventParameter = getAppManager().getPropertyManager().getProperty("eventParameter", "event") />
		<cfset var redirectPersistParameter = getAppManager().getPropertyManager().getProperty("redirectPersistParameter", "persistId") /> />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "event")>
			<cfset eventName = arguments.commandNode.xmlAttributes["event"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "url")>
			<cfset redirectUrl = arguments.commandNode.xmlAttributes["url"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "args")>
			<cfset args = variables.utils.trimList(arguments.commandNode.xmlAttributes["args"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "persist")>
			<cfset persist = arguments.commandNode.xmlAttributes["persist"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "persistArgs")>
			<cfset persistArgs = variables.utils.trimList(arguments.commandNode.xmlAttributes["persistArgs"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "persistArgsIgnore")>
			<cfset persistArgsIgnore = variables.utils.trimList(arguments.commandNode.xmlAttributes["persistArgsIgnore"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "module")>
			<cfset moduleName = arguments.commandNode.xmlAttributes["module"] />
		<cfelse>
			<cfset moduleName = getAppManager().getModuleName() />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "statusType")>
			<cfset statusType = arguments.commandNode.xmlAttributes["statusType"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.RedirectCommand").init(eventName, eventParameter, redirectPersistParameter, moduleName, redirectUrl, args, persist, persistArgs, statusType, persistArgsIgnore) />
		
		<cfset command.setLog(variables.redirectCommandLog) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventArg" access="private" returntype="MachII.framework.commands.EventArgCommand" output="false"
		hint="Sets up an event-arg command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var argValue = "" />
		<cfset var argVariable = "" />
		<cfset var overwrite = true />
		<cfset var argName = arguments.commandNode.xmlAttributes["name"] />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "value")>
			<cfset argValue = arguments.commandNode.xmlAttributes["value"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "variable")>
			<cfset argVariable = arguments.commandNode.xmlAttributes["variable"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "overwrite")>
			<cfset overwrite = arguments.commandNode.xmlAttributes["overwrite"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventArgCommand").init(argName, argValue, argVariable, overwrite) />
		
		<cfset command.setLog(variables.eventArgCommandLog) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupDefault" access="private" returntype="MachII.framework.Command" output="false"
		hint="Sets up a default command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = CreateObject("component", "MachII.framework.Command").init() />
		
		<cfset command.setParameter("commandName", arguments.commandNode.xmlName) />
		
		<cfreturn command />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="addConfigurableCommandTarget" access="private" returntype="void" output="false"
		hint="Adds an command to the on reload targets.">
		<cfargument name="command" type="MachII.framework.Command" required="true" />
		<cfset ArrayAppend(variables.configurableCommandTargets, arguments.command) />
	</cffunction>
	<cffunction name="getConfigurableCommandTargets" access="public" returntype="array" output="false"
		hint="Gets the on reload command targets.">
		<cfreturn variables.configurableCommandTargets />
	</cffunction>
	
</cfcomponent>