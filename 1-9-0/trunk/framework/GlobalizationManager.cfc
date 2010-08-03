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
	<cfset variables.globalizationLoaderProperty = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="GlobalizationManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getGlobalizationManager()) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the manager.">
		<!--- DOES NOTHING --->
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the manager.">
		<!--- DOES NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getString" access="public" returntype="string" output="false">
		<cfargument name="code" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />
		<cfargument name="args" type="array" required="true" />
		<cfargument name="defaultString" type="string" required="true" />
		
		<cfset var currentLocale = arguments.locale/>
		<!--- If the user doesn't specify a locale, use the one for the current request --->
		<cfif currentLocale EQ "">
			<cfset currentLocale = getAppManager().getRequestManager().getRequestHandler().getCurrentLocale()/>
		</cfif>
		
		<cfreturn getGlobalizationLoaderProperty().getMessageSource().getMessage(arguments.code, arguments.args, currentLocale, arguments.defaultString) />
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
	<cffunction name="getParent" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.parentGlobalizationManager />
	</cffunction>
	
	<cffunction name="setGlobalizationLoaderProperty" access="public" returntype="void" output="false">
		<cfargument name="globalizationLoaderProperty" type="MachII.globalization.GlobalizationLoaderProperty" required="true" />
		<cfset variables.globalizationLoaderProperty = arguments.globalizationLoaderProperty />
	</cffunction>
	<cffunction name="getGlobalizationLoaderProperty" access="public" returntype="MachII.globalization.GlobalizationLoaderProperty" output="true">
		<cfreturn variables.globalizationLoaderProperty />
	</cffunction>
	
</cfcomponent>