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
Updated version: 1.8.1

Notes:
--->
<cfcomponent
	displayname="PropertyManager"
	output="false"
	hint="Manages defined properties for the framework.">

	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.properties = StructNew() />
	<cfset variables.configurablePropertyNames = ArrayNew(1) />
	<cfset variables.parentPropertyManager = "">
	<cfset variables.majorVersion = "1.8.1" />
	<cfset variables.minorVersion = "@minorVersion@" />
	<cfset variables.propsNotAllowInModule =
		 "eventParameter,parameterPrecedence,maxEvents,redirectPersistParameter,redirectPersistScope,redirectPersistParameterLocation,moduleDelimiter,urlBase,urlDelimiters,urlParseSES,urlExcludeEventParameter" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PropertyManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />

		<cfset setAppManager(arguments.appManager) />

		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getPropertyManager()) />
		</cfif>

		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory()) />

		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />

		<cfset var propertyNodes = ArrayNew(1) />
		<cfset var propertyName = "" />
		<cfset var propertyValue = "" />
		<cfset var propertyType = "" />
		<cfset var propertyParams = "" />

		<cfset var paramsNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var baseProxy = "" />
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var utils = getAppManager().getUtils() />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for properties --->
		<cfif NOT arguments.override>
			<cfset propertyNodes = XMLSearch(arguments.configXML, "mach-ii/properties/property") />
		<cfelse>
			<cfset propertyNodes = XMLSearch(arguments.configXML, ".//properties/property") />
		</cfif>

		<!--- Set the properties from the XML file. --->
		<cfloop from="1" to="#ArrayLen(PropertyNodes)#" index="i">
			<cfset propertyName = propertyNodes[i].xmlAttributes["name"] />

			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(propertyNodes[i].xmlAttributes, "overrideAction")>
				<cfif propertyNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeProperty(propertyName) />
				<cfelseif propertyNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(propertyNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = propertyNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = propertyName />
					</cfif>

					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isPropertyDefined(mapping)>
						<cfthrow type="MachII.framework.overridePropertyNotDefined"
							message="An property named '#mapping#' cannot be found in the parent property manager for the override named '#propertyName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>

					<cfset setProperty(propertyName, getParent().getProperty(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<!--- Setup if configurable property --->
				<cfif StructKeyExists(propertyNodes[i].xmlAttributes, "type")>
					<cfset propertyType = propertyNodes[i].xmlAttributes["type"] />

					<!--- Set the Property's parameters. --->
					<cfset propertyParams = StructNew() />

					<!--- For each configurable property, parse all the parameters --->
					<cfif StructKeyExists(propertyNodes[i], "parameters")>
						<cfset paramsNodes = propertyNodes[i].parameters.xmlChildren />
						<cfloop from="1" to="#ArrayLen(paramsNodes)#" index="j">
							<cfset paramName = paramsNodes[j].XmlAttributes["name"] />
							<cftry>
								<cfset paramValue = utils.recurseComplexValues(paramsNodes[j]) />
								<cfcatch type="any">
									<cfthrow type="MachII.framework.InvalidPropertyXml"
										message="Xml parsing error for the property named '#propertyName#' in module named '#getAppManager().getModuleName()#'." />
								</cfcatch>
							</cftry>
							<cfset propertyParams[paramName] = paramValue />
						</cfloop>
					</cfif>

					<!--- Create the configurable property and append to array of configurable property names --->
					<cftry>
						<!--- Do not method chain the init() on the instantiation
							or objects that have their init() overridden will
							cause the variable the object is assigned to will
							be deleted if init() returns void --->
						<cfset propertyValue = CreateObject("component", propertyType) />
						<cfset propertyValue.init(getAppManager(), propertyParams) />

						<cfcatch type="any">
							<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ propertyType>
								<cfthrow type="MachII.framework.CannotFindProperty"
									message="Cannot find a CFC with the type of '#propertyType#' for the property named '#propertyName#' in module named '#getAppManager().getModuleName()#'."
									detail="Please check that a property exists and that there is not a misconfiguration in the XML configuration file." />
							<cfelse>
								<cfthrow type="MachII.framework.PropertySyntaxException"
									message="Mach-II could not register a property with type of '#propertyType#' for the property named '#propertyName#' in module named '#getAppManager().getModuleName()#'."
									detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
							</cfif>
						</cfcatch>
					</cftry>

					<!--- Continue setup on the property --->
					<cfset baseProxy = CreateObject("component",  "MachII.framework.BaseProxy").init(propertyValue, propertyType, propertyParams) />
					<cfset propertyValue.setProxy(baseProxy) />

					<!--- Add the property to the array of configurable properties so they can be configured --->
					<cfset ArrayAppend(variables.configurablePropertyNames, propertyName) />
				<!--- Setup if name/value pair, struct or array --->
				<cfelse>
					<cftry>
						<cfset propertyValue = utils.recurseComplexValues(propertyNodes[i]) />
						<cfcatch type="any">
							<cfthrow type="MachII.framework.InvalidPropertyXml"
								message="Xml parsing error for the property named '#propertyName#' in module '#getAppManager().getModuleName()#'." />
						</cfcatch>
					</cftry>
				</cfif>

				<!--- Set the property --->
				<cfif (hasParent AND NOT listFindNoCase(propsNotAllowInModule, propertyName))
						OR NOT hasParent>
					<cfset setProperty(propertyName, propertyValue) />
				</cfif>
			</cfif>
		</cfloop>

		<!--- Make sure required properties are set if this is the base application:
			defaultEvent, exceptionEvent, applicationRoot, eventParameter, parameterPrecedence, maxEvents and redirectPersistParameter. --->
		<cfif NOT hasParent>
			<cfif NOT isPropertyDefined("defaultEvent")>
				<cfset setProperty("defaultEvent", "defaultEvent") />
			</cfif>
			<cfif NOT isPropertyDefined("exceptionEvent")>
				<cfset setProperty("exceptionEvent", "exceptionEvent") />
			</cfif>
			<cfif NOT isPropertyDefined("applicationRoot")>
				<cfset setProperty("applicationRoot", "") />
			</cfif>
			<cfif NOT isPropertyDefined("eventParameter")>
				<cfset setProperty("eventParameter", "event") />
			</cfif>
			<cfif NOT isPropertyDefined("parameterPrecedence")>
				<cfset setProperty("parameterPrecedence", "form") />
			<cfelseif NOT ListFindNoCase("form|url", getProperty("parameterPrecedence"), "|")>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'parameterPrecedence' property must have a the value of 'form' or 'url'." />
			</cfif>
			<cfif NOT isPropertyDefined("maxEvents")>
				<cfset setProperty("maxEvents", 10) />
			<cfelseif NOT IsNumeric(getProperty("maxEvents"))>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'maxEvents' property must be an integer." />
			</cfif>
			<cfif NOT isPropertyDefined("redirectPersistParameter")>
				<cfset setProperty("redirectPersistParameter", "persistId") />
			</cfif>
			<cfif NOT isPropertyDefined("redirectPersistScope")>
				<cfset setProperty("redirectPersistScope", "session") />
			</cfif>
			<cfif NOT isPropertyDefined("redirectPersistParameterLocation")>
				<cfset setProperty("redirectPersistParameterLocation", "url") />
			<cfelseif NOT ListFindNoCase("cookie,url", getProperty("redirectPersistParameterLocation"))>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'redirectPersistParameterLocation' property must be an 'url' or 'cookie'." />
			</cfif>
			<cfif NOT isPropertyDefined("urlBase")>
				<cfset setProperty("urlBase", "index.cfm") />
			</cfif>
			<cfif NOT isPropertyDefined("urlDelimiters")>
				<cfset setProperty("urlDelimiters", "?|&|=") />
			<cfelseif ListLen(getProperty("urlDelimiters"), "|") NEQ 3>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'urlDelimiters' property must have a list length of 3 with a delimiter of a '|'." />
			</cfif>
			<cfif NOT isPropertyDefined("urlParseSES")>
				<!---
					Automatically parse for SES urls if the delimiters are not set to query
					string and no urlParseSES is defined
				--->
				<cfif getProperty("urlDelimiters") NEQ "?|&|=">
					<cfset setProperty("urlParseSES", true) />
				<cfelse>
					<cfset setProperty("urlParseSES", false) />
				</cfif>
			<cfelseif NOT IsBoolean(getProperty("urlParseSES"))>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'urlParseSES' property must be a boolean." />
			</cfif>
			<cfif NOT isPropertyDefined("moduleDelimiter")>
				<cfset setProperty("moduleDelimiter", ":") />
			</cfif>
			<cfif NOT isPropertyDefined("urlExcludeEventParameter")>
				<cfset setProperty("urlExcludeEventParameter", false) />
			<cfelseif NOT IsBoolean(getProperty("urlExcludeEventParameter"))>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'urlExcludeEventParameter' property must be a boolean." />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Prepares the configurable properties for use.">

		<cfset var appManager = getAppManager() />
		<cfset var configurablePropertyNames = getConfigurablePropertyNames() />
		<cfset var aConfigurableProperty = "" />
		<cfset var i = 0 />

		<!--- Run configure on all configurable properties --->
		<cfloop from="1" to="#ArrayLen(variables.configurablePropertyNames)#" index="i">
			<cfset aConfigurableProperty = getProperty(variables.configurablePropertyNames[i]) />
			<cfset appManager.onObjectReload(aConfigurableProperty) />
			<cfset aConfigurableProperty.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Performs deconfiguration logic.">

		<cfset var configurablePropertyNames = getConfigurablePropertyNames() />
		<cfset var aConfigurableProperty = "" />
		<cfset var i = 0 />

		<!--- Run configure on all configurable properties --->
		<cfloop from="1" to="#ArrayLen(variables.configurablePropertyNames)#" index="i">
			<cfset aConfigurableProperty = getProperty(variables.configurablePropertyNames[i]) />
			<cfset aConfigurableProperty.deconfigure() />
		</cfloop>
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getProperty" access="public" returntype="any" output="false"
		hint="Returns the property value by name. If the property is not defined, and a default value is passed, it will be returned. If the property and a default value are both not defined then an exception is thrown.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to return." />
		<cfargument name="defaultValue" type="any" required="false" default=""
			hint="The default value to use if the requested property is not defined." />

		<cfset var propertyValue = "" />

		<cfif isPropertyDefined(arguments.propertyName)>
			<cfset propertyValue = variables.properties[arguments.propertyName] />

			<!--- If configurable property, then return object --->
			<cfif IsObject(propertyValue) AND StructKeyExists(propertyValue, "getObject")>
				<cfset propertyValue = propertyValue.getObject() />
			<cfelseif IsSimpleValue(propertyValue) AND getAppManager().getExpressionEvaluator().isExpression(propertyValue)>
				<cfset propertyValue = getAppManager().getExpressionEvaluator().evaluateExpression(propertyValue, CreateObject("component", "MachII.framework.Event").init(), this) />
			</cfif>

			<cfreturn propertyValue />
		<cfelseif IsObject(getParent()) AND getParent().isPropertyDefined(arguments.propertyName)>
			<cfreturn getParent().getProperty(arguments.propertyName)>
		<cfelseif StructKeyExists(arguments, "defaultValue")>
			<cfreturn arguments.defaultValue />
		<cfelse>
			<!--- This case is current unimplemented to retain backwards compatibility.
           Currently the framework does not throw an error when a property does
           not exist, but returns "".  However, in future release this action may not be
           retained and an error thrown. --->
			<cfthrow type="MachII.framework.PropertyNotDefined"
				message="Property with name '#arguments.propertyName#' is not defined." />
		</cfif>
	</cffunction>
	<cffunction name="setProperty" access="public" returntype="void" output="false"
		hint="Sets the property value by name.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to set." />
		<cfargument name="propertyValue" type="any" required="true"
			hint="The value to store in the property." />
		<!--- Default properties for base/main property manager only cannot be overriden:
			applicationRoot, eventParameter, parameterPredence, maxEvents, redirectPreists, redirectPeristscope,
			moduleDelimiter, all url stuff. Can be overriden: defaultEvent, exceptionEvent
		--->
		<cfif IsObject(getParent()) AND listFindNoCase(propsNotAllowInModule, propertyName)>
			<cfthrow type="MachII.framework.propertyNotAllowed"
				message="The '#arguments.propertyName#' property cannot be set inside of a module." />
		<cfelse>
			<!--- Save the proxy if this is a configurable property --->
			<cfif IsObject(arguments.propertyValue) AND StructKeyExists(arguments.propertyValue, "getProxy")>
				<cfset arguments.propertyValue = arguments.propertyValue.getProxy() />
			</cfif>
			<cfset variables.properties[arguments.propertyName] = arguments.propertyValue />
		</cfif>
	</cffunction>
	<cffunction name="removeProperty" access="public" returntype="void" output="false"
		hint="Removes a property from the current property manager. Does NOT remove from a parent.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The name of the property to remove." />
		<cfset StructDelete(variables.properties, arguments.propertyName, false) />
	</cffunction>

	<cffunction name="isPropertyDefined" access="public" returntype="boolean" output="false"
		hint="Checks if property name is defined in the properties. Does NOT check a parent.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The named of the property to check if it is defined." />
		<cfreturn StructKeyExists(variables.properties, arguments.propertyName) />
	</cffunction>
	<cffunction name="hasProperty" access="public" returntype="boolean" output="false"
		hint="DEPRECATED - use isPropertyDefined() instead. Checks if property name is deinfed in the propeties.">
		<cfargument name="propertyName" type="string" required="true"
			hint="The named of the property to check if it is defined." />

		<cfset var log = getLog() />

		<cfif log.isWarnEnabled()>
			<cfset log.warn("DEPRECATED: The hasProperty() method has been deprecated. Please use isPropertyDefined() instead.") />
		</cfif>

		<cfreturn StructKeyExists(variables.properties, arguments.propertyName) />
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" output="false"
		hint="Returns all properties.">
		<cfreturn variables.properties />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getVersion" access="public" returntype="string" output="false"
		hint="Gets the version number of the framework.">

		<cfset var minorVersion = 0 />

		<!--- Leave the string as-is or the build will fail --->
		<cfif NOT variables.minorVersion IS "@" & "minorVersion" & "@">
			<cfset minorVersion = variables.minorVersion />
		</cfif>

		<cfreturn variables.majorVersion &  "." & minorVersion />
	</cffunction>

	<cffunction name="getConfigurablePropertyNames" access="public" returntype="array" output="false"
		hint="Returns an array of property names that we can call a configure() method on.">
		<cfreturn variables.configurablePropertyNames />
	</cffunction>

	<cffunction name="reloadProperty" access="public" returntype="void" output="false"
		hint="Reloads a configurable property.">
		<cfargument name="propertyName" type="string" required="true"
			hint="Name of configurable property to reload." />

		<cfset var newProperty = "" />
		<cfset var currentProperty = getProperty(arguments.propertyName) />
		<cfset var baseProxy = "" />

		<!--- Throw error if the property is not configurable --->
		<cfif NOT ensureConfigurableProperty(arguments.propertyName)>
			<cfthrow type="MachII.framework.CannotReloadPropertyNotConfigurable"
				message="The property '#arguments.propertyName#' cannot be reloaded because it is not configurable (i.e. Property.cfc)." />
		</cfif>

		<!--- Since we now have a configurable property, get the base proxy --->
		<cfset baseProxy = currentProperty.getProxy() />

		<!--- Setup the Property --->
		<cftry>
			<!--- Do not method chain the init() on the instantiation
				or objects that have their init() overridden will
				cause the variable the object is assigned to will
				be deleted if init() returns void --->
			<cfset newProperty = CreateObject("component", baseProxy.getType()) />
			<cfset newProperty.init(getAppManager(), baseProxy.getOriginalParameters()) />

			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName") AND cfcatch.missingFileName EQ baseProxy.getType()>
					<cfthrow type="MachII.framework.CannotFindProperty"
						message="Cannot find a listener CFC with type of '#baseProxy.getType()#' for the property named '#arguments.propertyName#' in module named '#getAppManager().getModuleName()#'."
						detail="Please check that this property exists and that there is not a misconfiguration in the XML configuration file." />
				<cfelse>
					<cfthrow type="MachII.framework.PropertySyntaxException"
						message="Mach-II could not register a property with type of '#baseProxy.getType()#' for the property named '#arguments.propertyName#' in module named '#getAppManager().getModuleName()#'."
						detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfif>
			</cfcatch>
		</cftry>

		<!--- Run deconfigure in the current Property
			which must take place before configure is
			run in the new Property --->
		<cfset currentProperty.deconfigure() />

		<!--- Replace the old Property with the new Property in the proxy--->
		<cfset baseProxy.setObject(newProperty) />
		<cfset newProperty.setProxy(baseProxy) />

		<!--- Configure the Property --->
		<cfset getAppManager().onObjectReload(newProperty) />
		<cfset newProperty.configure() />

		<!--- Add the Property to the manager --->
		<cfset setProperty(arguments.propertyName, newProperty) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="ensureConfigurableProperty" access="private" returntype="boolean" output="false"
		hint="Ensures that the passed property name is configuable. Does NOT check parent.">
		<cfargument name="propertyName" type="string" required="true" />

		<cfset var configurablePropertyNames = getConfigurablePropertyNames() />
		<cfset var configurable = false />
		<cfset var i = 0 />

		<!--- Ensure the property is configurable --->
		<cfloop from="1" to="#ArrayLen(configurablePropertyNames)#" index="i">
			<cfif CompareNoCase(arguments.propertyName, configurablePropertyNames[i]) EQ 0>
				<cfset configurable = true />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn configurable />
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

	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent PropertyManager instance this FilterManager belongs to.">
		<cfargument name="parentPropertyManager" type="MachII.framework.PropertyManager" required="true" />
		<cfset variables.parentPropertyManager = arguments.parentPropertyManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent PropertyManager instance this PropertyManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentPropertyManager />
	</cffunction>

	<cffunction name="setLog" access="private" returntype="void" output="false"
		hint="Uses the log factory to create a log.">
		<cfargument name="logFactory" type="MachII.logging.LogFactory" required="true" />
		<cfset variables.log = arguments.logFactory.getLog(getMetadata(this).name) />
	</cffunction>
	<cffunction name="getLog" access="private" returntype="MachII.logging.Log" output="false"
		hint="Gets the log.">
		<cfreturn variables.log />
	</cffunction>

</cfcomponent>