<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

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
	modules, and to copy and distribute the resultant executable under 
	the terms of your choice, provided that you also meet, for each linked 
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from 
	or based on this library and communicates with Mach-II solely through 
	the public interfaces* (see definition below). If you modify this library, 
	but you may extend this exception to your version of the library, 
	but you are not obligated to do so. If you do not wish to do so, 
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on 
	this library with the exception of independent module components that 
	extend certain Mach-II public interfaces (see README for list of public 
	interfaces).

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="GlobalizationManager"
	output="false"
	hint="Manages globalization for the framework">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentGlobalizationManager = "" />
	<cfset variables.messageSource = "" />
	<cfset variables.localePersistenceObject = "" />
	<cfset variables.debuggingEnabled = false />
	<cfset variables.debugPrefix = "**" />
	<cfset variables.debugSuffix = "**" />
	<cfset variables.localeUrlParam = "_locale" />
	<cfset variables.localePersistenceClass = "MachII.globalization.persistence.SessionPersistenceMethod" />
	<cfset variables.numberFormatter = CreateObject("java", "java.text.NumberFormat") />
	<cfset variables.dateFormatter = CreateObject("java", "java.text.DateFormat") />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="GlobalizationManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset var localePersistenceObject = "" />
		
		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getGlobalizationManager()) />

			<cfset localePersistenceObject = getParent().getLocalePersistenceObject() />
			<cfset variables.messageSource = CreateObject("component", "MachII.globalization.ResourceBundleMessageSource").init(getParent().getMessageSource()) />
		<cfelse>
			<cftry>			
				<cfset localePersistenceObject = CreateObject("component", getLocalePersistenceClass()).init(arguments.appManager) />

				<cfcatch type="any">
					<cfthrow type="MachII.framework.GlobalizationManager.InvalidLocalePersistenceObject"
						message="Unable to create LocalePersistenceObject of type '#getLocalePersistenceClass()#'. Please check that this type is extended from 'MachII.globalization.persistence.AbstractPersistenceMethod'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
			</cftry>

			<cfset variables.messageSource = CreateObject("component", "MachII.globalization.ResourceBundleMessageSource").init() />
		</cfif>
		<cfset variables.messageSource.setLog(getAppManager().getLogFactory()) />		
		<cfset setLocalePersistenceObject(localePersistenceObject) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the manager and related functionality.">

		<cfif NOT IsObject(getParent())>
			<cfset getLocalePersistenceObject().configure() />
		</cfif>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the manager and related functionality.">

		<cfif NOT IsObject(getParent())>
			<cfset getLocalePersistenceObject().deconfigure() />
		</cfif>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getString" access="public" returntype="string" output="false"
		hint="">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />
		<cfargument name="args" type="array" required="true" />
		<cfargument name="defaultString" type="string" required="true" />
		
		<cfset var currentLocale = arguments.locale />
		
		<!--- If the user doesn't specify a locale, use the one for the current request --->
		<cfif NOT IsObject(currentLocale) AND NOT Len(currentLocale)>
			<cfset currentLocale = getAppManager().getRequestManager().getRequestHandler().getCurrentLocale() />
		</cfif>
		
		<cfif isDebuggingEnabled()>	
			<cfreturn getDebugPrefix() & getMessageSource().getMessage(arguments.code, arguments.args, currentLocale, arguments.defaultString) & getDebugSuffix() />
		<cfelse>
			<cfreturn getMessageSource().getMessage(arguments.code, arguments.args, currentLocale, arguments.defaultString) />
		</cfif>
	</cffunction>
	
	<cffunction name="persistLocale" access="public" returntype="void" output="false"
		hint="Persists the passed locale as the user's current locale for this 'session'.">
		<cfargument name="locale" type="string" required="true" />
		<cfset getLocalePersistenceObject().storeLocale(arguments.locale) />
	</cffunction>
	
	<cffunction name="retrieveLocale" access="public" returntype="string" output="false"
		hint="Retrieves the current locale as set by the user.">
		<cfreturn getLocalePersistenceObject().retrieveLocale() />
	</cffunction>
	
	<cffunction name="appendBasenames" access="public" returntype="void" output="false"
		hint="Appends base names to the message source.">
		<cfargument name="basenames" type="array" required="true" />
		<cfset getMessageSource().appendBasenames(arguments.basenames) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="parentManager" type="MachII.framework.GlobalizationManager" required="true" />
		<cfset variables.parentGlobalizationManager = arguments.parentManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false">
		<cfreturn variables.parentGlobalizationManager />
	</cffunction>
	
	<cffunction name="setLocalePersistenceObject" access="public" returntype="void" output="false">
		<cfargument name="localePersistenceObject" type="MachII.globalization.persistence.AbstractPersistenceMethod" required="true" />
		<cfset variables.localePersistenceObject = arguments.localePersistenceObject />
	</cffunction>
	<cffunction name="getLocalePersistenceObject" access="public" returntype="MachII.globalization.persistence.AbstractPersistenceMethod" output="false">
		<cfreturn variables.localePersistenceObject />
	</cffunction>

	<cffunction name="setDebugPrefix" access="public" returntype="void" output="false">
		<cfargument name="debugPrefix" type="string" required="true" />
		<cfset variables.debugPrefix = arguments.debugPrefix />
	</cffunction>
	<cffunction name="getDebugPrefix" access="public" returntype="string" output="false">
		<cfreturn variables.debugPrefix />
	</cffunction>

	<cffunction name="setDebugSuffix" access="public" returntype="void" output="false">
		<cfargument name="debugSuffix" type="string" required="true" />
		<cfset variables.debugSuffix = arguments.debugSuffix />
	</cffunction>
	<cffunction name="getDebugSuffix" access="public" returntype="string" output="false">
		<cfreturn variables.debugSuffix />
	</cffunction>

	<cffunction name="setDebuggingEnabled" access="public" returntype="void" output="false">
		<cfargument name="debuggingEnabled" type="boolean" required="true" />
		<cfset variables.debuggingEnabled />
	</cffunction>
	<cffunction name="isDebuggingEnabled" access="public" returntype="boolean" output="false">
		<cfreturn variables.debuggingEnabled />
	</cffunction>

	<cffunction name="setMessageSource" access="public" returntype="void" output="false">
		<cfargument name="messageSource" type="MachII.globalization.BaseMessageSource" required="true"/>
		<cfset variables.messageSource = arguments.messageSource />
	</cffunction>
	<cffunction name="getMessageSource" access="public" returntype="MachII.globalization.BaseMessageSource"  output="false">
		<cfreturn variables.messageSource />
	</cffunction>
	
	<cffunction name="setLocaleUrlParam" access="public" returntype="void" output="false">
		<cfargument name="localeUrlParam" type="string" required="true"/>
		<cfset variables.localeUrlParam = arguments.localeUrlParam />
	</cffunction>
	<cffunction name="getLocaleUrlParam" access="public" returntype="string" output="false">
		<cfreturn variables.localeUrlParam />
	</cffunction>
	
	<cffunction name="setLocalePersistenceClass" access="public" returntype="void" output="false">
		<cfargument name="localePersistenceClass" type="string" required="true"/>
		<cfset variables.localePersistenceClass = arguments.localePersistenceClass />
	</cffunction>
	<cffunction name="getLocalePersistenceClass" access="public" returntype="string" output="false">
		<cfreturn variables.localePersistenceClass />
	</cffunction>

</cfcomponent>