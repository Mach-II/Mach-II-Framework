<cfcomponent output="false">
	
	<cfproperty name="code" type="string" />
	<cfproperty name="name" type="string" />
	
	<cfset variables.instance = structNew() />
	<cfset variables.instance.code = "" />
	<cfset variables.instance.name = "" />
	
	<cffunction name="init" access="public" returntype="any" output="no">
		<cfargument name="code" required="no" type="string" default="">
		<cfargument name="name" required="no" type="string" default="">
		<cfset setCode(arguments.code) />
		<cfset setName(arguments.name) />
		<cfreturn this />
	</cffunction>

	<cffunction name="getCode" access="public" output="no" returntype="string">
		<cfreturn variables.instance.code>
	</cffunction>
	<cffunction name="setCode" access="public" output="no" returntype="void">
		<cfargument name="code" required="yes" type="string">
		<cfset variables.instance.code = arguments.code>
	</cffunction>
	<cffunction name="getName" access="public" output="no" returntype="string">
		<cfreturn variables.instance.name>
	</cffunction>
	<cffunction name="setName" access="public" output="no" returntype="void">
		<cfargument name="name" required="yes" type="string">
		<cfset variables.instance.name = arguments.name>
	</cffunction>

</cfcomponent>