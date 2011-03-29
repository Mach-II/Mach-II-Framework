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

Created version: 1.9.0

Notes:
Your concrete task implementation with extend this CFC:

MachII.endpoints.task.BaseEndpoint

Configuration Notes:

Simple Configuration:
<endpoints>
	<endpoint name="scheduledTasks" type="path.to.you.TaskEndpoint" />
</endpoints>

Custom Configuration:
<endpoints>
	<endpoint name="scheduledTasks" type="path.to.you.TaskEndpoint">
		<parameters>
			<!--
			Optional: Enables (boolean) the registeration of scheduled tasks in the CFML engine if set to
				false the endpoint will be available, but no tasks will be registered in the CFML engine
				and any tasks in the CFML engine that start with the taskNamePrefix will be removed
			Default: true
			-->
			<parameter name="enabled" value="" />
			<!--
			Optional: The prefix to use in front of the task name when registering it with cfschedule
			Default:  "{application.applicationName}_{endpointName}"
			-->
			<parameter name="taskNamePrefix" value="" />
			<!--
			Optional: THe base server and protocol to use for task url.
			Default:  http://{cgi.server_name}
			-->
			<parameter name="server" value="" />
			<!--
			Optional: The basic HTTP access authentication user name.
			Default: Auto-generated
			-->
			<parameter name="authUsername" value="" />
			<!--
			Optional: The basic HTTP access authentication password.
			Default: Auto-generated
			-->
			<parameter name="authPassword" value="" />
		</parameters>
	</endpoint>
</endpoints>

--->
<cfcomponent
	displayname="ScheduledTaskEndpoint"
	extends="MachII.endpoints.AbstractEndpoint"
	output="false"
	hint="Base endpoint for all scheduled task endpoints to be exposed directly by Mach-II.">

	<!---
	CONSTANTS
	--->
	<!--- Constants for the annotations we allow in ScheduledTask sub-classes --->
	<cfset variables.ANNOTATION_TASK_BASE = "TASK" />
	<cfset variables.ANNOTATION_TASK_ENABLED = variables.ANNOTATION_TASK_BASE & ":ENABLED" />
	<cfset variables.ANNOTATION_TASK_INTERVAL = variables.ANNOTATION_TASK_BASE & ":INTERVAL" />
	<cfset variables.ANNOTATION_TASK_STARTDATE = variables.ANNOTATION_TASK_BASE & ":STARTDATE" />
	<cfset variables.ANNOTATION_TASK_ENDDATE = variables.ANNOTATION_TASK_BASE & ":ENDDATE" />
	<cfset variables.ANNOTATION_TASK_TIMEPERIOD = variables.ANNOTATION_TASK_BASE & ":TIMEPERIOD" />
	<cfset variables.ANNOTATION_TASK_REQUESTTIMEOUT = variables.ANNOTATION_TASK_BASE & ":REQUESTTIMEOUT" />
	<cfset variables.ANNOTATION_TASK_ALLOWCONCURRENTEXECUTIONS = variables.ANNOTATION_TASK_BASE & ":ALLOWCONCURRENTEXECUTIONS" />
	<cfset variables.ANNOTATION_TASK_RETRYONFAILURE = variables.ANNOTATION_TASK_BASE & ":RETRYONFAILURE" />
	<cfset variables.STARTDATE_DEFAULT = "8/1/03" /><!--- The date of our first release which is sufficiently enough in the past --->
	<cfset variables.REQUESTTIMEOUT_DEFAULT = 180 />

	<!---
	PROPERTIES
	--->
	<!--- Introspector looks for TASK:* annotations in child classes to find TASK-enabled methods. --->
	<cfset variables.introspector = CreateObject("component", "MachII.util.metadata.Introspector").init() />
	<cfset variables.authentication = "" />
	<cfset variables.urlBase = "" />
	<cfset variables.server = "" />
	<cfset variables.authUsername = "" />
	<cfset variables.authPassword = "" />
	<cfset variables.adminApi = "" />
	<cfset variables.taskNamePrefix = "" />
	<cfset variables.tasks = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Configures the scheduled task endpoint. Override to provide custom functionality and call super.preProcess() last.">
		
		<!--- Default is "{applicationName}_{endpointName}" or "{userDefinedPrefix}" --->
		<cfset setTaskNamePrefix(getParameter("taskNamePrefix", application.applicationName & "_" & getParameter("name")) & "_") />
		<cfset setUrlBase(getProperty("urlBase")) />
		<cfset setServer(getParameter("server", cgi.server_name)) />
		
		<!--- Only create a URLBase if the properties.urlBase doesn't start with https:// or http:// --->
		<cfif NOT getUrlBase().toLowerCase().startsWith("http://") AND NOT getUrlBase().toLowerCase().startsWith("https://")>
			<cfset setUrlBase("http://" & getServer() & getUrlBase()) />
		</cfif>

		<!--- Setup default in parameters so if the endpoint is reloaded by dashboard they don't change --->
		<cfif NOT IsParameterDefined("authUsername")>
			<cfset setParameter("authUsername", Left(Hash(getTickCount() & RandRange(0, 1000000) & RandRange(0, 1000000)), 12)) />
		</cfif>
		<cfif NOT IsParameterDefined("authPassword")>
			<cfset setParameter("authPassword", CreateUUID()) />
		</cfif>		
		
		<cfset setAuthUsername(getParameter("authUsername")) />
		<cfset setAuthPassword(getParameter("authPassword")) />
		
		<cfif IsStruct(getParameter("enabled"))>
			<cfset setEnabled(resolveValueByEnvironment(getParameter("enabled"), true)) />
		<cfelse>
			<cfset setEnabled(getParameter("enabled", true)) />
		</cfif>
		
		<!--- Setup authentication services --->
		<cfset variables.authentication = CreateObject("component", "MachII.security.http.basic.Authentication").init(application.applicationName & "Scheduled Tasks") />
		<cfset variables.authentication.setCredentials(buildAuthCredentials()) />
		
		<!--- Get a CFML engine API engine adapter --->
		<cfset variables.adminApi = getUtils().createAdminApiAdapter() />
		
		<!--- Setup the endpoint --->
		<cfset setupTaskMethods() />
		<cfset manageTasks() />
	</cffunction>

	<!---
	PUBLIC METHODS - REQUEST
	--->
	<cffunction name="onAuthenticate" access="public" returntype="void" output="false"
		hint="Authenticates the scheduled task request. Do not override this method.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<!--- All requests must be authenticated --->
		<cfif NOT variables.authentication.authenticate(getHTTPRequestData().headers)>
			<cfthrow type="MachII.endpoints.task.notAuthorized"
				message="Bad credentials." />
		</cfif>
	</cffunction>
	
	<cffunction name="handleRequest" access="public" returntype="void" output="true"
		hint="Executes the scheduled task method. Do not override this method.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

		<cfset var taskName = arguments.event.getArg("task") />
		<cfset var task = "" />
		<cfset var aquiredLock = false />
		<cfset var output = "" />

		<!--- Setup basic required request args --->
		<cfset arguments.event.setArg("retryOnFailureCount", 0) />
	
		<!--- Check for a task that accepts requests from the outside (always check variables.tasks for security reasons) --->
		<cfif StructKeyExists(variables.tasks, taskName)>
			<cfset task = variables.tasks[taskName] />
			
			<!--- Set the request timeout for this task --->
			<cfsetting requesttimeout="#task.requestTimeout#" />
			
			<!--- Handle allow concurrent execution --->
			<cfif NOT task.allowConcurrentExecutions>
				<cflock name="_MachIITaskEndpoint_#getTaskNamePrefix()##taskName#" type="exclusive" timeout="1" throwontimeout="false">
					<cfset aquiredLock = true />
					<cfset output = invokeTask(task, arguments.event) />
				</cflock>

				<!--- It is easier to check a condition then try/catch a failed attempt at aquiring a lock --->
				<cfif NOT aquiredLock>
					<cfthrow type="MachII.endpoints.task.noConcurrentExecution"
						message="Blocked concurrent execution of task '#taskName#' in '#getParameter("name")#' endpoint." />
				</cfif>
			<cfelse>
				<cfset output = invokeTask(task, arguments.event) />
			</cfif>
			
			<cfsetting enablecfoutputonly="false" /><cfoutput>#output#</cfoutput><cfsetting enablecfoutputonly="true" />		
		<cfelse>
			<!--- Ultimately this will be processed by the AbstractEndpoint base onException() --->
			<cfthrow type="MachII.endpoints.EndpointNotDefined"
				message="Cannot find a task named '#taskName#' in '#getParameter("name")#' endpoint." />
		</cfif>
	</cffunction>
	
	<cffunction name="onException" access="public" returntype="void" output="true"
		hint="Runs when an exception occurs in the endpoint. Override to provide custom functionality and call super.onException(arguments.event, arguments.exception) last.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="exception" type="MachII.util.Exception" required="true"
			hint="The Exception that was thrown/caught by the endpoint request processor." />
		
		<!--- Handle notAuthorized --->
		<cfif arguments.exception.getType() EQ "MachII.endpoints.task.notAuthorized">
			<cfset addHTTPHeaderByStatus(401) />
			<cfset addHTTPHeaderByName("machii.endpoint.error", arguments.exception.getMessage()) />
			<cfsetting enablecfoutputonly="false" /><cfoutput>401 Not Authorized - #arguments.exception.getMessage()#</cfoutput><cfsetting enablecfoutputonly="true" />
		<!--- Handle noConcurrentExecution --->
		<cfelseif arguments.exception.getType() EQ "MachII.endpoints.task.noConcurrentExecution">
			<cfset addHTTPHeaderByStatus(409) />
			<cfset addHTTPHeaderByName("machii.endpoint.error", arguments.exception.getMessage()) />
			<cfsetting enablecfoutputonly="false" /><cfoutput>409 Conflict - #arguments.exception.getMessage()#</cfoutput><cfsetting enablecfoutputonly="true" />		
		<!--- Default exception handling --->
		<cfelse>
			<cfset super.onException(arguments.event, arguments.exception) />
		</cfif>
	</cffunction>
	
	<cffunction name="buildEndpointUrl" access="public" returntype="string" output="false"
		hint="Builds an Url specific to this endpoint. We use query string URLs because it does not matter for scheduled tasks.">
		<cfargument name="task" type="string" required="true"
			hint="The name of the task." />
			
		<cfset var builtUrl = getUrlBase() & "?" />
		
		<cfset builtUrl = builtUrl & "endpoint=" & getParameter("name") />
		<cfset builtUrl = ListAppend(builtUrl, "task=" & arguments.task, "&") />
		
		<cfreturn builtUrl />
	</cffunction>
	
	<!---
	PROTECTED METHODS
	--->
	<cffunction name="invokeTask" access="private" returntype="string" output="false"
		hint="Invokes a task. This method is recursive if retry on failure is enabled for this task.">
		<cfargument name="task" type="struct" required="true"
			hint="The internal task metadata struct." />
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var output = "" />
		<cfset var startTick = getTickCount() />
			
		<cftry>
			<cfinvoke component="#this#" method="#arguments.task.name#" returnvariable="output">
				<cfinvokeargument name="event" value="#arguments.event#" />
			</cfinvoke>
			<cfcatch type="any">
				<!--- Increment the failures --->
				<cfset arguments.event.setArg("retryOnFailureCount", arguments.event.getArg("retryOnFailureCount") + 1) />

				<!--- Handle retry on failure --->
				<cfif arguments.task.retryOnFailure GT 0 AND arguments.event.getArg("retryOnFailureCount") LTE arguments.task.retryOnFailure>
					<cfset invokeTask(arguments.task, arguments.event) />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>
		
		<cfif IsDefined("output")>
			<cfreturn output />
		<cfelse>
			<cfreturn "Task '#task.name#' has completed execution in #getTickCount() - startTick#ms." />
		</cfif>
	</cffunction>
	
	<cffunction name="setupTaskMethods" access="private" returntype="void" output="false"
		hint="Setups all task related methods by introspection the metadata. This method is recursive and looks through all the object hierarchy until the stop class.">
		<cfargument name="taskMethodMetadata" type="array" required="false"
			default="#variables.introspector.findFunctionsWithAnnotations(object:this, namespace:variables.ANNOTATION_TASK_BASE, walkTree:true, walkTreeStopClass:'MachII.endpoints.schedule.BaseEndpoint')#"
			hint="An array of metadata to discover any TASK methods in." />

		<cfset var currMetadata = "" />
		<cfset var currFunction = "" />
		<cfset var taskMetadata = "" />
		<cfset var i = 0 />
		
		<cfif ArrayLen(arguments.taskMethodMetadata)>
			<cfset currMetadata = arguments.taskMethodMetadata[1] />

			<cfif StructKeyExists(currMetadata, "functions")>
				<cfloop from="1" to="#ArrayLen(currMetadata.functions)#" index="i">
					<!--- Iterate through found methods and look for required TASK:INTERVAL annotation which is required for a tasks --->
					<cfset currFunction = currMetadata.functions[i] />
					
					<!---
					Add the task if the required TASK:INTERVAL is defined and the task name is not already defined.
					We need to check for already defined tasks due to object inheritance. We loop through the top level
					inheritance first so those should be even priority over matches in the super classes.
					--->
					<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_INTERVAL)
						AND NOT StructKeyExists(variables.tasks, currFunction.name)>
						
						<cfset taskMetadata = StructNew() />
						
						<cfset taskMetadata.name = currFunction.name />
						<cfset taskMetadata.interval = currFunction[variables.ANNOTATION_TASK_INTERVAL] />
						
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_STARTDATE)>
							<cfset taskMetadata.startDate = currFunction[variables.ANNOTATION_TASK_STARTDATE] />
						<cfelse>
							<cfset taskMetadata.startDate = variables.STARTDATE_DEFAULT />
						</cfif>

						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_ENDDATE)>
							<cfset taskMetadata.endDate = currFunction[variables.ANNOTATION_TASK_ENDDATE] />
						<cfelse>
							<cfset taskMetadata.endDate = 0 />
						</cfif>
						
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_TIMEPERIOD)>
							<cfset taskMetadata.timePeriod = currFunction[variables.ANNOTATION_TASK_TIMEPERIOD] />
						<cfelse>
							<cfset taskMetadata.timePeriod = "00:00" />
						</cfif>
						
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_REQUESTTIMEOUT)>
							<cfset taskMetadata.requestTimeout = currFunction[variables.ANNOTATION_TASK_REQUESTTIMEOUT] />
						<cfelse>
							<cfset taskMetadata.requestTimeout = variables.REQUESTTIMEOUT_DEFAULT />
						</cfif>

						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_ALLOWCONCURRENTEXECUTIONS)>
							<cfset taskMetadata.allowConcurrentExecutions = currFunction[variables.ANNOTATION_TASK_ALLOWCONCURRENTEXECUTIONS] />
						<cfelse>
							<cfset taskMetadata.allowConcurrentExecutions = false />
						</cfif>
						
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_RETRYONFAILURE)>
							<cfset taskMetadata.retryOnFailure = currFunction[variables.ANNOTATION_TASK_RETRYONFAILURE] />
						<cfelse>
							<cfset taskMetadata.retryOnFailure = 0 />
						</cfif>
						
						<cfif StructKeyExists(currFunction, variables.ANNOTATION_TASK_ENABLED)>
							<cfset taskMetadata.enabled = currFunction[variables.ANNOTATION_TASK_ENABLED] />
						<cfelse>
							<cfset taskMetadata.enabled = true />
						</cfif>

						<cfset variables.tasks[taskMetadata.name] = taskMetadata />
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- Pop off the current level of metadata and recurse until the stop class if required --->
			<cfset ArrayDeleteAt(arguments.taskMethodMetadata, 1) />
			
			<cfif ArrayLen(arguments.taskMethodMetadata)>
				<cfset setupTaskMethods(arguments.taskMethodMetadata) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="manageTasks" access="private" returntype="void" output="false"
		hint="Manages tasks that belong to this endpoint.">
		
		<cfset var key = "" />
		<cfset var task = "" />
		
		<!--- Remove all tasks by prefix --->
		<cfset variables.adminApi.deleteTasks(getTaskNamePrefix() & "*") />
		
		<!--- Add all defined tasks if enabled--->
		<cfif isEnabled()>
			<cfloop collection="#variables.tasks#" item="key">
				<cfset task = variables.tasks[key] />
				
				<!--- Only define tasks that are enabled --->
				<cfif task.enabled>
					<cfset variables.adminApi.addTask(getTaskNamePrefix() & task.name
														, BuildEndpointUrl(task.name)
														, task.interval
														, task.startDate
														, task.endDate
														, task.timePeriod
														, getAuthUsername()
														, getAuthPassword()
														, task.requestTimeout) />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="buildAuthCredentials" access="private" returntype="struct" output="false"
		hint="Builds the authentication credentials maps for injection into the basic HTTP access authenticate module.">
		
		<cfset var credentials = StructNew() />
		
		<cfset credentials[getAuthUsername()] = Hash(getAuthPassword(), "sha") />
		
		<cfreturn credentials />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setEnabled" access="public" returntype="void" output="false">
		<cfargument name="enabled" type="boolean" required="true" />
		<cfset variables.enabled = arguments.enabled />
	</cffunction>
	<cffunction name="isEnabled" access="public" returntype="boolean" output="false">
		<cfreturn variables.enabled />
	</cffunction>
	
	<cffunction name="setTaskNamePrefix" access="public" returntype="void" output="false">
		<cfargument name="taskNamePrefix" type="string" required="true" />
		<cfset variables.taskNamePrefix = arguments.taskNamePrefix />
	</cffunction>
	<cffunction name="getTaskNamePrefix" access="public" returntype="string" output="false">
		<cfreturn variables.taskNamePrefix />
	</cffunction>
	
	<cffunction name="setUrlBase" access="public" returntype="void" output="false">
		<cfargument name="urlBase" type="string" required="true" />
		<cfset variables.urlBase = arguments.urlBase />
	</cffunction>
	<cffunction name="getUrlBase" access="public" returntype="string" output="false">
		<cfreturn variables.urlBase />
	</cffunction>
	
	<cffunction name="setServer" access="public" returntype="void" output="false">
		<cfargument name="server" type="string" required="true" />
		
		<!--- Only set the server if url base does not have a full URL with server and protocal in it --->
		<cfif NOT getUrlBase().startsWith("http://") OR NOT getUrlBase().startsWith("https://")>
			<!--- Ensure an absolute path if to route bootstrapper file --->
			<cfif NOT getUrlBase().startsWith("/")>
				<cfset arguments.server = arguments.server & getUtils().filePathClean(getDirectoryFromPath(cgi.scriptName)) />
			</cfif>
			<cfset variables.server = arguments.server />
		</cfif>
	</cffunction>
	<cffunction name="getServer" access="public" returntype="string" output="false">
		<cfreturn variables.server />
	</cffunction>
	
	<cffunction name="setAuthUsername" access="public" returntype="void" output="false">
		<cfargument name="authUsername" type="string" required="true" />
		<cfset variables.authUsername = arguments.authUsername />
	</cffunction>
	<cffunction name="getAuthUsername" access="public" returntype="string" output="false">
		<cfreturn variables.authUsername />
	</cffunction>

	<cffunction name="setAuthpassword" access="public" returntype="void" output="false">
		<cfargument name="authpassword" type="string" required="true" />
		<cfset variables.authPassword = arguments.authPassword />
	</cffunction>
	<cffunction name="getAuthpassword" access="public" returntype="string" output="false">
		<cfreturn variables.authPassword />
	</cffunction>

</cfcomponent>