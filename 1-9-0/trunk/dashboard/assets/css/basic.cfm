<cfoutput>
/*
    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

	As a special exception, the copyright holders of this library give you
	permission to link this library with independent modules to produce an
	executable, regardless of the license terms of these independent
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.0.0
Updated version: 1.0.0
*/

* {
margin: 0;
padding: 0;
}

html {
	font-size: 100.1%; /* IE hack */
}

body {
	font: 0.75em/1.5em Arial, Helvetica, sans-serif;
	margin:0;
	background: ##FFF url(#getProperty("urlBase")#/dashboard.serveAsset/img/headerBk.jpg) top left repeat-x;
}

hr {
	padding: 0;
	border: 0;
	color: ##D0D0D0;
	background-color: ##D0D0D0;
	height: 1px;
	margin: 2em 0 2em 0;
}

table {
	width:100%;
	border: 0;
}

table tr {
	border: 0;
}

table td {
	border: 0;
	vertical-align: top;
}

a, a:visited, a:hover {
	text-decoration: none;
	color: ##1878B2;
}

img {
	border: 0;
	padding: 0;
}

h1 { font-size: 175%; margin: 1em 0 1em 0; color: ##000; }

h2 { font-size: 135%; margin: 0; color: ##1878B2; }

h3 { font-size: 115%; margin: 0; color: ##1878B2; }

h4 { font-size: 100%; font-weight: bold; margin: 0; }

.small { font-size: 0.9em }
.green, .green a, .green a:visited, .green a:hover {
	color: ##6BB300;
}

.good {
	background-color: ##C4FF6F;
}

.red, .red a, .red a:visited, .red a:hover {
	color: ##CC0000;
}

.bad {
	background-color: ##FF7F7F;
}

.right {
	float: right;
}

.clear { clear: both; }

.center { text-align: center; }

input { margin: 0.5em; padding: 0.5em; }

label { cursor: pointer; display:block; }

pre, code {
	font-size: 150%;
	font-family: "Courier New", "Andale Mono", "Bitstream Vera Sans Mono", monospace;
	white-space: pre-wrap; /* css-3 */
	white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
	white-space: -pre-wrap; /* Opera 4-6 */
	white-space: -o-pre-wrap; /* Opera 7 */
	word-wrap: break-word; /* Internet Explorer 5.5+ */
}

pre.bold, code.bold {
	font-size: 200%;
	font-weight: bold;
}

/* CONTAINER
---------------*/
##container {
	margin: 0 auto 0 auto;
	padding: 0;
	width: 960px;
	text-align: left;
}

/* HEADER
---------------*/
##header {
	margin: 0;
	padding: 0;
	height: 94px;
	position: relative;
}

##logo h3 {
	float: left;
	margin: 8px 0;
	padding: 0;
}

/* NAVTABS
---------------*/

##navTabs {
	position: absolute;
	bottom: 12px;
	right: -3px;
}

##navTabs ul {
	padding: 0;
	margin: 0;
	display: block;
	font-size: 1.1em;
	font-weight: bold;
}

##navTabs li {
	list-style: none;
	float: left;
	padding: 0 3px 0 3px;

}

##navTabs a {
	float: left;
	padding: 0px 9px;
	text-decoration: none;
	color: ##FFF;
	height: 28px;
	voice-family: "\"}\"";
	voice-family: inherit;
	height: 18px;
	-moz-border-radius-topleft:	6px;
	-moz-border-radius-topright: 6px;
	-webkit-border-top-left-radius:	6px;
	-webkit-border-top-right-radius: 6px;
}

##navTabs a:link, ##navTabs a:visited {
	background-color: ##999;
	border: 6px solid ##999;
}

##navTabs a:hover {
	background-color: ##666;
	border: 6px solid ##666;
}

##navTabs a.highlight {
	background-color: ##CC0000;
	border: 6px solid ##CC0000;
}

/* NAVTABS
---------------*/
##subNavTabs {
	float: right;
	margin-top: 9px;
	margin-right: 12px;
	margin-bottom: 24px;
	width: 960px;
}

##subNavTabs ul {
	list-style-type: none;
	margin: 0;
	padding: 0;
	float: right;
}

##subNavTabs li {
	border-right: 1px dotted ##CCC !important;
	border-right: 1px solid ##CCC; /* fix for IE6 */
	float: left;
	line-height: 1.1em;
	margin: 0 -1em 0 1em;
	padding: 0 1em 0 1em;
}

##subNavTabs li img {
	float: left;
	margin-top: -1px;
	margin-right: 3px;
}

##subNavTabs a, ##subNavTabs a:visited {
	color: ##333;
	font-weight: bold;
	font-size: 0.9em;
}

##subNavTabs a:hover, ##subNavTabs a.highlight {
	color: ##CC3300;
}

/* SERVERINFO
---------------*/

##serverInfo {
	position: absolute;
	top: 0;
	right: 0;
	font-size: 0.9em;
}

##serverInfo ul {
	position: relative;
	list-style-type: none;
	margin: 0;
	padding: 0;
	float: right;
	overflow: hidden;
	padding: 9px 0 9px 2em;
	border-bottom: 1px dotted ##D0D0D0;
	border-right: 1px dotted ##D0D0D0;
	border-left: 1px dotted ##D0D0D0;
	background-color: ##F5F5F5;
	font-size: 0.9em;
}

##serverInfo li {
	list-style-type: none;
	border-left: 1px dotted ##D0D0D0;
	float: left;
	line-height: 1.1em;
	margin: 0 1em 0 -1em;
	padding: 0 1em 0 1em;
}

##serverInfo li:first-child {
	border-left: none;
}

##serverInfo li img {
	vertical-align: middle;
}

##serverInfo strong {
	color: ##0971AF;
}

##serverInfo a, ##serverInfo a:visited {
	cursor: pointer;
}

/* CONTENT
---------------*/

##content {
	margin: 24px 0 24px 0;
	clear: both;
}


##content h1 {
	background-color: ##666;
	color: ##FFF;
	padding: 9px 9px 9px .5em;
	font-variant: small-caps;
	border: 1px solid ##000;
	-moz-border-radius:	6px;
	-webkit-border-radius: 6px;
}

##content h1:first-child {
	margin-top: 0;
}

##content h2 {
	background-color: ##E6ECFF;
	color: ##0971AF;
	padding: 6px 3px 6px .5em;
	border: 1px solid ##0971AF;
	-moz-border-radius:	6px;
	-webkit-border-radius: 6px;
}

##content h4 img { vertical-align: middle; }

##content div.info {
	font-weight: bold;
	color: ##0971AF;
	padding: 0.5em 0 0.5em 2.5em;
	margin: 0.5em 0 1em 0;
	background: ##E6ECFF url(#getProperty("urlBase")#/dashboard.serveAsset/img/icons/information.png) 0.5em center no-repeat;
	border: 1px solid ##0971AF;
	border-top: 6px solid ##0971AF;
}

##content div.success {
	font-weight: bold;
	color: ##6BB300;
	padding: 0.5em 0 0.5em 2.5em;
	margin: 0.5em 0 1em 0;
	background: ##E9FFE6 url(#getProperty("urlBase")#/dashboard.serveAsset/img/icons/tick.png) 0.5em center no-repeat;
	border: 1px solid ##6BB300;
	border-top: 6px solid ##6BB300;
}

##content div.exception {
	font-weight: bold;
	color: ##CC0000;
	padding: 0.5em 0 0.5em 2.5em;
	margin: 0.5em 0 1em 0;
	background: ##FFE6E6 url(#getProperty("urlBase")#/dashboard.serveAsset/img/icons/exclamation.png) 0.5em center no-repeat;
	border: 1px solid ##CC0000;
	border-top: 6px solid ##CC0000;
}

##content .twoColumn {
}

##content .twoColumn .left {
	padding: 0 24px 0 0;
    float:left;
}

##content .twoColumn .right {
    padding: 0 0 0 24px;
    border-left: 1px dotted ##D0D0D0;
    float:right;
}

hr {
	padding: 0;
	border: 0;
	color: ##D0D0D0;
	background-color: ##D0D0D0;
	height: 1px;
	margin: 2em 0 2em 0;
}

div.line hr { /* take out the troublemaking HR */
	display:none;
}
div.line { /* DIV that wraps and replaces the HR */
	height: 1px;
	border-bottom: 1px dotted ##D0D0D0;
	height: 1px;
	margin: 2em 0 2em 0;
	padding: 0;
	clear:both;
}

##content .icon img {
	vertical-align: middle;
}

##content ul {
	padding-left: 2em;
	list-style-type: disc;
}

##content ul.none {
	padding-left: 0;
	list-style-type: none;
}

##content table .shade {
	background-color: ##F5F5F5;
}

##content table.none td {
	border: none;
}

##content table th {
	padding: 0.5em;
	color: ##FFF;
	background-color: ##999;
	border: 1px solid ##666;
	-moz-border-radius:	6px;
	-webkit-border-radius: 6px;
}

##content table th h3 {
	color: ##FFF;
}

##content table td {
	padding: 0.5em;
	border-top: 1px dotted ##D0D0D0;
	border-bottom: 1px dotted ##D0D0D0;
}

##content table td hr {
	margin: 1em 0 1em 0;
}

##content table td .shade {
	background-color: ##F5F5F5;
}

##content table table td {
	border: none;
	padding: 0;
	margin: 0;
}


/* pageNav
---------------*/

.pageNavTabs {
	margin: 2em 0 2em 0;
	padding: 1em 0 1em 0;
	overflow: hidden;
	border-top: 1px dotted ##D0D0D0;
	border-bottom: 1px dotted ##D0D0D0;
}

.pageNavTabs ul {
	list-style-type: none;
	margin: 0;
	padding: 0;
	float: right;
	width: 960px;
}

.pageNavTabs li {
	list-style-type: none;
	border-left: 1px dotted ##D0D0D0;
	float: left;
	line-height: 24px;
	margin: 0 1em 0 -1em;
	padding: 0 1em 0 1em;
}

.pageNavTabs li:first-child {
	border-left: none;
}

.pageNavTabs li img {
	vertical-align: middle;
}

.pageNavTabs li form select {
	vertical-align: middle;
}


.pageNavTabs a, .pageNavTabs a:visited {
	cursor: pointer;
}



/* FOOTER
---------------*/

##footer {
	clear: both;
	padding: 24px 0 24px 0;
}

##footer div {
	padding: 12px 0 12px 0;
	border-top: 1px dotted ##D0D0D0;
	border-bottom: 1px dotted ##D0D0D0;
}

##footer p {
	font-size: 0.9em;
	color: ##666;
}

##footer p.red {
	color: ##CC0000;
}

##footer p img {
	vertical-align: top;
}
</cfoutput>