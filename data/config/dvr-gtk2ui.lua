-- IMPORTANTE: ESTE FICHERO ESTÃ EN UTF-8
-- Variable global con el nombre del "profile"
profile = "dvr"

-- XXX (jur) para discriminar local de remoto
remote = 1
--remote = 0

require "functions"

loadlualib("gobject")
loadlualib("gdk")
loadlualib("config")

-- XXX necesarios en loginscript, borrar si se mueve a otro fuente
require("gtk")
loadlualib("access")
loadlualib("accessx")

local sdsxsnmp_host = "localhost"
local sdsxsnmp_community = "XXX"  -- En realidad se usara el que se introduzca en pantalla de login

local columns = {
   ["1"]  = { name = "name",    type = G_TYPE_STRING,   },
   ["2"]  = { name = "type",    type = G_TYPE_STRING,   },
   ["3"]  = { name = "key",     type = G_TYPE_STRING,   },
   ["4"]  = { name = "val",     type = G_TYPE_VALUE,    },
   ["5"]  = { name = "display", type = G_TYPE_STRING,   },
   ["6"]  = { name = "units",   type = G_TYPE_STRING,   },
   ["7"]  = { name = "factor",  type = G_TYPE_INT,      },
   ["8"]  = { name = "descr",   type = G_TYPE_STRING,   },
   ["9"]  = { name = "pic",     type = GDK_TYPE_PIXBUF, },
   ["10"] = { name = "edit",    type = G_TYPE_BOOLEAN,  },
   ["11"] = { name = "id",      type = G_TYPE_STRING,   },
   ["12"] = { name = "enum",    type = G_TYPE_STRING,   },
   --
   ["13"] = { name = "node-visible",  type = G_TYPE_BOOLEAN, },
   ["14"] = { name = "var-visible",   type = G_TYPE_BOOLEAN, },
   --["15"] = { name = "param-visible", type = G_TYPE_BOOLEAN, }, --solo si estado y param de un mismo nodo
}

local columns_alarms = {
   [ "1"] = { name = "descr",        type = G_TYPE_STRING,  },
   [ "2"] = { name = "codigo",       type = G_TYPE_STRING,  },
   [ "3"] = { name = "display",      type = G_TYPE_STRING,  },
   [ "4"] = { name = "time",         type = G_TYPE_STRING,  },
   [ "5"] = { name = "time-display", type = G_TYPE_STRING,  },
   [ "6"] = { name = "elements",     type = G_TYPE_STRING,  },
   [ "7"] = { name = "cond",         type = G_TYPE_INT,     },
   [ "8"] = { name = "id",           type = G_TYPE_STRING,  },
   [ "9"] = { name = "pic",          type = GDK_TYPE_PIXBUF,},
   ["10"] = { name = "imp-key",      type = G_TYPE_STRING,  },
   ["11"] = { name = "imp",          type = G_TYPE_INT,     },
   ["12"] = { name = "imp-display",  type = G_TYPE_STRING,  },
   ["13"] = { name = "ack",          type = G_TYPE_BOOLEAN, },
   ["14"] = { name = "reset",        type = G_TYPE_BOOLEAN, },
}

local columns_heventos = {
   [ "1"] = { name = "descr",        type = G_TYPE_STRING,  },
   [ "2"] = { name = "codigo",       type = G_TYPE_STRING,  },
   [ "3"] = { name = "display",      type = G_TYPE_STRING,  },
   [ "4"] = { name = "time",         type = G_TYPE_STRING,  },
   [ "5"] = { name = "time-display", type = G_TYPE_STRING,  },
   [ "6"] = { name = "element",      type = G_TYPE_STRING,  },
   [ "7"] = { name = "cond",         type = G_TYPE_INT,     }, -- enumerado
   [ "8"] = { name = "id",           type = G_TYPE_STRING,  },
   [ "9"] = { name = "pic",          type = GDK_TYPE_PIXBUF,},
   ["10"] = { name = "imp-key",      type = G_TYPE_STRING,  },
   ["11"] = { name = "imp",          type = G_TYPE_INT,     },
   ["12"] = { name = "imp-display",  type = G_TYPE_STRING,  },
}

local columns_gaplog_st = {
   [ "1"] = { name = "id",           type = G_TYPE_STRING,  },
   [ "2"] = { name = "minimo",       type = G_TYPE_INT,     },
   [ "3"] = { name = "integral",     type = G_TYPE_INT,     },
   [ "4"] = { name = "tiempo",       type = G_TYPE_INT,     },
   [ "5"] = { name = "fase",         type = G_TYPE_INT,     },
   [ "6"] = { name = "fase-display", type = G_TYPE_STRING,  },
   [ "7"] = { name = "time",         type = G_TYPE_STRING,  },
   [ "8"] = { name = "time-display", type = G_TYPE_STRING,  },
}

local columns_treeview = {
   properties = { ["headers-visible"] = false, },
   -- columna 1
   ["1"] = {
      properties = { title = "Nombre", alignment = 0.5, },  -- i18n
      -- "Cells" columna 1
      cells = {
	 ["1"] = { name = "pic",  },
	 ["2"] = { name = "name",
	    -- properties = { ["family"] = "Monospace", },
	    properties = { height = 45 },   -- (jur) altura de las filas de los menus gtktreeview
	 },
      },
   },
}
local columns_infoview = {
   properties = { ["rules-hint"] = true, },
   -- columna 1
   ["1"] = {
      properties = { title = "Nombre", },  -- i18n
      -- "Cells" columna 1
      cells = {
	 ["1"] = { name = "pic",  },
	 ["2"] = { name = "name",
	    -- properties = { ["family"] = "Monospace", },
	 },
      },
   },
   -- columna 2
   ["2"] = {
      properties = { title = "Valor", },  -- i18n
      -- "Cells columna 2
      cells = {
	 ["1"] = { name = "display",
	    --properties ={ foreground = "Blue", font = "Courier", },
	    properties ={ foreground = "Blue", font = "Courier", height = 34 },
	    ----properties = { background = "Black", foreground = "White", },
	 },
	 ["2"] = { name = "units", }
      },
   },
}

local columns_alarms_view = {
   properties = { ["rules-hint"] = true, },
   -- columna 1
   ["1"] = {
      properties = { title = "Código", },  -- i18n
      -- "Cells" columna 1
      cells = {
	 ["1"] = { name = "codigo",
	    properties = { foreground = "Black", },
	 },
      },
   },
   -- columna 2
   ["2"] = {
      properties = { title = "Evento", },  -- i18n
      -- "Cells" columna 2
      cells = {
	 ["1"] = { name = "display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 3
   ["3"] = {
      properties = { title = "Fecha", },  -- i18n
      -- "Cells" columna 5
      cells = {
	 ["1"] = { name = "time-display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
}

local columns_heventos_view = {
   properties = { ["rules-hint"] = true, },
   -- columna 1
   ["1"] = {
      properties = { title = "Código", },  -- i18n
      -- "Cells" columna 1
      cells = {
	 ["1"] = { name = "codigo",
	    properties = { foreground = "Black", },
	 },
      },
   },
   -- columna 2
   ["2"] = {
      properties = { title = "Evento", },  -- i18n
      -- "Cells" columna 2
      cells = {
	 ["1"] = { name = "display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 3
   ["3"] = {
      properties = { title = "Est.", },  -- i18n
      -- "Cells" columna 3
      cells = {
	 ["1"] = { name = "pic", },
      },
   },
   -- columna 4
   ["4"] = {
      properties = { title = "Fecha", },  -- i18n
      -- "Cells" columna 5
      cells = {
	 ["1"] = { name = "time-display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 5
   ["5"] = {
      properties = { title = "Descripción", },  -- i18n
      -- "Cells" columna 6
      cells = {
	 ["1"] = { name = "element",
	 },
      },
   },
}

local columns_gaplog_vw = {
   properties = { ["rules-hint"] = true, },
   -- columna 1
   ["1"] = {
      properties = { title = "Mínimo (%)", },
      -- "Cells" columna 1
      cells = {
	 ["1"] = { name = "minimo",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 2
   ["2"] = {
      properties = { title = "Media (%)", },
      -- "Cells" columna 2
      cells = {
	 ["1"] = { name = "integral",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 3
   ["3"] = {
      properties = { title = "Duración (ms)", },
      -- "Cells" columna 3
      cells = {
	 ["1"] = { name = "tiempo",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 4
   ["4"] = {
      properties = { title = "Fase", },
      -- "Cells" columna 4
      cells = {
	 ["1"] = { name = "fase-display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
   -- columna 5
   ["5"] = {
      properties = { title = "Fecha", },
      -- "Cells" columna 5
      cells = {
	 ["1"] = { name = "time-display",
	    properties = { foreground = "Blue", },
	 },
      },
   },
}

local columns_enum = {
   ["1"] = { name = "n",    type = G_TYPE_INT,    },
   ["2"] = { name = "text", type = G_TYPE_STRING, },
}

-- keymaps:
-----------
-- Se define tabla "keymap" con teclas de entrada y tabla asociada con definicion de teclas para cada modo.
-- Existen 3 modos de operacion:
--    modo "monotecla": se utiliza unicamente el elemento 1 de la tabla (pensado para navegacion).
--    modo "multitecla": se utilizan los elementos 2 en adelante en modo ciclico (pensado para edicion).
--    modo "unitecla": se utiliza unicamente el elemento 2 de la tabla (surge para la edicion en "campos ocultos" donde no puede haber multitecla claro).
-- La aplicacion de cada modo es en funcion de la editabilidad y visibilidad (campos ocultos) del widget que posea el foco. Asi:
--    si widget no editable -> modo monotecla
--    si widget editable y visible -> modo multitecla
--    si widget editable y no visible -> modo unitecla
--
-- Como tecla de entrada se utiliza el mapeo existente del modulo "char2scancode" de teclas Fx para las teclas numéricas.
-- No obstante existe la posibilidad de utilizar mapeo _aun mas_ independiente de teclado
-- utilizando simbolos no existentes en teclado para evitar conflictos con teclado remoto.
local keymap = {
   F1  =  { ["1"]="0", ["2"]="0", ["3"]="space", ["4"]="period", ["5"]="comma", ["6"]="colon", ["7"]="minus", ["8"]="underscore", ["9"]="at", ["10"]="parenleft", ["11"]="parenright", ["12"]="asterisk", ["13"]="slash", ["14"]="backslash", },
   F2  =  { ["1"]="1", ["2"]="1", ["3"]="a", ["4"]="b", ["5"]="c", ["6"]="A", ["7"]="B", ["8"]="C", },
   F3  =  { ["1"]="2", ["2"]="2", ["3"]="d", ["4"]="e", ["5"]="f", ["6"]="D", ["7"]="E", ["8"]="F", },
   F4  =  { ["1"]="3", ["2"]="3", ["3"]="g", ["4"]="h", ["5"]="i", ["6"]="G", ["7"]="H", ["8"]="I", },
   F5  =  { ["1"]="4", ["2"]="4", ["3"]="j", ["4"]="k", ["5"]="l", ["6"]="J", ["7"]="K", ["8"]="L", },
   F6  =  { ["1"]="5", ["2"]="5", ["3"]="m", ["4"]="n", ["5"]="ntilde", ["6"]="M", ["7"]="N", ["8"]="Ntilde", },
   F7  =  { ["1"]="6", ["2"]="6", ["3"]="o", ["4"]="p", ["5"]="q", ["6"]="O", ["7"]="P", ["8"]="Q", },
   F8  =  { ["1"]="7", ["2"]="7", ["3"]="r", ["4"]="s", ["5"]="t", ["6"]="R", ["7"]="S", ["8"]="T", },
   F9  =  { ["1"]="8", ["2"]="8", ["3"]="u", ["4"]="v", ["5"]="w", ["6"]="U", ["7"]="V", ["8"]="W", },
   F10 =  { ["1"]="9", ["2"]="9", ["3"]="x", ["4"]="y", ["5"]="z", ["6"]="X", ["7"]="Y", ["8"]="Z", },
   Left = { ["1"]="Left", ["2"]="BackSpace", },
}

----------------------------------------
ags = {
   mainwin = {
      mod_new="uigtk2",
      depends = {
	 _ = "loginscript",
	 sds = "sds",  -- new
      },
      --
      properties = {
	 title = "DVR",
	 --["default-width"]  = 640,
	 --["default-height"] = 480,
	 ["default-width"]  = 1024,
	 ["default-height"] = 600,
      },
      hide_cursor = true,	-- opcion de ocultar el cursor
      timeout = 5*60;		-- segundos de inactividad para considerarse inactividad (5 minutos)
   },
   --
   ui = {
      mod_new="gtk2gladelo",
      depends = {
	 container_obj="mainwin",
      },
      --
      container_name="mainwindow",
      layout_filename="ui-dvr-1024x600.glade",
      layout_root = "vbox1",
   },
   --
   keysnooper = {
      mod_new="gtk2keysnooper",
      depends = {
	 --_ = "mainwin",
	 _ = "loginui",
      },
      --
      --keymap  = {},
      --hotspot = false, -- opción para que el cursor del ratón siga al foco de teclado
      keymap = keymap,
      timeout = 1500, -- timeout para efecto multitecla (milisegundos).
      --hotspot = true,
      hotspot = false, -- OJO he tenido q cambiar a false xq sino perdia el foco en remoto !?
   },
   --
   pixbufs = {
      mod_new="gtk2pixbufs",
      depends = {
	 _ = "loginui",
      },
      --
      pixbufs = {
	 --logo        = { pb_filename = "zigor_p.xpm", },
	 verde       = { pb_filename = "greenball.xpm", },
	 rojo        = { pb_filename = "redball.xpm", },
	 gris        = { pb_filename = "grayball.xpm", },
	 tree_sis    = { pb_filename = "tree_sis.xpm", },
	 activo      = { pb_filename = "redbell.xpm", },
	 inactivo    = { pb_filename = "greenbell.xpm", },
	 reconocido  = { pb_filename = "orangebell.xpm", },
	 bloqueado   = { pb_filename = "yellowbell.xpm", },
	 --idioma      = { pb_filename = "language.xpm", },
	 idioma      = { pb_filename = "translate-32.xpm", },
	 dsp         = { pb_filename = "DSP.xpm", },
	 medidas     = { pb_filename = "medidas.xpm", },
	 graybell    = { pb_filename = "graybell.xpm", },
	 cfg         = { pb_filename = "cfg.xpm", },
	 sinoptico   = { pb_filename = "SinopticoDVR.xpm", },
	 sinoptico_on = { pb_filename = "SinopticoDVR-ON.xpm", },
	 gris2       = { pb_filename = "grayball2.xpm", },
      },
   },

   -------------------------------------
   store = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado.
      },
      --
      columns = columns,
   },
   --
   sds = {
      mod_new="sdsxsnmp",
      --
      host      = sdsxsnmp_host,
      community = sdsxsnmp_community,
      trapd     = true,
      transport = "udp:65162",
   },
   --
   poll = {
      mod_new="pollglib",
      depends = {
	 model_obj = "store",
	 sds = "sds",
	 _ = "xml2store",
	 _ = "script",
      },
      --
      timeout = 3000,
   },
   -------------------------------------
   xml = {
      mod_new="cmtextbuffer",
      --
      text = "",
   },
   --
   lxml_textbuffer = {
      mod_new="cmtextbuffer",
      depends = {
	 _ = "loginscript",			-- no ejecutar hasta despues de login (porque depende del nivel de acceso)
      },
      --
      txt_filename="ui-dvr-XXX.lxml",		-- ojo, variable establecida tras hacer login (depende de access_level)
   },
   --
   lxml_script = {
      mod_new="cmscript",
      depends = {
	 interpreter    = "cflua",
	 script_text    = "lxml_textbuffer",
	 --
	 sds            = "sds",
	 xml_textbuffer = "xml",
      },
   },
   xml2store = {
      mod_new="xml2tslibxml2",
      depends = {
	 model_obj   = "store",
	 pixbufs_obj = "pixbufs",
	 textbuffer  = "xml",
	 _ = "lxml_script",                  -- El script genera dinÃ¡micamente el XML.
      },
   },
   -------------------------------------
   script_text = {
      mod_new="cmtextbuffer",
      --
      txt_filename="script-gtk2ui-dvr.lua",
   },
   --
   script = {
      mod_new="cmscript",
      depends = {
	 interpreter     = "cflua",
	 script_text     = "script_text",
	 --
	 container       = "ui",
	 pixbufs         = "pixbufs",
	 xml2store       = "xml2store",
	 sds             = "sds",
	 params          = "infoview_cfg",
	 alarms          = "alarms",
	 heventos        = "heventos",
	 enum_void       = "enum_void",
	 enum_severity   = "enum_AlarmCfgSeverity",
	 enum_notificationlang = "enum_NotificationLang",
	 enum_notification = "enum_AlarmCfgNotification",
	 enum_timezone = "enum_TimeZone",
	 --- modbus
	 enum_baudrate   = "enum_MBBaudrate",
	 enum_parity     = "enum_MBParity",
	 enum_mode       = "enum_MBMode",
	 --
	 enum_sino       = "enum_SiNo",
	 _               = "treeview",  -- new
	 loginui2        = "loginui2",
      },
      --
   },
   -------------------------------------
   -- Estado
   -------------------------------------
   treeview = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "store",
	 _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_estado_tree",
      columns = columns_treeview,

      visible_column = "node-visible",
      visible_rules = {
	 ["1"] = { type = "node", },
      },
      root_rules = {
	 ["1"] = { name = "Estado", },  -- i18n
      },
   },
   --
   infoview = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "store",
	 master = "treeview",
	 _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_estado",
      columns = columns_infoview,

      visible_column = "var-visible",
      visible_rules = {
	 --["1"] = { type = "var", edit = "0", }, --solo si estado y param de un mismo nodo
	 ["1"] = { type = "var", },
      },
   },
   -------------------------------------
   -- Parametros
   -------------------------------------
   treeview_cfg = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "store",
	 _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_param_tree",
      columns = columns_treeview,

      visible_column = "node-visible",
      visible_rules = {
	 ["1"] = { type = "node", },
      },
      root_rules = {
	 ["1"] = { name = "Parametros", },  -- i18n
      },
   },
   --
   infoview_cfg = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "store",
	 master = "treeview_cfg",
	 _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_param",
      columns = columns_infoview,

      --visible_column = "param-visible", --solo si estado y param de un mismo nodo
      visible_column = "var-visible",
      visible_rules = {
	 --["1"] = { type = "var", edit = "1", }, --solo si estado y param de un mismo nodo
	 ["1"] = { type = "var", },
      },
   },
   -------------------------------------
   -- Alarmas
   -------------------------------------
   alarms_store = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado.
      },
      --
      columns = columns_alarms,
   },
   alarms = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "alarms_store",
	 -- _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_eventos",
      columns = columns_alarms_view,
      sort_column = "time",
      sort_order  = GTK_SORT_DESCENDING,

--       visible_column = "var-visible",
--       visible_rules = {
-- 	 ["1"] = { type = "var", },
--       },
   },
   -------------------------------------
   -- H. Eventos
   -------------------------------------
   heventos_store = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado.
      },
      --
      columns = columns_heventos, -- Mismas columnas que alarmas
   },
   heventos = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "heventos_store",
	 -- _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_heventos",
      columns = columns_heventos_view,
      sort_column = "time",
      sort_order  = GTK_SORT_DESCENDING,
   },
   -------------------------------------
   -- H. Eventos de Hueco
   -------------------------------------
   gaplog_st = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado.
      },
      --
      columns = columns_gaplog_st,
   },
   gaplog_vw = {
      mod_new="gtk2treeview",
      depends = {
	 container_obj = "ui",
	 model_obj = "gaplog_st",
	 -- _ = "xml2store",
      },
      --
      container_name = "scrolledwindow_huecos",
      columns = columns_gaplog_vw,
      sort_column = "time",
      sort_order  = GTK_SORT_DESCENDING,
   },
   -------------------------------------
   -- Enumerados
   -------------------------------------
   enum_void = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_AlarmCfgSeverity = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_NotificationLang = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_AlarmCfgNotification = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_TimeZone = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   --- modbus
   enum_MBBaudrate = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_MBParity = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_MBMode = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },
   enum_SiNo = {
      mod_new="gtk2treestore",
      depends = {
	 _ = "mainwin", -- requiere gtk inicializado
      },
      --
      columns = columns_enum,
   },

   -------------------------------------
   -- Login
   -------------------------------------
   loginui = {
      mod_filename="dvrgtk2",
      mod_new="gtk2gladelo",
      --
      layout_filename="ui-dvr-1024x600.glade",
      layout_root = "window2",
   },
   loginscript_text = {
      mod_new="cmtextbuffer",
      --
      text = [[
local main_loop=gobject.main_loop_new(nil, true)

--zkbd=io.open("/proc/zigor/zkbd", "w")
zkbd=io.open("/dev/kbde", "w")

-- intento ocultar cursor en display local (Xfbdev) en pantalla de login (uso xsetroot -cursor)
os.execute("/usr/local/zigor/activa/tools/hide_cursor.sh")

local login_button=gobject.get_data(loginui, "login_button")
local login_entry =gobject.get_data(loginui, "login_entry")
--local logo        =gobject.get_data(loginui, "image2")
local sb          =gobject.get_data(loginui, "statusbar2")
local w_toggle_bt   =gobject.get_data(loginui, "tbtkb1")

local nivel_str=_g("Nivel:")
local w_label_nivel = gobject.get_data(loginui, "label56")
gobject.set_property(w_label_nivel, "label", nivel_str)

gobject.set_property(w_toggle_bt, "visible", false)
--gobject.set_property(logo, "pixbuf", gobject.get_data(pixbufs, "logo") )
local top_id=gtk.statusbar_push(sb, "login", _g("Introduce password"))
local login_fallidos = 0

local function login_handler()

   local password=gobject.get_property(login_entry, "text")
   local level_entry =gobject.get_data(loginui, "comboboxentry2")
   local level_entry_text = gtk.bin_get_child(level_entry)
   local salt = gobject.get_property(level_entry_text, "text")
   print("Sal en remoto = " .. salt)

   gobject.set_property(sds, "community", "zadmin")

   local estado_bloqueo = access.get(sds, zigorCtrlLoginBlocked .. ".0")
   if estado_bloqueo == 1 then
        -- el acceso se encuentra bloqueado. Lo mostramos en la barra de estado del login.
        gtk.statusbar_push(sb, "login", _g("Acceso temporalmente bloqueado"))
        return --salimos sin mas. No se puede acceder
   end

   -- comprobar "password" vÃ¡lido
   require "oids-parameter"

   local tabla_pass_id=gtk.statusbar_push(sb, "login", _g("Comprobando password..."))
   gtk.main_iteration_do(FALSE);
   i=1
   local pass_key = accessx.getnextkey(sds, zigorSysPasswordPass)
   print("pass_key en remoto = ", pass_key)
   local sha1 = require 'sha1'
   local valor_salado = password .. salt
   print("valor_salado en remoto = " .. valor_salado)
   local valor_hasheado = sha1.hex(valor_salado)
   print("valor_hasheado en remoto = " .. valor_hasheado)

   while( pass_key and is_substring(pass_key, zigorSysPasswordPass) and pass_key~=zigorSysPasswordPass ) do
      local get_pass_id=gtk.statusbar_push(sb, "login", _g("Comprobando acceso nivel").. tostring(i) .."...")
      gtk.main_iteration_do(FALSE);
      local pass=access.get(sds, pass_key)
      gtk.statusbar_pop(sb, "login", get_pass_id)
      gtk.main_iteration_do(FALSE);

      -- Comprobar si es el nuestro
      -- if pass and pass==password then
      if pass and pass==valor_hasheado then
	 -- extraer el id (nÃºmero de instancia) para saber el nivel de acceso
	 -- (NOTA: access_level es global y numÃ©rica)
	 _,_,access_level=string.find(pass_key, "%.(%d+)$")
	 access_level_key=pass  -- XXX
	 access_level=tonumber(access_level)
	-- ojo, ahora actualizar parametros de objetos que no se hayan creado y dependan de access_level
	ags.lxml_textbuffer.txt_filename = "ui-dvr-" .. tostring(access_level) .. ".lxml"
	--
	 gobject.main_loop_quit(main_loop)
	 -- eliminar ventana de login
	 local loginwindow=gobject.get_data(loginui, "window2")
	 gtk.object_destroy(loginwindow)

	 zkbd:close()
        login_fallidos = 0
	 return
      end

      i=i+1
      pass_key = accessx.getnextkey(sds, pass_key)
   end
   gtk.statusbar_pop(sb, "login", tabla_pass_id)

   gtk.statusbar_pop(sb, "login", top_id)
   gobject.set_property(login_entry, "text", "")
   login_fallidos = login_fallidos + 1
   local max_intentos = access.get(sds, zigorSysPassRetries..".0")
   print("login_fallidos_remotos = " .. login_fallidos)
   print("max_intentos_remotos = " .. max_intentos)
   if login_fallidos == max_intentos then
       top_id=gtk.statusbar_push(sb, "login", _g("Acceso temporalmente bloqueado"))
       access.set(sds, zigorCtrlLoginBlocked .. ".0", 1)
   else
        top_id=gtk.statusbar_push(sb, "login", _g("Error, introduce password"))
   end
end

-- Gestion del login!
gobject.connect(login_button, "clicked", login_handler)

--- GUI keyboard > simplemente ocultar teclas ya q no usar al ser solo en remoto
local w_hbtbox1kb1 = gobject.get_data(loginui, "hbtbox1kb1")
local w_hbtbox2kb1 = gobject.get_data(loginui, "hbtbox2kb1")
local w_hbtbox3kb1 = gobject.get_data(loginui, "hbtbox3kb1")
local w_hbtbox4kb1 = gobject.get_data(loginui, "hbtbox4kb1")
local function enable_kb1(enable)
   gobject.set_property(w_hbtbox1kb1, "visible", enable)
   gobject.set_property(w_hbtbox2kb1, "visible", enable)
   gobject.set_property(w_hbtbox3kb1, "visible", enable)
   gobject.set_property(w_hbtbox4kb1, "visible", enable)
end
enable_kb1(false)
------

-- Tratamiento cliente local > autologin!
if remote==0 then
   --print("login local")
   local loginwindow=gobject.get_data(loginui, "window2")
   gtk.object_destroy(loginwindow)

   access_level = os.getenv("ACCESS_LEVEL")
   access_level=tonumber(access_level)
   gobject.set_property(sds, "community", "zadmin")  -- XXX
   access_level_key = access.get(sds, zigorSysPasswordPass.."."..tostring(access_level))
   --print("access_level / access_level_key", access_level, access_level_key)
   gobject.set_property(sds, "community", access_level_key)
   ags.lxml_textbuffer.txt_filename = "ui-dvr-" .. tostring(access_level) .. ".lxml"
else
   gobject.main_loop_run(main_loop)  -- main_loop!
end
]],
   },
   --
   loginscript = {
      mod_new="cmscript",
      depends = {
	 interpreter     = "cflua",
	 script_text     = "loginscript_text",
	 --
	 pixbufs = "pixbufs",
	 loginui = "loginui",
	 sds     = "sds",
	 _ = "keysnooper",
      },
      --
   },
   --
   loginui2 = {
      --mod_filename="dvrgtk2",
      mod_new="gtk2gladelo",
      layout_filename="ui-dvr-1024x600.glade",
      layout_root = "window3",
   },
   -------------------------------------
   --
   -- Watchdog
   --
   --[[
   watchdog = {
      mod_new = "cmwatchdog",
      depends = {
      },
      -- ConfiguraciÃ³n mÃ³dulo
      wd_filename =   "/dev/watchdog",			-- nombre del dispositivo
      pid_filename =  "/var/log/dvr-gtk2ui.log",	-- nombre del fichero de log con pid
      refresh_time = 10000,				-- tiempo en ms entre llamadas de refresco
      expiration_time = 100,				-- tiempo en s para llamada ioctl
   },
   --]]
   -------------------------------------

}
