<!---
License:
Copyright 2009-2010 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
$Id$

Created version: 1.0.0
Updated version: 1.0.0

Notes:
--->
<cfcomponent
	displayname="Udfs"
	extends="MachII.framework.Property"
	output="false"
	hint="Provides Udfs for Dashboard.">

	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="configure" access="public" returntype="void" output="false"
		hint="Initializes the property.">
		<!--- Does nothing --->
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="findPropertyByType" access="public" returntype="any" output="false"
		hint="Finds the first property of the passed type is available in the PropertyManager.">
		<cfargument name="type" type="string" required="true"
			hint="The CFC type (dot path) to find." />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true"
			hint="The PropertyManager to search in." />

		<cfset var configurablePropertyNames = arguments.propertyManager.getConfigurablePropertyNames() />
		<cfset var property = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#ArrayLen(configurablePropertyNames)#" index="i">
			<cfset property = arguments.propertyManager.getProperty(configurablePropertyNames[i]) />
			<cfif getMetadata(property).name EQ arguments.type>
				<cfreturn property />
			</cfif>
		</cfloop>

		<cfreturn "" />
	</cffunction>

	<cffunction name="findAllPropertiesByType" access="public" returntype="struct" output="false"
		hint="Finds the all property of the passed type is available in the PropertyManager.">
		<cfargument name="type" type="string" required="true"
			hint="The CFC type (dot path) to find." />
		<cfargument name="propertyManager" type="MachII.framework.PropertyManager" required="true"
			hint="The PropertyManager to search in." />

		<cfset var properties = arguments.propertyManager.getProperties() />
		<cfset var key = 0 />
		<cfset var md = "" />
		<cfset var results = StructNew() />

		<cfloop collection="#properties#" item="key">
			<cfif IsObject(properties[key])>
				<cfif getMetadata(properties[key]).name EQ arguments.type>
					<cfset results[key] = properties[key] />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn results />
	</cffunction>

	<cffunction name="getCFCDocUrl" access="public" returntype="string" output="false">
		<cfargument name="typeName" type="string" required="true" />

		<cfset var version = ReplaceNoCase(Left(getPropertyManager().getVersion(), 5), ".", "-", "ALL") />
		<cfset var component = ListLast(arguments.typeName, ".") />
		<cfset var package = Left(arguments.typeName, Len(arguments.typeName) - Len(component) -1) />

		<cfreturn getProperty("cfcDocBaseUrl") & version & "/" & package & "/" & component & ".html" />
	</cffunction>

	<cffunction name="getMemoryData" access="public" returntype="struct" output="false"
		hint="Get memory information from the JVM.">

		<cfset var jvm = StructNew() />
		<cfset var runtime = CreateObject("java", "java.lang.Runtime") />

		<!---
		mgmtFactory = createobject("java", "java.lang.management.ManagementFactory");
		pools = mgmtFactory.getMemoryPoolMXBeans();
		heap = mgmtFactory.getMemoryMXBean();
		--->

		<cfset jvm["JVM - Used Memory"] = runtime.getRuntime().totalMemory() - runtime.getRuntime().freeMemory() />
		<cfset jvm["JVM - Max Memory"] = runtime.getRuntime().maxMemory() />
		<cfset jvm["JVM - Free Memory"] = runtime.getRuntime().freeMemory() />
		<cfset jvm["JVM - Total Memory"] = runtime.getRuntime().totalMemory() />
		<cfset jvm["JVM - Unallocated Memory"] = runtime.getRuntime().maxMemory() - runtime.getRuntime().totalMemory() />

		<!---
		jvm["Heap Memory Usage - Max"] = formatMB(heap.getHeapMemoryUsage().getMax());
		jvm["Heap Memory Usage - Used"] = formatMB(heap.getHeapMemoryUsage().getUsed());
		jvm["Heap Memory Usage - Committed"] = formatMB(heap.getHeapMemoryUsage().getCommitted());
		jvm["Heap Memory Usage - Initial"] = formatMB(heap.getHeapMemoryUsage().getInit());
		jvm["Non-Heap Memory Usage - Max"] = formatMB(heap.getNonHeapMemoryUsage().getMax());
		jvm["Non-Heap Memory Usage - Used"] = formatMB(heap.getNonHeapMemoryUsage().getUsed());
		jvm["Non-Heap Memory Usage - Committed"] = formatMB(heap.getNonHeapMemoryUsage().getCommitted());
		jvm["Non-Heap Memory Usage - Initial"] = formatMB(heap.getNonHeapMemoryUsage().getInit());
		for( i=1; i lte arrayLen(pools); i=i+1 ) jvm["Memory Pool - #pools[i].getName()# - Used"] = formatMB(pools[i].getUsage().getUsed());
		--->

		<cfreturn jvm />
	</cffunction>

	<cffunction name="getMachIIVersionString" access="public" returntype="string" output="false"
		hint="Gets a nice version number istead of just numbers.">

		<cfset var version = getAppManager().getPropertyManager().getVersion() />
		<cfset var release = "" />

		<cfswitch expression="#ListLast(version, ".")#">
			<cfcase value="0">
				<cfset release = "BER - Unknown build" />
			</cfcase>
			<cfcase value="1">
				<cfset release = "Alpha" />
			</cfcase>
			<cfcase value="2">
				<cfset release = "Beta" />
			</cfcase>
			<cfcase value="3">
				<cfset release = "RC1" />
			</cfcase>
			<cfcase value="4">
				<cfset release = "RC2" />
			</cfcase>
			<cfcase value="5">
				<cfset release = "RC3" />
			</cfcase>
			<cfcase value="6">
				<cfset release = "RC4" />
			</cfcase>
			<cfcase value="7">
				<cfset release = "RC5" />
			</cfcase>
			<cfcase value="8">
				<cfset release = "Production Stable" />
			</cfcase>
			<cfcase value="9">
				<cfset release = "Production-Only Stable (duck-typed)" />
			</cfcase>
			<cfdefaultcase>
				<cfset release = "BER - Build " & ListLast(version, ".") />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn Left(version, Len(version) - Len(ListLast(version, ".")) - 1) & " " & release />
	</cffunction>

	<cffunction name="getVersionNumber" access="public" returntype="string" output="false"
		hint="Gets the current version of the dashboard.">

		<cfset var minorVersion = getProperty("minorVersion") />

		<!--- Set to 0 if placeholder which means this is a BER --->
		<cfif NOT IsNumeric(minorVersion)>
			<cfset minorVersion = 0 />
		</cfif>

		<cfreturn getProperty("majorVersion") & "." & minorVersion />
	</cffunction>

	<cffunction name="getVersionString" access="public" returntype="string" output="false"
		hint="Gets a nice version number istead of just numbers.">

		<cfset var version = getVersionNumber() />
		<cfset var release = "" />

		<cfswitch expression="#ListLast(version, ".")#">
			<cfcase value="0">
				<cfset release = "BER - Unknown build" />
			</cfcase>
			<cfcase value="1">
				<cfset release = "Alpha" />
			</cfcase>
			<cfcase value="2">
				<cfset release = "Beta1" />
			</cfcase>
			<cfcase value="3">
				<cfset release = "Beta2" />
			</cfcase>
			<cfcase value="4">
				<cfset release = "RC1" />
			</cfcase>
			<cfcase value="5">
				<cfset release = "RC2" />
			</cfcase>
			<cfcase value="6">
				<cfset release = "RC3" />
			</cfcase>
			<cfcase value="8">
				<cfset release = "Production Stable" />
			</cfcase>
			<cfdefaultcase>
				<cfset release = "BER - Build " & ListLast(version, ".") />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn Left(version, Len(version) - Len(ListLast(version, ".")) - 1) & " " & release />
	</cffunction>

	<cffunction name="datetimeDifferenceString" access="public" returntype="string" output="false"
		hint="Converts the different between to dates into time string.">
		<cfargument name="date1" type="date" required="true" />
		<cfargument name="date2" type="date" required="false" default="#Now()#" />

		<cfset var date1Epoch = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), arguments.date1) />
		<cfset var date2Epoch = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), arguments.date2) />
		<cfset var diff = date2Epoch - date1Epoch />

		<cfreturn convertSecondsToDiffString(diff) />
	</cffunction>

	<cffunction name="convertSecondsToDiffString" access="public" returntype="string" output="false"
		hint="Converts seconds to human reable diff string.">
		<cfargument name="inputSeconds" type="numeric" required="true"
			hint="Total seconds to convert." />

		<cfset var days = Fix(arguments.inputSeconds / 86400) />
		<cfset var hours = Fix(arguments.inputSeconds / 3600) />
		<cfset var minutes = Fix((arguments.inputSeconds / 60) MOD 60) />
		<cfset var seconds = Fix(arguments.inputSeconds MOD 60) />
		<cfset var tempstr = "" />
		<cfset var text = "" />

		<cfif days GTE 1>
			<cfif days GTE 2>
				<cfset tempstr = " days" />
			<cfelse>
				<cfset tempstr = " day" />
			</cfif>
			<cfset text = text & days & tempstr />
		<cfelseif hours GTE 1>
			<cfif hours GTE 2>
				<cfset tempstr = " hours" />
			<cfelse>
				<cfset tempstr = " hour" />
			</cfif>
			<cfset text = text & hours & tempstr />
		<cfelseif minutes GTE 1>
			<cfif minutes GTE 2>
				<cfset tempstr = " minutes" />
			<cfelse>
				<cfset tempstr = " minute">
			</cfif>
			<cfset text = text & minutes & tempstr />
		<cfelseif seconds GTE 1>
			<cfif seconds GTE 1>
				<cfset tempstr = " seconds" />
			<cfelse>
				<cfset tempstr = " second" />
			</cfif>
			<cfset text = text & seconds & tempstr />
		<cfelse>
			<cfset text = "0 seconds" />
		</cfif>

		<cfreturn text />
	</cffunction>

	<!---
		/**
		* Pass in a value in bytes, and this function converts it to a human-readable format of bytes, KB, MB, or GB.
		* Updated from Nat Papovich's version.
		* 01/2002 - Optional Units added by Sierra Bufe (sierra@brighterfusion.com)
		*
		* @param size    Size to convert.
		* @param unit    Unit to return results in. Valid options are bytes,KB,MB,GB.
		* @return Returns a string.
		* @author Paul Mone (sierra@brighterfusion.compaul@ninthlink.com)
		* @version 2.1, January 7, 2002
		*/
	--->
	<cffunction name="byteConvert" access="public" returntype="string" output="false">
		<cfargument name="num" type="numeric" required="true" />
		<cfargument name="unit" type="string" required="false" default="" />
		<cfargument name="addUnitString" type="boolean" required="false" default="true" />

		<cfscript>
		   var result = 0;
		   // Set unit variables for convenience
		   var bytes = 1;
		   var kb = 1024;
		   var mb = 1048576;
		   var gb = 1073741824;
		   // Check for non-numeric or negative num argument
		   if (not isNumeric(num) OR num LT 0)
		      return "Invalid size argument";
		   // Check to see if unit was passed in, and if it is valid
		   if ((ArrayLen(Arguments) GT 1)
		      AND ("bytes,KB,MB,GB" contains Arguments[2]))
		   {
		      unit = Arguments[2];
		   // If not, set unit depending on the size of num
		   } else {
		       if    (num lt kb) {   unit ="bytes";
		      } else if (num lt mb) {   unit ="KB";
		      } else if (num lt gb) {   unit ="MB";
		      } else            {   unit ="GB";
		      }
		   }
		   // Find the result by dividing num by the number represented by the unit
		   result = num / Evaluate(unit);
		   // Format the result
		   result = decimalRound(result, 1);
		   // Concatenate result and unit together for the return value
		   if (addUnitString) {
			   return (result & " " & unit);
		   } else {
		   	   return result;
		   }
		</cfscript>
	</cffunction>

	<cffunction name="formatMB" access="public" returntype="string" output="false"
		hint="Formats total bytes into MB.">
		<cfargument name="number" type="numeric" required="true" />
		<cfreturn byteConvert(arguments.number, "MB") />
	</cffunction>

	<cffunction name="getPercentage" access="public" returntype="numeric" output="false"
		hint="Returns a percentage based on the numbers passed.">
		<cfargument name="numerator" type="numeric" required="true"
			hint="Top number of a fraction. Value." />
		<cfargument  name="denominator" type="numeric" required="true"
			hint="Bottom number of a fraction. Maximum." />
		<cfargument name="numberOfDecimalPlaces" type="string" default=""
			hint="Number of decimal places to round to. Defaults to no rounding." />

		<cfset var result = 0 />

		<cfif arguments.denominator NEQ 0>
			<cfset result = (arguments.numerator / arguments.denominator) * 100 />
			<cfif IsTrueNumeric(arguments.numberOfDecimalPlaces) AND arguments.numberOfDecimalPlaces GTE 0>
				<cfset result = decimalRound(result, arguments.numberOfDecimalPlaces) />
			</cfif>
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="decimalRound" access="public" returntype="string" output="false"
		hint="Round mode can be up, down or even. Even is the default.">
		<cfargument name="numberToRound" type="numeric" required="true" />
		<cfargument name="numberOfPlaces" type="numeric" required="true" />
		<cfargument name="mode" type="string" required="false" default="even" />

		<cfset var bd = CreateObject("java", "java.math.BigDecimal") />
		<cfset var result = 0 />

		<cfif arguments.numberToRound NEQ 0>
			<cfset bd.init(arguments.numberToRound.toString()) />

			<cfif arguments.mode IS "up">
				<cfset result = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_UP).toString() />
			<cfelseif arguments.mode IS "down">
				<cfset result = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_DOWN).toString() />
			<cfelse>
				<cfset result = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_EVEN).toString() />
			</cfif>

			<cfif result EQ 0>
				<cfset result = 0 />
			</cfif>
		</cfif>

		<cfreturn  result />
	</cffunction>

	<cffunction name="isTrueNumeric" access="public" returntype="boolean" output="false"
		hint="Returns true if all characters in a string are numeric.">
		<cfargument name="value" type="string" required="true" />
		<cfreturn Len(arguments.value) AND REFind("[^0-9]", arguments.value) IS 0 />
	</cffunction>

	<cffunction name="isIPInRange" access="public" returntype="boolean" output="false"
		hint="Helper function to determine if the IP in question is in the range provided.">
		<cfargument name="ip" type="string" required="true" />
		<cfargument name="ipRange" type="string" required="true" />

		<cfset var inRange = true />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var temp = '' />

		<!--- Convert values to arrays - for speed --->
		<cfset arguments.ip = ListToArray(arguments.ip, ".") />
		<cfset arguments.ipRange = ListToArray(arguments.ipRange, ".") />

		<!--- Determine if the IPs have a length of 4 --->
		<cfif NOT (ArrayLen(arguments.ip) eq 4 AND ArrayLen(arguments.ipRange) eq 4)>
			<cfreturn false />
		</cfif>

		<!--- Loop through ip numbers --->
		<cfloop from="1" to="4" index="i">
			<cfset temp = ListToArray(arguments.ipRange[i], ",[]") />
			<cfset inRange = false /><!--- guilty until proven innocent --->

			<cfloop from="1" to="#ArrayLen(temp)#" index="j">
				<!--- Determine if this is a range, or a simple value --->
				<cfif (ListLen(temp[j], "-") eq 2 AND arguments.ip[i] gte ListFirst(temp[j], "-") AND arguments.ip[i] lte ListLast(temp[j], "-"))
				OR (IsNumeric(temp[j]) AND arguments.ip[i] eq temp[j])>
		 			<cfset inRange = true />
					<cfbreak />
				</cfif>
			</cfloop>

			<!--- Check if still false - meaning couldn't find the specified ip value --->
			<cfif NOT inRange>
				<cfreturn false />
			</cfif>
		</cfloop>

		<cfreturn inRange />
	</cffunction>

</cfcomponent>