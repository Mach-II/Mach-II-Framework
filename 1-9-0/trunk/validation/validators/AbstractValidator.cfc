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

Created version: 1.9.0
Updated version: 1.9.0

Notes:
--->
<cfcomponent 
	displayname="AbstractValidator"
	output="false"
	hint="A validator that validates data. This is abstract and must be extend by a concrete validator implementation.">

	<!---
	PROPERTIES
	--->
	<cfset variables.defaultFailtureMessage = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Validator" output="false"
		hint="Initializes the validator. Do not override.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC METHODS
	--->
	<cffunction name="validate" access="public" returntype="void" output="false"
		hint="Validates a value based on the current context.">
		<cfargument name="validationContext" type="MachII.validation.ValidationContext" required="true"
			hint="The current validation context." />
		<cfargument name="value" type="any" required="true"
			hint="The value to use for the validation." />
		<cfabort showerror="This method is abstract and must be overrided." />
	</cffunction>
	
	<!---
	PROTECTED METHODS
	--->
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setDefaultFailureMessage" access="public" returntype="void" output="false"
		hint="Sets the default failure message to use if an unspecified validation failure occurs.">
		<cfargument name="defaultFailureMessage">
		<cfset variables.defaultFailureMessage = arguments.defaultFailureMessage />
	</cffunction>
	<cffunction name="getDefaultFailureMessage" access="public" returntype="string" output="false"
		hint="Gets the default failure message.">
		<cfreturn variables.defaultFailureMessage />
	</cffunction>

</cfcomponent>