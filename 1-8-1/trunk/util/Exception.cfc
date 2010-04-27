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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.5.0

Notes:
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