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
$Id: RequiredFieldsFilter.cfc 4352 2006-08-29 20:35:15Z pfarrell $

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