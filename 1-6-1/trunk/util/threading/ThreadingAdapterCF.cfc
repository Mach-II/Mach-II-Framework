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
$Id: MessageHandler.cfc 549 2007-11-11 22:19:47Z peterfarrell $

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
		
		<!--- cfthread duplicates all passed attributes (we do not want to pass a copy of the even to the thread) --->
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