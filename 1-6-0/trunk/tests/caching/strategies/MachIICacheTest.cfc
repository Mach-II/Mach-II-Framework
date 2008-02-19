<cfcomponent displayname="MachIICacheTest"
			 extends="mxunit.framework.TestCase">
	<!--- org.cfcunit.framework.TestCase --->
	<cffunction name="setUp" access="public" returntype="void" output="false">
	</cffunction>
	
	<cffunction name="tearDown" access="private" returntype="void" output="false">
	</cffunction>
	
	<cffunction name="testPutExistsGet" access="public" returntype="void">
		<cfset var parameters = structNew() />
		<cfset var testKey = "productID=1">
		
		<cfoutput>testPutExistsGet called<br /></cfoutput>
		<cfset parameters.cacheFor = 1 />
		<cfset parameters.cacheForUnit = "hours" />
		<cfset parameters.scope = "application" />
		<cfset cache = createObject("component", "MachII.caching.strategies.MachIICache").init(parameters) />
		<cfset cache.configure() />

		<cfset cache.put(testkey, "testing") />
		
		<cfset debug(cache) />

		<cfset assertTrue(cache.keyExists(testkey)) />
		<cfset assertTrue(cache.get(testkey) eq "testing") />
		<cfoutput>testPutExistsGet done</cfoutput>
	</cffunction>
	
	<cffunction name="testFlush" access="public" returntype="void" output="false">
		<cfset var parameters = structNew() />
		<cfset var testKey = "productID=1">
		
		<cfset parameters.cacheFor = 1 />
		<cfset parameters.cacheForUnit = "hours" />
		<cfset parameters.scope = "application" />
		<cfset cache = createObject("component", "MachII.caching.strategies.MachIICache").init(parameters) />
		<cfset cache.configure() />

		<cfset cache.put(testkey, "testing") />
		<cfset cache.flush() />
		<cfset assertTrue(NOT cache.keyExists(testkey)) />
	</cffunction>
	
	<cffunction name="testRemove" access="public" returntype="void" output="false">
		<cfset var parameters = structNew() />
		<cfset var testKey = "productID=1">
		
		<cfset parameters.cacheFor = 1 />
		<cfset parameters.cacheForUnit = "hours" />
		<cfset parameters.scope = "application" />
		<cfset cache = createObject("component", "MachII.caching.strategies.MachIICache").init(parameters) />
		<cfset cache.configure() />

		<cfset cache.put(testkey, "testing") />
		<cfset cache.remove(testkey) />
		<cfset assertTrue(NOT cache.keyExists(testkey)) />
	</cffunction>

</cfcomponent>