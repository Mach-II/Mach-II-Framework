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
$Id: SizedQueue.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.0
--->
<cfcomponent 
	displayname="SizedQueue" 
	extends="Queue"
	output="false"
	hint="A specialization of Queue to limit size.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.maxSize = 100 />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="SizedQueue" output="false"
		hint="Initializes the queue.">
		<cfargument name="maxSize" type="numeric" required="false" default="100" />
		
		<cfset super.init() />
		<cfset setMaxSize(arguments.maxSize) />
		
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="put" access="public" returntype="void" output="false"
		hint="Queues the item.">
		<cfargument name="item" type="any" required="true" />
		
		<cfif NOT isFull()>
			<cfset super.put(arguments.item) />
		<cfelse>
			<cfthrow message="Max size of SizedQueue is #getMaxSize()# and has been exceeded." />
		</cfif>
	</cffunction>
	
	<cffunction name="isFull" access="public" returntype="boolean" output="false"
		hint="Returns whether or not the queue is full.">
		<cfreturn getSize() EQ getMaxSize() />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setMaxSize" access="public" returntype="void" output="false"
		hint="Sets the maximum size of the queue.">
		<cfargument name="maxSize" type="numeric" required="true" />
		<cfset variables.maxSize = arguments.maxSize />
	</cffunction>
	<cffunction name="getMaxSize" access="public" returntype="numeric" output="false"
		hint="Returns the maximum size of the queue.">
		<cfreturn variables.maxSize />
	</cffunction>
	
</cfcomponent>