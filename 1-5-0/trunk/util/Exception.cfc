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
Author: Ben Edwards (ben@ben-edwards.com)
$Id: Exception.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
Updated version: 1.1.0

Notes:
- Added wrapException() and get/setCaughtException() for cfcatch infomation. (pfarrell)
--->
<cfcomponent displayname="Exception"
	output="false"
	hint="Encapsulates exception information.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.type = "" />
	<cfset variables.message = "" />
	<cfset variables.errorCode = "" />
	<cfset variables.detail = "" />
	<cfset variables.extendedInfo = "" />
	<cfset variables.tagContext = ArrayNew(1) />
	<cfset variables.caughtException = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Exception" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorCode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedInfo" type="string" required="false" default="" />
		<cfargument name="tagContext" type="array" required="false" default="#ArrayNew(1)#" />
	
		<cfset setType(arguments.type) />
		<cfset setMessage(arguments.message) />
		<cfset setErrorCode(arguments.errorCode) />
		<cfset setDetail(arguments.detail) />
		<cfset setExtendedInfo(arguments.extendedInfo) />
		<cfset setTagContext(arguments.tagContext) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="wrapException" access="public" returntype="Exception" output="false"
		hint="Wraps and sets caughtException (cfcatch).">
		<cfargument name="caughtException" type="any" required="true"
			hint="The cfcatch." />
		
		<cfset setType(arguments.caughtException.type) />
		<cfset setMessage(arguments.caughtException.message) />
		<cfset setErrorCode(arguments.caughtException.errorCode) />
		<cfset setDetail(arguments.caughtException.detail) />
		<cfset setExtendedInfo(arguments.caughtException.extendedInfo) />
		<cfset setTagContext(arguments.caughtException.TagContext) />
		<cfset setCaughtException(arguments.caughtException) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setType" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="false" />
		<cfset variables.type = arguments.type />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.type />
	</cffunction>
	
	<cffunction name="setMessage" access="public" returntype="void" output="false">
		<cfargument name="message" type="string" required="false" />
		<cfset variables.message = arguments.message />
	</cffunction>
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfreturn variables.message />
	</cffunction>
	
	<cffunction name="setErrorCode" access="public" returntype="void" output="false">
		<cfargument name="errorCode" type="string" required="false" />
		<cfset variables.errorCode = arguments.errorCode />
	</cffunction>
	<cffunction name="getErrorCode" access="public" returntype="string" output="false">
		<cfreturn variables.errorCode />
	</cffunction>
	
	<cffunction name="setDetail" access="public" returntype="void" output="false">
		<cfargument name="detail" type="string" required="false" />
		<cfset variables.detail = arguments.detail />
	</cffunction>
	<cffunction name="getDetail" access="public" returntype="string" output="false">
		<cfreturn variables.detail />
	</cffunction>
	
	<cffunction name="setExtendedInfo" access="public" returntype="void" output="false">
		<cfargument name="extendedInfo" type="string" required="false" />
		<cfset variables.extendedInfo = arguments.extendedInfo />
	</cffunction>
	<cffunction name="getExtendedInfo" access="public" returntype="string" output="false">
		<cfreturn variables.extendedInfo />
	</cffunction>
	
	<cffunction name="setTagContext" access="public" returntype="void" output="false">
		<cfargument name="extendedInfo" type="array" required="false" />
		<cfset variables.tagContext = arguments.extendedInfo />
	</cffunction>
	<cffunction name="getTagContext" access="public" returntype="array" output="false">
		<cfreturn variables.tagContext />
	</cffunction>
	
	<cffunction name="setCaughtException" access="public" returntype="void" output="false">
		<cfargument name="caughtException" type="any" required="true" />
		<cfset variables.caughtException = arguments.caughtException />
	</cffunction>
	<cffunction name="getCaughtException" access="public" returntype="any" output="false"
		hint="Gets caughtException (cfcatch) that was collected at the point of the exception.">
		<cfreturn variables.caughtException />
	</cffunction>
	
</cfcomponent>