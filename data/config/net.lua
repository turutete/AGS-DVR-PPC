require "functions"

local this  = {
   file     = "/etc/conf.d/net",
   get      = tmpl_get,
   save     = tmpl_save,   
   restart  = tmpl_service_restart,
   _service = "net.eth0",
   tmpl     = [[
# NO EDITAR ESTE FICHERO

###########################################################################
#
# /etc/conf.d/net
#
#   - created by AGS
#
###########################################################################

config_eth0=(
	"$$zigorNetIP.0 netmask $$zigorNetMask.0"
)
routes_eth0=(
	"default gw $$zigorNetGateway.0"
)
]]

}

return this
