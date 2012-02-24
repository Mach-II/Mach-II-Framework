<cfsilent>
	<cfset variables.coldSpringWorks = false />
	<cfset variables.csProp = getProperty("coldSpringProperty")>
	<cfif IsStruct(variables.csProp)>
		<cfset variables.beanFactory = getProperty(variables.csProp.getParameter("beanFactoryPropertyName")) />
		<cfif IsStruct(variables.beanFactory) AND StructKeyExists(variables.beanFactory, "getBean" )>
			<cfset variables.coldSpringWorks = true />
		</cfif>
	</cfif>
</cfsilent>
<cfoutput>

<img src="img/machiiLogo.gif" width="229" height="60" alt="Mach-II" />
<h1>Skeleton Installation Success!</h1>
<p>You have successfully installed the Mach-II application skeleton.</p>

<hr />

<h3>ColdSpring Configuration Status</h3>
<cfif coldSpringWorks>
	<h4 class="success">Success</h4>
	<p>You have successfully configured Mach-II to use ColdSpring. Use 
		<code>getProperty("#csProp.getParameter('beanFactoryPropertyName')#")</code> to access the ColdSpring bean factory.
<cfelse>
	<h4 class="warn">Warning</h4>
	<p>ColdSpring is not installed or incorrectly configured. If you expected ColdSpring to work, check 
		your configuration. This Mach-II skeleton is compatible with <a href="http://coldspringframework.org/index.cfm?objectid=2DD544DF-E8F4-83AA-E2D7FED1F1B53FAE" target="_new">ColdSpring 1.2RC1</a> or
		higher. If you didn't install ColdSpring, maybe you should <a href="http://www.coldspringframework.org/" target="_new">download and install ColdSpring</a>.</p>
</cfif>

<hr />

<h3>Next Steps</h3>
<p>Just a few more thing to convert this skeleton to your application.</p>
<ul>
	<li>Open the Application.cfc file and change <code>this.name</code> to the name of your application.</li>
</ul>
<p>Start building your Mach-II application. The Mach-II configuration file is found at <code>/config/mach-ii.xml</code></p>
<ul>
	<li>Add and edit any event-handlers.
		<ul>
			<li>Note: The current defaultEvent property is <code>#getProperty("defaultEvent")#<code>.</li>
			<li>Note: The <code>#getProperty("defaultEvent")#</code> event-handler simply calls the <code>home</code> view. This view is found at <code>/views/home.cfm</code></li>
		</ul>
	</li>
	<li>Add any listeners.</li>
	<li>Add any event-filters.</li>
	<li>Add any plugins.</li>
</ul>

<hr />

<h3>Need Help?</h3>
<ul>
	<li>Check out the Mach-II Frequently Asked Questions (FAQs) at the 
		<a href="http://www.mach-ii.com" target="_blank">Mach-II website</a>.</li>
	<li>Join the <a href="http://groups-beta.google.com/group/mach-ii-for-coldfusion?hl=en">Mach-II 
		listserv</a> at Google Groups where you can ask questions and seek 
		advice from other Mach-II developers.</li>
</ul>
</cfoutput>