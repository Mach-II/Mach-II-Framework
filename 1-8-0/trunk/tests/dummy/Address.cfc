<cfcomponent output="false">
	
	<cfproperty name="id" type="numeric" default="0" required="false">
	<cfproperty name="address1" type="string" default="" required="false">
	<cfproperty name="address2" type="string" default="" required="false">
	<cfproperty name="city" type="string" default="" required="false">
	<cfproperty name="state" type="string" default="" required="false">
	<cfproperty name="zip" type="string" default="" required="false">
	<cfproperty name="country" type="MachII.tests.dummy.Country" required="false">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.id = 0>
	<cfset variables.instance.address1 = "">
	<cfset variables.instance.address2 = "">
	<cfset variables.instance.city = "">
	<cfset variables.instance.state = "">
	<cfset variables.instance.zip = "">
	<cfset variables.instance.country = "">

	<cffunction name="init" access="public" returntype="any" output="no">
		<cfargument name="id" required="no" type="numeric" default="0">
		<cfargument name="address1" required="no" type="string" default="">
		<cfargument name="address2" required="no" type="string" default="">
		<cfargument name="city" required="no" type="string" default="">
		<cfargument name="state" required="no" type="string" default="">
		<cfargument name="zip" required="no" type="string" default="">
		<cfargument name="country" required="no" type="MachII.tests.dummy.Country" 
			default="#createObject("component", "MachII.tests.dummy.Country").init()#">
		<cfset setInstanceMemento(arguments)>
		<cfreturn this />
	</cffunction>

	<cffunction name="getId" access="public" output="no" returntype="numeric">
		<cfreturn variables.instance.id>
	</cffunction>
	<cffunction name="setId" access="public" output="no" returntype="void">
		<cfargument name="id" required="yes" type="numeric">
		<cfset variables.instance.id = arguments.id>
	</cffunction>
	<cffunction name="getAddress1" access="public" output="no" returntype="string">
		<cfreturn variables.instance.address1>
	</cffunction>
	<cffunction name="setAddress1" access="public" output="no" returntype="void">
		<cfargument name="address1" required="yes" type="string">
		<cfset variables.instance.address1 = arguments.address1>
	</cffunction>
	<cffunction name="getAddress2" access="public" output="no" returntype="string">
		<cfreturn variables.instance.address2>
	</cffunction>
	<cffunction name="setAddress2" access="public" output="no" returntype="void">
		<cfargument name="address2" required="yes" type="string">
		<cfset variables.instance.address2 = arguments.address2>
	</cffunction>
	<cffunction name="getCity" access="public" output="no" returntype="string">
		<cfreturn variables.instance.city>
	</cffunction>
	<cffunction name="setCity" access="public" output="no" returntype="void">
		<cfargument name="city" required="yes" type="string">
		<cfset variables.instance.city = arguments.city>
	</cffunction>
	<cffunction name="getState" access="public" output="no" returntype="string">
		<cfreturn variables.instance.state>
	</cffunction>
	<cffunction name="setState" access="public" output="no" returntype="void">
		<cfargument name="state" required="yes" type="string">
		<cfset variables.instance.state = arguments.state>
	</cffunction>
	<cffunction name="getZip" access="public" output="no" returntype="string">
		<cfreturn variables.instance.zip>
	</cffunction>
	<cffunction name="setZip" access="public" output="no" returntype="void">
		<cfargument name="zip" required="yes" type="string">
		<cfset variables.instance.zip = arguments.zip>
	</cffunction>
	<cffunction name="getCountry" access="public" output="no" returntype="MachII.tests.dummy.Country">
		<cfreturn variables.instance.country>
	</cffunction>
	<cffunction name="setCountry" access="public" output="no" returntype="void">
		<cfargument name="country" required="yes" type="MachII.tests.dummy.Country">
		<cfset variables.instance.country = arguments.country>
	</cffunction>
	<cffunction name="getInstanceMemento" access="public" returntype="struct" output="false">
		<cfset var data = structNew()>
		<cfset data.id = getId()>
		<cfset data.address1 = getAddress1()>
		<cfset data.address2 = getAddress2()>
		<cfset data.city = getCity()>
		<cfset data.state = getState()>
		<cfset data.zip = getZip()>
		<cfset data.country = getCountry()>
		<cfreturn data>
	</cffunction>
	<cffunction name="setInstanceMemento" access="public" returntype="void" output="false">
		<cfargument name="data" type="struct" required="true">
		<cfset setId(arguments.data.id)>
		<cfset setAddress1(arguments.data.address1)>
		<cfset setAddress2(arguments.data.address2)>
		<cfset setCity(arguments.data.city)>
		<cfset setState(arguments.data.state)>
		<cfset setZip(arguments.data.zip)>
		<cfset setCountry(arguments.data.country)>
	</cffunction>
	
</cfcomponent>