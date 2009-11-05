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

Created version: 1.0.10
Updated version: 1.1.0

RequiredFieldsFilter
	This event-filter tests an event for required fields specified.
	If the required fields are not present (or are blank) then event 
	processing is aborted and a specified event is announced.
	
	If the required fields aren't defined then 'message' and 'missingFields' 
	are set in the event.
	
Configuration Usage:
	No configuration parameters.
	
	<event-filters>
		<event-filter name="RequiredFields" type="MachII.filters.RequiredFieldsFilter" />
	</event-filters>

Event-Handler Usage:
	- "requiredFields" - a comma delimited list of fields required
	- "invalidEvent" - the event to announce if all required fields are not in the event
	
	<event-handler name="someImportantEvent" access="public">
		<filter name="RequiredFields">
			<parameter name="requiredFields" value="list,of,important,args" />
			<parameter name="invalidEvent" value="eventToGoToIfArgsAreNotThere" />
		</filter>
	</event-handler>

--->
<cfcomponent 
	displayname="RequiredFieldsFilter" 
	extends="MachII.framework.EventFilter"
	output="false"
	hint="An EventFilter for testing that an event's args contain a list of required fields.">
	
	<!---
	PROPERTIES
	--->
	<cfset this.REQUIRED_FIELDS_PARAM = "requiredFields" />
	<cfset this.INVALID_EVENT_PARAM = "invalidEvent" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="This configure does nothing.">
		<!--- Does nothing. --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean"
		hint="Runs the filter event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var isContinue = true />
		<cfset var missingFields = '' />
		<cfset var requiredFields = '' />
		<cfset var invalidEvent = '' />
		<cfset var field = 0 />
		<cfset var newEventArgs = 0 />
		
		<cfif StructKeyExists(arguments.paramArgs,this.REQUIRED_FIELDS_PARAM) 
				AND StructKeyExists(arguments.paramArgs,this.INVALID_EVENT_PARAM)>
			<cfset requiredFields = arguments.paramArgs[this.REQUIRED_FIELDS_PARAM] />
			<cfset invalidEvent = arguments.paramArgs[this.INVALID_EVENT_PARAM] />
			
			<cfloop index="field" list="#requiredFields#" delimiters=",">
				<cfif (NOT event.isArgDefined(field)) OR (event.getArg(field,'') EQ '')>
					<cfset missingFields = ListAppend(missingFields, field, ',') />
					<cfset isContinue = false />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset throwUsageException() />
		</cfif>
		
		<cfif isContinue>
			<cfreturn true />
		<cfelse>
			<cfset newEventArgs = arguments.event.getArgs() />
			<cfset newEventArgs['message'] = "Please provide all required fields. Missing fields: " & ReplaceNoCase(missingFields,',',', ','all') & "." />
			<cfset newEventArgs['missingFields'] = missingFields />
			<cfset arguments.eventContext.announceEvent(invalidEvent, newEventArgs) />
			
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="throwUsageException" access="private" returntype="void" output="false"
		hint="Throws an usage exception.">
		<cfset var throwMsg = "RequiredFieldsFilter requires the following usage parameters: " & this.REQUIRED_FIELDS_PARAM & ", " & this.INVALID_EVENT_PARAM & "." />
		<cfthrow message="#throwMsg#" />
	</cffunction>
	
</cfcomponent>