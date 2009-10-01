<!---
License:
Copyright 2009 GreatBizTools, LLC

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

		<cfset var directoryResults = "" />
		<cfset var stringToHash = "" />
		<cfset var i = 0 />
		
		<!--- Ensure we have paths to compute reload hash off of --->
		<cfif NOT ArrayLen(variables.targetObjectPaths)>
			<cfset buildTargetObjectPaths() />
		</cfif>

		<!--- The hash needs to be based off entire target object path hierarchy --->
		<cfloop from="1" to="#ArrayLen(variables.targetObjectPaths)#" index="i">
			<cfdirectory action="LIST" 
				directory="#GetDirectoryFromPath(variables.targetObjectPaths[i])#" 
				name="directoryResults" 
				filter="#GetFileFromPath(variables.targetObjectPaths[i])#" />
			<cfset stringToHash = stringToHash & directoryResults.dateLastModified & directoryResults.size />
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