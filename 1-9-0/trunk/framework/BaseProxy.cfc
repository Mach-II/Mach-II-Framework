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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="BaseProxy"
	output="false"
	hint="Acts as proxy (holder) for all user extendable components so we reload them while maintaining a reference.">

	<!---
	PROPERTIES
	--->
	<cfset variables.object = "" />
	<cfset variables.type = "" />
	<cfset variables.targetObjectPaths = ArrayNew(1) />
	<cfset variables.originalParameters = StructNew() />

	<cfset variables.BASE_OBJECT_TYPES = StructNew() />
	<cfset variables.BASE_OBJECT_TYPES["MachII.framework.EventFilter"] = "" />
	<cfset variables.BASE_OBJECT_TYPES["MachII.framework.Listener"] = "" />
	<cfset variables.BASE_OBJECT_TYPES["MachII.framework.Plugin"] = "" />
	<cfset variables.BASE_OBJECT_TYPES["MachII.framework.Property"] = "" />
	<cfset variables.BASE_OBJECT_TYPES["MachII.endpoints.AbstractEndpoint"] = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="BaseProxy" output="false"
		hint="Initializes the proxy.">
		<cfargument name="object" type="any" required="true"
			hint="The target object." />
		<cfargument name="type" type="string" required="true"
			hint="The dot path type to the target object." />
		<cfargument name="originalParameters" type="struct" required="false" default="#StructNew()#"
			hint="The original set of parameters."/>

		<!--- Run setters --->
		<cfset setObject(arguments.object) />
		<cfset setType(arguments.type) />
		<cfset setOriginalParameters(arguments.originalParameters) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="shouldReloadObject" access="public" returntype="boolean" output="false"
		hint="Determines if target object should be reloaded.">

		<cfset var result = false />

		<cfif CompareNoCase(getLastReloadHash(), computeObjectReloadHash()) NEQ 0>
			<cfset result = true />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="computeObjectReloadHash" access="public" returntype="string" output="false"
		hint="Computes the current reload hash of the target object.">

		<cfset var fileInfo = "" />
		<cfset var stringToHash = "" />
		<cfset var i = 0 />

		<!--- Ensure we have paths to compute reload hash off of --->
		<cfif NOT ArrayLen(variables.targetObjectPaths)>
			<cfset buildTargetObjectPaths() />
		</cfif>

		<!--- The hash needs to be based off entire target object path hierarchy --->
		<cfloop from="1" to="#ArrayLen(variables.targetObjectPaths)#" index="i">
			<cfset fileInfo = getFileInfo(variables.targetObjectPaths[i]) />
			<cfset stringToHash = stringToHash & fileInfo.lastModified & fileInfo.size />
		</cfloop>

		<cfreturn Hash(stringToHash) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="buildTargetObjectPaths" access="private" returntype="void" output="false"
		hint="Builds an hierarchical array of object paths based on the target object.">

		<cfset var targetObjectMetadata = GetMetadata(getObject()) />
		<cfset var i = 0 />

		<!--- Set the path for the target object --->
		<cfset ArrayAppend(variables.targetObjectPaths, targetObjectMetadata.path) />

		<!--- Build hierarchy path array and stop when a base object type is found --->
		<cfloop condition="true">
			<cfif StructKeyExists(targetObjectMetadata, "extends")>
				<cfset targetObjectMetadata = targetObjectMetadata.extends />

				<cfif NOT StructKeyExists(variables.BASE_OBJECT_TYPES, targetObjectMetadata.name)>
					<cfset ArrayAppend(variables.targetObjectPaths, targetObjectMetadata.path) />
				<cfelse>
					<cfbreak />
				</cfif>
			<cfelse>
				<cfbreak />
			</cfif>
		</cfloop>

		<cfset setLastReloadHash(computeObjectReloadHash()) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setObject" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables.object = arguments.object />
		<cfset buildTargetObjectPaths() />
	</cffunction>
	<cffunction name="getObject" access="public" returntype="any" output="false">
		<cfreturn variables.object />
	</cffunction>

	<cffunction name="setType" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset variables.type = arguments.type />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.type />
	</cffunction>

	<cffunction name="setOriginalParameters" access="public" returntype="void" output="false">
		<cfargument name="originalParameters" type="struct" required="true" />
		<cfset variables.originalParameters = arguments.originalParameters />
	</cffunction>
	<cffunction name="getOriginalParameters" access="public" returntype="struct" output="false">
		<cfreturn variables.originalParameters />
	</cffunction>

	<cffunction name="setLastReloadHash" access="private" returntype="void" output="false">
		<cfargument name="lastReloadHash" type="string" required="true" />
		<cfset variables.lastReloadHash = arguments.lastReloadHash />
	</cffunction>
	<cffunction name="getLastReloadHash" access="public" returntype="string" output="false">
		<cfif NOT Len(variables.lastReloadHash)>
			<cfset setLastReloadHash(computeObjectReloadHash()) />
		</cfif>
		<cfreturn variables.lastReloadHash />
	</cffunction>

</cfcomponent>