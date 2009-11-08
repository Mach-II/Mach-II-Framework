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

Created version: 1.1.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="EventInvoker" 
	output="false"
	extends="MachII.framework.ListenerInvoker"
	hint="ListenerInvoker that invokes a Listener's method passing the Event as the sole argument.">
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventInvoker" output="false"
		hint="Used by the framework for initialization. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="invokeListener" access="public" returntype="void"
		hint="Invokes the Listener.">
		<cfargument name="event" type="MachII.framework.Event" required="true"
			hint="The Event triggering the invocation." />
		<cfargument name="listener" type="MachII.framework.Listener" required="true"
			hint="The Listener to invoke." />
		<cfargument name="method" type="string" required="true"
			hint="The name of the Listener's method to invoke." />
		<cfargument name="resultKey" type="string" required="false" default=""
			hint="The variable to set the result in." />
		<cfargument name="resultArg" type="string" required="false" default=""
			hint="The eventArg to set the result in." />
		
		<cfset var resultValue = "" />
		<cfset var componentNameForLogging = arguments.listener.getComponentNameForLogging() />
		<cfset var log = arguments.listener.getLog() />
		
		<cftry>
			<cfif log.isDebugEnabled()>
				<cfset log.debug("Listener '#componentNameForLogging#' invoking method '#arguments.method#'.") />
			</cfif>
			
			<!--- Enable output and invoke listener method --->
			<cfsetting enablecfoutputonly="false" /><cfinvoke 
				component="#arguments.listener#" 
				method="#arguments.method#" 
				event="#arguments.event#" 
				returnvariable="resultValue" /><cfsetting enablecfoutputonly="true" />
			
			<!--- resultKey --->
			<cfif arguments.resultKey NEQ ''>
				<cfif log.isWarnEnabled()>
					<cfset log.warn("DEPRECATED: The ResultKey attribute has been deprecated. This was called by listener '#componentNameForLogging#' invoking method '#arguments.method#'.") />
				</cfif>
				<cfset "#arguments.resultKey#" = resultValue />
			</cfif>
			<!--- resultArg --->
			<cfif arguments.resultArg NEQ ''>
				<cfif log.isDebugEnabled()>
					<cfset log.debug("Listener '#componentNameForLogging#' method '#arguments.method#' returned data in event-arg '#arguments.resultArg#.'", resultValue) />
				</cfif>
				<cfset arguments.event.setArg(arguments.resultArg, resultValue) />
			</cfif>

			<cfcatch type="expression">
				<cfif FindNoCase("RESULTVALUE", cfcatch.Message)>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Listener '#componentNameForLogging#' method '#arguments.method#' has returned void but a ResultArg/Key has been defined.",  cfcatch) />
					</cfif>
					<cfthrow type="MachII.framework.VoidReturnType"
							message="A ResultArg/Key has been specified on a notify command method that is returning void. This can also happen if your listener method returns a Java null. Return data from your listener or remove the resultArg/Key from your notify command."
							detail="Listener: '#getMetadata(listener).name#' Method: '#arguments.method#'" />
				<cfelse>
					<cfif log.isErrorEnabled()>
						<cfset log.error("Listener '#componentNameForLogging#' method '#arguments.method#' has caused an exception.",  cfcatch) />
					</cfif>
					<cfset arguments.listener.getUtils().rebundledException("Listener '#componentNameForLogging#' method '#arguments.method#' has caused an exception."
								, cfcatch
								, getMetadata(arguments.listener).path) />
				</cfif>
			</cfcatch>
			<cfcatch type="any">
				<cfif log.isErrorEnabled()>
					<cfset log.error("Listener '#componentNameForLogging#' method '#arguments.method#' has caused an exception.",  cfcatch) />
				</cfif>
				<cfset arguments.listener.getUtils().rebundledException("Listener '#componentNameForLogging#' method '#arguments.method#' has caused an exception."
							, cfcatch
							, getMetadata(arguments.listener).path) />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>