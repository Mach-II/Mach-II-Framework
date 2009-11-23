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
		hint="Calls onObjectReload for all configurable commands.">
		
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
			<cfset command = setupEventArg(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
		<!--- cache --->
		<cfelseif arguments.commandNode.xmlName EQ "cache">
			<cfset command = setupCache(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType, arguments.override) />
		<!--- cache-clear --->
		<cfelseif arguments.commandNode.xmlName EQ "cache-clear">
			<cfset command = setupCacheClear(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
		<!--- call-method --->
		<cfelseif arguments.commandNode.xmlName EQ "call-method">
			<cfset command = setupCallMethod(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset command = setupDefault(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
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
		<cfset command.setParentHandlerName(arguments.parentHandlerName) />
		<cfset command.setParentHandlerType(arguments.parentHandlerType) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCacheClear" access="private" returntype="MachII.framework.commands.CacheClearCommand" output="false"
		hint="Sets up a CacheClear command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var command = "" />
		<cfset var ids = "" />
		<cfset var aliases = "" />
		<cfset var strategyNames = "" />
		<cfset var criteria = "" />
		<cfset var criteriaCollectionName = "" />
		<cfset var criteriaCollection = "" />
		<cfset var condition = "" />
		
		<cfset var criterionName = "" />
		<cfset var criterionValue = "" />
		<cfset var criterionNodes = arguments.commandNode.xmlChildren />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "ids")>
			<cfset ids = variables.utils.trimList(arguments.commandNode.xmlAttributes["ids"]) />	
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "aliases")>
			<cfset aliases = variables.utils.trimList(arguments.commandNode.xmlAttributes["aliases"]) />	
		</cfif>		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "strategyNames")>
			<cfset strategyNames = variables.utils.trimList(arguments.commandNode.xmlAttributes["strategyNames"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "criteria")>
			<cfset criteria = variables.utils.trimList(arguments.commandNode.xmlAttributes["criteria"]) />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "condition")>
			<cfset condition = Trim(arguments.commandNode.xmlAttributes["condition"]) />	
		</cfif>
		
		<!--- Ensure there are not both criteria (attribute) and criterion nodes --->
		<cfif Len(criteria) AND ArrayLen(criterionNodes)>
			<cfthrow type="MachII.CommandLoaderBase.InvalidCacheClearCriteria"
				message="When using cache-clear you must use either all nested criterion elements or the 'criteria' attribute."
				detail="This exception occurred in a cache-clear command in '#arguments.parentHandlerName#' #arguments.parentHandlerType#." />
		</cfif>
		
		<!--- Get nested criterion --->
		<cfloop from="1" to="#ArrayLen(criterionNodes)#" index="i">
			<cfset criterionName = criterionNodes[i].xmlAttributes["name"] />
			
			<cfif NOT StructKeyExists(criterionNodes[i].xmlAttributes, "value")>
				<cfif Len(criteriaCollection)>
					<cfthrow type="MachII.CommandLoaderBase.InvalidCacheClearCriteriaCollection"
						message="There can be only one criterion collection to loop over when clearing a cache."
						detail="This exception occurred in a cache-clear command in '#arguments.parentHandlerName#' #arguments.parentHandlerType#." />				
				</cfif>
				
				<cfif StructKeyExists(criterionNodes[i].xmlAttributes, "collection")>
					<cfset criteriaCollection = criterionNodes[i].xmlAttributes["collection"] />
				<cfelse>
					<cfset criteriaCollection = variables.utils.recurseComplexValues(criterionNodes[i]) />
				</cfif>
				
				<cfset criteriaCollectionName = criterionName />
				
				<!--- If we have a complex value, ensure it's an array --->
				<cfif NOT IsSimpleValue(criteriaCollection) AND NOT IsArray(criteriaCollection)>
					<cfthrow type="MachII.CommandLoaderBase.InvalidCacheClearCriteriaCollection"
						message="The criterion collection can only be a list or array."
						detail="This exception occurred in a cache-clear command in '#arguments.parentHandlerName#' #arguments.parentHandlerType#." />					
				</cfif>
			<cfelse>
				<cfset criterionValue = criterionNodes[i].xmlAttributes["value"] />
				<cfset criteria = ListAppend(criteria, criterionName & "=" & criterionValue) />
			</cfif>	
		</cfloop>

		<cfset command = CreateObject("component", "MachII.framework.commands.CacheClearCommand").init(
			ids, aliases, strategyNames, criteria
			, criteriaCollectionName, criteriaCollection, condition) />
		<cfset command.setLog(variables.cacheClearCommandLog) />
		<cfset command.setExpressionEvaluator(variables.expressionEvaluator) />
		<cfset command.setParentHandlerName(arguments.parentHandlerName) />
		<cfset command.setParentHandlerType(arguments.parentHandlerType) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCallMethod" access="private" returntype="MachII.framework.commands.CallMethodCommand" output="false"
		hint="Sets up a CallMethodCommand command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var command = "" />
		<cfset var bean = arguments.commandNode.xmlAttributes["bean"] />
		<cfset var method = arguments.commandNode.xmlAttributes["method"] />
		<cfset var resultArg = "" />
		<cfset var args = "" />
		<cfset var i = "" />
		<cfset var namedArgCount = 0 />
		<cfset var argValue = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultArg")>
			<cfset resultArg = arguments.commandNode.xmlAttributes["resultArg"] />	
		</cfif>	
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "args")>
			<cfset args = arguments.commandNode.xmlAttributes["args"] />	
		</cfif>		

		<cfset command = CreateObject("component", "MachII.framework.commands.CallMethodCommand").init(bean, method, args, resultArg) />
		<cfset command.setLog(variables.callMethodCommandLog) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		<cfset command.setUtils(variables.utils) />
		<cfset command.setParentHandlerName(arguments.parentHandlerName) />
		<cfset command.setParentHandlerType(arguments.parentHandlerType) />

		<!--- support adding arguments tags inside call-method --->
		<cfloop from="1" to="#arrayLen(arguments.commandNode.xmlChildren)#" index="i">
			<cfif arguments.commandNode.xmlChildren[i].xmlName EQ "arg">
				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "name")>
					<cfif namedArgCount eq 0 AND i gt 1>
						<cfthrow type="MachII.CommandLoaderBase.InvalidCallMethodArguments"
							message="When using call-method calling bean '#bean#.#method#' you must use either all named arguments or all positional arguments.">
					<cfelse>
						<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "value")>
							<cfset command.addArgument(arguments.commandNode.xmlChildren[i].xmlAttributes["name"],
								arguments.commandNode.xmlChildren[i].xmlAttributes["value"]) />
						<cfelse>
							<cfif ArrayLen(arguments.commandNode.xmlChildren[i].xmlChildren) eq 0>
								<cfthrow type="MachII.CommandLoaderBase.InvalidCallMethodArguments"
									message="You must provide a value for the argument named '#arguments.commandNode.xmlChildren[i].xmlAttributes["name"]#'."
									detail="This exception occurred in a call-method command in '#arguments.parentHandlerName#' #arguments.parentHandlerType#." />
							<cfelse>
								<!--- Handle structs or arrays that are passed in as arguments --->
								<cfset argValue = variables.utils.recurseComplexValues(arguments.commandNode.xmlChildren[i]) />
								<cfset command.addArgument(arguments.commandNode.xmlChildren[i].xmlAttributes["name"], argValue) />
							</cfif>
						</cfif>
						<cfset namedArgCount = namedArgCount + 1 />
					</cfif>
				<cfelse>
					<cfif namedArgCount gt 0 AND i gt 1>
						<cfthrow type="MachII.CommandLoaderBase.InvalidCallMethodArguments"
							message="When using call-method you must use either all named arguments or all positional arguments."
							detail="This exception occurred in a call-method command in '#arguments.parentHandlerName#' #arguments.parentHandlerType#." />
					<cfelse>
						<cfset command.addArgument("", arguments.commandNode.xmlChildren[i].xmlAttributes["value"]) />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
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
				<cfset paramValue = variables.utils.recurseComplexValues(paramNodes[i]) />
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
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var ignoreFields = "" />
		<cfset var reinit = true />
		<cfset var innerBeans = ArrayNew(1) />
		<cfset var innerBean = "" />
		<cfset var innerBeanChildren = "" />
		<cfset var autoPopulate = false />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "type")>
			<cfset beanType = arguments.commandNode.xmlAttributes["type"] />
		</cfif>
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "autopopulate")>
			<cfset autoPopulate = arguments.commandNode.xmlAttributes["autopopulate"] />
		</cfif>
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "fields")>
			<cfset beanFields = variables.utils.trimList(arguments.commandNode.xmlAttributes["fields"]) />
		</cfif>
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "ignoreFields")>
			<cfset ignoreFields = variables.utils.trimList(arguments.commandNode.xmlAttributes["ignoreFields"]) />
		</cfif>
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "reinit")>
			<cfset reinit = arguments.commandNode.xmlAttributes["reinit"] />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(
			beanName, beanType, beanFields, ignoreFields, reinit, variables.beanUtil, autoPopulate) />
		
		<cfset command.setLog(variables.eventBeanCommandLog) />
		<cfset command.setExpressionEvaluator(getAppManager().getExpressionEvaluator()) />
		
		<!--- support adding inner-bean and field tags inside event-bean --->
		<cfloop from="1" to="#arrayLen(arguments.commandNode.xmlChildren)#" index="i">
			<cfif arguments.commandNode.xmlChildren[i].xmlName eq "inner-bean">
			
				<cfset innerBean = CreateObject("component", "MachII.util.BeanInfo").init() />
				
				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "name")>
					<cfset innerBean.setName(arguments.commandNode.xmlChildren[i].xmlAttributes["name"]) />
				<cfelse>
					<cfthrow type="MachII.framework.CommandLoaderBase.InnerBeanNameRequired"
						message="A name is required for the inner-bean that is part of event-bean '#beanName#'." />
				</cfif>
				
				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "prefix")>
					<cfset innerBean.setPrefix(arguments.commandNode.xmlChildren[i].xmlAttributes["prefix"]) />
				<cfelse>
					<cfset innerBean.setPrefix(innerBean.getName()) />
				</cfif>
				
				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "fields")>
					<cfset innerBean.setIncludeFields(variables.utils.trimList(arguments.commandNode.xmlChildren[i].xmlAttributes["fields"])) />
				</cfif>
				
				<cfset innerBeanChildren = arguments.commandNode.xmlChildren[i].xmlChildren />
				<cfif ArrayLen(innerBeanChildren)>
					<cfset processInnerBeans(innerBeanChildren, innerBean) />
				</cfif>
				
				<cfset command.addInnerBean(innerBean) />
			
			<cfelseif arguments.commandNode.xmlChildren[i].xmlName eq "field">

				<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "name")> 
					<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "ignore")>
						<cfif arguments.commandNode.xmlChildren[i].xmlAttributes["ignore"]>
						 	<cfset command.addIgnoreField(arguments.commandNode.xmlChildren[i].xmlAttributes["name"]) />
						<cfelse>
							<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "value")> 
							 	<cfset command.addFieldWithValue(arguments.commandNode.xmlChildren[i].xmlAttributes["name"],
									arguments.commandNode.xmlChildren[i].xmlAttributes["value"]) />
							<cfelse>
								<cfset command.addIncludeField(arguments.commandNode.xmlChildren[i].xmlAttributes["name"]) />
							</cfif>
						</cfif>
					<cfelse>
						<!--- The ignore attribute is not present to include the field --->
						<cfif StructKeyExists(arguments.commandNode.xmlChildren[i].xmlAttributes, "value")> 
						 	<cfset command.addFieldWithValue(arguments.commandNode.xmlChildren[i].xmlAttributes["name"],
								arguments.commandNode.xmlChildren[i].xmlAttributes["value"]) />
						<cfelse>
							<cfset command.addIncludeField(arguments.commandNode.xmlChildren[i].xmlAttributes["name"]) />
						</cfif>
					</cfif>
				<cfelse>
					<cfthrow type="MachII.framework.CommandLoaderBase.FieldNameRequired"
						message="In event-bean '#beanName#' field names are required for each field tag." />
				</cfif>
					
			</cfif>
		</cfloop>

		<cfreturn command />
	</cffunction>
	
	<cffunction name="processInnerBeans" access="private" returntype="void" output="false">
		<cfargument name="innerBeanChildren" type="any" required="true" />
		<cfargument name="innerBean" type="MachII.util.BeanInfo" required="true" />
		
		<cfset var j = 0 />
		<cfset var newInnerBean = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.innerBeanChildren)#" index="j">
			<cfif arguments.innerBeanChildren[j].xmlName eq "field">
				<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "name")>
					<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "value")>
						<cfset arguments.innerBean.addFieldWithValue(arguments.innerBeanChildren[j].xmlAttributes["name"],
							arguments.innerBeanChildren[j].xmlAttributes["value"]) />
					<cfelse>
						<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "ignore")>
							<cfif arguments.innerBeanChildren[j].xmlAttributes["ignore"]>
								<cfset arguments.innerBean.addIgnoreField(arguments.innerBeanChildren[j].xmlAttributes["name"]) />
							</cfif>
						<cfelse>
							<cfset arguments.innerBean.addIncludeField(arguments.innerBeanChildren[j].xmlAttributes["name"]) />
						</cfif>
					</cfif>
				<cfelse>
					<cfthrow type="MachII.framework.CommandLoaderBase.InnerBeanFieldNameRequired"
						message="In event-bean field names are required for inner-bean '#arguments.innerBean.getName()#'" />
				</cfif>
			<cfelseif arguments.innerBeanChildren[j].xmlName eq "inner-bean">
				<!--- handle inner-beans that have inner-beans defined --->
				<cfset newInnerBean = CreateObject("component", "MachII.util.BeanInfo").init() />
				
				<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "name")>
					<cfset newInnerBean.setName(arguments.innerBeanChildren[j].xmlAttributes["name"]) />
				<cfelse>
					<cfthrow type="MachII.framework.CommandLoaderBase.InnerBeanNameRequired"
						message="A name is required for the inner-bean that is part of inner-bean." />
				</cfif>
				
				<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "prefix")>
					<cfset newInnerBean.setPrefix(arguments.innerBeanChildren[j].xmlAttributes["prefix"]) />
				<cfelse>
					<cfset newInnerBean.setPrefix("#arguments.innerBean.getName()#.#newInnerBean.getName()#") />
				</cfif>
				
				<cfif StructKeyExists(arguments.innerBeanChildren[j].xmlAttributes, "fields")>
					<cfset newInnerBean.setIncludeFields(variables.utils.trimList(arguments.innerBeanChildren[j].xmlAttributes["fields"])) />
				</cfif>
				
				<cfif ArrayLen(arguments.innerBeanChildren[j].xmlChildren)>
					<cfset processInnerBeans(arguments.innerBeanChildren[j].xmlChildren, newInnerBean) />
				</cfif>
				
				<cfset arguments.innerBean.addInnerBean(newInnerBean) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="setupRedirect" access="private" returntype="MachII.framework.commands.RedirectCommand" output="false"
		hint="Sets up a redirect command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = "" />
		<cfset var redirectUrl = "" />
		<cfset var moduleName = "" />
		<cfset var routeName = "" />
		<cfset var args = "" />
		<cfset var persist = false />
		<cfset var persistArgs = "" />
		<cfset var persistArgsIgnore = "" />
		<cfset var statusType = "temporary" />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "event")>
			<cfset eventName = arguments.commandNode.xmlAttributes["event"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "route")>
			<cfset routeName = arguments.commandNode.xmlAttributes["route"] />
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
		
		<!--- support adding arg and persist-arg tags inside redirect --->
		<cfloop from="1" to="#arrayLen(arguments.commandNode.xmlChildren)#" index="i">
			<cfif arguments.commandNode.xmlChildren[i].xmlName EQ "arg">
				<cfset args = ListAppend(args, 
					"#arguments.commandNode.xmlChildren[i].xmlAttributes["name"]#=#arguments.commandNode.xmlChildren[i].xmlAttributes["value"]#")>
			<cfelseif arguments.commandNode.xmlChildren[i].xmlName EQ "persist-arg">
				<cfset persistArgs = ListAppend(persistArgs, 
					"#arguments.commandNode.xmlChildren[i].xmlAttributes["name"]#=#arguments.commandNode.xmlChildren[i].xmlAttributes["value"]#")>		
			</cfif>
		</cfloop>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.RedirectCommand").init(eventName, moduleName, redirectUrl, args, persist, persistArgs, statusType, persistArgsIgnore, routeName) />
		
		<cfset command.setLog(variables.redirectCommandLog) />
		<cfset command.setExpressionEvaluator(variables.expressionEvaluator) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventArg" access="private" returntype="MachII.framework.commands.EventArgCommand" output="false"
		hint="Sets up an event-arg command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var command = "" />
		<cfset var argValue = "" />
		<cfset var argVariable = "" />
		<cfset var overwrite = true />
		<cfset var argName = arguments.commandNode.xmlAttributes["name"] />
		
		<cfif NOT StructKeyExists(arguments.commandNode.xmlAttributes, "value")>
			<cfset argValue = variables.utils.recurseComplexValues(arguments.commandNode) />
		<cfelse>
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
		<cfset command.setExpressionEvaluator(variables.expressionEvaluator) />
		<cfset command.setParentHandlerName(arguments.parentHandlerName) />
		<cfset command.setParentHandlerType(arguments.parentHandlerType) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupDefault" access="private" returntype="MachII.framework.Command" output="false"
		hint="Sets up a default command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var command = CreateObject("component", "MachII.framework.Command").init() />
		
		<cfset command.setParameter("commandName", arguments.commandNode.xmlName) />
		<cfset command.setParentHandlerName(arguments.parentHandlerName) />
		<cfset command.setParentHandlerType(arguments.parentHandlerType) />
		
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