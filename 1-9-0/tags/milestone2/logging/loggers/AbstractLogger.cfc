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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.8.0

Notes:
When implementing a logger, do not implement onRequestEnd, onRedirectStart
and onRedirectEnd method unless required. Mach-II introspecs your logger and
only executes methods that have been implemented in order to increase performance.
--->
<cfcomponent
	displayname="AbstractLogger"
	output="false"
	hint="A logger that configures a logging adapter and performs output of the results if necessary. This is abstract and must be extend by a concrete logger implementation.">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />
	<cfset variables.instance.loggerTypeName = "undefined" />
	<cfset variables.instance.loggerId = "" />
	<cfset variables.logAdapter = "" />
	<cfset variables.parameters = StructNew() />
	<cfset variables.assert = "" />

	<!---
	INITIAlIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractLogger" output="false"
		hint="Initializes the logger. Do not override.">
		<cfargument name="loggerId" type="string" required="true"
			hint="The unique id for this logger." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="A struct of configure time parameters." />

		<!--- Run setters --->
		<cfset setLoggerId(arguments.loggerId) />
		<cfset setParameters(arguments.parameters) />
		<cfset setAssert(CreateObject("component", "MachII.util.Assert").init()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Does nothing --->
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Override to provide custom deconfiguration logic. Also called when target object is reloaded.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void" output="true"
		hint="On request end logic for this logger. Override to provide custom on request end logic.">
		<cfabort showerror="This method is abstract and must be overrided if onRequestEnd functionality is required." />
	</cffunction>

	<cffunction name="preRedirect" access="public" returntype="void" output="false"
		hint="Pre-redirect logic for this logger. Override to provide custom pre-redirect logic. Must be overriden in unison with postRedirect.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />
		<cfabort showerror="This method is abstract and must be overrided if preRedirect functionality is required." />
	</cffunction>

	<cffunction name="postRedirect" access="public" returntype="void" output="false"
		hint="Post-redirect logic for this logger. Override to provide custom post-redirect logic. Must be overriden in unison with preRedirect.">
		<cfargument name="data" type="struct" required="true"
			hint="Redirect persist data struct." />
		<cfabort showerror="This method is abstract and must be overrided if postRedirect functionality is required." />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="isOnRequestEndAvailable" access="public" returntype="boolean" output="false"
		hint="Checks if on request end method is available.">
		<cfreturn isMethodDefined("onRequestEnd") />
	</cffunction>

	<cffunction name="isPrePostRedirectAvailable" access="public" returntype="boolean" output="false"
		hint="Checks if pre/post-redirect methods are available.">

		<cfset var preRedirectResult = isMethodDefined("preRedirect") />
		<cfset var postRedirectResult = isMethodDefined("postRedirect") />
		<cfset var result = false />

		<cfif preRedirectResult AND postRedirectResult>
			<cfset result = true />
		<cfelseif preRedirectResult + postRedirectResult EQ 1>
			<cfthrow type="MachII.logging.loggers.bothPrePostRedirectMethodsRequired"
				message="Both PreRedirect and PostRedirect methods must be implemented in '#getLoggerId()#'."
				detail="Available Methods: preRedirectResult=#preRedirectResult#, postRedirectResult=#postRedirectResult#" />
		</cfif>

		<cfreturn result />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets pretty configuration data for this logger. Override for better Dashboard integration data.">

		<cfset var data = variables.instance />

		<cfset data.adapter = getLogAdapter().getConfigurationData() />

		<cfreturn data />
	</cffunction>

	<cffunction name="setParameter" access="public" returntype="void" output="false"
		hint="Sets a configuration parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" type="any" required="true"
			hint="The parameter value." />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" output="false"
		hint="Gets a configuration parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to return if the parameter is not defined. Defaults to a blank string." />
		<cfif isParameterDefined(arguments.name)>
			<cfreturn variables.parameters[arguments.name] />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>
	</cffunction>
	<cffunction name="isParameterDefined" access="public" returntype="boolean" output="false"
		hint="Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>
	<cffunction name="getParameterNames" access="public" returntype="string" output="false"
		hint="Returns a comma delimited list of parameter names.">
		<cfreturn StructKeyList(variables.parameters) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="isMethodDefined" access="private" returntype="boolean" output="false"
		hint="Checks if an abstract function was overridden in the concrete class. This method is recursive and will walk the inheritance tree.">
		<cfargument name="methodName" type="string" required="true"
			hint="Method name to look for in metadata" />
		<cfargument name="metadata" type="any" required="false" default="#GetMetadata(this)#"
			hint="Metadata to search for method name." />

		<cfset var methods = ArrayNew(1) />
		<cfset var i = 0 />
		<cfset var result = false />

		<!--- "functions" key only exists when there at least one defined method --->
		<cfif StructKeyExists(arguments.metadata, "functions")>
			<cfset methods = arguments.metadata.functions />

			<!--- Find if the method exists --->
			<cfloop from="1" to="#ArrayLen(methods)#" index="i">
				<cfif methods[i].name EQ arguments.methodName>
					<!--- Typically, we don't shortcircuit returns but it is easier in recursive functions --->
					<cfreturn true />
				</cfif>
			</cfloop>
		</cfif>

		<!--- Method is not at this level so walk inheritance tree if possible --->
		<cfif StructKeyExists(arguments.metadata, "extends")
			AND arguments.metadata.extends.name NEQ "MachII.logging.loggers.AbstractLogger">
			<cfreturn isMethodDefined(arguments.methodName, arguments.metadata.extends) />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setLoggingLevel" access="public" returntype="string" output="false"
		hint="Sets the logging level by name.">
		<cfargument name="loggingLevelName" type="string" required="true"
			hint="Accepts 'trace', 'debug', 'info', 'warn', 'error', 'fatal', 'all' or 'off'." />
		<cfset getLogAdapter().setLoggingLevel(arguments.loggingLevelName) />
	</cffunction>
	<cffunction name="getLoggingLevel" access="public" returntype="string" output="false"
		hint="Returns the logging level by name.">
		<cfreturn getLogAdapter().getLoggingLevel() />
	</cffunction>

	<cffunction name="setLoggingEnabled" access="public" returntype="void" output="false"
		hint="Sets logging. Convenience method for dashboard.">
		<cfargument name="loggingEnabled" type="boolean" required="true" />
		<cfset getLogAdapter().setLoggingEnabled(arguments.loggingEnabled) />
	</cffunction>
	<cffunction name="isLoggingEnabled" access="public" returntype="boolean" output="false"
		hint="Checkes if logging is currently enabled.">
		<cfreturn getLogAdapter().getLoggingEnabled() />
	</cffunction>

	<cffunction name="getLoggerTypeName" access="public" returntype="string" output="false"
		hint="Returns the type name of the logger. Required for Dashboard integration.">
		<cfreturn variables.instance.loggerTypeName />
	</cffunction>
	<cffunction name="getLoggerType" access="public" returntype="string" output="false"
		hint="Returns the dot path type of the logger. Required for Dashboard integration.">
		<cfreturn GetMetadata(this).name />
	</cffunction>

	<cffunction name="setLoggerId" access="private" returntype="void" output="false"
		hint="Sets the id of the logger.">
		<cfargument name="loggerId" type="string" required="true" />
		<cfset variables.instance.loggerId = arguments.loggerId />
	</cffunction>
	<cffunction name="getLoggerId" access="public" returntype="string" output="false"
		hint="Returns the id of the logger. Used for preRedirect/postRedirect id.">
		<cfreturn variables.instance.loggerId />
	</cffunction>

	<cffunction name="setLogAdapter" access="private" returntype="void" output="false"
		hint="Sets the log adapter for this logger.">
		<cfargument name="logAdapter" type="MachII.logging.adapters.AbstractLogAdapter" required="true" />
		<cfset variables.logAdapter = arguments.logAdapter />
	</cffunction>
	<cffunction name="getLogAdapter" access="public" returntype="MachII.logging.adapters.AbstractLogAdapter" output="false"
		hint="Gets the log adapter for this logger.">
		<cfreturn variables.logAdapter />
	</cffunction>

	<cffunction name="setAssert" access="private" returntype="void" output="false"
		hint="Sets the assert utility.">
		<cfargument name="assert" type="MachII.util.Assert" required="true" />
		<cfset variables.assert = arguments.assert />
	</cffunction>
	<cffunction name="getAssert" access="public" returntype="MachII.util.Assert" output="false"
		hint="Gets the assert utility.">
		<cfreturn variables.assert />
	</cffunction>

	<cffunction name="setParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of configuration parameters for the component.">
		<cfargument name="parameters" type="struct" required="true" />

		<cfset var key = "" />

		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, arguments.parameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of configuration parameters for the component.">
		<cfreturn variables.parameters />
	</cffunction>

</cfcomponent>