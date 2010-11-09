<cfif CGI.SERVER_PORT_SECURE>
	<cfset protocol = "https" />
<cfelse>
	<cfset protocol = "http" />
</cfif>
<cfoutput><cfset baseUrl = "#protocol#://#CGI.HTTP_HOST#" /></cfoutput>
<cfoutput><?xml version="1.0"?>
<cfset stylesheet = event.getArg('stylesheet') />
<cfif  stylesheet NEQ "">
<?xml-stylesheet type="text/xsl" href="#stylesheet#" ?>
</cfif>

<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns="http://wadl.dev.java.net/2009/02"
	xmlns:html="http://www.w3.org/1999/xhtml">

<cfif isDefined("application.applicationName")>
	<doc title="#application.applicationName#" />
</cfif>

<resources base="#baseUrl#">

<cfset endpoints = event.getArg('restEndpointMetadata') />

<cfloop collection="#endpoints.methodMetadata#" item="component">
	<cfloop collection="#endpoints.methodMetadata[component]#" item="restUri">
		<cfset restUriMethods = StructFind(endpoints.methodMetadata[component], restUri )>
		<cfif Left(restUri, 1) EQ "/">
			<cfset restUri = RemoveChars(restUri, 1, 1) />
		</cfif>
		<resource path="#restUri#">
			<cfloop collection="#restUriMethods#" item="restMethod">
				<cfset restUriItem = StructFind(restUriMethods, restMethod) />
				<method name="#restMethod#" id="#restUriItem.name#">
					<cfif isDefined("restUriItem.hint")>
						<doc>
							<html:p>#restUriItem.hint#</html:p>
							<html:strong>Request Media Type</html:strong>
							<html:p>#restUriItem["REST:queryType"]#</html:p>
						</doc>
					</cfif>
					<request>
						<cfset tokens = ArrayToList(restUriItem.tokens) />
						<cfloop array="#restUriItem.parameters#" index="parameter">
							<cfif parameter.type NEQ "MachII.framework.Event">
							<param name="#parameter.name#"
								type="xsd:#parameter["rest:type"]#"
								<cfif isDefined("parameter.required")>required="#parameter.required#"
									<!--- If not required and a default is specified --->
									<cfif NOT parameter.required AND isDefined("parameter.default")>default="#parameter.default#"</cfif>
								</cfif>
								<cfif ListFind(tokens, parameter.name)>style="template"<cfelse>style="query"</cfif>
								>
								<cfif isDefined("parameter.hint")><doc>#parameter.hint#</doc></cfif>
								<cfif StructKeyExists(parameter, "rest:options")>
									<cfset variables.options =  getAppManager().getUtils().parseAttributesIntoStruct(parameter["rest:options"]) />
									<cfloop collection="#variables.options#" item="option">
										<option value="#option#"
											<cfif Len(variables.options[option])>mediaType="#variables.options[option]#"</cfif> />
									</cfloop>
								</cfif>
							</param>
							</cfif>
						</cfloop>
					</request>
					<!--- Transform the notation from
								rest:response:html="status=200,status=404"
								rest:response:json="status=200|element=ent:contentItem"
								to:
								<response status="200">
									<representation mediaType="text/html" />
									<representation mediaType="text/json" element="ent:contentItem" />
								</response>
								<response status="404">
									<representation mediaType="text/html" />
								</response>
	--->
					<cfset responseStatus = StructNew() />
					<cfloop collection="#restUriItem#" item="metaDataKey">
						<cfif Left(metaDataKey, 14) EQ "rest:response:">
							<cfset format = ListGetAt(metaDataKey, 3, ":") />
							<cfset responses = StructFind(restUriItem, metaDataKey)>
							<cfloop list="#responses#" index="response">
								<cfset status = "" />
								<cfset element = "" />
								<cfloop list="#response#" index="attribute" delimiters="|">
									<cfif ListLen(attribute, "=") EQ 2>
										<cfif ListGetAt(attribute, 1, "=") EQ "status">
											<cfset status = ListGetAt(attribute, 2, "=") />
										</cfif>
										<cfif ListGetAt(attribute, 1, "=") EQ "element">
											<cfset element = ListGetAt(attribute, 2, "=") />
										</cfif>
									</cfif>
								</cfloop>
								<cfif StructKeyExists(responseStatus, status)>
									<cfset representation = responseStatus[status] />
								<cfelse>
									<cfset representation = StructNew() />
								</cfif>
								<cfset representation[format] = element />
								<cfset responseStatus[status] = representation />
							</cfloop>
						</cfif>
					</cfloop>
	
					<cfloop collection="#responseStatus#" item="statusKey">
						<cfset status = StructFind(responseStatus, statusKey)>
						<response status="#statusKey#">
							<cfloop collection="#status#" item="formatKey">
								<cfif status[formatKey] NEQ "">
									<representation href="###status[formatKey]#"
								<cfelse>
									<representation mediaType="#formatKey#"
								</cfif>
								/>
							</cfloop>
						</response>
					</cfloop>
				</method>
			</cfloop>
		</resource>
	</cfloop>
</cfloop>
</resources>

<cfloop collection="#endpoints.componentMetadata#" item="componentKey">
	<cfset component = endpoints.componentMetadata[componentKey] />
	<cfif isDefined("component.properties")>
		<cfloop array="#component.properties#" index="property">
			<cfif Left(property.name, 20) EQ "rest:representation:">
				<cfset format=ListGetAt(property.name, 3, ":") />
				<cfset mediaType = getAppManager().getUtils().getMimeTypeByFileExtension("." & format) />
				<cfset repid = ListGetAt(property.name, 2, ":") & ":" & ListGetAt(property.name, 4, ":") />
				<representation id="#repid#" mediaType="#mediaType#">
					<doc title="#repid#">
						 <html:p>
						<cfif isValid("url", property.value)>
							<html:a href="#property.value#">#property.value#</html:a>
						<cfelse>
							#property.value#
						</cfif>
						</html:p>
					</doc>
				</representation>
			</cfif>
		</cfloop>
	</cfif>
</cfloop>
</application>
</cfoutput>