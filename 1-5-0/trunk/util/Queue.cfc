<!---
License:
Copyright 2006 Mach-II Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: Mach-II Corporation
Author: Ben Edwards (ben@ben-edwards.com)
$Id: Queue.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
--->
<cfcomponent 
	displayname="Queue"
	output="false"
	hint="A simple Queue component.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.queueArray = ArrayNew(1) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Queue" output="false"
		hint="Initializes the queue.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Queues the item.">
		<cfargument name="item" type="any" required="true"
			hint="Item to append to queue." />
		<cfset ArrayAppend(variables.queueArray, arguments.item) />
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" output="false"
		hint="Dequeues and returns the next item in the queue.">
		<cfset var nextItem = variables.queueArray[1] />
		<cfset ArrayDeleteAt(variables.queueArray, 1) />
		<cfreturn nextItem />
	</cffunction>
	
	<cffunction name="peek" access="public" returntype="any" output="false"
		hint="Peeks the next item in the queue without removing it.">
		<cfreturn variables.queueArray[1] />
	</cffunction>
	
	<cffunction name="clear" access="public" returntype="void" output="false"
		hint="Clears the queue.">
		<cfset ArrayClear(variables.queueArray) />
	</cffunction>
	
	<cffunction name="getSize" access="public" returntype="numeric" output="false"
		hint="Returns the size of the queue (number of elements).">
		<cfreturn ArrayLen(variables.queueArray) />
	</cffunction>
	
	<cffunction name="isEmpty" access="public" returntype="boolean" output="false"
		hint="Returns whether or not the queue is empty.">
		<cfreturn getSize() EQ 0 />
	</cffunction>
	
</cfcomponent>