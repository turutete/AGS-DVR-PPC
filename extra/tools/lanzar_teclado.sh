#!/bin/bash

###Lanzar teclado:

PATH_ACTIVA_TOOLS="/usr/local/zigor/activa/tools"

#Activar si queremos salvapantallas:
#export IDLE_COMMAND="${PATH_ACTIVA_TOOLS}/off"
#export BUSY_COMMAND="${PATH_ACTIVA_TOOLS}/on"
export IDLE_COMMAND="${PATH_ACTIVA_TOOLS}/cgos-backlight off"
export BUSY_COMMAND="${PATH_ACTIVA_TOOLS}/cgos-backlight on"

export LOGOUT_COMMAND="killall -TERM ags-cliente-local"
export TIMEOUT_COMMAND="snmpget -v 2c -c zadmin -Ov localhost .1.3.6.1.4.1.4576.4.3.1.11.0"

#timeout en segundos:
#export TIMEOUT="300"
export TIMEOUT="600"

export LD_LIBRARY_PATH=${PATH_ACTIVA_TOOLS}

###${PATH_ACTIVA_TOOLS}/char2scancode </dev/ttyS4  >/proc/zigor/zkbd
#cat /dev/ttyS4 | ${PATH_ACTIVA_TOOLS}/char2scancode >/proc/zigor/zkbd
cat /dev/ttyS4 | ${PATH_ACTIVA_TOOLS}/char2scancode2 >/proc/zigor/zkbd
