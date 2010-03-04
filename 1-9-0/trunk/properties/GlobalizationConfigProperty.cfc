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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:
A Mach-II property that provides easy configuration for Internationalization
and Resource Bundle management

Usage:
<property name="globalizationConfigProperty" type="MachII.properties.GlobalizationConfigProperty">
	<parameters>
		<!-- Configures a string that will be output before any rendered message format -->
		<parameter name="debugPrefix" value="string"/>
		<!-- Configures a string that will be output after any rendered message format -->
		<parameter name="debugSuffix" value="string"/>
		<!-- Configures whether the debugging prefix and suffix will show up -->
		<parameter name="debugEnabled" value="true|false"
		<!-- The resource bundle declarations. -->
		<parameter name="bundles">
	  		<array>
	    		<element value="./config/resources/test"/>
	  		</array>
		</parameter>
	</parameters>
</property>

The [bundles] parameter value is the partial path and name of a Java
.properties file that contains key/value pairs representative of the
localized data strings necessary to write an internationalized application.
"Partial path" means that there needs to be a file at (in the case above)
ExpandPath(./config/resources/test_en_US.properties), if the default locale
is en_US.

--->
<cfcomponent
	displayname="GlobalizationConfigProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets up property configurations for the GlobalizationManager">

	<!---
	PROPERTIES
	--->
	<cfset variables.debugMode = false/>
	<cfset variables.debugPrefix = "**"/>
	<cfset variables.debugSuffix = "**"/>

	<cfset variables.messageSource = ""/>
	
	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="configure" access="public" output="false" returntype="void"
		hint="Initializes the property.">
		
		<cfset var bundles = getParameter("bundles", ArrayNew(1))/>
		<cfset var i = 0/>

		<cfset setDebugEnabled(getParameter("debugEnabled", "false"))/>
		<cfset setDebugPrefix(getParameter("debugPrefix", "**"))/>
		<cfset setDebugSuffix(getParameter("debugSuffix", "**"))/>
		
		<cfif IsSimpleValue(bundles)>
			<cfset bundles = ListToArray(bundles)/>
		</cfif>
		
		<cfset variables.messageSource = createobject("component", "MachII.globalization.ResourceBundleMessageSource").init(bundles)/>
		<cfset variables.messageSource.setLog(getAppManager().getLogFactory())/>
		
		<cfset getAppManager().getGlobalizationManager().setGlobalizationConfigProperty(this)/>
	</cffunction>
	
	<!---
	ACCESSORS
	--->
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

	<cffunction name="setDebugEnabled" access="public" returntype="void" output="false">
		<cfargument name="debugEnabled" type="any" required="true" />
		<cftry>
			<cfset getAssert().isTrue(IsBoolean(arguments.debugEnabled) OR IsStruct(arguments.debugEnabled), "The 'debugEnabled' parameter for 'CachingProperty' in module '#getAppManager().getModuleName()#' must be boolean or a struct of environment names / groups.") />

			<!--- Load caching enabled since this is a simple value (no environment names / group) --->
			<cfif IsBoolean(arguments.debugEnabled)>
				<cfset variables.debugEnabled = arguments.debugEnabled />
				<!--- Load caching enabled by environment name / group --->
			<cfelse>
				<cfset variables.debugEnabled = resolveValueByEnvironment(arguments.debugEnabled, true) />
			</cfif>

			<cfcatch type="MachII.util.IllegalArgument">
				<cfthrow type="MachII.properties.ResourceBundleLoaderProperty.invalidEnvironmentConfiguration"
					message="This misconfiguration error is defined in the property-wide 'debugEnabled' parameter in the 'ResourceLoaderProperty' in module named '#getModuleName()#'."
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>			
		</cftry>
	</cffunction>
	<cffunction name="getDebugEnabled" access="public" returntype="boolean" output="false">
		<cfreturn variables.debugEnabled />
	</cffunction>
	
	<cffunction name="setMessageSource" access="public" returntype="void" output="false">
		<cfargument name="messageSource" type="MachII.globalization.BaseMessageSource" required="true"/>
		<cfset variables.messageSource = arguments.messageSource/>
	</cffunction>
	<cffunction name="getMessageSource" access="public" returntype="MachII.globalization.BaseMessageSource" required="true">
		<cfreturn variables.messageSource/>
	</cffunction>
	
</cfcomponent>