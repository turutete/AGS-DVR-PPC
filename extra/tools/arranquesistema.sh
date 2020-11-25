/usr/local/opengalax-init start


### XXX dev:
rm -rf /dev/kbde
mknod /dev/kbde c 11 0
insmod /usr/local/zigor/activa/drivers/kbde.ko


# XXX dev!
#route add default gw 192.168.69.149


PATH_ACTIVA_TOOLS="/usr/local/zigor/activa/tools"


${PATH_ACTIVA_TOOLS}/lanzar_stty.sh &>/dev/null


# XXX
mount --bind /var/log/msmtp.zlog /home/user/email_log


#${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-servidor.sh &>/dev/null &
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-servidor.sh &>/var/log/ags-servidor &

#sleep 5

# on LAN boot:
###mount -t devpts none /dev/pts
# startx: (-br parece no hace falta)
#/usr/bin/X -nolisten tcp &
/usr/bin/X -nolisten tcp &>/var/log/startx &

#sleep 1
# idea hide_cursor fuera de mainwin->vbox1 (parece no vale del todo esto y hay q lanzarlo desde la aplicacion)
#${PATH_ACTIVA_TOOLS}/hide_cursor.sh

sleep 2

# (new) en arranque siempre comenzar en nivel 1:
sed -i -e 's/ACCESS_LEVEL=.*/ACCESS_LEVEL=1/' ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh

#G_SLICE=always-malloc ${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/dev/null &
#G_SLICE=always-malloc ${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/var/log/ags-cliente-local &
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/var/log/ags-cliente-local &
##su - genjur -c "${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-local.sh &>/var/log/ags-cliente-local" &

#sleep 5

#${PATH_ACTIVA_TOOLS}/lanzar_Xvnc.sh &>/dev/null &
${PATH_ACTIVA_TOOLS}/lanzar_Xvnc.sh &>/var/log/lanzar_Xvnc &
/usr/local/zigor/activa/tools/xscreensaver_once.sh &

sleep 5

#G_SLICE=always-malloc ${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/dev/null &
#G_SLICE=always-malloc ${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/var/log/ags-cliente-remoto &
${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-cliente-remoto.sh &>/var/log/ags-cliente-remoto &

${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-modem.sh &>/dev/null &

${PATH_ACTIVA_TOOLS}/respawn.sh ${PATH_ACTIVA_TOOLS}/ags-modbus.sh &>/dev/null &

sleep 15 && ${PATH_ACTIVA_TOOLS}/snmpd-mon.sh &>/dev/null &

sleep 30
# idea apagado/encendido display (de momento uso xscreensaver...) ojo lanzar como usuario distinto a root
#su - genjur -c "DISPLAY=:0 xscreensaver -no-splash -display :0" &
${PATH_ACTIVA_TOOLS}/xscreensaver.sh &


# XXX
${PATH_ACTIVA_TOOLS}/respawn.sh /usr/sbin/mgetty ttyS1 &
lighttpd -f /etc/lighttpd/lighttpd.conf

killall xscreensaver_once.sh
killall xv
