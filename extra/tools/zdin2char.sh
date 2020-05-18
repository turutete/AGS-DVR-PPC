#!/bin/bash

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"


mkfifo /var/pipe-zdin

#Activar si queremos control del backlight (variables de entorno de zdin2char):
export BUSY_COMMAND="echo -ne \"\010\" > /var/pipe-zs2p"
export IDLE_COMMAND="echo -ne \"\370\" > /var/pipe-zs2p"
#timeout en segundos:
export TIMEOUT="10"

${PATH_ACTIVA_TOOLS}/zdin2char </proc/zigor/zdin >/var/pipe-zdin
