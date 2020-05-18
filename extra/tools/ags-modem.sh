#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-dvr"

#XXX debug:
if [ $# -ge 1 ]
then
  PATH_ACTIVA_AGS="${PATH_ACTIVA_AGS}/dbg"
fi

cd ${PATH_ACTIVA_AGS}/bin

ln -sf dvr ags-modem
./ags-modem cflua dvr-modem
