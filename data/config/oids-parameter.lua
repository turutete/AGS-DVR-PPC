require "oids-zigor"

zigorParameter = zigorExperiment .. ".3"

-- Par�metros
zigorParamSystem   = zigorParameter .. ".1"
zigorSysName       = zigorParamSystem .. ".1"
zigorSysDescr      = zigorParamSystem .. ".2"
zigorSysLocation   = zigorParamSystem .. ".3"
zigorSysContact    = zigorParamSystem .. ".4"
zigorSysPasswordTable = zigorParamSystem .. ".5"
zigorSysPasswordEntry = zigorSysPasswordTable .. ".1"
zigorSysPasswordIndex = zigorSysPasswordEntry .. ".1"
zigorSysPasswordPass  = zigorSysPasswordEntry .. ".2"
zigorSysPasswordDescr = zigorSysPasswordEntry .. ".3"
zigorSysCode       = zigorParamSystem .. ".6"
zigorSysVersion    = zigorParamSystem .. ".7"
zigorSysDate       = zigorParamSystem .. ".8"
zigorSysTimeZone   = zigorParamSystem .. ".9"
zigorSysNotificationLang = zigorParamSystem .. ".10"
zigorSysBacklightTimeout = zigorParamSystem .. ".11"
zigorSysLogoutTimeout = zigorParamSystem .. ".12"
--
zigorParamNet = zigorParameter .. ".2"
zigorNetIP = zigorParamNet .. ".1"
zigorNetMask = zigorParamNet .. ".2"
zigorNetGateway = zigorParamNet .. ".3"
zigorNetPortVnc = zigorParamNet .. ".4"
zigorNetPortHttp = zigorParamNet .. ".5"
zigorNetDNS = zigorParamNet .. ".6"
zigorNetEmail1 = zigorParamNet .. ".7"
zigorNetEmail2 = zigorParamNet .. ".8"
zigorNetEmail3 = zigorParamNet .. ".9"
zigorNetEmail4 = zigorParamNet .. ".10"
zigorNetSmtp = zigorParamNet .. ".11"
zigorNetSmtpUser = zigorParamNet .. ".12"
zigorNetSmtpPass = zigorParamNet .. ".13"
zigorNetSmtpEmail = zigorParamNet .. ".14"
zigorNetSmtpAuth = zigorParamNet .. ".15"
zigorNetSmtpTest = zigorParamNet .. ".16"
zigorNetVncPassword = zigorParamNet .. ".17"
zigorNetEnableSnmp = zigorParamNet .. ".18"
zigorNetEnableSSH = zigorParamNet .. ".19"
zigorNetEnableEthernet = zigorParamNet .. ".20"
zigorNetEnableHTTP = zigorParamNet .. ".21"
zigorNetEnableVNC = zigorParamNet .. ".22"
--
zigorParamDialUp = zigorParameter .. ".3"
zigorDialUpPin = zigorParamDialUp .. ".1"
zigorDialUpSmsNum1 = zigorParamDialUp .. ".2"
zigorDialUpSmsNum2 = zigorParamDialUp .. ".3"
zigorDialUpSmsNum3 = zigorParamDialUp .. ".4"
zigorDialUpSmsNum4 = zigorParamDialUp .. ".5"
--
zigorParamControl = zigorParameter .. ".4"
zigorCtrlParamState = zigorParamControl .. ".1"
zigorCtrlParamDemo  = zigorParamControl .. ".2"

-- modbus
zigorParamModbus = zigorParameter .. ".5"
zigorModbusAddress  = zigorParamModbus..".1"
zigorModbusBaudrate = zigorParamModbus..".2"
zigorModbusParity   = zigorParamModbus..".3"
zigorModbusMode     = zigorParamModbus..".4"
zigorModbusTCPPort  = zigorParamModbus..".5"
zigorModbusTCPTimeout = zigorParamModbus..".6"
