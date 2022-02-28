--
-- Edici�n
-- XXX
loadlualib("gobject")
loadlualib("access")
require("gtk")
require "treestore"
require "functions"  -- i18n
require 'sha1'

local edit_same_units = true -- indica si la edici�n se hace en las mismas unidades que se muestra valor
local factor_prefix = {
   [10]      = "d",
   [100]     = "c",
   [1000]    = "m",
   [1000000] = "u", -- XXX usar s�mbolo unicode de "micro"
}

local edit_data = {}
local w_hbox_last_pass     = gobject.get_data(ui, "hbox_last_pass")
local w_last_pass_entry    = gobject.get_data(ui, "last_pass_entry")
local w_edit_name          = gobject.get_data(ui, "edit_name")

gobject.set_property(w_hbox_last_pass, "visible", false)
gobject.set_property(w_last_pass_entry, "text", "")

function edit_row_changed(object, iter, store)

   local key   = treestore.get(store, iter, "key") -- oid correspondiente al parametro.
   local id    = treestore.get(store, iter, "id")
   if id then key = key .. "." .. id end
   local val   = treestore.get(store, iter, "val")
   local name  = treestore.get(store, iter, "name")
   local units = treestore.get(store, iter, "units") or ""
   local enum  = nil
   local factor= treestore.get(store, iter, "factor")

   --En el momento de seleccionar otr parametro, limpio el mensaje de la barra de estatus.
   gtk.statusbar_push(w_statusbar, "edit", "")

   --JC dev
   print("edit_row_changed key-->", key)
   print("edit_row_changed id-->", id)
   print("edit_row_changed val-->", val)
   print("edit_row_changed name-->", name)
   print("edit_row_changed units-->", units)





   if not edit_same_units then
      if factor>0 then
	 local prefix = factor_prefix[factor] or tostring(1/factor)
	 units = prefix .. units
      end
   end

   gobject.set_property(w_edit_name, "label", name or "")
   gobject.set_property(w_edit_units, "label", units or "")

   -- Si combobox
   local w_edit = nil
   if enums then
      w_edit = gtk.bin_get_child(w_edit_val)
   end
   -- Si entry
   if not w_edit then w_edit = w_edit_val end


   -- obtenemos "edit config."
   local ec
   if edit_config and key then
      ec = edit_config[key] or edit_config[string.gmatch(key, "(.*)%.[^%.]+$")()]
   end

   -- Texto de entrada es "display" o "val" si "display" es no visible
   gobject.set_property(w_edit, "invisible-char", string.byte("*") ) -- Car�cter invisible por defecto
   if ec and ec.hide then
      gobject.set_property(w_edit, "text", treestore.get(store, iter, "val") or "")
      -- Car�cter invisible opcional
      if type(ec.hide)=="string" then
	 gobject.set_property(w_edit, "invisible-char", string.byte(ec.hide) )
      end
   else
      gobject.set_property(w_edit, "text", treestore.get(store, iter, "display") or "")
   end
   -- Establecemos visibilidad del texto de entrada
   gobject.set_property(w_edit, "visibility", not (ec and ec.hide))

   -- Solo si esta interfaz tiene definidos enums en edici�n
   local model
   if enums then
      enum = treestore.get(store, iter, "enum")
      -- Establece enum (o 'enum_void' si no enum)
      model = _G[enum]
      if model then
	 gobject.set_property(w_edit, "can-focus", false)
      else
	 gobject.set_property(w_edit, "can-focus", true)
	 if enum_void then model = enum_void end
      end

      if model then
	 gobject.set_property(w_edit_val, "model", model)
      end
   end
   --

   edit_data.key   = key
   edit_data.val   = val
   if edit_same_units then
      edit_data.factor= factor
   end
   if enum then
      edit_data.model = model
   else
      edit_data.model = nil
   end

   -- si la clave que se va a editar es alguna password, se visibiliza la edicion de la pass actual y se cambia el texto a "New Password"
   if   key == zigorSysPasswordPass .. ".4" or
        key == zigorSysPasswordPass .. ".3" or
        key == zigorSysPasswordPass .. ".2" or
        key == zigorSysPasswordPass .. ".1" then


                gobject.set_property(w_hbox_last_pass, "visible", true)
                gobject.set_property(w_hbox_last_pass, "sensitive", true)
                gobject.set_property(w_edit, "text", "")
                gobject.set_property(w_edit_name, "label", _g("Nueva password:"))
   else
                gobject.set_property(w_hbox_last_pass, "visible", false)
                gobject.set_property(w_last_pass_entry, "text", "")
   end

   edit_val_changed()
end



-- En esta funcion se comprueba si la pass se puede cambiar porque
-- al introducir la nueva password también se ha validado el valor de la password actual.
-- param key: oid del dato que se va a modificar
-- param valor: valor a establecer en el nuevo OID
-- return: devuelve valor verdadero en caso de que el parametro a cambiar no sea la password (por lo que sea lo que sea lo que se va a cambiar, se puede hacer sin comprobacion) o en caso de
--         de que sea la pass y se haya validado correctamente el valor de la pass actual
--         devuelve false en el caso de que lo que se quiera cambiar sea la password pero no se haya validado correctamente la pass actual.
function check_password_change(key, valor)

        local level_key                 --OID de tipo password concatenado con el nivel del usuario.
        local current_pass              --valor de la clave actual que se debe validar y que se escribe en una caja de texto en la interfaz.
        local current_pass_salted       --la pass actual con el string de sal concatenado
        local current_pass_hashed       --clave actual hasheada
        local hash_actual               --Clave actual leida del OID
        local new_pass                  --nueva pass hasheada a devolver

        print("check_password_change: " ..  key .. "=" .. valor)

        if is_substring(key, zigorSysPasswordPass) then

                local nivel_de_acceso
                _,_,nivel_de_acceso=string.find(key, "%.(%d+)$")
                print("nivel de acceso = " .. nivel_de_acceso)

                level_key = zigorSysPasswordPass .. "." .. nivel_de_acceso

                --En caso de cambiar la pass, chequeamos la validacion del campo del valor de la pass actual.
                current_pass=gobject.get_property(w_last_pass_entry, "text") -- tipo "string"
                current_pass_salted = current_pass .. "LEVEL" .. nivel_de_acceso
                current_pass_hashed = sha1.hex(current_pass_salted)
                hash_actual = access.get(sds, level_key)


                if hash_actual == current_pass_hashed then
                        print("match de pass hashead")
                        new_pass = sha1.hex(valor .. "LEVEL" .. access_level)
                        return true, new_pass
                else
                        print("no coincide pass hashead")
                        return false,nil
                end

        else
                --si no se va a cambiar la pass, devolvemos true para no afectar al proceso.
                return true,nil
        end

end -- end de check_password_change


-- Funcion a ejecutar cuando se pulsa el boton w_edit_button  un dato cambiado. No se guarda definitivamente, solo hasta que se pulse el botob "Guardar".
local edit_id
function edit(object, sds)


   local key=edit_data.key
   print("edit.lua -> edit: Key = ", key)

   -- Si combobox
   local w_edit = nil
   if enums then
      w_edit = gtk.bin_get_child(w_edit_val)
   end
   -- Si entry
   if not w_edit then w_edit = w_edit_val end

   local val=gobject.get_property(w_edit, "text") -- tipo "string"

   -- Obtenemos valor de enumerado
   if enums then
      local table=enums[edit_data.model]
      if table then
	 if table[val] then val=table[val] end
      end
   end

   -- Funci�n de formateo opcional
   if edit_config[key] then
      local ec=edit_config[key]
      if ec.format then
	 val=ec.format(val, edit_data.val, ec.format_args)
      end
   end

   if type(edit_data.val)=="number" then -- comprobamos si la variable es tipo "number", entonces...

      val=tonumber(val)                  -- pasamos nuevo valor a "number" y el marshalling hace el resto
      if edit_data.factor and edit_data.factor~=0 then
	 val=val*edit_data.factor
      end
   end

   if(key and val and sds) then

        local check_pass
        local new_pass
        check_pass,new_pass = check_password_change(key,val)

        if new_pass then
                val = new_pass
        end

        if check_pass == true then

            if edit_id then
      	         gtk.statusbar_pop(w_statusbar, "edit", edit_id)
            end

            edit_id=gtk.statusbar_push(w_statusbar, "edit", _g("Estableciendo valor..."))
            gtk.main_iteration_do(FALSE);
            local err=access.set(sds, key, val)
            print("key a escribir = " .. key .. "" .. "val a escribir = " .. val)

            gtk.statusbar_pop(w_statusbar, "set", edit_id)
            local msg
            if err==0 then
      	         msg=_g("Valor establecido.")
            else
      	         msg=_g("Error, no se pudo establecer valor.")
            end
            gtk.statusbar_push(w_statusbar, "edit", msg)
        end
   end

end --end de funcion.

function edit_val_changed()
   -- Si combobox
   print("edit_val_changed")
   local w_edit = nil
   if enums then
      w_edit = gtk.bin_get_child(w_edit_val)
   end
   -- Si entry
   if not w_edit then w_edit = w_edit_val end

   -- obtenemos "edit config."
   local ec
   if edit_config and edit_data.key then
      ec = edit_config[edit_data.key] or edit_config[string.gmatch(edit_data.key, "(.*)%.[^%.]+$")()]
   end

   if ec then
      local val=gobject.get_property(w_edit, "text") -- tipo "string"
      print("Edicion de parametro: ", val)
      if val=="" then
	 gtk.colorize_as_empty(w_edit)
	 -- Comprobamos si puede ser vac�o
	 if ec.null then
	    gobject.set_property(w_edit_button, "sensitive", true)
	 else
	    gobject.set_property(w_edit_button, "sensitive", false)
	 end
      else
	 -- check
	 if ec.check and ec.check(val, ec.check_args) then
	    gtk.colorize_as_valid(w_edit)
	    gobject.set_property(w_edit_button, "sensitive", true)
	 else
	    gtk.colorize_as_invalid(w_edit)
	    gobject.set_property(w_edit_button, "sensitive", false)
	 end
      end
   else
      -- sin "edit config" edici�n normal
      gobject.set_property(w_edit_button, "sensitive", true)
      gtk.colorize_as_empty(w_edit)
   end
end
