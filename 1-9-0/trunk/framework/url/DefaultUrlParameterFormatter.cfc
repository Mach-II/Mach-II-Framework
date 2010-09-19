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
Updated version: 1.9.0

Notes:
--->
<cfcomponent 
	displayname="DefaultUrlParameterFormatter"
	extends="AbstractUrlParameterFormatter"
	output="false"
	hint="An URL route parameter formatter. This is abstract and must be extended by a concrete formatter implementation.">
	
	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="DefaultUrlParameterFormatter" output="false"
		hint="Initializes the formatter.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="format" access="public" returntype="string" output="false"
		hint="Formats an URL parameter to the desired specification.">
		<cfargument name="urlParameterValue" type="string" required="true"
			hint="The value of the parameter to format." />
		<cfargument name="urlParameterName" type="string" required="true"
			hint="The name of the parameter to format." />
		<cfargument name="urlParameters" type="struct" required="true"
			hint="All the incoming url parameters." />

		<cfset var result = arguments.urlParameterValue />

		<cfset result = REReplaceNoCase(result, "[[:punct:]]", "", "all") />
		<cfset result = ReplaceNoCase(result, " ", "-", "all") />
		<cfset result = ReplaceNoCase(result, "--", "-", "all") />
		
		<cfset result = ReplaceList(result, "À,Á,Â,Ã,Ä,Æ,Ç,È,É,Ê,Ë,Ì,Í,Î,Ï,Ð,Ñ,Ò,Ó,Ô,Õ,Ö,Ø,Ù,Ú,Û,Ü,Ý,Þ,ß,à,á,â,ã,ä,å,æ,c,è,é,ê,ë,ì,í,î,ï,ð,ñ,ò,ó,ô,õ,ö,ø,ù,ú,û,ü,ý,þ,ÿ", "A,A,A,A,A,AE,C,E,E,E,E,I,I,I,I,D,N,O,O,O,O,O,O,U,U,U,U,Y,P,B,a,a,a,a,a,a,ae,c,e,e,e,e,i,i,i,i,o,n,o,o,o,o,o,o,u,u,u,u,y,p,y") />		

		<cfreturn result />
	</cffunction>

</cfcomponent>