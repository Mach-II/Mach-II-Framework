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
		
		<cfset var appManager = "" />
		<cfset var propertyManager = "" />
		<cfset var requestManager = "" />
		<cfset var listenerManager = "" />
		<cfset var filterManager = "" />
		<cfset var subroutineManager = "" />
		<cfset var eventManager = "" />
		<cfset var viewManager = "" />
		<cfset var pluginManager = "" />
		<cfset var configXML = "" />
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
		
		<!--- Replace include tags with contents of include file before validating the XML --->	
		<cfset configXmlFile = loadIncludes(configXmlFile) />

		<!--- Parse the XML contents. --->
		<cfset configXML = XmlParse(configXmlFile) />
		
		<!--- Validate the XML contents (if option is on and server is CFMX7). --->
		<cfif arguments.validateXml AND ListFirst(server.ColdFusion.ProductVersion) GTE 7>
			<cfset validationResult = XmlValidate(configXML, arguments.configDtdPath)>
			<cfif NOT validationResult.Status>
				<cfset validationException = CreateObject("component", "MachII.util.XmlValidationException") />
				<cfset validationException.wrapValidationResult(validationResult, arguments.configXmlpath, arguments.configDtdPath) />
				<cfthrow type="MachII.framework.XmlValidationException" 
					message="#validationException.getFormattedMessage()#" />
			</cfif>
		</cfif>
		
		<!--- Create the AppManager. --->
		<cfset appManager = CreateObject("component", "MachII.framework.AppManager").init() />
		
		<!--- 
		Create the Framework Managers and set them in the AppManager. 
		Creation order is important: propertyManager first, requestManager, listenerManager, filterManager and subroutineManager before eventManager. 
		--->
		<cfset propertyManager = CreateObject("component", "MachII.framework.PropertyManager").init(configXML, appManager) />
		<cfset appManager.setPropertyManager(propertyManager) />
		
		<cfset requestManager = CreateObject("component", "MachII.framework.RequestManager").init(appManager) />
		<cfset appManager.setRequestManager(requestManager) />
		
		<cfset listenerManager = CreateObject("component", "MachII.framework.ListenerManager").init(configXML, appManager) />
		<cfset appManager.setListenerManager(listenerManager) />
		
		<cfset filterManager = CreateObject("component", "MachII.framework.FilterManager").init(configXML, appManager) />
		<cfset appManager.setFilterManager(filterManager) />

		<cfset subroutineManager = CreateObject("component", "MachII.framework.SubroutineManager").init(configXML, appManager) />
		<cfset appManager.setSubroutineManager(subroutineManager) />
				
		<cfset eventManager = CreateObject("component", "MachII.framework.EventManager").init(configXML, appManager) />
		<cfset appManager.setEventManager(eventManager) />
		
		<cfset viewManager = CreateObject("component", "MachII.framework.ViewManager").init(configXML, appManager) />
		<cfset appManager.setViewManager(viewManager) />
		
		<cfset pluginManager = CreateObject("component", "MachII.framework.PluginManager").init(configXML, appManager) />
		<cfset appManager.setPluginManager(pluginManager) />
		
		<cfset appManager.configure() />
		
		<cfreturn appManager />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="loadIncludes" access="private" returntype="string" output="false"
		hint="Loads files to be included">
		<cfargument name="configXMLFile" type="string" required="true" />
		
		<cfset var includePosition = 0 />
		<cfset var includeFilePosition = 0 />
		<cfset var includeFilePath = "" />
		<cfset var includeXMLFile = "" />
		
		<!--- Replace include tags with contents of include file before validating again --->	
		<cfset includePosition = REFindNoCase('<include file=("|'')', arguments.configXMLFile, includePosition) />
		<cfloop condition="includePosition gt 0">	
			<cfset includeEndPosition = REFindNoCase('("|'')( )?/>', arguments.configXMLFile, includePosition + 15) />
			<cfset includeFilePath = Mid(arguments.configXMLFile, includePosition + 15, 
					(includeEndPosition - (includePosition + 15))) />
			
			<!--- Read the include file --->
			<cftry>
				<cffile
					action="read"
					file="#expandPath(includeFilePath)#"
					variable="includeXMLFile" />
				<cfcatch type="any">
					<cfthrow type="MachII.framework.CannotFindIncludeConfigFile"
						message="Unable to find the include config file."
						detail="includePath=#expandPath(includeFilePath)#" />
				</cfcatch>
			</cftry>
		
			<!--- Recursively check the include for more includes --->
			<cfset includeXMLFile = loadIncludes(includeXMLFile) />
			
			<!--- Replace the include tag body with contents of include file --->
			<cfset configXMLFile = REReplaceNoCase(arguments.configXMLFile, '<include file=("|'')#includeFilePath#("|'')( )?/>', includeXMLFile, "ALL") />
			
			<!--- Find the next include tag --->
			<cfset includePosition = REFindNoCase('<include file=("|'')', arguments.configXMLFile, includePosition) />
		</cfloop>
		
		<cfreturn arguments.configXMLFile />
	</cffunction>
	
</cfcomponent>