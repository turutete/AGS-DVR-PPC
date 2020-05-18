#!/bin/bash
##########
# Snmpd Monitor
# polling periodico de variable general de sistema 'zigorSysName' de ZIGOR-PARAMETER-MIB
# para verificar estado de agente snmpd y reiniciar en caso necesario.
# nota: usa community fija zadmin
##########

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"

source ${PATH_ACTIVA_TOOLS}/path-mibs.source

fail_count=0
restart_count=0
file="snmpd-mon.zlog"

while [ true ]; do
   #/usr/bin/snmpwalk -v 2c -c zadmin localhost zigorSysName
   /usr/bin/snmpget -v 2c -c zadmin localhost zigorSysName.0
   resul=$?
   
   if ((resul==1)); then	# Snmpd Timeout
      ((fail_count += 1))
      echo "return 1, fail_count: ${fail_count}"
   else
      ((fail_count=0))
      echo "return 0, fail_count: ${fail_count}"
   fi
   if ((fail_count>5)); then
      ((fail_count=0))
      echo "snmpd restart"
      /etc/init.d/snmpd restart
      ((restart_count += 1))
      echo "contador: ${restart_count}" > /var/log/${file}
      sleep 15
   fi
   sleep 15
done
