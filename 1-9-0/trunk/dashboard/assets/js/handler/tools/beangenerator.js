/*
$Id: rooibos.js 4545 2006-10-04 20:30:05Z pfarrell $
Version: 2.2.0
This file is subject to license in index file.
*/
<!-- 
function executeRooibos() {
	var data = configure();
	return createBean(data);
} // END executeRooibos()

function executeExample() {
	var dataForm = document.configureForm;
	dataForm.beanName.value = "testBean";
	dataForm.beanPath.value = "com.maestropublishing.testBean";
	dataForm.cfcextends.value = "com.maestropublishing.beanBase";
	dataForm.propertyInfo.value = "color \nproduct_line string brightColor\namount numeric 0\ndate_created date #dateConvert('local2UTC',now())#";
	dataForm.callSuper.checked = "y";
	dataForm.addTrim.checked = "y";
	dataForm.comments.checked = "y";
	dataForm.setMemento.checked = "y";
	dataForm.getMemento.checked = "y";
	dataForm.setStepInstance.checked = "y";
	dataForm.validate.checked = "y";
	dataForm.validateInterior.checked = "y";
	dataForm.dump.checked = "y";
	dataForm.dateFormat.value = "YYYY/MM/DD";
	// dataForm.generateDao.checked = "y";
	// dataForm.daoDisplayName.value = "testDao";
	// dataForm.daoPath.value = "com.maestropublishing.testDao";
	// dataForm.daocfcextends.value = "com.maestropublishing.daoBase";
	// dataForm.daoCallSuper.checked = "y";
	return executeRooibos();
} // END executeExample()

function configure() {
	var data = new Object();
	var form = document.configureForm;
	data.beanName = trim(form.beanName.value);
	data.beanPath = trim(form.beanPath.value);
	data.cfcextends = trim(form.cfcextends.value);
	data.callSuper = form.callSuper.checked;
	data.properties = computeProperties(form.propertyInfo.value);
	data.addTrim = form.addTrim.checked;
	data.comments = form.comments.checked;
	data.setMemento = form.setMemento.checked;
	data.getMemento = form.getMemento.checked;
	data.setStepInstance = form.setStepInstance.checked;
	data.validate = form.validate.checked;
	data.validateInterior = form.validateInterior.checked;
	data.dump = form.dump.checked;
	data.dateFormat = trim(form.dateFormat.value);
	data.dateFormat = data.dateFormat.toUpperCase();
	// beanPath defaults to beanName
	if (data.beanPath.value=="") {
		data.beanPath = form.beanName.value;
		configureForm.beanPath.value = data.beanPath;
	} // END IF
	// data.generateDao = form.generateDao.checked;
	// data.daoDisplayName = trim(form.daoDisplayName.value);
	// data.daoPath = trim(form.daoPath.value);
	// data.daocfcextends = trim(form.daocfcextends.value);
	// data.daoCallSuper = form.daoCallSuper.checked;
	return data;
} // END configure()

// Util Functions
function computeProperties(propertyInfo) {
	var i = "";
	var j = "";
	var aPropertyInfo = explode(trim(propertyInfo),"\n");
	var properties = new Object();
	var aThisLine = "";
	var tempString = "";
	properties.aPropertyNames = new Array(1);
	properties.aPropertyTypes = new Array(1);
	properties.aPropertyDefaults = new Array(1);
	for (i=0; i < aPropertyInfo.length; i++) {
		aThisLine = explode(trim(aPropertyInfo[i])," ");
		properties.aPropertyNames[i] = trim(aThisLine[0]);
		properties.aPropertyTypes[i] = "string";
		properties.aPropertyDefaults[i] = "";
		// if specific type has been assigned
		if (aThisLine.length >= 2) {
			properties.aPropertyTypes[i] = trim(aThisLine[1]);
			// if the type is numeric, automatically set a default of 0 - overridden in the next if
			switch (properties.aPropertyTypes[i]) {
				case "string":
					properties.aPropertyDefaults[i] = "";
					break;
				case "boolean":
					properties.aPropertyDefaults[i] = "false";
					break;
				case "numeric":
					properties.aPropertyDefaults[i] = 0;
					break;
				case "struct":
					properties.aPropertyDefaults[i] = "#StructNew()#";
					break;
				case "array":
					properties.aPropertyDefaults[i] = "#ArrayNew(1)#";
					break;
				case "date":
					properties.aPropertyDefaults[i] = "#Now()#";
					break;
				case "query":
					properties.aPropertyDefaults[i] = "#QueryNew('')#";
					break;
				default:
					properties.aPropertyDefaults[i] = "";
					break;
			} // END SWITCH
		} // END IF
		// if specific default has been assigned
		if (aThisLine.length >= 3) {
			tempString = "";
			for (j=2; j < aThisLine.length; j++) {
				if (j == aThisLine.length -1) {
					tempString = tempString + trim(aThisLine[j]);
				} else {
					tempString = tempString + trim(aThisLine[j]) + " ";
				}
			} // END FOR
			properties.aPropertyDefaults[i] = trim(tempString);
		} // END IF
	} // END FOR
	return properties;
} // END computeProperties()

function capFirstLetter(strIn) {
	var cappedFirstLetter = strIn.substring(0,1).toUpperCase();
	var restOfStr = strIn.substring(1,strIn.length);
	return cappedFirstLetter + restOfStr;
} // END capFirstLeter()

function explode(item,delimiter) {
	var tempArray = new Array(1);
	var count = 0;
	var i = 0;
	var tempString = new String(item);
	var temp = "";
	while (tempString.indexOf(delimiter)>0) {
		tempArray[count]=tempString.substr(0,tempString.indexOf(delimiter));
		tempString=tempString.substr(tempString.indexOf(delimiter)+1,tempString.length-tempString.indexOf(delimiter)+1);
		count = count + 1;
	} // END WHILE
	tempArray[count] = tempString;
	return tempArray;
} // END explode()

function trim(value) {
   var temp = value;
   var obj = /^(\s*)([\W\w]*)(\b\s*$)/;
   if (obj.test(temp)) { temp = temp.replace(obj, '$2'); } // END IF
   var obj = /  /g;
   while (temp.match(obj)) { temp = temp.replace(obj, " "); } // END WHILE
   return temp;
} // END trim()

// Bean Functions
function createBean(data) {
	var results = "";
	// Start the component definition.
	results = results + '<cfcomponent\n	displayname="' + data.beanName + '"\n';
	// If bean extends another
	if (data.cfcextends!=="") {
		results = results + '	extends="' + data.cfcextends + '"\n';
	} // END IF
	results = results + '	output="false"\n';
	results = results + '	hint="A bean which models the ' + data.beanName + ' form.">\n\n';
	// Write Comments if defined
	results = results + writeComments(data);
	// Write properties
	results = results + writeProperties(data);
	// Write init
	results = results + writeBeanInit(data);
	// Write public comment if any public functions are being written
	results = results + writePublicComment(data);
	// Write setMemento if defined
	results = results + writeSetMemento(data);
	// Write getMemento if defined
	results = results + writeGetMemento(data);
	// Write setStepInstance if defined
	results = results + writeSetStepInstance(data);
	// Write validate if defined
	results = results + writeValidate(data);
	// Write gets/sets
	results = results + writeGetSetMethods(data);
	// Write dump if defined
	results = results + writeDump(data);
	// Write out the final closing cfcomponent tag.
	results = results + '\n</'+'cfcomponent>';
	return results;
} // END createBean()

function writeComments(data) {
	var results = "";
	var i = 0;
	if (data.comments==1) {
		// Add comments and log of how this bean was created.
		results = results + '<!--- This bean was generated by the Rooibos Generator with the following template:\n';
		results = results + 'Bean Name: ' + data.beanName + '\n';
		results = results + 'Path to Bean: ' + data.beanPath + '\n';
		results = results + 'Extends: ' + data.cfcextends + '\n';
		results = results + 'Call super.init(): ' + data.callSuper + '\n';
		results = results + 'Bean Template:\n';
		for (i=0; i < data.properties.aPropertyNames.length; i++) {
			results = results + '	' + data.properties.aPropertyNames[i] + ' ' + data.properties.aPropertyTypes[i] + ' ' + data.properties.aPropertyDefaults[i] + '\n';
		} // END FOR
		results = results + 'Create getMemento method: ' + data.getMemento + '\n';
		results = results + 'Create setMemento method: ' + data.setMemento + '\n';
		results = results + 'Create setStepInstance method: ' + data.setStepInstance + '\n';
		results = results + 'Create validate method: ' + data.validate + '\n';
		results = results + 'Create validate interior: ' + data.validateInterior + '\n';
		results = results + 'Date Format: ' + data.dateFormat + '\n';
		results = results + '--->\n';
	} // END IF
	return results;
} // END writeComments()

function writeProperties(data) {
	var results = "";
	// Write comment
	results = results + '	<!---\n';
	results = results + '	PROPERTIES\n';
	results = results + '	--->\n';
	results = results + '	<cfset variables.instance = StructNew() />\n';
	if (data.setStepInstance==1) {
		results = results + writeBeanFieldArr(data);
	} // END IF 
	return results;
} // END writeProperties

function writeBeanFieldArr(data) {
	var results = "";
	var i = "";
	results = results + '	<!--- Required for setStepInstance() --->\n';
	results = results + '	<cfset variables.beanFieldArr = ListToArray("';
	for (i=0; i < data.properties.aPropertyNames.length; i++) {
		results = results + data.properties.aPropertyNames[i];
		if (i!==(data.properties.aPropertyNames.length - 1)) {
			results = results + '|';
		} // END IF
	} // END FOR
	results = results + '", "|") />\n';
	return results;
} // END writeBeanFieldArr

function writeBeanInit(data) {
	var results = ""
	var type = "";
	var i = "";
	// Write comment
	results = results + '\n	<!---\n';
	results = results + '	INITIALIZATION / CONFIGURATION\n';
	results = results + '	--->\n';
	// Create the init function.
	results = results + '	<cffunction name="init" access="public" returntype="' + data.beanPath + '" output="false">\n';
	// Write out the arguments.
	for (i=0; i < data.properties.aPropertyNames.length; i++) {
		type = data.properties.aPropertyTypes[i];
		if (type == "date") {
			type = "string";
		} // END IF 
		results = results + '		<cfargument name="' + data.properties.aPropertyNames[i] + '" type="' + type + '" required="false" default="' + data.properties.aPropertyDefaults[i] + '" />\n';
	} // END FOR
	results = results + '\n';
	// If bean extends something and callSuper is checked
	if (data.cfcextends!=="" && data.callSuper==1) {
	// Make comment
	results = results + '		<!--- call super --->\n';
		results = results + '		<cfset super.init() />\n';
	} // END IF
	// Make comment
	results = results + '		<!--- run setters --->\n';
	// Call the setters.
	for (i=0; i < data.properties.aPropertyNames.length; i++) {
		results = results + '		<cfset set' + capFirstLetter(data.properties.aPropertyNames[i]) + '(arguments.' + data.properties.aPropertyNames[i] + ') />\n';
	} // END FOR
	results = results + '\n';
	results = results + '		<cfreturn this />\n';
	// Write the return statement.
	results = results + ' 	<'+'/cffunction>\n';
	return results;
} // END writeInit()

function writePublicComment(data) {
	var results = "";
	if (data.getMemento==1 || data.setMemento==11 || data.validate==1) {
		results = results + '\n	<!---\n';
		results = results + '	PUBLIC FUNCTIONS\n';
		results = results + '	--->';
	} // END IF
	return results;
}

function writeSetMemento(data) {
	var results = "" ;
	// Create the setMemento method if asked for
	if (data.setMemento==1){
		results = results + '\n	<cffunction name="setMemento" access="public" returntype="' + data.beanPath + '" output="false">\n';
		results = results + '		<cfargument name="memento" type="struct" required="yes"/>\n';
		results = results + '		<cfset variables.instance = arguments.memento />\n';
		results = results + '		<cfreturn this />\n';
		results = results + '	</'+'cffunction>\n';
	} // END IF
	return results;
} // END writeSetMemento()

function writeGetMemento(data) {
	var results = "" ;
	// Create the getMemento method if asked for
	if (data.getMemento==1){
		results = results + '	<cffunction name="getMemento" access="public"returntype="struct" output="false" >\n';
		results = results + '		<cfreturn variables.instance />\n';
		results = results + '	</'+'cffunction>\n';
	} // END IF
	return results;
} // END writeGetMemento

function writeSetStepInstance(data) {
	var results = "";
	if (data.setStepInstance==1) {
		results = results + '\n	<cffunction name="setStepInstance" access="public" output="false" returntype="void"\n';
		results = results + '		hint="Populates bean data. Useful to popluate the bean in steps.<br/>\n';
		results = results + '		Throws: rethrows any caught exceptions">\n';
		results = results + '		<cfargument name="data" type="struct" required="true" />\n'
		results = results + '		<cfset var i = "" />\n';
		results = results + '\n'
		results = results + '		<cftry>\n';
		results = results + '			<cfloop from="1" to="#arrayLen(variables.beanFieldArr)#" index="i">\n';
		results = results + '				<cfif StructKeyExists(arguments.data, variables.beanFieldArr[i])>\n';
		results = results + '					<cfinvoke method="set#variables.beanFieldArr[i]#">\n';
		results = results + '						<cfinvokeargument name="#variables.beanFieldArr[i]#" value="#arguments.data[variables.beanFieldArr[i]]#" /'+'>\n';
		results = results + '					</'+'cfinvoke>\n';
		results = results + '				</'+'cfif>\n';
		results = results + '			</'+'cfloop>\n';
		results = results + '			<cfcatch type="any">\n';
		results = results + '				<cfrethrow />\n';
		results = results + '			</'+'cfcatch>\n';
		results = results + '		</'+'cftry>\n';
		results = results + '	</'+'cffunction>\n';
	} // END IF
	return results;
} // END writeStepInstance

function writeValidate(data) {
	var results = "";
	// Create a validation method.
	if (data.validate==1) {
		results = results +'\n	<cffunction name="validate" access="public" returntype="errorHandler" output="false">\n';
		// writeValidateInterior
		results = results + writeValidateInterior(data);
		// Close out validate method
		results = results + '	</'+'cffunction>\n';
	} // END IF
	return results;
} // END writeValidate()

function writeValidateInterior(data) {
	var results = "";
	var i = "";
	if (data.validateInterior==1) {
		results = results + '		<cfargument name="eH" required="true" type="errorHandler" />\n'
		results = results + '		<cfscript>\n';
		for (i=0; i < data.properties.aPropertyNames.length; i++) {
			results = results + '			// ' + data.properties.aPropertyNames[i] + '\n';
			results = results + '			if (get' + capFirstLetter(data.properties.aPropertyNames[i]) + '()) {\n';
			results = results + '				arguments.eH.setError("' + data.properties.aPropertyNames[i] + '", "' + data.beanName + '.' + data.properties.aPropertyNames[i] + '.");\n';
			results = results + '			} // END IF\n';
		} // END FOR
		// return errorHandler
		results = results + '			return arguments.eH;\n';
		results = results + '		</'+'cfscript>\n';
	} // END IF
	return results;
} // END writeValidateInterior

function writeGetSetMethods(data) {
	var results = "";
	var i = "";
	var type = "";
	// Add ACCESORS comment
	results = results + '\n	<!---\n';
	results = results + '	ACCESSORS\n';
	results = results + '	--->';
	// This will create the get and set methods for this property.
	for (i=0; i < data.properties.aPropertyNames.length; i++) {
		type = data.properties.aPropertyTypes[i];
		if (type == "date") {
			type = "string";
		} // END IF 
		// Write setter
		results = results + '\n	<cffunction name="set' + capFirstLetter(data.properties.aPropertyNames[i]) + '" access="public" returntype="void" output="false">\n';
		results = results + '		<cfargument name="' + data.properties.aPropertyNames[i] + '" type="' + type + '" required="true" />\n';
		if (data.properties.aPropertyTypes[i] == 'date' && data.dateFormat.length) {
			results = results + '		<cfif isDate(arguments.' + data.properties.aPropertyNames[i] + ')>\n';
			results = results + '			<cfset arguments.' + data.properties.aPropertyNames[i] + ' = dateformat(arguments.' + data.properties.aPropertyNames[i] + ',"' + data.dateFormat + '") />\n';
			results = results + '		</'+'cfif>\n';
		} // END IF
		if (data.addTrim==1 && data.properties.aPropertyTypes[i] == 'string' || data.properties.aPropertyTypes[i] == 'numeric' || data.properties.aPropertyTypes[i] == 'date') {
			results = results + '		<cfset variables.instance.' + data.properties.aPropertyNames[i] + ' = trim(arguments.' + data.properties.aPropertyNames[i] + ') />\n';
		} else {
			results = results + '		<cfset variables.instance.' + data.properties.aPropertyNames[i] + ' = arguments.' + data.properties.aPropertyNames[i] + ' />\n';
		} // END ELSE
		results = results + '	</'+'cffunction>\n';
		// Write getter
		results = results + '	<cffunction name="get' + capFirstLetter(data.properties.aPropertyNames[i]) + '" access="public" returntype="' + type + '" output="false">\n';
		results = results + '		<cfreturn variables.instance.' + data.properties.aPropertyNames[i] + ' />\n';
		results = results + '	</'+'cffunction>\n';
	} // END FOR
	return results;
} // END writeGetMethods()

function writeDump(data) {
	var results = "";
	if (data.dump==1) {
		results = results +'\n	<!---\n';
		results = results + '	DUMP\n';
		results = results + '	--->\n';
		results = results + '	<cffunction name="dump" access="public" output="true" return="void">\n';
		results = results + '	<cfargument name="abort" type="boolean" default="FALSE" />\n';
		results = results + '		<cfdump var="#variables.instance#" />\n';
		results = results + '		<cfif arguments.abort>\n';
		results = results + '			<cfabort />\n';
		results = results + '		</'+'cfif>\n';
		results = results + '	</'+'cffunction>';
	} // END IF
	return results;
} // END writeDumo()

function createDAO(data) {
	var results = "";
	var i = "";
	if (data.generateDAO==1) {
		
	} // END IF
	return results;
} // END createDAO()

function getQueryParam(type) {
	var result = "";
	return result;
} // END getQueryParam()

// XHTML Functions
function clearText(field) {
	if (field.defaultValue==field.value) {
		field.value = "";
	} else {
		field.value = field.defaultValue
	} // END ELSE
} // END clearText()
// -->