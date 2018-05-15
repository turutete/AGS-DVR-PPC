-- IMPORTANTE: ESTE FICHERO ESTÁ EN UTF-8

require "parameter"
   
-- Configuración de edición
-- para cada parámetro:
-- check(entrada, check_args) se llama para saber si entrada (in)válida (retorna verdadero si válida)
-- null es verdadero si se permite establecer a cadena ""
-- hide es verdadero si se quiere ocultar en edición (p.e. passwords)
-- format(entrada) se llama para formatear la entrada antes de hacer el "set"
-- XXX usar ',' o '.' en función de locale en regexp.
local edit_config_dvr = {
   [zigorSysName]       = {
      check = check_string,
      check_args = { len=255, }, },
   [zigorSysDescr]      = {
      check = check_string,
      check_args = { len=255, }, },
   [zigorSysLocation]   = {
      check = check_string,
      check_args = { len=255, }, },
   [zigorSysContact]    = {
      check = check_string,
      check_args = { len=255, }, },
   [zigorSysCode]       = {
      check = check_string,
      check_args = { re="%d%d%d%d%d%d", }, },
   [zigorSysVersion]    = {
      check = check_string,
      check_args = { len=255, }, },
   
   [zigorNetIP] = {
      check = check_ip,
   },
   [zigorNetMask] = {
      check = check_ip,
   },
   [zigorNetGateway] = {
      check = check_ip,
   },
   [zigorDialUpPin] = {
      check = check_string, -- XXX
      check_args = { re="%d%d%d%d", },
      --hide = "#",
      hide = "*",
      null = true,
   },
   [zigorDialUpSmsNum1] = {
      check = check_string,
      check_args = { len=255, re="[%d%+%*%#]*", },
      null = true,
   },
   [zigorDialUpSmsNum2] = {
      check = check_string,
      check_args = { len=255, re="[%d%+%*%#]*", },
      null = true,
   },
   [zigorDialUpSmsNum3] = {
      check = check_string,
      check_args = { len=255, re="[%d%+%*%#]*", },
      null = true
   },
   [zigorDialUpSmsNum4] = {
      check = check_string,
      check_args = { len=255, re="[%d%+%*%#]*", },
      null = true
   },
   
   [zigorSysPasswordPass] = {
      check = check_string, -- XXX
      check_args = {},
      hide = true,
   },
   [zigorSysDate..".0"] = {
      check = check_date,
      check_args = { 
	 re="^(%d%d)/(%d%d)/(%d%d%d%d) *(%d%d):(%d%d):(%d%d)$", 
	 fields={ day=1, month=2, year=3, hour=4, min=5, sec=6, }, },
      format = format_date,
      format_args = {
	 re="^(%d%d)/(%d%d)/(%d%d%d%d) *(%d%d):(%d%d):(%d%d)$", 
	 fields={ day=1, month=2, year=3, hour=4, min=5, sec=6, }, },
   },
   [zigorAlarmCfgSeverity] = {
      check = check_enum,
   },
   [zigorSysTimeZone] =  {
      check = check_enum, 
      check_args = {}, },

   [zigorSysNotificationLang] = {
      check = check_enum,
      check_args = {}, },

   ---
   [zigorSysBacklightTimeout] = {
      check = check_number,
      check_args = {min=0, max=65535}, },

   [zigorSysLogoutTimeout] = {
      check = check_number,
      check_args = {min=0, max=65535}, },
   ---

   [zigorNetPortVnc] =  {
      check = check_number, 
      check_args = {min=0, max=65535}, },
   [zigorNetPortHttp] =  {
      check = check_number, 
      check_args = {min=0, max=65535}, },

   [zigorNetDNS] = {
      check = check_ip,
      null = true,
   },
   [zigorNetEmail1 .. ".0"] = {
      check = check_string,
      --check_args = { len=100, re="[%w%p]+@[%w%p]+%.[%w%p]+", },
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },
   [zigorNetEmail2 .. ".0"] = {
      check = check_string,
      --check_args = { len=100, re="[%w%p]+@[%w%p]+%.[%w%p]+", },
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },
   [zigorNetEmail3 .. ".0"] = {
      check = check_string,
      --check_args = { len=100, re="[%w%p]+@[%w%p]+%.[%w%p]+", },
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },
   [zigorNetEmail4 .. ".0"] = {
      check = check_string,
      --check_args = { len=100, re="[%w%p]+@[%w%p]+%.[%w%p]+", }, 
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },

   [zigorNetSmtp] = {
      check = check_string,
      check_args = { len=100, },
      null = true, },
   [zigorNetSmtpUser] = {
      check = check_string,
      check_args = { len=100, },
      null = true, },
   [zigorNetSmtpPass] = {
      check = check_string,
      check_args = { len=100, },
      hide = "*",
      null = true, },
   [zigorNetSmtpEmail .. ".0"] = {
      check = check_string,
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },
   [zigorNetSmtpAuth] = {
      check = check_string,
      check_args = { len=100, },
      null = true, },
   [zigorNetSmtpTest .. ".0"] = {
      check = check_string,
      check_args = { len=100, re="[%w%p]+[@%*][%w%p]+%.[%w%p]+", },  -- ojo se admiten tanto * como @ (Uso de * por pb introduccion @ en gtk!)
      format = format_email,  -- para incluir el @ por el *
      null = true, },
   [zigorNetVncPassword .. ".0"] = {
      check = check_string,
      check_args = { len=100, },
      hide = "*",
      null = true,
   },
   [zigorNetEnableSnmp .. ".0"] = {
      check = check_enum,
      check_args = {},
   },
   ---
   [zigorDvrParamVRedNom] = {
      check = check_number,
      --check_args = {factor=10, min=0, max=2500}, },
      check_args = {factor=10, min=0, max=1000000}, },
   [zigorDvrParamVMinDVR] = {
      check = check_number,
      check_args = {factor=10, min=0, max=2300}, },
   [zigorDvrParamNumEquipos] = {
      check = check_number,
      check_args = {min=1, max=5}, },
   [zigorDvrParamFactor] = {
      check = check_number,
      check_args = {factor=1000, min=0, max=1000000}, },
   [zigorDvrParamFrecNom] = {
      check = check_number,
      check_args = {factor=10, min=500, max=600}, },

   --- modbus
   [zigorModbusAddress] =  {
      check = check_number, 
      check_args = {min=1, max=247}, },
   [zigorModbusBaudrate] =  {
      check = check_enum, 
      check_args = {}, },
   [zigorModbusParity] =  {
      check = check_enum, 
      check_args = {}, },
   [zigorModbusMode] =  {
      check = check_enum, 
      check_args = {}, },
   [zigorModbusTCPPort] =  {
      check = check_number, 
      check_args = {min=1, max=65535}, },
   [zigorModbusTCPTimeout] =  {
      check = check_number, 
      check_args = {min=1, max=65535}, },
   ---
   [zigorCtrlParamDemo] =  {
      check = check_enum,
      check_args = {},
   },
}

return edit_config_dvr
