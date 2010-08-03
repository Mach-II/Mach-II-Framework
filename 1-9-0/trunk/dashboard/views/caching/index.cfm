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

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Caching" />
</cfsilent>
<cfoutput>

<dashboard:displayMessage />

<h1>Caching</h1>

<ul class="pageNavTabs">
	<li class="green">
		<view:a event="caching.enableDisableAll" p:mode="enable">
			<view:img event="sys.serveAsset" p:path="@img@icons@accept.png" width="16" height="16" alt="Enabled" />
			&nbsp;Enable All
		</view:a>
	</li> 
	<li class="red">
		<view:a event="caching.enableDisableAll" p:mode="disable">
			<view:img event="sys.serveAsset" p:path="@img@icons@stop.png" width="16" height="16" alt="Disable" />
			&nbsp;Disable All
		</view:a>
	</li>
	<li>
		<view:a event="caching.reapAll">
			<view:img event="sys.serveAsset" p:path="@img@icons@database_refresh.png" width="16" height="16" alt="Reap All" />
			&nbsp;Reap All
		</view:a>
	</li>
	<li>
		<view:a event="caching.flushAll">
			<view:img event="sys.serveAsset" p:path="@img@icons@database_delete.png" width="16" height="16" alt="Flush All" />
			&nbsp;Flush All
		</view:a>
	</li>
	<li>
		<a onclick="cachingInformation.stop();cachingInformation.start();">
			<view:img event="sys.serveAsset" p:path="@img@icons@arrow_rotate_clockwise.png" width="16" height="16" alt="Flush All" />
			&nbsp;Refresh Stats (Automatically Updates Every 30 Seconds)
		</a>
	</li>
</ul>

<div id="cachingInformation">
</div>
<view:script outputType="inline">
	cachingInformation = new Ajax.PeriodicalUpdater('cachingInformation'
		, '#BuildUnescapedUrl("js.caching.snip_cachingInformation")#'
		, {
			frequency: 30
			, decay: 1
		}
	);
</view:script>
</cfoutput>