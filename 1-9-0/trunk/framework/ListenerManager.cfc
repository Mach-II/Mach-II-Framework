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

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="ListenerManager"
	output="false"
	hint="Manages registered Listeners for the framework instance.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentListenerManager = "" />
	<cfset variables.defaultInvoker = "" />
	<cfset variables.listenerProxies = StructNew() />
	<cfset variables.baseProxyTarget = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ListenerManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getListenerManager()) />
			<cfset setDefaultInvoker(getParent().getDefaultInvoker()) />
		<cfelse>
			<cfset setDefaultInvoker(CreateObject("component", "MachII.framework.invokers.EventInvoker").init()) />
		</cfif>

		<!--- Setup for duplicate for performance --->
		<cfset variables.baseProxyTarget = CreateObject("component",  "MachII.framework.BaseProxy") />

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var listenerNodes = ArrayNew(1) />
		<cfset var listenerParams = "" />
		<cfset var listenerName = "" />
		<cfset var listenerType = "" />
		<cfset var listener = "" />

		<cfset var paramNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var invokerType = "" />
		<cfset var invoker = "" />
		<cfset var instantiatedInvokers = StructNew() />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var baseProxy = "" />
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for listeners --->
		<cfif NOT arguments.override>
			<cfset listenerNodes = XMLSearch(arguments.configXML, "mach-ii/listeners/listener") />
		<cfelse>
			<cfset listenerNodes = XMLSearch(arguments.configXML, ".//listeners/listener") />
		</cfif>

		<!--- Setup up each Listener --->
		<cfloop from="1" to="#ArrayLen(listenerNodes)#" index="i">
			<cfset listenerName = listenerNodes[i].xmlAttributes["name"] />

			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(listenerNodes[i].xmlAttributes, "overrideAction")>
				<cfif listenerNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeListener(listenerName) />
				<cfelseif listenerNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(listenerNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = listenerNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = listenerName />
					</cfif>

					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isListenerDefined(mapping)>
						<cfthrow type="MachII.framework.overrideListenerNotDefined"
							message="An listener named '#mapping#' cannot be found in the parent listener manager for the override named '#listenerName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>

					<cfset addListener(listenerName, getParent().getListener(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<cfset listenerType = listenerNodes[i].xmlAttributes["type"] />

				<!--- Get the Listener's parameters --->
				<cfset listenerParams = StructNew() />

				<!--- Parse all the parameters --->
				<cfif StructKeyExists(listenerNodes[i], "parameters")>
					<cfset paramNodes = listenerNodes[i].parameters.xmlChildren />
					<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
						<cfset paramName = paramNodes[j].xmlAttributes["name"] />
						<cftry>
							<cfset paramValue = utils.recurseComplexValues(paramNodes[j]) />
							<cfcatch type="any">
								<cfthrow type="MachII.framework.InvalidParameterXml"
									message="Xml parsing error for the parameter named '#paramName#' for listener '#listenerName#' in module '#getAppManager().getModuleName()#'." />
							</cfcatch>
						</cftry>
						<cfset listenerParams[paramName] = paramValue />
					</cfloop>
				</cfif>

				<!--- Setup the Listener --->
				<cftry>
					<!--- Do not method chain the init() on the instantiation
						or objects that have their init() overridden will
						cause the variable the object is assigned to will
						be deleted if init() returns void --->
					<cfset listener = CreateObject("component", listenerType) />
					<cfset listener.init(getAppManager(), listenerParams) />

					<cfcatch type="any">
						<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ listenerType>
							<cfthrow type="MachII.framework.CannotFindListener"
								message="Cannot find a listener CFC with type of '#listenerType#' for the listener named '#listenerName#' in module named '#getAppManager().getModuleName()#'."
								detail="Please check that this listener exists and that there is not a misconfiguration in the XML configuration file." />
						<cfelse>
							<cfthrow type="MachII.framework.ListenerSyntaxException"
								message="Mach-II could not register a listener with type of '#listenerType#' for the listener named '#listenerName#' in module named '#getAppManager().getModuleName()#'."
								detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
						</cfif>
					</cfcatch>
				</cftry>

				<!--- Use declared invoker from config file --->
				<cfif StructKeyExists(listenerNodes[i], "invoker")>
					<cfset invokerType = listenerNodes[i].invoker.xmlAttributes["type"] />

					<!--- Uses the flyweight pattern to reduce the number of instantiations of invokers --->
					<cfif NOT StructKeyExists(instantiatedInvokers, Hash(invokerType))>
						<cftry>
							<cfset instantiatedInvokers[Hash(invokerType)] = CreateObject("component", invokerType).init() />

							<cfcatch type="any">
								<cfif StructKeyExists(cfcatch, "missingFileName")>
									<cfthrow type="MachII.framework.CannotFindInvoker"
										message="Cannot find an listener invoker CFC with type of '#invokerType#' for the listener named '#listenerName#' in module named '#getAppManager().getModuleName()#'."
										detail="Please check that the invoker exists for this listener and that there is not a misconfiguration in the XML configuration file." />
								<cfelse>
									<cfrethrow />
								</cfif>
							</cfcatch>
						</cftry>
					</cfif>

					<cfset invoker = instantiatedInvokers[Hash(invokerType)] />

				<!--- Use defaultInvoker --->
				<cfelse>
					<cfset invoker = getDefaultInvoker() />
				</cfif>

				<!--- Continue setup on the Listener --->
				<cfset listener.setInvoker(invoker) />

				<cfset baseProxy = Duplicate(variables.baseProxyTarget).init(listener, listenerType, listenerParams) />
				<cfset listener.setProxy(baseProxy) />

				<!--- Add the Listener to the manager --->
				<cfset addListener(listenerName, listener, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures each of the registered listeners and its' invoker.">

		<cfset var appManager = getAppManager() />
		<cfset var aListener = 0 />
		<cfset var i = 0 />

		<!--- Loop through the listeners configure --->
		<cfloop collection="#variables.listenerProxies#" item="i">
			<cfset aListener = variables.listenerProxies[i].getObject() />
			<cfset appManager.onObjectReload(aListener) />
			<cfset aListener.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Performs deconfigure logic.">

		<cfset var aListener = 0 />
		<cfset var i = 0 />

		<!--- Loop through the listeners configure --->
		<cfloop collection="#variables.listenerProxies#" item="i">
			<cfset aListener = variables.listenerProxies[i].getObject() />
			<cfset aListener.deconfigure() />
		</cfloop>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getListener" access="public" returntype="MachII.framework.Listener" output="false"
		hint="Gets a listener with the specified name.">
		<cfargument name="listenerName" type="string" required="true" />

		<cfif isListenerDefined(arguments.listenerName)>
			<cfreturn variables.listenerProxies[arguments.listenerName].getObject() />
		<cfelseif IsObject(getParent())>
			<cfreturn getParent().getListener(arguments.listenerName) />
		<cfelse>
			<cfthrow type="MachII.framework.ListenerNotDefined"
				message="Listener with name '#arguments.listenerName#' is not defined. Available Listeners: '#ArrayToList(getListenerNames())#'" />
		</cfif>
	</cffunction>

	<cffunction name="addListener" access="public" returntype="void" output="false"
		hint="Registers a listener with the specified name.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfargument name="listener" type="MachII.framework.Listener" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />

		<cfif NOT arguments.overrideCheck AND isListenerDefined(arguments.listenerName)>
			<cfthrow type="MachII.framework.ListenerAlreadyDefined"
				message="A Listener with name '#arguments.listenerName#' is already registered." />
		<cfelse>
			<cfset variables.listenerProxies[arguments.listenerName] = arguments.listener.getProxy() />
		</cfif>
	</cffunction>

	<cffunction name="removeListener" access="public" returntype="void" output="false"
		hint="Removes a listener. Does NOT remove from a parent.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfset StructDelete(variables.listenerProxies, arguments.listenerName, false) />
	</cffunction>

	<cffunction name="isListenerDefined" access="public" returntype="boolean" output="false"
		hint="Returns true if a listener is registered with the specified name. Does NOT check parent.">
		<cfargument name="listenerName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.listenerProxies, arguments.listenerName) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getListenerNames" access="public" returntype="array" output="false"
		hint="Returns an array of listener names.">
		<cfreturn StructKeyArray(variables.listenerProxies) />
	</cffunction>

	<cffunction name="reloadListener" access="public" returntype="void" output="false"
		hint="Reloads a listener.">
		<cfargument name="listenerName" type="string" required="true" />

		<cfset var newListener = "" />
		<cfset var currentListener = getListener(arguments.listenerName) />
		<cfset var baseProxy = currentListener.getProxy() />

		<!--- Setup the Listener --->
		<cftry>
			<!--- Do not method chain the init() on the instantiation
				or objects that have their init() overridden will
				cause the variable the object is assigned to will
				be deleted if init() returns void --->
			<cfset newListener = CreateObject("component", baseProxy.getType()) />
			<cfset newListener.init(getAppManager(), baseProxy.getOriginalParameters()) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ baseProxy.getType()>
					<cfthrow type="MachII.framework.CannotFindListener"
						message="Cannot find a listener CFC with type of '#baseProxy.getType()#' for the listener named '#arguments.listenerName#' in module named '#getAppManager().getModuleName()#'."
						detail="Please check that this listener exists and that there is not a misconfiguration in the XML configuration file." />
				<cfelse>
					<cfthrow type="MachII.framework.ListenerSyntaxException"
						message="Mach-II could not register a listener with type of '#baseProxy.getType()#' for the listener named '#arguments.listenerName#' in module named '#getAppManager().getModuleName()#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfif>
			</cfcatch>
		</cftry>

		<!--- Run deconfigure in the current Listener
			which must take place before configure is
			run in the new Listener --->
		<cfset currentListener.deconfigure() />

		<!--- Continue setup on the Listener --->
		<cfset newListener.setInvoker(currentListener.getInvoker()) />
		<cfset baseProxy.setObject(newListener) />
		<cfset newListener.setProxy(baseProxy) />

		<!--- Configure the listener --->
		<cfset getAppManager().onObjectReload(newListener) />
		<cfset newListener.configure() />

		<!--- Add the Listener to the manager --->
		<cfset addListener(arguments.listenerName, newListener, true) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false"
		hint="Returns the AppManager instance this ListenerManager belongs to.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Sets the AppManager instance this ListenerManager belongs to.">
		<cfreturn variables.appManager />
	</cffunction>

	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent ListenerManager instance this ListenerManager belongs to.">
		<cfargument name="parentListenerManager" type="MachII.framework.ListenerManager" required="true" />
		<cfset variables.parentListenerManager = arguments.parentListenerManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent ListenerManager instance this ListenerManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentListenerManager />
	</cffunction>

	<cffunction name="setDefaultInvoker" access="public" returntype="void" output="false"
		hint="Sets the default invoker.">
		<cfargument name="defaultInvoker" type="MachII.framework.ListenerInvoker" required="true" />
		<cfset variables.defaultInvoker = arguments.defaultInvoker />
	</cffunction>
	<cffunction name="getDefaultInvoker" access="public" returntype="MachII.framework.ListenerInvoker" output="false"
		hint="Get the default invoker.">
		<cfreturn variables.defaultInvoker />
	</cffunction>

</cfcomponent>