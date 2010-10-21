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

Created version: 1.8.0
Updated version: 1.8.0
--->
<cfcomponent
	name="GetterSetterInjectionMethods"
	hint="A target object for method injection."
	output="false">

	<!---
	PROPERTIES
	--->
	<cfset variables.beanNames = ArrayNew(1) />
	<cfset variables._MachIIBeansToMethods = ArrayNew(1) />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="GetterSetterInjectionMethods" output="false"
		hint="Intializes the injection methods object.">
		<cfargument name="beanNames" type="array" required="true" />
		
		<cfset setBeanNames(beanNames) />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="_injectMethods" access="public" returntype="void" output="false"
		hint="Used to inject the methods. Due to the reflection involed we need to pass in a reference this to objection again.">
		<cfargument name="object" type="MachII.util.injection.GetterSetterInjectionMethods" required="true"
			hint="A reference to this object." />
		<cfargument name="targets" type="struct" required="true"
			hint="A struct of bean targets." />
		
		<cfset var i = 0 />
		<cfset var beanNames = arguments.object.getBeanNames() />
		<cfset var beanName = "" />
		<cfset var machIIBeansToMethods = StructNew() />
		
		<cfloop from="1" to="#ArrayLen(beanNames)#" index="i">
			<cfset beanName = beanNames[i] />
			
			<cfset this["set" & beanName] = arguments.object["set" & i] />
			<cfset variables["set" & beanName] = arguments.object["set" & i] />

			<cfset this["get" & beanName] = arguments.object["get" & i] />
			<cfset variables["get" & beanName] = arguments.object["get" & i] />			

			<cfset machIIBeansToMethods[i] = beanName />
		</cfloop>
		
		<cfset StructAppend(variables, arguments.targets, true) />
		<cfset variables._MachIIBeansToMethods = machIIBeansToMethods />
	</cffunction>

	<!---
	INJECTION METHODS
	--->
	<cffunction name="set1" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["1"]] = arguments.object />
	</cffunction>
	<cffunction name="get1" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["1"]] />
	</cffunction>
	
	<cffunction name="set2" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["2"]] = arguments.object />
	</cffunction>
	<cffunction name="get2" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["2"]] />
	</cffunction>
	
	<cffunction name="set3" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["3"]] = arguments.object />
	</cffunction>
	<cffunction name="get3" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["3"]] />
	</cffunction>
	
	<cffunction name="set4" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["4"]] = arguments.object />
	</cffunction>
	<cffunction name="get4" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["4"]] />
	</cffunction>
	
	<cffunction name="set5" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["5"]] = arguments.object />
	</cffunction>
	<cffunction name="get5" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["5"]] />
	</cffunction>

	<cffunction name="set6" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["6"]] = arguments.object />
	</cffunction>
	<cffunction name="get6" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["6"]] />
	</cffunction>

	<cffunction name="set7" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["7"]] = arguments.object />
	</cffunction>
	<cffunction name="get7" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["7"]] />
	</cffunction>
	
	<cffunction name="set8" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["8"]] = arguments.object />
	</cffunction>
	<cffunction name="get8" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["8"]] />
	</cffunction>
	
	<cffunction name="set9" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["9"]] = arguments.object />
	</cffunction>
	<cffunction name="get9" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["9"]] />
	</cffunction>
	
	<cffunction name="set10" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["10"]] = arguments.object />
	</cffunction>
	<cffunction name="get10" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["10"]] />
	</cffunction>
	
	<cffunction name="set11" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["11"]] = arguments.object />
	</cffunction>
	<cffunction name="get11" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["11"]] />
	</cffunction>
	
	<cffunction name="set12" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["12"]] = arguments.object />
	</cffunction>
	<cffunction name="get12" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["12"]] />
	</cffunction>
	
	<cffunction name="set13" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["13"]] = arguments.object />
	</cffunction>
	<cffunction name="get13" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["13"]] />
	</cffunction>
	
	<cffunction name="set14" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["14"]] = arguments.object />
	</cffunction>
	<cffunction name="get14" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["14"]] />
	</cffunction>

	<cffunction name="set15" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["15"]] = arguments.object />
	</cffunction>
	<cffunction name="get15" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["15"]] />
	</cffunction>

	<cffunction name="set16" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["16"]] = arguments.object />
	</cffunction>
	<cffunction name="get16" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["16"]] />
	</cffunction>
	
	<cffunction name="set17" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["17"]] = arguments.object />
	</cffunction>
	<cffunction name="get17" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["17"]] />
	</cffunction>
	
	<cffunction name="set18" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["18"]] = arguments.object />
	</cffunction>
	<cffunction name="get18" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["18"]] />
	</cffunction>
	
	<cffunction name="set19" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["19"]] = arguments.object />
	</cffunction>
	<cffunction name="get19" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["19"]] />
	</cffunction>
	
	<cffunction name="set20" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["20"]] = arguments.object />
	</cffunction>
	<cffunction name="get20" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["20"]] />
	</cffunction>
	
	<cffunction name="set21" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["21"]] = arguments.object />
	</cffunction>
	<cffunction name="get21" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["21"]] />
	</cffunction>
	
	<cffunction name="set22" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["22"]] = arguments.object />
	</cffunction>
	<cffunction name="get22" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["22"]] />
	</cffunction>
	
	<cffunction name="set23" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["23"]] = arguments.object />
	</cffunction>
	<cffunction name="get23" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["23"]] />
	</cffunction>
	
	<cffunction name="set24" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["24"]] = arguments.object />
	</cffunction>
	<cffunction name="get24" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["24"]] />
	</cffunction>
	
	<cffunction name="set25" access="public" returntype="void" output="false">
		<cfargument name="object" type="any" required="true" />
		<cfset variables[variables._MachIIBeansToMethods["25"]] = arguments.object />
	</cffunction>
	<cffunction name="get25" access="public" returntype="any" output="false">
		<cfreturn variables[variables._MachIIBeansToMethods["25"]] />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setBeanNames" access="private" returntype="void" output="false">
		<cfargument name="beanNames" type="array" required="true" />
		<cfset variables.beanNames = arguments.beanNames />
	</cffunction>
	<cffunction name="getBeanNames" access="public" returntype="array" output="false">
		<cfreturn variables.beanNames />
	</cffunction>

</cfcomponent>