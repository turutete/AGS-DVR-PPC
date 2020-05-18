#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-dvr"

#XXX debug:
if [ $# -ge 1 ]
then
  PATH_ACTIVA_AGS="${PATH_ACTIVA_AGS}/dbg"
fi

# idioma:
export LC_ALL=""
echo $LC_ALL
export LAUNCH="${PATH_ACTIVA_TOOLS}/`basename $0`"
echo $LAUNCH
###

cd ${PATH_ACTIVA_AGS}/bin

export DISPLAY=:1
#export GTK2_RC_FILES="${PATH_ACTIVA_TOOLS}/gtkrc.zigor"
export GTK2_RC_FILES="/etc/gtk-2.0/gtkrc"

ln -sf dvr ags-cliente-remoto
G_SLICE=always-malloc ./ags-cliente-remoto cflua dvr-gtk2ui
 
