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

Created version: 1.8.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent displayname="DummyListenerForInvokerTests"
	extends="MachII.framework.Listener"
	output="false">

	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC METHODS
	--->
	<cffunction name="testEventInvoker" access="public" returntype="any" output="false">
		<cfargument name="Event" type="MachII.framework.Event" required="true" />
	</cffunction>
	
	<cffunction name="testEventArgsInvokerWithReturn" access="public" returntype="string" output="false">
		<cfargument name="test1" type="any" required="true" />
		<cfargument name="test2" type="any" required="true" />
		<cfargument name="test3" type="any" required="true" />
		
		<cfreturn arguments.test1 & "_" & arguments.test2 & "_" & arguments.test3 />
	</cffunction>
	
	<cffunction name="testEventArgsInvokerWithoutReturn" access="public" returntype="void" output="false">
		<cfargument name="test1" type="any" required="true" />
		<cfargument name="test2" type="any" required="true" />
		<cfargument name="test3" type="any" required="true" />
		
		<cfif arguments.test1 NEQ "value1"
			AND arguments.test2 NEQ "value2"
			AND arguments.test3 NEQ "value3">
			<cfthrow message="Something is wrong because the values did not match." />
		</cfif>
	</cffunction>
	
	<cffunction name="testEventInvokerWithReturn" access="public" returntype="string" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfreturn arguments.event.getArg("test1") & "_" & arguments.event.getArg("test2") & "_" & arguments.event.getArg("test3") />
	</cffunction>
	
	<cffunction name="testEventInvokerWithoutReturn" access="public" returntype="void" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
				
		<cfif arguments.event.getArg("test1") NEQ "value1"
			AND rguments.event.getArg("test2") NEQ "value2"
			AND arguments.event.getArg("test3") NEQ "value3">
			<cfthrow message="Something is wrong because the values did not match." />
		</cfif>
	</cffunction>
	
	<cffunction name="testDummyException" access="public" returntype="void" output="false">
		<cfthrow message="Test exception" />
	</cffunction>

</cfcomponent>