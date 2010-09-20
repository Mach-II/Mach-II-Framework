<cfcomponent
	displayname="Application"
	extends="MachII.mach-ii"
	output="false">

	<!---
	PROPERTIES - APPLICATION SPECIFIC
	--->
	<cfset this.name = "AppName" />
	<cfset this.loginStorage = "session" />
	<cfset this.sessionManagement = true />
	<cfset this.setClientCookies = true />
	<cfset this.setDomainCookies = false />
	<cfset this.sessionTimeOut = CreateTimeSpan(0,1,0,0) />
	<cfset this.applicationTimeOut = CreateTimeSpan(1,0,0,0) />

	<!---
		Most of the rest of the properties, methods, etc. have "intelligent defaults" 
		set in MachII.mach-ii (which Application.cfc extends). The typical Mach-II 
		properties such as MACHII_CONFIG_PATH, MACHII_APP_KEY, MACHII_CONFIG_MODE, etc. 
		can be overridden here, as can the Application CFC methods to which you wish 
		to add custom functionality.
		
		If you do override any of the methods, make sure to call super or copy/paste 
		the contents from MachII.mach-ii into your overridden methods. This is particularly 
		important with:
		* onApplicationStart(): this must call loadFramework()
		* onRequestStart(): this must call handleRequest()
	--->
</cfcomponent>