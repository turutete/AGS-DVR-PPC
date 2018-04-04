require "functions"

local this  = {
   file     = "/etc/resolv.conf",
   get      = tmpl_get,
   save     = tmpl_save,   
--   restart  = tmpl_service_restart,
--   _service = "net.eth0",
   tmpl     = [[
# NO EDITAR ESTE FICHERO

###########################################################################
#
# /etc/resolv.conf
#
#   - created by AGS
#
###########################################################################

nameserver $$zigorNetDNS.0
]]

}

return this
