#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-dvr"

#XXX debug:
if [ $# -ge 1 ]
then
  PATH_ACTIVA_AGS="${PATH_ACTIVA_AGS}/dbg"
  source ${PATH_ACTIVA_TOOLS}/path-mibs.source dbg
else
  source ${PATH_ACTIVA_TOOLS}/path-mibs.source
fi

cd ${PATH_ACTIVA_AGS}/bin

ln -sf dvr ags-servidor
./ags-servidor cflua dvr-snmpd
