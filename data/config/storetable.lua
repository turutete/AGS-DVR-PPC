require "functions"
loadlualib("access")
loadlualib("accessx")
require "treestore"
require("gtk")
--
-- "helpers"
--
--[[
local old_print=print
local function print(...)
--   old_print("TABLE: ", unpack(arg) )
end
--]]
--

--
local function walk(sds, key)
   local oids={}
   local rev_oids={}
   local i=1
   local nextkey=accessx.getnextkey(sds, key) -- primero
   -- new (jur)
   if nextkey==nil then
     print("get KO porque tabla de log vacia.", key, nextkey)
   end
   ----
   while( nextkey and is_substring(nextkey, key) and nextkey~=key ) do
      oids[i]=nextkey
      rev_oids[nextkey]=i
      i=i+1
      nextkey=accessx.getnextkey(sds, nextkey) -- siguiente
      gtk.main_iteration_do(FALSE)
   end

   return oids,rev_oids
end
--
local function append_row(store, parent_row, presets)
   local row=treestore.append(store, parent_row)
   for col,v in pairs(presets) do
      --print(tostring(col).."="..tostring(v))
      treestore.set(store, row, col, v)
   end

   return row
end

----
-- Constructor de "objeto" storetable.
----
-- Parámetros:
-- sds:
--    Objeto "sds" (implementa AccessIf y AccessXIf)
-- store:
--    Objeto "store" (implementa TreestoreIf)
-- key_col:
--    Columna a usar para obtener las filas existentes
-- preset_row:
--    Tabla conteniendo parejas columna=valor para inicializar
--    las filas nuevas.
-- id_col:
--    Columna donde guardar el número de instancia (# de fila en la MIB)
-- keyvals:
--    Tabla conteniendo parejas columna_clave=columna_valor
--    para realizar el "polling".
--    (si columna_clave comienza por "." se toma como clave directa).
-- parent_row:
--    Referencia al nodo donde colgar las filas de la tabla.
function storetable_new(params)
   local sds,store,key,preset_row,id_col,keyvals,parent_row = unpack(params)
   local rows = {}
   
   local refresh_row = function(row)
			 local id=treestore.get(store, row, id_col)
			 for col_k,col_v in pairs(keyvals) do
			    local k
			    if string.sub(col_k,1,1) == "." then
			       k=col_k .."."..id
			    else
			       k=treestore.get(store, row, col_k)
			    end
			    if k then
			       local v=treestore.get(store, row, col_v)
			       local new_v=access.get(sds, k)
			       if new_v ~= v then
				  treestore.set(store, row, col_v, new_v)
			       end
			    end
			 end
		      end
   local refresh = function()
		      for oid,row in pairs(rows) do
			 refresh_row(row)
			 gtk.main_iteration_do(FALSE)
		      end
		   end
   local update = function()
		     local total=0
		     local add=0
		     local rm=0
		     local oids,roids=walk(sds, key)
      
		     for i,oid in pairs(oids) do
			--print(tostring(i) ..":".. tostring(oid))

			if rows[oid] then
			   -- limpiar fila
			   for col,v in pairs(keyvals) do
			      treestore.set(store, rows[oid], col, v)
			   end
			else
			   -- fila nueva
			   rows[oid]=append_row(store, parent_row, preset_row)
			   -- Añadimos número de instancia
			   local a,b,id=string.find(oid, "%.([^%.]*)$")
			   treestore.set(store, rows[oid], id_col, id)
			   --print(tostring(rows[oid]).."#"..id)
			   -- Refrescamos valores
			   refresh_row(rows[oid])
			   -- Actualizamos contador
			   add=add+1
			   total=total+1
			end
		     end
		     
		     -- borrar filas sobrantes
		     for oid,row in pairs(rows) do
			if not roids[oid] then
			   --print("remove: "..tostring(row))
			   treestore.remove(store, row)
			   rows[oid]=nil
			   -- Actualizamos contador
			   rm=rm+1
			end
		     end

		     return total,add,rm
		  end

   return {
      rows=rows,
      update=update,
      refresh=refresh,
   }
end
