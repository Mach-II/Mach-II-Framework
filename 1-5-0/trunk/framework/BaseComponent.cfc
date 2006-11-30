<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
$Id: BaseComponent.cfc 4466 2006-09-15 16:43:50Z pfarrell $

Created version: 1.0.10
Updated version: 1.1.0

MachComponent:
Base Mach-II component.

Notes:
The BaseComponent extended by Listener, EventFilter and Plugin components and gives
quick access to things such as announcing a new event or getting/setting properties.

- Implemented accessors to access the PropertyManager instead of direct name space
calling. (pfarrell)
- Deprecated hasParameter(). Duplicate method isParameterDefined is more inline with
the rest of the framework. (pfarrell)
--->
<cfcomponent
	displayname="Mach-II Base Component"
	output="false"
	hint="Base Mach-II component.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parameters = StructNew() />
	<cfset variables.propertyManager = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The framework instances' AppManager." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="The initial set of configuration parameters." />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset setParameters(arguments.parameters) />
		<cfset setPropertyManager(getAppManager().getPropertyManager()) />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Override to provide custom configuration logic. Called after init(). --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->	
	<cffunction name="announceEvent" access="public" returntype="void" output="false"
		hint="Announces a new event to the framework.">
		<cfargument name="eventName" type="string" required="true"
			hint="The name of the event to announce." />
		<cfargument name="eventArgs" type="struct" required="false" default="#StructNew()#"
			hint="A struct of arguments to set as the event's args." />
		
		<cfif StructKeyExists(request, "eventContext")>
			<cfset request.eventContext.announceEvent(arguments.eventName, arguments.eventArgs) />
		<cfelse>
			<cfthrow message="The EventContext necessary to announce events is not set in 'request.eventContext.'" />
		</cfif>
	</cffunction>
	
	<cffunction name="setParameter" access="public" returntype="void" output="false"
		hint="Sets a configuration parameter.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="value" required="true"
			hint="The parameter value." />
		<cfset variables.parameters[arguments.name] = arguments.value />
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" output="false"
		hint="Gets a configuration parameter value, or a default value if not defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfargument name="defaultValue" type="string" required="false" default=""
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
	<cffunction name="hasParameter" access="public" returntype="boolean" output="false"
		hint="DEPRECATED - use isParameterDefined() instead. Checks to see whether or not a configuration parameter is defined.">
		<cfargument name="name" type="string" required="true"
			hint="The parameter name." />
		<cfreturn StructKeyExists(variables.parameters, arguments.name) />
	</cffunction>

	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Gets the specified property - this is just a shortcut for getAppManager().getPropertyManager().getProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to return."/>
		<cfreturn getPropertyManager().getProperty(arguments.propertyName) />
	</cffunction>
	<cffunction name="setProperty" access="public" returntype="any" output="false"
		hint="Sets the specified property - this is just a shortcut for getAppManager().getPropertyManager().setProperty()">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to set."/>
		<cfargument name="propertyValue" type="any" required="true" 
			hint="The value to store in the property." />
		<cfreturn getPropertyManager().setProperty(arguments.propertyName, arguments.propertyValue) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
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
	
	<cffunction name="setAppManager" access="private" returntype="void" output="false"
		hint="Sets the components AppManager instance.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager instance to set." />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="package" returntype="MachII.framework.AppManager" output="false"
		hint="Gets the components AppManager instance.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setPropertyManager" access="private" returntype="void" output="false"
		hint="Sets the components PropertyManager instance.">
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true"
			hint="The PropertyManager instance to set." />
		<cfset variables.propertyManager = arguments.propertyManager />
	</cffunction>
	<cffunction name="getPropertyManager" access="package" returntype="MachII.framework.PropertyManager" output="false"
		hint="Gets the components PropertyManager instance.">
		<cfreturn variables.propertyManager />
	</cffunction>	

</cfcomponent>