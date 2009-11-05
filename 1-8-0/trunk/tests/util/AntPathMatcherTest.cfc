<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id: AntPathMatcherTest.cfc 814 2008-06-14 21:48:39Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Notes:
Patterns for the test has been kindly ported from the 
Spring Framework (http://www.springframework.org)
--->
<cfcomponent
	displayname="AntPathMatcherTest"
	extends="mxunit.framework.TestCase"
	hint="Test cases for MachII.util.AntPathMatcher.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.pm = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Logic to run to setup before each test case method.">		
		<cfset variables.pm = CreateObject("component", "MachII.util.AntPathMatcher").init() />
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" output="false"
		hint="Logic to run to tear down after each test case method.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - TEST CASES
	--->
	<cffunction name="testMatch" access="public" returntype="void" output="false"
		hint="Tests match() with various coverage of exact, ?, *, ** and combos.">
		
		<!--- Test exact matching --->
		<cfset assertTrue(variables.pm.match("", "")) />
		<cfset assertTrue(variables.pm.match("test", "test")) />
		<cfset assertTrue(variables.pm.match("/test", "/test")) />
		<cfset assertFalse(variables.pm.match("/test.jpg", "test.jpg")) />
		<cfset assertFalse(variables.pm.match("test", "/test")) />
		<cfset assertFalse(variables.pm.match("/test", "test")) />
		
		<!--- test matching with ?'s --->
		<cfset assertTrue(variables.pm.match("t?st", "test")) />
		<cfset assertTrue(variables.pm.match("??st", "test")) />
		<cfset assertTrue(variables.pm.match("tes?", "test")) />
		<cfset assertTrue(variables.pm.match("te??", "test")) />
		<cfset assertTrue(variables.pm.match("?es?", "test")) />
		<cfset assertFalse(variables.pm.match("tes?", "tes")) />
		<cfset assertFalse(variables.pm.match("tes?", "testt")) />
		<cfset assertFalse(variables.pm.match("tes?", "tsst")) />

		<!--- Test matchin with *'s --->
		<cfset assertTrue(variables.pm.match("*", "test")) />
		<cfset assertTrue(variables.pm.match("test*", "test")) />
		<cfset assertTrue(variables.pm.match("test*", "testTest")) />
		<cfset assertTrue(variables.pm.match("test/*", "test/Test")) />
		<cfset assertTrue(variables.pm.match("test/*", "test/t")) />
		<cfset assertTrue(variables.pm.match("test/*", "test/")) />
		<cfset assertTrue(variables.pm.match("*test*", "AnothertestTest")) />
		<cfset assertTrue(variables.pm.match("*test", "Anothertest")) />
		<cfset assertTrue(variables.pm.match("*.*", "test.")) />
		<cfset assertTrue(variables.pm.match("*.*", "test.test")) />
		<cfset assertTrue(variables.pm.match("*.*", "test.test.test")) />
		<cfset assertTrue(variables.pm.match("test*aaa", "testblaaaa")) />
		<cfset assertFalse(variables.pm.match("test*", "tst")) />
		<cfset assertFalse(variables.pm.match("test*", "tsttest")) />
		<cfset assertFalse(variables.pm.match("test*", "test/")) />
		<cfset assertFalse(variables.pm.match("test*", "test/t")) />
		<cfset assertFalse(variables.pm.match("test/*", "test")) />
		<cfset assertFalse(variables.pm.match("*test*", "tsttst")) />
		<cfset assertFalse(variables.pm.match("*test", "tsttst")) />
		<cfset assertFalse(variables.pm.match("*.*", "tsttst")) />
		<cfset assertFalse(variables.pm.match("test*aaa", "test")) />
		<cfset assertFalse(variables.pm.match("test*aaa", "testblaaab")) />

		<!--- Test matching with ?'s and /'s --->
		<cfset assertTrue(variables.pm.match("/?", "/a")) />
		<cfset assertTrue(variables.pm.match("/?/a", "/a/a")) />
		<cfset assertTrue(variables.pm.match("/a/?", "/a/b")) />
		<cfset assertTrue(variables.pm.match("/??/a", "/aa/a")) />
		<cfset assertTrue(variables.pm.match("/a/??", "/a/bb")) />
		<cfset assertTrue(variables.pm.match("/?", "/a")) />
		<cfset assertFalse(variables.pm.match("/????", "/bala/bla")) />

		<!--- Test matching with **'s --->
		<cfset assertTrue(variables.pm.match("/**", "/testing/testing")) />
		<cfset assertTrue(variables.pm.match("/*/**", "/testing/testing")) />
		<cfset assertTrue(variables.pm.match("/**/*", "/testing/testing")) />
		<cfset assertTrue(variables.pm.match("/bla/**/bla", "/bla/testing/testing/bla")) />
		<cfset assertTrue(variables.pm.match("/bla/**/bla", "/bla/testing/testing/bla/bla")) />
		<cfset assertTrue(variables.pm.match("/**/test", "/bla/bla/test")) />
		<cfset assertTrue(variables.pm.match("/bla/**/**/bla", "/bla/bla/bla/bla/bla/bla")) />
		<cfset assertTrue(variables.pm.match("/bla*bla/test", "/blaXXXbla/test")) />
		<cfset assertTrue(variables.pm.match("/*bla/test", "/XXXbla/test")) />
		<cfset assertTrue(variables.pm.match("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing/")) />
		<cfset assertTrue(variables.pm.match("/*bla*/**/bla/*", "/XXXblaXXXX/testing/testing/bla/testing")) />
		<cfset assertTrue(variables.pm.match("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing")) />
		<cfset assertTrue(variables.pm.match("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing.jpg")) />
		<cfset assertTrue(variables.pm.match("*bla*/**/bla/**", "XXXblaXXXX/testing/testing/bla/testing/testing/")) />
		<cfset assertTrue(variables.pm.match("*bla*/**/bla/*", "XXXblaXXXX/testing/testing/bla/testing")) />
		<cfset assertTrue(variables.pm.match("*bla*/**/bla/**", "XXXblaXXXX/testing/testing/bla/testing/testing")) />
		<cfset assertFalse(variables.pm.match("/bla*bla/test", "/blaXXXbl/test")) />
		<cfset assertFalse(variables.pm.match("/*bla/test", "XXXblab/test")) />
		<cfset assertFalse(variables.pm.match("/*bla/test", "XXXbl/test")) />
		<cfset assertFalse(variables.pm.match("/**/*bla", "/bla/bla/bla/bbb")) />
		<cfset assertFalse(variables.pm.match("/x/x/**/bla", "/x/x/x/")) />
		<cfset assertFalse(variables.pm.match("*bla*/**/bla/*", "XXXblaXXXX/testing/testing/bla/testing/testing")) />
	</cffunction>

	<cffunction name="testMatchStart" access="public" returntype="void" output="false"
		hint="Tests matchStart() with various coverage of exact, ?, *, ** and combos.">

		<!--- test exact matching --->
		<cfset assertTrue(variables.pm.matchStart("", "")) />
		<cfset assertTrue(variables.pm.matchStart("test", "test")) />
		<cfset assertTrue(variables.pm.matchStart("/test", "/test")) />
		<cfset assertFalse(variables.pm.matchStart("/test.jpg", "test.jpg")) />
		<cfset assertFalse(variables.pm.matchStart("test", "/test")) />
		<cfset assertFalse(variables.pm.matchStart("/test", "test")) />

		<!--- test matching with ?'s --->
		<cfset assertTrue(variables.pm.matchStart("t?st", "test")) />
		<cfset assertTrue(variables.pm.matchStart("??st", "test")) />
		<cfset assertTrue(variables.pm.matchStart("tes?", "test")) />
		<cfset assertTrue(variables.pm.matchStart("te??", "test")) />
		<cfset assertTrue(variables.pm.matchStart("?es?", "test")) />
		<cfset assertFalse(variables.pm.matchStart("tes?", "tes")) />
		<cfset assertFalse(variables.pm.matchStart("tes?", "testt")) />
		<cfset assertFalse(variables.pm.matchStart("tes?", "tsst")) />

		<!--- test matching with *'s --->
		<cfset assertTrue(variables.pm.matchStart("*", "test")) />
		<cfset assertTrue(variables.pm.matchStart("test*", "test")) />
		<cfset assertTrue(variables.pm.matchStart("test*", "testTest")) />
		<cfset assertTrue(variables.pm.matchStart("test/*", "test/Test")) />
		<cfset assertTrue(variables.pm.matchStart("test/*", "test/t")) />
		<cfset assertTrue(variables.pm.matchStart("test/*", "test/")) />
		<cfset assertTrue(variables.pm.matchStart("*test*", "AnothertestTest")) />
		<cfset assertTrue(variables.pm.matchStart("*test", "Anothertest")) />
		<cfset assertTrue(variables.pm.matchStart("*.*", "test.")) />
		<cfset assertTrue(variables.pm.matchStart("*.*", "test.test")) />
		<cfset assertTrue(variables.pm.matchStart("*.*", "test.test.test")) />
		<cfset assertTrue(variables.pm.matchStart("test*aaa", "testblaaaa")) />
		<cfset assertTrue(variables.pm.matchStart("test/*", "test")) />
		<cfset assertTrue(variables.pm.matchStart("test/t*.txt", "test")) />
		<cfset assertFalse(variables.pm.matchStart("test*", "tst")) />
		<cfset assertFalse(variables.pm.matchStart("test*", "test/")) />
		<cfset assertFalse(variables.pm.matchStart("test*", "tsttest")) />
		<cfset assertFalse(variables.pm.matchStart("test*", "test/")) />
		<cfset assertFalse(variables.pm.matchStart("test*", "test/t")) />
		<cfset assertFalse(variables.pm.matchStart("*test*", "tsttst")) />
		<cfset assertFalse(variables.pm.matchStart("*test", "tsttst")) />
		<cfset assertFalse(variables.pm.matchStart("*.*", "tsttst")) />
		<cfset assertFalse(variables.pm.matchStart("test*aaa", "test")) />
		<cfset assertFalse(variables.pm.matchStart("test*aaa", "testblaaab")) />
		<cfset assertFalse(variables.pm.matchStart("/bla*bla/test", "/blaXXXbl/test")) />
		<cfset assertFalse(variables.pm.matchStart("/*bla/test", "XXXblab/test")) />
		<cfset assertFalse(variables.pm.matchStart("/*bla/test", "XXXbl/test")) />

		<!--- test matching with ?'s and /'s --->
		<cfset assertTrue(variables.pm.matchStart("/?", "/a")) />
		<cfset assertTrue(variables.pm.matchStart("/?/a", "/a/a")) />
		<cfset assertTrue(variables.pm.matchStart("/a/?", "/a/b")) />
		<cfset assertTrue(variables.pm.matchStart("/??/a", "/aa/a")) />
		<cfset assertTrue(variables.pm.matchStart("/a/??", "/a/bb")) />
		<cfset assertTrue(variables.pm.matchStart("/?", "/a")) />
		<cfset assertFalse(variables.pm.matchStart("/????", "/bala/bla")) />

		<!--- test matching with **'s --->
		<cfset assertTrue(variables.pm.matchStart("/**", "/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("/*/**", "/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("/**/*", "/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("test*/**", "test/")) />
		<cfset assertTrue(variables.pm.matchStart("test*/**", "test/t")) />
		<cfset assertTrue(variables.pm.matchStart("/bla/**/bla", "/bla/testing/testing/bla")) />
		<cfset assertTrue(variables.pm.matchStart("/bla/**/bla", "/bla/testing/testing/bla/bla")) />
		<cfset assertTrue(variables.pm.matchStart("/**/test", "/bla/bla/test")) />
		<cfset assertTrue(variables.pm.matchStart("/bla/**/**/bla", "/bla/bla/bla/bla/bla/bla")) />
		<cfset assertTrue(variables.pm.matchStart("/bla*bla/test", "/blaXXXbla/test")) />
		<cfset assertTrue(variables.pm.matchStart("/*bla/test", "/XXXbla/test")) />
		<cfset assertTrue(variables.pm.matchStart("/**/*bla", "/bla/bla/bla/bbb")) />
		<cfset assertTrue(variables.pm.matchStart("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing/")) />
		<cfset assertTrue(variables.pm.matchStart("/*bla*/**/bla/*", "/XXXblaXXXX/testing/testing/bla/testing")) />
		<cfset assertTrue(variables.pm.matchStart("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("/*bla*/**/bla/**", "/XXXblaXXXX/testing/testing/bla/testing/testing.jpg")) />
		<cfset assertTrue(variables.pm.matchStart("*bla*/**/bla/**", "XXXblaXXXX/testing/testing/bla/testing/testing/")) />
		<cfset assertTrue(variables.pm.matchStart("*bla*/**/bla/*", "XXXblaXXXX/testing/testing/bla/testing")) />
		<cfset assertTrue(variables.pm.matchStart("*bla*/**/bla/**", "XXXblaXXXX/testing/testing/bla/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("*bla*/**/bla/*", "XXXblaXXXX/testing/testing/bla/testing/testing")) />
		<cfset assertTrue(variables.pm.matchStart("/x/x/**/bla", "/x/x/x/")) />
	</cffunction>

	<cffunction name="testMatchWithUniqueDeliminator" access="public" returntype="void" output="false"
		hint="Test match() with an unique deliminator of '.'">
		<cfset variables.pm.setPathSeparator(".") />

		<!--- test exact matching --->
		<cfset assertTrue(variables.pm.match("test", "test")) />
		<cfset assertTrue(variables.pm.match(".test", ".test")) />
		<cfset assertFalse(variables.pm.match(".test/jpg", "test/jpg")) />
		<cfset assertFalse(variables.pm.match("test", ".test")) />
		<cfset assertFalse(variables.pm.match(".test", "test")) />

		<!--- test matching with ?'s --->
		<cfset assertTrue(variables.pm.match("t?st", "test")) />
		<cfset assertTrue(variables.pm.match("??st", "test")) />
		<cfset assertTrue(variables.pm.match("tes?", "test")) />
		<cfset assertTrue(variables.pm.match("te??", "test")) />
		<cfset assertTrue(variables.pm.match("?es?", "test")) />
		<cfset assertFalse(variables.pm.match("tes?", "tes")) />
		<cfset assertFalse(variables.pm.match("tes?", "testt")) />
		<cfset assertFalse(variables.pm.match("tes?", "tsst")) />

		<!--- test matchin with *'s --->
		<cfset assertTrue(variables.pm.match("*", "test")) />
		<cfset assertTrue(variables.pm.match("test*", "test")) />
		<cfset assertTrue(variables.pm.match("test*", "testTest")) />
		<cfset assertTrue(variables.pm.match("*test*", "AnothertestTest")) />
		<cfset assertTrue(variables.pm.match("*test", "Anothertest")) />
		<cfset assertTrue(variables.pm.match("*/*", "test/")) />
		<cfset assertTrue(variables.pm.match("*/*", "test/test")) />
		<cfset assertTrue(variables.pm.match("*/*", "test/test/test")) />
		<cfset assertTrue(variables.pm.match("test*aaa", "testblaaaa")) />
		<cfset assertFalse(variables.pm.match("test*", "tst")) />
		<cfset assertFalse(variables.pm.match("test*", "tsttest")) />
		<cfset assertFalse(variables.pm.match("*test*", "tsttst")) />
		<cfset assertFalse(variables.pm.match("*test", "tsttst")) />
		<cfset assertFalse(variables.pm.match("*/*", "tsttst")) />
		<cfset assertFalse(variables.pm.match("test*aaa", "test")) />
		<cfset assertFalse(variables.pm.match("test*aaa", "testblaaab")) />

		<!--- test matching with ?'s and .'s --->
		<cfset assertTrue(variables.pm.match(".?", ".a")) />
		<cfset assertTrue(variables.pm.match(".?.a", ".a.a")) />
		<cfset assertTrue(variables.pm.match(".a.?", ".a.b")) />
		<cfset assertTrue(variables.pm.match(".??.a", ".aa.a")) />
		<cfset assertTrue(variables.pm.match(".a.??", ".a.bb")) />
		<cfset assertTrue(variables.pm.match(".?", ".a")) />

		<!--- test matching with **'s --->
		<cfset assertTrue(variables.pm.match(".**", ".testing.testing")) />
		<cfset assertTrue(variables.pm.match(".*.**", ".testing.testing")) />
		<cfset assertTrue(variables.pm.match(".**.*", ".testing.testing")) />
		<cfset assertTrue(variables.pm.match(".bla.**.bla", ".bla.testing.testing.bla")) />
		<cfset assertTrue(variables.pm.match(".bla.**.bla", ".bla.testing.testing.bla.bla")) />
		<cfset assertTrue(variables.pm.match(".**.test", ".bla.bla.test")) />
		<cfset assertTrue(variables.pm.match(".bla.**.**.bla", ".bla.bla.bla.bla.bla.bla")) />
		<cfset assertTrue(variables.pm.match(".bla*bla.test", ".blaXXXbla.test")) />
		<cfset assertTrue(variables.pm.match(".*bla.test", ".XXXbla.test")) />
		<cfset assertFalse(variables.pm.match(".bla*bla.test", ".blaXXXbl.test")) />
		<cfset assertFalse(variables.pm.match(".*bla.test", "XXXblab.test")) />
		<cfset assertFalse(variables.pm.match(".*bla.test", "XXXbl.test")) />
	</cffunction>

	<cffunction name="testExtractPathWithinPattern" access="public" returntype="void" output="false"
		hint="Tests extractPathWithinPattern().">

		<cfset assertEquals("", variables.pm.extractPathWithinPattern("/docs/commit.html", "/docs/commit.html")) />
		<cfset assertEquals("cvs/commit", variables.pm.extractPathWithinPattern("/docs/*", "/docs/cvs/commit")) />
		<cfset assertEquals("commit.html", variables.pm.extractPathWithinPattern("/docs/cvs/*.html", "/docs/cvs/commit.html")) />
		<cfset assertEquals("cvs/commit", variables.pm.extractPathWithinPattern("/docs/**", "/docs/cvs/commit")) />
		<cfset assertEquals("cvs/commit.html", variables.pm.extractPathWithinPattern("/docs/**/*.html", "/docs/cvs/commit.html")) />
		<cfset assertEquals("commit.html", variables.pm.extractPathWithinPattern("/docs/**/*.html", "/docs/commit.html")) />
		<cfset assertEquals("commit.html", variables.pm.extractPathWithinPattern("/*.html", "/commit.html")) />
		<cfset assertEquals("docs/commit.html", variables.pm.extractPathWithinPattern("/*.html", "/docs/commit.html")) />
		<cfset assertEquals("/commit.html", variables.pm.extractPathWithinPattern("*.html", "/commit.html")) />
		<cfset assertEquals("/docs/commit.html", variables.pm.extractPathWithinPattern("*.html", "/docs/commit.html")) />
		<cfset assertEquals("/docs/commit.html", variables.pm.extractPathWithinPattern("**/*.*", "/docs/commit.html")) />
		<cfset assertEquals("/docs/commit.html", variables.pm.extractPathWithinPattern("*", "/docs/commit.html")) />
		<cfset assertEquals("docs/cvs/commit", variables.pm.extractPathWithinPattern("/d?cs/*", "/docs/cvs/commit")) />
		<cfset assertEquals("cvs/commit.html", variables.pm.extractPathWithinPattern("/docs/c?s/*.html", "/docs/cvs/commit.html")) />
		<cfset assertEquals("docs/cvs/commit", variables.pm.extractPathWithinPattern("/d?cs/**", "/docs/cvs/commit")) />
		<cfset assertEquals("docs/cvs/commit.html", variables.pm.extractPathWithinPattern("/d?cs/**/*.html", "/docs/cvs/commit.html")) />
	</cffunction>

</cfcomponent>