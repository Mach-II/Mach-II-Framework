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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
Queue methods are not synchronized so an external synchronization is required (i.e. cflock).
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
		<cfargument name="maxSize" type="numeric" required="false" default="100"
			hint="The maximum size of the queue before an exception is raised." />

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
			<cfthrow type="MachII.util.SizedQueue"
				message="Max size of SizedQueue is #getMaxSize()# and has been exceeded." />
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