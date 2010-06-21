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

Created version: 1.9.0

Notes:

--->
<cfcomponent
	displayname="AbstractEndpoint"
	extends="MachII.framework.BaseComponent"
	output="false"
	hint="">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.endpointManager = "" />
	<cfset variables.parameters = StructNew() />
	<cfset variables.parameterPrecedence = "form" />
	<cfset variables.targetPage = "" />
	<cfset variables.log = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AbstractEndpoint" output="false"
		hint="Initializes the endpoint. Do not override.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="A reference to the AppManager this endpoint was loaded from." />
		<cfargument name="endpointManager" type="MachII.framework.EndpointManager" required="true"
			hint="A reference to the EndpointManager." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="A struct of configure time parameters." />

		<!--- Run setters --->
		<cfset setAppManager(arguments.appManager) />
		<cfset setEndpointManager(arguments.endpointManager) />
		<cfset setParameters(arguments.parameters) />

		<!--- Setup additional --->
		<cfset setLog(getAppManager().getLogFactory()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the endpoint. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deconfigures the endpoint. Override to provide custom functionality.">
		<!--- Does nothing. Override to provide custom functionality. --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="preProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request begins. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<cffunction name="handleRequest" access="public" returntype="String" output="true"
		hint="Handles endpoint request. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<cffunction name="postProcess" access="public" returntype="void" output="false"
		hint="Runs when an endpoint request end. Override to provide custom functionality.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getRequestEventArgs" access="public" returntype="struct" output="false"
		hint="Builds a struct of incoming event args.">

		<cfset var eventArgs = StructNew() />
		<cfset var overwriteFormParams = (variables.instance.endpointConfig.parameterPrecedence EQ "url") />

		<!--- Build event args from form/url/SES --->
		<cfset StructAppend(eventArgs, form) />
		<cfset StructAppend(eventArgs, url, overwriteFormParams) />

		<cfreturn eventArgs />
	</cffunction>

	<!--- TODO: Implement method that introspects if
		preProcess / postProcess methods have been implemented
		in the endpoint because we shouldn't invoke those methods if they are not implemented --->

	<!--- TODO: Implement get/setProperty --->

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
			AND arguments.metadata.extends.name NEQ "MachII.endpoints.impl.AbstractEndpoint">
			<cfreturn isMethodDefined(arguments.methodName, arguments.metadata.extends) />
		<cfelse>
			<cfreturn false />
		</cfif>
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

	<cffunction name="setEndpointManager" access="public" returntype="void" output="false">
		<cfargument name="endpointManager" type="MachII.framework.EndpointManager" required="true" />
		<cfset variables.endpointManager = arguments.endpointManager />
	</cffunction>
	<cffunction name="getEndpointManager" access="public" returntype="MachII.framework.EndpointManager" output="false">
		<cfreturn variables.endpointManager />
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
	</cffunction>

</cfcomponent>