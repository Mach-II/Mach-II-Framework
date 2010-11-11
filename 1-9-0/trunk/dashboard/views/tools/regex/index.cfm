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
	<view:meta type="title" content="Tools - RegEx Tester" />
</cfsilent>
<cfoutput>
<h1>RegEx Tester</h1>

<h2 id="resultsTitle">Results</h2>
<div id="results" style="padding-bottom:24px;">
</div>

<h2>Tests</h2>
<form:form actionEvent="js.tools.regex.process" id="processRegEx">
<table>
	<tr>
		<th style="width:15%;"><h3>Type</h4></th>
		<th style="width:15%;"><h3>Case-Sensitive</h4></th>
		<th style="width:70%;"><h3>RegEx</h3></th>
	</tr>
	<tr>
		<td>
			<p><label><form:radio path="type" value="refind" /> REFind / REMatch</label></p>
			<p><label><form:radio path="type" value="rereplace" /> REReplace</label></p>
		</td>
		<td>
			<p><label><form:radio path="caseSensitive" value="1" /> Yes</label></p>
			<p><label><form:radio path="caseSensitive" value="0" /> No</label></p>
		</td>
		<td>
			<table>
				<tr>
					<th style="width:15%;"><p><label for="pattern1">Pattern 1</label></p></th>
					<td style="width:85%;"><p><form:textarea path="pattern1" style="width:100%" /></p></td>
				</tr>
				<tr class="replace" style="display:none;">
					<th><p><label for="replace1">Replace 1</label></p></th>
					<td><p><form:textarea path="replace1" style="width:100%" /></p></td>
				</tr>
				<tr>
					<th><p><label for="pattern2">Pattern 2</label></p></th>
					<td><p><form:textarea path="pattern2" style="width:100%" /></p></td>
				</tr>
				<tr class="replace" style="display:none;">
					<th><p><label for="replace2">Replace 2</label></p></th>
					<td><p><form:textarea path="replace2" style="width:100%" /></p></td>
				</tr>
				<tr>
					<th><p><label for="pattern3">Pattern 3</label></p></th>
					<td><p><form:textarea path="pattern3" style="width:100%" /></p></td>
				</tr>
				<tr class="replace" style="display:none;">
					<th><p><label for="replace3">Replace 3</label></p></th>
					<td><p><form:textarea path="replace3" style="width:100%" /></p></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<th colspan="3"><h3><label for="input">Input Text</label></h3></th>
	</tr>
	<tr>
		<td colspan="3">
			<p><form:textarea path="input" style="width:100%;" rows="10" cols="100" /></p>
		</td>
	</tr>
</table>
<p class="right"><form:button /></p>


<p class="clear" style="padding-top:24px;" />
<h2>RegEx Reference Guide</h2>

#event.getArg("layout.snip_referenceGuide")#

<p class="right"><form:button type="button" value="Back to Tests" id="backToTests" /></p>
</form:form>

<view:script outputType="inline">
	Event.observe('processRegEx', 'submit', function(event) {
	    Event.stop(event); // stop the form from submitting first in case we encounter an error
	    $('processRegEx').request({
	    	parameters: {
				evalJS: true
			},
			onCreate: function() {
				Effect.ScrollTo('resultsTitle', { duration:'0.2'});
			},
	        onSuccess: function(transport) {
	            $('results').update(transport.responseText);
	        }
	    });
	});

	Event.observe('type_rereplace', 'change', function(event) {
		$$('.replace').each(function(l) { l.show(); });
	});

	Event.observe('type_refind', 'change', function(event) {
		$$('.replace').each(function(l) { l.hide(); });
	});

	new TextAreaResize('input');
	new TextAreaResize('pattern1');
	new TextAreaResize('pattern2');
	new TextAreaResize('pattern3');
	new TextAreaResize('replace1');
	new TextAreaResize('replace2');
	new TextAreaResize('replace3');
	$('backToTests').observe('click', function () { Effect.ScrollTo('processRegEx', { duration:'0.2'}) });
</view:script>
</cfoutput>