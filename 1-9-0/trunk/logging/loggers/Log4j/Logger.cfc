<cfcomponent output="false"
	extends="MachII.logging.loggers.AbstractLogger">


	<!---
	PROPERTIES
	--->
	<cfset variables.instance.loggerTypeName = "Log4j" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the logger.">

		<cfset var filter = CreateObject("component", "MachII.logging.filters.GenericChannelFilter").init(getParameter("filter", "")) />
		<cfset var adapter = CreateObject("component", "MachII.logging.adapters.Log4jAdapter").init(getParameters()) />

		<!--- For better peformance, set the filter to the adapter only we have something to filter --->
		<cfif ArrayLen(filter.getFilterChannels())>
			<cfset adapter.setFilter(filter) />
		</cfif>

		<!--- Configure and set the adapter --->
		<cfset adapter.configure() />
		<cfset setLogAdapter(adapter) />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getConfigurationData" access="public" returntype="struct" output="false"
		hint="Gets the configuration data for this logger including adapter and filter.">

		<cfset var data = StructNew() />

		<cfset data["Log Config File Name"] = getLogAdapter().getConfigFile() />
		<cfset data["Logging Enabled"] = YesNoFormat(isLoggingEnabled()) />

		<cfreturn data />
	</cffunction>


</cfcomponent>