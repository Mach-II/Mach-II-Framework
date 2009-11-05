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

Created version: 1.0.7
Updated version: 1.1.0
Deprecated version 1.5.0

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

Notes:
This filter has been DEPRECATED in Mach-II 1.5.0.
--->
<cfcomponent 
	displayname="EventBeanFilter" 
	extends="MachII.framework.EventFilter"
	output="false"
	hint="DEPRECATED. A robust EventFilter for creating and populating beans in events.">
	
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
		hint="DEPRECATED. Configures the filter.">
		<cfset setBeanUtil( CreateObject('component','MachII.util.BeanUtil') ) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="filterEvent" access="public" returntype="boolean"
		hint="DEPRECATED. Runs the filter event.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<cfargument name="paramArgs" type="struct" required="false" default="#StructNew()#" />
		
		<cfset var bean = "" />
		<cfset var beanName = "" />
		<cfset var beanType = "" />
		<cfset var beanFields = "" />
		<cfset var isFieldsDefined = false />
		<cfset var log = getLog() />
		
		<cfif log.isWarnEnabled()>
			<cfset log.warn("DEPRECATED: Filter '#getComponentNameForLogging()#' has been deprecated. Use the <event-bean> command.") />
		</cfif>
		
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