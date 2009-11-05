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
$Id: CacheCommand.cfc 595 2007-12-17 02:39:01Z kurtwiersma $

Created version: 1.6.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="CacheCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for performing caching.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "cache" />
	<cfset variables.handlerId = "" />
	<cfset variables.alias = "" />
	<cfset variables.strategyName = "" />
	<cfset variables.criteria = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="handlerId" type="string" required="false" default="" />
		<cfargument name="strategyName" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />

		<cfset setHandlerId(arguments.handlerId) />
		<cfset setAlias(arguments.alias) />
		<cfset setStrategyName(arguments.strategyName) />
		<cfset setCriteria(arguments.criteria) />
		
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="true"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = true />
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<cfset var cacheHandler = "" />
		<cfset var log = getLog() />
		
		<cfif log.isDebugEnabled()>
			<cfset log.debug("Cache-handler '#getHandlerId()#' in module named '#arguments.eventContext.getAppManager().getModuleName()#' beginning execution.") />
		</cfif>
		
		<cfset cacheHandler = cacheManager.getCacheHandler(getHandlerId()) />
		<cfset continue = cacheHandler.handleCache(arguments.event, arguments.eventContext) />

		<cfif log.isWarnEnabled() AND NOT continue>
			<cfset log.warn("Cache-handler '#getHandlerId()#' has changed the flow of this event.") />
		</cfif>

		<cfif log.isDebugEnabled()>
			<cfset log.debug("Cache-handler '#getHandlerId()#' in module named '#arguments.eventContext.getAppManager().getModuleName()#' has ended.") />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setHandlerId" access="private" returntype="void" output="false">
		<cfargument name="handlerId" type="string" required="true" />
		<cfset variables.handlerId = arguments.handlerId />
	</cffunction>
	<cffunction name="getHandlerId" access="private" returntype="string" output="false">
		<cfreturn variables.handlerId />
	</cffunction>
	
	<cffunction name="setAlias" access="private" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="private" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>
	
	<cffunction name="setStrategyName" access="private" returntype="void" output="false">
		<cfargument name="strategyName" type="string" required="true" />
		<cfset variables.strategyName = arguments.strategyName />
	</cffunction>
	<cffunction name="getStrategyName" access="private" returntype="string" output="false">
		<cfreturn variables.strategyName />
	</cffunction>
	
	<cffunction name="setCriteria" access="private" returntype="void" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = arguments.criteria />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false">
		<cfreturn variables.criteria />
	</cffunction>

</cfcomponent>