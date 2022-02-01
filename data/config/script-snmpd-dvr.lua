require "objs-dvr" -- Define DA_* e ID_*
require "oids-dvr"
require "oids-parameter" --XXX
require "oids-alarm"
require "oids-alarm-log"
require "parameter" --XXX

require "alarmtable"
require "alarmlogtable"
require "alarms-dvr"

require "functions"  -- i18n

require 'sha1'

--- gaplog:
require "functions"
loadlualib("accessx")
---

loadlualib("access")
loadlualib("textbuffer")
loadlualib("bus")
loadlualib("bit")

-- forward declaration
local set_handler_id
local get_handler_id
local dsp_handler_id
local at -- XXX
local alt
local temp_timeout=nil
-- sms:
local sms_set
local sms_set_aux=0
--
local testmail=0
local testmail_init=1


----------------------------------------
-- "helpers" de carga de configuración
local function load_factory()
   return load_param("factory-dvr", sdscoreglib)
end
local function load_active()
   return load_param("active-dvr", sdscoreglib) or load_factory()
end


-- gaplog
----------------------------------------
----
-- "helpers"
----

-- jur
local function rev_t(itable)
   local t={}
   local length = #itable
   local i=0
   for k,v in ipairs(itable) do
      t[1+i]=itable[length-i]
      i=i+1
   end
   return t
end

-- jur (deprecated!)
local function update_gaplog_html(sds)
      package.loaded["gaplog-" .. profile] = nil -- Forzamos recarga desde disco
      local t=require ("gaplog-" .. profile)

      -- Implementar multi-idioma y OJO fichero debe ser utf8 para interpretar los acentos
      --(en este fichero de momento no hace falta multi-idioma)setlocale(sds)   -- require "functions" required.
      local displays = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
      local display_fase = displays.display_hueco

      t = rev_t(t)   -- ordenamos para que ultimas entradas primero

      -- estilos
      local style = [[
<style type="text/css">
.miestilo {
   border-style: none;
   background-color: white;
   font-family: Verdana, Sans-Serif;
   font-size: 0.8em;
}
.miestilo td {
   padding: 5px;
}
.miestilo .odd {
   background-color: #edffce;
}
.miestilo .even {
   background-color: white;
}
</style>
<table class="miestilo">
<theader>
   <th>[N.]</th><th>[Date]</th><th>[Minimum(%)]</th><th>[Average(%)]</th><th>[Duration(ms)]</th><th>[Phase]</th>
</theader>
<tbody>
]]
      local date, minimo, integral, tiempo, fase

      local fd=io.open("/home/user/gaplog.html", "w") -- XXX path y sufijo "hardcoded"
      fd:write("<html>\n<body>\n")
      fd:write(style)

      for i,gap in ipairs(t) do   -- ojo ipairs y no pairs
        date = os.date("%d/%m/%Y/%H:%M:%S", os.time(ZDateAndTime2timetable(gap["time"])))
        minimo=gap["minimo"]
        integral=gap["integral"]
        tiempo=gap["tiempo"]
        fase=display_fase[gap["fase"]]["fase-display"]

        local class
        if(i%2==1) then class='class="odd"' else class='class="even"' end
        fd:write('<tr '..class..'><td>'..i..'.</td><td>'..date..'</td><td>'..minimo..'</td><td>'..integral..'</td><td>'..tiempo..'</td><td>'..fase..'</td></tr>\n')
      end
      fd:write("</tbody></table>\n</body>\n</html>\n")
      fd:close()
end

local function create_log_html()
      local html = [[
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>SAG LOG</title>
</head>
<body>
<style type="text/css">
.miestilo {
   border-style: none;
   background-color: white;
   font-family: Verdana, Sans-Serif;
   font-size: 0.8em;
}
.miestilo td {
   padding: 5px;
}
/*
.miestilo .odd {
   background-color: #ddd;
}
.miestilo .even {
   background-color: white;
}
*/
tbody tr:nth-child(even) {
  background: #ddd;
}
</style>
<table class="miestilo">
  <theader>
    <th>[Date]</th><th>[Minimum(%)]</th><th>[Average(%)]</th><th>[Duration(ms)]</th><th>[Phase]</th>
  </theader>
  <tbody>
  </tbody>
</table>
</body>
</html>
]]
   local fd=io.open("/home/user/saglog.html", "w") -- XXX path y sufijo "hardcoded"
   if fd then
      fd:write(html)
      fd:close()
   end
   os.execute("cp /home/user/saglog.html /home/user/saglog2.html")
   os.execute("sync")
end

local id=1
local function insert_log_row(sds,time,minimo,integral,tiempo,fase, init)
   local LOG_MAX=6000
   --
   local this_id=id
   access.set(sds, zigorDvrGapLogId          .. "." .. tostring(id), this_id)
   access.set(sds, zigorDvrGapLogTime        .. "." .. tostring(id), time)
   access.set(sds, zigorDvrGapLogMinimo      .. "." .. tostring(id), minimo)
   access.set(sds, zigorDvrGapLogIntegral    .. "." .. tostring(id), integral)
   access.set(sds, zigorDvrGapLogTiempo      .. "." .. tostring(id), tiempo)
   access.set(sds, zigorDvrGapLogFase        .. "." .. tostring(id), fase)

   -- Comprobar "MaxEntries", QueueWraps, etc.
   local queue_wraps = access.get(sds, zigorDvrGapLogQueueWraps .. ".0")
   local max_entries = access.get(sds, zigorDvrGapLogMaxEntries .. ".0")
   local total_entries = access.get(sds, zigorDvrGapLogTotalEntries .. ".0") or 0
   if(total_entries < id) then
      access.set(sds, zigorDvrGapLogTotalEntries .. ".0", id)
   end
   if id < max_entries then
      id = id + 1
   else
      id=1
      queue_wraps = queue_wraps + 1
      access.set(sds, zigorDvrGapLogQueueWraps .. ".0", queue_wraps)
   end
   access.set(sds, zigorDvrGapLogIndex .. ".0", id)

   -- Escribir a disco (si no es "init")
   if not init then
      package.loaded["gaplog-" .. profile] = nil -- Forzamos recarga desde disco
      local t=require ("gaplog-" .. profile)
      if type(t)~="table" then t={} end
      t[this_id] = {
	 id      = this_id,
	 time    = time,
	 minimo  = minimo,
	 integral= integral,
	 tiempo  = tiempo,
	 fase    = fase,
      }
      local serial_t=serialize(t)
      local filename = "../share/config/gaplog-" .. profile .. ".lua"
      local filename_tmp = filename .. "_tmp"
      local fd=io.open(filename_tmp, "w+") -- XXX path y sufijo "hardcoded"
      fd:write('local gaplog = ')
      fd:write( serial_t )
      fd:write('\n\n')
      fd:write('return gaplog,'.. tostring(id) ..','.. tostring(queue_wraps) ..'\n')
      fd:close()
      os.execute("mv " .. filename_tmp .. " " .. filename)
      os.execute("sync")

      --update_gaplog_html(sds)
      -- (new) html & csv! (idea sólo en inglés para simplificar)
      local displays = dofile("../share/config/displays-dvr.lua")
      local display_fase = displays.display_hueco
      local dfase=display_fase[fase]["fase-display"]
      local date = os.date("%d/%m/%Y/%H:%M:%S", os.time(ZDateAndTime2timetable(time)))

      -- (new) idea adjuntar tb en otro fichero info adicional del estado (medidas)
      local vr = access.get(sds, zigorDvrObjVRedR..".0")
      local vs = access.get(sds, zigorDvrObjVRedS..".0")
      local vt = access.get(sds, zigorDvrObjVRedT..".0")
      local vbus = access.get(sds, zigorDvrObjVBus..".0")
      local voutr = access.get(sds, zigorDvrObjVSecundarioR..".0")
      local vouts = access.get(sds, zigorDvrObjVSecundarioS..".0")
      local voutt = access.get(sds, zigorDvrObjVSecundarioT..".0")
      local ir = access.get(sds, zigorDvrObjISecundarioR..".0")
      local is = access.get(sds, zigorDvrObjISecundarioS..".0")
      local it = access.get(sds, zigorDvrObjISecundarioT..".0")
      local pr = access.get(sds, zigorDvrObjPSalidaR..".0")
      local ps = access.get(sds, zigorDvrObjPSalidaS..".0")
      local pt = access.get(sds, zigorDvrObjPSalidaT..".0")

      -- html file
      print("saglog html file!")
      local fd=io.open("/var/log/saglog_tmp.html", "w")
      local lines=0
      local flag_stop=false
      local file="/home/user/saglog.html"
      for line in io.lines(file) do
         if not flag_stop then
	    lines=lines+1
	 end
         --print(line)
         --print(lines)
	 if string.match(line,"<tbody>") then
	    --print(">>> tbody\n")
	    fd:write(line) fd:write('\n')
	    lines=0
	    --[[
	    local class
	    if(toggle==true) then class='class="odd"' toggle=false else class='class="even"' toggle=true end
	    new='    <tr '..class..'><td>'..date..'</td><td>'..minimo..'</td><td>'..integral..'</td><td>'..tiempo..'</td><td>'..dfase..'</td></tr>\n'
	    --]]
	    new='<tr><td>'..date..'</td><td>'..minimo..'</td><td>'..integral..'</td><td>'..tiempo..'</td><td>'..dfase..'</td></tr>\n'
	    fd:write(new)
	    print(new)
	 elseif string.match(line,"</tbody>") then
	    --print(">>> /tbody\n")
	    fd:write(line) fd:write('\n')
	    flag_stop=false
	 elseif not flag_stop then
	    --print("write!\n")
	    fd:write(line) fd:write('\n')
	 end
	 if not flag_stop and lines>=LOG_MAX then -- XXX
	    --print("flag_stop=true")
	    flag_stop=true
	    lines=0
	 end
      end
      fd:close()
      local cmd="cp /var/log/saglog_tmp.html /home/user/saglog.html"
      print(cmd)
      os.execute(cmd)
      os.execute("sync")
      --- Nuevo fichero con info extra
      print("saglog2 html file!")
      local fd=io.open("/var/log/saglog2_tmp.html", "w")
      local lines=0
      local flag_stop=false
      local file="/home/user/saglog2.html"
      for line in io.lines(file) do
         if not flag_stop then
	    lines=lines+1
	 end
         --print(line)
	 --print(lines)
	 if string.match(line,"<tbody>") then
	    --print(">>> tbody\n")
	    fd:write(line) fd:write('\n')
	    lines=0
	    local new
	    --if vr~=0 and vs~=0 and vt~=0 and voutr~=0 and vouts~=0 and voutt~=0 and vbus~=0 and ir~=0 and is~=0 and it~=0 and pr~=0 and ps~=0 and pt~=0 then
	    if vr~=nil and vs~=nil and vt~=nil and voutr~=nil and vouts~=nil and voutt~=nil and vbus~=nil and ir~=nil and is~=nil and it~=nil and pr~=nil and ps~=nil and pt~=nil then
	       local extra = "VInR:"..tostring(vr/10).."V/VInS:"..tostring(vs/10).."V/VInT:"..tostring(vt/10).."V/VBus:"..tostring(vbus/10).."V/VOutR:"..tostring(voutr/10).."V/VOutS:"..tostring(vouts/10).."V/VOutT:"..tostring(voutt/10).."V/IR:"..tostring(ir/10).."A/IS:"..tostring(is/10).."A/IT:"..tostring(it/10).."A/PR:"..tostring(pr/10).."kW/PS:"..tostring(ps/10).."kW/PT:"..tostring(pt/10).."kW"
	       new='<tr><td>'..date..'</td><td>'..minimo..'</td><td>'..integral..'</td><td>'..tiempo..'</td><td>'..dfase..'</td><td>'..extra..'</td></tr>\n'
	    else
	       new='<tr><td>'..date..'</td><td>'..minimo..'</td><td>'..integral..'</td><td>'..tiempo..'</td><td>'..dfase..'</td></tr>\n'
	    end
	    fd:write(new)
	    print(new)
	 elseif string.match(line,"</tbody>") then
	    --print(">>> /tbody\n")
	    fd:write(line) fd:write('\n')
	    flag_stop=false
	 elseif not flag_stop then
	    --print("write!\n")
	    fd:write(line) fd:write('\n')
	 end
	 if not flag_stop and lines>=LOG_MAX then -- XXX
	    --print("flag_stop=true")
	    flag_stop=true
	    lines=0
	 end
      end
      fd:close()
      local cmd="cp /var/log/saglog2_tmp.html /home/user/saglog2.html"
      --print(cmd)
      os.execute(cmd)
      os.execute("sync")

      -- csv file
      print("saglog csv file!")
      fd=io.open("/var/log/saglog_tmp.csv", "w")
      new = date..','..minimo..','..integral..','..tiempo..','..dfase..'\n'
      fd:write(new)
      print(new)
      fd:close()
      cmd='head -n '..tostring(LOG_MAX-1)..' /home/user/saglog.csv >>/var/log/saglog_tmp.csv; cp /var/log/saglog_tmp.csv /home/user/saglog.csv'
      print(cmd)
      os.execute(cmd)
      os.execute("sync")
      ----------

      -- Emitir notificación de nueva fila insertada en histórico
      access.set(sds, zigorTrapDvrGapLogEntryAdded, this_id)
   end

end

local function delete_log_row_by_id(sds,id)
   access.set(sds, zigorDvrGapLogTime        .. "." .. tostring(id), nil)
   access.set(sds, zigorDvrGapLogMinimo      .. "." .. tostring(id), nil)
   access.set(sds, zigorDvrGapLogIntegral    .. "." .. tostring(id), nil)
   access.set(sds, zigorDvrGapLogTiempo      .. "." .. tostring(id), nil)
   access.set(sds, zigorDvrGapLogFase        .. "." .. tostring(id), nil)
   access.set(sds, zigorDvrGapLogId          .. "." .. tostring(id), nil)
   local total_entries = access.get(sds, zigorDvrGapLogTotalEntries .. ".0") or 0
   if total_entries > 0 then total_entries = total_entries-1 end
   access.set(sds, zigorDvrGapLogTotalEntries .. ".0", total_entries)
end
------------------------

local function gaplog_set(sds, date, minimo, integral, tiempo, fase)
        insert_log_row(sds, date, minimo, integral, tiempo, fase, false)
        local displays = dofile("../share/config/displays-dvr.lua")
        local display_fase = displays.display_hueco
        local dfase=display_fase[fase]["fase-display"]
        local sag_info = _g("F") .. ": " .. dfase .. " " ..  _g("Dur") .. ": " .. tiempo .. " ms" .. " " .. _g("Mín") ..": " .. minimo .. " %" .. " " .. _g("Med") .. ": " .. integral .. " %"
        alt.insert(zigorAlarmaSagRecorded, index_cond.bloqueada, sag_info, date)
    end

local function gaplog_init(sds)
                   local t,last_id, last_queue_wraps
                   local filename = "../share/config/gaplog-" .. profile .. ".lua"
                   if (pcall(dofile_protected, filename)) then
                      t,last_id,last_queue_wraps=dofile_protected(filename)
                   else
                      t = {}
                      fd=io.open(filename, "w+")
                      fd:write('return {}\n')
                      fd:close()
                      os.execute("sync")
                      print("Fallo al leer archivo " .. filename)
                   end
		   if t~=nil then
		    for i = 1, #t do
		      v = t[i]
		      insert_log_row(sds, v.time, v.minimo, v.integral, v.tiempo, v.fase, true)
		    end
		   end
		   id=last_id or id
		   access.set(sds, zigorDvrGapLogQueueWraps .. ".0", last_queue_wraps or 0)
		end

local function del_row_by_id(sds, id)
			    delete_log_row_by_id(sds, id)
			 end

local function gaplog_del_log(sds)
		      -- borramos histórico de SDS
		      local key = zigorDvrGapLogId
		      local nextkey=accessx.getnextkey(sds, key) -- primero
		      while( nextkey and is_substring(nextkey, key) and nextkey~=key ) do
			 local a,b,id=string.find(nextkey, "%.([0-9]*)$")
			 del_row_by_id(sds,id)
			 nextkey=accessx.getnextkey(sds, nextkey) -- siguiente
		      end
		      -- borramos histórico de disco
		      local fd=io.open("../share/config/gaplog-" .. profile .. ".lua", "w+") -- XXX path y sufijo "hardcoded"
		      fd:write('local gaplog = ')
		      fd:write( "{}" )
		      fd:write('\n\n')
		      fd:write('return gaplog,1,'..tostring(queue_wraps)..'\n')
		      fd:close()
		      -- inicializamos
		      id=1
		      -- XXX añadir un evento "borrado de histórico"

		      --update_gaplog_html(sds)
		      --cmd = [[sed -i '/tbody/,/\/tbody/d' /home/user/saglog.html; echo >/home/user/saglog.csv]]
		      create_log_html()
		      cmd = [[echo >/home/user/saglog.csv]]
		      print(cmd)
		      os.execute(cmd)
		      os.execute("sync")
		   end


----------------------------------------
local function make_demo_handler()
 local count=0  -- static variables
 local COUNT_MAX = 300
 --local COUNT_MAX = 60
 local update = math.random(1+COUNT_MAX/4,COUNT_MAX-COUNT_MAX/4)
 local valor=0
 ---
 return function(data)
   -- Ejemplo de que cada COUNT_MAX segundos se genera una alarma aleatoriamente (de la tabla t) e igualmente se resetea. Además baile random de tensiones etc.

   print("demo>> demo_handler", count)

   t={
      { oid=zigorDvrObjErrorVInst..".0",	estado=6  },
      { oid=zigorDvrObjAlarmaVBusMax..".0",	estado=23 },
      { oid=zigorDvrObjAlarmaVCondMax..".0",	estado=22 },
      { oid=zigorDvrObjAlarmaVBusMin..".0",	estado=8  },
      { oid=zigorDvrObjAlarmaVRed..".0",	estado=7  },
      { oid=zigorDvrObjAlarmaDriver..".0",	estado=10 },
      { oid=zigorDvrObjErrorDriver..".0",	estado=25 },
      { oid=zigorDvrObjErrorTermo..".0",	estado=24 },
      { oid=zigorDvrObjErrorFusCondAC..".0",	estado=26 },
   }

   if count==0 then  -- solo al inicio
      --print("demo>> init")
      --access.set(sdscoreglib, zigorDvrObjParado..".0", 1)
      access.set(sdscoreglib, zigorDvrObjEstadoControl..".0", 4)  -- ON
      for k,v in ipairs(t) do
         access.set(sdscoreglib, v.oid, 2)
      end
   end

   if math.fmod(count,3)==0 then  -- random de temperaturas etc (tener en cuenta cfg de timeout de refresco de UI)
      --print("demo: random de temperaturas etc")
      --access.set(sdscoreglib, zigorDvrObjVRedR..".0",    math.random(2250,2350))  -- 230
      --access.set(sdscoreglib, zigorDvrObjVRedS..".0",    math.random(2250,2350))
      --access.set(sdscoreglib, zigorDvrObjVRedT..".0",    math.random(2250,2350))
      access.set(sdscoreglib, zigorDvrObjVRedR..".0",    math.random(3900,4100))  -- 400 +-2.5%
      access.set(sdscoreglib, zigorDvrObjVRedS..".0",    math.random(3900,4100))
      access.set(sdscoreglib, zigorDvrObjVRedT..".0",    math.random(3900,4100))

      estado = access.get(sdscoreglib, zigorDvrObjEstadoControl..".0")
      if estado == 4 then
         access.set(sdscoreglib, zigorDvrObjVBus..".0",  math.random(7170,7230))  -- 720 en On
      else
         access.set(sdscoreglib, zigorDvrObjVBus..".0",  math.random(5370,5430))  -- 540 en no On
      end

      --access.set(sdscoreglib, zigorDvrObjVSecundarioR..".0", math.random(2250,2350))
      --access.set(sdscoreglib, zigorDvrObjVSecundarioS..".0", math.random(2250,2350))
      --access.set(sdscoreglib, zigorDvrObjVSecundarioT..".0", math.random(2250,2350))
      VSR=math.random(3980,4020)
      VSS=math.random(3980,4020)
      VST=math.random(3980,4020)
      access.set(sdscoreglib, zigorDvrObjVSecundarioR..".0", VSR)  -- 400 +-0.5%
      access.set(sdscoreglib, zigorDvrObjVSecundarioS..".0", VSS)
      access.set(sdscoreglib, zigorDvrObjVSecundarioT..".0", VST)

      ISR=math.random(800,950)
      ISS=math.random(ISR-50,ISR+50)
      IST=math.random(ISR-50,ISR+50)
      access.set(sdscoreglib, zigorDvrObjISecundarioR..".0", ISR)  -- 50..125 A
      access.set(sdscoreglib, zigorDvrObjISecundarioS..".0", ISS)
      access.set(sdscoreglib, zigorDvrObjISecundarioT..".0", IST)

      --access.set(sdscoreglib, zigorDvrObjPSalidaR..".0",     math.random(100,1000))  -- 0..100
      --access.set(sdscoreglib, zigorDvrObjPSalidaS..".0",     math.random(100,1000))
      --access.set(sdscoreglib, zigorDvrObjPSalidaT..".0",     math.random(100,1000))
      PSR=VSR*ISR/10/1000 --print(PSR) -- decimas de kVA
      PSS=VSS*ISS/10/1000 --print(PSS)
      PST=VST*IST/10/1000 --print(PST)
      access.set(sdscoreglib, zigorDvrObjPSalidaR..".0", PSR)
      access.set(sdscoreglib, zigorDvrObjPSalidaS..".0", PSS)
      access.set(sdscoreglib, zigorDvrObjPSalidaT..".0", PST)
   end

   if count==update then
      --print("demo>> update")
      valor = math.random(1,#t)
      --print("demo>> valor:", valor)
      access.set(sdscoreglib, t[valor].oid, 1)
      access.set(sdscoreglib, zigorDvrObjEstadoControl..".0", t[valor].estado)
   end

   if count==COUNT_MAX then
      print("demo>> COUNT_MAX")
      count=0
      update = math.random(1+COUNT_MAX/4,COUNT_MAX-COUNT_MAX/4)
      --print("demo>> update:", update)
      -- reset error:
      access.set(sdscoreglib, t[valor].oid, 2)
      access.set(sdscoreglib, zigorDvrObjEstadoControl..".0", 4)  -- ON

      --- XXX test (sds, time, minimo, integral, tiempo, fase, init)
      -- Obtenemos 'date' en formato ZDateAndTime
      time=os.date("%Y%m%d%H%M%S0%z")
      --insert_log_row(sdscoreglib, time, math.random(1,100), math.random(1,100), math.random(10,1500), math.random(1,3), true)  -- no escribir a disco
      gaplog_set(sdscoreglib, time, math.random(1,100), math.random(1,100), math.random(10,1500), math.random(1,3))
      ------
   end

   count=count+1

   access.set(sdscoreglib, zigorDvrObjEComDSP..".0", 2) -- Inhibir la alarma de error de comunicaciones con el DSP

   return true
 end
end

local function configureETH(sds)
   local ethEnabled = access.get(sds, zigorNetEnableEthernet .. ".0")
   if ethEnabled == TruthValueTRUE then
      os.execute("ifconfig eth0 up")
   else
      os.execute("ifconfig eth0 down")
   end
end

local function configureSSH(sds)
   local sshEnabled = access.get(sds, zigorNetEnableSSH .. ".0")
   if sshEnabled == TruthValueTRUE then
      os.execute("ln -s /etc/init.d/dropbear /etc/runlevels/default/dropbear")
      os.execute("/etc/init.d/dropbear restart")
   else
      os.execute("rm -f /etc/runlevels/default/dropbear")
      os.execute("/etc/init.d/dropbear stop")
   end
end
----------------------------------------
-- Ahora uso dofile... --local displays_dvr=require "displays-dvr"

local flag_objgap = 0  --gaplog
local estado_ant  --estado de control anterior
local log_init=1
--------------------------------------------
-- Gestión de eventos "set" y "get"  del SDS
--------------------------------------------
local demo_handler_id = nil
local setsig_init=1
local changes={} -- tabla para guardar registro de los cambios en temp(1)

local function setsig_handler(sds, k, v, data)
   local res=false -- por defecto, no manejamos 'set'

   -- Actuaciones

   -- Parámetros
   if is_substring(k, zigorParameter) or is_substring(k, zigorAlarmConfig) or is_substring(k, zigorDvrObjParams)  then
      if (k==zigorCtrlParamState .. ".0") then
	 -- "Commit" configuración
	 if v==1 then     -- temp(1)
	    -- grabar configuración AGS (parámetros)
	    print("Se establecen parametros en active-dvr.lua")
	    local p="active-"..profile
	    local f="factory-"..profile
	    local param=require(p) or require(f)
	    save_param_data(param, sds, "../share/config/" .. p .. ".lua") -- XXX "hardwired path"
	    -- XXX ¿alarma de configuración salvada?
	    -- Eventos en función de qué parámetros se han cambiado
	    -- comprobar cambio de passwords
	    if changes[zigorSysPasswordPass] then
	       for n,p in pairs(changes[zigorSysPasswordPass]) do
		  if p.temp~=p.active then
		     alt.insert(zigorAlarmaPasswdChange, index_cond.activa, tostring(n), os.date("%Y%m%d%H%M%S0%z"))
		  end
	       end
	    end

	    if changes[zigorNetVncPassword] then
	       password = access.get(sds, zigorNetVncPassword .. ".0")
	       os.execute("echo " .. password .. " | vncpasswd -f > /etc/.vncpasswd")
	    end

            -- SSH deshabilitar/habilitar
            if changes[zigorNetEnableSSH] then
                configureSSH(sds)
            end
            -- Puerto ethernet deshabilitar/habilitar
            if changes[zigorNetEnableEthernet] then
                configureETH(sds)
            end
	    --
	    changes={}
	    -- grabar configuración sistema y reiniciar servicios en la próxima iteración del "mainloop"
	    print("Grabar configuracion del sistema -> save_system_data")
 	    gobject.timeout_add(0,
 				function(sds)
 				   save_system_data(sds)
 				   return false
 				end,
 				sds)
	    -- Establecemos estado=active(2)
	    gobject.block(sds, set_handler_id)
	    access.set(sds, zigorCtrlParamState .. ".0", 2)
	    gobject.unblock(sds, set_handler_id)
	    res=true -- no hacer el set de temp(1) (ya hemos puesto active(2))
	    temp_timeout=nil -- anulamos cuenta de expiración
	 elseif v==2 then -- active(2)
	    -- (XXX duda xq se bloqueo...) gobject.block(sds, set_handler_id)
	    load_active()
	    changes={}       -- anulamos registro de cambios temporales
	    --gobject.unblock(sds, set_handler_id)
	    temp_timeout=nil -- anulamos cuenta de expiración
	 elseif v==3 then -- factory(3)
	    -- (XXX duda xq se bloqueo...) gobject.block(sds, set_handler_id)
	    load_factory()
	    --gobject.unblock(sds, set_handler_id)
	    temp_timeout=0 -- XXX inicializar cuenta de expiración (?)
	 end
      elseif access.get(sds, k)~=v then
	 -- Edición de un parámetro.
	 -- Comprobamos si primera edición ( estado no es temp(1) )
	 if access.get(sds, zigorCtrlParamState .. ".0")~=1 then
	    -- Inicializamos registro de cambios para este temporal
	    changes={}
	    -- Establecemos estado=temp(1)
	    gobject.block(sds, set_handler_id)
	    access.set(sds, zigorCtrlParamState .. ".0", 1)
	    gobject.unblock(sds, set_handler_id)
	 end
	 -- Guardamos registro de los cambios
	 local _,_,id,n=string.find(k, "(.*)%.([0-9]+)$")
	 if not changes[id] then
	    changes[id]={}
	 end
	 if not changes[id][n] then
	    changes[id][n]={}
	    changes[id][n].active=access.get(sds, k)
	 end
	 changes[id][n].temp=v
	 -- inicializar cuenta de expiración
	 temp_timeout=0
      end
   end

   -- Fecha
   if k==zigorSysDate .. ".0" then
      -- Establecemos fecha del sistema mediante comando 'date'
      --[[
      local tt=ZDateAndTime2timetable(v)
      os.execute("date -s '" .. os.date("%m/%d/%Y %H:%M:%S %z", os.time(tt)) .. "'" )
      --]]
      local tt={}
      tt.day  =string.sub(v,7,8)
      tt.month=string.sub(v,5,6)
      tt.year =string.sub(v,1,4)
      tt.hour =string.sub(v,9,10)
      tt.min  =string.sub(v,11,12)
      tt.sec =string.sub(v,13,14)
      os.execute("date -s '"..tt.month.."/"..tt.day.."/"..tt.year.." "..tt.hour..":"..tt.min..":"..tt.sec.."'" )
      os.execute("hwclock --systohc --utc")
      os.execute("echo \"0.0 0 0.0\" > /etc/adjtime")  --XXX fix problema desajuste de hora observado...
      res=true -- no hacer el set, hemos configurado la fecha del sistema
   end

   -- Condición de alarmas (reconocimiento y reset)
   if is_substring(k, zigorAlarmCondition) then
      -- Para hacer el "reset", se hace SET a "inactiva"
      if v==index_cond["inactiva"] then
	 local _,_, id = string.find(k, "([0-9]+)$")
	 local descr = at.get_descr(tonumber(id))
	 local date=os.date("%Y%m%d%H%M%S0%z")
	 if descr then   -- fix: proteccion ante situacion descr=nil(?) Parece se da cuando hay intento envio mail y no cfg adecuada a internet
	  at.set(descr, v, "", date)
	  -- Actualizar histórico
	  alt.set(descr, v, "", date)
	  -- preparacion sms (caso desaparicion de eventos reseteables)
	  sms_set(descr, v, "", date)
	 end
	 ----
	 res=true -- no hacer el set
      end
      -- XXX reconocimiento?
   end

   -- Borrado de histórico
   if (k == zigorAlarmLogTotalEntries .. ".0") and (v == 0) then
      gobject.block(sds, set_handler_id)
      alt.del_log()
      gobject.unblock(sds, set_handler_id)
   end

   -- Actuaciones
   if (k == zigorDvrObjOrdenMarcha .. ".0" or k == zigorDvrObjOrdenParo .. ".0" or k == zigorDvrObjOrdenReset .. ".0") then

      gobject.timeout_add(1, function(k)
                                gobject.block(sds, set_handler_id)  -- Bloquear señal para evitar recursión
                                access.set(sds, k, 1)                       -- la variable de actuación a On(1) mientras se actua
                                for i=1,3 do
                                   bus.write(zigorobj_dsp, DA_ETX_BUS_DSP .. ID_ETX_ACTUA, nil) -- escritura en el bus del objeto de actuación
                                end
                                access.set(sds, k, 2) -- variable a Off(2)
                                for i=1,3 do
                                   bus.write(zigorobj_dsp, DA_ETX_BUS_DSP .. ID_ETX_ACTUA, nil) -- escritura en el bus del objeto de actuación
                                end
                                gobject.unblock(sds, set_handler_id)
                                return false -- no repetir
                             end,
                          k)
      res=true              -- evitamos el 'set'
      --gobject.stop(sds, "setsig")  --XXX
   end

   -- Cambio de zona horaria => CAMBIOS en el sistema (/etc/localtime)
   -- Y ademas hacemos uso de variable de entorno TZ para interaccion con algoritmo de reloj astronomico en cm-ctrl(gob)
   -- dado que solo cambio en /etc/locatime no del todo ok
   if (k == zigorSysTimeZone .. ".0") then
      print("zigorSysTimeZone") io.flush()
      if access.get(sds,k)~=v then
         require "display-timezone"
	 tz = display_timezone[v].display
         print("cambiar en zigorSysTimeZone", tz) io.flush()
	 -- cambio en /etc/localtime
	 --cmd = 'date +%z; echo "cambiando zoneinfo..."; ln -sf /usr/share/zoneinfo/'..tz..' /etc/localtime; sync; date +%z'
	 cmd = 'ln -sf /usr/share/zoneinfo/'..tz..' /etc/localtime; sync'
	 print(cmd)
	 os.execute(cmd)
	 -- cambio variable de entorno
	 --print("antes setenv",os.getenv("TZ"))
	 i18n.setenv("TZ",tz)
	 --print("despues setenv",os.getenv("TZ"))
      end
   end

   -- gaplog:
   -- Recepcion variables de objeto de bus zigor de evento de hueco
   if (k == zigorDvrObjGapMinimo .. ".0") then
      flag_objgap = bit.OR(flag_objgap, 1)
      -- incluir porcentaje respecto a 32768
      v = v/32768*100
   end
   if (k == zigorDvrObjGapIntegral .. ".0") then
      flag_objgap = bit.OR(flag_objgap, 2)
   end
   if (k == zigorDvrObjGapTiempo .. ".0") then
      flag_objgap = bit.OR(flag_objgap, 4)
   end
   if (k == zigorDvrObjGapFase .. ".0") then
      flag_objgap = bit.OR(flag_objgap, 8)
   end
   --
   if (k == zigorDvrObjGapMinimo .. ".0") or (k == zigorDvrObjGapIntegral .. ".0") or
      (k == zigorDvrObjGapTiempo .. ".0") or (k == zigorDvrObjGapFase .. ".0") then
      -- Metemos la variable en el SDS
      gobject.block(sds, set_handler_id)
      access.set(sds, k, v)
      gobject.unblock(sds, set_handler_id)
      res=true -- no hacer el set, ya hecho
      --gobject.stop(sds, "setsig")  --XXX
   end
   --
   if(flag_objgap==15) then
      flag_objgap=0
      -- set de todas las variables del objeto de hueco
      local date=os.date("%Y%m%d%H%M%S0%z")
      local minimo=access.get(sds, zigorDvrObjGapMinimo .. ".0")
      local tiempo=access.get(sds, zigorDvrObjGapTiempo .. ".0")
      local integral=access.get(sds, zigorDvrObjGapIntegral .. ".0")

      if tiempo~=0 then
        integral = (1 - (integral/(tiempo*3.2)))*100
      end

      local fase=access.get(sds, zigorDvrObjGapFase .. ".0")
      -- (new) filtrar huecos con duración -1 o media 100!
      if tiempo~=65535 and integral~=100 then
         gaplog_set(sds, date, minimo, integral, tiempo, fase)  --set en tabla gaplog y escritura en fichero
      end
   end

   -- Borrado de histórico de huecos
   if (k == zigorDvrGapLogTotalEntries .. ".0") and (v == 0) then
      gobject.block(sds, set_handler_id)
      gaplog_del_log(sds)
      gobject.unblock(sds, set_handler_id)
   end

   -- Corriente y Potencia segun el numero de equipos en paralelo
   if (k == zigorDvrObjISecundarioR .. ".0") or (k == zigorDvrObjISecundarioS .. ".0") or (k == zigorDvrObjISecundarioT .. ".0") or
      (k == zigorDvrObjPSalidaR .. ".0") or (k == zigorDvrObjPSalidaS .. ".0") or (k == zigorDvrObjPSalidaT .. ".0") then
      local num_equipos=access.get(sds, zigorDvrParamNumEquipos .. ".0")
      if num_equipos then
         v = v*num_equipos
      end
      -- Aplicar Factor a las potencias:
      if (k == zigorDvrObjPSalidaR .. ".0") or (k == zigorDvrObjPSalidaS .. ".0") or (k == zigorDvrObjPSalidaT .. ".0") then
         local factor=access.get(sds, zigorDvrParamFactor .. ".0")  -- 0.001
         if factor then
	    --v = v*(factor/10)
	    v = v*(factor/1000)
	 end
      end
      -- Metemos la variable en el SDS
      gobject.block(sds, set_handler_id)
      access.set(sds, k, v)
      gobject.unblock(sds, set_handler_id)
      res=true -- no hacer el set, ya hecho
      --gobject.stop(sds, "setsig")  --XXX
   end

   -- Insertar evento de cambio de estado en historico
   if (k == zigorDvrObjEstadoControl .. ".0") then
      if v~=estado_ant then
--[[
	       setlocale(sdscoreglib)
	       local displays = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
	       local display_descr = displays.display_descr
--]]
         --alt.insert(zigorAlarmaStatusChange, index_cond.bloqueada, displays_dvr.display_EstadoControl[v]["display"], os.date("%Y%m%d%H%M%S0%z"))
         setlocale(sds)
	 local displays_dvr = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
	 alt.insert(zigorAlarmaStatusChange, index_cond.bloqueada, displays_dvr.display_EstadoControl[v]["display"], os.date("%Y%m%d%H%M%S0%z"))
	 ----
	 estado_ant=v
      end
   end

   -- calculo de variable VRedNom
   if (k == zigorDvrParamVRedNom .. ".0") or (k == zigorDvrParamFactor .. ".0") then
      -- Metemos la variable en el SDS _antes_ de recalcular
      gobject.block(sds, set_handler_id)
      err=access.set(sds, k, v)
      if err==0 then
         res=true -- no hacer el set, ya hecho
         -- Recalcular
         set_VRedNom(sds)
         set_VMinDVR(sds)
      end
      gobject.unblock(sds, set_handler_id)
   end

   -- calculo de variable VMinDVR
   if (k == zigorDvrParamVMinDVR .. ".0") then
      -- Metemos la variable en el SDS _antes_ de recalcular
      gobject.block(sds, set_handler_id)
      err=access.set(sds, k, v)
      if err==0 then
         res=true -- no hacer el set, ya hecho
         -- Recalcular
         access.set(sds, zigorDvrObjVMinDVR .. ".0", v)
      end
      gobject.unblock(sds, set_handler_id)
   end

   if (k == zigorDvrParamHuecoNom .. ".0") then
      -- Metemos la variable en el SDS _antes_ de recalcular
      gobject.block(sds, set_handler_id)
      err=access.set(sds, k, v)
      if err==0 then
         res=true -- no hacer el set, ya hecho
         -- Recalcular
         set_VMinDVR(sds)
      end
      gobject.unblock(sds, set_handler_id)
   end

   -- Tensiones segun parametro de factor
   if (k == zigorDvrObjVRedR .. ".0") or (k == zigorDvrObjVRedS .. ".0") or (k == zigorDvrObjVRedT .. ".0") or
      (k == zigorDvrObjVSecundarioR .. ".0") or (k == zigorDvrObjVSecundarioS .. ".0") or (k == zigorDvrObjVSecundarioT .. ".0") then
      local factor=access.get(sds, zigorDvrParamFactor .. ".0")  -- 0.001
      if factor then
         --v = v*(factor/10)
         v = v*(factor/1000)
      end
      -- Metemos la variable en el SDS
      gobject.block(sds, set_handler_id)
      access.set(sds, k, v)
      gobject.unblock(sds, set_handler_id)
      res=true -- no hacer el set, ya hecho
   end

   -- Test de envio email
   if (k == zigorNetSmtpTest .. ".0") then
      --send_email(sds, "Test email", "Test de envio de email.", v)
      -- pb de timeout en respuesta al set, mejor:
      if testmail_init==1 then
         testmail_init=0
      else
         testmail=v
      end
   end

   -- XXX Opcion DEMO (arrancar script)
   if k==zigorCtrlParamDemo .. ".0" then
      local demo = access.get(sds, zigorCtrlParamDemo .. ".0")
      if(demo~=v) then
         if v==1 then
            if not demo_handler_id then
	       demo_handler = make_demo_handler()
	       demo_handler_id = gobject.timeout_add(1000, demo_handler, nil)  -- 2 seg como el timeout del gtk
	    end
         elseif v==2 then
	    if demo_handler_id then
	       gobject.source_remove(demo_handler_id)
	       demo_handler_id = nil
	    end
         end
      end
   end

  ------
  -- EVITAR EN ARRANQUE:
  if setsig_init==0 then

   --- MODBUS:
   -- Cambios de parametro de modo MODBUS -> reiniciar proceso
   if (k == zigorModbusMode .. ".0") then
      print("zigorModbusMode") io.flush()
      if access.get(sds,k)~=v then
         if v==1  then  -- paso de modo TCP a RTU es el critico
            os.execute("killall -KILL ags-modbus")
	    print("Cambio en Modo Modbus, executing killall...")
	 end
      end
   end
   if (k == zigorModbusTCPPort .. ".0") then
      print("zigorModbusTCPPort") io.flush()
      if access.get(sds,k)~=v then
         if access.get(sds, zigorModbusMode..".0")==2 then  -- solo reinicio del proceso si en modo TCP
            os.execute("killall -KILL ags-modbus")
	    print("Cambio en TCPPort, executing killall...")
	 end
      end
   end

   if k == zigorModbusAddress .. ".0" or
      k == zigorModbusBaudrate .. ".0" or
      k == zigorModbusParity .. ".0" or
      k == zigorModbusMode .. ".0" or
      k == zigorModbusTCPTimeout .. ".0" then
         print("Cambios en parametros de Modbus") io.flush()
         if access.get(sds,k)~=v then
	    print("Envio de SIGUSR2 para releer")
	    os.execute("killall -SIGUSR2 ags-modbus")
         end
   end

   -- PASSWORDS
   --Variable para contener el valor de la pass + la sal para hashear posteriormente.
   -- local valor_salado
   --Variable para contener el hash que va a ser guardado.
   -- local valor_hasheado

   --modulo necesario para llevar a cabo el hashing
   --local sha1 = require 'sha1'

--   if k == zigorSysPasswordPass .. ".4"         then
--
--        local valor_previo = access.get(sds,k)
--
--        gobject.block(sds, set_handler_id)
--        valor_salado = v .. "LEVEL4"
--        valor_hasheado = sha1.hex(valor_salado)
--
--
--        local err = access.set(sds, k, v)
--        local valor_releido = access.get(sds,k)
--        print("Valor previo = ", valor_previo)
--        print("Valor hasheado = ", valor_hasheado)
--
--        print("Valor salado = ", valor_salado)
--        print("Valor releido = ", valor_releido)
--
--        res = true
--        gobject.unblock(sds, set_handler_id)
--
--   elseif   k == zigorSysPasswordPass .. ".3"   then
--
--        local valor_previo = access.get(sds,k)
--        gobject.block(sds, set_handler_id)
--
--        valor_salado = v .. "LEVEL3"
--        valor_hasheado = sha1.hex(valor_salado)
--
--
--        local err = access.set(sds, k, v)
--        local valor_releido = access.get(sds,k)
--        print("Valor previo = ", valor_previo)
--        print("Valor hasheado = ", valor_hasheado)
--
--        print("Valor salado = ", valor_salado)
--        print("Valor releido = ", valor_releido)
--
--        res = true
--        gobject.unblock(sds, set_handler_id)
--
--   elseif k == zigorSysPasswordPass .. ".2"     then
--
--        local valor_previo = access.get(sds,k)
--        gobject.block(sds, set_handler_id)
--
--        valor_salado = v .. "LEVEL2"
--        valor_hasheado = sha1.hex(valor_salado)
--
--
--        local err = access.set(sds, k, v)
--        local valor_releido = access.get(sds,k)
--        print("Valor previo = ", valor_previo)
--        print("Valor hasheado = ", valor_hasheado)
--
--        print("Valor salado = ", valor_salado)
--        print("Valor releido = ", valor_releido)
--
--        res = true
--        gobject.unblock(sds, set_handler_id)
--
--   elseif k == zigorSysPasswordPass .. ".1"     then
--
--        local valor_previo = access.get(sds,k)
--
--        gobject.block(sds, set_handler_id)
--        valor_salado = v .. "LEVEL1"
--        valor_hasheado = sha1.hex(valor_salado)
--
--        local err = access.set(sds, k, valor_hasheado)
--        local valor_releido = access.get(sds,k)
--
--        print("Valor previo = ", valor_previo)
--        print("Valor hasheado = ", valor_hasheado)
--
--        print("Valor salado = ", valor_salado)
--        print("Valor releido = ", valor_releido)
--
--
--        res = true
--        gobject.unblock(sds, set_handler_id)
--   end
  end  --FIN (if setsig_init==0)
  ------

   return res
end

------

local function getsig_handler(sds, k, data)
   local res=false -- por defecto no manejamos 'get'

   -- Fecha
   if k==zigorSysDate .. ".0" then
      local date
      -- Obtenemos 'date' en formato ZDateAndTime
      date=os.date("%Y%m%d%H%M%S0%z")
      -- Establecemos 'date' en SDS, la continuación del 'get' lo retornará
      -----gobject.block(sds, set_handler_id)
      handlers=block_rest(sds, "setsig")
      access.set(sds, zigorSysDate .. ".0", date)
      ----gobject.unblock(sds, set_handler_id)
      unblock_list(sds, handlers)
      res=true -- Hemos gestionado esta variable, no continuar emisión
   end

   return res
end
----------------------------------------
function set_VRedNom(sds)
   local vrednom,factor
   vrednom=access.get(sds, zigorDvrParamVRedNom .. ".0")
   factor =access.get(sds, zigorDvrParamFactor .. ".0")  -- 0.001
   if vrednom and factor and factor~=0 then
      local VRedNom = vrednom / (factor/1000) / math.sqrt(3)
      access.set(sds, zigorDvrObjVRedNom .. ".0", VRedNom)
   end
end

function set_VMinDVR(sds)
   local vrednom,porcentaje
   vredNom = access.get(sds, zigorDvrParamVRedNom .. ".0")
   huecoNom = access.get(sds, zigorDvrParamHuecoNom .. ".0")
   if vredNom and huecoNom then
      local VMinDVR = vredNom / math.sqrt(3) * (1 - (huecoNom / 100))
      access.set(sds, zigorDvrParamVMinDVR .. ".0", VMinDVR)
      access.set(sds, zigorDvrObjVMinDVR .. ".0", VMinDVR)
   end
end

--------------------------------------------
-- Manipulación "buffer" de salida al bus
--------------------------------------------
--
-- Configuración de "handlers"
--
local dsp_buf   =string.char(tonumber(DA_ETX_BUS_DSP, 16), tonumber(ID_ETX_BUF,   16)) -- DAID de objeto buffer

local fichero_dsp_buf = {
   index = 1,
   buffer = {
--      zigorDvrParamVRedNom .. ".0",
      zigorDvrObjVRedNom .. ".0",
      zigorDvrObjVMinDVR .. ".0",
      zigorDvrParamFrecNom .. ".0",
   },
}

--
-- "helpers"
--
local function replace_buffer(buffer, t, handler_id)
   -- Escribimos trama modificada
   gobject.block(buffer, handler_id)
   textbuffer.set(buffer, t)
   gobject.unblock(buffer, handler_id)
   gobject.stop(buffer, "changed")
end

--
-- "handlers"
--
local function handle_dsp_buf(buffer, t)
   -- Obtenemos OID de parámetro que toca y avanzamos índice
   local oid = fichero_dsp_buf.buffer[fichero_dsp_buf.index]
   if not oid then
      fichero_dsp_buf.index=1
      oid = fichero_dsp_buf.buffer[fichero_dsp_buf.index]
   end
   fichero_dsp_buf.index=fichero_dsp_buf.index+1
   -- Obtenemos parámetro
   local v = access.get(sdscoreglib, oid)
   if type(v)=="boolean" then
      if v then v=1 else v=0 end
   elseif type(v)~="number" then
      return false
   end
   -- Calculamos "offset" y "param" en trama  (offset: indice de objeto fichero de parametros)
   local offset = string.char(0) .. string.char(fichero_dsp_buf.index - 2)
   local param  = string.char(bit.AND(255, bit.SHR(v, 8))) .. string.char(bit.AND(255, v))
   -- Ponemos tamaño de data a 4 bytes
   local fc = string.char( bit.OR(4, bit.AND(240, string.byte(string.sub(t,1,1)))) )
   -- Reconstruimos trama
   t = fc .. string.sub(t,2) .. offset .. param
   -- Escribimos trama modificada
   replace_buffer(buffer, t, dsp_handler_id)

   return true
end

local buffer_handlers = {
   [ dsp_buf    ] = handle_dsp_buf,
}

local function buffer_handler(buffer, user_data)
   local t=textbuffer.get(buffer)
   local daid=string.sub(t,2,3)
   if buffer_handlers[daid] then
      return buffer_handlers[daid](buffer, t)
   end
end
----------------------------------------

-- Conexión de "handlers" de eventos
set_handler_id=gobject.connect(sdscoreglib, "setsig", setsig_handler, nil)
get_handler_id=gobject.connect(sdscoreglib, "getsig", getsig_handler, nil)
dsp_handler_id=gobject.connect(wbuffer_dsp, "changed", buffer_handler, nil)


----------------------------------------
-- Inicializaciones
----------------------------------------
-- Inicialización de configuración (carga de "active")
access.set(sdscoreglib, zigorCtrlParamState .. ".0", 2)
-- Sincronización de sistema a configuración (forzamos guardar)
access.set(sdscoreglib, zigorCtrlParamState .. ".0", 1)

setsig_init=0  -- usado para evitar sets de ciertas variables en arranque

--gaplog:
gaplog_init(sdscoreglib)
--VReNom:
set_VRedNom(sdscoreglib)
--VMinDVR:
set_VMinDVR(sdscoreglib)
-- Servicio SSH
configureSSH(sdscoreglib)
-- Ethernet Port
configureETH(sdscoreglib)

----------------------------------------
-- Gestión alarmas
----------------------------------------
local alarms_config=get_alarm_config_index(sdscoreglib)
local alarms=alarms_dvr_new(sdscoreglib)
at=alarmtable_new{sdscoreglib,false,true}
alt=alarmlogtable_new{sdscoreglib}

local alarm_cache={}

local function alarm_manager(data)
   -- XXX aprovechamos que es función periódica para comprobar "timeout" de configuración
   if temp_timeout then
      -- 150 x 2 segundos = 5 minutos
      if temp_timeout < 150 then
	 temp_timeout = temp_timeout +1
      else
	 access.set(sdscoreglib, zigorCtrlParamState .. ".0", 2)
	 temp_timeout=nil
      end
   end
   ------
   if testmail~=0 then
      print("Prueba envio email") io.flush()

      setlocale(sdscoreglib)  --XXX
      ---
      local name        = access.get(sdscoreglib, zigorSysName..".0") or ""
      local description = access.get(sdscoreglib, zigorSysDescr..".0") or ""
      local location    = access.get(sdscoreglib, zigorSysLocation..".0") or ""

      local date2 = os.date("%d/%m/%y %H:%M")
      local subject = _g("Prueba envio email").." ("..name.."/"..location..")"
      local text = _g("Prueba envio email").."  ("..date2..")\n\n".._g("Nombre del equipo")..": "..name.."\n".._g("Descripción del equipo")..": "..description.."\n".._g("Localización")..": "..location.."\n"
      text = text .. "\n----------------------------------------\n".._g("Esta información ha sido elaborada por un sistema automático.\nPor favor, no responda a este correo.\n")

      send_email(sdscoreglib, "noreply@zigor.com", subject, text, testmail)
      ---
      testmail=0
   end
   ------

   local date=os.date("%Y%m%d%H%M%S0%z")
   for k,v in pairs(alarms) do
      local descr,actives=v.f()

      if descr then     -- Comprobación de seguridad

	 --
	 -- Filtrado
	 --
	 -- Inicializar cache para esta alarma
	 if not alarm_cache[descr] then
	    sms_set_aux=1
	    alarm_cache[descr] = {
	       cnt_act = {},
	       cnt_des = {},
	       t_elements = {}, -- tabla de elementos activos ( p.e. { ["1"] = true, ["3"] = true, ["5"] = true, } ).
	       elements = "",   -- lista de elementos activos ( p.e. "1 3 5" )
	       cond = 0,
	       severity = 0,
	    }
	 end

	 -- variables para saber si es "bloqueante"
	 local severity=access.get(sdscoreglib, zigorAlarmCfgSeverity ..".".. tostring(alarms_config[descr]))
	 local locked=(severity==index_sev["severa"] or severity==index_sev["persistente"])

	 -- Actualizamos elementos activos
	 for e,a in pairs(actives) do
	    -- Inicializamos contadores para este elemento
	    if not alarm_cache[descr].cnt_act[e] then alarm_cache[descr].cnt_act[e]=0 end
	    if not alarm_cache[descr].cnt_des[e] then alarm_cache[descr].cnt_des[e]=0 end
	    -- Comprobamos contador
	    if alarm_cache[descr].cnt_act[e] > v.ca then
	       -- Cuenta de activación cumplida, añadimos elemento a lista de activos
	       alarm_cache[descr].t_elements[e] = true
	    else
	       -- Si no se ha alcanzado cuenta, incrementamos contador
	       alarm_cache[descr].cnt_act[e] = alarm_cache[descr].cnt_act[e] +1
	    end
	 end

	 -- Filtramos elementos inactivos
	 for e in pairs(alarm_cache[descr].cnt_act) do
	    if not actives[e] then
	       -- Reseteamos contador de activación si no
	       -- se llegó a activar este elemento.
	       if not alarm_cache[descr].t_elements[e] then
		  alarm_cache[descr].cnt_act[e] = nil
	       end
	       -- Comprobamos contador
	       if alarm_cache[descr].cnt_des[e] > v.cd then
		  -- Se ha alcanzado la cuenta, desactivamos este elemento
		  alarm_cache[descr].t_elements[e] = nil
		  alarm_cache[descr].cnt_act[e] = nil
		  alarm_cache[descr].cnt_des[e] = nil
	       else
		  -- Si no se ha alcanzado cuenta, incrementamos contador
		  alarm_cache[descr].cnt_des[e] = alarm_cache[descr].cnt_des[e] +1
	       end
	    else
	       -- Reseteamos contador de desactivación
	       -- si elemento activo
	       alarm_cache[descr].cnt_des[e] = 0
	    end
	 end

	 -- Creamos lista de elementos activos con el resultado del filtrado
	 elements = ""
	 for e in pairs(alarm_cache[descr].t_elements) do
	    if elements then
	       elements = elements .. " " .. e
	    else
	       elements = e
	    end
	 end

	 -- Calculamos condición en función de los elementos activos
	 if elements ~= "" then
	    cond = index_cond["activa"]
	 else
	    if locked and alarm_cache[descr].elements~=""  then
	       cond = index_cond["bloqueada"]
	       elements=alarm_cache[descr].elements
	    else
	       cond = index_cond["inactiva"]
	    end
	 end
	 --
	 -- Fin de filtrado
	 --

	 -- Si cambio de condición o elementos, actualizar "alarmtable"
	 if (alarm_cache[descr].cond~=cond or alarm_cache[descr].elements~=elements) then
	    -- prepararacion sms:
	    if sms_set_aux==1 then sms_set_aux=0 else   -- evitar la primera iteracion de evaluacion de alarmas
	       -- ojo evitar activaciones desde estado de bloqueada (en eventos reseteables)
	       ---- YA NO (xq ad+ implicaba perdida de notificaciones en las activaciones posteriores a la primera)
	       -- y el envio de la desactivacion se realiza en la captura del set a inactiva
	       ----if not (alarm_cache[descr].cond==index_cond["bloqueada"] and cond==index_cond["activa"]) then
	          sms_set(descr,cond,elements,date)
	       ----end
	    end
	    ----
	    at.set(descr,cond,elements,date)
	    alarm_cache[descr].cond     = cond
	    alarm_cache[descr].elements = elements
	    -- Actualizar histórico
	    alt.set(descr,cond,elements,date)
	 end
      end

   end

   return true
end
gobject.timeout_add(2000, alarm_manager, nil)

----------------------------------------
----------------------------------------
local notify_emails={
   zigorNetEmail1,
   zigorNetEmail2,
   zigorNetEmail3,
   zigorNetEmail4,
}
----------------------------------------
-- Gestion envio sms
----------------------------------------
-- marcas sms (0:pendiente, 1:enviado, 2:anulado)
local tsms = {}   --tabla circular
local tsms_index_r = 1
local tsms_index_w = 1
local tsms_index_max = 100   --XXX max size of circular table
---------
function sms_set(descr,cond,elements,date)
   --print("sms>>>---------")
   --print("sms>>>sms_set")
   local severity=access.get(sdscoreglib, zigorAlarmCfgSeverity ..".".. tostring(alarms_config[descr]))
   -- filtrar segun cfg de aviso y condicion (activas e inactivas)
   local aviso=access.get(sdscoreglib, zigorAlarmCfgNotification ..".".. tostring(alarms_config[descr]))
   ----local filter=(aviso==AlarmNotificationSMS) and (cond==index_cond["activa"] or cond==index_cond["inactiva"])
   ---- ahora notificar tambien estado de 'bloqueada' dado q tb se notifican las reactivaciones tras dicho estado
   local filter=(aviso==AlarmNotificationSMS)
   --print("sms>>>filter:",filter)
   if not filter then return end
   -- insertar en tabla
   tsms[tsms_index_w] = {
      descr = descr,
      cond = cond,
      elements = elements,  --XXX
      date = date,
      --sms = {0,0,0},  --XXX, para 3 numeros de telefono
      sms = {0,0,0,0},  --XXX, para 4 numeros de telefono
      sev = severity
   }
   -- refinamiento:
   -- caso de producirse desactivacion, si activaciones correspondientes pendientes, anular ambas
   --[[ ahora desactivar
   --print("sms>>>cond: ",cond)
   if(cond==index_cond["inactiva"]) then
      --print("sms>>>insertar desactivacion")
      local tsms_index_aux = tsms_index_w
      while(tsms_index_aux ~= tsms_index_r) do
         --print("sms>>>hay pendientes luego buscar activaciones correspondientes")
         tsms_index_aux = tsms_index_aux - 1
         if(tsms_index_aux<1) then
            tsms_index_aux = tsms_index_max
         end
         --
         if(tsms[tsms_index_aux].descr==descr and tsms[tsms_index_aux].cond==index_cond["activa"]) then
            --print("sms>>>encontrada activacion pendiente para la desactivacion actual")
	    for k,v in pairs(tsms[tsms_index_aux].sms) do
	       if v==0 then
	          --print("sms>>>anulando sms: ",k)
	          tsms[tsms_index_aux].sms[k]=2  --anulacion de activaciones pendientes
	          tsms[tsms_index_w].sms[k]=2    --anulacion de desactivaciones correspondientes
	       end
	    end
	    break
         end
      end
   end
   --]]
   -- gestion de posicion de escritura
   tsms_index_w = tsms_index_w + 1
   if tsms_index_w>tsms_index_max then
      tsms_index_w = 1
   end
   -- si rebase incrementar posicion de lectura
   if tsms_index_w==tsms_index_r then
      tsms_index_r = tsms_index_r + 1
   end
   --print("sms>>>tsms_index_w:",tsms_index_w,"tsms_index_r:",tsms_index_r)

   -- XXX (jur) Aprovechamos para envio de email:
   -------------------------------------------
   ------------
      for i=1,#notify_emails do
	    local email = access.get(sdscoreglib, notify_emails[i]..".0")
	    if not email then return true end
	    --e("email:"..tostring(email))
	    if email~="" then
	       setlocale(sdscoreglib)
	       local displays = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
	       local display_descr = displays.display_descr

	       local descrd, cod
	       if display_descr[descr] then
	          descrd  = display_descr[descr]["display"]
	          cod   = display_descr[descr]["codigo"]
	       end
	       local condd = displays.display_condicion[cond]["display"]
	       local dated = os.date("%d/%m/%Y %H:%M:%S", os.time(ZDateAndTime2timetable(date)))
	       local severityd = displays.display_severidad[severity]["display"]

	       local name        = access.get(sdscoreglib, zigorSysName..".0")
	       local description = access.get(sdscoreglib, zigorSysDescr..".0")
	       local location    = access.get(sdscoreglib, zigorSysLocation..".0")
	       --
	       if not descrd or not condd or not dated or not severityd or not cod or not elements or not name or not description or not location then
	          print("alguna variable inexistente, se cancela email")
		  print(tostring(descrd).." "..tostring(condd).." "..tostring(dated).." "..tostring(severity).." "..tostring(cod).." "..tostring(elements).." "..tostring(name).." "..tostring(description).." "..tostring(location))
		  break
	       end
	       --
	       local date2 = os.date("%d/%m/%y %H:%M")
	       local subject = _g("INFORME DE ALARMAS").." ("..name.."/"..location..")"
	       local text = _g("INFORME DE ALARMAS").."  ("..date2..")\n\n".._g("Nombre del equipo")..": "..name.."\n".._g("Descripción del equipo")..": "..description.."\n".._g("Localización")..": "..location.."\n\n".._g("Alarma")..": "..descrd.."\n".._g("Código")..": "..cod.."\n".._g("Condición")..": "..condd.."\n".._g("Elementos")..": "..elements.."\n".._g("Severidad")..": "..severityd.."\n".._g("Fecha")..": "..dated.."\n"
	       text = text .. "\n----------------------------------------\n".._g("Esta información ha sido elaborada por un sistema automático.\nPor favor, no responda a este correo.\n")

	       send_email(sdscoreglib, "noreply@zigor.com", subject, text, email)
	    end
      end
   ------------
end
---------
local puerto="ttyS1"  --XXX puerto fijo
--
local mgetty_pid=0
local function sms_send(number,text)
   --print("sms>>>sms_send")
   --XXX proteccion para longitud sms>160chars
   if #text > 160 then text = string.sub(text,1,160) end

   -- si no lock file, crear lock file
   os.execute("ps x | grep dvr-snmpd | grep -v grep | cut -b 1-5 > /var/log/dvr-snmpd.pid")
   if(os.execute("test -f /var/lock/LCK.." .. puerto))==0 then
      return false
   end
   --print("sms>>>crear lock file")
   os.execute("cat /var/log/dvr-snmpd.pid > /var/lock/LCK.."..puerto)

   --[[ ahora envio mediante gsmsendsms (evitar perdida de algunos sms)
   -- set modem to 'text mode':
   cmd = "echo -e \"at+cmgf=1\\r\" >/dev/"..puerto.." && sleep 1"
   os.execute(cmd)
   -- envio de sms:
   cmd = "echo -e \"at+cmgs=\\\""..number.."\\\"\\r\" >/dev/"..puerto.." && sleep 1 && echo -e \""..text.."\\0032\" >/dev/"..puerto
   os.execute(cmd)
   --]]
   --cmd="gsmsendsms -d /dev/"..puerto.." -b 9600 "..number.." \""..text.."\""
   cmd='../../tools/enviaSMS 1 0 '..number..' "'..text..'"'
   ret=os.execute(cmd)

   -- remove lock file
   --print("sms>>>remove lock file")
   os.execute("rm -f /var/lock/LCK.."..puerto)

   --[[ seguridad ante posible fallo de gsmsendsms (peor!)
   if ret~=0 then
      return false
   end
   --]]

   return true
end
---------
-- Mantener estas tablas sincronizadas con MIB
ModemStatus = {
   "ocupado",
   "sinSim",
   "esperaPin",
   "esperaPuk",
   "libre",
   "fallo",
   "ppp",
}
index_modem = {}
for i,c in pairs(ModemStatus) do index_modem[c] = i end
--
local function sms_modem_status(data)
   local mstatus = access.get(sdscoreglib,zigorDvrObjModemStatus..".0")
   return mstatus
end
---------
--require "functions"  -- i18n
local sms_numbers={
   zigorDialUpSmsNum1,
   zigorDialUpSmsNum2,
   zigorDialUpSmsNum3,
   zigorDialUpSmsNum4,
}
--[[ OLD. Ahora en fichero de 'displays' para soporte multi-idioma
-- Mantener estas tablas sincronizadas con MIB
local Condicion = {  -- i18n
   _g("Activacion"),
   _g("Desactivacion"),
   _g("Reconocida"),
   _g("Bloqueada"),
}
local Severidad = {  -- i18n
   _g("Leve"),
   _g("Persistente"),
   _g("GRAVE"),
   _g("SEVERA"),
}
--]]
local function sms_handler(data)
   --print("sms>>>---------")
   --print("sms>>>sms handler")
   --
   -- envio (si es posible), uno cada iteracion, de los sms pendientes
   --
   if(sms_modem_status()~= index_modem["libre"]) then return true end
   --print("sms>>>modem libre")
   --
   local name=access.get(sdscoreglib,zigorSysName..".0")
   local location=access.get(sdscoreglib,zigorSysLocation..".0")
   --
   while(tsms_index_r ~= tsms_index_w) do
      --[[
      print("sms>>>hay pendientes: tsms_index_r:",tsms_index_r)
      for k,v in pairs(tsms[tsms_index_r].sms) do
         print("sms>>>sms:",k,v)
      end
      --]]
      for k,v in pairs(tsms[tsms_index_r].sms) do
         if v==0 then
	    local number = access.get(sdscoreglib,sms_numbers[k]..".0")
	    if number=="" then
	       --print("sms>>>no hay numero, anulo")
	       tsms[tsms_index_r].sms[k]=2
	    else
	       setlocale(sdscoreglib)
	       local displays = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
	       local display_descr = displays.display_descr

	       local descr = display_descr[tsms[tsms_index_r].descr]["display_sms"]
	       --local cond = Condicion[tsms[tsms_index_r].cond]
	       local cond = displays.display_condicion[tsms[tsms_index_r].cond]["display_sms"]
	       local date = os.date("%d/%m/%Y %H:%M:%S", os.time(ZDateAndTime2timetable(tsms[tsms_index_r].date)))
	       --local sev = Severidad[tsms[tsms_index_r].sev]
	       local sev = displays.display_severidad[tsms[tsms_index_r].sev]["display_sms"]
	       local cod = display_descr[tsms[tsms_index_r].descr]["codigo"]
	       local elements = tsms[tsms_index_r].elements
	       --print("sms>>>envio: ",descr,cond,date,sev,cod,elements)

	       local str = _g("Elementos")  -- i18n
	       --if(sms_send(number, name.." ("..location.."): /"..cod.."/ "..descr.." ("..cond.."/"..sev.."/"..str..": "..elements..") "..date..".")~=true) then
	       if(sms_send(number, name.." ("..location.."): /"..cod.."/ "..descr.." ("..cond.."/"..sev.."/"..str..": "..elements..") "..date..".")~=true) then
	          --print("sms>>>cancelo envio sms, existe lock file")
	          return true
	       end

	       -- se supone envio ok y se marca como enviado
	       -- XXX contemplar hacer resets periodicos del modem por si acaso...
	       tsms[tsms_index_r].sms[k]=1
	       return true
	    end
	 end
      end
      tsms_index_r = tsms_index_r + 1
      if tsms_index_r>tsms_index_max then
         tsms_index_r = 1
      end
      --print("sms>>>tsms_index_r:",tsms_index_r,"tsms_index_w:",tsms_index_w)
   end
   return true
end
---------
gobject.timeout_add(20000, sms_handler, nil)
----------------------------------------
