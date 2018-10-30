-- IMPORTANTE: ESTE FICHERO ESTÁ EN UTF-8

require "functions"
require "oids-dvr"
require "oids-parameter" --XXX
require "oids-alarm"

loadlualib("gobject")
loadlualib("access")
require "treestore"

-- Forzar acceso síncrono (no usar cache)
local cache=gobject.get_property(sds, "cache")
gobject.set_property(sds, "cache", false)

-- i18n test
print(">>>>>>>>> i18n test (Estado):", _g("Estado"))

-- Inicialización
--local pb_logo=gobject.get_data(pixbufs, "logo")
local pb_gray=gobject.get_data(pixbufs, "gris")
local pb_green=gobject.get_data(pixbufs, "verde")
local pb_red=gobject.get_data(pixbufs, "rojo")
local pb_gray2=gobject.get_data(pixbufs, "gris2")

--local w_logo=gobject.get_data(ui, "logo")
local w_notebook    = gobject.get_data(ui, "notebook1")
local w_button_estado = gobject.get_data(ui, "button_estado")
local w_button_params = gobject.get_data(ui, "button_parametros")
local w_button_alarms = gobject.get_data(ui, "button_alarmas")
local w_button_hevent = gobject.get_data(ui, "button_heventos")
local w_button_term   = gobject.get_data(ui, "button_terminar")
---
local w_button_rmlog           = gobject.get_data(ui, "button_borrar_heventos")
local w_button_huecos          = gobject.get_data(ui, "button_huecos")
local w_button_huecos_borrar   = gobject.get_data(ui, "button_huecos_borrar")
local w_button_huecos_heventos = gobject.get_data(ui, "button_huecos_heventos")
---
local w_label_section      = gobject.get_data(ui, "label_section")
gobject.set_property(w_label_section, "visible", false)
local w_label_level        = gobject.get_data(ui, "label_level")
--gobject.set_property(w_logo, "pixbuf", pb_logo)
local level_str=_g("Nivel de acceso")
gobject.set_property(w_label_level, "label", level_str..": "..tostring(access_level) )

local w_alarm_state_image = gobject.get_data(ui, "alarm_state_image")
local w_param_state_image = gobject.get_data(ui, "param_state_image")
local w_param_state_label = gobject.get_data(ui, "param_state_label")
local w_label_time        = gobject.get_data(ui, "label_time")
-- Botones actuacion
--local w_button_marcha = gobject.get_data(ui, "button_marcha")
--local w_button_paro   = gobject.get_data(ui, "button_paro")
--local w_button_reset  = gobject.get_data(ui, "button_reset")
-- Botones confirmacion
local w_button_ok     = gobject.get_data(ui, "button_ok")
local w_button_cancel = gobject.get_data(ui, "button_cancel")

local w_image_heartbeat   = gobject.get_data(ui, "image_heartbeat")
local w_event_alarm_state_img = gobject.get_data(ui, "event_alarm_state_img")
local w_event_level = gobject.get_data(ui, "event_label_level")

-- sinoptico
local pb_sin = gobject.get_data(pixbufs, "sinoptico")
local pb_sin_on = gobject.get_data(pixbufs, "sinoptico_on")
local w_sin = gobject.get_data(ui, "img_sin")
gobject.set_property(w_sin, "pixbuf", pb_sin)
--
local w_button_sin = gobject.get_data(ui, "button_sin")
local w_lab_vr = gobject.get_data(ui, "lab_vr")
local w_lab_vs = gobject.get_data(ui, "lab_vs")
local w_lab_vt = gobject.get_data(ui, "lab_vt")
local w_lab_aux = gobject.get_data(ui, "lab_aux")
local w_lab_vsr = gobject.get_data(ui, "lab_vsr")
local w_lab_vss = gobject.get_data(ui, "lab_vss")
local w_lab_vst = gobject.get_data(ui, "lab_vst")
local w_lab_isr = gobject.get_data(ui, "lab_isr")
local w_lab_iss = gobject.get_data(ui, "lab_iss")
local w_lab_ist = gobject.get_data(ui, "lab_ist")
local w_lab_psr = gobject.get_data(ui, "lab_psr")
local w_lab_pss = gobject.get_data(ui, "lab_pss")
local w_lab_pst = gobject.get_data(ui, "lab_pst")
local w_estado = gobject.get_data(ui, "lab_estado")
local w_button_mar = gobject.get_data(ui, "button_mar")
local w_button_par = gobject.get_data(ui, "button_par")
local w_button_res = gobject.get_data(ui, "button_res")
--
local w_ball = gobject.get_data(ui, "img_ball")
gobject.set_property(w_ball, "pixbuf", pb_gray)
----

-- i18n
gobject.set_property(gobject.get_data(ui, "image_idioma"), "pixbuf", gobject.get_data(pixbufs, "idioma"))
gobject.set_property(gobject.get_data(ui, "image_tab_idioma"), "pixbuf", gobject.get_data(pixbufs, "idioma"))

local w_button_idioma_ok = gobject.get_data(ui, "button_idioma_ok")
local w_combo_idioma = gobject.get_data(ui, "combo_idioma")
local w_button_idioma_cancel = gobject.get_data(ui, "button_idioma_cancel")

local button_labels={
   [1] = gobject.get_data(ui, "label_button_estado"),
   [2] = gobject.get_data(ui, "label_button_parametros"),
   [3] = gobject.get_data(ui, "label_button_alarmas"),
   [4] = gobject.get_data(ui, "label_button_heventos"),
   [6] = gobject.get_data(ui, "label_button_huecos"),
   [8] = gobject.get_data(ui, "label_button_sin"),
}

local w_idioma_params_button = gobject.get_data(ui, "idioma_params_button")
--gobject.connect(w_idioma_params_button, "clicked", function() gobject.set_property(w_notebook,"page",6) end )  -- XXX
local w_hbuttonbox_menu  = gobject.get_data(ui, "hbuttonbox_menu")
gobject.connect(w_idioma_params_button, "clicked", function() gobject.set_property(w_hbuttonbox_menu, "sensitive", false) gobject.set_property(w_notebook, "page", 6) end )

local w_button_descargas  = gobject.get_data(ui, "button_descargas")
-- de momento pasar del boton:
gobject.set_property(w_button_descargas, "visible", false)
w_statusbar   = gobject.get_data(ui, "statusbar1")

--[[ ya no hace falta
local w_label_idioma = gobject.get_data(ui, "label_idioma")
local label_t=gobject.get_property(w_label_idioma, "label")
gobject.set_property(w_label_idioma, "label", '<span size="large">'..label_t..'</span>')

local w_label_confirma = gobject.get_data(ui, "label_confirma")
local label_t=gobject.get_property(w_label_confirma, "label")
gobject.set_property(w_label_confirma, "label", '<span size="large">'..label_t..'</span>')
--]]

----------------------------------------
local iters = {}

local NIVEL_MIN_FABRICA = 2
local NIVEL_MIN_RMLOG = 3
local NIVEL_MIN_ACTUACIONES = 2
local NIVEL_MIN_BUTTON_REBOOT = 2
local NIVEL_MIN_RESET_ALARMAS=2
----------------------------------------
-- Cargar/Salvar parámetros (configuración)
--
local function action_params(object, action)
   --XXX
   if(access_level_key ~= access.get(sds,zigorSysPasswordPass .. "." .. tostring(access_level))) then
      --cambio de password de nivel actual -> reiniciar
      gobject.main_loop_quit(main_loop)
      print("Exit por cambio de nivel de acceso")
      os.exit()  -- mas robustez?
   end
   --
   access.set(sds, zigorCtrlParamState .. ".0", tonumber(action) )
end

local w_save_params_button    = gobject.get_data(ui, "save_params_button")
local w_cancel_params_button  = gobject.get_data(ui, "cancel_params_button")
local w_factory_params_button = gobject.get_data(ui, "factory_params_button")

gobject.connect(w_save_params_button,    "clicked", action_params, 1)
gobject.connect(w_cancel_params_button,  "clicked", action_params, 2)
-- XXX (jur)
--gobject.connect(w_factory_params_button, "clicked", action_params, 3)

function func_CtrlParamState(w, iter)
   local pb   =treestore.get(w, iter, "pic")
   local lb   =treestore.get(w, iter, "display")
   local state=treestore.get(w, iter, "val")
   gobject.set_property(w_param_state_image, "pixbuf", pb)
   gobject.set_property(w_param_state_label, "label", lb)
   
   -- Cambiar estado botones de configuración
   if     state == 1 then -- temp(1)
      gobject.set_property(w_save_params_button,    "sensitive", true)
      gobject.set_property(w_cancel_params_button,  "sensitive", true)
      -- habilitar boton de fabrica solo en niveles permitidos
      if access_level>=NIVEL_MIN_FABRICA then
         gobject.set_property(w_factory_params_button, "sensitive", true)
      end
   elseif state == 2 then -- active(2)
      gobject.set_property(w_save_params_button,    "sensitive", false)
      gobject.set_property(w_cancel_params_button,  "sensitive", false)
      -- habilitar boton de fabrica solo en niveles permitidos
      if access_level>=NIVEL_MIN_FABRICA then
         gobject.set_property(w_factory_params_button, "sensitive", true)
      end
   elseif state == 3 then -- factory(3)
      gobject.set_property(w_save_params_button,    "sensitive", true)
      gobject.set_property(w_cancel_params_button,  "sensitive", true)
      gobject.set_property(w_factory_params_button, "sensitive", false)
   end
end


--------------------------------------------------
-- Factorías varias
-- Factoría para generar funciones de formateo de celdas con magnitudes (volts, ampers, etc.)
local function factory_cell_format(model, key, col, factor, units, name, size, color)
   local label = nil

   return function()
	     local aux   = treestore.get(model, iters[key], col)
	     
	     if(aux) then
		local v = myround(aux / (factor or 1) ); -- pasamos a Volts
		label = name .. v .. units
		-- (jur) span
		label ="<span foreground='"..color.."' weight='bold' font_desc='"..size.."'>" .. label .. "</span>"
	     end
	     return label
	  end
end

-- Factoría para generar funciones que establecen propiedad de un objeto con el resultado de una función
local function factory_object_property(object, prop_name, func)
   return function()
	     gobject.set_property(object, prop_name, func() )
	  end
end

--------------------------------------------------
--fun_vr = factory_object_property(w_lab_vr, "label", factory_cell_format(store, zigorDvrObjVRedR .. ".0", "val", 10, " V", "V1 = ") )
--fun_vr = factory_object_property(w_lab_vr, "label", factory_cell_format(store, zigorDvrObjVRedR .. ".0", "val", 10, " V", "", "22", "green") )
fun_vr = factory_object_property(w_lab_vr, "label", factory_cell_format(store, zigorDvrObjVRedR .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_vs = factory_object_property(w_lab_vs, "label", factory_cell_format(store, zigorDvrObjVRedS .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_vt = factory_object_property(w_lab_vt, "label", factory_cell_format(store, zigorDvrObjVRedT .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_vsr = factory_object_property(w_lab_vsr, "label", factory_cell_format(store, zigorDvrObjVSecundarioR .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_vss = factory_object_property(w_lab_vss, "label", factory_cell_format(store, zigorDvrObjVSecundarioS .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_vst = factory_object_property(w_lab_vst, "label", factory_cell_format(store, zigorDvrObjVSecundarioT .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_isr = factory_object_property(w_lab_isr, "label", factory_cell_format(store, zigorDvrObjISecundarioR .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_iss = factory_object_property(w_lab_iss, "label", factory_cell_format(store, zigorDvrObjISecundarioS .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_ist = factory_object_property(w_lab_ist, "label", factory_cell_format(store, zigorDvrObjISecundarioT .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_psr = factory_object_property(w_lab_psr, "label", factory_cell_format(store, zigorDvrObjPSalidaR .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_pss = factory_object_property(w_lab_pss, "label", factory_cell_format(store, zigorDvrObjPSalidaS .. ".0", "val", 10, "", "", "22", "#1d9d26") )
fun_pst = factory_object_property(w_lab_pst, "label", factory_cell_format(store, zigorDvrObjPSalidaT .. ".0", "val", 10, "", "", "22", "#1d9d26") )

local function fun_estado(w)
   local estado = treestore.get(w, iters[zigorDvrObjEstadoControl .. ".0"    ], "display")
   
   if estado then
      local t = estado
      -- importante habilitar propiedades de 'pango markup' a la etiqueta en glade! :-)
      --t='<span weight="ultrabold" foreground="blue" variant="smallcaps" size="large">' .. t .. '</span>'
      --t='<span weight="bold" foreground="#261d9d" size="large">' .. t .. '</span>'
      t='<span weight="bold" foreground="#1d949d" size="large">' .. t .. '</span>'
      gobject.set_property(w_estado, "label", t)
   
   end
end

local function fun_ball(w)
   local val =treestore.get(w, iters[zigorDvrObjEstadoControl .. ".0" ],  "val")
   
   if(val) then
      if(val==4) then  -- on XXX OJO hardcoded
	 gobject.set_property(w_ball, "pixbuf", pb_green)
      elseif(val==1) then  -- off XXX OJO hardcoded
	 gobject.set_property(w_ball, "pixbuf", pb_gray2)
      else
	 gobject.set_property(w_ball, "pixbuf", pb_red)
      end
   else
      gobject.set_property(w_ball, "pixbuf", pb_gray)
   end

   -- flujo sinoptico
   if val==4 then  -- ON
      gobject.set_property(w_sin, "pixbuf", pb_sin_on)
   else
      gobject.set_property(w_sin, "pixbuf", pb_sin)
   end
end

local funcs = {
   [ zigorCtrlParamState .. ".0" ] = {func_CtrlParamState, },
   [ zigorDvrObjVRedR .. ".0" ]    = {fun_vr, },
   [ zigorDvrObjVRedS .. ".0" ]    = {fun_vs, },
   [ zigorDvrObjVRedT .. ".0" ]    = {fun_vt, },
   [ zigorDvrObjVSecundarioR .. ".0" ] = {fun_vsr, },
   [ zigorDvrObjVSecundarioS .. ".0" ] = {fun_vss, },
   [ zigorDvrObjVSecundarioT .. ".0" ] = {fun_vst, },
   [ zigorDvrObjISecundarioR .. ".0" ] = {fun_isr, },
   [ zigorDvrObjISecundarioS .. ".0" ] = {fun_iss, },
   [ zigorDvrObjISecundarioT .. ".0" ] = {fun_ist, },
   [ zigorDvrObjPSalidaR .. ".0" ]     = {fun_psr, },
   [ zigorDvrObjPSalidaS .. ".0" ]     = {fun_pss, },
   [ zigorDvrObjPSalidaT .. ".0" ]     = {fun_pst, },
   [ zigorDvrObjEstadoControl .. ".0" ] = {fun_estado, fun_ball},
}
----------------------------------------
-- Acceso a elementos de la 'ui' en funcion del nivel de acceso:
--
-- deshabilitar botones de cargar cfg de fabrica en niveles no permitidos
if access_level<NIVEL_MIN_FABRICA then
   gobject.set_property(w_factory_params_button, "sensitive", false)
end
-- deshabilitar botones de borrar historicos en niveles no permitidos
if access_level<NIVEL_MIN_RMLOG then
   gobject.set_property(w_button_rmlog,          "sensitive", false)
   gobject.set_property(w_button_huecos_borrar,  "sensitive", false)
end
-- deshabilitar botones de actuaciones en nivel en niveles no permitidos
if access_level<NIVEL_MIN_ACTUACIONES then
   --gobject.set_property(w_button_marcha, "sensitive", false)
   --gobject.set_property(w_button_paro,   "sensitive", false)
   --gobject.set_property(w_button_reset,  "sensitive", false)
   gobject.set_property(w_button_mar, "sensitive", false)
   gobject.set_property(w_button_par,   "sensitive", false)
   gobject.set_property(w_button_res,  "sensitive", false)
end

local w_button_reboot = gobject.get_data(ui, "button_reboot")
local w_button_test = gobject.get_data(ui, "button_test")
if access_level<NIVEL_MIN_BUTTON_REBOOT then
   gobject.set_property(w_button_reboot, "sensitive", false)
   gobject.set_property(w_button_test, "visible", false)  -- XXX
else
   gobject.set_property(w_button_test, "visible", true) -- XXX
end

local w_hbuttonbox_reboot = gobject.get_data(ui, "hbuttonbox_reboot")
gobject.set_property(w_hbuttonbox_reboot, "visible", false)

-- discriminar seleccion en tree para mostrar/ocultar botones
local function treeseleccion(w, iter)
   print("changed_rowsig") io.flush()
   local str = treestore.get(store, iter, "name")
   if(string.match(str, _g("Sistema"))) then   -- XXX ojo si se cambia la etiqueta (DANGEROUS)
      gobject.set_property(w_hbuttonbox_reboot, "visible", true)
   else
      gobject.set_property(w_hbuttonbox_reboot, "visible", false)
   end
end
gobject.connect(treeview, "changed_rowsig", treeseleccion)
----------------------------------------

--
-- Confirmación
--
local confirma_params = {}
local function confirma_cancel(w)   
   gobject.set_property(w_hbuttonbox_menu, "sensitive", true)
   gobject.set_property(w_notebook, "page", confirma_params.oldpage)
end
local function confirma_ok(w)
   if confirma_params.f then
      confirma_params.f(w, unpack(confirma_params.params) )
   end
   gobject.set_property(w_hbuttonbox_menu, "sensitive", true)
   gobject.set_property(w_notebook, "page", confirma_params.oldpage)
end
local function confirma(w, args)
   confirma_params.f      = args.f
   confirma_params.params = args.params
   confirma_params.oldpage  = gobject.get_property(w_notebook, "page")
   gobject.set_property(w_hbuttonbox_menu, "sensitive", false)
   gobject.set_property(w_notebook, "page", 4)
end

--
gobject.connect(w_button_ok,                 "clicked", confirma_ok)
gobject.connect(w_button_cancel,             "clicked", confirma_cancel)

-- boton reboot
local function reboot(w, args)
   print("reboot sistema") io.flush()
   os.execute("reboot")
end
gobject.connect(w_button_reboot, "clicked", confirma, { f=reboot, params={ sds, }, } )

local function rmlog(w, sds)
		   local msg = _g("Borrando histórico...")
		   local bar_id=gtk.statusbar_push(w_statusbar, "bar", msg)
		   gtk.main_iteration_do(FALSE);
		   local err=access.set(sds, zigorAlarmLogTotalEntries .. ".0", 0)
		   gtk.statusbar_pop(w_statusbar, "bar", bar_id)
		   if err==0 then
		      msg=_g("Histórico borrado.")
		   else
		      msg=_g("Error, no se pudo borrar histórico.")
		   end
		   gtk.statusbar_push(w_statusbar, "bar", msg)
		   heventos_dirty=true
		   --
		   --[[ ahora integrado en alarmlogtable.lua > del_log > llamada a update para refresco del fichero
		   local cmd="rm /home/user/alarmlog.html"
		   os.execute(cmd)
		   --]]
end

local function rmsaglog(w, sds)
		   local msg = _g("Borrando histórico...")
		   local bar_id=gtk.statusbar_push(w_statusbar, "bar", msg)
		   gtk.main_iteration_do(FALSE);
		   local err=access.set(sds, zigorDvrGapLogTotalEntries .. ".0", 0)
		   gtk.statusbar_pop(w_statusbar, "bar", bar_id)
		   local msg
		   if err==0 then
		      msg=_g("Histórico borrado.")
		   else
		      msg=_g("Error, no se pudo borrar histórico.")
		   end
		   gtk.statusbar_push(w_statusbar, "bar", msg)

		   gaplog_dirty=true
end

--XXX (jur)
gobject.connect(w_factory_params_button, "clicked", confirma, { f=action_params, params={ 3, }, } )
gobject.connect(w_button_rmlog,  "clicked", confirma, { f=rmlog, params={ sds, }, } )
gobject.connect(w_button_huecos_borrar,  "clicked", confirma, { f=rmsaglog, params={ sds, }, } )
----------------------------------------
--
-- Actuaciones
--
local function marcha(w, sds)
   access.set(sds, zigorDvrObjOrdenMarcha .. ".0", 1)
end
local function paro(w, sds)
   access.set(sds, zigorDvrObjOrdenParo .. ".0", 1)
end
local function reset(w, sds)
   access.set(sds, zigorDvrObjOrdenReset .. ".0", 1)
end

--gobject.connect(w_button_marcha,   "clicked", confirma, { f=marcha,   params={ sds, }, } )
--gobject.connect(w_button_paro,     "clicked", confirma, { f=paro,     params={ sds, }, } )
--gobject.connect(w_button_reset,    "clicked", confirma, { f=reset,    params={ sds, }, } )
gobject.connect(w_button_mar,   "clicked", confirma, { f=marcha,   params={ sds, }, } )
gobject.connect(w_button_par,   "clicked", confirma, { f=paro,     params={ sds, }, } )
gobject.connect(w_button_res,   "clicked", confirma, { f=reset,    params={ sds, }, } )

----------------------------------------

local displays_dvr=require "displays-dvr"
local display_imp       = displays_dvr.display_imp
local display_imp_param = displays_dvr.display_imp_param

-- Tabla "displays": key = display
local displays = {
-- variables
   [ zigorDvrObjEstadoControl .. ".0"      ] = displays_dvr.display_EstadoControl,
   --
   [ zigorDvrObjParado .. ".0"             ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjErrorVInst .. ".0"         ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjSaturado .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjPwmOndOn .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjBypassOn .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjPwmRecOn .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjDeteccionEnable .. ".0"    ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaVBusMax .. ".0"      ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaVCondMax .. ".0"     ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaVBusMin .. ".0"      ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaVRed .. ".0"         ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjLimitIntVSal .. ".0"       ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjErrorPLL .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaDriver .. ".0"       ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjParadoError .. ".0"        ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjErrorDriver .. ".0"        ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjErrorTermo .. ".0"         ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjLimitando .. ".0"          ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjErrorFusible .. ".0"       ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjRegHueco .. ".0"           ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjAlarmaPLL .. ".0"          ] = displays_dvr.display_ActivoInact_RG,
   [ zigorDvrObjResetDriver .. ".0"        ] = displays_dvr.display_ActivoInact_RG,
   --
   [ zigorDvrObjEComDSP .. ".0"            ] = displays_dvr.display_SiNo_RG,
   --
   [ zigorDvrObjModemStatus .. ".0"        ] = displays_dvr.display_ModemStatus,
-- parametros
   [ zigorAlarmCfgSeverity                 ] = displays_dvr.display_imp_param,
   -- estado configuración
   [ zigorCtrlParamState .. ".0"           ] = displays_dvr.display_CtrlParamState,
   --
   [ zigorSysPasswordPass                  ] = displays_dvr.display_PasswordPass,
   [ zigorDialUpPin .. ".0"                ] = displays_dvr.display_DialUpPin,
   [ zigorSysDate .. ".0"                  ] = displays_dvr.display_Date,
   [ zigorSysTimeZone .. ".0"              ] = displays_dvr.display_TimeZone,
   [ zigorSysNotificationLang .. ".0"      ] = displays_dvr.display_NotificationLang,
   [ zigorAlarmCfgNotification             ] = displays_dvr.display_notification,
   ---
   [ zigorNetSmtpPass .. ".0"              ] = displays_dvr.display_PasswordPass,
   --- modbus
   [ zigorModbusBaudrate .. ".0" ] = displays_dvr.display_MBBaudrate,
   [ zigorModbusParity .. ".0"   ] = displays_dvr.display_MBParity,
   [ zigorModbusMode .. ".0"     ] = displays_dvr.display_MBMode,
   ---
   [ zigorCtrlParamDemo .. ".0"            ] = displays_dvr.display_SiNo_GR,
   [ zigorNetEnableSnmp .. ".0"            ] = displays_dvr.display_SiNo_GR,
   [ zigorNetVncPassword .. ".0"           ] = displays_dvr.display_PasswordPass,
}

--- Actualizar la info de 'pic' si tabla de displays en otro fichero (y en ese fichero ahora el valor de pic convertir a texto)
for k,v in pairs(displays) do
   for val,t in pairs(v) do
      if t.pic then
         if t.pic=="pb_gray" then
	    t.pic = pb_gray
         elseif t.pic=="pb_green" then
	    t.pic = pb_green
         elseif t.pic=="pb_red" then
	    t.pic = pb_red
	 end
      end
   end
end
---

local handler_id -- forward declaration
local function display(w, iter, k, data)
   local v=treestore.get(w, iter, "val")

   if v then
      gobject.block(w, handler_id)

      if displays[k] then
	 -- enums
	 local d=displays[k][v] or displays[k].default
	 if d then
	    for col, newval in pairs(d) do
	       if type(newval) ~= "function" then
		  treestore.set(w, iter, col, newval)
	       else
		  treestore.set(w, iter, col, newval(v) )
	       end
	    end
	 end
      else
	 -- magnitudes y cadenas
	 local factor = treestore.get(w, iter, "factor")
	 local disp_str
	 if factor~=0 then
	    v=tonumber(v)/factor
	    disp_str=string.format("%.0".. tostring(string.len(factor)-1) .."f", v)
	 else
	    disp_str=tostring(v)
	 end
	 treestore.set(w, iter, "display", disp_str)
      end

      gobject.unblock(w, handler_id)
   end
end

-- Callback llamado ante un cambio en una fila del store
local function changed(w, path, iter, data)
   local k=treestore.get(w, iter, "key")

   -- cacheamos iters de variables
   if k and not iters[k] then
      iters[k] = iter
   end

   -- actualizamos "display"
   display(w, iter, k, data)

   -- Llamamos a la función que se encarga de esta variable
   if funcs[k] then
      --funcs[k](w, iter)
      for i,f in pairs(funcs[k]) do
         f(w, iter)
      end
   end

   -- XXX test!
   --   collectgarbage()
end

handler_id=gobject.connect(store, "row-changed", changed, nil)

----------------------------------------
local bar_id
--
-- Navegación
--
local current_w=w_button_estado
gobject.set_property(current_w,  "sensitive", false)
local function factory_notebook_page(nb, p, w)
   return 
   function()
      gobject.set_property(current_w,  "sensitive", true)
      current_w=w
      
      --gobject.set_property(w_label_section, "label", "<b>".. gobject.get_property(current_w, "label")  .."</b>")
      ----gobject.set_property(w_label_section, "label", "<b>".. gobject.get_property(button_labels[p+1], "label")  .."</b>")  -- i18n
      gobject.set_property(current_w,  "sensitive", false)
      gobject.set_property(nb,         "page",      p    )
      --
      gtk.statusbar_pop(w_statusbar, "bar", barid)  -- XXX
   end
end

local p_estado = factory_notebook_page(w_notebook, 0, w_button_estado)
local p_params = factory_notebook_page(w_notebook, 1, w_button_params)
local p_alarms = factory_notebook_page(w_notebook, 2, w_button_alarms)
local p_hevent = factory_notebook_page(w_notebook, 3, w_button_hevent)
local p_huecos = factory_notebook_page(w_notebook, 5, w_button_hevent)
local p_sin    = factory_notebook_page(w_notebook, 7, w_button_sin)
gobject.connect(w_button_sin, "clicked", p_sin)
gobject.connect(w_button_estado, "clicked", p_estado )
gobject.connect(w_button_params, "clicked", p_params )
gobject.connect(w_button_alarms, "clicked", p_alarms )
gobject.connect(w_button_hevent, "clicked", p_hevent )
gobject.connect(w_button_huecos_heventos, "clicked", p_hevent )
gobject.connect(w_button_huecos, "clicked", p_huecos )
gobject.connect(w_event_alarm_state_img, "button_press_event", p_alarms)
gobject.connect(w_button_term,   "clicked",
	function(w, ml)
		--if remote==0 then
		if remote==0 and access_level>1 then  -- no hacer si ya en nivel 1
			-- salir con nivel basico (1)
			script = os.getenv("LAUNCH")
			cmd=[[sed -i -e 's/ACCESS_LEVEL=.*/ACCESS_LEVEL=ZZZ/' ]] .. script
			cmd = string.gsub(cmd,"ZZZ", "1")
			print(cmd)
			os.execute(cmd)		
		end
		gobject.main_loop_quit(ml)
		print("Exit por boton terminar")
		os.exit()  -- mas robusto?
	end,
	main_loop)
----gobject.connect(w_button_rmlog,  "clicked", rmlog, sds)

--
gobject.connect(w_button_descargas,  "clicked",
		function(w, sds)
		   --gtk.statusbar_pop(w_statusbar, "ftp", ftp_id)
		   local ip = access.get(sds, zigorNetIP..".0")
		   local msg = _g("Descargas por acceso FTP")
		   msg = msg ..". ftp://".. ip .." (user,zigor)"
		   local bar_id = gtk.statusbar_push(w_statusbar, "bar", msg)
		   gtk.main_iteration_do(FALSE);
		end,
		sds)

----gobject.connect(w_button_huecos_borrar,  "clicked", rmsaglog, sds)

-- Sección inicial: Estado
--p_estado()
p_sin()

----------------------------------------
--
-- displays para tablas de alarma e histórico
-- XXX pasar resto de displays de dvr a fichero de displays
local display_descr = displays_dvr.display_descr

-- pixbufs
w_activo    =gobject.get_data(pixbufs, "activo")
w_inactivo  =gobject.get_data(pixbufs, "inactivo")
w_reconocido=gobject.get_data(pixbufs, "reconocido")
w_bloqueado =gobject.get_data(pixbufs, "bloqueado")

require "alarmtable" -- XXX index_cond
local display_cond = {
   [index_cond.activa    ] = { pic = w_activo, },
   [index_cond.inactiva  ] = { pic = w_inactivo, },
   [index_cond.reconocida] = { pic = w_reconocido, },
   [index_cond.bloqueada ] = { pic = w_bloqueado, },
}

alarm_cfg=get_alarm_config_index(sds)

----------------------------------------------
-- Tabla de alarmas
----------------------------------------------
alarm_dirty=true
do
   require "storetable"

   -- Preparamos parámetros para storetable
   local firstrow=treestore.first(alarms_store)
   local presets = { 
      --
   }
   local keyvals = {
      [ zigorAlarmDescr       ] = "descr",
      [ zigorAlarmTime        ] = "time",
      [ zigorAlarmElementList ] = "elements",
      [ zigorAlarmCondition   ] = "cond",
      [ "imp-key"             ] = "imp",
   }
   local id_col="id"
   
   alarm_st=storetable_new{sds, alarms_store, zigorAlarmId, presets, id_col, keyvals, firstrow}
   local function alarm_update() 
      if alarm_dirty then
	 local total=alarm_st.update()
	 alarm_st.refresh()
	 -- obtener estado global de alarmas
	 local global_alarm_state=index_cond.inactiva
	 for oid,row in pairs(alarm_st.rows) do
	    local cond=treestore.get(alarms_store, row, "cond")
	    if cond == index_cond.activa or cond == index_cond.bloqueada then
	       global_alarm_state=index_cond.activa
	       break
	    elseif cond == index_cond.reconocida then
	       global_alarm_state=index_cond.reconocida
	    end
	 end	 
	 gobject.set_property(w_alarm_state_image, "pixbuf", display_cond[global_alarm_state].pic)
	 -- Si tabla vacía, reintento periódico
	 if total~=0 then
	    alarm_dirty=false
	 end
      end
      -- XXX aprovechamos que es función periódica para actualizar reloj
      gobject.set_property(w_label_time, "label", os.date("%H:%M"))

      return true
   end
   gobject.timeout_add(2000, alarm_update, nil)

   --
   -- Gestión de "displays" de alarmas
   --
   alarm_displays = {
      [ zigorAlarmDescr ]       = display_descr,
      [ zigorAlarmCondition ]   = display_cond,
      [ zigorAlarmCfgSeverity ] = display_imp,
      -- XXX completar
   }
   
   local alarm_handler_id -- forward declaration
   local function alarm_display(s, iter, keyvals)
      -- Inicializar clave de severidad
      if not treestore.get(s, iter, "imp-key") then
	 local descr=treestore.get(s, iter, "descr")
	 if descr then
	    gobject.block(s, alarm_handler_id)
	    treestore.set(s, iter, "imp-key", zigorAlarmCfgSeverity .. "." .. alarm_cfg[descr])
	    gobject.unblock(s, alarm_handler_id)
	 end
      end

      for key_col,val_col in pairs(keyvals) do
	 local k
	 if string.sub(key_col, 1, 1) == "." then
	    k=key_col
	 else
	    k=treestore.get(s, iter, key_col)
	 end
	 local v=treestore.get(s, iter, val_col)
	 if k and v then
	    gobject.block(s, alarm_handler_id)
	    local display = alarm_displays[k] or alarm_displays[string.gmatch(k, "(.*)%.[^%.]+$")()]
	    if display then
	       -- enums
	       local d=display[v] or display.default
	       if d then
		  for col, newval in pairs(d) do
		     if type(newval) ~= "function" then
			treestore.set(s, iter, col, newval)
		     else
			treestore.set(s, iter, col, newval(v) )
		     end
		  end
	       end
	    else
	       -- magnitudes y cadenas
	       -- XXX no se contempla en tabla de alarmas
	    end
	    
	    gobject.unblock(s, alarm_handler_id)
	 end
      end
      -- Actualizar "display" de fecha
      local t=treestore.get(s, iter, "time")
      if t then
	 gobject.block(s, alarm_handler_id)
	 
	 local tt=ZDateAndTime2timetable(t)
	 t_display=os.date("%d/%m/%y %H:%M:%S", os.time(tt))
	 treestore.set(s, iter, "time-display", gobject.locale_to_utf8(t_display) or "?")
	 
	 gobject.unblock(s, alarm_handler_id)
      end
      -- actualizamos estado (activo/reconocido)
      local reconocido=treestore.get(s, iter, "ack")
      if reconocido then
	 gobject.block(s, alarm_handler_id)
	 treestore.set(s, iter, "pic", w_reconocido)
	 gobject.unblock(s, alarm_handler_id)
      end
      -- reseteamos evento
      local reset=treestore.get(s, iter, "reset")
      if reset then
      if treestore.get(s, iter, "cond")==index_cond.bloqueada 
      and access_level>=NIVEL_MIN_RESET_ALARMAS then  -- XXX (jur)
	    local id = treestore.get(s, iter, "id")
	    local msg = _g("Reseteando alarma...")
	    local bar_id=gtk.statusbar_push(w_statusbar, "bar", msg)
	    gtk.main_iteration_do(FALSE);
	    local err=access.set(sds, zigorAlarmCondition .. "." .. tostring(id), index_cond.inactiva)
	    gtk.statusbar_pop(w_statusbar, "bar", bar_id)
	    if err==0 then
	       msg=_g("Alarma reseteada.")
	    else
	       msg=_g("Error, no se pudo resetear alarma.")
	    end
	    gtk.statusbar_push(w_statusbar, "bar", msg)
     end
     gobject.block(s, alarm_handler_id)
     treestore.set(s, iter, "reset", false)
     gobject.unblock(s, alarm_handler_id)
     end
   end

   -- Callback llamado ante un cambio en una fila del store de alarmas
   local function alarm_changed(s, path, iter, data)
      -- actualizamos "display"
      alarm_display(s, iter, data)
   end
   
   alarm_handler_id=gobject.connect(alarms_store, "row-changed", alarm_changed, keyvals)
end
-- FIN Tabla de alarmas --

----------------------------------------------
-- Tabla de h. eventos
----------------------------------------------
heventos_dirty=true
do
   require "storetable"
   require "oids-alarm-log"

   -- pixbufs
   w_activo    =gobject.get_data(pixbufs, "activo")
   w_inactivo  =gobject.get_data(pixbufs, "inactivo")
   w_reconocido=gobject.get_data(pixbufs, "reconocido")
   
   -- Preparamos parámetros para storetable
   local firstrow=treestore.first(heventos_store)
   local presets = { 
      --
   }
   local keyvals = {
      [ zigorAlarmLogDescr       ] = "descr",
      [ zigorAlarmLogTime        ] = "time",
      [ zigorAlarmLogElementList ] = "element",
      [ zigorAlarmLogCondition   ] = "cond",
      [ "imp-key"                ] = "imp",
   }
   local id_col="id"
   
   heventos_st=storetable_new{sds, heventos_store, zigorAlarmLogId, presets, id_col, keyvals, firstrow}
   function heventos_update() 
      if heventos_dirty then
	 local total=heventos_st.update()
	 heventos_st.refresh()
	 -- Si tabla vacía, reintento periódico
	 if total~=0 then
	    heventos_dirty=false
	 end
      end

      return true
   end
   gobject.timeout_add(2000, heventos_update, nil)
   
   --
   -- Gestión de "displays" de h. eventos
   --
   -- XXX Usar display de alarmas (mismos OIDs de alarma)
   heventos_displays = {
      [ zigorAlarmLogDescr ]     = display_descr,
      [ zigorAlarmLogCondition ] = display_cond,
      [ zigorAlarmCfgSeverity ]  = display_imp,
      -- XXX completar
   }
   
   local heventos_handler_id -- forward declaration
   local function heventos_display(s, iter, keyvals)
      -- Inicializar clave de severidad
      local descr=treestore.get(s, iter, "descr")
      if descr then
	 gobject.block(s, heventos_handler_id)
	 treestore.set(s, iter, "imp-key", zigorAlarmCfgSeverity .. "." .. alarm_cfg[descr])
	 gobject.unblock(s, heventos_handler_id)
      end

      for key_col,val_col in pairs(keyvals) do
	 local k
	 if string.sub(key_col, 1, 1) == "." then
	    k=key_col
	 else
	    k=treestore.get(s, iter, key_col)
	 end
	 local v=treestore.get(s, iter, val_col)
	 if k and v then
	    gobject.block(s, heventos_handler_id)
	    local display = heventos_displays[k] or heventos_displays[string.gmatch(k, "(.*)%.[^%.]+$")()]
	    if display then
	       -- enums
	       local d=display[v] or display.default
	       if d then
		  for col, newval in pairs(d) do
		     if type(newval) ~= "function" then
			treestore.set(s, iter, col, newval)
		     else
			treestore.set(s, iter, col, newval(v) )
		     end
		  end
	       end
	    else
	       -- magnitudes y cadenas
	       -- XXX no se contempla en tabla de h. eventos
	    end
	    
	    gobject.unblock(s, heventos_handler_id)
	 end
	 -- Actualizar "display" de fecha
	 local t=treestore.get(s, iter, "time")
	 if t then
	    gobject.block(s, heventos_handler_id)
	    
	    local tt=ZDateAndTime2timetable(t)
	    t_display=os.date("%d/%m/%y %H:%M:%S", os.time(tt))
	    treestore.set(s, iter, "time-display", gobject.locale_to_utf8(t_display) or "?")
	    
	    gobject.unblock(s, heventos_handler_id)
	 end
      end
   end

   -- Callback llamado ante un cambio en una fila del store de h. eventos
   local function heventos_changed(s, path, iter, data)
      -- actualizamos "display"
      heventos_display(s, iter, data)
   end
   
   heventos_handler_id=gobject.connect(heventos_store, "row-changed", heventos_changed, keyvals)
end
-- FIN Tabla de h. eventos  --

----------------------------------------
--
-- Tabla de h. eventos de hueco
--
gaplog_dirty=true
do
   require "storetable"
--   require "oids-dvr"  --XXX

   -- Preparamos parámetros para storetable
   local firstrow=treestore.first(gaplog_st)
   local presets = {
      --
   }
   local keyvals = {
      [ zigorDvrGapLogMinimo   ] = "minimo",
      [ zigorDvrGapLogIntegral ] = "integral",
      [ zigorDvrGapLogTiempo   ] = "tiempo",
      [ zigorDvrGapLogFase     ] = "fase",
      [ zigorDvrGapLogTime     ] = "time",
   }
   local id_col="id"
   
   gaplog_st_poll = storetable_new{sds, gaplog_st, zigorDvrGapLogId, presets, id_col, keyvals, firstrow}
   local function gaplog_update()
      if gaplog_dirty then
	 local total=gaplog_st_poll.update()
	 gaplog_st_poll.refresh()
	 -- Si tabla vacía, reintento periódico
	 if total~=0 then
	    gaplog_dirty=false
	 end
      end

      return true
   end
   gobject.timeout_add(2000, gaplog_update, nil)

   --
   -- Gestión de "displays" de h. eventos de hueco
   --
   local display_fase = displays_dvr.display_hueco
   gaplog_displays = {
      [ zigorDvrGapLogFase     ] = display_fase,
   }
   
   local titulo='<span underline="single">'.._g("Ultimo Hueco")..':</span>'
   gobject.set_property(w_lab_aux, "label", titulo.."\n\n\n")
   local gaplog_rowchanged_handler_id -- forward declaration
   local function gaplog_display(s, iter, keyvals)
      --- aprovechamos para actualizar info hueco en sinoptico:
      local minimo=treestore.get(s, iter, "minimo")
      local duracion=treestore.get(s, iter, "tiempo")
      local datos=nil
      local fecha=nil
      if minimo and duracion then
         datos=_g("Mínimo").." = "..minimo.." %\n".._g("Duración").." = "..duracion.." ms"
      end
      ------
      for key_col,val_col in pairs(keyvals) do
	 local k
	 if string.sub(key_col, 1, 1) == "." then
	    k=key_col
	 else
	    k=treestore.get(s, iter, key_col)
	 end
	 local v=treestore.get(s, iter, val_col)
	 if k and v then
	    gobject.block(s, gaplog_rowchanged_handler_id)
	    local display = gaplog_displays[k] or gaplog_displays[string.gmatch(k, "(.*)%.[^%.]+$")()]
	    if display then
	       -- enums
	       local d=display[v] or display.default
	       if d then
		  for col, newval in pairs(d) do
		     if type(newval) ~= "function" then
			treestore.set(s, iter, col, newval)
		     else
			treestore.set(s, iter, col, newval(v) )
		     end
		  end
	       end
	    else
	       -- magnitudes y cadenas
	       -- XXX no se contempla en tabla de h. eventos
	    end
	    
	    gobject.unblock(s, gaplog_rowchanged_handler_id)
	 end
	 -- Actualizar "display" de fecha
	 local t=treestore.get(s, iter, "time")
	 if t then
	    gobject.block(s, gaplog_rowchanged_handler_id)
	    
	    local tt=ZDateAndTime2timetable(t)
	    t_display=os.date("%d/%m/%y %H:%M:%S", os.time(tt))
	    treestore.set(s, iter, "time-display", gobject.locale_to_utf8(t_display) or "?")
	    --- aprovechamos para actualizar info hueco en sinoptico:
	    fecha = gobject.locale_to_utf8(t_display)
	    ------
	    
	    gobject.unblock(s, gaplog_rowchanged_handler_id)
	 end
      end  -- for
      --- aprovechamos para actualizar info hueco en sinoptico:
      if datos and fecha then
	 gobject.set_property(w_lab_aux, "label", titulo.."\n"..fecha.."\n"..datos)
      end
      -- XXX dev (pb Olarizu no update last log!!)
      --print("--->>> minimo, duracion, datos, t, fecha", minimo, duracion, datos, t, fecha)
      ------
   end

   -- Callback llamado ante un cambio en una fila del store de h. eventos
   local function gaplog_rowchanged(s, path, iter, data)
      -- actualizamos "display"
      gaplog_display(s, iter, data)
   end
   
   gaplog_rowchanged_handler_id=gobject.connect(gaplog_st, "row-changed", gaplog_rowchanged, keyvals)

end
-- FIN Tabla de h. eventos de hueco --

----------------------------------------
--
-- Edición de parámetros
--
do
   require "parameter"
   edit_config = require "config-edit-dvr"

   w_edit_name   = gobject.get_data(ui, "edit_name")
   w_edit_val    = gobject.get_data(ui, "edit_val")
   w_edit_units  = gobject.get_data(ui, "edit_units")
   w_edit_button = gobject.get_data(ui, "edit_button")
   --w_statusbar   = gobject.get_data(ui, "statusbar1")

   require "edit"

   gobject.connect(infoview_cfg,  "changed_rowsig", edit_row_changed, store)
   gobject.connect(w_edit_button, "clicked",        edit,             sds)
   gobject.connect(w_edit_val,    "changed",        edit_val_changed, nil)
end

----------------------------------------
--
-- Inicializar enumerados
--
-- Tabla global de enumerados
enums = {}
do
   local function insert_enum(enum_store, enum_table) 
      local lookup_table = {}
      for i,t in pairs(enum_table) do
	 local text,n=next(t)
	 local row=treestore.append(enum_store, nil)
	 treestore.set(enum_store, row, "n", n)
	 treestore.set(enum_store, row, "text", text)
	 lookup_table[text] = n
      end

      -- Insertar en tabla de enumerados global
      enums[enum_store] = lookup_table
   end
   ----------------------------------------------------
   -- Tablas de enumerados
   table_AlarmCfgSeverity = display2enum(display_imp_param)
   table_NotificationLang = display2enum(displays_dvr.display_NotificationLang)
   table_AlarmCfgNotification = display2enum(displays_dvr.display_notification)
   table_TimeZone = display2enum(displays_dvr.display_TimeZone)
   table_MBBaudrate = display2enum(displays_dvr.display_MBBaudrate)
   table_MBParity = display2enum(displays_dvr.display_MBParity)
   table_MBMode = display2enum(displays_dvr.display_MBMode)
   table_SiNo = display2enum(displays_dvr.display_SiNo_GR)
   
   -- Inicialización enumerados a partir de tablas
   insert_enum(enum_AlarmCfgSeverity, table_AlarmCfgSeverity)
   insert_enum(enum_NotificationLang, table_NotificationLang)
   insert_enum(enum_AlarmCfgNotification, table_AlarmCfgNotification)
   insert_enum(enum_TimeZone, table_TimeZone)
   insert_enum(enum_MBBaudrate, table_MBBaudrate)
   insert_enum(enum_MBParity, table_MBParity)
   insert_enum(enum_MBMode, table_MBMode)
   insert_enum(enum_SiNo, table_SiNo)
   
   -- Inicializamos comboboxentry
   gobject.set_property(w_edit_val, "model",       enum_void )
   gobject.set_property(w_edit_val, "text-column", treestore.get_col_number(enum_void, "text") )
end

-- Restaurar configuración cache
gobject.set_property(sds, "cache", cache)

-- Terminar ante inactividad (requiere reinicio externo)
gobject.connect(mainwin, "inactivitysig", function(w, ml)
      -- (new) en local salir reestableciendo el nivel basico (1) SI nivel mayor
      if remote==0 and access_level>1 then
         script = os.getenv("LAUNCH")
         cmd=[[sed -i -e 's/ACCESS_LEVEL=.*/ACCESS_LEVEL=ZZZ/' ]] .. script
         cmd = string.gsub(cmd,"ZZZ", 1)
         print(cmd)
         os.execute(cmd)
	 --
         gobject.main_loop_quit(ml)
         print("Exit por inactividad")
         os.exit()  -- mas robustez?
      elseif remote==1 then
         gobject.main_loop_quit(ml)
         print("Exit por inactividad")
         os.exit()  -- mas robustez?
      end
   end, main_loop)

----------------------------------------------
-- Gestión de notificaciones ("traps") del SDS
----------------------------------------------
local trapsig_handler_id -- "forward declaration"
local function trapsig_handler(sds, uptime, trapoid, m, v)
   -- pasamos "members" a tabla Lua y sin número de instancia
   members={}
   for i=1,100 do -- XXX límite inalcanzable, salimos con un "break" cuando se acaba el "array"
      if m[i] then
	 local _,_,k=string.find(m[i], "(.*)%.[0-9]+$")
	 members[k]=v[i]
      else
	 break
      end
   end
   -- Acción en función de "trap"
   if trapoid==zigorTrapAlarmLogEntryAdded then
      -- Comprobamos qué alarma se ha añadido al histórico
      if members[zigorAlarmLogDescr] == zigorAlarmaPasswdChange then
	 -- Se ha cambiado el password, comprobamos si es el de nuestro nivel
	 -- (requiere reiniciar)
	 if tonumber(members[zigorAlarmLogElementList]) == access_level then
	    -- XXX mostrar advertencia de reinicio
	    gobject.main_loop_quit(main_loop)
	    io.stderr:write("Exit por cambio de password de nivel actual")
	    -- XXX salida "drastica" para evitar bloqueo
	    os.exit()
	 end
      end
      -- Actualizamos vistas eventos e histórico
      alarm_dirty    = true
      heventos_dirty = true
   elseif trapoid==zigorTrapDvrGapLogEntryAdded then
      -- Actualizamos vistas histórico de huecos
      gaplog_dirty    = true
   end
end

-- Conectar a notificaciones ("traps") del SDS
trapsig_handler_id=gobject.connect(sds, "trapsig", trapsig_handler)
----------------------------------------------

----------------------------------------------
-- Gestión de "heartbeat" comunicación con SDS
----------------------------------------------
local last_date
local hb_pb=pb_gray -- "heartbeat pixbuf"
local function heartbeat_update(sds)
   local date=access.get(sds, zigorSysDate..".0")
   if date==last_date then
      -- Error de comunicación
      gobject.set_property(w_image_heartbeat, "pixbuf", pb_red)
   else
      -- Comunicación ok
      if hb_pb==pb_gray then
	 hb_pb=pb_green
      else
	 hb_pb=pb_gray
      end
      gobject.set_property(w_image_heartbeat, "pixbuf", hb_pb)
   end

   return true
end

-- Comprobación periódica comunicación con SDS ("heartbeat")
gobject.timeout_add(1000, heartbeat_update, sds)
----------------------------------------------

function cambio_idioma(object, sds)  -- i18n
   --local val=gobject.get_property(w_combo_idioma, "text-column")  -- KO
   local w_edit = gtk.bin_get_child(w_combo_idioma)
   local val=gobject.get_property(w_edit, "text")
   print(val)

   if val=="Spanish" then
      --locale="es_ES.utf8"
      locale=""
   elseif val=="English" then
      locale = "en_GB.utf8"
   elseif val=="Chinese" then
      locale = "zh_CN.utf8"
   else
      print("seleccion KO")
      return
   end
   locale_ant = os.getenv("LC_ALL")
   print("LC_ALL",locale_ant)
   if(locale==locale_ant) then
      print("mismo locale")
      --p_estado()
      gobject.set_property(w_hbuttonbox_menu, "sensitive", true)
      p_params()
      return
   end
   
   script = os.getenv("LAUNCH")
   cmd=[[sed -i -e 's/LC_ALL=".*"/LC_ALL="LOCALE"/' ]] .. script
   cmd = string.gsub(cmd,"LOCALE",locale)
   print(cmd)
   os.execute(cmd)

   -- exit:
   gobject.main_loop_quit(main_loop)
   io.stderr:write("Exit por cambio de idioma")
   os.exit()

end
gobject.connect(w_button_idioma_ok, "clicked", cambio_idioma, sds)

gobject.connect(w_button_idioma_cancel, "clicked", function() gobject.set_property(w_hbuttonbox_menu, "sensitive", true) p_params() end, sds)

----------
--- GUI keyboard!
local w_hbtbox1_kb2 = gobject.get_data(ui, "hbtbox1_kb2")
local w_hbtbox2_kb2 = gobject.get_data(ui, "hbtbox2_kb2")

local function enable_kb2(enable)
   gobject.set_property(w_hbtbox1_kb2, "visible", enable)
   gobject.set_property(w_hbtbox2_kb2, "visible", enable)
end
enable_kb2(false)

---
local zkbd
zkbd=io.open("/dev/kbde", "w")
---

------------------
--[[
-- no funciona siempre bien (?) (usar el child (GtkEntry) en lugar de el GtkComboBoxEntry)
local function edit_val_press(w, event, data)
   print(">>>edit_val_press!")
   enable_kb2(true)
end
if remote==0 then  -- mostrar teclado solo en local
   gobject.connect(w_edit_val, "button-press-event", edit_val_press)
end

-- no ha funcionado nunca
local function edit_val_popup(w, event, data)
   print(">>>edit_val popup!!!")
   enable_kb2(true)
end
if remote==0 then  -- mostrar teclado solo en local
   gobject.connect(w_edit_val, "popup-menu", edit_val_popup)
end
--]]

local function edit_press(w, event, data)
   --print(">>>edit_press!!!")
   enable_kb2(true)
   
   ----gtk.widget_grab_focus(w)
   return true  -->> (!)importante: si return TRUE, se para la emision del 'click' para evitar el posterior popup!
end

------
local function edit_popup(w, event, data)
   --print(">>>edit_popup!!!")
   enable_kb2(true)
end

------
local function edit_populate(w, menu, data)
   print(">>>populate-popup!!!")
   --KO?--gobject.stop(w, "populate-popup")  -- XXX
end
---
-- pruebas con el child:
local w_edit = gtk.bin_get_child(w_edit_val)  -- ahora lidiamos con GtkEntry
--gobject.connect(w_edit, "populate-popup", edit_populate)  -- OK (cuando salta pop-up al mantener el dedo (=click mouse dcho)
--gobject.connect(w_edit, "popup-menu", edit_popup)  -- KO!
if remote==0 then  -- mostrar teclado solo en local
   --gobject.connect(w_edit, "button-press-event", edit_press)  -- OK!
   gobject.connect(w_edit, "button-release-event", edit_press)  -- OK! (usar release en lugar de press para evitar cortar callbacks de grabar el foco etc!)
end

--  XXX test
local function firefox(w, key)
   print(">>>firefox!")
   cmd='su - user -c "DISPLAY=:0 firefox -width 1024 -height 600 http://maps.pqube.com"'
   os.execute(cmd)
end
--gobject.connect(w_button_term, "populate-popup", firefox)
gobject.connect(w_button_test, "clicked", firefox)

------------------
-- gestion boton mostrar/ocultar teclado edicion
-- ahora ya hacemos con gestion de 'button-press-event'
w_btkb2 = gobject.get_data(ui, "btkb2")
gobject.set_property(w_btkb2, "visible", false)
--[[
local toggle=0
if remote==1 then  -- mostrar teclado solo en local
   gobject.set_property(w_btkb2, "visible", false)
else
   gobject.connect(w_btkb2, "clicked", function()
	 if toggle==0 then toggle=1 else toggle=0 end
	 if toggle==1 then enable_kb2(true) else enable_kb2(false) end
         ----gtk.widget_grab_focus(w_edit_val)
      end)
end
--]]
------------------

local w_bt1_kb2 = gobject.get_data(ui, "bt1_kb2")
local w_bt2_kb2 = gobject.get_data(ui, "bt2_kb2")
local w_bt3_kb2 = gobject.get_data(ui, "bt3_kb2")
local w_bt4_kb2 = gobject.get_data(ui, "bt4_kb2")
local w_bt5_kb2 = gobject.get_data(ui, "bt5_kb2")
local w_bt6_kb2 = gobject.get_data(ui, "bt6_kb2")
local w_bt7_kb2 = gobject.get_data(ui, "bt7_kb2")
local w_bt8_kb2 = gobject.get_data(ui, "bt8_kb2")
local w_bt9_kb2 = gobject.get_data(ui, "bt9_kb2")
local w_bt0_kb2 = gobject.get_data(ui, "bt0_kb2")
local w_btDel_kb2 = gobject.get_data(ui, "btDel_kb2")
local w_btClose_kb2 = gobject.get_data(ui, "btClose_kb2")
-- mejor ni usar el close:
--gobject.set_property(w_btClose_kb2, "visible", false)

local scancodes={
   F1     = string.char(59)..string.char(187),
   F2     = string.char(60)..string.char(188),
   F3     = string.char(61)..string.char(189),
   F4     = string.char(62)..string.char(190),
   F5     = string.char(63)..string.char(191),
   F6     = string.char(64)..string.char(192),
   F7     = string.char(65)..string.char(193),
   F8     = string.char(66)..string.char(194),
   F9     = string.char(67)..string.char(195),
   F10    = string.char(68)..string.char(196),
   Left   = string.char(224)..string.char(75)..string.char(224)..string.char(203),
   --Return = string.char(28)..string.char(156),
}

local function bt_kb2_handler(w, key)
   --gtk.widget_grab_focus(w_edit_val)   -- parece no hace falta / ojo! tb en propiedades de glade... (Focus on Click & Can Focus...)
   --gtk.main_iteration_do(FALSE)	-- pensaba para ejecutar keysnooper pero no hace falta
   zkbd:write(scancodes[key])
   print(key)  -- dev
end


local function btClose_kb2_handler(w, data)
   enable_kb2(false)
end


gobject.connect(w_bt1_kb2, "clicked", bt_kb2_handler, "F2")
gobject.connect(w_bt2_kb2, "clicked", bt_kb2_handler, "F3")
gobject.connect(w_bt3_kb2, "clicked", bt_kb2_handler, "F4")
gobject.connect(w_bt4_kb2, "clicked", bt_kb2_handler, "F5")
gobject.connect(w_bt5_kb2, "clicked", bt_kb2_handler, "F6")
gobject.connect(w_bt6_kb2, "clicked", bt_kb2_handler, "F7")
gobject.connect(w_bt7_kb2, "clicked", bt_kb2_handler, "F8")
gobject.connect(w_bt8_kb2, "clicked", bt_kb2_handler, "F9")
gobject.connect(w_bt9_kb2, "clicked", bt_kb2_handler, "F10")
gobject.connect(w_bt0_kb2, "clicked", bt_kb2_handler, "F1")
gobject.connect(w_btDel_kb2, "clicked", bt_kb2_handler, "Left")
gobject.connect(w_btClose_kb2, "clicked", btClose_kb2_handler)
----------

--====================--
-- login window (XXX) --- de momento solo en local!
--====================--
local login_entry =gobject.get_data(loginui2, "login_entry2")

local vbox1 = gobject.get_data(ui, "vbox1")
local loginwindow = gobject.get_data(loginui2, "window3")
gobject.set_property(loginwindow, "visible", false)

--local top_id=gtk.statusbar_push(sb, "login", _g("Introduce password"))
local login_button=gobject.get_data(loginui2, "login_button2")
--local logo        =gobject.get_data(loginui2, "image_login")
local sb          =gobject.get_data(loginui2, "statusbar_login")
local top_id

----------
-- Mostrar ventana de login de acceso:
local w_level_params_button = gobject.get_data(ui, "level_params_button")
function mostrar_login()
   print("w_level_params_button")
   if top_id then
      gtk.statusbar_pop(sb, "login", top_id)
   end

   -- intento ocultar cursor en display local (Xfbdev) en pantalla de login (uso xsetroot -cursor)
   os.execute("/usr/local/zigor/activa/tools/hide_cursor.sh")

   gobject.set_property(vbox1, "visible", false)
   gobject.set_property(loginwindow, "visible", true)
end

----------
-- Mostrar ventana de login de acceso:
if remote==1 then  -- ocultar en modo remoto
   gobject.set_property(w_level_params_button, "visible", false)
end

gobject.connect(w_level_params_button, "clicked", mostrar_login)
gobject.connect(w_event_level, "button_press_event", mostrar_login)

--gobject.set_property(logo, "pixbuf", gobject.get_data(pixbufs, "logo") )
    
----------
-- Gestion Click en Login!
local function login_handler()
   print("login_handler")
   --gtk.window_set_keep_above(window2, false)

   local tabla_pass_id=gtk.statusbar_push(sb, "login", "cacaaa")
   print(">>>tabla_pass_id", tabla_pass_id)

   local password=gobject.get_property(login_entry, "text")
   print("password", password)

   --
   ----gobject.set_property(sds, "community", password)  -- recorrer tabla de passwords con el nivel introducido!
   gobject.set_property(sds, "community", "zadmin")

   -- comprobar "password" vÃ¡lido
   require "oids-parameter"
   
   i=1
   local pass
   
   --gtk.statusbar_pop(sb, "login", top_id)
   --gtk.statusbar_pop(sb, "login")
   
   ----local tabla_pass_id=gtk.statusbar_push(sb, "login", _g("Comprobando password..."))
   ----gtk.main_iteration_do(FALSE);  -- entiendo es para q pase por el bucle y se refresque la statusbar!
   print("eooo")
   
   local pass_key = accessx.getnextkey(sds, zigorSysPasswordPass) -- si no es correcto se da Timeout por community inapropiada
   while( pass_key and is_substring(pass_key, zigorSysPasswordPass) and pass_key~=zigorSysPasswordPass ) do
      print("bucle pass")
      --local get_pass_id=gtk.statusbar_push(sb, "login", _g("Comprobando acceso nivel")..tostring(i).."...")
      ----gtk.main_iteration_do(FALSE);
      pass=access.get(sds, pass_key)
      print("pass", pass)
      --gtk.statusbar_pop(sb, "login", get_pass_id)
      ----gtk.main_iteration_do(FALSE);
      
      -- Comprobar si es el nuestro
      if pass and pass==password then
         print("pass match!")
	 _,_,access_level=string.find(pass_key, "%.(%d+)$")
	 access_level_key=pass  -- XXX
	 access_level=tonumber(access_level)
     -- new! establecer env variable y salir!
	 ----gobject.set_property(sds, "community", password)
	 --gobject.set_property(w_label_level, "label", level_str..": "..tostring(access_level) )
	 --gobject.set_property(loginwindow, "visible", false)
	 --gobject.set_property(vbox1, "visible", true)
	 ----return
   script = os.getenv("LAUNCH")
   cmd=[[sed -i -e 's/ACCESS_LEVEL=.*/ACCESS_LEVEL=ZZZ/' ]] .. script
   cmd = string.gsub(cmd,"ZZZ", access_level)
   print(cmd)
   os.execute(cmd)
   gobject.main_loop_quit(main_loop)
   print("Exit para reinicio en otro nivel")
   os.exit()  -- mas robustez?
	 break
      end
      pass_key = accessx.getnextkey(sds, pass_key)
      i=i+1
   end  -- while
   gobject.set_property(login_entry, "text", "")
   gtk.statusbar_pop(sb, "login", tabla_pass_id)
   --gtk.statusbar_pop(sb, "login", top_id)
   if pass~=password then
      print("pass NOT matched and exit")
      gobject.set_property(sds, "community", access.get(sds, zigorSysPasswordPass.."."..access_level))  -- reestablecer community
      --top_id=gtk.statusbar_push(sb, "login", _g("Error, introduce de nuevo el password"))
      top_id=gtk.statusbar_push(sb, "login", _g("Error, introduce de nuevo"))
   end
   -- 
   print("fin login_handler")
end
----------

gobject.connect(login_button, "clicked", login_handler)
--gobject.connect(login_button, "clicked", btClosekb1_handler)

-----------------
--- GUI keyboard!
-----------------
local w_hbtbox1kb1 = gobject.get_data(loginui2, "hbtbox1kb1-2")
local w_hbtbox2kb1 = gobject.get_data(loginui2, "hbtbox2kb1-2")
local w_hbtbox3kb1 = gobject.get_data(loginui2, "hbtbox3kb1-2")
local w_hbtbox4kb1 = gobject.get_data(loginui2, "hbtbox4kb1-2")
local function enable_kb1(enable)
   gobject.set_property(w_hbtbox1kb1, "visible", enable)
   gobject.set_property(w_hbtbox2kb1, "visible", enable)
   gobject.set_property(w_hbtbox3kb1, "visible", enable)
   gobject.set_property(w_hbtbox4kb1, "visible", enable)
end

--[[ no, mejor en ambos!
-- Mostrar teclado solo en local
if remote==1 then
  enable_kb1(false)
end
--]]

--[[ en principio ya no usamos
local function login_entry_press(w, event, data)
   print("login_entry_press")
   --enable_kb1(true)
end

if remote==0 then  -- mostrar teclado solo en local
  gobject.connect(login_entry, "button-press-event", login_entry_press)
end
--]]

local w_bt1kb1 = gobject.get_data(loginui2, "bt1kb1")
local w_bt2kb1 = gobject.get_data(loginui2, "bt2kb1")
local w_bt3kb1 = gobject.get_data(loginui2, "bt3kb1")
local w_bt4kb1 = gobject.get_data(loginui2, "bt4kb1")
local w_bt5kb1 = gobject.get_data(loginui2, "bt5kb1")
local w_bt6kb1 = gobject.get_data(loginui2, "bt6kb1")
local w_bt7kb1 = gobject.get_data(loginui2, "bt7kb1")
local w_bt8kb1 = gobject.get_data(loginui2, "bt8kb1")
local w_bt9kb1 = gobject.get_data(loginui2, "bt9kb1")
local w_bt0kb1 = gobject.get_data(loginui2, "bt0kb1")
local w_btDelkb1 = gobject.get_data(loginui2, "btDelkb1")
local w_btClosekb1 = gobject.get_data(loginui2, "btClosekb1")

local numberkeys={
   F1     = "0",
   F2     = "1",
   F3     = "2",
   F4     = "3",
   F5     = "4",
   F6     = "5",
   F7     = "6",
   F8     = "7",
   F9     = "8",
   F10    = "9",
}

local function btkb1_handler(w, key)
   --[[
   if key=="Left" then
     print("Left")
     gtk.widget_grab_focus(login_entry)	-- al final no hace falta, se gestiona en propiedades de glade
   end
   --]]
   --gtk.main_iteration_do(FALSE)	-- pensaba para ejecutar keysnooper pero no hace falta
   if remote==1 then
      if key=="Left" then
         print("Left")
         local text = gobject.get_property(login_entry, "text")
	 if string.len(text) > 0 then
	    text = string.sub(text, 1, string.len(text)-1)
	    gobject.set_property(login_entry, "text", text)
	 end
      else
         print(key, numberkeys[key])
	 local text = gobject.get_property(login_entry, "text")
	 text = string.format("%s%s", text, numberkeys[key])
	 --gobject.set_property(login_entry, "text", numberkeys[key])
	 gobject.set_property(login_entry, "text", text)
      end
   else
      zkbd:write(scancodes[key])
   end
end


local function btClosekb1_handler(w, data)
	 --enable_kb1(false)
	 print("btClosekb1_handler")
	 gobject.set_property(loginwindow, "visible", false)
	 gobject.set_property(vbox1, "visible", true)
	 gobject.set_property(login_entry, "text", "")
	 --zkbd:close()
end


gobject.connect(w_bt1kb1, "clicked", btkb1_handler, "F2")
gobject.connect(w_bt2kb1, "clicked", btkb1_handler, "F3")
gobject.connect(w_bt3kb1, "clicked", btkb1_handler, "F4")
gobject.connect(w_bt4kb1, "clicked", btkb1_handler, "F5")
gobject.connect(w_bt5kb1, "clicked", btkb1_handler, "F6")
gobject.connect(w_bt6kb1, "clicked", btkb1_handler, "F7")
gobject.connect(w_bt7kb1, "clicked", btkb1_handler, "F8")
gobject.connect(w_bt8kb1, "clicked", btkb1_handler, "F9")
gobject.connect(w_bt9kb1, "clicked", btkb1_handler, "F10")
gobject.connect(w_bt0kb1, "clicked", btkb1_handler, "F1")
gobject.connect(w_btDelkb1, "clicked", btkb1_handler, "Left")
--gobject.connect(w_btDelkb1, "clicked", function() os.execute("/usr/local/zigor/activa/drivers/kbde -k ArrowL") end)
--gobject.connect(w_btDelkb1, "clicked", function() zkbd:write(string.char(224)..string.char(75)..string.char(224)..string.char(203)) end)
gobject.connect(w_btClosekb1, "clicked", btClosekb1_handler)
------
