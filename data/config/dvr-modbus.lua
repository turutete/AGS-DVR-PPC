-- Configuracion cliente de control
require "functions"
require "oids-dvr"

local sdsxsnmp_host = "localhost"
local sdsxsnmp_community = "zadmin"

ags = {
   objsds = {  --objeto de acceso al sds
      mod_filename="dvrmodbus",  -- basta cargarlo una vez
      mod_new="sdsxsnmp",
      --
      host      = sdsxsnmp_host,
      community = sdsxsnmp_community,
      --trapd     = true,
      --transport = "udp:65165",  -- new
   },
   --
   -- Comunicacion MODBUS
   --
   modbus = {
      mod_new = "cmmodbus",
      depends = {
         elsds = "objsds",
      },
      -- Configuración módulo
      n_ioport = 5,  --numero de puerto serie (/dev/ttySX)
   },
   --
   -- Watchdog
   --
   --watchdog = {
      --mod_new = "cmwatchdog",
      --depends = {
      --},
      -- Configuración módulo
      --wd_filename = "/dev/watchdog",	-- nombre del dispositivo
      --refresh_time = 2000,		-- tiempo en ms entre llamadas de refresco
      --expiration_time = 5,		-- tiempo en s para llamada ioctl
   --},
}
