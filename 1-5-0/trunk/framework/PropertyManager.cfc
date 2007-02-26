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
	<cfset variables.version = "1.5.0.0" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="PropertyManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="parentPropertyManager" type="any" required="false" default=""
			hint="Optional argument for a parent property manager. If there isn't one default to empty string." />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif isObject(arguments.parentPropertyManager)>
			<cfset setParent(arguments.parentPropertyManager) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml into the manager.">
		<cfargument name="configXML" type="string" required="true" />
		
		<cfset var xnProperties = "" />
		<cfset var xnParams = "" />
		<cfset var name = "" />
		<cfset var value = "" />
		<cfset var type = "" />
		<cfset var propertyParams = "" />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Set the properties from the XML file. --->
		<cfset xnProperties = XMLSearch(arguments.configXML, "//property") />

		<cfloop from="1" to="#ArrayLen(xnProperties)#" index="i">			
			<cfset name = xnProperties[i].xmlAttributes["name"] />
			
			<!--- Setup if configurable property --->
			<cfif StructKeyExists(xnProperties[i].xmlAttributes, "type")>
				<cfset type = xnProperties[i].xmlAttributes["type"] />
				
				<!--- For each configurable property, parse all the parameters --->
				<cfset propertyParams = StructNew() />
				<cfset xnParams = XMLSearch(xnProperties[i], "./parameters/parameter") />
				<cfloop from="1" to="#ArrayLen(xnParams)#" index="j">
					<cfset paramName = xnParams[j].XmlAttributes["name"] />
					<cfset paramValue = xnParams[j].XmlAttributes["value"] />
					
					<cfset StructInsert(propertyParams, paramName, paramValue, true) />
				</cfloop>
				
				<!--- Create the configurable property and append to array of configurable property names --->
				<cfset value = CreateObject("component", type).init(getAppManager(), propertyParams) />
				<cfset ArrayAppend(variables.configurableProperties, name) />
			<!--- Setup if name/value pair, struct or array --->
			<cfelse>
				<cfset value = recurseProperty(xnProperties[i]) />
			</cfif>
			
			<!--- Set the property --->
			<cfset setProperty(name, value) />
		</cfloop>
		
		<!--- TODO: Add logic to set default properties for base/main property manager only --->
		
		<!--- Make sure required properties are set: 
			defaultEvent, exceptionEvent, applicationRoot, eventParameter, parameterPrecedence, maxEvents and redirectPersistParameter. --->
		<cfif NOT isPropertyDefined("defaultEvent")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("defaultEvent")>
			<cfelse>
				<cfset setProperty("defaultEvent", "defaultEvent") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("exceptionEvent")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("exceptionEvent")>
			<cfelse>
				<cfset setProperty("exceptionEvent", "exceptionEvent") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("applicationRoot")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("applicationRoot")>
			<cfelse>
				<cfset setProperty("applicationRoot", "") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("eventParameter")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("eventParameter")>
			<cfelse>
				<cfset setProperty("eventParameter", "event") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("parameterPrecedence")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("parameterPrecedence")>
			<cfelse>
				<cfset setProperty("parameterPrecedence", "form") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("maxEvents")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("maxEvents")>
			<cfelse>
				<cfset setProperty("maxEvents", 10) />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("redirectPersistParameter")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("redirectPersistParameter")>
			<cfelse>
				<cfset setProperty("redirectPersistParameter", "persistId") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("redirectPersistScope")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("redirectPersistScope")>
			<cfelse>
				<cfset setProperty("redirectPersistScope", "session") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("urlBase")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("urlBase")>
			<cfelse>
				<cfset setProperty("urlBase", "index.cfm") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("urlDelimiters")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("urlDelimiters")>
			<cfelse>
				<cfset setProperty("urlDelimiters", "?,&,=") />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("urlParseSES")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("urlParseSES")>
			<cfelse>
				<cfset setProperty("urlParseSES", false) />
			</cfif>
		</cfif>
		<cfif NOT isPropertyDefined("moduleDelimiter")>
			<cfif isObject(getParent()) AND getParent().isPropertyDefined("moduleDelimiter")>
			<cfelse>
				<cfset setProperty("moduleDelimiter", ":") />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void" output="false"
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
		<cfargument name="propertyName" type="string" required="true" />
		<cfargument name="defaultValue" type="any" required="false" default="" />
		
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
		<cfargument name="propertyName" type="string" required="true" />
		<cfargument name="propertyValue" type="any" required="true" />
		<cfset variables.properties[arguments.propertyName] = arguments.propertyValue />
	</cffunction>
	
	<cffunction name="isPropertyDefined" access="public" returntype="boolean" output="false"
		hint="Checks if property name is defined in the properties.">
		<cfargument name="propertyName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.properties, arguments.propertyName) />
	</cffunction>
	<cffunction name="hasProperty" access="public" returntype="boolean" output="false"
		hint="DEPRECATED - use isPropertyDefined() instead. Checks if property name is deinfed in the propeties.">
		<cfargument name="propertyName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.properties, arguments.propertyName) />
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" output="false"
		hint="Returns all properties.">
		<cfreturn variables.properties />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->	
	<cffunction name="recurseProperty" access="private" returntype="any" output="false"
		hint="Recurses properties by type.">
		<cfargument name="node" type="any" required="true" />
		
		<cfset var value = "" />
		<cfset var child = "" />
		<cfset var i = "" />
		
		<cfif StructKeyExists(arguments.node.xmlAttributes, "value")>
			<cfset value = arguments.node.xmlAttributes["value"] />
		<cfelse>
			<cfset child = arguments.node.xmlChildren[1] />
			<cfif child.xmlName EQ "value">
				<cfset value = child.xmlText />
			<cfelseif child.xmlName EQ "struct">
				<cfset value = StructNew() />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">
					<cfset value[child.xmlChildren[i].xmlAttributes["name"]] = recurseProperty(child.xmlChildren[i]) />
				</cfloop>
			<cfelseif child.xmlName EQ "array">
				<cfset value = ArrayNew(1) />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">			
					<cfset ArrayAppend(value, recurseProperty(child.xmlChildren[i])) />
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn value />
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

	<cffunction name="getVersion" access="public" returntype="string" output="false"
		hint="Gets the version number of the framework.">
		<cfreturn variables.version />
	</cffunction>
	
	<cffunction name="getConfigurablePropertyNames" access="public" returntype="array" output="false"
		hint="Returns an array of configurable property names.">
		<cfreturn variables.configurableProperties />
	</cffunction>
	
</cfcomponent>