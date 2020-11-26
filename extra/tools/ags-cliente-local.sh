#!/bin/bash

LOCK_FILE=/tmp/block_gui.txt
if [ -f $LOCK_FILE ]; then
    sleep 1
    exit
fi

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-dvr"

#XXX debug:
if [ $# -ge 1 ]
then
  PATH_ACTIVA_AGS="${PATH_ACTIVA_AGS}/dbg"
fi

# idioma:
#export LC_ALL="en_GB.utf8"
export LC_ALL="en_GB.utf8"
echo $LC_ALL
export LAUNCH="${PATH_ACTIVA_TOOLS}/`basename $0`"
echo $LAUNCH
export ACCESS_LEVEL=1
echo $ACCESS_LEVEL
###

cd ${PATH_ACTIVA_AGS}/bin

export DISPLAY=:0
#export GTK2_RC_FILES="${PATH_ACTIVA_TOOLS}/gtkrc.zigor"

ln -sf dvr ags-cliente-local
G_SLICE=always-malloc ./ags-cliente-local cflua dvr-gtk2ui-local
