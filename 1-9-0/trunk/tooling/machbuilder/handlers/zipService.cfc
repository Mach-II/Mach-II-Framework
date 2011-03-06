<cfcomponent output="false">
	<cffunction name="doUnzip" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		
		<cfzip file="#arguments.file#" action="unzip" destination="#arguments.destination#" storepath="yes" overwrite="yes" />
	</cffunction>
</cfcomponent>