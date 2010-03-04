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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

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
		<cftry>
			<cfset temp.configXml = XmlParse(configXmlFile) />
			<cfset temp.override = false />
			<cfcatch type="any">
				<cfthrow type="MachII.framework.AppFactory.BaseConfigFileParseException"
					message="Exception occurred parsing base config file '#arguments.configXmlPath#' for module '#arguments.moduleName#'."
					detail="#variables.utils.buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>
		
		<!--- Validate the XML contents --->
		<cfset validateConfigXml(arguments.validateXml, temp.configXml, arguments.configXmlPath, arguments.configDtdPath) />

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
		Creation order is important (do not change!):
		cacheManager, propertyManager, requestManager, listenerManager, messageManager, filterManager, 
		subroutineManager, eventManager, viewManager, pluginManager, globalizationManager and then moduleManager
		--->
		<!--- The cacheManager does load in any xml. The cache commands are loaded in by the 
			eventManager and the subroutineManager when looks through its commands. Needs to be loaded
			before the property manager so its cache strategies can get loaded in. --->
		<cfset cacheManager = CreateObject("component", "MachII.framework.CacheManager").init(appManager) />
		<cfset appManager.setCacheManager(cacheManager) />
		
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(appManager) />
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
		<cfif appManager.inModule()>
			<cfset appManager.setRequestManager(appManager.getParent().getRequestManager()) />
		<cfelse>
			<cfset appManager.setRequestManager(requestManager) />
		</cfif>

		<cfset listenerManager = CreateObject("component", "MachII.framework.ListenerManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset listenerManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset listenerManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setListenerManager(listenerManager) />

		<cfset messageManager = CreateObject("component", "MachII.framework.MessageManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset messageManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset messageManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setMessageManager(messageManager) />
		
		<cfset filterManager = CreateObject("component", "MachII.framework.EventFilterManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset filterManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset filterManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setFilterManager(filterManager) />

		<cfset subroutineManager = CreateObject("component", "MachII.framework.SubroutineManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset subroutineManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset subroutineManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setSubroutineManager(subroutineManager) />
				
		<cfset eventManager = CreateObject("component", "MachII.framework.EventManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset eventManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset eventManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setEventManager(eventManager) />
		
		<cfset viewManager = CreateObject("component", "MachII.framework.ViewManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset viewManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset viewManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setViewManager(viewManager) />
		
		<cfset pluginManager = CreateObject("component", "MachII.framework.PluginManager").init(appManager) />
		<cfloop from="1" to="#ArrayLen(configXmls)#" index="i">
			<cfset pluginManager.loadXml(configXmls[i].configXml, configXmls[i].override) />
		</cfloop>
		<cfif Len(arguments.overrideXml)>
			<cfset pluginManager.loadXml(arguments.overrideXml, true) />
		</cfif>
		<cfset appManager.setPluginManager(pluginManager) />
		
		<!--- The globalizationManager doesn't load any xml; all configuration information is taken from
			the globalizationConfigProperty --->
		<cfset globalizationManager = CreateObject("component", "MachII.framework.GlobalizationManager").init(appManager) />
		<cfset appManager.setGlobalizationManager(globalizationManager) />
		
		<!--- ModuleManager is a singleton across the application --->
		<cfif NOT appManager.inModule()>
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
		<cfargument name="moduleName" type="string" required="true" />
		<cfargument name="overrideIncludeType" type="boolean" required="false" default="false" />
		<cfargument name="alreadyLoaded" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var includeNodes = XmlSearch(arguments.configXML, "mach-ii/includes/include") />
		<cfset var temp = StructNew() />
		<cfset var includeFilePath = "" />
		<cfset var includeXmlFile = "" />
		<cfset var i = 0 />
		
		<cfif NOT arguments.overrideIncludeType>
			<cfset includeNodes = XmlSearch(arguments.configXML, "mach-ii/includes/include") />
		<cfelse>
			<cfset includeNodes = XmlSearch(arguments.configXML, ".//includes/include") />
		</cfif>
		
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
						message="Unable to find the include config file in module '#arguments.moduleName#'. This could be due to an incorrect relative path."
						detail="includePath=#includeFilePath#" />
				</cfcatch>
			</cftry>
			
			<!--- Parse the XML contents --->
			<cftry>
				<cfset temp.configXml = XmlParse(includeXmlFile) />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.AppFactory.IncludeConfigFileParseException"
						message="Exception ocurred parsing include config file '#includeFilePath#' in module '#arguments.moduleName#'."
						detail="#variables.utils.buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
			</cftry>

			<!--- Validate the XML contents --->
			<cfset validateConfigXml(arguments.validateXml, temp.configXml, includeFilePath, arguments.configDtdPath) />
			
			<!--- Append the include config file to the file paths --->
			<cfset appendConfigFilePath(includeFilePath) />
			
			<!--- Append the parsed include file to the config xml array --->
			<cfset ArrayAppend(arguments.configFiles, temp) />
			
			<!--- Recursively check the currently processing include for more includes --->
			<cfset arguments.configFiles = loadIncludes(arguments.configFiles, temp.configXml, arguments.validateXml, arguments.configDtdPath, GetDirectoryFromPath(includeFilePath), arguments.moduleName, arguments.overrideIncludeType, arguments.alreadyLoaded) />
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
		<cfset var vendorName = server.ColdFusion.ProductName />
		<cfset var vendorMajorVersion = ListFirst(server.ColdFusion.ProductVersion) />
		<cfset var vendorLevel = server.ColdFusion.ProductLevel />
		
		<!--- Validate if directed and CF version 7 or higher --->
		<cfif arguments.validateXml AND (
					(FindNoCase("ColdFusion", vendorName) AND vendorMajorVersion GTE 7)
					OR (FindNoCase("BlueDragon", vendorName) AND vendorMajorVersion GTE 1 AND vendorLevel EQ "GPL")
					OR (FindNoCase("BlueDragon", vendorName) AND vendorMajorVersion GTE 7 AND vendorLevel NEQ "GPL")
					OR (FindNoCase("Railo", vendorName) AND vendorMajorVersion GTE 3)
				)>
			
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