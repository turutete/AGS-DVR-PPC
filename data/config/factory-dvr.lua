require "oids-dvr"
require "oids-parameter"
require "oids-alarm"
require "oids-alarm-log"

require "functions"  -- i18n

local param = {
   --
   -- Parámetros generales
   --
   -- ParamSystem
   [ zigorSysName ..  ".0"          ] = "",
   [ zigorSysDescr .. ".0"          ] = "",
   [ zigorSysLocation .. ".0"       ] = "Paris",
   [ zigorSysContact .. ".0"        ] = "Schneider@SE.com",
   -- Password de "usuario basico" (solo lectura)
   [ zigorSysPasswordIndex .. ".1"  ] = 1,
   [ zigorSysPasswordPass .. ".1"   ] = "1234",
   [ zigorSysPasswordDescr .. ".1"  ] = _g("Password de usuario basico."),
   -- Password de "usuario" (lectura/escritura)
   [ zigorSysPasswordIndex .. ".2"  ] = 2,
   [ zigorSysPasswordPass .. ".2"   ] = "4231",
   [ zigorSysPasswordDescr .. ".2"  ] = _g("Password de usuario avanzado."),
   -- Password de "mantenimiento" (lectura/escritura)
   [ zigorSysPasswordIndex .. ".3"  ] = 3,
   [ zigorSysPasswordPass .. ".3"   ] = "0212",
   [ zigorSysPasswordDescr .. ".3"  ] = _g("Password de zms."),
   -- Password de "administrador" (lectura y escritura)
   [ zigorSysPasswordIndex .. ".4"  ] = 4,
   [ zigorSysPasswordPass .. ".4"   ] = "7788",
   [ zigorSysPasswordDescr .. ".4"  ] = _g("Password de administrador."),
   --
   [ zigorSysCode .. ".0"           ] = "000000",
   [ zigorSysTimeZone .. ".0"       ] = 354,  -- Europe/Madrid
   [ zigorSysVersion .. ".0"        ] = "DVR-1.2.8-SE-NC",
   [ zigorSysNotificationLang .. ".0" ] = 1,  -- en
   --
   [ zigorSysBacklightTimeout .. ".0" ] = 5,  -- minutes
   [ zigorSysLogoutTimeout .. ".0"  ] = 5,  -- minutes
   ---
   -- ParamNet
   [ zigorNetIP .. ".0"             ] = "192.168.4.13",
   [ zigorNetMask .. ".0"           ] = "255.255.0.0",
   [ zigorNetGateway .. ".0"        ] = "192.168.3.254",
--   [ zigorNetPortVnc .. ".0"        ] = "5901",
--   [ zigorNetPortHttp .. ".0"       ] = "80",
   [ zigorNetPortVnc .. ".0"        ] = 5901,
   [ zigorNetPortHttp .. ".0"       ] = 80,
   [ zigorNetDNS .. ".0"            ] = "",
   [ zigorNetSmtp .. ".0"           ] = "",
   [ zigorNetSmtpUser .. ".0"       ] = "",
   [ zigorNetSmtpPass .. ".0"       ] = "",
   [ zigorNetSmtpEmail .. ".0"      ] = "",
   [ zigorNetSmtpAuth .. ".0"       ] = "",
   [ zigorNetSmtpTest .. ".0"       ] = "",
   [ zigorNetEmail1 .. ".0"         ] = "",
   [ zigorNetEmail2 .. ".0"         ] = "",
   [ zigorNetEmail3 .. ".0"         ] = "",
   [ zigorNetEmail4 .. ".0"         ] = "",
   [ zigorNetVncPassword .. ".0"    ] = "",
   [ zigorNetEnableSnmp .. ".0"     ] = 2, -- Deshabilitado por defecto
   [ zigorNetEnableSSH .. ".0"     ] = 2, -- Deshabilitado por defecto?
   -- ParamDialUp
   [ zigorDialUpPin .. ".0"         ] = "",
   [ zigorDialUpSmsNum1 .. ".0"     ] = "",
   [ zigorDialUpSmsNum2 .. ".0"     ] = "",
   [ zigorDialUpSmsNum3 .. ".0"     ] = "",
   [ zigorDialUpSmsNum4 .. ".0"     ] = "",
   -- modbus
   [ zigorModbusAddress .. ".0"          ] = 1, -- 1..247
   [ zigorModbusBaudrate .. ".0"         ] = 3,  -- 38400
   [ zigorModbusParity .. ".0"           ] = 2,  -- Par
   [ zigorModbusMode .. ".0"             ] = 1,  -- RTU
   [ zigorModbusTCPPort .. ".0"          ] = 502,  -- default port of modbus
   [ zigorModbusTCPTimeout .. ".0"       ] = 600,  -- timeout en segundos
   --
   [ zigorCtrlParamDemo .. ".0"     ] = 2,  -- desactivado por defecto
   --
   -- Parámetros particulares
   --
   [ zigorDvrParamVRedNom .. ".0"	] = 4000,  -- 0.1
   [ zigorDvrParamVMinDVR .. ".0"	] = 1380,  -- 0.1
   [ zigorDvrParamNumEquipos .. ".0"	] = 1,
   [ zigorDvrParamFactor .. ".0"	] = 1000,  -- 0.001
   [ zigorDvrParamFrecNom .. ".0"	] = 500,   -- 0.1
   [ zigorDvrParamHuecoNom .. ".0"      ] = 40,

   --
   -- Configuración de alarmas
   --
   [ zigorAlarmCfgId .. ".1"              ] = 1,
   [ zigorAlarmCfgDescr .. ".1"           ] = zigorAlarmaStart,
   [ zigorAlarmCfgSeverity .. ".1"        ] = AlarmSeverityLEVE,
   [ zigorAlarmCfgNotification .. ".1"    ] = AlarmNotificationNOSMS,
   ---
   [ zigorAlarmCfgId .. ".2"              ] = 2,
   [ zigorAlarmCfgDescr .. ".2"           ] = zigorAlarmaErrorVInst,
   [ zigorAlarmCfgSeverity .. ".2"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".2"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".3"              ] = 3,
   [ zigorAlarmCfgDescr .. ".3"           ] = zigorAlarmaSaturado,
   [ zigorAlarmCfgSeverity .. ".3"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".3"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".4"              ] = 4,
   [ zigorAlarmCfgDescr .. ".4"           ] = zigorAlarmaVBusMax,
   [ zigorAlarmCfgSeverity .. ".4"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".4"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".5"              ] = 5,
   [ zigorAlarmCfgDescr .. ".5"           ] = zigorAlarmaVCondMax,
   [ zigorAlarmCfgSeverity .. ".5"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".5"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".6"              ] = 6,
   [ zigorAlarmCfgDescr .. ".6"           ] = zigorAlarmaVBusMin,
   [ zigorAlarmCfgSeverity .. ".6"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".6"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".7"              ] = 7,
   [ zigorAlarmCfgDescr .. ".7"           ] = zigorAlarmaVRed,
   [ zigorAlarmCfgSeverity .. ".7"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".7"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".8"              ] = 8,
   [ zigorAlarmCfgDescr .. ".8"           ] = zigorAlarmaLimitIntVSal,
   [ zigorAlarmCfgSeverity .. ".8"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".8"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".9"              ] = 9,
   [ zigorAlarmCfgDescr .. ".9"           ] = zigorAlarmaDriver,
   [ zigorAlarmCfgSeverity .. ".9"        ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".9"    ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".10"             ] = 10,
   [ zigorAlarmCfgDescr .. ".10"          ] = zigorAlarmaParadoError,
   [ zigorAlarmCfgSeverity .. ".10"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".10"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".11"             ] = 11,
   [ zigorAlarmCfgDescr .. ".11"          ] = zigorAlarmaErrorDriver,
   [ zigorAlarmCfgSeverity .. ".11"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".11"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".12"             ] = 12,
   [ zigorAlarmCfgDescr .. ".12"          ] = zigorAlarmaErrorTermo,
   [ zigorAlarmCfgSeverity .. ".12"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".12"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".13"             ] = 13,
   [ zigorAlarmCfgDescr .. ".13"          ] = zigorAlarmaLimitando,
   [ zigorAlarmCfgSeverity .. ".13"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".13"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".14"             ] = 14,
   [ zigorAlarmCfgDescr .. ".14"          ] = zigorAlarmaPLL,
   [ zigorAlarmCfgSeverity .. ".14"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".14"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".15"             ] = 15,
   [ zigorAlarmCfgDescr .. ".15"          ] = zigorAlarmaErrorComDSP,
   [ zigorAlarmCfgSeverity .. ".15"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".15"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".16"             ] = 16,
   [ zigorAlarmCfgDescr .. ".16"          ] = zigorAlarmaStatusChange,
   [ zigorAlarmCfgSeverity .. ".16"       ] = AlarmSeverityLEVE,
   [ zigorAlarmCfgNotification .. ".16"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".17"             ] = 17,
   [ zigorAlarmCfgDescr .. ".17"          ] = zigorAlarmaTemperaturaAlta,
   [ zigorAlarmCfgSeverity .. ".17"       ] = AlarmSeverityGRAVE,
   [ zigorAlarmCfgNotification .. ".17"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".18"             ] = 18,
   [ zigorAlarmCfgDescr .. ".18"          ] = zigorAlarmaPasswdChange,
   [ zigorAlarmCfgSeverity .. ".18"       ] = AlarmSeverityLEVE, -- XXX
   [ zigorAlarmCfgNotification .. ".18"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgNotification .. ".18"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgId .. ".19"             ] = 19,
   [ zigorAlarmCfgDescr .. ".19"          ] = zigorAlarmaSagRecorded,
   [ zigorAlarmCfgSeverity .. ".19"       ] = AlarmSeverityLEVE, -- XXX
   [ zigorAlarmCfgNotification .. ".19"   ] = AlarmNotificationNOSMS,
   [ zigorAlarmCfgNotification .. ".19"   ] = AlarmNotificationNOSMS,
   --
   [ zigorAlarmsCfgPresent .. ".0"        ] = 19,
   [ zigorAlarmLogMaxEntries .. ".0"      ] = 100, -- XXX

   [ zigorDvrGapLogMaxEntries .. ".0"     ] = 100, -- XXX gaplog
}

return param
