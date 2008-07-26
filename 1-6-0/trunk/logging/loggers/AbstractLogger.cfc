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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="AbstractLogger"
	output="false"
	hint="A logger that configures a logging adapter and performs output of the results if necessary. This is abstract and must be extend by a concrete logger implementation.">

	<!---
	PROPERTIES
	--->
	<cfset variables.loggerType = "undefined" />
	<cfset variables.loggerId = "" />
	<cfset variables.logFactory = "" />
	<cfset variables.logAdapter = "" />
	<cfset variables.parameters = StructNew() />
	
	<!---
	INITIAlIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractLogger" output="false"
		hint="Initializes the logger. Do not override.">
		<cfargument name="loggerId" type="string" required="true" />
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset setLoggerId(arguments.loggerId) />
		<cfset setLogFactory(arguments.logFactory) />
		<cfset setParameters(arguments.parameters) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onRequestEnd" access="public" returntype="void" 
		hint="On request end logic for this logger. Override to provide custom on request end logic.">
		<!--- Note that leaving off the 'output' attribute requires all output to be
			surrounded by cfoutput tags --->
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
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="isOnRequestEndAvailable" access="public" returntype="boolean" output="false"
		hint="Checks if on request end method is available.">
		<cfreturn isMethodDefined("onRequestEnd") />
	</cffunction>
	
	<cffunction name="isPrePostRedirectAvailable" access="public" returntype="boolean" output="false"
		hint="Checks if pre/post-redirect methods are available.">
		<cfreturn isMethodDefined("preRedirect") AND isMethodDefined("postRedirect") />
	</cffunction>
	
	<cffunction name="disableLogging" access="public" returntype="void" output="false"
		hint="Disables logging. Convenience method for dashboard.">
		<cfset getLogAdapter().setLoggingEnabled(false) />
	</cffunction>
	<cffunction name="enableLogging" access="public" returntype="void" output="false"
		hint="Enables logging. Convenience method for dashboard.">
		<cfset getLogAdapter().setLoggingEnabled(true) />
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
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="isMethodDefined" access="private" returntype="boolean" output="false"
		hint="Checks if an abstract function was overridden in the concrete class. Does not walk the inheritance tree.">
		<cfargument name="methodName" type="string" required="true" />

		<cfset var md = GetMetadata(this) />
		<cfset var methods = ArrayNew(1) />
		<cfset var i = 0 />
		<cfset var result = false />
		
		<!--- "functions" key only exists when there at least one defined method --->
		<cfif StructKeyExists(md, "functions")>
			<cfset methods = md.functions />
			
			<!--- Find if the method exists --->
			<cfloop from="1" to="#ArrayLen(methods)#" index="i">
				<cfif methods[i].name EQ arguments.methodName>
					<cfset result = true />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />		
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="getLoggerType" access="public" returntype="string" output="false"
		hint="Returns the type of the logger. Required for Dashboard integration.">
		<cfreturn variables.loggerType />
	</cffunction>

	<cffunction name="setLoggerId" access="private" returntype="void" output="false"
		hint="Sets the id of the logger.">
		<cfargument name="loggerId" type="string" required="true" />
		<cfset variables.loggerId = arguments.loggerId />
	</cffunction>
	<cffunction name="getLoggerId" access="public" returntype="string" output="false"
		hint="Returns the id of the logger. Used for preRedirect/postRedirect id.">
		<cfreturn variables.loggerId />
	</cffunction>
	
	<cffunction name="setLogFactory" access="private" returntype="void" output="false"
		hint="Sets the log factory for this logger.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.logFactory = arguments.logFactory />
	</cffunction>
	<cffunction name="getLogFactory" access="private" returntype="MachII.logging.LogFactory" output="false"
		hint="Gets the log factory for this logger.">
		<cfreturn variables.logFactory />
	</cffunction>
	
	<cffunction name="setLogAdapter" access="private" returntype="void" output="false"
		hint="Sets the log adapter for this logger.">
		<cfargument name="logAdapter" type="MachII.logging.adapters.AbstractLogAdapter" required="true" />
		<cfset variables.logAdapter = arguments.logAdapter />
	</cffunction>
	<cffunction name="getLogAdapter" access="private" returntype="MachII.logging.adapters.AbstractLogAdapter" output="false"
		hint="Gets the log adapter for this logger.">
		<cfreturn variables.logAdapter />
	</cffunction>
	
	<cffunction name="setParameters" access="public" returntype="void" output="false"
		hint="Sets the full set of configuration parameters for the component.">
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset var key = "" />
		
		<cfloop collection="#arguments.parameters#" item="key">
			<cfset setParameter(key, parameters[key]) />
		</cfloop>
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false"
		hint="Gets the full set of configuration parameters for the component.">
		<cfreturn variables.parameters />
	</cffunction>

</cfcomponent>