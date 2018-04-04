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
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>AVC SET DVR</title>
	<link rel="stylesheet" href="main.css">	
</head>

<body>
	<div class="container header">
		<p class="title-text">AVC SET DVR</p>
	</div>

	<div class="applet">
	<APPLET CODE="com.glavsoft.viewer.Viewer" ARCHIVE="tightvnc-jviewer.jar" WIDTH=1027 HEIGHT=603>
		<param name="Port" value="$$zigorNetPortVnc.0">
		<param name="OpenNewWindow" value="no">
		<param name="ShowControls" value="no">

		<param name="Encoding" value="Tight">
		<param name="CompressionLevel" value="3">
		<!--param name="JpegImageQuality" value=""/-->

		<!--param name="LocalPointer" value="On"-->
		<!--param name="ScalingFactor" value="100"-->
	</APPLET>
	</div>

	<div class="container footer">
	  <div class="footer-cols">
	    <img src="images/logo_zigor.png">
	  </div>
	  <div class="footer-cols">
	    <a href="downloads.html"><img class="center" src="images/down48.png"></a>
	  </div>
	  <div class="footer-cols">
	    <p class="footer-text">ZIGOR CORPORACIÓN S.A.</p>
	    <p class="footer-text">E-mail: zigor@zigor.com</p>
	    <p class="footer-text">Web: www.zigor.com</p>
	  </div>
	</div>
</body>
</html>

]]

}

return this
