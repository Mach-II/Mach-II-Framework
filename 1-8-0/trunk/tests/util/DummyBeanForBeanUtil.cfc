<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
This is a test bean for the BeanUtilTest.cfc test case.
--->
<cfcomponent
	displayname="BeanUtilTestBean"
	output="false"
	hint="A bean which models the BeanUtilTestBean form.">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="DummyBeanForBeanUtil" output="false">
		<cfargument name="firstName" type="string" required="false" default="" />
		<cfargument name="lastName" type="string" required="false" default="" />

		<!--- run setters --->
		<cfset setFirstName(arguments.firstName) />
		<cfset setLastName(arguments.lastName) />

		<cfreturn this />
 	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setFirstName" access="public" returntype="void" output="false">
		<cfargument name="firstName" type="string" required="true" />
		<cfset variables.instance.firstName = trim(arguments.firstName) />
	</cffunction>
	<cffunction name="getFirstName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.firstName />
	</cffunction>

	<cffunction name="setLastName" access="public" returntype="void" output="false">
		<cfargument name="LastName" type="string" required="true" />
		<cfset variables.instance.LastName = trim(arguments.LastName) />
	</cffunction>
	<cffunction name="getLastName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.LastName />
	</cffunction>

</cfcomponent>