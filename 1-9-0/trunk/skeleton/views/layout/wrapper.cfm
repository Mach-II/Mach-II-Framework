<cfsilent>
	<cfimport prefix="view" taglib="/MachII/customtags/view" />

</cfsilent>
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Home | Mach-II Skeleton</title>

	<view:style >
		html {
			background-color: ##D0D0D0;
			width:600px;
			margin: 0 auto 0 auto;
			padding: 0;
			font: 0.75em/1.5em Arial, Helvetica, sans-serif; /* the font size in EM */
		}
		body {
			margin:0;
			padding: 1em;
			background-color: ##FFF;
		}
		hr {
			padding: 0;
			border: 0;
			color: ##D0D0D0;
			background-color: ##D0D0D0;
			height: 1px;
		}
		.success { color:##33FF00; }
		.warn { color:##FF0000; }
	</view:style>
</head>

<body>
	#event.getArg("layout.content")#
</body>
</html>
</cfoutput>
