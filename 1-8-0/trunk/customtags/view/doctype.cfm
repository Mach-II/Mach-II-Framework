<cfsetting enablecfoutputonly="true" /><cfsilent>
<!---
License:
Copyright 2009 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.8.0
Updated version: 1.8.0

Notes:
- OPTIONAL ATTRIBUTES
	type		= The doc type to render. Accepted values are 'xhtml-1.0-strict' (default), 'xhtml-1.0-trans', 'xhtml-1.0-frame', 'xhtml-1.1', 'html-4.0-strict', 'html-4.0-trans', 'html-4.0-frame' and 'html-5.0'.
--->
<cfif thisTag.ExecutionMode IS "start">
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("doctype", true) />	
<cfelse>
	<!--- Use the default type if no type is defined --->
	<cfif NOT StructKeyExists(attributes, "type")>
		<cfset thisTag.GeneratedContent = locateHtmlHelper().addDoctype() />
	<cfelse>
		<cfset thisTag.GeneratedContent = locateHtmlHelper().addDoctype(attributes.type) />
	</cfif>
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />