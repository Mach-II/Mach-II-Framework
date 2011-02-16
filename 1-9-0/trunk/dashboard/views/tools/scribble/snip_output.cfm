<cfoutput>
<cfsetting showdebugoutput="false" />
<div style="border:1px dotted ##CCC;padding:12px;margin-top:12px;">
<cfset variables.tickStart = getTickCount() />
	<cftry>
		<cfif event.getArg("renderType") EQ "render">
			#render(event.getArg('input'))#
		<cfelse>
			<cfinclude template="#event.getArg("filePath")#" />
			<!--- The result comes from the cfsavecontent in the temp file --->
			#variables.result#
		</cfif>
		<cfcatch type="any">
			<h3>Exception</h3>
			<cfdump var="#cfcatch#" />
		</cfcatch>
	</cftry>
</div>
<p>Execution Time: #NumberFormat(getTickCount() - variables.tickStart)#ms</p>
</cfoutput>