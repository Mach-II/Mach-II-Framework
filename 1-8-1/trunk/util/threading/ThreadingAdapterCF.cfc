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
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="ThreadingAdapter"
	extends="MachII.util.threading.ThreadingAdapter"
	output="false"
	hint="Threading adapter for Adobe ColdFusion 8+.">

	<!---
	PROPERTIES
	--->
	<cfset variables.allowThreading = TRUE />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ThreadingAdapter" output="false"
		hint="This initializes the adapter for Adobe ColdFusion 8+.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="run" access="public" returntype="string" output="false"
		hint="Runs a thread.">
		<cfargument name="callback" type="component" required="true"
			hint="A CFC to perform the callback on." />
		<cfargument name="method" type="string" required="true"
			hint="Name of method to call on the callback CFC." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="Arguments to pass to the callback method." />
		
		<cfset var threadId = createThreadId(arguments.method) />
		<cfset var collection = { action="run", name=threadId, threadId=threadId } />
		
		<!--- cfthread duplicates all passed attributes (we do not want to pass a copy of the event to the thread) --->
		<cfset request._MachIIThreadingAdapter[threadId] = { 
				component=arguments.callback
				, method=arguments.method
				, argumentCollection=arguments.parameters
				, returnVariable="thread.resultData" } />
		
		<!--- Run the thread and catch any errors for later --->
		<cfthread attributeCollection="#collection#">
			<cftry>
				<cfset thread.collection = request._MachIIThreadingAdapter[threadId] />
				
				<cfinvoke attributeCollection="#thread.collection#" />
				
				<cfif IsDefined("thread.resultData")>
					<cfset thread.result = true />
				<cfelse>
					<cfset thread.result = false />
					<cfset thread.resultData = "" />
				</cfif>
					
				<!--- Catch and rethrow so this will be logged --->
				<cfcatch type="any">
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfthread>
		
		<cfreturn threadId />
	</cffunction>
	
	<cffunction name="join" access="public" returntype="any" output="false"
		hint="Joins a group of threads.">
		<cfargument name="threadIds" type="any" required="true"
			hint="A list, struct or array of thread ids to join." />
		<cfargument name="timeout" type="numeric" required="true"
			hint="How many seconds to wait to join threads. Set to 0 to wait forever (or until request timeout is reached)." />
		
		<cfset var collection = StructNew() />
		<cfset var results = StructNew() />
		<cfset var i = "" />
		
		<cfset collection.action = "join" />
		
		<!--- Convert the thread ids into a list --->
		<cfif IsStruct(arguments.threadIds)>
			<cfset collection.name = StructKeyList(arguments.threadIds) />
		<cfelseif IsArray(arguments.threadIds)>
			<cfset collection.name = ArrayToList(arguments.threadIds) />
		<cfelse>
			<cfset collection.name = arguments.threadIds />
		</cfif>
		
		<!--- ColdFusion 8 does not allow a timeout="0" --->
		<cfif arguments.timeout GT 0>
			<cfset collection.timeout = convertSecondsToMilliseconds(arguments.timeout) />
		</cfif>
		
		<!--- ResultArgs are automatically put into the event so we just have to wait for all threads --->
		<cfthread attributeCollection="#collection#" />
		
		<cfset results.errors = ArrayNew(1) />
		
		<!--- Check for unhandled errors in the threads --->
		<cfloop list="#collection.name#" index="i">
			
			<!--- CF will error out for some reason if you don't pre-create the struct --->
			<cfset results[i] = StructNew() />
			
			<!--- Check if the thread was terminated and return the error to be handled --->
			<cfif cfthread[i].status is "terminated">
				<cfset ArrayAppend(results.errors, i) />
				<cfset results[i].error = cfthread[i].error />
			<cfelse>
				<cfset results[i].result = cfthread[i].result />
				<cfset results[i].resultData = cfthread[i].resultData />
			</cfif>
		</cfloop>
		
		<cfreturn results />
	</cffunction>

</cfcomponent>