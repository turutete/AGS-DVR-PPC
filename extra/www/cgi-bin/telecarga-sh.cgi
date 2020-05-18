#!/bin/bash

#Cabecera http:
echo -e "Content-Type: text/html\n"
echo -e "\n"

#Cabecera xml: XXX
#echo "<!doctype HTML public \"-//W30//DTD W3 HTML 3.0//EN\">"
#echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"

echo "<html><head>"
echo "	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">"
echo "	<title>Remote Control</title>"
echo "</head>"

#echo "<body bgcolor=\"#042045\" link=\"#3030FF\" alink=\"#FF3030\" vlink=\"#FF30FF\" text=\"#FFFFFF\">"
echo "<body bgcolor=\"#003366\" link=\"#00D2FF\" alink=\"#00D2FF\" vlink=\"#00D2FF\" text=\"#FFFFFF\">"
echo "	<div align=\"center\">"
#echo "	<br>"
echo "	<img src=\"/images/cabecera_zigor.jpg\">"
echo "	<br>"
echo "	<p><h2>Version Upgrade</h2></p>"
echo "	<br><br>"

echo "  <table border=\"3\" cellpadding=\"10\" cellspacing=\"2\" bgcolor=\"#808080\" bordercolor=\"#00D2FF\">"
echo "  <tr>"
echo "  <td>CURRENT VERSION</td>"
echo "  <td>LAST VERSION</td>"
echo "  </tr>"

if [ -f "/usr/local/zigor/activa/version.txt" ]
#if [ -f "/root/gestor-integral/www/version.txt" ]
then
   VERSION_ACTIVA=`cat /usr/local/zigor/activa/version.txt`
#   VERSION_ACTIVA="`cat /root/gestor-integral/www/version.txt`"
else
   VERSION_ACTIVA="Not available"
fi
if [ -f "/usr/local/zigor/reserva/version.txt" ]
then
   VERSION_RESERVA="`cat /usr/local/zigor/reserva/version.txt`"
else
   VERSION_RESERVA="Not available"
fi

echo "  <tr>"
echo "  <td>${VERSION_ACTIVA}</td>"
echo "  <td>${VERSION_RESERVA}</td>"
echo "  </tr>"
echo "  </table>"

echo "  <br><br><br>"
echo "  Select file for upgrade:"
echo "	<form method=\"post\" action=\"/cgi-bin/telecarga.cgi\" enctype=\"multipart/form-data\">"
echo "	<input type=\"file\" name=\"fichero_telecarga\">"
echo "	<br>"
echo "	<input type=\"submit\" value=\"Upload\">"
echo "	</form>"
#echo "  <br>"
echo "  <h4><a href="/cgi-bin/cambia_version-sh.cgi" target="ppal">Version Exchange</h4>"
echo "	</div>"
echo "</body></html>"
exit 0   #XXX
