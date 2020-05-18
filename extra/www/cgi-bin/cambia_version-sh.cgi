#!/bin/bash
#XXX Edited by jurrutia:

#Script encargado de activar la aplicacion de reserva.

echo -e "Content-Type: text/html\n\n"
echo "<!doctype HTML public \"-//W30//DTD W3 HTML 3.0//EN\">"
echo "<html><head>"
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">"
echo "<title>Remote Control</title>"
echo "</head>"

echo "<body bgcolor=\"#003366\" link=\"#00D2FF\" alink=\"#00D2FF\" vlink=\"#00D2FF\" text=\"#FFFFFF\">"

echo "<div align=\"center\"><br>"
echo "<img src=\"/images/cabecera_zigor.jpg\" alt=\"Zigor\"><br>"
echo "<p><h1>Version upgrading...</h1></p>"


#Utilizamos tool 'suid-wrapper' para poder ejecutar el script con los privilegios de root


#Ejecutamos script de la actualizacion:
##########
if [ -f "/usr/local/zigor/reserva/actualizacion.sh" ]
then
    #/usr/local/zigor/reserva/actualizacion.sh
    /usr/local/zigor/activa/tools/suid-wrapper /usr/local/zigor/reserva/actualizacion.sh
fi


echo "<p><h1>Version upgrade done</h1></p>"
echo "</div></body>"
echo "</html>"
exit 0
