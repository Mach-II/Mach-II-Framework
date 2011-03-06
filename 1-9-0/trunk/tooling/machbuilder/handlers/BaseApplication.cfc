import BuilderUpdaterService;

component  output="false"
{
	public boolean function onApplicationStart() output="false"
	{
		// read the settings
		local.iniPath = ExpandPath("settings.ini");
		local.currentVersion = trim(GetProfileString(local.iniPath,"main","version"));
		local.urlToCheck = trim(GetProfileString(local.iniPath,"main","urlToCheck"));
		local.riaForgeProjectName = trim(GetProfileString(local.iniPath,"main","riaForgeProjectName"));
		local.lastDateChecked = trim(GetProfileString(local.iniPath,"main","lastDateChecked"));
		
		local.currentVersion = checkIDEConfig(local.iniPath);
		
		application.builderUpdaterService = new BuilderUpdaterService(local.currentVersion,local.urlToCheck,local.riaForgeProjectName,local.lastDateChecked); 
		
		SetProfileString(local.iniPath,"main","lastDateChecked",application.builderUpdaterService.getLastDateChecked());

		return true;
	}
	
	public void function onRequest(
		required string targetPage) output="true"
	{
		if (structKeyExists(url,"reload")) {
			onApplicationStart();
		}
		
		if (isDefined("data.event.user.input.xmlAttributes.value") && data.event.user.input.xmlAttributes.value eq "No") {
			url.downloadUpdate = false;
		}
		
		local.data = xmlParse(ideeventinfo);
		if (isDefined("local.data.event.user.input.xmlAttributes.value") && local.data.event.user.input.xmlAttributes.value eq "Yes") {
			// do the download and install
			application.builderUpdaterService.downloadUpdate();
			
			// run the cleanup
			application.builderUpdaterService.completeUpdate();
			// display the complete form.
			application.builderUpdaterService.setLastDateChecked(now());
			local.iniPath = ExpandPath("settings.ini");
			SetProfileString(local.iniPath,"main","lastDateChecked",application.builderUpdaterService.getLastDateChecked());
			checkIDEConfig(local.iniPath); // reset the version in the config
			application.builderUpdaterService.displayUpdateComplete();
		}
		else if (isDefined("data.event.user.input.xmlAttributes.value") && data.event.user.input.xmlAttributes.value eq "No") {
			application.builderUpdaterService.setLastDateChecked(now());
			local.iniPath = ExpandPath("settings.ini");
			SetProfileString(local.iniPath,"main","lastDateChecked",application.builderUpdaterService.getLastDateChecked());
			// proceed with the extension as normal
		}
		// if we've never checked or if x time has passed, check for a new version
		else if (application.builderUpdaterService.isNewVersionAvailable()) {
			application.builderUpdaterService.displayUpdateForm();
		}
	}
	
	private numeric function checkIDEConfig(
		required string iniPath) {
		// read in the settings from the xml config
		local.ide_config = fileRead(expandPath("../ide_config.xml"));
		local.ide_config = xmlParse(local.ide_config);
		
		if (isNumeric(local.ide_config.application.version.xmlText)) {
			local.currentVersion = local.ide_config.application.version.xmlText;
			SetProfileString(arguments.iniPath,"main","version",local.currentVersion);
		}
		
		return local.currentVersion;
	}
}