<cfsilent>
<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

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
$Id$

Created version: 1.1.0
Updated version: 1.1.0

Notes:
--->
</cfsilent>
<cfoutput>
<cfimport prefix="view" taglib="/MachII/customtags/view" />
<ul class="pageNavTabs">
	<li>
		<view:a event="tools.regex">
			<view:img event="sys.serveAsset" p:path="@img@icons@arrow_rotate_clockwise.png" alt="Use Regex Tester Tool" />
			&nbsp;RegEx Tester
		</view:a>
	</li>
<!--- 	<li>
		<view:a event="tools.beanGenerator">
			<view:img event="sys.serveAsset" p:path="@img@icons@arrow_rotate_clockwise.png" alt="Use Bean Generator Tool" />
			&nbsp;Bean Generator
		</view:a>
	</li> --->
</ul>
</cfoutput>