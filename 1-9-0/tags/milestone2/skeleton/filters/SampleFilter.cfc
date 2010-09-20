<cfcomponent
	displayname="SampleFilter"
	extends="MachII.framework.EventFilter"
	output="false"
	hint="A simple event filter example.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the filter.">
		<!--- Put custom configuration for this filter here. --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean" output="false"
		hint="I am invoked by the Mach II framework.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="I am the current event object created by the Mach II framework." />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true"
			hint="I am the current event context object created by the Mach II framework." />
		<cfargument name="paramArgs" type="struct" required="false" default="#structNew()#"
			hint="I am the structure containing the parameters specified in the filter invocation in mach-ii.xml." />		
		<!--- Put logic here.
			Return FALSE to abort the current event handler.
			Return TRUE to continue the current event handler. --->
	</cffunction>
	
</cfcomponent>
