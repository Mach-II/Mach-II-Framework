<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="Message"
	output="false"
	hint="A bean which models the Message form.">


	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Message" output="false">
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="info" />
		<cfargument name="caughtException" type="struct" required="false" default="#StructNew()#" />

		<!--- run setters --->
		<cfset setMessage(arguments.message) />
		<cfset setType(arguments.type) />
		<cfset setCaughtException(arguments.caughtException) />

		<cfreturn this />
 	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="hasCaughtException" access="public" returntype="boolean" output="false"
		hint="Checks if there is a caught exception.">
		<cfreturn StructCount(getCaughtException()) />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setMessage" access="public" returntype="void" output="false">
		<cfargument name="message" type="string" required="true" />
		<cfset variables.instance.message = trim(arguments.message) />
	</cffunction>
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfreturn variables.instance.message />
	</cffunction>

	<cffunction name="setType" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset variables.instance.type = trim(arguments.type) />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.type />
	</cffunction>

	<cffunction name="setCaughtException" access="public" returntype="void" output="false">
		<cfargument name="caughtException" type="any" required="true" />
		<cfset variables.instance.caughtException = arguments.caughtException />
	</cffunction>
	<cffunction name="getCaughtException" access="public" returntype="any" output="false">
		<cfreturn variables.instance.caughtException />
	</cffunction>

</cfcomponent>