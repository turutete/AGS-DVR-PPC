require "functions"
require "oids-dvr"

local sdsxsnmp_host = "localhost"
local sdsxsnmp_community = "zadmin"  --XXX

ags = {
   objsds = {  --objeto de acceso al sds
      mod_filename="dvrmodem",  -- basta cargarlo una vez
      mod_new="sdsxsnmp",
      --
      host      = sdsxsnmp_host,
      community = sdsxsnmp_community,
   },
   --
   -- Comunicacion modem GSM
   --
   cmmodem = {
      mod_new = "cmmodem",
      depends = {
	 elsds = "objsds",
      },
      -- Configuración módulo
      n_ioport = 1,		-- numero de puerto serie (/dev/ttySX)
      baudrate = 9600,		-- velocidad de comunicacion
      timeout = 25000,		-- tiempo de polling (mseg)
				-- suficientemente grande para dejar tiempo a mgetty
				-- y mejor aprox.=timeout sms_handler (script-snmpd-XXX)
      oid_status = zigorDvrObjModemStatus,
   },
}
