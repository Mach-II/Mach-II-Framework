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
		<cfargument name="parentAppManager" type="any" required="false" default=""
			hint="Optional argument for a parent app manager. If there isn't one default to empty string." />
			
		<cfset var appManager = "" />
		<cfset var utils = "" />
		<cfset var propertyManager = "" />
		<cfset var parentPropertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var listenerManager = "" />
		<cfset var parentListenerManager = "" />
		<cfset var filterManager = "" />
		<cfset var parentFilterManager = "" />
		<cfset var subroutineManager = "" />
		<cfset var parentSubroutineManager = "" />
		<cfset var eventManager = "" />
		<cfset var viewManager = "" />
		<cfset var parentViewManager = "" />
		<cfset var pluginManager = "" />
		<cfset var parentPluginManager = "" />
		<cfset var configXml = "" />
		<cfset var configXmlFile = "" />
		<cfset var configXmls = ArrayNew(1) />
		<cfset var i = "" />
	
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

		<!--- Added the base config to the array --->
		<cfset ArrayAppend(configXmls, configXml) />

		<!--- Load the includes --->	
		<cfset configXmls = loadIncludes(configXmls, configXML, arguments.validateXml, arguments.configDtdPath) />
		
		<!--- Create the AppManager --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		
		<!--- Setup a parent app manager and related managers if the parent is not empty string --->
		<cfif IsObject(arguments.parentAppManager)>
			<cfset appManager.setParent(arguments.parentAppManager) />
			<cfset parentListenerManager = appManager.getParent().getListenerManager() />
			<cfset parentPropertyManager = appManager.getParent().getPropertyManager() />
			<cfset parentFilterManager = appManager.getParent().getFilterManager() />
			<cfset parentSubroutineManager = appManager.getParent().getSubroutineManager() />
			<cfset parentViewManager = appManager.getParent().getViewManager() />
			<cfset parentPluginManager = appManager.getParent().getPluginManager() />
		</cfif>
		
		<!--- Load in the low-level Utils class --->
		<cfset utils = CreateObject("component", "MachII.util.Utils").init() />
		<cfset appManager.setUtils(utils) />
		
		<!--- 
		Create the Framework Managers and set them in the AppManager
		Creation order is important: propertyManager first, requestManager, listenerManager, filterManager and subroutineManager before eventManager. 
		--->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager, parentPropertyManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset propertyManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setPropertyManager(propertyManager) />
		
		<!--- The requestManager is a singleton --->
		<cfset requestManager = CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		<cfset appManager.setRequestManager(requestManager) />
		
		<cfset listenerManager = CreateObject("component", "MachII.framework.ListenerManager").init(appManager, parentListenerManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset listenerManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setListenerManager(listenerManager) />
		
		<cfset filterManager = CreateObject("component", "MachII.framework.FilterManager").init(appManager, parentFilterManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset filterManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setFilterManager(filterManager) />

		<cfset subroutineManager = CreateObject("component", "MachII.framework.SubroutineManager").init(appManager, parentSubroutineManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset subroutineManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setSubroutineManager(subroutineManager) />
				
		<cfset eventManager = CreateObject("component", "MachII.framework.EventManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset eventManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setEventManager(eventManager) />
		
		<cfset viewManager = CreateObject("component", "MachII.framework.ViewManager").init(appManager, parentViewManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset viewManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setViewManager(viewManager) />
		
		<cfset pluginManager = CreateObject("component", "MachII.framework.PluginManager").init(appManager, parentPluginManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset pluginManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setPluginManager(pluginManager) />

		<cfset moduleManager = CreateObject("component", "MachII.framework.ModuleManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset moduleManager.loadXml(configXmls[i]) />
		</cfloop>
		<cfset appManager.setModuleManager(moduleManager) />
		
		<!--- Configure all the managers by calling the base configure --->
		<cfset appManager.configure() />
		
		<cfreturn appManager />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadIncludes" access="private" returntype="array" output="false"
		hint="Loads files to be included into the config xml array.">
		<cfargument name="configFiles" type="array" required="true" />
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		<cfargument name="alreadyLoaded" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var includeNodes = "" />
		<cfset var includeFilePath = "" />
		<cfset var includeXMLFile = "" />
		<cfset var includeXml = "" />
		<cfset var i = 0 />
		
		<cfset includeNodes =  XmlSearch(arguments.configXML, "//includes/include") />
		<cfloop from="1" to="#ArrayLen(includeNodes)#" index="i">
			<cfset includeFilePath = includeNodes[i].xmlAttributes["file"] />
			
			<!--- Check for circular dependencies --->
			<cfset arguments.alreadyLoaded = checkIfAlreadyIncluded(arguments.alreadyLoaded, includeFilePath) />
			
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
			
			<!--- Append the parsed include file to the config xml array --->
			<cfset ArrayAppend(arguments.configFiles, includeXml) />
			
			<!--- Recursively check the include for more includes --->
			<cfset arguments.configFiles = loadIncludes(arguments.configFiles, includeXml, arguments.validateXml, arguments.configDtdPath, arguments.alreadyLoaded) />
		</cfloop>
		
		<cfreturn arguments.configFiles />
	</cffunction>
	
	<cffunction name="validateConfigXml" access="private" returntype="void" output="false"
		hint="Validates an xml file.">
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configXml" type="any" required="true" />
		<cfargument name="configXmlPath" type="string" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		
		<cfset var validationResult = "" />
		<cfset var validationException = "" />
		
		<!--- Validate if directed and CF version 7 or higher --->
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
	
	<cffunction name="checkIfAlreadyIncluded" access="private" returntype="struct" output="false"
		hint="Checks if the include has already been processed.">
		<cfargument name="alreadyLoaded" type="struct" required="true" />
		<cfargument name="includeFilePath" type="string" required="true" />
		
		<cfset var includeFilePathHash = Hash(ExpandPath(arguments.includeFilePath)) />
		
		<cfif StructKeyExists(arguments.alreadyLoaded, includeFilePathHash)>
			<cfthrow type="MachII.framework.IncludeAlreadyDefined"
				message="An include located at '#arguments.includeFilePath#' has already been included. You cannot define an include more than once." />
		<cfelse>
			<cfset arguments.alreadyLoaded[includeFilePathHash] = TRUE />
		</cfif>
		
		<cfreturn arguments.alreadyLoaded />
	</cffunction>
	
</cfcomponent>