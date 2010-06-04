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