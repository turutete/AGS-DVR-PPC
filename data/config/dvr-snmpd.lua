-- Variable global con el nombre del "profile"
profile = "dvr"

require "functions"
require "defs-dvr"
require "objs-dvr"
require "oids-dvr"
require "oids-alarm"
require "oids-alarm-log"

-- configuración
local gw_root_node  = zigor                  -- OID rama gestionada por nuestro subagente 
local mib_root_node = "zigorExperiment"      -- Identificador rama en la que inicializar objetos

-- fin configuración

ags = {
   sdscoreglib = {
      mod_filename = "dvrserver", -- Solo hace falta cargarlo aquí.
      mod_new = "sdscoreglib",
   },
   gwsnmp = {
      mod_new = "gwsnmp",
      depends = {
	 ["sds"] = "sdscoreglib",
      },
      -- Configuración módulo
      root_node = gw_root_node,
      use_serialize = false,
      max_checks = 10,
      master = false -- XXX todavía no funciona como master
   },
   cmmibinit = {
      mod_new = "cmmibinit",
      depends = {
	 ["sds"] = "sdscoreglib",
	 _ = "gwsnmp",       -- requiere net-snmp inicializado
      },
      -- Configuración módulo
      root_node = mib_root_node,
      values = {
	 [zigorDvrObjEComDSP .. ".0"       ] = 2,  --com. ok
	 [zigorDvrObjOrdenMarcha .. ".0"   ] = 2,  --orden nula
	 [zigorDvrObjOrdenParo .. ".0"     ] = 2,  --orden nula
	 [zigorDvrObjOrdenReset .. ".0"    ] = 2,  --orden nula
      },
      tables = {
	 [zigorAlarmEntry .. ".0"      ] = -1,
	 [zigorAlarmCfgEntry .. ".0"   ] = -1,
	 [zigorAlarmLogEntry .. ".0"   ] = -1,
	 [zigorSysPasswordEntry .. ".0"] = -1,
	 [zigorDvrGapLogEntry .. ".0"  ] = -1,  --gaplog
      },
   },
   --
   -- bus Zigor DSP (no hay que arbitrar. polling de interrogacion cada XXX ms)
   --
   rbuffer_dsp = {
      mod_new = "cmtextbuffer",
      depends = {
	 _ = "sdscoreglib",
      },
      --
      text = "",
   },
   wbuffer_dsp = {
      mod_new = "cmtextbuffer",
      depends = {
	 _ = "sdscoreglib",
      },
      --
      text = "",
   },
   zigorobj_dsp = {
      mod_new = "cmzigorobj",
      depends = {
	 rbuffer = "rbuffer_dsp",
	 wbuffer = "wbuffer_dsp",
	 sds     = "sdscoreglib",
      },
      --
      types = tipo_objeto_dsp, -- definido en defs-dvr.lua
      objects = objects_dsp    -- definido en objs-dvr.lua
   },
   zigorbus_dsp = {
      mod_new = "cmzigorbus",
      depends = {
	 rbuffer = "rbuffer_dsp",
	 wbuffer = "wbuffer_dsp",
	 _       = "script",       -- Queremos ser los últimos en conectar al bus de salida. Precarga del resto que conecten.
      },
      -- XXX
      bus_filename = "/dev/ttyS2",
      queue        = true,         -- ¿usar cola de escritura? (sincronizada con el bus)
      da           = byte(x"11"),  -- si queue = true (da del nodo embedded, para permiso de respuesta en caso de no ser arbitro, establecer en cualquier caso)
      da_gestora   = byte(x"03"),  -- si se especifica, se sustituye en tramas PREGUNTA_POLL
                                   -- (sustituye da de arbitraje por da de direccion, establecer tambien en caso de ser arbitro para evitar problemas con el eco)
      -- timeout (no publicamos periodicamente, solo ante PREGUNTA_POLL)
   },
   zigormng_dsp = {
      mod_new = "cmzigormng",
      depends = {
	 zigorobj = "zigorobj_dsp",
	 rbuffer  = "rbuffer_dsp",
	 zigorbus = "zigorbus_dsp",
	 sds      = "sdscoreglib",
      },
      --
      timeout    = 100,
      -- Objectos a publicar/arbitrar
      objects_id = {
	 ["1"] = { daid = DA_ETX_BUS_DSP .. ID_ETX_BUF },
      },
      -- Nodos a auditar
      nodes = {
	 dsp = { da = DA_DSP, },
      },
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

   -------------------------------------
   script_text = {
      mod_new="cmtextbuffer",
      --
      txt_filename="script-snmpd-dvr.lua",
   },
   --
   script = {
      mod_new="cmscript",
      depends = {
	 interpreter  = "cflua",
	 script_text  = "script_text",
	 --
	 gw           = "gwsnmp",       -- Se requiere Net-SNMP inicializado en el "script".
	 buffer       = "wbuffer_dsp",  -- Nos conectamos al "buffer" de salida. Solo precarga, se cogera nombre de objeto directamente.
	 _            = "cmmibinit",    -- mas conveniente
      },
      --
   },   
   script2 = {
      mod_new="cmscript",
      depends = {
	 interpreter  = "cflua",
	 script_text  = "script2_text",
	 --
	 sds          = "sdscoreglib",
	 dsp_status   = "zigormng_dsp",   -- Nos conectamos a goodsig/failsig. Solo precarga, se cogera nombre de objeto directamente.
      },
      --
   },
   script2_text = {
      mod_new="cmtextbuffer",
      --
      text = [[
require "oids-dvr"
loadlualib("access")
loadlualib("gobject")

--XXX cambiar a utilizar MIB de STATUS

local dsp_goodsig_handler_id
local dsp_failsig_handler_id

local function dsp_goodsig_handler(da, user_data)
   access.set(sdscoreglib, zigorDvrObjEComDSP .. ".0", 2)  --clear
end
local function dsp_failsig_handler(da, user_data)
   access.set(sdscoreglib, zigorDvrObjEComDSP .. ".0", 1)  --set
end

dsp_goodsig_handler_id=gobject.connect(zigormng_dsp, "goodsig", dsp_goodsig_handler, nil)
dsp_failsig_handler_id=gobject.connect(zigormng_dsp, "failsig", dsp_failsig_handler, nil)
	]],
   },
}
