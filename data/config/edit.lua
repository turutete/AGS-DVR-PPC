--
-- Edición
-- XXX
loadlualib("gobject")
require("gtk")
require "treestore"

require "functions"  -- i18n

local edit_same_units = true -- indica si la edición se hace en las mismas unidades que se muestra valor
local factor_prefix = {
   [10]      = "d",
   [100]     = "c",
   [1000]    = "m",
   [1000000] = "u", -- XXX usar símbolo unicode de "micro"
}

local edit_data = {}
function edit_row_changed(object, iter, store)
   local key   = treestore.get(store, iter, "key")
   local id    = treestore.get(store, iter, "id")
   if id then key = key .. "." .. id end
   local val   = treestore.get(store, iter, "val")
   local name  = treestore.get(store, iter, "name")
   local units = treestore.get(store, iter, "units") or ""
   local enum  = nil
   local factor= treestore.get(store, iter, "factor")

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
   gobject.set_property(w_edit, "invisible-char", string.byte("*") ) -- Carácter invisible por defecto
   if ec and ec.hide then
      gobject.set_property(w_edit, "text", treestore.get(store, iter, "val") or "")
      -- Carácter invisible opcional
      if type(ec.hide)=="string" then
	 gobject.set_property(w_edit, "invisible-char", string.byte(ec.hide) )
      end
   else
      gobject.set_property(w_edit, "text", treestore.get(store, iter, "display") or "")
   end
   -- Establecemos visibilidad del texto de entrada
   gobject.set_property(w_edit, "visibility", not (ec and ec.hide) )

   -- Solo si esta interfaz tiene definidos enums en edición
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

   edit_val_changed()
end

local edit_id
function edit(object, sds)
   local key=edit_data.key

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

   -- Función de formateo opcional
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
      if edit_id then
	 gtk.statusbar_pop(w_statusbar, "edit", edit_id)
      end

      edit_id=gtk.statusbar_push(w_statusbar, "edit", _g("Estableciendo valor..."))
      gtk.main_iteration_do(FALSE);
      local err=access.set(sds, key, val)
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

function edit_val_changed()
   -- Si combobox
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
      if val=="" then
	 gtk.colorize_as_empty(w_edit)
	 -- Comprobamos si puede ser vacío
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
      -- sin "edit config" edición normal
      gobject.set_property(w_edit_button, "sensitive", true)
      gtk.colorize_as_empty(w_edit)
   end
end
