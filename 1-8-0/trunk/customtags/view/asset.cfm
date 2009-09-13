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
	package		= A list or array of the asset packages names to add.
	outputType	= Indicates tthe output type for the generated HTML code (head, inline). Defaults to "head".
--->
<cfif thisTag.ExecutionMode IS "start">
	<!--- Setup the tag --->
	<cfinclude template="/MachII/customtags/view/helper/viewTagBuilder.cfm" />
	<cfset setupTag("asset", true) />	

	<!--- Setup required --->
	<cfset ensureByName("package") />
	
	<!--- Setup optional --->
	<cfparam name="attributes.outputType" type="string" 
		default="head" />
<cfelse>
	<cfset thisTag.GeneratedContent = locateHtmlHelper().addAssetPackage(attributes.package, attributes.outputType) />
</cfif>
</cfsilent><cfsetting enablecfoutputonly="false" />