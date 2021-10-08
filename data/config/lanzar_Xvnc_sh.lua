require "functions"

function vnc_restart()
   os.execute("killall Xvnc")
   os.execute("/usr/local/zigor/activa/tools/lanzar_Xvnc.sh")
end

function lanzar_Xvnc_get(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global

   -- Sustituimos subidentificadores por OIDs
   local t=string.gsub(this.tmpl, "%$(%w+)", function (k) return oids[k] or "$" .. k end)
   -- Sustituimos OIDs por valor
   t=string.gsub(t, "%$([%.%d]+)", function (k) local v=access.get(sds, k) return v end)

   t=string.gsub(t, "_USE_PASSWORD_", function (k)
                                         if access.get(sds, zigorNetVncPassword .. ".0")=="" then 
                                            return ""
                                         else
                                            return "-rfbauth /etc/.vncpasswd"
                                         end
                                      end)
   return t
end

local this  = {
   file     = "/usr/local/zigor/activa/tools/lanzar_Xvnc.sh",
   get      = lanzar_Xvnc_get,
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

#Xvnc:
Xvnc :1 -rfbport $$zigorNetPortVnc.0 -dpi 88 -depth 16 -geometry 1024x600 -nolisten tcp -nocursor -alwaysshared -desktop zigor -fp /usr/share/fonts/misc _USE_PASSWORD_ &

sleep 1

#establecer color de fondo
#vease /usr/X11R6/lib/X11/rgb.txt
#Fondo para DVR:
${PATH_ACTIVA_TOOLS}/xsetroot -d :1 -solid "rgb:20/20/20"

]]

}

return this
