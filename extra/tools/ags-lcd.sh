#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
#PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-dvr"

#XXX debug:
if [ $# -ge 1 ]
then
  PATH_ACTIVA_AGS="${PATH_ACTIVA_AGS}/dbg"
fi

# idioma:
export LC_ALL="en_GB.utf8"
echo $LC_ALL
#export LAUNCH="`pwd`/`basename $0`"
export LAUNCH="${PATH_ACTIVA_TOOLS}/`basename $0`"
echo $LAUNCH
###

cd ${PATH_ACTIVA_AGS}/bin

ln -sf dvr ags-lcd

./ags-lcd cflua dvr-curs2x16 </var/pipe-zdin
