<cfsilent>
<!---

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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfheader statuscode="503" statustext="Service Unavailable" />
</cfsilent>
<cfcontent reset="true" /><cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="refresh" content="10" />

	<title>Application Loading</title>

	<style type="text/css">
		* {
		margin: 0;
		padding: 0;
		}

		html {
		font-size: 100.1%; /* IE hack */
		}

		body {
		font: 100.1%/1.125em Arial, Tahoma, Verdana, Helvetica, sans-serif; /* the font size in EM */
		color: ##000;
		text-align: center;
		background-color: ##D0D0D0;
		}

		h1 { font-size: 155%; margin:0.25em 0 0.25em 0; padding: 0.5em 0 0.5em 0; }

		p { margin: 0; padding: 0.5em 0 0.5em 0; }

		##container {
		text-align: left;
		margin: 0 auto 0 auto;
		padding: 0;
		width: 600px;
		}

		##notice {
		position: absolute;
		top: 40%;
		width: 600px;
		text-align: center;
		background-color: ##FFF;
		border: 3px solid ##999;
		padding: 0.5em;
		-moz-border-radius:	12px;
		-webkit-border-radius:	12px;
		}
	</style>
</head>
<body>
	<div id="container">
		<div id="notice">
			<h1>Please Wait...</h1>
			<p>The application is loading. We will retry your request again in 10 seconds.</p>
		</div>
	</div>
</body>
</html></cfoutput>