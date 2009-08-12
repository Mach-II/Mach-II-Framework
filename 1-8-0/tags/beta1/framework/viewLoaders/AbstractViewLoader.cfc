<!---
License:
Copyright 2009 GreatBizTools, LLC

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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="AbstractViewLoader" 
	output="false" 
	hint="Abstract class for ViewLoaders.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parameters = StructNew() />
	<cfset variables.log = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractViewLoader" output="false"
		hint="Initializes the loader.">
		<cfargument name="appManager" type="MachII.framework.appManager" required="true"
			hint="The framework instances' AppManager." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The initial set of configuration parameters." />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setParameters(arguments.parameters) />
		
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
	<cffunction name="discoverViews" access="public" returntype="void" output="false"
		hint="Loads views based on defined parameters.">
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
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
	
	<cffunction name="getUtils" access="public" returntype="MachII.util.Utils" output="false"
		hint="Gets the Utils component.">
		<cfreturn getAppManager().getUtils() />
	</cffunction>
	
	<cffunction name="getAssert" access="public" returntype="MachII.util.Assert" output="false"
		hint="Gets the Assert component.">
		<cfreturn getAppManager().getAssert() />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the components AppManager instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Gets the components AppManager instance.">
		<cfreturn variables.appManager />
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
	
	<cffunction name="setLog" access="public" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="public" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>v

</cfcomponent>