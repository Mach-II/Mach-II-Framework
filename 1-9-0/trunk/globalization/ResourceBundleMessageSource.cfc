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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0
--->
<cfcomponent
	displayname="ResourceBundleMessageSource"
	output="false"
	extends="BaseMessageSource"
	hint="Implementation of the resource bundle message source.">

	<!---
	PROPERTIES
	--->
	<!--- An array containing the basenames of the project bundles (or 'families')--->
	<cfset variables.basenames = ArrayNew(1) />

	<!---
		Cache to hold loaded resourceBundles.
		This struct is keyed with the bundle basename, which
		returns a struct that is keyed with the locale, which
		returns a resource bundle.
	--->
	<cfset variables.cachedResourceBundles = StructNew() />

	<!---
		Cache to hold already generated messageFormats.
		This struct is keyed with a resourceBundle, which
		returns a struct that is keyed with a given code, which
		returns a struct that is keyed with the locale, which
		returns a generated messageFormat.
	--->
	<cfset variables.cachedMessageFormats = CreateObject("java", "java.util.HashMap").init() />

	<!---
	INITIALIZATION/CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ResourceBundleMessageSource" output="false"
		hint="Initializes the message source.">
		<cfargument name="parentMessageSource" type="any" required="false"
			hint="The parent message source if available."/>
		<cfargument name="basenames" type="array" required="false" default="#ArrayNew(1)#"
			hint="An array of base names to use for this message source." />

		<cfset setBasenames(arguments.basenames) />

		<cfif StructKeyExists(arguments, "parentMessageSource")>
			<cfset super.init(arguments.parentMessageSource) />
		<cfelse>
			<cfset super.init() />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="appendBasenames" access="public" returntype="void" output="false">
		<cfargument name="basenames" type="array" required="true"/>

		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(arguments.basenames)#" index="i">
			<cfset ArrayAppend(variables.basenames, arguments.basenames[i]) />
		</cfloop>
	</cffunction>

	<!---
	PACKAGE FUNCTIONS
	--->
	<cffunction name="resolveCode" access="package" returntype="any" output="false"
		hint="Resolves a message code by code name and locale.">
		<cfargument name="code" type="string" required="true"
			hint="Name of message code to resolve." />
		<cfargument name="locale" type="any" required="true"
			hint="The locale to use for the resolution." />

		<cfset var i = 0 />
		<cfset var resourceBundle = "" />
		<cfset var messageFormat = "" />

		<cfset getLog().trace("Resolving code for #ArrayLen(getBasenames())# basenames", getBasenames()) />

		<cfloop from="1" to="#ArrayLen(variables.basenames)#" index="i">
			<cfset resourceBundle = getResourceBundle(variables.basenames[i].bundle, variables.basenames[i].charset, locale) />

			<cfif IsObject(resourceBundle)>
				<cfset messageFormat = getMessageFormat(resourceBundle, code, locale) />
				<cfif IsObject(messageFormat)>
					<cfreturn messageFormat />
				</cfif>
			</cfif>
		</cfloop>

		<cfif IsObject(getParent())>
			<cfreturn getParent().resolveCode(arguments.code, arguments.locale) />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="getResourceBundle" access="package" returntype="any" output="false"
		hint="Gets a resource bundle by base name and locale.">
		<cfargument name="basename" type="string" required="true"
			hint="The base name of the resource bundle." />
		<cfargument name="charset" type="string" required="true"
			hint="The charset encoding of the resource bundle." />
		<cfargument name="locale" type="any" required="true"
			hint="The locale to use to get the resource bundle." />

		<cfset var localeStruct = "" />
		<cfset var bundle = "" />

		<cfif StructKeyExists(variables.cachedResourceBundles, arguments.basename)>
			<cfset localeStruct = variables.cachedResourceBundles[arguments.basename] />
			<cfif StructKeyExists(variables.cachedResourceBundles[arguments.basename], arguments.locale.toString())>
				<cfset getLog().trace("Globalization resource bundle cache hit for '#arguments.basename#' and '#arguments.locale.toString()#'; returning preconfigured resource bundle") />
				<cfreturn variables.cachedResourceBundles[arguments.basename][arguments.locale.toString()] />
			</cfif>
		</cfif>

		<cflock name="_MachIIResourceBundleMessageSource_cachedResourceBundles_#variables.uniqueId#_#arguments.basename#_#arguments.charset#_#arguments.locale.toString()#" type="readonly" timeout="30">

			<!--- Check again to see if some other thread beat us to it --->
			<cfif StructKeyExists(variables.cachedResourceBundles, arguments.basename)>
				<cfset localeStruct = variables.cachedResourceBundles[arguments.basename] />
				<cfif StructKeyExists(variables.cachedResourceBundles[arguments.basename], arguments.locale.toString())>
					<cfset getLog().trace("Globalization resource bundle cache hit for '#arguments.basename#' and '#arguments.locale.toString()#'; returning preconfigured resource bundle") />
					<cfreturn variables.cachedResourceBundles[arguments.basename][arguments.locale.toString()] />
				</cfif>
			</cfif>

			<cfset getLog().trace("Globalization resource bundle cache not hit; creating and caching new resource bundle for #arguments.basename#") />
			<cfset bundle = doGetBundle(arguments.basename, arguments.charset, arguments.locale) />

			<cfif IsObject(bundle)>
				<cfif NOT IsStruct(localeStruct)>
					<cfset localeStruct = StructNew() />
					<cfset variables.cachedResourceBundles[arguments.basename] = localeStruct />
				</cfif>
				<cfset localeStruct[arguments.locale.toString()] = bundle />

				<cfreturn bundle />
			<cfelse>
				<cfset getLog().warn("Resource bundle '#arguments.basename#' and '#arguments.locale.toString()#' not found. Please check that you have the correct basename.", cfcatch) />
			</cfif>
		</cflock>

		<cfif IsObject(getParent())>
			<cfreturn getParent().getResourceBundle() />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction name="getMessageFormat" access="private" returntye="any" output="false">
		<cfargument name="resourceBundle" type="any" required="true"/>
		<cfargument name="code" type="string" required="true"/>
		<cfargument name="locale" type="any" required="true"/>

		<cfset var codeStruct = "" />
		<cfset var localeStruct = "" />
		<cfset var message = "" />
		<cfset var messageFormat = "" />

		<cflock name="cachedMessageFormats" timeout="30">
			<cfset codeStruct = variables.cachedMessageFormats.get(arguments.resourceBundle) />

			<cfif IsDefined("codeStruct")>
				<cfif StructKeyExists(codeStruct, arguments.code)>
					<cfset localeStruct = codeStruct[arguments.code] />
					<cfif StructKeyExists(codeStruct[arguments.code], arguments.locale.toString())>
						<cfset getLog().trace("Cache hit, returning preconfigured message format object") />
						<cfreturn codeStruct[arguments.code][arguments.locale.toString()] />
					</cfif>
				</cfif>
			</cfif>

			<cfset message = getStringOrEmpty(arguments.resourceBundle, arguments.code) />

			<cfif Len(message)>
				<cfset getLog().trace("Cache not hit; creating and caching new messageFormat object") />
				<cfif not IsDefined("codeStruct")>
					<cfset codeStruct = StructNew() />
					<cfset variables.cachedMessageFormats.put(arguments.resourceBundle, codeStruct) />
				</cfif>
				<cfif not IsStruct(localeStruct)>
					<cfset localeStruct = StructNew() />
					<cfset codeStruct[arguments.code] = localeStruct />
				</cfif>
				<cfset messageFormat = createMessageFormat(message, arguments.locale) />
				<cfset localeStruct[arguments.locale.toString()] = messageFormat />
				<cfreturn messageFormat />
			</cfif>

		</cflock>

		<cfreturn "" />
	</cffunction>

	<cffunction name="getStringOrEmpty" access="private" returntype="string" output="false">
		<cfargument name="resourceBundle" type="any" required="true"/>
		<cfargument name="code" type="string" required="true"/>

		<cftry>
			<cfreturn arguments.resourceBundle.getString(arguments.code) />

			<cfcatch type="any">
				<cfreturn "" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="doGetBundle" access="private" returntype="any" output="false">
		<cfargument name="basename" type="string" required="true" />
		<cfargument name="charset" type="string" required="true" />
		<cfargument name="locale" type="any" required="true" />

		<cfset var bundle = "" />

		<cfset bundle = doGetBundleInternal("#arguments.basename#_#arguments.locale.getLanguage()#_#arguments.locale.getCountry()#.properties", arguments.charset) />

		<cfif IsObject(bundle)>
			<cfreturn bundle />
		</cfif>

		<cfset bundle = doGetBundleInternal("#arguments.basename#_#arguments.locale.getLanguage()#.properties", arguments.charset) />

		<cfif IsObject(bundle)>
			<cfreturn bundle />
		</cfif>

		<cfset bundle = doGetBundleInternal("#arguments.basename#.properties", arguments.charset) />

		<cfif IsObject(bundle)>
			<cfreturn bundle />
		</cfif>

		<cfreturn bundle/>
	</cffunction>

	<cffunction name="doGetBundleInternal" access="private" returntype="any" output="false">
		<cfargument name="fileName" type="string" required="true" />
		<cfargument name="charset" type="string" required="true" />

		<!--- Cannot initialize Java objects in the var block because we need a try/catch around it --->
		<cfset var inputStream = "" />
		<Cfset var inputReader = "" />
		<cfset var resourceBundle = "" />

		<cftry>
			<!--- Use a file reader to support UTF-8 and other encoding for .properties files (see ticket 763) --->
			<cfset inputStream = CreateObject("java", "java.io.FileInputStream").init(ExpandPath(arguments.fileName)) />
			<cfset inputReader = CreateObject("java", "java.io.InputStreamReader").init(inputStream, arguments.charset) />
			<cfset resourceBundle = CreateObject("java", "java.util.PropertyResourceBundle").init(inputReader) />
			<cfset inputStream.close() />
			<cfset inputReader.close() />

			<!--- If anything goes wrong, close the file input stream and input stream reader or we will have a memory leak --->
			<cfcatch type="any">
				<!--- Only close the inputStream if it exists --->
				<cfif IsObject(inputStream)>
					<cfset inputStream.close() />
				</cfif>

				<!--- Only close the inputReader if it exists --->
				<cfif IsObject(inputReader)>
					<cfset inputReader.close() />
				</cfif>

				<cfset getLog().trace("Globalization unable to open resource bundle file '#arguments.fileName#' with charset '#arguments.charset#': #cfcatch.message#", cfcatch) />
			</cfcatch>
		</cftry>

		<cfreturn resourceBundle />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setBasenames" access="public" returntype="void" output="false">
		<cfargument name="basenames" type="array" required="true"/>
		<cfset variables.basenames = arguments.basenames />
	</cffunction>
	<cffunction name="getBasenames" access="public" returntype="Array" output="false">
		<cfreturn variables.basenames />
	</cffunction>

</cfcomponent>