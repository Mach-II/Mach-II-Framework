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

Original license from Douglas Crockford (http://www.crockford.com/javascript/jsmin.c).
This work is a translation from original C to CFML of jsmin.c published by Douglas Crockford:
------------------------------------------------------------------------------------------
Copyright (c) 2002 Douglas Crockford (www.crockford.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------------------

Notes:
The JSCompressor is a modified port of the Java version of JSMin by Douglas Crockford.
Thank you to Mr. Crockford for his efforts on this utility.

This CFC *cannot* be used as a singleton and therefore is not thread-safe.
--->
<cfcomponent
	displayname="JsCompressor"
	output="false"
	hint="Compresses JS files.">

	<!---
	PROPERTIES
	--->
	<cfset variables.in = "" />
	<cfset variables.out = "" />
	<cfset variables.theA = 0 />
	<cfset variables.theB = 0 />
	<cfset variables.line = 1 />
	<cfset variables.column = 0 />

	<!--- "Static" --->
	<cfset variables.EOF = -1 />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="JsCompressor" output="false"
		hint="Initializes the compressor.">
		<cfargument name="in" type="any" required="true"
			hint="An input stream of the type java.io.InputStream." />
		<cfargument name="out" type="any" required="true"
			hint="An output stream of the type java.io.OutputStream." />

		<!--- Wrap a pushback stream around the input steam so we can peek at bytes without modifying data --->
		<cfset variables.in = CreateObject("java", "java.io.PushbackInputStream").init(arguments.in) />
		<cfset variables.out = arguments.out />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<!--- Copy the input to the output, deleting the characters which are
	 	insignificant to JavaScript. Comments will be removed. Tabs will be
	 	replaced with spaces. Carriage returns will be replaced with linefeeds.
	 	Most spaces and linefeeds will be removed. --->
	<cffunction name="compress" access="public" returntype="void" output="false"
		hint="Compress the javascript.">

		<cftry>
			<!--- Line feed (\n) --->
			<cfset variables.theA = 10 />
			<cfset action(3) />

			<cfloop condition="variables.theA NEQ variables.EOF">
				<cfscript>
					switch (variables.theA) {
						// If space
						case 32:
							if (isAlphanum(variables.theB)) {
								action(1);
							} else {
								action(2);
							}
							break;
						// If line break "/n"
						case 10:
							switch (variables.theB) {
								// If case '{', '[', '(', '+', '-'
								case '123,91,40,43,45':
									action(1);
									break;
								// If line break "/n"
								case 10:
									action(3);
									break;
								default:
									if (isAlphanum(variables.theB)) {
										action(1);
									} else {
										action(2);
									}
							}
							break;
						default:
							switch (variables.theB) {
							// If space
							case 32:
								if (isAlphanum(variables.theA)) {
									action(1);
									break;
								}
								action(3);
								break;
							// If line break "/n"
							case 10:
								switch (theA) {
								// If case '}', ']', ')', '+', '-', '"', "'":
								case '125,93,41,43,45,34,92':
									action(1);
									break;
								default:
									if (isAlphanum(variables.theA)) {
										action(1);
									} else {
										action(3);
									}
								}
								break;
							default:
								action(1);
								break;
							}
					}
				</cfscript>
			</cfloop>

			<cfset variables.in.close() />

			<!--- Just in case there are any errors, close the streams (wish <cffinally> was available on all CFML engines) --->
			<cfcatch type="any">
				<cfset variables.in.close() />
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="isAlphanum" access="private" returntype="boolean" output="false"
		hint="Returns true if the character is a letter, digit, underscore, dollar sign or non-ASCII character.">
		<cfargument name="c" type="numeric" required="true" />
		<!---
			Valid characters:
			* a-z
			* 0-9
			* A-Z
			* _
			* $
			* \
			* GT 126
		--->
		<cfreturn (arguments.c GTE 97 AND arguments.c LTE 122)
			OR (arguments.c GTE 48 AND arguments.c LTE 57)
			OR (arguments.c GTE 65 AND arguments.c LTE 90)
			OR arguments.c EQ 95
			OR arguments.c EQ 36
			OR arguments.c EQ 92
			OR arguments.c GT 126 />
	</cffunction>

	<cffunction name="get" access="private" returntype="numeric" output="false"
		hint="Return the next character from stdin. Watch out for lookahead. If
		the character is a control character, translate it to a space or linefeed.">

		<cfset var c = variables.in.read() />

		<cfif c EQ 10>
			<cfset variables.line = variables.line + 1 />
			<cfset variables.column = 0 />
		<cfelse>
			<cfset variables.column = variables.column + 1 />
		</cfif>

		<!--- If space or higher, line feed (\n) or EOF, the return a character --->
		<cfif c GTE 32 OR c EQ 10 OR c EQ variables.EOF>
			<cfreturn c />
		</cfif>

		<!--- If carriage return (\r), then return a line feed (\n) --->
		<cfif c EQ 13>
			<cfset variables.column = 0 />
			<cfreturn 10 />
		</cfif>

		<!--- If anything else, then return a space --->
		<cfreturn 32 />
	</cffunction>

	<cffunction name="peek" access="private" returntype="numeric" output="false"
		hint="Get the next character without getting it.">

		<cfset var lookaheadChar = variables.in.read() />

		<cfset variables.in.unread(lookaheadChar) />

		<cfreturn lookaheadChar />
	</cffunction>

	<cffunction name="next" access="private" returntype="numeric" output="false"
		hint="Get the next character, excluding comments. peek() is used to see if a '/' is followed by a '/' or '*'.">

		<cfset var c = get() />

		<!--- If / --->
		<cfif c EQ 47>
			<!--
			The tag version cfswitch does not have fall through support so we have to switch to cfscript
			--->
			<cfscript>
				switch (peek()) {
				// if "/"
				case 47:
					while (1) {
						c = get();
						// If LTE line break "/n"
						if (c LTE 10) {
							return c;
						}
					}

				// if "*"
				case 42:
					get();
					while (1) {
						switch (get()) {

						// if "*"
						case 42:
							// if "/"
							if (peek() EQ 47) {
								get();
								// Return space
								return 32;
							}
							break;
						// if EoF
						case '-1':
							unterminatedCommentException();
						}
					}

				default:
					return c;
				}
			</cfscript>
		</cfif>

		<cfreturn c />
	</cffunction>

	 <!--- action -- do something! What you do is determined by the argument: 1
	 	Output A. Copy B to A. Get the next B. 2 Copy B to A. Get the next B.
	 	(Delete A). 3 Get the next B. (Delete B). action treats a string as a
	 	single character. Wow! action recognizes a regular expression if it is
	 	preceded by ( or , or =. --->
	<cffunction name="action" access="private" returntype="void" output="false"
		hint="Peforms an action by type.">
		<cfargument name="d" type="numeric" required="true" />

		<!--
		The tag version cfswitch does not have fall through support so we have to switch to cfscript
		--->
		<cfscript>
			switch (arguments.d) {
			case 1:
				variables.out.append(JavaCast("string", variables.theA));
			case 2:
				variables.theA = variables.theB;

				// If "\" or '"'
				if (variables.theA EQ 39 OR variables.theA EQ 34) {
					while (1) {
						variables.out.append(JavaCast("string", variables.theA));
						variables.theA = get();
						if (variables.theA EQ variables.theB) {
							break;
						}
						// If LTE line break "/n"
						if (variables.theA LTE 10) {
							unterminatedStringLiteralException();
						}
						// If "\"
						if (variables.theA == 92) {
							variables.out.append(JavaCast("string", variables.theA));
							variables.theA = get();
						}
					}
				}

			case 3:
				variables.theB = next();

				/*
					If "/" AND one of the following:
					'(', ',', '=', ':', '[', '!', '&', '|', '?', '{', '}', ';' or line break '\n'
				*/
				if (variables.theB EQ 47
					AND (variables.theA EQ 40 OR variables.theA EQ 44
							OR variables.theA EQ 61 OR variables.theA EQ 58
							OR variables.theA EQ 91 OR variables.theA EQ 33
							OR variables.theA EQ 38 OR variables.theA EQ 124
							OR variables.theA EQ 63 OR variables.theA EQ 123
							OR variables.theA EQ 125 OR variables.theA EQ 59
							OR variables.theA EQ 10)) {
					variables.out.append(JavaCast("string", variables.theA));
					variables.out.append(JavaCast("string", variables.theB));

					while (1) {
						variables.theA = get();
						// If "/"
						if (variables.theA EQ 47) {
							break;
						// If "\"
						} else if (variables.theA EQ 92) {
							variables.out.append(JavaCast("string", variables.theA));
							variables.theA = get();
						// If LTE line break "/n"
						} else if (variables.theA LTE 10) {
							unterminatedRegExpLiteralException();
						}
						variables.out.append(JavaCast("string", variables.theA));
					}
					variables.theB = next();
				}
			}
		</cfscript>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="throwUnterminatedCommentException" access="private" returntype="void" output="false"
		hint="Throws a 'UnterminatedCommentException' exception.">
		<cfthrow type="MachII.util.JSCompressor.UnterminatedCommentException"
			message="Unterminated comment at line #variables.line# and column #variables.column#." />
	</cffunction>

	<cffunction name="throwUnterminatedStringLiteralException" access="private" returntype="void" output="false"
		hint="Throws a 'UnterminatedStringLiteralException' exception.">
		<cfthrow type="MachII.util.JSCompressor.UnterminatedStringLiteralException"
			message="Unterminated string literal at line #variables.line# and column #variables.column#." />
	</cffunction>

	<cffunction name="throwUnterminatedRegExpLiteralException" access="private" returntype="void" output="false"
		hint="Throws a 'UnterminatedRegExpLiteralException' exception.">
		<cfthrow type="MachII.util.JSCompressor.UnterminatedRegExpLiteralException"
			message="Unterminated regular expression at line #variables.line# and column #variables.column#." />
	</cffunction>

	<!---
	ACCESSORS
	--->

</cfcomponent>