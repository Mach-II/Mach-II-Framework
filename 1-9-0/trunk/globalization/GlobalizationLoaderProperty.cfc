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
A Mach-II property that provides easy configuration for Internationalization
and Resource Bundle management

Usage:
<property name="globalizationLoaderProperty" type="MachII.globalization.GlobalizationLoaderProperty">
	<parameters>
		<!-- Configures a string that will be output before any rendered message format -->
		<parameter name="debugPrefix" value="string"/>
		<!-- Configures a string that will be output after any rendered message format -->
		<parameter name="debugSuffix" value="string"/>
		<!-- Configures whether the debugging prefix and suffix will show up -->
		<parameter name="debuggingEnabled" value="true|false"

		<!-- The resource bundle declarations as list -->
		<parameter name="bundles" value="./config/resources/test,./config/resources/temp" />
		<!--- OR as an array --->
		<parameter name="bundles">
	  		<array>
	  			<!--- Defaults the charset to the one set in `bundleCharset` --->
	    		<element value="./config/resources/test" />
	    		<element>
	    			<struct>
	    				<key name="bundle" value="./config/resources/test" />
	    				<key name="charset" value="UTF-8" />
	    			</struct>
	    		</element>
	  		</array>
		</parameter>
		<parameter name="defaultCharset" value="ISO-8859-1" />
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
	displayname="GlobalizationLoaderProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Sets up property configurations for the GlobalizationManager.">

	<!---
	PROPERTIES
	--->
	<cfset variables.defaultCharset = "ISO-8859-1" />

	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="configure" access="public" output="false" returntype="void"
		hint="Configures the property.">

		<cfset var bundles = getParameter("bundles", ArrayNew(1)) />
		<cfset var modifiedBundles = ArrayNew(1) />
		<cfset var tempBundle = "" />
		<cfset var defaultCharset = getParameter("defaultCharset", variables.defaultCharset) />
		<cfset var i = 0 />
		<cfset var globalizationManager = getAppManager().getGlobalizationManager() />

		<cfset globalizationManager.setDebuggingEnabled(decideDebuggingEnabled(getParameter("debuggingEnabled", "false"))) />
		<cfset globalizationManager.setDebugPrefix(getParameter("debugPrefix", "**")) />
		<cfset globalizationManager.setDebugSuffix(getParameter("debugSuffix", "**")) />

		<cfset globalizationManager.setLocaleUrlParam(getParameter("localeUrlParam", "_locale")) />
		<cfset globalizationManager.setLocalePersistenceClass(getParameter("localePersistenceClass", "MachII.globalization.persistence.SessionPersistenceMethod")) />

		<cfif IsSimpleValue(bundles)>
			<cfset bundles = ListToArray(bundles) />
		</cfif>

		<!--- Add in charset if available --->
		<cfloop from="1" to="#ArrayLen(bundles)#" index="i">
			<cfif IsSimpleValue(bundles[i])>
				<cfset tempBundle = StructNew() />
				<cfset tempBundle.bundle = bundles[i] />
				<cfset tempBundle.charset = defaultCharset />

				<cfset modifiedBundles[i] = tempBundle />
			<cfelse>
				<cfset modifiedBundles[i] = bundles[i] />
			</cfif>
		</cfloop>

		<cfset globalizationManager.appendBasenames(modifiedBundles) />
	</cffunction>

	<cffunction name="deconfigure" access="public" output="false" returntype="void"
		hint="Deconfigures the property.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PROTECTED METHODS
	--->
	<cffunction name="decideDebuggingEnabled" access="private" returntype="boolean" output="false"
		hint="Decides if debugging is enabled.">
		<cfargument name="debuggingEnabled" type="any" required="true" />

		<cfset var result = false />

		<cfset getAssert().isTrue(IsBoolean(arguments.debuggingEnabled)
			OR IsStruct(arguments.debuggingEnabled), "The 'debuggingEnabled' parameter for 'GlobalizationLoaderProperty' in module '#getAppManager().getModuleName()#' must be boolean or a struct of environment names / groups.") />

		<!--- Load caching enabled since this is a simple value (no environment names / group) --->
		<cfif IsBoolean(arguments.debuggingEnabled)>
			<cfset result = arguments.debuggingEnabled />
			<!--- Load caching enabled by environment name / group --->
		<cfelse>
			<cfset result = resolveValueByEnvironment(arguments.debuggingEnabled, false) />
		</cfif>

		<cfreturn result />
	</cffunction>

</cfcomponent>
