require "functions"

function mgetty_restart()
   os.execute("killall mgetty")
end

local this  = {
   file     = "/etc/mgetty+sendfax/mgetty.config",
   get      = tmpl_get,
   save     = tmpl_save,   
--  restart  = tmpl_service_restart,
  restart  = mgetty_restart,
--   _service = "snmpd",
   tmpl     = [[
# NO EDITAR ESTE FICHERO

#
# mgetty configuration file
#
# Created by AGS.
#
# this is a sample configuration file, see mgetty.info for details
#
# comment lines start with a "#", empty lines are ignored


# ----- global section -----
#
# In this section, you put the global defaults, per-port stuff is below


# set the global debug level to "4" (default from policy.h)
debug 4

# set the local fax station id
fax-id 49 115 xxxxxxxx

# access the modem(s) with 38400 bps
speed 38400

#  use these options to make the /dev/tty-device owned by "uucp.uucp" 
#  and mode "rw-rw-r--" (0664). *LEADING ZERO NEEDED!*
#port-owner uucp
#port-group uucp
#port-mode 0664

#  use these options to make incoming faxes owned by "root.uucp" 
#  and mode "rw-r-----" (0640). *LEADING ZERO NEEDED!*
#fax-owner root
#fax-group uucp
#fax-mode 0640


# ----- port specific section -----
# 
# Here you can put things that are valid only for one line, not the others
#

# Zoom V.FX 28.8, connected to ttyS0: don't do fax, less logging
#
#port ttyS0
#  debug 3
#  data-only y

# some other Rockwell modem, needs "switchbd 19200" to receive faxes
# properly (otherwise it will fail with "timeout").
#
#port ttyS1
#  speed 38400
#  switchbd 19200

# ZyXEL 2864, connected to ttyS2: maximum debugging, grab statistics
#
#port ttyS2
#  debug 8
#  init-chat "" \d\d\d+++\d\d\dAT&FS2=255 OK ATN3S0=0S13.2=1 OK 
#  statistics-chat "" AT OK ATI2 OK
#  statistics-file /var/log/statistics.ttyS2
#  modem-type cls2

# direct connection of a VT100 terminal which doesn't like DTR drops
#
#port ttyS3
#  direct y
#  speed 19200
#  toggle-dtr n

#----------
# Modem GSM Zigor
port ttyS1
  data-only yes
  speed 9600
  # debug: ctrl de logs (/var/log/mgetty/mgetty.ttySX), valor 0..9
  # importante poner a 0 para evitar escritura flash, sobretodo sino se ha redirigido a disco ram
  debug 0
  # init-chat: secuencia de inicializacion del modem. Formato:
  # respecto al pin imprescindible incluir comillas en modelo Sony Ericsson GM29
  # tambien importante incluir AT OK para que no se intente configurar pin mientras no preparado
  # si se desea incluir un delay usese "\d" tantas veces sea necesario
  init-chat "" AT OK AT+CPIN=\"$$zigorDialUpPin.0\"

]]

}

return this
