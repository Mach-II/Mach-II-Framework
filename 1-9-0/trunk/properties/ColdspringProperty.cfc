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

Created version: 1.5.0
Updated version: 1.8.0

Original license from the ColdSpring project (http://www.coldspringframework.org):
------------------------------------------------------------------------------------------
Copyright (c) 2007, David Ross, Chris Scott, Kurt Wiersma, Sean Corfield, Peter J. Farrell

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
------------------------------------------------------------------------------------------

Notes:
A Mach-II property that provides easy ColdSpring integration with Mach-II applications.

Special thanks to GreatBizTools, LLC and Peter J. Farrell for donating the improvements
to this integration component for Mach-II.

Usage:
<property name="coldSpringProperty" type="MachII.properties.ColdspringProperty">
	<parameters>
		<!-- Name of a Mach-II property name that will hold a reference to the ColdSpring beanFactory
			Default: 'coldspring.beanfactory.root' -->
		<parameter name="beanFactoryPropertyName" value="serviceFactory"/>

		<!-- Takes the path to the ColdSpring config file
			(required) -->
		<parameter name="configFile" value="/path/to/services.xml"/>

		<!-- Flag to indicate whether supplied config path is relative (mapped) or absolute
			Default: FALSE (absolute path) -->
		<parameter name="configFilePathIsRelative" value="true"/>

		<!-- Flag to indicate whether to resolve dependencies for
			listeners/filters/plugins/properties using introspection and new
			dynamic autowire method generation feature.
			Default: FALSE -->
		<parameter name="resolveMachIIDependencies" value="false"/>

		<!-- Indicates a scope to pull in a parent bean factory into a child bean factory
			 Default: application
		<parameter name="parentBeanFactoryScope" value="application"/>
		-->

		<!-- Indicates a key to pull in a parent bean factory from the application scope
			Default: FALSE
		<parameter name="parentBeanFactoryKey" value="serviceFactory"/>
		-->

		<!-- Indicates whether or not to place the bean factory in the application scope
			 Default: FALSE
		<parameter name="placeFactoryInApplicationScope" value="false" />
		-->

		<!-- Indicates whether or not to place the bean factory in the server scope
			 Default: FALSE
		<parameter name="placeFactoryInServerScope" value="false" />
		-->

		<!-- Flag to indicate whether to automatically generate remote proxies for you
			Does not generate remote proxies in parent bean factories.
			Default: FALSE
		<parameter name="generateRemoteProxies" value="true" />
		-->

		<!-- Indicates the autowire attribute name to introspect in cfcomponent tags
			Default: 'depends'
		<parameter name="autowireAttributeName" value="depends" />
		-->

		<!-- Indicates where to write the temporary CFCs of the dynamic autowire method
			generation feature. Specify a path that can be expanded via expandPath().
			Default: to current location of ColdspringProperty.cfc
			DO NOT DEFINE THESE PARAMETERS UNLESS YOU WANT TO OVERRIDE THE DEFAULT
		<parameter name="cfcGenerationLocation" value="PathThatCanBeExpanded" />
		-->

		<!-- Indicates the dot path to where the temporary CFCs of the dynamic autowire method
			generation feature.
			DO NOT DEFINE THESE PARAMETERS UNLESS YOU WANT TO OVERRIDE THE DEFAULT
		<parameter name="dotPathToCfcGenerationLocation" value="DotPathToCFCGenerationLocation" />
		-->

		<!-- Struct of bean names and corresponding Mach-II property names for injecting back into Mach-II
			Default: does nothing if struct is not defined
		<parameter name="beansToMachIIProperties">
			<struct>
				<key name="ColdSpringBeanName1" value="MachIIPropertyName1" />
				<key name="ColdSpringBeanName2" value="MachIIPropertyName2" />
			</struct>
		</parameter>
		-->
	</parameters>
</property>

The [beanFactoryPropertyName] parameter value is the name of the Mach-II property name
that will hold a reference to the ColdSpring beanFactory. This parameter
defaults to "coldspring.beanfactory.root" if not defined.

The [configFile] paramater value holds the path of the ColdSpring configuration file. The path
can be an relative, ColdFusion mapped or absolute path. If you are using a relative or mapped
path, be sure to set the [configFilePathIsRelative] parameter to TRUE or the ColdSpring will
not find your configuration file.

The [configGilePathIsRelative] parameter value defines if the configure file is an relative
(including ColdFusion mapped) or absolute path. If you are using a relative or mapped
path, be sure to set the [configFilePathIsRelative] parameter to TRUE or the property will
not find your configuration file.
- TRUE (for relative or mapped configuration file paths)
- FALSE (for absolute configuration file paths)

The [resolveMachIIDependencies] parameter value indicates if the property to "automagically"
wire Mach-II listeners/filters/plugins/properties.  This parameter defaults to FALSE if not defined.
- TRUE (resolves all Mach-II dependencies)
- FALSE (does not resolve Mach-II dependencies)

The [parentBeanFactoryScope] parameter values defines which scope to pull in a parent bean
factory. This parameter defaults to 'false' if not defined and indicates that a parent bean
factory does not need to be referenced.

The [parentBeanFactoryKey] parameter values defines a key to pull in a parent bean factory
from the scope specified in the [parentBeanFactoryKey] parameter.  This parameter defaults
to 'false' if not defined and indicates that a parent bean factory does not need to be referenced.

The [placeFactoryInApplicationScope] parameter indicates whether or not to place the bean factory
in the application scope.  This parameter is used to for setting your bean factory for use as a
parent.  The key that used is driven from the value from of the [beanFactoryPropertyName] parameter.
If the parent uses the same value for the beanFactoryPropertyName, the module name (e.g. "_account")
is append to the end of the key to eliminate namespace conflicts in the application scope.
This parameter defaults to 'false' if not defined and indicates that this bean factory should not
be placed in the application scope.

The [placeFactoryInServerScope] parameter indicates whether or not to place the bean factory
in the server scope.  This parameter is used to for setting your bean factory for use as a
parent.  The key that used is driven from the value from of the [beanFactoryPropertyName] parameter.
If the parent uses the same value for the beanFactoryPropertyName, the module name (e.g. "_account")
is append to the end of the key to eliminate namespace conflicts in the server scope.
This parameter defaults to 'false' if not defined and indicates that this bean factory should not
be placed in the server scope.

The [autowireAttributeName] parameter indicates the name of the attribute to introspect
for in cfcomponent tags when using the dynamic autowire method generation feature of the
Coldspring Property.  Autowire method generation injection allows you to put a list of ColdSpring
bean names in the autowire attribute (which default to 'depends') in cfcomponent tag of your
listeners, filters, plugins and properties CFC in Mach-II. ColdSpring property will automatically
generate and dynamically inject getters/setters for the listed bean names into your target
cfc at runtime.  This does not modify the contents of the cfc file, but injects dynamically
while the cfc is in memory.  This feature allows you to stop having to type out getters/setters
for the service that you want ColdSpring to inject into your cfc.

Example:
<cfcomponent extends="MachII.framework.Listener" depends="someService">
	... additional code ...
</cfcomponent>

This will dynamically inject a getSomeService() and setSomeService() method into this listener.
ColdSpring will then use the bean name and use setter injection to inject the bean into the
listener.

The [cfcGenerationLocation] parameter indicates where to write the temporary CFCs of the
dynamic autowire method generation feature. Specify a path that can be expanded via
expandPath(). Defaults to current location of ColdspringProperty.cfc.
DO NOT DEFINE THESE PARAMETERS UNLESS YOU WANT TO OVERRIDE THE DEFAULT

The [dotPathToCfcGenerationLocation] parameter indicates the dot path to where temporary CFCs
are written for the dynamic autowire method generation feature.
DO NOT DEFINE THESE PARAMETERS UNLESS YOU WANT TO OVERRIDE THE DEFAULT

The [beansToMachIIProperties] parameter holds a struct of bean names and corresponding
Mach-II property names. This parameter will inject the specified beans in the Mach-II property
manager as the bean factory has been loaded.  In the past, a seperate property has to be written
to accomplish this task. This should be used for framework required "utility" objects that you
want to be managed by ColdSpring such as UDF, i18n or session facade objects. Do not use this
feature to inject your model objects into the Mach-II property manager.

Parent/Child Bean Factories Configuration for Use with Modules:

Base Mach-II Config File (i.e. Parent Factory)
<property name="ColdSpring" type="MachII.properties.ColdspringProperty">
	<parameters>
		<parameter name="beanFactoryPropertyName" value="serviceFactory"/>
		<parameter name="configFile" value="/path/to/config/services.xml"/>
		<parameter name="configFilePathIsRelative" value="true"/>
		<parameter name="placeFactoryInApplicationScope" value="true"/>
		<parameter name="resolveMachIIDependencies" value="true"/>
	</parameters>
</property>

You must put the parent bean factory in the application (or server scope) in order
for a module to inherit from a parent factory. This example put the parent factory
into the application.serviceFactory variable.

Account Module Config File (i.e. Child Factory):
<property name="ColdSpring" type="MachII.properties.ColdspringProperty">
	<parameters>
		<parameter name="beanFactoryPropertyName" value="serviceFactory"/>
		<parameter name="configFile" value="/path/to/modules/account/config/services_account.xml"/>
		<parameter name="configFilePathIsRelative" value="true"/>
		<parameter name="resolveMachIIDependencies" value="true"/>
		<parameter name="placeFactoryInApplicationScope" value="true"/>
		<parameter name="parentBeanFactoryScope" value="application"/>
		<parameter name="parentBeanFactoryKey" value="serviceFactory"/>
	</parameters>
</property>

You are NOT required to put child factories into the application (or server scope) for
modules to inherit froma a parent factory. However, in this example the account module
puts this child factory into the application scope. Since the parent and module use the
same beanFactoryPropertyName, an application scope namespace conflict would occur - so
the Property appends the module name to the end. This factory would be located in
application.serviceFactory_account variable.

--->
<cfcomponent
	name="ColdspringProperty"
	extends="MachII.framework.Property"
	hint="A Mach-II application property for easy ColdSpring integration"
	output="false">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="I initialize this property during framework startup.">

		<!--- Default vars --->
		<cfset var bf = "" />
		<cfset var factoryKey = "" />
		<cfset var i = 0 />

		<!--- Get the Mach-II property manager (gets the a module's property manager if this is a module) --->
		<cfset var propertyManager = getPropertyManager() />

		<!--- Determine the location of the bean def xml file --->
		<cfset var serviceDefXmlLocation = "" />

		<!--- Get all properties to pass to bean factory
			Create a new struct instead of doing a direct assignment otherwise parent
			property managers will suddendly have properties from modules since
			structs are by passed by reference
		--->
		<cfset var defaultProperties = StructNew() />

		<!--- todo: Default attributes set via mach-ii params --->
		<cfset var defaultAttributes = StructNew() />

		<!--- Locating and storing bean factory (from properties/params) --->
		<cfset var bfUtils = CreateObject("component", "coldspring.beans.util.BeanFactoryUtils").init() />
		<cfset var parentBeanFactoryScope = getParameter("parentBeanFactoryScope", "application") />
		<cfset var parentBeanFactoryKey = getParameter("parentBeanFactoryKey", "") />
		<cfset var localBeanFactoryKey = getParameter("beanFactoryPropertyName", bfUtils.DEFAULT_FACTORY_KEY) />

		<cfset var temp = "" />

		<!--- Test for getFileInfo() --->
		<cftry>
			<cfset getFileInfo(ExpandPath("./ColdspringProperty.cfc")) />
			<cfcatch type="any">
				<cfset variables.getFileInfo = getUtils().getFileInfo_cfdirectory />
				<cfset this.getFileInfo = getUtils().getFileInfo_cfdirectory />
			</cfcatch>
		</cftry>

		<!--- Set the autowire attribute name --->
		<cfset setAutowireAttributeName(getParameter("autowireAttributeName", "depends")) />

		<!--- Get the config file path --->
		<cfset getAssert().hasLength(getParameter("configFile")
				, "You must specify a parameter named 'configFile'.") />
		<cfset serviceDefXmlLocation = getParameter("configFile") />

		<!--- Get the properties from the current property manager --->
		<cfset StructAppend(defaultProperties, propertyManager.getProperties()) />

		<!--- Append the parent's default properties if we have a parent --->
		<cfif IsObject(getAppManager().getParent())>
			<cfset StructAppend(defaultProperties, propertyManager.getParent().getProperties(), false) />
		</cfif>

		<!--- Evaluate any dynamic properties --->
		<cfloop collection="#defaultProperties#" item="i">
			<cfif IsSimpleValue(defaultProperties[i]) AND REFindNoCase("\${(.)*?}", defaultProperties[i])>
				<cfset defaultProperties[i] = Evaluate(Mid(defaultProperties[i], 3, Len(defaultProperties[i]) -3)) />
			</cfif>
		</cfloop>

		<!--- Add in a reference to AppManager for the UtilityConnectBeanFactoryPostProcessor --->
		<cfset defaultProperties["_MachIIAppManager"] = getAppManager() />

		<!--- Create a new bean factory --->
		<cfset bf = CreateObject("component", "coldspring.beans.DefaultXmlBeanFactory").init(defaultAttributes, defaultProperties) />

		<!--- Put a bean factory reference into Mach-II property manager --->
		<cfset setProperty("beanFactoryName", localBeanFactoryKey) />
		<cfset setProperty(localBeanFactoryKey, bf) />

		<!---
			Inject a bean factory post processor to aid in the wiring of the UtilityConnector (Tickets 540 and 799)
			wich must be done before the BF is loaded due to non-lazy load beans possibly requiring the UtilityConnector
		--->
		<cfset injectUtilityConnectorBeanFactoryPostProcessorDefinition() />

		<!--- If necessary setup the parent bean factory using the new ApplicationContextUtils --->
		<cfif Len(parentBeanFactoryKey) AND bfUtils.namedFactoryExists(parentBeanFactoryScope, parentBeanFactoryKey)>
			<cfset bf.setParent(bfUtils.getNamedFactory(parentBeanFactoryScope, parentBeanFactoryKey))/>
		</cfif>

		<!--- Expand path for relative and mapped config file paths --->
		<cfif getParameter("configFilePathIsRelative", false)>
			<cfset serviceDefXmlLocation = ExpandPath(serviceDefXmlLocation) />
		</cfif>

		<!--- Load the bean defs --->
		<cftry>
			<cfset bf.loadBeansFromXmlFile(serviceDefXmlLocation, true) />
			<cfcatch type="any">
				<cfthrow type="MachII.properties.ColdSpringProperty.LoadBeansFromXmlFileException"
					message="A ColdSpring load XML file exception occurred in module '#getAppManager().getModuleName()#'."
					detail="#getAppManager().getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>

		<!--- Figure out application/server key --->
		<cfset factoryKey = localBeanFactoryKey />

		<!--- Append the module the parent and child are using the same property name for the bean factory --->
		<cfif Len(getAppManager().getModuleName()) AND getAppManager().getParent().getPropertyManager().isPropertyDefined(localBeanFactoryKey)>
			<cfset factoryKey = factoryKey & "_" & getAppManager().getModuleName() />
		</cfif>

		<!--- Put a bean factory reference into the application or server scopes if required --->
		<cfif getParameter("placeFactoryInApplicationScope", false)>
			<cfset bfUtils.setNamedFactory("application", factoryKey, bf) />
		</cfif>
		<cfif getParameter("placeFactoryInServerScope", false)>
			<cfset bfUtils.setNamedFactory("server", factoryKey, bf) />
		</cfif>

		<!--- Resolve Mach-II dependences if required and application is not
			loading (because during load Mach-II will call onObjectReload and
			this is needed when the CS property is being reloaded) --->
		<cfif NOT getAppManager().isLoading()>
			<cfset resolveDependencies() />
		</cfif>

		<!--- Generate the remote proxies if required --->
		<cfif getParameter("generateRemoteProxies", false)>
			<cfset generateRemoteProxies() />
		</cfif>

		<!--- Place bean references into the Mach-II properties if required --->
		<cfif isParameterDefined("beansToMachIIProperties")>
			<cfset getAssert().isTrue(IsStruct(getParameter("beansToMachIIProperties"))
					, "The value of a parameter named 'beansToMachIIProperties' must contain a struct.") />
			<cfset referenceBeansToMachIIProperties(getParameter("beansToMachIIProperties")) />
		</cfif>

		<!--- Build the config files and hash --->
		<cfset setConfigFilePaths(buildConfigFilePaths(serviceDefXmlLocation)) />
		<cfset setLastReloadHash(getConfigFileReloadHash()) />
		<cfset setLastReloadDatetime(Now()) />

		<!--- Register as onPostObjectReload callback --->
		<cfset getAppManager().addOnObjectReloadCallback(this, "resolveDependency") />
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Deregisters ColdSpring as an available DI engine interface.">

		<!--- Deregister as onPostObjectReload callback --->
		<cfset getAppManager().removeOnObjectReloadCallback(this) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="shouldReloadConfig" access="public" returntype="boolean" output="false"
		hint="Checks if the bean factory config file or any of its' imports have changed.">

		<cfset var result = false />

		<cfif CompareNoCase(getLastReloadHash(), getConfigFileReloadHash()) NEQ 0>
			<cfset result = true />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="generateRemoteProxies" access="public" returntype="void" output="false"
		hint="Generates all the remote proxies that are of type 'coldspring.aop.framework.RemoteFactoryBean'.">

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />
		<!--- Names of remote proxies. Do not check the parent since remote proxy generation. --->
		<cfset var remoteProxyNames = beanFactory.findAllBeanNamesByType("coldspring.aop.framework.RemoteFactoryBean", false) />
		<cfset var remoteProxy = "" />
		<cfset var i = "" />

		<!--- Generate all the remote proxies --->
		<cfloop from="1" to="#ArrayLen(remoteProxyNames)#" index="i">
			<!--- Get the remote proxy api by using the ampersand with the bean name --->
			<cfset remoteProxy = beanFactory.getBean("&" & remoteProxyNames[i]) />

			<!--- Destroy the proxy if already constructed.
				Must check if already constructed or it will cause an exception --->
			<cfif remoteProxy.isConstructed()>
				<cfset remoteProxy.destroyRemoteProxy() />
			</cfif>

			<!--- Create the proxy --->
			<cfset remoteProxy.createRemoteProxy() />
		</cfloop>
	</cffunction>

	<cffunction name="resolveDependencies" access="public" returntype="void" output="false"
		hint="Resolves Mach-II dependencies.">

		<cfset var targetBase = StructNew() />
		<cfset var targetObj = 0 />
		<cfset var targetMetadata = "" />
		<cfset var autowireAttributeName = getAutowireAttributeName() />
		<cfset var i = 0 />

		<!--- Only resolve if dependency resolution is on --->
		<cfif getParameter("resolveMachIIDependencies", false)>
			<cfset targetBase.targets = ArrayNew(1) />

			<!--- Get listener/filter/plugin/property targets --->
			<cfset getListeners(targetBase) />
			<cfset getFilters(targetBase) />
			<cfset getPlugins(targetBase) />
			<cfset getConfigurableProperties(targetBase) />
			<cfset getEndpoints(targetBase) />

			<cfloop from="1" to="#ArrayLen(targetBase.targets)#" index="i">
				<!--- Get this iteration target object for easy use --->
				<cfset targetObj =  targetBase.targets[i] />

				<!--- Get metadata --->
				<cfset targetMetadata = GetMetadata(targetObj) />

				<!--- Autowire by dynamic method generation --->
				<cfset autowireByDynamicMethodGeneration(targetObj, targetMetadata, autowireAttributeName) />

				<!--- Autowire by defined setters --->
				<cfset autowireByDefinedSetters(targetObj, targetMetadata) />
			</cfloop>
		</cfif>

		<!--- Autowire configurale commands --->
		<cfset targetBase.targets = ArrayNew(1) />

		<cfset getConfigurableCommands(targetBase) />

		<!--- Autowire all commands --->
		<cfloop from="1" to="#ArrayLen(targetBase.targets)#" index="i">
			<!--- Get this iteration target object for easy use --->
			<cfset targetObj =  targetBase.targets[i] />

			<!--- Get metadata --->
			<cfset targetMetadata = GetMetadata(targetObj) />

			<!--- Autowire by value from bean id method --->
			<cfset autowireByBeanIdValue(targetObj, targetMetadata) />
		</cfloop>
	</cffunction>

	<cffunction name="resolveDependency" access="public" returntype="void" output="false"
		hint="Resolves Mach-II dependency by passed object.">
		<cfargument name="targetObject" type="any" required="true"
			hint="Target object to resolve dependency." />

		<!--- Look for autowirable collaborators for any setters --->
		<cfset var targetMetadata = GetMetadata(arguments.targetObject) />
		<cfset var extendsMetadata = GetMetadata(arguments.targetObject) />

		<!--- If target object is a command --->
		<cfif StructKeyExists(targetMetadata, "extends") AND targetMetadata.extends.name EQ "MachII.framework.Command">

		<!--- Autowire by value from bean id method --->
		<cfset autowireByBeanIdValue(arguments.targetObject, targetMetadata) />

		<!--- Only resolve if dependency resolution is on --->
		<cfelseif getParameter("resolveMachIIDependencies", false)>

			<cfif NOT structKeyExists(targetMetadata, "depends")>
				<cfset targetMetadata.depends = "" />
			</cfif>

			<!--- Loop through all extended objects looking for injection targets --->
			<cfloop condition="structKeyExists(extendsMetadata, 'extends') AND isStruct(extendsMetadata.extends)">
				<cfset extendsMetadata = extendsMetadata.extends />

				<!--- Must make sure dependant isn't already defined at the top level --->
				<cfif structKeyExists(extendsMetadata, "depends") AND len(extendsMetadata.depends) AND NOT listFindNoCase(targetMetadata.depends, extendsMetadata.depends)>
					<!--- Add dependants to top level metadata for later rendering --->
					<cfset targetMetadata.depends = listAppend(targetMetadata.depends, extendsMetadata.depends) />
				</cfif>
			</cfloop>

			<!--- Autowire by dynamic method generation --->
			<cfset autowireByDynamicMethodGeneration(arguments.targetObject, targetMetadata, getAutowireAttributeName()) />

			<!--- Autowire by defined setters --->
			<cfset autowireByDefinedSetters(arguments.targetObject, targetMetadata) />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="buildConfigFilePaths" access="private" returntype="array" output="false"
		hint="Builds an array of config file paths.">
		<cfargument name="baseConfigFilePath" type="string" required="true" />

		<cfset var configFiles = ArrayNew(1) />
		<cfset var imports = StructNew() />
		<cfset var i = "" />

		<!--- Add any imports by using the bean factory's built-in functionality --->
		<cfset getProperty(getProperty("beanFactoryName")).findImports(imports, arguments.baseConfigFilePath) />

		<!--- FindImports does not return a variable, but the data is available in the imports var via reference --->
		<cfloop collection="#imports#" item="i">
			<cfset ArrayAppend(configFiles, i) />
		</cfloop>

		<cfreturn configFiles />
	</cffunction>

	<cffunction name="getConfigFileReloadHash" access="private" returntype="string" output="false"
		hint="Get the current reload hash of the bean factory config file and imports files.  The hash is based on dateLastModified and size of the file.">

		<cfset var configFilePaths = getConfigFilePaths() />
		<cfset var fileInfo = "" />
		<cfset var hashableString = "" />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(configFilePaths)#" index="i">
			<cfset fileInfo = getFileInfo(configFilePaths[i]) />
			<cfset hashableString = hashableString & fileInfo.lastModified & fileInfo.size />
		</cfloop>

		<cfreturn Hash(hashableString) />
	</cffunction>

	<cffunction name="autowireByBeanIdValue" access="private" returntype="void" output="false"
		hint="Autowires by the value from the bean id method.">
		<cfargument name="targetObj" type="any" required="true" />
		<cfargument name="targetObjMetadata" type="any" required="true" />

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />
		<cfset var beanName = arguments.targetObj.getBeanId() />

		<cftry>
			<cfinvoke component="#arguments.targetObj#" method="setBean">
				<cfinvokeargument name="bean" value="#beanFactory.getBean(beanName)#" />
			</cfinvoke>
			<!--- Faster to fast fail and handle a missing bean exception than to check if the bean exists in the factory --->
			<cfcatch type="all">
				<cfthrow message="Cannot find bean named '#beanName#' to autowire by method injection in a '#ListLast(targetObjMetadata.extends.name, '.')#' of type '#targetObjMetadata.name#' in module '#getAppManager().getModuleName()#'."
					detail="Original Exception: #getUtils().buildMessageFromCfCatch(cfcatch)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="autowireByDynamicMethodGeneration" access="private" returntype="void" output="false"
		hint="Autowires by dynamic method generation.">
		<cfargument name="targetObj" type="any" required="true" />
		<cfargument name="targetObjMetadata" type="any" required="true" />
		<cfargument name="autowireAttributeName" type="string" required="true" />

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />
		<cfset var autowireBeanNames = "" />
		<cfset var beanName = "" />
		<cfset var targets = StructNew() />
		<cfset var autowireCfc = "" />
		<cfset var i = 0 />

		<!--- Autowire by concrete setters (dynamically injected setters do not show up in the metadata) --->
		<cfif StructKeyExists(arguments.targetObjMetadata, arguments.autowireAttributeName)>

			<!--- Get all of the bean names to autowire --->
			<cfset autowireBeanNames = ListToArray(getUtils().trimList(arguments.targetObjMetadata[arguments.autowireAttributeName])) />

			<!--- Generate and instantiate autowire component with the getter/setter methods --->
			<cfset autowireCfc = CreateObject("component", "MachII.util.injection.GetterSetterInjectionMethods").init(autowireBeanNames) />

			<!--- Build all the targets --->
			<cftry>
				<cfloop from="1" to="#ArrayLen(autowireBeanNames)#" index="i">
					<cfset beanName = autowireBeanNames[i] />

					<!--- Add appropriate bean if the factory has a bean by that name --->
					<cfset targets[beanName] = beanFactory.getBean(beanName) />
				</cfloop>
				<!--- Faster to fast fail and handle a missing bean exception than to check if the bean exists in the factory --->
				<cfcatch type="any">
					<!--- Not all CFML engines support "metadata.fullname" so use "metadata.name" --->
					<cfthrow type="MachII.properties.ColdSpringProperty.NoBean"
						message="Cannot load bean named '#beanName#' to autowire by method injection in a '#ListLast(targetObjMetadata.extends.name, '.')#' of type '#targetObjMetadata.name#' in module '#getAppManager().getModuleName()#'."
						detail="Original Exception: #getUtils().buildMessageFromCfCatch(cfcatch)#" />
				</cfcatch>
			</cftry>

			<!--- Inject the _methodInject() so we can get the methods into the variables scope
				in addition to the this scope of the component --->
			<cfset arguments.targetObj["_injectMethods"] = autowireCfc["_injectMethods"] />

			<!--- Now inject everything into the target --->
			<cfset arguments.targetObj._injectMethods(autowireCfc, targets) />

			<!--- Delete the _methodInject() from the target --->
			<cfset StructDelete(arguments.targetObj, "_injectMethods") />
		</cfif>
	</cffunction>

	<cffunction name="autowireByDefinedSetters" access="private" returntype="void" output="false"
		hint="Autowires by defined setters.">
		<cfargument name="targetObj" type="any" required="true" />
		<cfargument name="targetObjMetadata" type="any" required="true" />

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />
		<cfset var functionMetadata = "" />
		<cfset var setterName = "" />
		<cfset var beanName = "" />
		<cfset var access = "" />
		<cfset var i = 0 />

		<!--- If this object extends another, fetch sub-injection targets first --->
		<cfif structKeyExists(targetObjMetadata, "extends") and isStruct(targetObjMetadata.extends)>
			<cfset autowireByDefinedSetters(arguments.targetObj, targetObjMetadata.extends) />
		</cfif>

		<!--- Autowire by concrete setters (dynamically injected setters do not show up in the metadata) --->
		<cfif StructKeyExists(arguments.targetObjMetadata, "functions")>
			<cfloop from="1" to="#ArrayLen(arguments.targetObjMetadata.functions)#" index="i">
				<cfset functionMetadata = arguments.targetObjMetadata.functions[i] />

				<!--- first get the access type --->
				<cfif StructKeyExists(functionMetadata, "access")>
					<cfset access = functionMetadata.access />
				<cfelse>
					<cfset access = "public" />
				</cfif>

				<!--- if this is a 'real' setter --->
				<cfif Left(functionMetadata.name, 3) EQ "set" AND Arraylen(functionMetadata.parameters) EQ 1 AND access NEQ "private">

					<!--- look for a bean in the factory of the params's type --->
					<cfset setterName = Mid(functionMetadata.name, 4, Len(functionMetadata.name) - 3) />

					<!--- Get bean by setter name and if not found then get by type --->
					<cfif beanFactory.containsBean(setterName)>
						<cfset beanName = setterName />
					<cfelseif ArrayLen(functionMetadata.parameters) GT 0
						AND StructKeyExists(functionMetadata.parameters[1], "type")>
						<cfset beanName = beanFactory.findBeanNameByType(functionMetadata.parameters[1].type) />
					<cfelse>
						<cfset beanName = "" />
					</cfif>

					<!--- If we found a bean, put the bean by calling the target object's setter --->
					<cfif Len(beanName)>
						<cftry>
							<cfinvoke component="#arguments.targetObj#" method="set#setterName#">
								<cfinvokeargument name="#functionMetadata.parameters[1].name#" value="#beanFactory.getBean(beanName)#" />
							</cfinvoke>
							<cfcatch type="any">
								<cfthrow type="MachII.properties.ColdSpringProperty.NoBean"
									message="Cannot load bean named '#beanName#' to autowire by method injection in a '#ListLast(targetObjMetadata.extends.name, '.')#' of type '#targetObjMetadata.name#' in module '#getAppManager().getModuleName()#'."
									detail="Original Exception: #getUtils().buildMessageFromCfCatch(cfcatch)#" />
							</cfcatch>
						</cftry>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="getListeners" access="private" returntype="void" output="false"
		hint="Gets the listener targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var listenerManager = getAppManager().getListenerManager() />
		<cfset var listenerNames = listenerManager.getListenerNames() />
		<cfset var i = 0 />

		<!--- Append each retrieved listener and its' invoker to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(listenerNames)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, listenerManager.getListener(listenerNames[i])) />
		</cfloop>
	</cffunction>

	<cffunction name="getFilters" access="private" returntype="void" output="false"
		hint="Get the filter targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var filterManager = getAppManager().getFilterManager() />
		<cfset var filterNames = filterManager.getFilterNames() />
		<cfset var i = 0 />

		<!--- Append each retrieved filter to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(filterNames)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, filterManager.getFilter(filterNames[i])) />
		</cfloop>
	</cffunction>

	<cffunction name="getPlugins" access="private" returntype="void" output="false"
		hint="Get the plugin targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var pluginManager = getAppManager().getPluginManager() />
		<cfset var pluginNames = pluginManager.getPluginNames() />
		<cfset var i = 0 />

		<!--- Append each retrieved plugin to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(pluginNames)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, pluginManager.getPlugin(pluginNames[i])) />
		</cfloop>
	</cffunction>

	<cffunction name="getConfigurableProperties" access="private" returntype="void" output="false"
		hint="Get the configurable property targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var propertyManager = getAppManager().getPropertyManager() />
		<cfset var configurablePropertyNames = propertyManager.getConfigurablePropertyNames() />
		<cfset var i = 0 />

		<!--- Append each retrieved configurable properties to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(configurablePropertyNames)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, propertyManager.getProperty(configurablePropertyNames[i])) />
		</cfloop>
	</cffunction>

	<cffunction name="getEndpoints" access="private" returntype="void" output="false"
		hint="Get the configurable endpoints targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var endpointManager = getAppManager().getEndpointManager() />
		<cfset var endpointNames = endpointManager.getEndpointNames() />
		<cfset var i = 0 />

		<!--- Append each retrieved configurable properties to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(endpointNames)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, endpointManager.getEndpointByName(endpointNames[i])) />
		</cfloop>
	</cffunction>

	<cffunction name="getConfigurableCommands" access="private" returntype="void" output="false"
		hint="Get the configurable command targets.">
		<cfargument name="targetBase" type="struct" required="true" />

		<cfset var configurableEventCommands = getAppManager().getEventManager().getConfigurableCommandTargets() />
		<cfset var configurableSubroutineCommands = getAppManager().getSubroutineManager().getConfigurableCommandTargets() />
		<cfset var configurableCacheCommands = getAppManager().getCacheManager().getConfigurableCommandTargets() />
		<cfset var configurableMessageCommands = getAppManager().getMessageManager().getConfigurableCommandTargets() />
		<cfset var i = 0 />

		<!--- Append each retrieved configurable event commands to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(configurableEventCommands)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, configurableEventCommands[i]) />
		</cfloop>

		<!--- Append each retrieved configurable subroutine commands to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(configurableSubroutineCommands)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, configurableSubroutineCommands[i]) />
		</cfloop>

		<!--- Append each retrieved configurable cache commands to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(configurableCacheCommands)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, configurableCacheCommands[i]) />
		</cfloop>

		<!--- Append each retrieved configurable message commands to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(configurableMessageCommands)#" index="i">
			<cfset ArrayAppend(arguments.targetBase.targets, configurableMessageCommands[i]) />
		</cfloop>
	</cffunction>

	<cffunction name="injectUtilityConnectorBeanFactoryPostProcessorDefinition" access="private" returntype="void" output="false"
		hint="Injects an UtilityConnectorBeanFactoryPostProcessor definition into the local bean factory.">

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />

		<!--- This definition is used to wire in the correct AppManager into any UtilityConnector definition --->
		<cfset beanFactory.createBeanDefinition("_MachIIUtilityConnectorBeanFactoryPostProcessor"
			, "MachII.util.injection.UtilityConnectorBeanFactoryPostProcessor"
			, ArrayNew(1)
			, true
			, false
			, true
			, ""
			, ""
			, ""
			, false
			, true
			, false
			, false
			, "") />
	</cffunction>

	<cffunction name="referenceBeansToMachIIProperties" access="private" returntype="void" output="false"
		hint="Places references to ColdSpring managed beans into the Mach-II properties.">
		<cfargument name="beansToProperties" type="struct" required="true" />

		<cfset var beanFactory = getProperty(getProperty("beanFactoryName")) />
		<cfset var key = "" />

		<!--- Inject the beans into the properties --->
		<cfloop collection="#arguments.beansToProperties#" item="key">
			<cfif beanFactory.containsBean(key)>
				<cfset setProperty(arguments.beansToProperties[key], beanFactory.getBean(key)) />
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setAutowireAttributeName" access="private" returntype="void" output="false">
		<cfargument name="autowireAttributeName" type="string" required="true" />
		<cfset variables.instance.autowireAttributeName = arguments.autowireAttributeName />
	</cffunction>
	<cffunction name="getAutowireAttributeName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.autowireAttributeName />
	</cffunction>

	<cffunction name="setLastReloadHash" access="private" returntype="void" output="false">
		<cfargument name="lastReloadHash" type="string" required="true" />
		<cfset variables.instance.lastReloadHash = arguments.lastReloadHash />
	</cffunction>
	<cffunction name="getLastReloadHash" access="public" returntype="string" output="false">
		<cfreturn variables.instance.lastReloadHash />
	</cffunction>

	<cffunction name="setLastReloadDatetime" access="private" returntype="void" output="false">
		<cfargument name="lastReloadDatetime" type="date" required="true" />
		<cfset variables.instance.lastReloadDatetime = arguments.lastReloadDatetime />
	</cffunction>
	<cffunction name="getLastReloadDatetime" access="public" returntype="date" output="false">
		<cfreturn variables.instance.lastReloadDatetime />
	</cffunction>

	<cffunction name="setConfigFilePaths" access="private" returntype="void" output="false">
		<cfargument name="configFilePaths" type="array" required="true" />
		<cfset variables.instance.configFilePaths = arguments.configFilePaths />
	</cffunction>
	<cffunction name="getConfigFilePaths" access="public" returntype="array" output="false">
		<cfreturn variables.instance.configFilePaths />
	</cffunction>

</cfcomponent>