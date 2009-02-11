<!--- 
License:
Copyright 2008 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id: ColdspringProperty.cfc 1294 2009-01-25 10:16:47Z peterfarrell $

Created version: 1.8.0
Updated version: 1.8.0

Original license from John Reilly (http://inconspicuous.org/projects/jsmin/jsmin.java):
------------------------------------------------------------------------------------------
/*
 * 
 * JSMin.java 2006-02-13
 * 
 * Updated 2007-08-20 with updates from jsmin.c (2007-05-22)
 * 
 * Copyright (c) 2006 John Reilly (www.inconspicuous.org)
 * 
 * This work is a translation from C to Java of jsmin.c published by
 * Douglas Crockford.  Permission is hereby granted to use the Java 
 * version under the same conditions as the jsmin.c on which it is
 * based.  
 * 
 * 
 * 
 * 
 * jsmin.c 2003-04-21
 * 
 * Copyright (c) 2002 Douglas Crockford (www.crockford.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * The Software shall be used for Good, not Evil.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
------------------------------------------------------------------------------------------

Notes:
The JSCompressor is a modified port of the Java version of JSMin by Douglas Crockford.
Thank you to Mr. Crockford for his efforts to this utility.

This CFC *cannot* be used as a singleton and therefore is not thread-safe.
--->
<cfcomponent 
	displayname="JSCompressor"
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
	<cfset variables.temp = "" />
	
	<!--- "Static" --->
	<cfset variables.EOF = -1 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="JSCompressor" output="false"
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
		
		<!--- Line feed (\n) --->
		<cfset variables.theA = 10 />
		<cfset action(3) />
		
		<cfloop condition="variables.theA NEQ variables.EOF">
			<cfswitch expression="#variables.theA#">
				<!--- Space --->
				<cfcase value="32">
					<cfif isAlphanum(variables.theB)>
						<cfset action(1) />
					<cfelse>
						<cfset action(2) />
					</cfif>
				</cfcase>
				<!--- Line feed (\n) --->
				<cfcase value="10">
					<cfswitch expression="#variables.theB#">
						<!---If { [ ( + - --->
						<cfcase value="123,91,40,43,45">
							<cfset action(1) />
						</cfcase>
						<!--- If space --->
						<cfcase value="32">
							<cfset action(3) />
						</cfcase>
						<cfdefaultcase>
							<cfif isAlphanum(variables.theB)>
								<cfset action(1) />
							<cfelse>
								<cfset action(2) />
							</cfif>
						</cfdefaultcase>
					</cfswitch>
				</cfcase>
				<cfdefaultcase>
					<cfswitch expression="#variables.theB#">
						<!--- If space --->
						<cfcase value="32">
							<cfif isAlphanum(variables.theA)>
								<cfset action(1) />
							<cfelse>
								<cfset action(3) />
							</cfif>
						</cfcase>
						<!--- If line feed (\n) --->
						<cfcase value="10">
							<cfswitch expression="#variables.theA#">
								<!--- If } ] ) + - " \ --->
								<cfcase value="125,93,41,43,45,34,92">
									<cfset action(1) />
								</cfcase>
								<cfdefaultcase>
									<cfif isAlphanum(variables.theA)>
										<cfset action(1) />
									<cfelse>
										<cfset action(3) />
									</cfif>
								</cfdefaultcase>
							</cfswitch>
						</cfcase>
						<cfdefaultcase>
							<cfset action(1) />
						</cfdefaultcase>
					</cfswitch>
				</cfdefaultcase>
			</cfswitch>
		</cfloop>
		
		<cfset variables.out.flush() />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="isAlphanum" access="private" returntype="boolean" output="false"
		hint="Returns true if the character is a letter, digit, underscore, dollar sign or non-ASCII character.">
		<cfargument name="c" type="numeric" required="true" />
		<cfreturn (arguments.c GTE 65 AND arguments.c LTE 90)
			OR (arguments.c GTE 141 AND arguments.c LTE 172)
			OR (arguments.c GTE 48 AND arguments.c LTE 57)
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
			<cfset column = 0 />
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
			<cfswitch expression="#peek()#">
				<!--- If / --->
				<cfcase value="47">
					<!--- Infinite loop until return occurs --->
					<cfloop condition="true">
						<cfset c = get() />
						<cfif c LTE 10>
							<cfreturn c />
						</cfif>
					</cfloop>
				</cfcase>
				
				<!--- If * --->
				<cfcase value="42">
					<cfset get() />
					<!--- Infinite loop until return occurs --->
					<cfloop condition="true">
						<cfswitch expression="#get()#">
							<!--- If * --->
							<cfcase value="42">
								<!--- If / --->
								<cfif peek() EQ 47>
									<cfset get() />
									<!--- Space --->
									<cfreturn 32 />
								</cfif>
							</cfcase>
							<cfcase value="-1">
								<cfset throwUnterminatedCommentException() />
							</cfcase>
						</cfswitch>
					</cfloop>
				</cfcase>
				<cfdefaultcase>
					<cfreturn c />
				</cfdefaultcase>
			</cfswitch>
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
		
		<cfswitch expression="#arguments.d#">
			<cfcase value="1">
				<cfset variables.out.write(variables.theA) />
			</cfcase>
			<cfcase value="2">
				<cfset variables.theA = variables.theB />
				
				<!--- If ' or  " --->
				<cfif variables.theA EQ 39 OR variables.theA EQ 34>
					<!--- Infinite loop until break occurs --->
					<cfloop condition="true">
						<cfset variables.out.write(variables.theA) />
						<cfset variables.theA = get() />
						
						<cfif variables.theA EQ variables.theB>
							<cfbreak />
						</cfif>
						<!--- If line feed (\n) --->
						<cfif variables.theA LTE 10>
							<cfset throwUnterminatedStringLiteralException() />
						</cfif>
						<!--- If \ --->
						<cfif variables.theA EQ 92>
							<cfset variables.out.write(variables.theA) />
							<cfset variables.theA = get() />
						</cfif>
					</cfloop>
				</cfif>
			</cfcase>
			<cfcase value="3">
				<cfset variables.theB = next() />
				<!--- If / AND one of ( , = : [ ! &  | ? { } \n --->
				<cfif variables.theB EQ 47
					AND (variables.theA EQ 40 OR variables.theA EQ 44
							OR variables.theA EQ 61 OR variables.theA EQ 58
							OR variables.theA EQ 91 OR variables.theA EQ 33
							OR variables.theA EQ 38 OR variables.theA EQ 124
							OR variables.theA EQ 63 OR variables.theA EQ 123
							OR variables.theA EQ 125 OR variables.theA EQ 59
							OR variables.theA EQ 10)>
					<cfset variables.out.write(variables.theA) />
					<cfset variables.out.write(variables.theB) />
					<!--- Infinite loop until break occurs --->
					<cfloop condition="true">
						<cfset variables.theA = get() />
						<!--- If / --->
						<cfif variables.theA EQ 47>
							<cfbreak />
						<!--- If \ --->
						<cfelseif variables.theA EQ 92>
							<cfset variables.out.write(variables.theA) />
							<cfset variables.theA = get() />
						<!--- If line feed (\n) --->
						<cfelseif variables.theA LTE 10>
							<cfset throwUnterminatedRegExpLiteralException() />
						</cfif>
						<cfset variables.out.write(variables.theA) />
					</cfloop>
					<cfset variables.theB = next() />
				</cfif>
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getVars">
		<cfreturn variables />
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