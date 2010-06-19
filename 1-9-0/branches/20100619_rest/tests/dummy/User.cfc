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
	displayname="User"
	output="false"
	hint="A bean which models the User form.">

	<!---
	PROPERTIES
	--->
	<cfproperty name="firstName" type="string" default="" required="false" />
	<cfproperty name="lastName" type="string" default="" required="false" />
	<cfproperty name="birthDate" type="string" default="" required="false" />
	<cfproperty name="favoriteColor" type="string" default="" required="false" />
	<cfproperty name="favoriteSeason" type="string" default="" required="false" />
	<cfproperty name="favoriteHoliday" type="string" default="" required="false" />
	<cfproperty name="emailPreferences" type="string" default="" required="false" />
	<cfproperty name="address" type="MachII.tests.dummy.Address" required="false" />

	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="User" output="false">
		<cfargument name="firstName" type="string" required="false" default="" />
		<cfargument name="lastName" type="string" required="false" default="" />
		<cfargument name="birthDate" type="string" required="false" default="" />
		<cfargument name="favoriteColor" type="string" required="false" default="" />
		<cfargument name="favoriteSeason" type="string" required="false" default="" />
		<cfargument name="favoriteHoliday" type="string" required="false" default="" />
		<cfargument name="emailPreferences" type="string" required="false" default="" />
		<cfargument name="address" type="MachII.tests.dummy.Address" required="false"
			default="#createObject("component", "MachII.tests.dummy.Address").init()#" />

		<cfset setFirstName(arguments.firstName) />
		<cfset setLastName(arguments.lastName) />
		<cfset setBirthDate(arguments.birthDate) />
		<cfset setFavoriteColor(arguments.favoriteColor) />
		<cfset setFavoriteSeason(arguments.favoriteSeason) />
		<cfset setFavoriteHoliday(arguments.favoriteHoliday) />
		<cfset setEmailPreferences(arguments.emailPreferences) />
		<cfset setAddress(arguments.address) />

		<cfreturn this />
 	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="getMemento" access="public" returntype="struct" output="false">
		<cfreturn variables.instance />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setFirstName" access="public" returntype="void" output="false">
		<cfargument name="firstName" type="string" required="true" />
		<cfset variables.instance.firstName = Trim(arguments.firstName) />
	</cffunction>
	<cffunction name="getFirstName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.firstName />
	</cffunction>

	<cffunction name="setLastName" access="public" returntype="void" output="false">
		<cfargument name="lastName" type="string" required="true" />
		<cfset variables.instance.lastName = Trim(arguments.lastName) />
	</cffunction>
	<cffunction name="getLastName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.lastName />
	</cffunction>

	<cffunction name="setBirthDate" access="public" returntype="void" output="false">
		<cfargument name="birthDate" type="string" required="true" />
		<cfset variables.instance.birthDate = Trim(arguments.birthDate) />
	</cffunction>
	<cffunction name="getBirthDate" access="public" returntype="string" output="false">
		<cfreturn variables.instance.birthDate />
	</cffunction>

	<cffunction name="setFavoriteColor" access="public" returntype="void" output="false">
		<cfargument name="favoriteColor" type="string" required="true" />
		<cfset variables.instance.favoriteColor = Trim(arguments.favoriteColor) />
	</cffunction>
	<cffunction name="getFavoriteColor" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteColor />
	</cffunction>

	<cffunction name="setFavoriteSeason" access="public" returntype="void" output="false">
		<cfargument name="favoriteSeason" type="string" required="true" />
		<cfset variables.instance.favoriteSeason = Trim(arguments.favoriteSeason) />
	</cffunction>
	<cffunction name="getFavoriteSeason" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteSeason />
	</cffunction>

	<cffunction name="setFavoriteHoliday" access="public" returntype="void" output="false">
		<cfargument name="favoriteHoliday" type="string" required="true" />
		<cfset variables.instance.favoriteHoliday = Trim(arguments.favoriteHoliday) />
	</cffunction>
	<cffunction name="getFavoriteHoliday" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteHoliday />
	</cffunction>

	<cffunction name="setEmailPreferences" access="public" returntype="void" output="false">
		<cfargument name="emailPreferences" type="string" required="true" />
		<cfset variables.instance.emailPreferences = Trim(arguments.emailPreferences) />
	</cffunction>
	<cffunction name="getEmailPreferences" access="public" returntype="string" output="false">
		<cfreturn variables.instance.emailPreferences />
	</cffunction>

	<cffunction name="setAddress" access="public" returntype="void" output="false">
		<cfargument name="address" type="MachII.tests.dummy.Address" required="true" />
		<cfset variables.instance.address = arguments.address />
	</cffunction>
	<cffunction name="getAddress" access="public" returntype="MachII.tests.dummy.Address" output="false">
		<cfreturn variables.instance.address />
	</cffunction>

</cfcomponent>