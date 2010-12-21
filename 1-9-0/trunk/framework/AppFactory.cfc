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

$Id$

Created version: 1.0.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="AppFactory"
	output="false"
	hint="Factory class for creating instances of AppManager.">

	<!---
	PROPERTIES
	--->
	<cfset variables.configFilePaths = ArrayNew(1) />
	<cfset variables.fileMatcher = "" />
	<cfset variables.utils = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="AppFactory" output="false"
		hint="Used by the framework for initialization. Do not override.">
		
		<cfset variables.fileMatcher = CreateObject("component", "MachII.util.matching.FileMatcher").init() />	
		
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
		<cfset var propertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var listenerManager = "" />
		<cfset var messageManager = "" />
		<cfset var filterManager = "" />
		<cfset var subroutineManager = "" />
		<cfset var eventManager = "" />
		<cfset var viewManager = "" />
		<cfset var pluginManager = "" />
		<cfset var globalizationManager = "" />
		<cfset var endpointManager = "" />
		<cfset var moduleManager = "" />
		<cfset var cacheManager = "" />

		<cfset var configXml = "" />
		<cfset var configXmlFile = "" />
		<cfset var configXmls = ArrayNew(1) />
		<cfset var overrideIncludeNodes  = "" />
		<cfset var overrideIncludes = ArrayNew(1) />
		<cfset var temp = StructNew() />
		<cfset var i = "" />

		<!--- Clear the config file paths as this is important since the AppFactory is reused for full reloads --->
		<cfset resetConfigFilePaths() />

		<!--- Create the AppManager --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init(arguments.parentAppManager) />
		<cfset appManager.setAppKey(arguments.appkey) />
		<cfif Len(arguments.moduleName)>
			<cfset appManager.setModuleName(arguments.moduleName) />
		</cfif>

		<!--- Put a reference of the utils into the variables so loadIncludes can use it --->
		<cfset variables.utils = appManager.getUtils() />
		<cfset variables.engineInfo = variables.utils.getCfmlEngineInfo() />

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

		<!--- Validate the XML contents --->
		<cfset validateConfigXml(arguments.validateXml, configXmlFile, arguments.configXmlPath, arguments.configDtdPath) />
		
		<!--- Parse the XML contents --->
		<cftry>
			<cfset temp.configXml = XmlParse(configXmlFile) />
			<cfset temp.override = false />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.AppFactory.BaseConfigFileParseException"
					message="Exception occurred parsing base config file '#arguments.configXmlPath#' for module '#arguments.moduleName#'."
					detail="#variables.utils.buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Added the base config to the array --->
		<cfset ArrayAppend(configXmls, temp) />

		<!--- Load the includes --->
		<cfset configXmls = loadIncludes(configXmls, temp.configXml, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(arguments.configXmlPath), arguments.moduleName) />

		<!--- Search for includes in the overrideXml if defined --->
		<cfif Len(arguments.overrideXml)>
			<cfset configXmls = loadIncludes(configXmls, arguments.overrideXml, arguments.validateXml, arguments.configDtdPath, true, arguments.moduleName, true) />
		</cfif>

		<!---
			Create the Framework Managers and set them in the AppManager
			Creation order is important so do not change:
			* CacheManager (must be loaded first due to the cache commands loaded by Events and Subroutines)
			* PropertyManager
			* RequestManager (singleton)
			* ListenerManager
			* MessageManager
			* FilterManager
			* SubroutineManager
			* EventManager
			* ViewManager
			* PluginManager
			* GlobalizationManager
			* EndpointManager (singleton)
			* ModuleManager (singleton)
		--->

		<!--- CacheManager is not a singleton and loads no XML --->
		<cfset loadManager(appManager, "MachII.framework.CacheManager", false) />

		<!--- PropertyManager is not a singleton and loads XML --->
		<cfset loadManager(appManager, "MachII.framework.PropertyManager", false, configXmls, arguments.overrideXml) />

		<!--- RequestManager is a singleton and loads no XML --->
		<cfset loadManager(appManager, "MachII.framework.RequestManager", true) />

		<!--- These managers are not singletons and loads XML --->
		<cfset loadManager(appManager, "MachII.framework.ListenerManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.MessageManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.EventFilterManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.SubroutineManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.EventManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.ViewManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.PluginManager", false, configXmls, arguments.overrideXml) />
		<cfset loadManager(appManager, "MachII.framework.EndpointManager", false, configXmls, arguments.overrideXml) />

		<!--- GlobalizationManager is not a singleton and loads no XML --->
		<cfset loadManager(appManager, "MachII.framework.GlobalizationManager", false) />

		<cfif NOT appManager.inModule()>
			<cfset moduleManager = CreateObject("component", "MachII.framework.ModuleManager").init(appManager, GetDirectoryFromPath(arguments.configXmlPath), arguments.configDtdPath, arguments.validateXML) />
			<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
					<!--- Register the XML for later which is deferred to be loaded during configure() --->
				<cfset moduleManager.registerXml(configXmls[i].configXml, configXmls[i].override) />
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
	<cffunction name="loadManager" access="private" returntype="void" output="false"
		hint="Loads a manager in the AppManager.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true"
			hint="The AppManager for this base or module." />
		<cfargument name="managerType" type="string" required="true"
			hint="The CFC dot path type of the manager to load." />
		<cfargument name="singleton" type="boolean" required="true"
			hint="Defines is the manager is a singleton." />
		<cfargument name="configXmls" type="array" required="false"
			hint="An array of XML config files to load. Does not load any XML config files if not passed." />
		<cfargument name="overrideXml" type="string" required="false"
			hint="The override XML to set. Does not load any override XML if not passed" />

		<cfset var manager =  "" />
		<cfset var managerName = ListLast(arguments.managerType, ".") />
		<cfset var i = 0 />

		<!--- Get the parent manager if we are in a module and the manager is a singleton --->
		<cfif arguments.singleton AND arguments.appManager.inModule()>
			<cfinvoke component="#arguments.appManager.getParent()#"
				method="get#managerName#"
				returnvariable="manager" />
		<cfelse>
			<cfset manager = CreateObject("component", arguments.managerType).init(arguments.appManager) />

			<!--- Load in all the XML config files if defined --->
			<cfif StructKeyExists(arguments, "configXmls")>
				<cfloop from="1" to="#ArrayLen(arguments.configXmls)#" index="i">
					<cfset manager.loadXml(arguments.configXmls[i].configXml, arguments.configXmls[i].override) />
				</cfloop>
			</cfif>

			<!--- Load in the override XML if defined --->
			<cfif StructKeyExists(arguments, "overrideXml") AND Len(arguments.overrideXml)>
				<cfset manager.loadXml(arguments.overrideXml, true) />
			</cfif>
		</cfif>

		<!--- Load the manager in the AppManager --->
		<cfinvoke component="#arguments.appmanager#"
			method="set#managerName#">
			<cfinvokeargument name="#managerName#" value="#manager#" />
		</cfinvoke>
	</cffunction>

	<cffunction name="loadIncludes" access="private" returntype="array" output="false"
		hint="Loads files to be included into the config xml array.">
		<cfargument name="configFiles" type="array" required="true" />
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		<cfargument name="parentConfigFilePathDirectory" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="overrideIncludeType" type="boolean" required="false" default="false" />
		<cfargument name="alreadyLoaded" type="struct" required="false" default="#StructNew()#" />

		<cfset var includeNodes = XmlSearch(arguments.configXML, "mach-ii/includes/include") />
		<cfset var override = StructNew() />
		<cfset var includeFilePath = "" />
		<cfset var includeFilePathResults = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<cfif NOT arguments.overrideIncludeType>
			<cfset includeNodes = XmlSearch(arguments.configXML, "mach-ii/includes/include") />
		<cfelse>
			<cfset includeNodes = XmlSearch(arguments.configXML, ".//includes/include") />
		</cfif>

		<cfloop from="1" to="#ArrayLen(includeNodes)#" index="i">
			<cfset includeFilePath = includeNodes[i].xmlAttributes["file"] />

			<!--- If this isn't a setup override includes, then check otherwise override --->
			<cfif NOT arguments.overrideIncludeType>
				<cfif StructKeyExists(includeNodes[i].xmlAttributes, "override")>
					<cfset override = includeNodes[i].xmlAttributes["override"] />
				<cfelse>
					<cfset override = false />
				</cfif>
			<cfelse>
				<cfset override = true />
			</cfif>

			<!--- Check to see if the includeFilePath is a pattern to support **, * and ? --->
			<cfif variables.fileMatcher.isPattern(includeFilePath)>
				<cfif includeFilePath.startsWith(".")>
					<cfset includeFilePath = variables.utils.expandRelativePath(arguments.parentConfigFilePathDirectory, includeFilePath) />
					<cfset includeFilePathResults  = variables.fileMatcher.match(includeFilePath, arguments.parentConfigFilePathDirectory) />
				<cfelse>
					<cfset includeFilePath = ExpandPath(includeFilePath) />
					<cfset includeFilePathResults  = variables.fileMatcher.match(includeFilePath, variables.fileMatcher.extractPathWithoutPattern(includeFilePath)) />
				</cfif>
				
				<cfloop from="1" to="#includeFilePathResults.recordcount#" index="j">
					<cfset arguments.configFiles = loadInclude(arguments.configFiles, includeFilePathResults.fullPath[j], override, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.moduleName, arguments.overrideIncludeType, arguments.alreadyLoaded) />
				</cfloop>
			<cfelseif includeFilePath.startsWith(".")>
				<cfset includeFilePath = variables.utils.expandRelativePath(arguments.parentConfigFilePathDirectory, includeFilePath) />
				<cfset arguments.configFiles = loadInclude(arguments.configFiles, includeFilePath, override, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.moduleName, arguments.overrideIncludeType, arguments.alreadyLoaded) />
			<cfelse>
				<cfset includeFilePath = ExpandPath(includeFilePath) />
				<cfset arguments.configFiles = loadInclude(arguments.configFiles, includeFilePath, override, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.moduleName, arguments.overrideIncludeType, arguments.alreadyLoaded) />
			</cfif>
		</cfloop>

		<cfreturn arguments.configFiles />
	</cffunction>
	
	<cffunction name="loadInclude" access="private" returntype="array" output="false"
		hint="Loads an include to be included into the config xml array.">
		<cfargument name="configFiles" type="array" required="true" />
		<cfargument name="includeFilePath" type="string" required="true" />
		<cfargument name="includeFileOverride" type="string" required="true" />
		<cfargument name="validateXml" type="boolean" required="true" />
		<cfargument name="configDtdPath" type="string" required="true" />
		<cfargument name="parentConfigFilePathDirectory" type="string" required="true" />
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="overrideIncludeType" type="boolean" required="false" default="false" />
		<cfargument name="alreadyLoaded" type="struct" required="false" default="#StructNew()#" />

		<cfset var temp = StructNew() />
		<cfset var includeXmlFile = "" />
		
		<cfset temp.override = arguments.includeFileOverride />

		<!--- Check for circular dependencies (pass a struct instead of stateful variables in case there is a error and it's impossible to cleanup)--->
		<cfset checkIfAlreadyIncluded(arguments.alreadyLoaded, arguments.includeFilePath) />

		<!--- Read the include file --->
		<cftry>
			<cffile
				action="read"
				file="#arguments.includeFilePath#"
				variable="includeXMLFile" />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.CannotFindIncludeConfigFile"
					message="Unable to find the include config file in module '#arguments.moduleName#'. This could be due to an incorrect relative path."
					detail="includePath=#arguments.includeFilePath#" />
			</cfcatch>
		</cftry>

		<!--- Validate the XML contents --->
		<cfset validateConfigXml(arguments.validateXml, includeXMLFile, arguments.includeFilePath, arguments.configDtdPath) />

		<!--- Parse the XML contents --->
		<cftry>
			<cfset temp.configXml = XmlParse(includeXmlFile) />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.AppFactory.IncludeConfigFileParseException"
					message="Exception ocurred parsing include config file '#includeFilePath#' in module '#arguments.moduleName#'."
					detail="#variables.utils.buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Append the include config file to the file paths --->
		<cfset appendConfigFilePath(arguments.includeFilePath) />

		<!--- Append the parsed include file to the config xml array --->
		<cfset ArrayAppend(arguments.configFiles, temp) />

		<!--- Recursively check the currently processing include for more includes --->
		<cfreturn loadIncludes(arguments.configFiles, temp.configXml, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.moduleName, arguments.overrideIncludeType, arguments.alreadyLoaded) />
	</cffunction>

	<cffunction name="validateConfigXml" access="private" returntype="void" output="false"
		hint="Validates an xml file.">
		<cfargument name="validateXml" type="boolean" required="true"
			hint="A boolean if the XML string should be validated." />
		<cfargument name="configXml" type="any" required="true"
			hint="A string representing an XML document or a parsed XML document to be validated." />
		<cfargument name="configXmlPath" type="string" required="true"
			hint="The path to this config file." />
		<cfargument name="configDtdPath" type="string" required="true"
			hint="The path to the DTD to use for validation." />

		<cfset var validationResult = "" />
		<cfset var validationException = "" />

		<!--- Validate if directed and CF version 7 or higher --->
		<cfif arguments.validateXml AND (
					(FindNoCase("ColdFusion", variables.engineInfo.Name) AND variables.engineInfo.majorVersion GTE 7)
					OR (FindNoCase("BlueDragon", variables.engineInfo.Name) AND variables.engineInfo.majorVersion GTE 1 AND variables.engineInfo.productLevel EQ "GPL")
					OR (FindNoCase("BlueDragon", variables.engineInfo.Name) AND variables.engineInfonfo.majorVersion GTE 7 AND variables.engineInfo.productLevel NEQ "GPL")
					OR (FindNoCase("Railo", variables.engineInfo.Name) AND variables.engineInfo.majorVersion GTE 3)
			)>

			<!--- Check to see if the dtd file exists if the dtd path is not a URL --->
			<cfif NOT arguments.configDtdPath.startsWith("http://") 
				AND NOT arguments.configDtdPath.startsWith("https://") 
				AND NOT FileExists(arguments.configDtdPath)>
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