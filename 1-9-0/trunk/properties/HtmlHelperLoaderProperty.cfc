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

Created version: 1.9.0

Notes:

Configuration Usage:
<property name="html" type="MachII.properties.HtmlHelperLoaderProperty">
	<parameters>
		<parameter name="assetPackages">
			<struct>
				<key name="lightwindow">
					<array>
						<element value="prototype.js,effects.js,otherDirectory/lightwindow.js" />
						<!-- SIMPLE -->
						<element value="lightwindow.css">
						<!-- VERBOSE-->
						<element>
							<struct>
								<key name="paths" value="/css/lightwindow.cfm" />
								<key name="type" value="css" />
								<key name="attributes" value="media=screen,projection" />
								<key name="forIEVersion" value="gte 7" />
							</struct>
						</element>
					</array>
				</key>
			</struct>
		</parameter>
	</parameters>
</property>

Notes:
--->
<cfcomponent
	displayname="HTMLHelperLoaderProperty"
	extends="MachII.framework.Property"
	output="false"
	hint="Provider HTML helper loader functionality.">

	<!---
	CONSTANTS
	--->
	<!--- Do not use these locators as they may change in future versions --->
	<cfset variables.HTML_HELPER_PROPERTY_NAME = "_HTMLHelper" />

	<!---
	PROPERTIES
	--->

	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the property.">

		<cfset var packages = getParameter("assetPackages", StructNew()) />
		<cfset var htmlHelper = locateHtmlHelper() />
		<cfset var key = "" />

		<cfloop collection="#packages#" item="key">
			<cfset htmlHelper.loadAssetPackage(key, packages[key]) />
		</cfloop>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="locateHtmlHelper" access="private" returntype="MachII.properties.HtmlHelperProperty" output="false"
		hint="Locates the HtmlHelperProperty for use.">

		<cfset var htmlHelper = getProperty(variables.HTML_HELPER_PROPERTY_NAME, "") />

		<cfif IsObject(htmlHelper)>
			<cfreturn htmlHelper />
		<cfelse>
			<cfthrow type="MachII.properties.HtmlHelperLoaderProperty..htmlHelperUnavailable"
				message="The HTML Helper Loader property in module '#getAppManager().getModuleName()#' cannot located a HTML Helper property."
				detail="Do you have an HtmlHelperProperty setup for in this application?" />
		</cfif>
	</cffunction>

</cfcomponent>