#!/bin/bash
##########
# Script de inicio para configuracion del SISTEMA y las APLICACIONES
##########

# Paths varios:
PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"
##########

# Lanzar servicios:
#boa, snmpd, (utelnetd), portmap... muchos ya incluidos en runlevel default
# Lanzar servidor telnet netkit-telnetd:
###${PATH_ACTIVA_TOOLS}/respawn.sh /usr/sbin/telnetd -debug 23 &
### Ahora se usa telnet-bsd + xinetd
##########

# Configuracion puertos serie:
# Set serial ports info (io ports, irqs...)
${PATH_ACTIVA_TOOLS}/setserial.sh &>/dev/null
# Change terminal line settings (speed, parity...)
${PATH_ACTIVA_TOOLS}/lanzar_stty.sh &>/dev/null
##########

# Carga de modulos del kernel:
/sbin/insmod ${PATH_ACTIVA_TOOLS}/zproc.o &>/dev/null
###/sbin/insmod ${PATH_ACTIVA_TOOLS}/blkscr.o &>/dev/null

/sbin/modprobe cgosdrv cgos_major=100

###/sbin/insmod ${PATH_ACTIVA_TOOLS}/zdin.o &>/dev/null
###/sbin/insmod ${PATH_ACTIVA_TOOLS}/zs2p.o &>/dev/null
###/sbin/insmod ${PATH_ACTIVA_TOOLS}/zlcd.o &>/dev/null
/sbin/insmod ${PATH_ACTIVA_TOOLS}/zkbd.o &>/dev/null
###/sbin/insmod ${PATH_ACTIVA_TOOLS}/zwdt.o &>/dev/null
##########

mount --bind /var/log/msmtp.zlog /home/user/email_log

# Lanzar teclado local con control de apagado/encendido:
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/lanzar_teclado.sh &
##########

# Lanzar gestion del modem:
${PATH_ACTIVA_TOOLS}/respawn.sh /usr/sbin/mgetty ttyS1 &
##########

# Lanzar vigilante de watchdog:
###${PATH_ACTIVA_TOOLS}/watchman &>/dev/null &
##########


#Lanzar filtro para control de salidas digitales:
###mkfifo /var/pipe-zs2p
###${PATH_ACTIVA_TOOLS}/char2zs2p </var/pipe-zs2p >/proc/zigor/zs2p &
###${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/char2zs2p </var/pipe-zs2p >/proc/zigor/zs2p &

# Lanzar aplicacion servidor:
###chmod 777 /var/agentx/master
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-servidor.sh &>/dev/null &
###${PATH_ACTIVA_TOOLS}/ags-servidor.sh &>/dev/null &
###${PATH_ACTIVA_TOOLS}/ags-servidor.sh &>/var/log/ags-servidor.log &
##########

# Lanzar aplicacion cliente lcd:
#Lanzar filtro de entrada de pulsadores redirigiendo salida a entrada de cliente lcd:
###${PATH_ACTIVA_TOOLS}/zdin2char.sh &
##${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/zdin2char.sh &
#---
#sleep ya que se ha observado: "ags-lcd.sh: /var/pipe-zdin: No such file or directory"
##sleep 1
##${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-lcd.sh 2>/dev/null &
###${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-lcd.sh 2>/var/log/ags-lcd.log &
###${PATH_ACTIVA_TOOLS}/ags-lcd.sh 2>/var/log/ags-lcd.log &
###${PATH_ACTIVA_TOOLS}/ags-lcd.sh 2>/dev/null &
##########


# Lanzar servidor X:
${PATH_ACTIVA_TOOLS}/lanzar_X.sh &>/dev/null &
##########

# Lanzar aplicacion cliente: (display local)
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/dev/null &
###${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/dev/null &
##########


# Lanzar servidor Xvnc:
${PATH_ACTIVA_TOOLS}/lanzar_Xvnc.sh &>/dev/null & 
##########

# Lanzar aplicacion cliente: (display remoto)
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/dev/null &
###${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/var/log/ags-cliente-remoto.log &
###${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/dev/null &
##########


# Lanzar aplicacion cliente: (display local - variante compartir escritorio)
#export DISPLAY=:0
#vncviewer :1 -fullscreen -encodings "raw copyrect" &>/dev/null
##########


# Lanzar proceso del modem:
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-modem.sh &>/dev/null &
##########


# Lanzar proceso del modbus:
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-modbus.sh &>/dev/null &
##########


# Monitorizacion de net-snmpd
sleep 15 && ${PATH_ACTIVA_TOOLS}/snmpd-mon.sh &>/dev/null &
##########

#exit 0
