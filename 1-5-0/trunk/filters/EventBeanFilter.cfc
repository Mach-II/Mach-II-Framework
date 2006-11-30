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
$Id: EventBeanFilter.cfc 4352 2006-08-29 20:35:15Z pfarrell $

Created version: 1.0.10
Updated version: 1.1.0

EventBeanFilter
	This event-filter creates beans in an event and populates the beans
	using event-args.
	
	Beans are expected to follow the standard Java bean pattern of having
	a no argument constuctor (an init() function with no required arguments) 
	and setter functions with name setXXX() (with a single argument named XXX) 
	for field XXX.
	
	If the "fields" parameter is not specified for the filter, then the 
	entire event-args struct will be passed to the bean's init() function 
	as an argument collection.
	
Configuration Parameters:
	["name"] - The name of the bean to create (in the event-args).
	["type"] - The type of the bean to create.
	["fields"] - The fields from the event-args to set in the bean.
	
Event-Handler Parameters:
	These parameters will override configuration parameters specified with 
		the same name.
	"name" - The name of the bean to create (in the event-args).
	"type" - The type of the bean to create.
	"fields" - The fields from the event-args to set in the bean.
--->
<cfcomponent 
	displayname="EventBeanFilter" 
	extends="MachII.framework.EventFilter"
	output="false"
	hint="A robust EventFilter for creating and populating beans in events.">
	
	<!---
	PROPERTIES
	--->
	<cfset this.BEAN_NAME_PARAM = "name" />
	<cfset this.BEAN_TYPE_PARAM = "type" />
	<cfset this.BEAN_FIELDS_PARAM = "fields" />
	
	<cfset variables.beanUtil = "" />
	
	<!---
	INITALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the filter.">
		<cfset setBeanUtil( CreateObject('component','MachII.util.BeanUtil') ) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean"
		hint="Runs the filter event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var bean = "" />
		<cfset var beanName = "" />
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var isFieldsDefined = false />
		
		<!--- beanName --->
		<cfif StructKeyExists(arguments.paramArgs, this.BEAN_NAME_PARAM)>
			<cfset beanName = paramArgs[this.BEAN_NAME_PARAM] />
		<cfelseif isParameterDefined(this.BEAN_NAME_PARAM)>
			<cfset beanName = getParameter(this.BEAN_NAME_PARAM) />
		</cfif>
		
		<!--- beanType --->
		<cfif StructKeyExists(arguments.paramArgs, this.BEAN_TYPE_PARAM)>
			<cfset beanType = paramArgs[this.BEAN_TYPE_PARAM] />
		<cfelseif isParameterDefined(this.BEAN_TYPE_PARAM)>
			<cfset beanType = getParameter(this.BEAN_TYPE_PARAM) />
		</cfif>
		
		<!--- beanFields --->
		<cfif StructKeyExists(arguments.paramArgs, this.BEAN_FIELDS_PARAM)>
			<cfset beanFields = paramArgs[this.BEAN_FIELDS_PARAM] />
			<cfset isFieldsDefined = true />
		<cfelseif isParameterDefined(this.BEAN_FIELDS_PARAM)>
			<cfset beanFields = getParameter(this.BEAN_FIELDS_PARAM) />
			<cfset isFieldsDefined = true />
		<cfelse>
			<cfset isFieldsDefined = false />
		</cfif>
		
		<!--- Check for required parameters. --->
		<cfif beanName EQ '' OR beanType EQ ''>
			<cfset throwUsageException() />
		</cfif>
		
		<!--- Create the bean and populate it using either setters or init(). --->
		<cfif isFieldsDefined>
			<cfset bean = getBeanUtil().createBean(beanType) />
			<cfset getBeanUtil().setBeanFields(bean, beanFields, arguments.event.getArgs()) />
		<cfelse>
			<cfset bean = getBeanUtil().createBean(beanType, arguments.event.getArgs()) />
		</cfif>
		
		<!--- Set the bean in the event-args. --->
		<cfset arguments.event.setArg(beanName, bean, beanType) />
		
		<cfreturn true />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="throwUsageException" access="private" returntype="void" output="false">
		<cfset var throwMsg = "EventBeanFilter requires the following usage parameters: " & this.BEAN_NAME_PARAM & ", " & this.BEAN_TYPE_PARAM & "." />
		<cfthrow message="#throwMsg#" />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setBeanUtil" access="private" returntype="void" output="false">
		<cfargument name="beanUtil" type="MachII.util.BeanUtil" required="true" />
		<cfset variables.beanUtil = arguments.beanUtil />
	</cffunction>
	<cffunction name="getBeanUtil" access="private" returntype="MachII.util.BeanUtil" output="false">
		<cfreturn variables.beanUtil />
	</cffunction>
	
</cfcomponent>