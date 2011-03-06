<cfcomponent displayname="Application" output="true" extends="BaseApplication">
	
	<!--- Set up the application. --->
	<cfset THIS.Name = "machbuilder"/>
	<cfset THIS.ApplicationTimeout = createTimeSpan(0, 0, 30, 0)/>
	<cfset THIS.SessionManagement = true/>
	<cfset THIS.SetClientCookies = true/>

	<!--- Define the page request properties. --->
	<cfsetting requesttimeout="20" showdebugoutput="false" enablecfoutputonly="false"/>

	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false"
	            hint="Fires when the application is first created.">
		<cfset super.onApplicationStart() />
		<cfreturn true />
	</cffunction>
	
	<cffunction name="OnRequest" access="public" returntype="void" output="true"
	            hint="Fires after pre page processing is complete.">
		<cfargument name="TargetPage" type="string" required="true"/>
		
		<cflog file="machbuilder" type="info" text="Page requested: #arguments.targetpage#" />
	
		<!--- Include the requested page. --->
		<cftry>
			<cfset super.onRequest(arguments.TargetPage) />
			
			<cfinclude template="#ARGUMENTS.TargetPage#"/>
			<cfcatch type="any">
				<cflog file="machbuilder" type="error" text="#CFCATCH.message#" />
				<cflog file="machbuilder" type="error" text="#CFCATCH.detail#" />
				<cfrethrow />
			</cfcatch>
		</cftry>
	
	</cffunction>
	
	<cffunction name="OnError" access="public" returntype="void" output="true"
	            hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="Exception" type="any" required="true" />
		<cfargument name="EventName" type="string" required="false" default="" />
	
		<cflog file="machbuilder" type="error" text="#ARGUMENTS.Exception#" />
	
		<cflog file="machbuilder" type="error" text="#serializeJSON(arguments.Exception)#" />
		<cfheader statuscode="432" statustext="Error: #ARGUMENTS.Exception#" />
		
	</cffunction>
	
</cfcomponent>