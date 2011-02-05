<cfcomponent displayname="Application" output="true" hint="Handle the application.">
  
	<!--- Set up the application. --->
	<cfset THIS.Name = "machbuilder" />
	<cfset THIS.ApplicationTimeout = createTimeSpan( 0, 0, 30, 0 ) />
	<cfset THIS.SessionManagement = true />
	<cfset THIS.SetClientCookies = true />
  
	<!--- Define the page request properties. --->
	<cfsetting
		requesttimeout="20"
		showdebugoutput="false"
		enablecfoutputonly="false"
		/>
  
	<cffunction
		name="OnApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="Fires when the application is first created.">
 
		<cfreturn true />
	</cffunction>
  
	<cffunction
		name="OnSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is first created.">
 
	</cffunction>
  
	<!---<cffunction
		name="OnRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="Fires at first part of page processing.">
 
		<!--- Define arguments. --->
		<cfargument
			name="TargetPage"
			type="string"
			required="true"
			/>
 
	</cffunction>--->
 
 
	<cffunction
		name="OnRequest"
		access="public"
		returntype="void"
		output="true"
		hint="Fires after pre page processing is complete.">
 
		<!--- Define arguments. --->
		<cfargument
			name="TargetPage"
			type="string"
			required="true"
			/>
 
 		<cflog file="machbuilder" type="info" text="Page requested: #arguments.targetpage#" />
 
		<!--- Include the requested page. --->
		<cftry>
			<cfinclude template="#ARGUMENTS.TargetPage#" />
			<cfcatch type="any">
				<cflog file="machbuilder" type="error" text="#CFCATCH.message#" />
				<cflog file="machbuilder" type="error" text="#CFCATCH.detail#" />
			</cfcatch>
		</cftry>
 
	</cffunction>
 
 
	<cffunction
		name="OnRequestEnd"
		access="public"
		returntype="void"
		output="true"
		hint="Fires after the page processing is complete.">
 
	</cffunction>
 
 
	<cffunction
		name="OnSessionEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is terminated.">
 
		<!--- Define arguments. --->
		<cfargument
			name="SessionScope"
			type="struct"
			required="true"
			/>
 
		<cfargument
			name="ApplicationScope"
			type="struct"
			required="false"
			default="#StructNew()#"
			/>
 
	</cffunction>
 
 
	<cffunction
		name="OnApplicationEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the application is terminated.">
 
		<!--- Define arguments. --->
		<cfargument
			name="ApplicationScope"
			type="struct"
			required="false"
			default="#StructNew()#"
			/>
 
	</cffunction>
 
 
	<cffunction
		name="OnError"
		access="public"
		returntype="void"
		output="true"
		hint="Fires when an exception occures that is not caught by a try/catch.">
 
		<!--- Define arguments. --->
		<cfargument
			name="Exception"
			type="any"
			required="true"
			/>
 
		<cfargument
			name="EventName"
			type="string"
			required="false"
			default=""
			/>
			
			<cflog file="machbuilder" type="error" text="#ARGUMENTS.Exception#" />

]			<cflog file="machbuilder" type="error" text="#serializeJSON(arguments.Exception)#" />
			<cfheader statuscode="432" statustext="Error: #ARGUMENTS.Exception#">
 
	</cffunction>
 
</cfcomponent>