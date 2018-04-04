require "functions"

function index_restart()
end

local this  = {
   file     = "/usr/local/zigor/activa/www/html/index.html",
   get      = tmpl_get,
   save     = tmpl_save,   
--  restart  = tmpl_service_restart,
  restart  = index_restart,
--   _service = "snmpd",
   tmpl     = [[
<!-- NO EDITAR ESTE FICHERO. Created by AGS. -->
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Remote Control</title>
</head>

<style type="text/css">
body {
  background-image: url("/images/tile.png");
  background-color: #A0A0A0;
  background-repeat: repeat-x;
}
.rounded-borders {
  border-radius: 10px;
  -ms-border-radius: 10px;
  -moz-border-radius: 10px;
  -webkit-border-radius: 10px;
  -khtml-border-radius: 10px;
}

.title {
  color: #ffffff;
  font-family: Arial;
  font-size: 40px;
  font-weight: bold;
  text-shadow: 3px 3px 3px #000000;
  text-align: center;
  padding: 20px 0px 10px 0px;
}
</style>

<body>
	<div class="title">AVC SET DVR</div>
	<table class="rounded-borders" border="8" bordercolor="#202020" cellspacing="0" align="center"><tr><td>
	<APPLET CODE="com.glavsoft.viewer.Viewer" ARCHIVE="tightvnc-jviewer.jar" WIDTH=643 HEIGHT=483>
		<param name="Port" value="$$zigorNetPortVnc.0">
		<param name="OpenNewWindow" value="no">
		<param name="ShowControls" value="no">

		<param name="Encoding" value="Tight">
		<param name="CompressionLevel" value="3">
        <!--param name="JpegImageQuality" value=""/-->

		<!--param name="LocalPointer" value="On"-->
		<!--param name="ScalingFactor" value="100"-->
	</APPLET>
	</td></tr></table>

	<table cellspacing="10" width="640" align="center"><tr>
	<td><img border=0 src="/images/logo_zigor.png"></td>
	<td>
	 <div style="font-size:10px; color:#FFFFFF; font-family: Verdana, Arial, Helvetica, sans-serif; text-align:right; line-height:150%;">
	    ZIGOR CORPORACIÓN S.A.<br>
	    E-mail: zigor@zigor.com<br>
	    Web: www.zigor.com<br>
	 </div>
	</td>
	</tr></table>
</body>
</html>

]]

}

return this
