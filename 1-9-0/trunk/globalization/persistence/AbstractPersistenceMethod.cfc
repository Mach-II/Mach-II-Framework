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

Author: Mike Rogers (mike@mach-ii.com)
$Id$

Created version: 1.9.0

Notes:
An abstract class that represents a base class for persisting locale information.
If the user passes a URL parameter (default '_locale'), that changes their
locale; that change needs to be persisted through the rest of that user's
'session'.

--->
<cfcomponent
	displayname="AbstractPersistenceMethod"
	output="false"
	hint="Base class for various locale persistence methods.">
	
	<cfset variables.instance = StructNew()/>
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Override to provide custom configuration logic. Called after init().">
		<!--- Does nothing --->
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void" output="false"
		hint="Override to provide custom deconfiguration logic. Also called when target object is reloaded.">
		<!--- Does nothing --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="storeLocale" access="public" returntype="void" output="false"
		hint="The method to be overriden in order to store a new locale.">
		<cfargument name="locale" type="string" required="true" />
		<cfabort showerror="This method is abstract and must be overrided if storeLocale functionality is required." />
	</cffunction>
	
	<cffunction name="retrieveLocale" access="public" returntype="void" output="false"
		hint="The method to be overriden in order to retrieve the current locale.">
		<cfabort showerror="This method is abstract and must be overriden if retrieveLocale functionality is required." />
	</cffunction>
	
</cfcomponent>
