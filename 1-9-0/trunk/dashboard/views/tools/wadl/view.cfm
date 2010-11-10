<cfif arguments.event.isArgDefined("view")>
	<cfoutput>#event.getArg("wadlDoc")#</cfoutput>
<cfelseif arguments.event.isArgDefined("xml")>
	<cfheader  name="Content-Disposition" value="attachment; filename=wadl.xml">
	<cfoutput>#event.getArg("wadlDoc")#</cfoutput>
<cfelseif arguments.event.isArgDefined("pdf")>
	<cfabort showerror="Not implemented because I cannot get XMLParse() to parse the XML document and therefore I cannot get XMLTransform() to work so I can output HTML for a PDF function." />
</cfif>