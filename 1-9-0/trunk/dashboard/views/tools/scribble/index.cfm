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

<form:form actionEvent="js.tools.scribble.process" id="processScribble">
	<p>The scribble code is rendered within Mach-II. All function calls available in normal Mach-II views are available (e.g. <code>buildUrl()</code>, etc.).</p>
	<div style="border: 1px solid black; padding: 6px;">
		<form:textarea name="code">
&lt;html>
  &lt;head>
    &lt;title>HTML Example&lt;/title>
  &lt;/head>
  &lt;body>
    &lt;p>Duh&lt;/p>
  &lt;/body>
&lt;/html>
		</form:textarea>
	</div>
	<p class="right"><form:button /></p>
</form:form>

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
	textWrapping: false
  });
</view:script>

<p class="clear" />

<h2 id="resultsTitle">Output</h2>
<div id="results" style="padding-bottom:24px;">
</div>

<view:script outputType="inline">
	Event.observe('processScribble', 'submit', function(event) {
	    Event.stop(event); // stop the form from submitting first in case we encounter an error
	    
	    $('processScribble').request({
	    	parameters: {
				evalJS: true
			},
			onCreate: function() {
				$('resultsTitle').scrollTo();
			},
	        onSuccess: function(transport) {
	            $('results').update(transport.responseText);
	        }
	    });
	});
</view:script>
<cfelse>
	<h4>We are unable to write to a temp directory and therefore the scribble pad has been disabled.</h4>
	<p>#getProperty("scribbleAvailableMessage")#</p>
</cfif>
</cfoutput>