require "oids-alarm"

require "functions"
loadlualib("access")
loadlualib("accessx")

-- Mantener estas tablas sincronizadas con MIB
AlarmCondition = {
   "activa",
   "inactiva",
   "reconocida",
   "bloqueada",
}
index_cond = {}
for i,c in pairs(AlarmCondition) do index_cond[c] = i end

AlarmSeverity = {
   "leve",
   "persistente",
   "grave",
   "severa",
}
index_sev = {}
for i,c in pairs(AlarmSeverity) do index_sev[c] = i end

----
-- Constructor de "objeto" alarmtable.
----
-- Parámetros:
-- sds:
--    Objeto "sds" (implementa AccessIf y AccessXIf)
-- keep_inactive:
--    booleano indicando si se deben mantener en la tabla
--    las alarmas inactivas.
-- mib_sync:
--    booleano indicando si se debe mantener la MIB sincronizada.
function alarmtable_new(params)
   local sds,keep_inactive,mib_sync = unpack(params)
   local alarms = {}
   local alarms_index = {}
   local present=0
   
   local set = function(descr, cond, elements, date)
		  local id = alarms_index[descr] or (#alarms + 1)
		  -- XXX comprobar MAX id

		  -- Convertir parámetro "cond" a numérico si es cadena
		  if type(cond)=="string" then cond=index_cond[cond] end

		  if not keep_inactive and AlarmCondition[cond]=="inactiva" then
		     -- Borrar evento
		     -- Sincronizar MIB (borrar)
		     if mib_sync and alarms[id] then
			for k,v in pairs(alarms[id]) do
			   access.set(sds, k .. "." .. tostring(id), nil)
			end
		     end
		     -- Si existe alarma en tabla, decrementamos contador
		     if alarms_index[descr] then
			present=present-1
		     end
		     -- Eliminar evento inactivo de la tabla
		     alarms[id]          = nil
		     alarms_index[descr] = nil
		  else
		     -- Añadir/actualizar evento en la tabla
		     alarms[id] = {
			[ zigorAlarmId          ] = id,
			[ zigorAlarmDescr       ] = descr,
			[ zigorAlarmTime        ] = date or os.date("%Y%m%d%H%M%S0%z"),
			[ zigorAlarmElementList ] = elements,
			[ zigorAlarmCondition   ] = cond,
		     }
		     -- Si es alarma nueva (no presente en índice) incrementamos contador
		     if not alarms_index[descr] then
			present=present+1
		     end
		     -- Añadimos al índice de alarmas
		     alarms_index[descr] = id
		     -- Sincronizar MIB
		     if mib_sync then
			for k,v in pairs(alarms[id]) do
			   access.set(sds, k .. "." .. tostring(id), v)
			end
		     end
		  end

		  -- Sincronizar número de alarmas en MIB
		  if mib_sync then
		     access.set(sds, zigorAlarmsPresent .. ".0", present)
		  end
	       end

   local get_descr = function(id)
			   for k,i in pairs(alarms_index) do
			      if i==id then
				 return k
			      end
			   end
			end

   return {
      set = set,
      get_descr = get_descr,
   }
end
