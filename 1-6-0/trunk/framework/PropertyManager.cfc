<!---
License:
Copyright 2007 GreatBizTools, LLC

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
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
- Deprecated hasProperty(). Duplicate method isPropertyDefined is more inline with
the rest of the framework. (pfarrell)
- Added method to get Mach-II framework version (pfarrell)
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
	<cfset variables.configurableProperties = ArrayNew(1) />
	<cfset variables.parentPropertyManager = "">
	<cfset variables.majorVersion = "1.6.0" />
	<cfset variables.minorVersion = "@minorVersion@" />
	<cfset variables.utils = "" />
	<cfset variables.propsNotAllowInModule =
		 "eventParameter,parameterPrecedence,maxEvents,redirectPersistParameter,redirectPersistScope,moduleDelimiter,urlBase,urlDelimiters,urlParseSES" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PropertyManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentPropertyManager" type="any" required="false" default=""
			hint="Optional argument for a parent property manager. If there isn't one default to empty string." />
		
		<cfset setAppManager(arguments.appManager) />
		<cfset variables.utils = getAppManager().getUtils() />
		
		<cfif isObject(arguments.parentPropertyManager)>
			<cfset setParent(arguments.parentPropertyManager) />
		</cfif>
		
		<!--- Setup the log --->
		<cfset setLog(getAppManager().getLogFactory()) />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
		
		<cfset var propertyNodes = "" />
		<cfset var propertyName = "" />
		<cfset var propertyValue = "" />
		<cfset var propertyType = "" />
		<cfset var propertyParams = "" />
		<cfset var paramsNodes = "" />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var hasParent = isObject(getParent()) />
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
								<cfset paramValue = variables.utils.recurseComplexValues(paramsNodes[j]) />
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
						<cfset propertyValue = CreateObject("component", propertyType).init(getAppManager(), propertyParams) />
						<cfcatch type="any">
							<cfif StructKeyExists(cfcatch, "missingFileName")>
								<cfthrow type="MachII.framework.CannotFindProperty"
									message="Cannot find a CFC with the type of '#propertyType#' for the property named '#propertyName#' in module named '#getAppManager().getModuleName()#'.">
							<cfelse>
								<cfrethrow />
							</cfif>
						</cfcatch>
					</cftry>
					<cfset ArrayAppend(variables.configurableProperties, propertyName) />
				<!--- Setup if name/value pair, struct or array --->
				<cfelse>
					<cftry>
						<cfset propertyValue = variables.utils.recurseComplexValues(propertyNodes[i]) />
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
				<cfset setProperty("urlParseSES", false) />
			<cfelseif NOT IsBoolean(getProperty("urlParseSES"))>
				<cfthrow type="MachII.framework.invalidPropertyValue"
					message="The 'urlParseSES' property must be a boolean." />
			</cfif>
			<cfif NOT isPropertyDefined("moduleDelimiter")>
				<cfset setProperty("moduleDelimiter", ":") />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void"
		hint="Prepares the configurable properties for use.">
		<cfset var aConfigurableProperty = "" />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#ArrayLen(variables.configurableProperties)#" index="i">
			<cfset aConfigurableProperty = getProperty(variables.configurableProperties[i]) />
			<cfset aConfigurableProperty.configure() />
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
		
		<cfif isPropertyDefined(arguments.propertyName)>
			<cfreturn variables.properties[arguments.propertyName] />
		<cfelseif isObject(getParent()) AND getParent().isPropertyDefined(arguments.propertyName)>
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
		<cfif isObject(getParent()) AND listFindNoCase(propsNotAllowInModule, propertyName)>
			<cfthrow type="MachII.framework.propertyNotAllowed"
				message="The '#arguments.propertyName#' property cannot be set inside of a module." />
		<cfelse>
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
			<cfset log.warn("The hasProperty() method has been deprecated. Please use isPropertyDefined() instead.") />
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
		<cfreturn variables.configurableProperties />
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