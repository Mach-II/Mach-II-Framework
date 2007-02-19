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
Updated version: 1.1.1

Notes:
- Added optimal XML configuration file validation. {bedwards)
--->
<cfcomponent 
	displayname="AppFactory" 
	output="false"
	hint="Factory class for creating instances of AppManager.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.includeDependencies = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AppFactory" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction> 
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="createAppManager" access="public" returntype="MachII.framework.AppManager" output="false"
		hint="Creates the AppManager and reads (and optionally validates) the XML configuration file.">
		<cfargument name="configXmlPath" type="string" required="true"
		 	hint="The full path to the configuration XML file." />
		<cfargument name="configDtdPath" type="string" required="true"
		 	hint="The full path to the configuration DTD file." />
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var listenerManager = "" />
		<cfset var filterManager = "" />
		<cfset var subroutineManager = "" />
		<cfset var eventManager = "" />
		<cfset var viewManager = "" />
		<cfset var pluginManager = "" />
		<cfset var configXml = "" />
		<cfset var configXmlFile = "" />
		<cfset var validationResult = "" />
		<cfset var validationException = "" />
		
		<!--- Read the XML configuration file. --->
		<cftry>
			<cffile 
				action="READ" 
				file="#arguments.configXmlPath#" 
				variable="configXmlFile" />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.CannotFindBaseConfigFile"
					message="Unable to find the base config file."
					detail="configPath=#arguments.configXmlPath#" />
			</cfcatch>
		</cftry>

		<!--- Parse the XML contents --->
		<cfset configXml = XmlParse(configXmlFile) />
		
		<!--- Validate the XML contents --->
		<cfset validateConfigXml(arguments.validateXml, configXml, arguments.configXmlPath, arguments.configDtdPath) />
		
		<!--- Create the AppManager --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		
		<!--- 
		Create the Framework Managers and set them in the AppManager
		Creation order is important: propertyManager first, requestManager, listenerManager, filterManager and subroutineManager before eventManager. 
		--->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(configXml, appManager) />
		<cfset appManager.setPropertyManager(propertyManager) />
		
		<cfset requestManager = CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		<cfset appManager.setRequestManager(requestManager) />
		
		<cfset listenerManager = CreateObject("component", "MachII.framework.ListenerManager").init(configXml, appManager) />
		<cfset appManager.setListenerManager(listenerManager) />
		
		<cfset filterManager = CreateObject("component", "MachII.framework.FilterManager").init(configXml, appManager) />
		<cfset appManager.setFilterManager(filterManager) />

		<cfset subroutineManager = CreateObject("component", "MachII.framework.SubroutineManager").init(configXml, appManager) />
		<cfset appManager.setSubroutineManager(subroutineManager) />
				
		<cfset eventManager = CreateObject("component", "MachII.framework.EventManager").init(configXml, appManager) />
		<cfset appManager.setEventManager(eventManager) />
		
		<cfset viewManager = CreateObject("component", "MachII.framework.ViewManager").init(configXml, appManager) />
		<cfset appManager.setViewManager(viewManager) />
		
		<cfset pluginManager = CreateObject("component", "MachII.framework.PluginManager").init(configXml, appManager) />
		<cfset appManager.setPluginManager(pluginManager) />

		<!--- Load the includes --->	
		<cfset loadIncludes(configXML, appManager, arguments.validateXml, arguments.configDtdPath) />

		<!--- Configure all the managers by calling the base configure --->
		<cfset appManager.configure() />
		
		<cfreturn appManager />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadIncludes" access="private" returntype="void" output="false"
		hint="Loads files to be included">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		
		<cfset var includeNodes = "" />
		<cfset var includeFilePath = "" />
		<cfset var includeXMLFile = "" />
		<cfset var includeXml = "" />
		<cfset var i = 0 />
		
		<cfset includeNodes =  XmlSearch(arguments.configXML, "//includes/include") />
		<cfloop from="1" to="#ArrayLen(includeNodes)#" index="i">
			<cfset includeFilePath = includeNodes[i].xmlAttributes["file"] />
			
			<!--- Check for circular dependencies --->
			<cfset checkIfAlreadyIncluded(includeFilePath) />
			
			<!--- Read the include file --->
			<cftry>
				<cffile
					action="read"
					file="#ExpandPath(includeFilePath)#"
					variable="includeXMLFile" />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.CannotFindIncludeConfigFile"
						message="Unable to find the include config file."
						detail="includePath=#includeFilePath#" />
				</cfcatch>
			</cftry>
			
			<!--- Parse the XML contents --->
			<cfset includeXml = XmlParse(includeXmlFile) />
			
			<!--- Validate the XML contents --->
			<cfset validateConfigXml(arguments.validateXml, includeXml, includeFilePath, arguments.configDtdPath) />
			
			<!--- Pass in the includeXml for processing
			Init order is important: propertyManager first, listenerManager, filterManager and subroutineManager before eventManager. 
			--->
			<cfset arguments.appManager.getPropertyManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getListenerManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getFilterManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getSubroutineManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getEventManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getViewManager().init(includeXml, appManager) />
			<cfset arguments.appManager.getPluginManager().init(includeXml, appManager) />
			
			<!--- Recursively check the include for more includes --->
			<cfset includeXMLFile = loadIncludes(includeXml, arguments.appManager, arguments.validateXml, arguments.configDtdPath) />
		</cfloop>
	</cffunction>
	
	<cffunction name="validateConfigXml" access="private" returntype="void" output="false"
		hint="Validates an xml file.">
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configXml" type="any" required="true" />
		<cfargument name="configXmlPath" type="string" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		
		<cfset var validationResult = "" />
		<cfset var validationException = "" />
		
		<cfif arguments.validateXml AND ListFirst(server.ColdFusion.ProductVersion) GTE 7>
			<cfset validationResult = XmlValidate(arguments.configXml, arguments.configDtdPath)>
			<cfif NOT validationResult.Status>
				<cfset validationException = CreateObject("component", "MachII.util.XmlValidationException") />
				<cfset validationException.wrapValidationResult(validationResult, arguments.configXmlPath, arguments.configDtdPath) />
				<cfthrow type="MachII.framework.XmlValidationException" 
					message="#validationException.getFormattedMessage()#" />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="checkIfAlreadyIncluded" access="private" returntype="void" output="false"
		hint="Checks if the include has already been processed.">
		<cfargument name="includeFilePath" type="string" required="true" />
		
		<cfset var includeFilePathHash = Hash(ExpandPath(arguments.includeFilePath)) />
		
		<cfif StructKeyExists(variables.includeDependencies, includeFilePathHash)>
			<cfthrow type="MachII.framework.IncludeAlreadyDefined"
				message="An include located at '#arguments.includeFilePath#' has already been included. You cannot define an include more than once." />
		<cfelse>
			<cfset variables.includeDependencies[includeFilePathHash] = TRUE />
		</cfif>
	</cffunction>
	
</cfcomponent>