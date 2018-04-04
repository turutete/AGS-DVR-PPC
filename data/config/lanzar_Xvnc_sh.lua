require "functions"

function vnc_restart()
   os.execute("killall Xvnc")
   os.execute("/usr/local/zigor/activa/tools/lanzar_Xvnc.sh")
end

local this  = {
   file     = "/usr/local/zigor/activa/tools/lanzar_Xvnc.sh",
   get      = tmpl_get,
   save     = tmpl_save,   
--  restart  = tmpl_service_restart,
  restart  = vnc_restart,
--   _service = "snmpd",
   tmpl     = [[
#!/bin/bash

# NO EDITAR ESTE FICHERO

# Lanzador del servidor vnc (Xvnc)
#
# Created by AGS.

#Lanzar servidor VNC:

PATH_ACTIVA="/usr/local/zigor/activa"
PATH_ACTIVA_TOOLS="${PATH_ACTIVA}/tools"

#vncserver: (OJO necesita perl)
#vncserver :0 -depth 16 -geometry 640x480 ...

#Xvnc:
#Xvnc :1 -depth 16 -geometry 640x480 -nocursor -alwaysshared (-nevershared) (-dontdisconnect) -httpd /usr/share/tightvnc/classes -desktop zigor &> /dev/null
#Xvnc :1 -depth 16 -geometry 640x480 -nocursor -alwaysshared -httpd /usr/share/tightvnc/classes -desktop zigor &> /dev/null
#Xvnc :1 -depth 16 -geometry 640x480 -nocursor -alwaysshared -desktop zigor &
#Xvnc :1 -dpi 96 -depth 16 -geometry 640x480 -nocursor -alwaysshared -desktop zigor &
###Xvnc :1 -dpi 88 -depth 16 -geometry 640x480 -nocursor -alwaysshared -desktop zigor &
Xvnc :1 -rfbport $$zigorNetPortVnc.0 -dpi 88 -depth 16 -geometry 640x480 -nocursor -alwaysshared -desktop zigor &

sleep 1

#establecer color de fondo
#vease /usr/X11R6/lib/X11/rgb.txt
#${PATH_ACTIVA_TOOLS}/xsetroot -d :1 -solid "light steel blue"
#${PATH_ACTIVA_TOOLS}/xsetroot -d :1 -solid "sky blue"
Fondo para DVR:
${PATH_ACTIVA_TOOLS}/xsetroot -d :1 -solid "rgb:20/20/20"

]]

}

return this
