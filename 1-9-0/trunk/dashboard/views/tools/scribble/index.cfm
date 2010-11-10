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
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<view:meta type="title" content="Tools - Scribble Pad" />
	
	<view:script endpoint="dashboard.serveAsset" p:file="/js/handler/tools/scribble.js">
	<cfoutput>
		pasteBinUrl = '#BuildUnescapedUrl('js.tools.scribble.processPasteBin')#';
		myScribbleHandler = new ScribbleHandler();
	</cfoutput>
	</view:script>
	
	<view:script endpoint="dashboard.serveAsset" p:file="/lib/codemirror/js/codemirror.js" />
	<view:style>
		.CodeMirror-line-numbers {
			font: 10pt monospace;
			margin-top:5px;
			background-color: #D0D0D0;
			padding: 0 6px 0 6px;
		}
	</view:style>
</cfsilent>
<cfoutput>
<h1>Scribble Pad</h1>

<cfif getProperty("scribbleAvailable")>
<h2>Scribble</h2>

<div id="pasteBinUrlBox" style="display:none">
	<div class="info">
		<p class="small right" style="margin-right:12px;"><a onclick="Effect.BlindUp('pasteBinUrlBox');">hide</a></p>
		<p>Your PasteBin URL is: <input id="pasteBinInput" type="text" size="25" value="" /> <span id="pasteBinUrl"><a id="pasteBinUrlValue" href="" target="_blank">Open in new window</a></span></p>
	</div>
</div>

<form:form actionEvent="js.tools.scribble.process" id="processScribble">
<p>The scribble code is rendered within Mach-II. All function calls available in normal Mach-II views are available (e.g. <code>buildUrl()</code>, etc.).</p>
<div style="border: 1px solid black; padding: 6px;">
	<form:textarea name="code"></form:textarea>
</div>
<p class="right"><form:button type="button" value="Share on PasteBin" id="promptPasteBin" /> <form:button name="render1" value="Render" /></p>

<view:script outputType="inline">
  editor = CodeMirror.fromTextArea('code', {
    height: "350px",
     parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js", "parsehtmlmixed.js"],
    stylesheet: ["#BuildUnescapedEndpointUrl("dashboard.serveAsset", "file=/lib/codemirror/css/xmlcolors.css")#"
		, "#BuildUnescapedEndpointUrl("dashboard.serveAsset", "file=/lib/codemirror/css/jscolors.css")#"
		, "#BuildUnescapedEndpointUrl("dashboard.serveAsset", "file=/lib/codemirror/css/csscolors.css")#"
		],
	path: "#BuildUnescapedEndpointUrl("dashboard.serveAsset", "file=/lib/codemirror/js/")#",
	lineNumbers: true,
	textWrapping: false,
	tabMode: 'shift'
	
  });
  editor.focus();
</view:script>

<p class="clear" />

<h2 id="resultsTitle" style="margin:1em 0 3px 0;">Output</h2>
<div id="results" style="padding-bottom:24px;">
</div>

<p class="right"><form:button type="button" value="Back to Scribble" id="backToScribble" /><form:button name="render2" value="Render" /></p>
</form:form>

<view:script outputType="inline">
		$('processScribble').observe('submit', myScribbleHandler.processScribble);
		$('promptPasteBin').observe('click', myScribbleHandler.promptPasteBin);
		$('backToScribble').observe('click', function () { Effect.ScrollTo('processScribble', { duration:'0.2', offset:-20 }) });
</view:script>
<cfelse>
	<h4>We are unable to write to a temp directory and therefore the scribble pad has been disabled.</h4>
	<p>#getProperty("scribbleAvailableMessage")#</p>
</cfif>
</cfoutput>