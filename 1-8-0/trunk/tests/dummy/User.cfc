<cfcomponent
	displayname="User"
	output="false"
	hint="A bean which models the User form.">
	
	<cfproperty name="firstName" type="string" />
	<cfproperty name="lastName" type="string" />
	<cfproperty name="birthDate" type="string" />
	<cfproperty name="favoriteColor" type="string" />
	<cfproperty name="favoriteSeason" type="string" />
	<cfproperty name="favoriteHoliday" type="string" />
	<cfproperty name="emailPreferences" type="string" />
	<cfproperty name="address" type="MachII.tests.dummy.Address" />
	
	<!---
	PROPERTIES
	--->
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

		<!--- run setters --->
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
		<cfset variables.instance.firstName = trim(arguments.firstName) />
	</cffunction>
	<cffunction name="getFirstName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.firstName />
	</cffunction>

	<cffunction name="setLastName" access="public" returntype="void" output="false">
		<cfargument name="lastName" type="string" required="true" />
		<cfset variables.instance.lastName = trim(arguments.lastName) />
	</cffunction>
	<cffunction name="getLastName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.lastName />
	</cffunction>

	<cffunction name="setBirthDate" access="public" returntype="void" output="false">
		<cfargument name="birthDate" type="string" required="true" />
		<cfset variables.instance.birthDate = trim(arguments.birthDate) />
	</cffunction>
	<cffunction name="getBirthDate" access="public" returntype="string" output="false">
		<cfreturn variables.instance.birthDate />
	</cffunction>

	<cffunction name="setFavoriteColor" access="public" returntype="void" output="false">
		<cfargument name="favoriteColor" type="string" required="true" />
		<cfset variables.instance.favoriteColor = trim(arguments.favoriteColor) />
	</cffunction>
	<cffunction name="getFavoriteColor" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteColor />
	</cffunction>
	
	<cffunction name="setFavoriteSeason" access="public" returntype="void" output="false">
		<cfargument name="favoriteSeason" type="string" required="true" />
		<cfset variables.instance.favoriteSeason = trim(arguments.favoriteSeason) />
	</cffunction>
	<cffunction name="getFavoriteSeason" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteSeason />
	</cffunction>
	
	<cffunction name="setFavoriteHoliday" access="public" returntype="void" output="false">
		<cfargument name="favoriteHoliday" type="string" required="true" />
		<cfset variables.instance.favoriteHoliday = trim(arguments.favoriteHoliday) />
	</cffunction>
	<cffunction name="getFavoriteHoliday" access="public" returntype="string" output="false">
		<cfreturn variables.instance.favoriteHoliday />
	</cffunction>

	<cffunction name="setEmailPreferences" access="public" returntype="void" output="false">
		<cfargument name="emailPreferences" type="string" required="true" />
		<cfset variables.instance.emailPreferences = trim(arguments.emailPreferences) />
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