component  output="false"
{
	public BuilderUpdaterService function init(
		required numeric currentVersion,
		required string urlToCheck = "",
		string riaForgeProjectName = "",
		string lastDateChecked = "")
		hint="checks a specified URL for a newer version" output="false"
	{
		variables.currentVersion = arguments.currentVersion;
		variables.remoteVersion = 0;
		variables.riaForgeProjectName = arguments.riaForgeProjectName;
		variables.riaForgeDownloadURL = "";
		variables.urlToCheck = arguments.urlToCheck;
		variables.lastDateChecked = arguments.lastDateChecked;
		
		return this;
	}
	
	public string function setLastDateChecked(
		required date lastDateChecked) {
		variables.lastDateChecked = arguments.lastDateChecked;
	}
	
	public string function getLastDateChecked() {
		return variables.lastDateChecked;
	}
	
	public boolean function isNewVersionAvailable()
		hint="checks to see if there is a newer version of the extension available" output="false"
	{
		local.isRemoteVersionNewer = false;
		// strip the filename off the URL and check for ide_config.xml
		local.configLocation = getDirectoryFromPath(variables.urlToCheck) & "ide_config.xml";
		
		if ((not isDate(variables.lastDateChecked)) or (dateDiff("d",now(),variables.lastDateChecked) < 0)) {
			if (len(variables.riaForgeProjectName)) {
				local.isRemoteVersionNewer = checkRIAForge(variables.urlToCheck,variables.riaForgeProjectName);
			}
			else {
				local.isRemoteVersionNewer = checkURL(local.configLocation);
			}
		}
		
		return local.isRemoteVersionNewer;
	}
	
	public void function displayUpdateForm()
		hint="displays a form that asks the user if they would like to update" output="true"
	{
		include "updateForm.cfm";
	}
	
	public void function downloadUpdate()
		hint="if the user accepted the update download it" output="false"
	{
		if (len(variables.riaForgeProjectName)) {
			downloadFromRIAForge(variables.urlToCheck,variables.riaForgeProjectName);
		}
		else {
			downloadFromURL(variables.urlToCheck);
		}
	}
	
	public void function displayUpdateComplete()
		hint="displays a message saying the update is completed" output="true"
	{
		include "updateInstalled.cfm";
	}
	
	public void function completeUpdate()
		hint="does cleanup tasks when a new update has been installed" output="false"
	{
		if (directoryExists(expandPath("temp"))) {
			directoryDelete(expandPath("temp"),true);
		}
		if (directoryExists(expandPath("../__MACOSX"))) {
			directoryDelete(expandPath("../__MACOSX"),true);
		}
	}
	
	private boolean function checkURL(
		required string urlToCheck)
		hint="checks a specified URL for a newer version" output="false"
	{	
		local.isRemoteVersionNewer = false;
		local.httpService = new http();
		local.httpService.setMethod("get");
		local.httpService.setCharset("utf-8");
		local.httpService.setTimeout(10);
		local.httpService.setUrl(arguments.urlToCheck);

		local.result = local.httpService.send().getPrefix();
		local.result = xmlParse(local.result.fileContent);
		if (isNumeric(local.result.application.version.xmlText)) {
			variables.remoteVersion = local.result.application.version.xmlText;
		}
		
		if (variables.remoteVersion > variables.currentVersion) {
			local.isRemoteVersionNewer =  true;
		}
		
		return local.isRemoteVersionNewer;
	}
	
	private boolean function checkRIAForge(
		required string urlToCheck,
		required string riaForgeProjectName)
		hint="checks a for a newer version of this project at RIAForge" output="false"
	{
		local.isRemoteVersionNewer = false;
		local.httpService = new http();
		local.httpService.setMethod("get");
		local.httpService.setCharset("utf-8");
		local.httpService.setTimeout(10);
		local.httpService.setUrl(arguments.urlToCheck);

		local.result = local.httpService.send().getPrefix();
		local.result = xmlParse(local.result.fileContent);
		
		local.projectVersion = xmlSearch(local.result,"//project[starts-with(NAME,'#arguments.riaForgeProjectName#')]/VERSION");
		if (arrayLen(local.projectVersion) and isNumeric(local.projectVersion[1].xmlText)) {
			variables.remoteVersion = local.projectVersion[1].xmlText;
			// get the download url
			local.projectURL = xmlSearch(local.result,"//project[starts-with(NAME,'#arguments.riaForgeProjectName#')]/PROJECTURL");
			variables.riaForgeDownloadURL = local.projectURL[1].xmlText & "/index.cfm?event=action.download&doit=true";
		}
		
		if (variables.remoteVersion > variables.currentVersion) {
			local.isRemoteVersionNewer =  true;
		}
		
		return local.isRemoteVersionNewer;
	}
	
	private void function downloadFromURL(
		required string urlToCheck)
		hint="downloads the zip from specified URL" output="false"
	{
		// put into temp folder
		if (not directoryExists(expandPath('temp'))) {
			directoryCreate(expandPath("temp"));
		}
		local.httpService = new http();
		local.httpService.setMethod("get");
		local.httpService.setCharset("utf-8");
		local.httpService.setTimeout(10);
		local.httpService.setUrl(arguments.urlToCheck);
		local.httpService.setPath(expandPath("temp"));
		local.result = local.httpService.send().getPrefix();

		local.zipService = createObject("component","zipService").doUnzip(expandPath("temp/") & getFileFromPath(arguments.urlToCheck),expandPath("../"));
		
	}
	
	private void function downloadFromRIAForge()
		hint="downloads the zip from RIAForge" output="false"
	{
		// put into temp folder
		if (not directoryExists(expandPath('temp'))) {
			directoryCreate(expandPath("temp"));
		}
		local.httpService = new http();
		local.httpService.setMethod("get");
		local.httpService.setCharset("utf-8");
		local.httpService.setTimeout(10);
		local.httpService.setUrl(variables.riaForgeDownloadURL);
		local.httpService.setPath(expandPath("temp"));
		local.result = local.httpService.send().getPrefix();

		local.zipService = createObject("component","zipService").doUnzip(expandPath("temp/") & getFileFromPath(variables.riaForgeDownloadURL),expandPath("../"));
	}

}