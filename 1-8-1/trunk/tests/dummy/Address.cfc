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

Author: Kurt Wiersma (kurt@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent
	displayname="Address"
	output="false"
	hint="A bean which models the Address form.">
	
	<!---
	PROPERTIES
	--->
	<cfproperty name="id" type="numeric" default="0" required="false" />
	<cfproperty name="address1" type="string" default="" required="false" />
	<cfproperty name="address2" type="string" default="" required="false" />
	<cfproperty name="city" type="string" default="" required="false" />
	<cfproperty name="state" type="string" default="" required="false" />
	<cfproperty name="zip" type="string" default="" required="false" />
	<cfproperty name="country" type="MachII.tests.dummy.Country" required="false" />

	<cfset variables.instance = structNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="address1" type="string" required="false" default="" />
		<cfargument name="address2" type="string" required="false" default="" />
		<cfargument name="city" type="string" required="false" default="" />
		<cfargument name="state" type="string" required="false" default="" />
		<cfargument name="zip" type="string" required="false" default="" />
		<cfargument name="country" type="MachII.tests.dummy.Country" required="false"
			default="#CreateObject("component", "MachII.tests.dummy.Country").init()#" />

		<cfset setInstanceMemento(arguments) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setInstanceMemento" access="public" returntype="void" output="false">
		<cfargument name="data" type="struct" required="true" />

		<cfset setId(arguments.data.id) />
		<cfset setAddress1(arguments.data.address1) />
		<cfset setAddress2(arguments.data.address2) />
		<cfset setCity(arguments.data.city) />
		<cfset setState(arguments.data.state) />
		<cfset setZip(arguments.data.zip) />
		<cfset setCountry(arguments.data.country) />
	</cffunction>
	<cffunction name="getInstanceMemento" access="public" returntype="struct" output="false">

		<cfset var data = StructNew() />

		<cfset data.id = getId() />
		<cfset data.address1 = getAddress1() />
		<cfset data.address2 = getAddress2() />
		<cfset data.city = getCity() />
		<cfset data.state = getState() />
		<cfset data.zip = getZip() />
		<cfset data.country = getCountry() />

		<cfreturn data />
	</cffunction>

	<!---
	ACCESSORTS
	--->
	<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset variables.instance.id = Trim(arguments.id) />
	</cffunction>
	<cffunction name="getId" access="public" returntype="numeric"  output="false">
		<cfreturn variables.instance.id />
	</cffunction>

	<cffunction name="setAddress1" access="public" returntype="void" output="false">
		<cfargument name="address1" type="string" required="true" />
		<cfset variables.instance.address1 = Trim(arguments.address1) />
	</cffunction>
	<cffunction name="getAddress1" access="public" returntype="string" output="false">
		<cfreturn variables.instance.address1 />
	</cffunction>

	<cffunction name="setAddress2" access="public" returntype="void" output="false">
		<cfargument name="address2" type="string" required="true" />
		<cfset variables.instance.address2 = Trim(arguments.address2) />
	</cffunction>	
	<cffunction name="getAddress2" access="public" returntype="string" output="false">
		<cfreturn variables.instance.address2 />
	</cffunction>

	<cffunction name="setCity" access="public" returntype="void" output="false">
		<cfargument name="city" type="string" required="yes" />
		<cfset variables.instance.city = Trim(arguments.city) />
	</cffunction>
	<cffunction name="getCity" access="public" returntype="string" output="false">
		<cfreturn variables.instance.city />
	</cffunction>

	<cffunction name="setState" access="public" returntype="void" output="false">
		<cfargument name="state" type="string" required="true" />
		<cfset variables.instance.state = Trim(arguments.state) />
	</cffunction>
	<cffunction name="getState" access="public" returntype="string" output="false">
		<cfreturn variables.instance.state />
	</cffunction>

	<cffunction name="setZip" access="public" returntype="void" output="false">
		<cfargument name="zip" type="string" required="true" />
		<cfset variables.instance.zip = Trim(arguments.zip) />
	</cffunction>
	<cffunction name="getZip" access="public" returntype="string" output="false">
		<cfreturn variables.instance.zip />
	</cffunction>

	<cffunction name="setCountry" access="public" returntype="void" output="false">
		<cfargument name="country" type="MachII.tests.dummy.Country" required="true" />
		<cfset variables.instance.country = arguments.country />
	</cffunction>
	<cffunction name="getCountry" access="public" returntype="MachII.tests.dummy.Country" output="false">
		<cfreturn variables.instance.country />
	</cffunction>
	
</cfcomponent>