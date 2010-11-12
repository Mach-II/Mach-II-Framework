
<cfif arguments.event.isArgDefined("view")>
	<cfcontent reset="true" />
	<cfset addHTTPHeaderByName("Content-Type", "application/xml") />
	<cfoutput>#event.getArg("wadlDoc")#</cfoutput>
<cfelseif arguments.event.isArgDefined("xml")>
	<cfcontent reset="true" />
	<cfset addHTTPHeaderByName("Content-Type", "application/xml") />
	<cfset addHTTPHeaderByName("Content-Disposition", "attachment; filename=wadl.xml") />
	<cfoutput>#event.getArg("wadlDoc")#</cfoutput>
<cfelseif arguments.event.isArgDefined("pdf")>
	<cfsavecontent variable="variables.xslt"><cfinclude template="/MachII/dashboard/assets/xsl/wadl_documentation-2006-10.xsl"></cfsavecontent>
	<cfset variables.html = XmlTransform(XmlParse(event.getArg("wadlDoc")), variables.xslt) />
	<cfdocument format="pdf"><cfoutput>#variables.html#</cfoutput></cfdocument>
</cfif>