<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2009 GreatBizTools, LLC

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

Author: Ben Edwards (ben@ben-edwards.com)
$Id$

Created version: 1.0.0
Deprecated in version: 1.1.0
Updated version: 1.6.0


Notes:
This invoker is DEPRECATED and may not be included with future versions of Mach-II.
Please use EventInvoker.cfc instead.
--->
<cfcomponent 
	displayname="CFCInvoker_Event" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="DEPRECATED. ListenerInvoker that invokes a Listener's method passing the Event as the sole argument.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CFCInvoker_Event" output="false"
		hint="DEPRECATED. Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="invokeListener" access="public" returntype="void"
		hint="DEPRECATED. Invokes the Listener.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The Event triggering the invocation." />
		<cfargument name="listener" type="MachII.framework.Listener" required="true"
			hint="The Listener to invoke." />
		<cfargument name="method" type="string" required="true"
			hint="The name of the Listener's method to invoke." />
		<cfargument name="resultKey" type="string" required="false" default=""
			hint="The variable to set the result in." />
		<cfargument name="resultArg" type="string" required="false" default=""
			hint="Not supported." />
		
		<cfset var resultValue = "" />
		<cfset var log = arguments.listener.getLog() />
		
		<cftry>
			<!--- Enable output and invoke listener method --->
			<cfsetting enablecfoutputonly="false" /><cfinvoke 
				component="#arguments.listener#" 
				method="#arguments.method#" 
				event="#arguments.event#" 
				returnvariable="resultValue" /><cfsetting enablecfoutputonly="true" />
			
			<!--- resultKey --->
			<cfif arguments.resultKey NEQ ''>
				<cfset "#arguments.resultKey#" = resultValue />
			</cfif>
			<!--- resultArg not supported. --->
			
			<cfif log.isWarnEnabled()>
				<cfset log.warn("DEPRECATED: Listener '#arguments.listener.getComponentNameForLogging()#' is using the CFCInvoker_Event which has been deprecated. Please use the EventInvoker.") />
			</cfif>

			<cfcatch type="Any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>