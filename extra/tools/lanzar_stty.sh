#!/bin/bash

PATH_ACTIVA_TOOLS="/usr/local/zigor/activa/tools"

### MODEM:
/bin/stty -F /dev/ttyS1 `cat ${PATH_ACTIVA_TOOLS}/ttySX-9600-8N1-RTSyes.stty`

### bus zigor DSP:
/bin/stty -F /dev/ttyS0 `cat ${PATH_ACTIVA_TOOLS}/ttySX-38400-8E1-RTSno.stty`

# XXX dev:
#/bin/stty -F /dev/ttyS1 `cat ${PATH_ACTIVA_TOOLS}/ttySX-38400-8E1-RTSno.stty`
