#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
PATH_ACTIVA_AGS="${PATH_ACTIVA}/ags-sepec"

###sleep 5

#ej. flecha arriba
###echo -ne "\110" >/proc/zigor/zkbd
#left
#echo -ne "\340\113" >/proc/zigor/zkbd

cd ${PATH_ACTIVA_TOOLS}
./xsetroot -d :0 -cursor mycursor8x8-lines.xbm mycursor8x8-all0.xbm
