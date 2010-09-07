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
<table>
	<tr>
		<th colspan="3"><h3>Repeaters / Quantification</h3></th>
	</tr>
	<tr class="shade">
		<td class="center" style="width:10%;"><pre class="bold">*</pre></td>
		<td style="width:30%;"><p>Matches any (0 or more) of previous</p></td>
		<td style="width:60%;">
			<table>
				<tr>
					<td style="width:40%;"><code>a*hh</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">ahh</code></td>
				</tr>
				<tr>
					<td><code>a*hh</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">aahh</code></td>
				</tr>
				<tr>
					<td><code>a*hh</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">hh</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">?</pre></td>
		<td><p>Matches optional (0 or 1) of previous</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>to?t</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">tt</code></td>
				</tr>
				<tr>
					<td><code>to?t</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">tot</code></td>
				</tr>
				<tr>
					<td><code>to?t</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">toot</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="shade">
		<td class="center"><pre class="bold">+</pre></td>
		<td><p>Matches etc. (1 or more) of previous</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>to+t</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">tot</code></td>
				</tr>
				<tr>
					<td><code>to+t</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">toot</code></td>
				</tr>
				<tr>
					<td><code>to+t</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">tt</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">{n}</pre></td>
		<td><p>Matches exactly (no more; no less) of previous</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>to{2}t</code></td>
					<td style="width:20%;" class="center bad"><code>&ne;</code></td>
					<td style="width:40%;"><code class="right">tt</code></td>
				</tr>
				<tr>
					<td><code>to{2}t</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">toot</code></td>
				</tr>
				<tr>
					<td><code>to{2}t</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">tooot</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="shade">
		<td class="center"><pre class="bold">{n,}</pre></td>
		<td><p>Matches minimum (n or more) of previous</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>ah{2,}</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">ahh</code></td>
				</tr>
				<tr>
					<td><code>ah{2,}</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">ahhhh</code></td>
				</tr>
				<tr>
					<td><code>ah{2,}</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">ah</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">{n,m}</pre></td>
		<td><p>Matches range (n to m) of previous</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>ah{2,4}</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">ahh</code></td>
				</tr>
				<tr>
					<td><code>ah{2,4}</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">ahhhh</code></td>
				</tr>
				<tr>
					<td><code>ah{2,4}</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">ahhhhhhhh</code></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table style="margin-top:24px;">
	<tr>
		<th colspan="3"><h3>Anchors</h3></th>
	</tr>
	<tr class="shade">
		<td class="center" style="width:10%;"><pre class="bold">^</pre><br/><pre class="bold">\A</pre></td>
		<td style="width:30%;"><p>Starts with</p></td>
		<td style="width:60%;">
			<table>
				<tr>
					<td style="width:40%;"><code>^m</code> OR <code>\Am</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">mike</code></td>
				</tr>
				<tr>
					<td><code>^m</code> OR <code>\Am</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">matt</code></td>
				</tr>
				<tr>
					<td><code>^m</code> OR <code>\Am</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">peter</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">$</pre><br/><pre class="bold">\Z</pre></td>
		<td><p>Ends with</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>n$</code> OR <code>n\Z</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">brian</code></td>
				</tr>
				<tr>
					<td><code>n$</code> OR <code>n\Z</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">adrian</code></td>
				</tr>
				<tr>
					<td><code>n$</code> OR <code>n\Z</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">kurt</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="shade">
		<td class="center"><pre class="bold">^...$</pre></td>
		<td><p>Starts with and ends with combination</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>^p.*n$</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">peter and brian</code></td>
				</tr>
				<tr>
					<td><code>^p.*n$</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">pension</code></td>
				</tr>
				<tr>
					<td><code>^p.*n$</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">peter and matt</code></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table style="margin-top:24px;">
	<tr>
		<th colspan="3"><h3>Special Characters</h3></th>
	</tr>
	<tr class="shade">
		<td class="center" style="width:10%;"><pre class="bold">.</pre></td>
		<td style="width:30%;"><p>Wildcard character matches any single character (except for new lines <code>\n</code>)</p></td>
		<td style="width:60%;">
			<table>
				<tr>
					<td style="width:40%;"><code>c.t</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">cat</code></td>
				</tr>
				<tr>
					<td><code>c.t</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">cot</code></td>
				</tr>
				<tr>
					<td><code>c.t</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">c\nt</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">|</pre></td>
		<td><p>Matches Either / Or</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code>apple|orange</code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">apple</code></td>
				</tr>
				<tr>
					<td><code>apple|orange</code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">orange</code></td>
				</tr>
				<tr>
					<td><code>apple|orange</code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">banana</code></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table style="margin-top:24px;">
	<tr>
		<th colspan="3"><h3>Greedy / Lazy Quantifications</h3></th>
	</tr>
	<tr class="shade">
		<td class="center" style="width:10%;"><pre class="bold">.*</pre></td>
		<td style="width:30%;"><p>Matches multiple wildcards (greedy) and will consume as <em>many</em> characters as possible from the input becore finding a match</p></td>
		<td style="width:60%;">
			<table>
				<tr>
					<td style="width:40%;"><code><.*></code></td>
					<td style="width:20%;" class="center good"><code>=</code></td>
					<td style="width:40%;"><code class="right">#HtmlEditFormat("<p>text</p>")#</code></td>
				</tr>
				<tr>
					<td><code><.*></code></td>
					<td class="center bad"><code>&ne;</code></td>
					<td><code class="right">#HtmlEditFormat("<p>")#</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="center"><pre class="bold">.*?</pre></td>
		<td><p>Matches multiple wildcards (lazy, non-greedy) and will consume as <em>few</em> characters as possible from the input before finding a match</p></td>
		<td>
			<table>
				<tr>
					<td style="width:40%;"><code><.*></code></td>
					<td style="width:20%;" class="center bad"><code>&ne;</code></td>
					<td style="width:40%;"><code class="right">#HtmlEditFormat("<p>text</p>")#</code></td>
				</tr>
				<tr>
					<td><code><.*></code></td>
					<td class="center good"><code>=</code></td>
					<td><code class="right">#HtmlEditFormat("<p>")#</code></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table style="margin-top:24px;">
	<tr>
		<th colspan="3"><h3>Common Patterns</h3></th>
	</tr>
	<tr class="shade">
		<td>
			<table>
				<tr>
					<td style="width:30%;">Matches single open / closing HTML tag</code></td>
					<td style="width:70%;"><code class="small">(\<(/?[^\>]+)\>)</code></td>
				</tr>
				<tr>
					<td>Matches open / closing HTML tag with text between</code></td>
					<td><code class="small"><([A-Za-z][A-Za-z0-9]*)\b[^>]*>(.*?)</\1></code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table>
				<tr>
					<td style="width:30%;">Matches valid IP addresses</code></td>
					<td style="width:70%;"><code class="small">\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table>
				<tr>
					<td style="width:30%;">Matches number range 0-999</code></td>
					<td style="width:70%;"><code class="small">^([0-9]|[1-9][0-9]|[1-9][0-9][0-9])$</code></td>
				</tr>
				<tr>
					<td>Matches number range 0-56</code></td>
					<td><code class="small">^[0-5]?[0-9]$</code></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table>
				<tr>
					<td style="width:30%;">Matches date format mm/dd/yyyy (19xx or 20xx)</code></td>
					<td style="width:70%;"><code class="small">^(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d$</code></td>
				</tr>
				<tr>
					<td>Matches date format dd-mm-yyyy (19xx or 20xx)</code></td>
					<td><code class="small">^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$</code></td>
				</tr>
			</table>
		</td>
	</tr>


</table>
</cfoutput>