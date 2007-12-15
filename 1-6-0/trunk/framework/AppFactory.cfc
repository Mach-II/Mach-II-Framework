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
- Added optimal XML configuration file validation. (bedwards)
- Thanks to the ColdSpring project for the inspiration for the expandRelativePath() method (pfarrell)
--->
<cfcomponent 
	displayname="AppFactory" 
	output="false"
	hint="Factory class for creating instances of AppManager.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.configFilePaths = ArrayNew(1) />
	<cfset variables.utils = "" />

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
		<cfargument name="appkey" type="string" required="true"
			hint="Unqiue key for this application.">
		<cfargument name="validateXml" type="boolean" required="false" default="false"
			hint="Should the XML be validated before parsing." />
		<cfargument name="parentAppManager" type="any" required="false" default=""
			hint="Optional argument for a parent app manager. Defaults to empty string." />
		<cfargument name="overrideXml" type="any" required="false" default=""
			hint="Optional argument for override Xml for a module. Defaults to empty string." />
		<cfargument name="moduleName" type="string" required="false" default=""
			hint="Optional argument for the name of a module. Defaults to empty string." />
			
		<cfset var appManager = "" />
		<cfset var utils = "" />
		<cfset var logFactory = "" />
		<cfset var propertyManager = "" />
		<cfset var parentPropertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var listenerManager = "" />
		<cfset var parentListenerManager = "" />
		<cfset var messageManager = "" />
		<cfset var parentMessageManager = "" />
		<cfset var filterManager = "" />
		<cfset var parentFilterManager = "" />
		<cfset var subroutineManager = "" />
		<cfset var parentSubroutineManager = "" />
		<cfset var eventManager = "" />
		<cfset var viewManager = "" />
		<cfset var parentViewManager = "" />
		<cfset var pluginManager = "" />
		<cfset var parentPluginManager = "" />
		<cfset var parentEventManager = "" />
		<cfset var moduleManager = "" />
		<cfset var configXml = "" />
		<cfset var configXmlFile = "" />
		<cfset var configXmls = ArrayNew(1) />
		<cfset var overrideIncludeNodes  = "" />
		<cfset var overrideIncludes = ArrayNew(1) />
		<cfset var temp = StructNew() />
		<cfset var i = "" />
		
		<!--- Clear the config file paths as this is important since the AppFactory is reused for full reloads --->
		<cfset resetConfigFilePaths() />
		
		<!--- Utils and LogFactory is a singleton --->
		<cfif IsObject(arguments.parentAppManager)>
			<cfset utils = arguments.parentAppManager.getUtils() />
			<cfset logFactory = arguments.parentAppManager.getLogFactory() />
		<cfelse>
			<cfset utils = CreateObject("component", "MachII.util.Utils").init() />
			<cfset logFactory = CreateObject("component", "MachII.logging.LogFactory").init() />
			
			<cfset p = { loggingLevel="all" } />
			
			<cfset adapter = CreateObject("component", "MachII.logging.adapters.CFLogAdapter").init(p) />
			<cfset adapter.configure() />
			
			<cfset logFactory.registerLogAdapter(adapter) />
			
		</cfif>
		
		<!--- Put a reference of the utils into the variables so loadIncludes can use it --->
		<cfset variables.utils = utils />
		
		<!--- Read the XML configuration file. --->
		<cftry>
			<cffile 
				action="READ" 
				file="#arguments.configXmlPath#" 
				variable="configXmlFile" />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.CannotFindBaseConfigFile"
					message="Unable to find the base config file for module '#arguments.moduleName#'."
					detail="configPath=#arguments.configXmlPath#" />
			</cfcatch>
		</cftry>
		
		<!--- Append the master config file to the file paths --->
		<cfset appendConfigFilePath(arguments.configXmlPath) />

		<!--- Parse the XML contents --->
		<cfset temp.configXml = XmlParse(configXmlFile) />
		<cfset temp.override = false />
		
		<!--- Validate the XML contents --->
		<cfset validateConfigXml(arguments.validateXml, temp.configXml, arguments.configXmlPath, arguments.configDtdPath) />

		<!--- Added the base config to the array --->
		<cfset ArrayAppend(configXmls, temp) />

		<!--- Load the includes --->
		<cfset configXmls = loadIncludes(configXmls, temp.configXml, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(arguments.configXmlPath)) />

		<!--- Search for includes in the overrideXml if defined --->
		<cfif Len(arguments.overrideXml)>
			<cfset configXmls = loadIncludes(configXmls, arguments.overrideXml, arguments.validateXml, arguments.configDtdPath, true) />
		</cfif>
		
		<!--- Create the AppManager --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		<cfset appManager.setAppKey(arguments.appkey) />
		<cfif Len(arguments.moduleName)>
			<cfset appManager.setModuleName(arguments.moduleName) />
		</cfif>
		
		<!--- Setup a parent app manager and related managers if the parent is not empty string --->
		<cfif IsObject(arguments.parentAppManager)>
			<cfset appManager.setParent(arguments.parentAppManager) />
			<cfset parentPropertyManager = appManager.getParent().getPropertyManager() />
			<cfset parentListenerManager = appManager.getParent().getListenerManager() />
			<cfset parentMessageManager = appManager.getParent().getMessageManager() />
			<cfset parentFilterManager = appManager.getParent().getFilterManager() />
			<cfset parentSubroutineManager = appManager.getParent().getSubroutineManager() />
			<cfset parentEventManager = appManager.getParent().getEventManager() />
			<cfset parentViewManager = appManager.getParent().getViewManager() />
			<cfset parentPluginManager = appManager.getParent().getPluginManager() />
		</cfif>
		
		<!--- 
		Create the Framework Managers and set them in the AppManager
		Creation order is important (do not change!):
		utils, propertyManager, requestManager, listenerManager, messageManager, filterManager, 
		subroutineManager, eventManager, viewManager, pluginManager and then moduleManager
		--->
		
		<!--- Set the utils which is a singleton across the application --->
		<cfset appManager.setUtils(utils) />

		<!--- Set the LogFactory which is a singleton across the application --->
		<cfset appManager.setLogFactory(logFactory) />
		
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager, parentPropertyManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset propertyManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset propertyManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setPropertyManager(propertyManager) />
		
		<!--- RequestManager is a singleton --->
		<cfif IsObject(arguments.parentAppManager)>
			<cfset requestManager = arguments.parentAppManager.getRequestManager() />
		<cfelse>
			<cfset requestManager = CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		</cfif>
		<cfif isObject(appManager.getParent())>
			<cfset appManager.setRequestManager(appManager.getParent().getRequestManager()) />
		<cfelse>
			<cfset appManager.setRequestManager(requestManager) />
		</cfif>

		<cfset listenerManager = CreateObject("component", "MachII.framework.ListenerManager").init(appManager, parentListenerManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset listenerManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset listenerManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setListenerManager(listenerManager) />

		<cfset messageManager = CreateObject("component", "MachII.framework.MessageManager").init(appManager, parentMessageManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset messageManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset messageManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setMessageManager(messageManager) />
		
		<cfset filterManager = CreateObject("component", "MachII.framework.EventFilterManager").init(appManager, parentFilterManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset filterManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset filterManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setFilterManager(filterManager) />

		<cfset subroutineManager = CreateObject("component", "MachII.framework.SubroutineManager").init(appManager, parentSubroutineManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset subroutineManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset subroutineManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setSubroutineManager(subroutineManager) />
				
		<cfset eventManager = CreateObject("component", "MachII.framework.EventManager").init(appManager, parentEventManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset eventManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset eventManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setEventManager(eventManager) />
		
		<cfset viewManager = CreateObject("component", "MachII.framework.ViewManager").init(appManager, parentViewManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset viewManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset viewManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setViewManager(viewManager) />
		
		<cfset pluginManager = CreateObject("component", "MachII.framework.PluginManager").init(appManager, parentPluginManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset pluginManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset pluginManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setPluginManager(pluginManager) />
		
		<!--- ModuleManager is a singleton across the application --->
		<cfif NOT IsObject(arguments.parentAppManager)>
			<cfset moduleManager = CreateObject("component", "MachII.framework.ModuleManager").init(appManager, GetDirectoryFromPath(arguments.configXmlPath), arguments.configDtdPath, arguments.validateXML) />
			<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
				<cfset moduleManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
			</cfloop>
		<cfelse>
			<cfset moduleManager = arguments.parentAppManager.getModuleManager() />
		</cfif>
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
		<cfargument name="parentConfigFilePathDirectory" type="string" required="true" />
		<cfargument name="overrideIncludeType" type="boolean" required="false" default="false" />
		<cfargument name="alreadyLoaded" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var includeNodes = "" />
		<cfset var temp = StructNew() />
		<cfset var includeFilePath = "" />
		<cfset var includeXmlFile = "" />
		<cfset var i = 0 />
		
		<cfset includeNodes =  XmlSearch(arguments.configXML, ".//includes/include") />
		<cfloop from="1" to="#ArrayLen(includeNodes)#" index="i">

			<cfset temp = StructNew() />
			<cfset includeFilePath = includeNodes[i].xmlAttributes["file"] />
			
			<cfif Left(includeFilePath, 1) IS ".">
				<cfset includeFilePath = variables.utils.expandRelativePath(arguments.parentConfigFilePathDirectory, includeFilePath) />
			<cfelse>
				<cfset includeFilePath = ExpandPath(includeFilePath) />
			</cfif>

			<!--- If this isn't a setup override includes, then check otherwise override --->
			<cfif NOT arguments.overrideIncludeType>
				<cfif StructKeyExists(includeNodes[i].xmlAttributes, "override")>
					<cfset temp.override = includeNodes[i].xmlAttributes["override"] />
				<cfelse>
					<cfset temp.override = false />
				</cfif>
			<cfelse>
				<cfset temp.override = true />
			</cfif>
			
			<!--- Check for circular dependencies (pass a struct instead of stateful variables in case there is a error and it's impossible to cleanup)--->
			<cfset checkIfAlreadyIncluded(arguments.alreadyLoaded, includeFilePath) />
			
			<!--- Read the include file --->
			<cftry>
				<cffile
					action="read"
					file="#includeFilePath#"
					variable="includeXMLFile" />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.CannotFindIncludeConfigFile"
						message="Unable to find the include config file. This could be due to an incorrect relative path."
						detail="includePath=#includeFilePath#" />
				</cfcatch>
			</cftry>
			
			<!--- Parse the XML contents --->
			<cfset temp.configXml = XmlParse(includeXmlFile) />

			<!--- Validate the XML contents --->
			<cfset validateConfigXml(arguments.validateXml, temp.configXml, includeFilePath, arguments.configDtdPath) />
			
			<!--- Append the include config file to the file paths --->
			<cfset appendConfigFilePath(includeFilePath) />
			
			<!--- Append the parsed include file to the config xml array --->
			<cfset ArrayAppend(arguments.configFiles, temp) />
			
			<!--- Recursively check the currently processing include for more includes --->
			<cfset arguments.configFiles = loadIncludes(arguments.configFiles, temp.configXml, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.overrideIncludeType, arguments.alreadyLoaded) />
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
			<!--- Check to see if the dtd file exists if the dtd path is not a URL --->
			<cfif NOT FindNoCase("http://", arguments.configDtdPath) AND NOT FileExists(arguments.configDtdPath)>
				<cfthrow type="MachII.framework.XmlValidationException"
					message="Unable to find the DTD for xml validation. Please check that this a valid path."
					detail="dtdPath=#arguments.configDtdPath#" />
			</cfif>
			
			<cfset validationResult = XmlValidate(arguments.configXml, arguments.configDtdPath) />
			
			<!--- Throw an error if the Xml config file does not validate --->
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
		<cfargument name="alreadyLoaded" type="struct" required="true" />
		<cfargument name="includeFilePath" type="string" required="true" />
		
		<cfset var includeFilePathHash = Hash(arguments.includeFilePath) />
		
		<cfif StructKeyExists(arguments.alreadyLoaded, includeFilePathHash)>
			<cfthrow type="MachII.framework.IncludeAlreadyDefined"
				message="An include located at '#arguments.includeFilePath#' has already been included. You cannot define an include more than once." />
		<cfelse>
			<cfset arguments.alreadyLoaded[includeFilePathHash] = true />
		</cfif>
	</cffunction>
	
	<!---
	ACCESSORS
	--->	
	<cffunction name="resetConfigFilePaths" access="private" returntype="void" output="false"
		hint="Resets the config file paths to a zero element array.">
		<cfset ArrayClear(variables.configFilePaths) />
	</cffunction>
	<cffunction name="appendConfigFilePath" access="private" returntype="void" output="false"
		hint="Appends a config file path to be used by AppLoader to check if reloading is necessary when in dynamic mode.">
		<cfargument name="configFilePath" type="string" required="true" />
		<cfset ArrayAppend(variables.configFilePaths, arguments.configFilePath) />
	</cffunction>
	<cffunction name="getConfigFilePaths" access="public" returntype="array" output="false"
		hint="Returns an array of config file paths.">
		<cfreturn variables.configFilePaths />
	</cffunction>
	
</cfcomponent>