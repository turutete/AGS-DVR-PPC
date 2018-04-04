require "functions"

loadlualib("gobject")
loadlualib("gdk")
loadlualib("config")

local sdsxsnmp_host = "localhost"
local sdsxsnmp_community = "zadmin"  --XXX

----------------------------------------
ags = {
   mainwin = {
      mod_filename="dvrcurses",
      mod_new="uicurses",
      --
      --term = "vt52",
      term = "zlcd",    -- permite usar la implementacion de curses.clear. incluir terminfo zlcd (/etc/terminfo/z/zlcd)
      out_filename = "/proc/zigor/zlcd",
      --in_filename = "/var/pipe",
   },
   -------------------------------------
   sds = {
      mod_new="sdsxsnmp",
      --
      host      = sdsxsnmp_host,
      community = sdsxsnmp_community,
   },
   -------------------------------------
   script_text = {
      mod_new="cmtextbuffer",
      --
      txt_filename="script-curs2x16-dvr.lua",
   },
   --
   script = {
      mod_new="cmscript",
      depends = {
	 interpreter     = "cflua",
	 script_text     = "script_text",
	 --
	 sds             = "sds",
	 mainwin         = "mainwin",
      },
      --
   },
   -------------------------------------
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
}
