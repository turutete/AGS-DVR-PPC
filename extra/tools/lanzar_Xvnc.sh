#!/bin/bash

# NO EDITAR ESTE FICHERO

# Lanzador del servidor vnc (Xvnc)
#
# Created by AGS.

#Lanzar servidor VNC:

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"

#Xvnc:
Xvnc :1 -rfbport 5901 -dpi 88 -depth 16 -geometry 1024x600 -nocursor -alwaysshared -desktop zigor -fp /usr/share/fonts/misc  &

sleep 1

#establecer color de fondo
#vease /usr/X11R6/lib/X11/rgb.txt
#Fondo para DVR:
${PATH_ACTIVA_TOOLS}/xsetroot -d :1 -solid "rgb:20/20/20"

