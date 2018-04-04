require "oids-alarm"
require "oids-alarm-log"
require "alarmtable"

require "functions"
loadlualib("access")
loadlualib("accessx")

----
-- Operaciones con "conjuntos" de elementos
----
local function ElementList2table(elements)
   local t={}

   for e in string.gmatch(elements, "([^ \t\n\r]+)") do
      t[e]=true
   end

   return t
end

-- Devuelve los elementos que están en "a" pero no en "b"
local function elements_diff(a, b)
   local t={}

   for e in pairs(a) do
      if not b[e] then
	 t[e]=true
      end
   end

   return t
end

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
------------------------

----
-- "helpers"
----
-- jur (deprecated!)
local function update_log_html(sds)
      package.loaded["alarmlog-" .. profile] = nil -- Forzamos recarga desde disco
      local t=require ("alarmlog-" .. profile)

      -- Implementar multi-idioma y OJO fichero debe ser utf8 para interpretar los acentos
      setlocale(sds)   -- require "functions" required.
      local displays = dofile("/usr/local/zigor/activa/ags-"..profile.."/share/config/displays-"..profile..".lua")  -- a ver si funciona 'profile'
      local display_descr = displays.display_descr

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
   <th>[N.]</th><th>[Date]</th><th>[Description]</th><th>[Code]</th><th>[Status]</th><th>[Severity]</th><th>[Elements]</th>
</theader>
<tbody>
]]
      local ddescr, dcond, date, cod, element, sev, dsev
      local alarms_config=get_alarm_config_index(sds)

      local fd=io.open("/home/user/alarmlog.html", "w") -- XXX path y sufijo "hardcoded"
      fd:write("<html>\n<body>\n")
      fd:write(style)
      
      for i,alarm in ipairs(t) do   -- ojo ipairs y no pairs
        ddescr = display_descr[alarm["descr"]]["display"]
        dcond = displays.display_condicion[alarm["cond"]]["display"]
        date = os.date("%d/%m/%Y/%H:%M:%S", os.time(ZDateAndTime2timetable(alarm["time"])))
        cod = display_descr[alarm["descr"]]["codigo"]
        sev=access.get(sds, zigorAlarmCfgSeverity ..".".. tostring(alarms_config[alarm["descr"]]))
        dsev = displays.display_severidad[sev]["display"]
        element=alarm["element"]
       
        local class
        if(i%2==1) then class='class="odd"' else class='class="even"' end
        fd:write('<tr '..class..'><td>'..i..'.</td><td>'..date..'</td><td>'..ddescr..'</td><td>'..cod..'</td><td>'..dcond..'</td><td>'..dsev..'</td><td>'..element..'</td></tr>\n')
      end
      fd:write("</tbody></table>\n</body>\n</html>\n")
      fd:close()
end

local function create_log_html()
      local html = [[
<!DOCTYPE html>
<html>
<head>
  <title>ALARM LOG</title>
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
    <th>[Date]</th><th>[Description]</th><th>[Code]</th><th>[Status]</th><th>[Severity]</th><th>[Elements]</th>
  </theader>
  <tbody>
  </tbody>
</table>
</body>
</html>
]]
   local fd=io.open("/home/user/alarmlog.html", "w") -- XXX path y sufijo "hardcoded"
   if fd then
      fd:write(html)
      fd:close()
   end
   os.execute("cp /home/user/alarmlog.html /home/user/alarmlog2.html")
end

local id=1
local function insert_log_row(sds,descr,time,element,cond, init)
   local LOG_MAX=5000
   --
   local this_id=id
   access.set(sds, zigorAlarmLogId          .. "." .. tostring(id), this_id)
   access.set(sds, zigorAlarmLogDescr       .. "." .. tostring(id), descr)
   access.set(sds, zigorAlarmLogTime        .. "." .. tostring(id), time)
   access.set(sds, zigorAlarmLogElementList .. "." .. tostring(id), element)
   access.set(sds, zigorAlarmLogCondition   .. "." .. tostring(id), cond)

   -- Comprobar "MaxEntries", QueueWraps, etc.
   local queue_wraps = access.get(sds, zigorAlarmLogQueueWraps .. ".0")
   local max_entries = access.get(sds, zigorAlarmLogMaxEntries .. ".0")
   local total_entries = access.get(sds, zigorAlarmLogTotalEntries .. ".0") or 0
   if(total_entries < id) then
      access.set(sds, zigorAlarmLogTotalEntries .. ".0", id)
   end
   if id < max_entries then
      id = id + 1
   else
      id=1
      queue_wraps = queue_wraps + 1
      access.set(sds, zigorAlarmLogQueueWraps .. ".0", queue_wraps)
   end
   access.set(sds, zigorAlarmLogIndex .. ".0", id)

   -- Escribir a disco (si no es "init")
   if not init then
      package.loaded["alarmlog-" .. profile] = nil -- Forzamos recarga desde disco
      local t=require ("alarmlog-" .. profile)
      if type(t)~="table" then t={} end
      t[this_id] = {
	 id      = this_id,
	 descr   = descr,
	 time    = time,
	 element = element,
	 cond    = cond,
      }
      local serial_t=serialize(t)
      local fd=io.open("../share/config/alarmlog-" .. profile .. ".lua", "w+") -- XXX path y sufijo "hardcoded"
      fd:write('local alarmlog = ')
      fd:write( serial_t )
      fd:write('\n\n')
      fd:write('return alarmlog,'.. tostring(id) ..','.. tostring(queue_wraps) ..'\n')
      fd:close()
      
      -- update_log_html(sds)
      -------------
      -- (new) html & csv! (idea sólo en inglés para simplificar)
      setlocale(sds, "en_GB.utf8")   -- require "functions" required.
      local displays = dofile("../share/config/displays-dvr.lua")
      local display_descr = displays.display_descr
      local alarms_config=get_alarm_config_index(sds)

      local ddescr = display_descr[descr]["display"]
      local dcond = displays.display_condicion[cond]["display"]
      local date = os.date("%d/%m/%Y/%H:%M:%S", os.time(ZDateAndTime2timetable(time)))
      local cod = display_descr[descr]["codigo"]
      local sev=access.get(sds, zigorAlarmCfgSeverity ..".".. tostring(alarms_config[descr]))
      local dsev = displays.display_severidad[sev]["display"]
       
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
      print("alarmlog html file!")
      local fd=io.open("/var/log/alarmlog_tmp.html", "w")
      local lines=0
      local flag_stop=false
      local file="/home/user/alarmlog.html"
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
	    new='    <tr '..class..'><td>'..date..'</td><td>'..ddescr..'</td><td>'..cod..'</td><td>'..dcond..'</td><td>'..dsev..'</td><td>'..element..'</td></tr>\n'
	    --]]
	    new='<tr><td>'..date..'</td><td>'..ddescr..'</td><td>'..cod..'</td><td>'..dcond..'</td><td>'..dsev..'</td><td>'..element..'</td></tr>\n'
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
      local cmd="cp /var/log/alarmlog_tmp.html /home/user/alarmlog.html"
      --print(cmd)
      os.execute(cmd)

      --- Nuevo fichero con info extra
      print("alarmlog2 html file!")
      local fd=io.open("/var/log/alarmlog2_tmp.html", "w")
      local lines=0
      local flag_stop=false
      local file="/home/user/alarmlog2.html"
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
	       new='<tr><td>'..date..'</td><td>'..ddescr..'</td><td>'..cod..'</td><td>'..dcond..'</td><td>'..dsev..'</td><td>'..element..'</td><td>'..extra..'</td></tr>\n'
	    else
	       new='<tr><td>'..date..'</td><td>'..ddescr..'</td><td>'..cod..'</td><td>'..dcond..'</td><td>'..dsev..'</td><td>'..element..'</td></tr>\n'
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
      local cmd="cp /var/log/alarmlog2_tmp.html /home/user/alarmlog2.html"
      --print(cmd)
      os.execute(cmd)
      
      -- csv file
      --print("csv file!")
      fd=io.open("/var/log/alarmlog_tmp.csv", "w")
      new = date..','..ddescr..','..cod..','..dcond..','..dsev..','..element..'\n'
      fd:write(new)
      print(new)
      fd:close()
      cmd='head -n '..tostring(LOG_MAX-1)..' /home/user/alarmlog.csv >>/var/log/alarmlog_tmp.csv; cp /var/log/alarmlog_tmp.csv /home/user/alarmlog.csv'
      --print(cmd)
      os.execute(cmd)
      ----------

      -- Emitir notificación de nueva fila insertada en histórico
      access.set(sds, zigorTrapAlarmLogEntryAdded, this_id)
   end

end

local function delete_log_row_by_id(sds,id)
   access.set(sds, zigorAlarmLogDescr       .. "." .. tostring(id), nil)
   access.set(sds, zigorAlarmLogTime        .. "." .. tostring(id), nil)
   access.set(sds, zigorAlarmLogElementList .. "." .. tostring(id), nil)
   access.set(sds, zigorAlarmLogCondition   .. "." .. tostring(id), nil)
   access.set(sds, zigorAlarmLogId          .. "." .. tostring(id), nil)
   local total_entries = access.get(sds, zigorAlarmLogTotalEntries .. ".0") or 0
   if total_entries > 0 then total_entries = total_entries-1 end
   access.set(sds, zigorAlarmLogTotalEntries .. ".0", total_entries)
end
------------------------


----
-- Constructor de "objeto" "alarmlogtable"
----
-- Parámetros
-- sds:
--    Objeto "sds" (implementa AccessIf y AccessXIf)
function alarmlogtable_new(params)
   local sds=unpack(params)
   local log = {}
   local log_cond = {}
   --
   local toggle=false

   local set = function(descr, cond, elements, date)
		  -- Pasamos ElementsList a tabla
		  elements=ElementList2table(elements)


		  local old_elements=log[descr] or {}

		  -- Obtener nuevos elementos activos
		  local new_elements_active   = elements_diff(elements, old_elements)
		  -- Obtener elementos que han pasado a inactivo
		  local new_elements_inactive = elements_diff(old_elements, elements)
		  
		  -- Insertamos filas de nuevos elementos activos
		  for e,v in pairs(new_elements_active) do
		     insert_log_row(sds, descr, date, e, index_cond["activa"])
		  end
		  -- jur. opcion de tambien insertar si condicion bloqueada o vuelta a activa
		  if cond==index_cond["bloqueada"] then
		     print("alt.set: insertar si condicion bloqueada") io.flush()
		     for e,v in pairs(elements) do
		        insert_log_row(sds, descr, date, e, cond)
		     end
		  elseif log_cond[descr]==index_cond["bloqueada"] and cond==index_cond["activa"] then
		     print("alt.set: insertar si activa tras bloqueada") io.flush()
		     for e,v in pairs(elements) do
		        insert_log_row(sds, descr, date, e, cond)
		     end
		  end
		  log_cond[descr]=cond

 		  -- Insertamos filas de elementos que han pasado a inactivo
 		  for e,v in pairs(new_elements_inactive) do
 		     insert_log_row(sds, descr, date, e, index_cond["inactiva"])
 		  end

		  -- Actualizar evento en la tabla
		  log[descr] = elements
	       end
   local insert = function(descr, cond, elements, date)
		     insert_log_row(sds, descr, date, elements, cond, false)
		  end

   local init = function()
		   local t,last_id,last_queue_wraps=dofile("../share/config/alarmlog-" .. profile .. ".lua") -- XXX path y sufijo "hardcoded"
		   for i,v in pairs(t) do
		      --set(v.descr, v.cond, v.element, v.time)
		      insert_log_row(sds, v.descr, v.time, v.element, v.cond, true)
		   end
		   id=last_id or id
		   access.set(sds, zigorAlarmLogQueueWraps .. ".0", last_queue_wraps or 0)
		   local date=os.date("%Y%m%d%H%M%S0%z")
		   insert_log_row(sds, zigorAlarmaStart, date, "1", index_cond["activa"], false)
		end

   local del_row_by_id = function(id)
			    delete_log_row_by_id(sds, id)
			 end

   local del_log = function()
		      -- borramos histórico de SDS
		      local key = zigorAlarmLogId
		      local nextkey=accessx.getnextkey(sds, key) -- primero
		      while( nextkey and is_substring(nextkey, key) and nextkey~=key ) do
			 local a,b,id=string.find(nextkey, "%.([0-9]*)$")
			 del_row_by_id(id)
			 nextkey=accessx.getnextkey(sds, nextkey) -- siguiente
		      end
		      -- borramos histórico de disco
		      local fd=io.open("../share/config/alarmlog-" .. profile .. ".lua", "w+") -- XXX path y sufijo "hardcoded"
		      fd:write('local alarmlog = ')
		      fd:write( "{}" )
		      fd:write('\n\n')
		      fd:write('return alarmlog,1,'..tostring(queue_wraps)..'\n')
		      fd:close()
		      -- inicializamos
		      id=1
		      -- XXX añadir un evento "borrado de histórico"
		      
		      --update_log_html(sds)
		      --cmd = [[sed -i '/tbody/,/\/tbody/d' /home/user/alarmlog.html; echo >/home/user/alarmlog.csv]]
		      create_log_html()
		      cmd = [[echo >/home/user/alarmlog.csv]]
		      print(cmd)
		      os.execute(cmd)
		   end

   --[[
   local update_html_log = function()
			    update_log_html(sds)
			 end
   --]]
   --
   init()
   return {
      set=set,
      del_log=del_log,
      -- exportamos función para insertar una fila sin control de estado
      insert=insert,
      --update_html_log=update_html_log,
   }
end
------------------------
