-- IMPORTANTE: ESTE FICHERO ESTÁ EN UTF-8

require "oids-dvr"
require "oids-alarm"
require "display-timezone"

--
-- displays para tablas de alarma e histórico
--
displays_dvr = {
   display_descr = {
      [ zigorAlarmaStart           ] = { codigo = "00", display = _g("Inicio sistema"), }, -- XXX
      [ zigorAlarmaPasswdChange    ] = { codigo = "01", display = _g("Cambio de password"), },-- XXX
      [ zigorAlarmaSagRecorded     ] = { codigo = "02", display = _g("Hueco registrado"), },

      --
      [ zigorAlarmaErrorVInst      ] = { codigo = "10", display_lcd = _g("ErrorVInst","Maximum 16 characters & ASCII only"),	display = _g("Error tensión instantánea"),	display_sms = _g("<Error tension instantanea>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaSaturado        ] = { codigo = "11", display_lcd = _g("Sobrecarga","Maximum 16 characters & ASCII only"),	display = _g("Sobrecarga"),		display_sms = _g("<Sobrecarga>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaVBusMax         ] = { codigo = "12", display_lcd = _g("VBusMax","Maximum 16 characters & ASCII only"),        display = _g("Tensión de bus máxima"),		display_sms = _g("<Tension de bus maxima>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaVCondMax        ] = { codigo = "13", display_lcd = _g("VCondMax","Maximum 16 characters & ASCII only"),	display = _g("Tensión de condensador máxima"),		display_sms = _g("<Tension de condensador maxima>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaVBusMin         ] = { codigo = "14", display_lcd = _g("VBusMin","Maximum 16 characters & ASCII only"),		display = _g("Tensión de bus mínima"),		display_sms = _g("<Tension de bus minima>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaVRed            ] = { codigo = "15", display_lcd = _g("FalloVRed","Maximum 16 characters & ASCII only"),	display = _g("Fallo tensión de red"),		display_sms = _g("<Fallo tension de red>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaLimitIntVSal    ] = { codigo = "16", display_lcd = _g("LimitIntVSal","Maximum 16 characters & ASCII only"),	display = _g("Limitación integrador de tensión de salida"),	display_sms = _g("<Limitacion integrador de tension de salida>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaDriver          ] = { codigo = "17", display_lcd = _g("AlarmaDriver","Maximum 16 characters & ASCII only"),	display = _g("Alarma driver"),	display_sms = _g("<Alarma driver>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaParadoError     ] = { codigo = "18", display_lcd = _g("ParadoPorError","Maximum 16 characters & ASCII only"),	display = _g("Parado por error"),		display_sms = _g("<Parado por error>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaErrorDriver     ] = { codigo = "19", display_lcd = _g("ErrorDriver","Maximum 16 characters & ASCII only"),	display = _g("Error driver"),		display_sms = _g("<Error driver>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaErrorTermo      ] = { codigo = "20", display_lcd = _g("ErrorTermo","Maximum 16 characters & ASCII only"),	display = _g("Error termostato"),		display_sms = _g("<Error termostato>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaLimitando       ] = { codigo = "21", display_lcd = _g("Limitación de potencia interna","Maximum 16 characters & ASCII only"),	display = _g("Limitación de potencia interna"),		display_sms = _g("<Limitación de potencia interna>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaPLL             ] = { codigo = "23", display_lcd = _g("AlarmaPLL","Maximum 16 characters & ASCII only"),	display = _g("Alarma PLL"),		display_sms = _g("<Alarma PLL>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaErrorComDSP     ] = { codigo = "24", display_lcd = _g("Fallo Com.DSP","Maximum 16 characters & ASCII only"),	display = _g("Error de comunicación con DSP"), display_sms = _g("<Error de comunicacion con DSP>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaStatusChange    ] = { codigo = "25", display_lcd = _g("CambioEstado","Maximum 16 characters & ASCII only"),	display = _g("Cambio de estado"),		display_sms = _g("<Cambio de estado>","SMS characters only [GSM 03.38]"), },
      [ zigorAlarmaTemperaturaAlta ] = { codigo = "26", display_lcd = _g("Temperatura alta","Maximum 16 characters & ASCII only"),  display = _g("Alarma temperatura alta"),               display_sms = _g("<Temperatura alta>","SMS characters only [GSM 03.38]"), },
   },
   -- XXX en nuevo displays-alarm.lua ???
   display_imp = {
      default                      = { ["imp-display"] = "?",           },
      [ AlarmSeverityLEVE        ] = { ["imp-display"] = '<span background="blue"   weight="ultrabold" foreground="white"><tt>'.._g("   LEVE    ","11 characters wide [use blanks]")..'</tt></span>', },
      [ AlarmSeverityPERSISTENTE ] = { ["imp-display"] = '<span background="yellow" weight="ultrabold" foreground="black"><tt>'.._g("PERSISTENTE","11 characters wide [use blanks]")..'</tt></span>', },
      [ AlarmSeverityGRAVE       ] = { ["imp-display"] = '<span background="orange" weight="ultrabold" foreground="black"><tt>'.._g("   GRAVE   ","11 characters wide [use blanks]")..'</tt></span>', },
      [ AlarmSeveritySEVERA      ] = { ["imp-display"] = '<span background="red"    weight="ultrabold" foreground="white"><tt>'.._g("   SEVERA  ","11 characters wide [use blanks]")..'</tt></span>', },
   },
   display_imp_param = {
      default                      = { display = _g("?"),           },
      [ AlarmSeverityLEVE        ] = { display = _g("LEVE"),        },
      [ AlarmSeverityPERSISTENTE ] = { display = _g("PERSISTENTE"), },
      [ AlarmSeverityGRAVE       ] = { display = _g("GRAVE"),       },
      [ AlarmSeveritySEVERA      ] = { display = _g("SEVERA"),      },
   },
   display_hueco = {
      default  = { ["fase-display"] = "?" },
      [ 1 ]    = { ["fase-display"] = "R" },
      [ 2 ]    = { ["fase-display"] = "S" },
      [ 3 ]    = { ["fase-display"] = "T" },
   },
   display_EstadoControl = {
      -- Los estados son lo que envía el DSP + 1 (el DSP envía un 0 y se mapea al valor [1])
      default = { display = "?" },
      [ 1]    = { display = _g("OFF") },
      [ 2]    = { display = _g("Espera Carga"), display_lcd=_g("_Espera Carga_","Maximum 16 characters & ASCII only") },
      [ 3]    = { display = _g("Espera ON"), display_lcd=_g("_Espera ON_","Maximum 16 characters & ASCII only") },
      [ 4]    = { display = _g("ON") },
      [ 5]    = { display = _g("Sobrecarga"), display_lcd=_g("_Sobrecarga_","Maximum 16 characters & ASCII only") },
      [ 6]    = { display = _g("Fallo tensión instantánea"), display_lcd=_g("_Fallo V Inst_","Maximum 16 characters & ASCII only") },
      [ 7]    = { display = _g("Fallo de red"),	display_lcd=_g("_Fallo Red_","Maximum 16 characters & ASCII only") },
      [ 8]    = { display = _g("Tensión de bus mínima"), display_lcd=_g("_V Bus Minima_","Maximum 16 characters & ASCII only") },
      [ 9]    = { display = _g("Hueco máximo"),	display_lcd=_g("_Hueco Maximo_","Maximum 16 characters & ASCII only") },
      [10]    = { display = _g("Alarma driver"),	display_lcd=_g("_Alarma Driver_","Maximum 16 characters & ASCII only") },
      [12]    = { display = _g("Alarma tensión de bus máxima"),        display_lcd=_g("_Alarma VBusMax_","Maximum 16 characters & ASCII only") },

      [16]    = { display = _g("Espera OFF"),	display_lcd=_g("_Espera OFF_","Maximum 16 characters & ASCII only") },
      [21]    = { display = _g("Error de precarga"),	display_lcd=_g("_Error precarga_","Maximum 16 characters & ASCII only") },
      [22]    = { display = _g("Error tensión de condensador"),	display_lcd=_g("_Error VCond_","Maximum 16 characters & ASCII only") },
      [23]    = { display = _g("Error tensión de bus máxima"),	display_lcd=_g("_Error VBusMax_","Maximum 16 characters & ASCII only") },
      [24]    = { display = _g("Error termostato"),		display_lcd=_g("_Error Termo_","Maximum 16 characters & ASCII only") },
      [25]    = { display = _g("Error driver"),		display_lcd=_g("_Error Driver_","Maximum 16 characters & ASCII only") },
      [26]    = { display = _g("Error Fusible / Error condensador AC"),		display_lcd=_g("_Error Fus/C-AC_","Maximum 16 characters & ASCII only") }, -- Error CON13
      [27]    = { display = _g("Error temperatura"),	display_lcd=_g("_Error Temp_","Maximum 16 characters & ASCII only") },
      [28]    = { display = _g("Error fusible"),                display_lcd=_g("_Error Fusible_","Maximum 16 characters & ASCII only") },
      [29]    = { display = _g("Error Condensador AC"),                display_lcd=_g("_Error Cond AC_","Maximum 16 characters & ASCII only") },
   },
   -- Mantener estas tablas sincronizadas con MIB (*)
   display_condicion = {
      { display=_g("Activación"),	display_sms=_g("<Activacion>","SMS characters only [GSM 03.38]"), },
      { display=_g("Desactivación"),	display_sms=_g("<Desactivacion>","SMS characters only [GSM 03.38]"), },
      { display=_g("Reconocida"),	display_sms=_g("<Reconocida>","SMS characters only [GSM 03.38]"), },
      { display=_g("Bloqueada"),	display_sms=_g("<Bloqueada>","SMS characters only [GSM 03.38]"), },
   },
   display_severidad = {
      { display=_g("Leve"),		display_sms=_g("<Leve>","SMS characters only [GSM 03.38]"), },
      { display=_g("Persistente"),	display_sms=_g("<Persistente>","SMS characters only [GSM 03.38]"), },
      { display=_g("GRAVE"),		display_sms=_g("<GRAVE>","SMS characters only [GSM 03.38]"), },
      { display=_g("SEVERA"),		display_sms=_g("<SEVERA>","SMS characters only [GSM 03.38]"), },
   },
   display_notification = {
      default                    = { display = _g("?"),  },
      [ AlarmNotificationSMS   ] = { display = _g("SI"), },
      [ AlarmNotificationNOSMS ] = { display = _g("NO"), },
   },
----------------------------------------
-- Definición de varios "displays"
-- un "display" es un mapeo de valores de variables, a valores de columnas.
--    DISPLAY_NAME = {
--       VAL | "default" = { COL_NUM = COL_NEWVAL, ... }
--       ...
--    }
display_CerradoAbierto_GR = {
   default = { display = _g("?"),       pic = "pb_gray",  },
   [1]     = { display = _g("Cerrado"), pic = "pb_green", },
   [2]     = { display = _g("Abierto"), pic = "pb_red",   },
},
display_AbiertoCerrado_RG = {
   default = { display = _g("?"),       pic = "pb_gray",  },
   [1]     = { display = _g("Abierto"), pic = "pb_red",   },
   [2]     = { display = _g("Cerrado"), pic = "pb_green", },
},
display_SiNo_GR = {
   default = { display = _g("?"),  pic = "pb_gray",  },
   [1]     = { display = _g("Si"), pic = "pb_green", },
   [2]     = { display = _g("No"), pic = "pb_red",   },
},
display_SiNo_RG = {
   default = { display = _g("?"),  pic = "pb_gray",  },
   [1]     = { display = _g("Si"), pic = "pb_red",   },
   [2]     = { display = _g("No"), pic = "pb_green", },
},
display_ActivoInact_RG = {
   default = { display = _g("?"),        pic = "pb_gray",  },
   [1]     = { display = _g("Activo"),   pic = "pb_red",   },
   [2]     = { display = _g("Inactivo"), pic = "pb_green", },
},
display_InactAct_RG = {
   default = { display = _g("?"),        pic = "pb_gray",  },
   [1]     = { display = _g("Inactivo"), pic = "pb_red",   },
   [2]     = { display = _g("Activo"),   pic = "pb_green", },
},
display_DesactAct_RG = {
   default = { display = _g("?"),           pic = "pb_gray",  },
   [1]     = { display = _g("Desactivado"), pic = "pb_red",   },
   [2]     = { display = _g("Activado"),    pic = "pb_green", },
},
display_ActDesact_GR = {
   default = { display = _g("?"),           pic = "pb_gray",  },
   [1]     = { display = _g("Activado"),    pic = "pb_green", },
   [2]     = { display = _g("Desactivado"), pic = "pb_red",   },
},
display_ActDesact_RG = {
   default = { display = _g("?"),           pic = "pb_gray",  },
   [1]     = { display = _g("Activado"),    pic = "pb_red",   },
   [2]     = { display = _g("Desactivado"), pic = "pb_green", },
},
display_MarchaParo_GR = {
   default = { display = _g("?"),      pic = "pb_gray",  },
   [1]     = { display = _g("Marcha"), pic = "pb_green", },
   [2]     = { display = _g("Paro"),   pic = "pb_red",   },
},
display_ParoMarcha_RG = {
   default = { display = _g("?"),      pic = "pb_gray",  },
   [1]     = { display = _g("Paro"),   pic = "pb_red",   },
   [2]     = { display = _g("Marcha"), pic = "pb_green", },
},
display_CtrlParamState = {
   default = { display = _g("?"),        },
   [1]     = { display = _g("Temporal"), pic = "pb_red",   },
   [2]     = { display = _g("Trabajo"),  pic = "pb_green", },
   [3]     = { display = _g("Fábrica"),  pic = "pb_gray",  },
},
display_PasswordPass = {
   default = { display = function(v)
			    return string.rep("*", string.len(v))
			 end, },
},
display_DialUpPin = {
   default = { display = function(v)
			    --return string.rep("#", string.len(v))
			    return string.rep("*", string.len(v))
			 end, },
},
display_Date = {
   default = { display = function(v) 
			    local tt=ZDateAndTime2timetable(v)
			    return os.date("%d/%m/%Y %H:%M:%S", os.time(tt))
			 end, },
},

display_NotificationLang = {
   default = { display = _g("?"),         locale="", },
   [ 1]    = { display = _g("Inglés"),   locale="en_GB.utf8", },
   [ 2]    = { display = _g("Chino"),     locale="zh_CN.utf8", },
   [ 3]    = { display = _g("Español"),  locale="", },
},

display_ModemStatus = {
   default = { display = _g("?"),       },
   [1]     = { display = _g("OCUPADO"), },
   [2]     = { display = _g("SIN TARJETA SIM"), },
   [3]     = { display = _g("ESPERA PIN"), },
   [4]     = { display = _g("ESPERA PUK (BLOQUEADO)"), },
   [5]     = { display = _g("LIBRE"), },
   [6]     = { display = _g("ERROR DE COMUNICACION"), },
   [7]     = { display = _g("CONECTADO"), },
},

display_TimeZone = display_timezone,

--- modbus
display_MBBaudrate = {
   default = { display = "?",      },
   [ 1]    = { display = "9600",   },
   [ 2]    = { display = "19200",  },
   [ 3]    = { display = "38400",  },
   [ 4]    = { display = "57600",  },
   [ 5]    = { display = "115200", },
},

display_MBParity = {
   default = { display = _g("?"),      },
   [ 1]    = { display = _g("Ninguna"),},
   [ 2]    = { display = _g("Par"),    },
   [ 3]    = { display = _g("Impar"),  },
},

display_MBMode = {
   default = { display = "?",   },
   [ 1]    = { display = "RTU", },
   [ 2]    = { display = "TCP", },
},
---

}

return displays_dvr
