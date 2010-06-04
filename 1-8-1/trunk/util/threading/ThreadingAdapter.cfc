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

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="ThreadingAdapter"
	output="false"
	hint="Base threading adapter component. This is a base class. Please instantiate a concrete adapter.">

	<!---
	PROPERTIES
	--->
	<cfset variables.allowThreading = FALSE />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="ThreadingAdapter" output="false"
		hint="This is the base class. Please instantiate a concrete adapter.">
		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="run" access="public" returntype="void" output="false"
		hint="Runs a thread.">
		<cfargument name="callback" type="any" required="true"
			hint="A CFC to perform the callback on." />
		<cfargument name="method" type="string" required="true"
			hint="Name of method to call on the callback CFC." />
		<cfargument name="parameters" type="struct" required="false" default="#StructNew()#"
			hint="Arguments to pass to the callback method." />
		<cfabort showerror="This is the base class. Please instantiate a concrete adapter." />
	</cffunction>

	<cffunction name="join" access="public" returntype="void" output="false"
		hint="Joins a group of threads.">
		<cfargument name="threadIds" type="any" required="true"
			hint="A list, struct or array of thread ids to join." />
		<cfargument name="timeout" type="numeric" required="true"
			hint="How many seconds to wait to join threads. Set to 0 to wait forever (or until request timeout is reached)." />
		<cfabort showerror="This is the base class. Please instantiate a concrete adapter." />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - UTIL
	--->
	<cffunction name="allowThreading" access="public" returntype="boolean" output="false"
		hint="Returns a boolean if threading is allowed. Does not actually test if threading works, but a boolean of if threading is implemented in the target CFML engine in general.">
		<cfreturn variables.allowThreading />
	</cffunction>

	<cffunction name="testIfThreadingAvailable" access="public" returntype="boolean" output="false"
		hint="Tests if threading is available because some configurations disable threading in the security sandbox.">

		<cfset var available = true />

		<cftry>
			<cfset run(this, "dummyTestMethod") />

			<!--- If any error occurs, then threading has been disabled --->
			<cfcatch type="any">
				<cfset available = false />
			</cfcatch>
		</cftry>

		<cfreturn available />
	</cffunction>

	<cffunction name="dummyTestMethod" access="public" returntype="boolean" output="false"
		hint="This is just a dummy method for the testIfThreadingAvailable() method to call. DO NOT CALL THIS METHOD.">
		<cfreturn true />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createThreadId" access="private" returntype="string" output="false"
		hint="Creates a random tread id. Does not use UUID for performance reasons.">
		<cfargument name="method" type="string" required="true"
			hint="Name of method. Adds additional data for seed.">
		<cfreturn Hash(getTickCount() & RandRange(0, 100000) & RandRange(0, 100000) & arguments.method) />
	</cffunction>

	<cffunction name="convertSecondsToMilliseconds" access="private" returntype="numeric" output="false"
		hint="Convert seconds to milliseconds.">
		<cfargument name="seconds" type="numeric" required="true" />
		<cfreturn arguments.seconds * 1000 />
	</cffunction>

</cfcomponent>