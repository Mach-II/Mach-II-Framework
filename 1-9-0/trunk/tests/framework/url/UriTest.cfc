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

Author: Doug Smith (doug.smith@daveramsey.com)
$Id$

Created version: 1.9.0

Notes:
--->
<cfcomponent
	displayname="UriTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.framework.url.Uri.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testUriWithNoTokens" access="public" returntype="void" output="false"
		hint="Tests the URI matching code against URLs with no tokens.">

		<cfscript>
			var uri = CreateObject("component", "MachII.framework.url.Uri").init(
				"/content/item",
				"GET",
				"getContent",
				"content"
				);
			// Match, no format
			assertTrue(uri.matchUri('/content/item'), 'Should match /content/item.');
			var tokens = uri.getTokensFromUri('/content/item');
			assertFalse(IsDefined("tokens.format"), 'Should not have format included.');
			// Match, w/format
			tokens = uri.getTokensFromUri('/content/item.json');
			assertTrue(tokens.format == 'json', 'Should have json format.');
			// No match
			commonInvalidMatches(uri);
		</cfscript>

	</cffunction>

	<cffunction name="testUriWithOneToken" access="public" returntype="void" output="false"
		hint="Tests the URI matching code against URLs with one token.">

		<cfscript>
			var uri = CreateObject("component", "MachII.framework.url.Uri").init(
				"/content/item/{key}",
				"GET",
				"getContent",
				"content"
				);
			var tokens = "";

			// Match, no format
			assertTrue(uri.matchUri('/content/item/my-item'), 'Should match /content/item/my-item.');
			assertTrue(uri.matchUri('/content/item/my-item/'), 'Should match /content/item/my-item/.');

			tokens = uri.getTokensFromUri('/content/item/my-item');
			assertFalse(IsDefined("tokens.format"), 'Should not have format included.');
			assertTrue(tokens.key EQ 'my-item', 'Should have a key token match of my-item.');

			// Match, w/format
			tokens = uri.getTokensFromUri('/content/item/my-item.json');
			assertTrue(tokens.key EQ 'my-item', 'Should have a key token match of my-item.');
			assertTrue(tokens.format EQ 'json', 'Should have json format.');

			// No match
			assertFalse(uri.matchUri('/content/item'), 'Should not match /content/item');
			assertFalse(uri.matchUri('/content/item.xml'), 'Should not match /content/item.xml');
			commonInvalidMatches(uri);
		</cfscript>

	</cffunction>

	<cffunction name="testUriWithTwoTokens" access="public" returntype="void" output="false"
		hint="Tests the URI matching code against URLs with two tokens.">

		<cfscript>
			var uri = CreateObject("component", "MachII.framework.url.Uri").init(
				"/content/item/{key}/{category}",
				"GET",
				"getContent",
				"content"
				);
			var tokens = "";

			// Match, no format
			assertTrue(uri.matchUri('/content/item/my-item/my-cat'), 'Should match /content/item/my-item/my-cat.');

			tokens = uri.getTokensFromUri('/content/item/my-item/my-cat');
			assertFalse(IsDefined("tokens.format"), 'Should not have format included.');
			assertTrue(tokens.key EQ 'my-item', 'Should have a key token match of my-item.');
			assertTrue(tokens.category EQ 'my-cat', 'Should have a category token match of my-cat.');

			// Match, w/format
			tokens = uri.getTokensFromUri('/content/item/my-item/my-cat.json');
			assertTrue(tokens.key EQ 'my-item', 'Should have a key token match of my-item.');
			assertTrue(tokens.category EQ 'my-cat', 'Should have a category token match of my-cat.');
			assertTrue(tokens.format EQ 'json', 'Should have json format.');

			// No match
			assertFalse(uri.matchUri('/content/item'), 'Should not match /content/item');
			assertFalse(uri.matchUri('/content/item.xml'), 'Should not match /content/item.xml');
			commonInvalidMatches(uri);
		</cfscript>

	</cffunction>

	<!---
	PRIVATE FUNCTIONS - UTILITIES
	--->
	<cffunction name="commonInvalidMatches" access="private" returntype="void" output="false"
		hint="Tests the URI matching code against URLs with two tokens.">
		<cfargument name="uri" type="MachII.framework.url.Uri" required="true" />

		<cfscript>
			assertFalse(arguments.uri.matchUri('/content'), 'Should not match /content');
			assertFalse(arguments.uri.matchUri('/'), 'Should not match /');
			assertFalse(arguments.uri.matchUri(''), 'Should not match empty string');
			assertFalse(arguments.uri.matchUri('/not/even/close/to/matching'), 'Should not match /not/even/close/to/matching');
			assertFalse(arguments.uri.matchUri('lakjsdlajsdlkj'), 'Should not match lakjsdlajsdlkj');
		</cfscript>
	</cffunction>

</cfcomponent>