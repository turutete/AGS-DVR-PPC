require "oids-dvr"
require "oids-alarm"
require "oids-parameter"
require "functions"	-- uso get_alarm_config_index

----------------------------------------
-- XXX redefinimos check_enum asumiendo que un enumerado es una secuencia continua de enteros
require "parameter"
check_enum = check_number
local edit_config=require "config-edit-dvr"
-- XXX Eliminamos configuración de "factor", en LCD se edita el valor en mismas unidades que SDS
for k,v in pairs(edit_config) do
   if v.check_args then
      v.check_args.factor=nil
   end
end

----------------------------------------
-- Definiciones varias, etc
----------------------------------------
-- obtener etiquetas de alarmas
local displays = require "displays-dvr"
local display_descr = displays.display_descr

-- "forward"
local update = function() end

-- Tabla de pantallas
local deck = {}
-- Pantalla actual
deck.current = "main"
deck.prev="main"

local alarm_cfg
local function safealarm_cfg(descr)
   local id=alarm_cfg[descr]
   if not id then
      alarm_cfg=get_alarm_config_index(sds)
   end
   return id
end

loadlualib("access")
access.safeget = function(sds,k)
		    -- XXX
		    local v=access.get(sds, k)

		    if not v then		       
		       if deck.current~="error" then
			  deck.prev=deck.current
		       end
		       deck.current="error"
		       update()
		       return nil
		    end

		    return v
		 end

loadlualib("accessx")   -- XXX uso accessx
loadlualib("gobject")
loadlualib("curses")

--salida de filtro 'zdin2char': 4,2,1,0 (de izq. a der.)
curses.KEY_UP    =   4
curses.KEY_DOWN  =   1
curses.KEY_RET   =   0
curses.KEY_ESC   =   2

local factor10  = 10
local factor100 = 100
local factor1000= 1000
----
local step_factor=1

CUENTA_IDLE_LCD = 5  -- minutos, valor minimo 2
local cuenta_idle = CUENTA_IDLE_LCD	 -- contador para gestion vuelta pantalla principal


-- variables auxiliares pantallas alarmas
local i_alarma		-- indice de alarma en pantallas de alarmas
local tabla_alarmas={}	-- tabla interna de alarmas presentes

-- Valores CGRAM LCD
local flecha_arriba        = 0  --XXX
local flecha_return        = 1
local flecha_triangulo     = 2
local flecha_triangulo_izq = 3
local flecha_arriba_fill   = 4
local flecha_abajo_fill    = 5
local ohmnio               = 6
local grado                = 7

-- Etiquetas Estados                "0123456789012"
local eti_EstadosActInact =  { _g("Activo"), _g("Inactivo"), }
local eti_EstadosOnOff =     { _g("ON"), _g("OFF"), }
local eti_EstadosAceptarCancelar = { _g("Aceptar"), _g("Cancelar"), }

local zlcd,err=io.open("/proc/zigor/zlcd", "w")
if zlcd==nil then
   io.stderr:write(err..'\n')
end

--------------------
-- Notas:
-- la salida de curses es "cocinada", es decir, que los caracteres de control aparte de nueva linea,
-- tab y backspace se sustituyen por la forma ^X
-- Asi, el procedimiento para utilizar los caracteres cgram es _no_ incluirlos en la cadena que
-- escribimos mediante mvaddstr() y escribirlos "sueltos" despues mediante mvaddch(x,y,n,true).
-- donde x,y es posicion, n el caracter a escribir y true es de 'raw'=true: sin cocinar ^X
-- ojo parece que el 0 no se muestra porque es fin de cadena en curses...

--------------------
-- niveles de acceso:
local nivel_basico   ="1234"
local nivel_avanzado ="1324"
--
-- Mapa de navegación para cada clave (solo definir KEY_DOWN y KEY_RET para navegación _normal_)
-- añadir readonly=true si se quiere deshabilitar edición de una pantalla en ese nivel
navmap={}
--------------------
-- nivel basico:
--------------------
navmap[nivel_basico] = {
   main = {
      [curses.KEY_DOWN] = "Alarmas", },
   Alarmas = { 
      [curses.KEY_ESC ] = "main",
      [curses.KEY_DOWN] = "Medidas",
      [curses.KEY_RET ] = "Alarma", },
   Medidas = {
      [curses.KEY_ESC ] = "main",
      [curses.KEY_DOWN] = "Configuracion",
      [curses.KEY_RET ] = "VReds", },
   Configuracion = {
      [curses.KEY_ESC ] = "main",
      [curses.KEY_RET ] = "Acceso", },
   --
   Alarma = {  -- se configura para que no se pueden resetear alarmas XXX
   readonly=true, },
   --
   VReds ={
      [curses.KEY_DOWN ] = "VBus", },
   VBus ={
      [curses.KEY_DOWN ] = "Bypass", },
   Bypass ={
      [curses.KEY_DOWN ] = "VSecs", },
   VSecs ={
      [curses.KEY_DOWN ] = "ISecs", },
   ISecs ={
      [curses.KEY_DOWN ] = "PSecs", },
   --
   Acceso = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "VRedNom",
      [curses.KEY_RET]  = "login", },
   VRedNom = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "VMinDVR", },
   VMinDVR = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "FrecNom", },
   FrecNom = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NumEquipos", },
   NumEquipos = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Fecha", },
   Fecha = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetIP", },
   NetIP = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetMask", },
   NetMask = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetGateway", },
   NetGateway = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Idioma", },
   Idioma = {
      readonly=true,
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Version", },
   Version = {
      [curses.KEY_ESC]  = "Configuracion", },
}
--------------------
-- nivel avanzado:
--------------------
navmap[nivel_avanzado] = {
   main = {
      [curses.KEY_DOWN] = "Alarmas", },
   Alarmas = { 
      [curses.KEY_ESC ] = "main",
      [curses.KEY_DOWN] = "Medidas",
      [curses.KEY_RET ] = "Alarma", },
   Medidas = {
      [curses.KEY_ESC ] = "main",
      [curses.KEY_DOWN] = "Configuracion",
      [curses.KEY_RET ] = "VReds", },
   Configuracion = {
      [curses.KEY_ESC ] = "main",
      [curses.KEY_DOWN] = "Actuaciones",
      [curses.KEY_RET ] = "Acceso", },
   Actuaciones = {
      [curses.KEY_ESC ] = "main",
      [curses.KEY_RET ] = "Marcha", },
   --
   VReds ={
      [curses.KEY_DOWN ] = "VBus", },
   VBus ={
      [curses.KEY_DOWN ] = "Bypass", },
   Bypass ={
      [curses.KEY_DOWN ] = "VSecs", },
   VSecs ={
      [curses.KEY_DOWN ] = "ISecs", },
   ISecs ={
      [curses.KEY_DOWN ] = "PSecs", },
   --
   Acceso = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "VRedNom",
      [curses.KEY_RET]  = "login", },
   VRedNom = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "VMinDVR", },
   VMinDVR = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "FrecNom", },
   FrecNom = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NumEquipos", },
   NumEquipos = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Fecha", },
   Fecha = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetIP", },
   NetIP = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetMask", },
   NetMask = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "NetGateway", },
   NetGateway = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Idioma", },
   Idioma = {
      [curses.KEY_ESC]  = "Configuracion",
      [curses.KEY_DOWN] = "Version", },
   Version = {
      [curses.KEY_ESC]  = "Configuracion", },
   --
   Marcha = {
      [curses.KEY_DOWN] = "Paro", },
   Paro = {
      [curses.KEY_DOWN] = "Reset", },
}

local taux={}  -- to fix bug
-- Se calcula mapa para teclas KEY_UP y KEY_ESC en función de KEY_DOWN y KEY_RET
for k,nav in pairs(navmap) do  -- para cada clave
   -- KEY_UP en función de KEY_DOWN
   for d,dnav in pairs(nav) do -- para cada pantalla (display)
      local down=dnav[curses.KEY_DOWN]
      --if down and not nav[down] then nav[down] = {} end
      if down and not nav[down] then taux[down] = {} end
      local next=dnav[curses.KEY_RET]
      --if next and not nav[next] then nav[next]={} end
      if next and not nav[next] then taux[next]={} end
   end
   for k,v in pairs(taux) do
      nav[k]=v
   end
   for d,dnav in pairs(nav) do -- para cada pantalla (display)
      local down=dnav[curses.KEY_DOWN]
      if down then
	 if not nav[down][curses.KEY_UP] then
	    nav[down][curses.KEY_UP] = d
	 end
      end
      local next=dnav[curses.KEY_RET]
      while(next) do
	 if not nav[next][curses.KEY_ESC] then
	    nav[next][curses.KEY_ESC] = d
	 end
	 next=nav[next][curses.KEY_DOWN]
      end
   end
end

----------------------------------------
-- Pantallas de "login" y error
----------------------------------------
--local logged = logged -- para poder inicializarla externamente (menutree)
local logged = nivel_basico -- por defecto nivel basico
--
deck.login = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Password:           
    %s    ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       local shadow = string.gsub(this.login, ".", "*")
	       -- Obtenemos plantilla
	       local s = string.format(this.template, shadow)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
   dokey = function(this, key)
	      local ret = "login"
	      this.login = this.login .. this.keymap[key]
	      this.len   = this.len+1
	      if this.len == 4 then
		 -- Comprobamos login correcto
		 if navmap[this.login] then
		    logged = this.login
		    ret="main"
		 else
		    ret=navmap[logged][deck.current][curses.KEY_ESC]  --vuelta pantalla anterior
		    logged = nivel_basico
		 end
		 --
		 this.login=""
		 this.len=0
	      end
	      return ret
	   end,
   -- variables internas	   
   len=0,
   login="",
   keymap = {
      [curses.KEY_UP]    =   "2",
      [curses.KEY_DOWN]  =   "3",
      [curses.KEY_RET]   =   "4",
      [curses.KEY_ESC]   =   "1",
   },
}

local CUENTA_ERROR_MAX = 5

deck.error = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
PROCESANDO...
ESPERE          ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos plantilla
	       local s = this.template
	       -- Evitar pulsar tecla, reintento automatico de vuelta a pantalla previa tras cierto tiempo:
	       if this.time_count>0 then
	          this.time_count=this.time_count-1
	       else
	          this.time_count=CUENTA_ERROR_MAX
	          deck.current=deck.prev
	       end
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
   dokey = function(this, key)
	      deck.current=deck.prev
	      this.time_count=CUENTA_ERROR_MAX
	      --update() --necesario?
	   end,
   -- variables internas	   
   time_count=5,
}

----------------------------------------
-- Configuración de "pantallas"
----------------------------------------
--
-- Pantalla principal
--
deck.main = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
ESTADO CONTROL
%s              ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local EstadoControl = access.safeget(sds, zigorDvrObjEstadoControl .. ".0")
	       -- Creamos cadena con el contenido de la pantalla
	       local s
	       --((ojo KO!)if EstadoControl then
	       if EstadoControl and displays.display_EstadoControl[EstadoControl] then
	          --s = string.format(this.template, eti_EstadosControl[EstadoControl] or "?")
		  --(ojo KO!)s = string.format(this.template, displays.display_EstadoControl[EstadoControl].display_lcd or displays.display_EstadoControl[EstadoControl].display or "?")
		  s = string.format(this.template, displays.display_EstadoControl[EstadoControl].display_lcd or displays.display_EstadoControl[EstadoControl].display or "?")
	       else
	          s = string.format(this.template, "?")
	       end
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       --marco:
	       --curses.mvaddch(0,0, 255, true)
	       --curses.mvaddch(0,15, 255, true)
	       --curses.mvaddch(1,0, 255, true)
	       --curses.mvaddch(1,15, 255, true)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      if key==curses.KEY_ESC then  -- mandar ESC+z
		 if(zlcd) then
		    zlcd:write( string.char(27), string.char(122) )
		    zlcd:flush()
		    curses.clear()
		 end
	      end
	   end
}
--------------------------------------------------------------------------------
--
-- Menu de Alarmas
--
deck.Alarmas = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
EVENTOS        >
%8s eventos     ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local numAlarmas = access.safeget(sds, zigorAlarmsPresent .. ".0")
	       this.numAlarmas=numAlarmas
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, tostring(numAlarmas))
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if key==curses.KEY_RET then
		 if this.numAlarmas>0 then
		    i_alarma=1
		 else
		    ret="Alarmas"  -- solo cambiar de pantalla si hay alarmas presentes
		 end
	      end
	      return ret
	   end,
   -- variables internas
   numAlarmas=0,
}
----------------------------------------
--
-- Pantallas de Alarmas
--
deck.Alarma = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = [[
%s
%02d %02d/%02d %s]],
--23456789012345
   -- Función de "render"
   render = function(this)
	     local R
	     if not this.edit then  
	       ----
	       -- Modo Visualizacion
	       ----
	       -- Obtenemos variables
	       local numAlarmas = access.safeget(sds, zigorAlarmsPresent .. ".0")
	       this.numAlarmas=numAlarmas
	       
	       --protecciones:
	       if numAlarmas==0 then
	          deck.current = navmap[logged][deck.current][curses.KEY_ESC]
		  return
	       end
	       if i_alarma>numAlarmas then
	          i_alarma=numAlarmas
	       end
	       if i_alarma<1 then
	          i_alarma=1
	       end
	       
	       --mostrar elemento actual de tabla en funcion de la navegacion en la lista (i_alarma)
	       local alarm_descr=access.safeget(sds, zigorAlarmDescr ..".".. tostring(tabla_alarmas[i_alarma]))
	       local codigo = display_descr[alarm_descr]["codigo"]
	       local display_lcd = display_descr[alarm_descr]["display_lcd"]
	       this.codigo=codigo
	       this.display_lcd=display_lcd

	       --si reseteable (severas y persistentes), poner R:
	       R = "       "
	       this.reset=false
	       local severity = access.safeget(sds, zigorAlarmCfgSeverity ..".".. tostring(safealarm_cfg(alarm_descr)))
	       if severity==AlarmSeveritySEVERA or severity==AlarmSeverityPERSISTENTE then
	          R = "     R "
	          --y si ausencia de causa de evento en reseteables, bloqueada(4), poner R! y habilitar tecla RET:
	          local condition = access.safeget(sds, zigorAlarmCondition ..".".. tostring(tabla_alarmas[i_alarma]))
	          if condition==4 then
	             R = "     R!"
	             this.reset=true
	          end
	       end
	     else
	       ----
	       -- Modo Edicion
	       ----
	       R = _g("Reset? ","Ocupar 7 caracteres! [usar espacios]")
	       --comprobar periodicamente si vuelve a estar activa para salir de edicion
	       local condition = access.safeget(sds, zigorAlarmCondition ..".".. tostring(tabla_alarmas[i_alarma]))
	       if condition~=4 then
	          this.edit=false
	       end
	     end
	       ----
	       -- Comun
	       ----
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, this.display_lcd, this.codigo, i_alarma, this.numAlarmas, R)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	    local ret
	    if not this.edit then
	      ----
	      -- Modo navegacion
	      ----
	      if key==curses.KEY_DOWN then
		 i_alarma = i_alarma+1
	      elseif key==curses.KEY_UP then
		 i_alarma = i_alarma-1
	      elseif key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		 if this.reset then
		   this.edit=true
		 end
	      end
	    else
	      ----
	      -- Modo edicion
	      ----
	      if key==curses.KEY_RET then
	         -- comprobacion de bloqueada
		 local condition = access.safeget(sds, zigorAlarmCondition ..".".. tostring(tabla_alarmas[i_alarma]))
		 if condition==4 then
		    -- resetear: pasar a condicion inactiva (2)
		    access.set(sds, zigorAlarmCondition ..".".. tostring(tabla_alarmas[i_alarma]), 2)
		 end
		 this.edit=false
	      elseif key==curses.KEY_ESC then
		 this.edit=false
	      end
	    end
	    return ret
	   end,
   -- variables internas
   edit = false,
   numAlarmas,
   codigo,
   display_lcd,
   reset = false,
}

--------------------------------------------------------------------------------
--
-- Pantalla de Medidas
--
deck.Medidas = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
MEDIDAS        >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
}

----------------------------------------
--
-- Pantalla de Medidas > Entrada (NADA)
--
deck.Entrada = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
ENTRADA        >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       -- Creamos cadena con el contenido de la pantalla
	       --local s = string.format(this.template, string.format("%.1f", Pot))
	       local s = string.format(this.template)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      if key==curses.KEY_DOWN then
		 deck.current = "Rec"
	      elseif key==curses.KEY_RET then
		 deck.current = "VReds"
	      elseif key==curses.KEY_ESC then
		 deck.current = "Medidas"
	      end
	   end
}

--------------------
--
-- Pantalla de Medidas > Entrada > VReds
--
deck.VReds = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Tension Ent.(%s)
%4s %4s %4s]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local dVRedR = access.safeget(sds, zigorDvrObjVRedR .. ".0")
	       local dVRedS = access.safeget(sds, zigorDvrObjVRedS .. ".0")
	       local dVRedT = access.safeget(sds, zigorDvrObjVRedT .. ".0")
	       local VRedR = dVRedR / factor10
	       local VRedS = dVRedS / factor10
	       local VRedT = dVRedT / factor10
	       -- new: adaptar para valores de media tension MT
	       local units="V"
	       if VRedR>=10000 or VRedS>=10000 or VRedT>=10000 then
	          VRedR=VRedR/1000
	          VRedS=VRedS/1000
	          VRedT=VRedT/1000
		  units="kV"
	       end
	       ----
	       -- Creamos cadena con el contenido de la pantalla
	       --local s = string.format(this.template, string.format("%.0f", VRedR), string.format("%.0f", VRedS), string.format("%.0f", VRedT))
	       local s
	       if units=="kV" then
	          s = string.format(this.template, units, string.format("%.1f", VRedR), string.format("%.1f", VRedS), string.format("%.1f", VRedT))
	       else
	          s = string.format(this.template, units, string.format("%.0f", VRedR), string.format("%.0f", VRedS), string.format("%.0f", VRedT))
	       end
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

----------------------------------------
--
-- Pantalla de Medidas > Rec (NADA)
--
deck.Rec = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
RECTIFICADOR   >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       -- Creamos cadena con el contenido de la pantalla
	       --local s = string.format(this.template, string.format("%.0f", VPv), string.format("%.0f", IEnt))
	       local s = string.format(this.template)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      if key==curses.KEY_DOWN then
		 deck.current = "Bypass"
	      elseif key==curses.KEY_UP then
		 deck.current = "Entrada"
	      elseif key==curses.KEY_RET then
		 deck.current = "VBus"
	      elseif key==curses.KEY_ESC then
		 deck.current = "Medidas"
	      end
	   end
}

--------------------
--
-- Pantalla de Medidas > Rec > VBus
--
deck.VBus = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Tension Bus
%10s V          ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local dVBus = access.safeget(sds, zigorDvrObjVBus .. ".0")
	       local VBus = dVBus / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.1f", VBus))
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

----------------------------------------
--
-- Pantalla de Medidas > Bypass
--
deck.Bypass = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Bypass
   %s           ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local Bypass = access.safeget(sds, zigorDvrObjBypassOn .. ".0")
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, eti_EstadosActInact[Bypass] or "?")
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

----------------------------------------
--
-- Pantalla de Medidas > Salida (NADA)
--
deck.Salida = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
SALIDA         >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      if key==curses.KEY_UP then
		 deck.current = "Bypass"
	      elseif key==curses.KEY_ESC then
		 deck.current = "Medidas"
	      elseif key==curses.KEY_RET then
		 deck.current = "VSecs"
	      end
	   end
}

--------------------
--
-- Pantalla de Medidas > Salida > VSecs
--
deck.VSecs = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Tension Sal.(%s)
%4s %4s %4s]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local dVSecR = access.safeget(sds, zigorDvrObjVSecundarioR .. ".0")
	       local dVSecS = access.safeget(sds, zigorDvrObjVSecundarioS .. ".0")
	       local dVSecT = access.safeget(sds, zigorDvrObjVSecundarioT .. ".0")
	       local VSecR = dVSecR / factor10
	       local VSecS = dVSecS / factor10
	       local VSecT = dVSecT / factor10
	       -- new: adaptar para valores de media tension MT
	       local units="V"
	       if VSecR>=10000 or VSecS>=10000 or VSecT>=10000 then
	          VSecR=VSecR/1000
	          VSecS=VSecS/1000
	          VSecT=VSecT/1000
		  units="kV"
	       end
	       ----
	       -- Creamos cadena con el contenido de la pantalla
	       --local s = string.format(this.template, string.format("%.0f", VSecR), string.format("%.0f", VSecS), string.format("%.0f", VSecT))
	       local s
	       if units=="kV" then
	          s = string.format(this.template, units, string.format("%.1f", VSecR), string.format("%.1f", VSecS), string.format("%.1f", VSecT))
	       else
	          s = string.format(this.template, units, string.format("%.0f", VSecR), string.format("%.0f", VSecS), string.format("%.0f", VSecT))
	       end
	       
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

--------------------
--
-- Pantalla de Medidas > Salida > ISecs
--
deck.ISecs = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Corriente Salida
%3s %3s %3s  (A)]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local dISecR = access.safeget(sds, zigorDvrObjISecundarioR .. ".0")
	       local dISecS = access.safeget(sds, zigorDvrObjISecundarioS .. ".0")
	       local dISecT = access.safeget(sds, zigorDvrObjISecundarioT .. ".0")
	       local ISecR = dISecR / factor10
	       local ISecS = dISecS / factor10
	       local ISecT = dISecT / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", ISecR), string.format("%.0f", ISecS), string.format("%.0f", ISecT))
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

--------------------
--
-- Pantalla de Medidas > Salida > PSecs
--
deck.PSecs = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Potencia Sal. kW
%3s %3s %3s]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local dPSecR = access.safeget(sds, zigorDvrObjPSalidaR .. ".0")
	       local dPSecS = access.safeget(sds, zigorDvrObjPSalidaS .. ".0")
	       local dPSecT = access.safeget(sds, zigorDvrObjPSalidaT .. ".0")
	       local PSecR = dPSecR / factor10
	       local PSecS = dPSecS / factor10
	       local PSecT = dPSecT / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", PSecR), string.format("%.0f", PSecS), string.format("%.0f", PSecT))
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

--------------------------------------------------------------------------------
--
-- Pantalla de Configuracion
--
deck.Configuracion = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
CONFIGURACION  >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Creamos cadena con el contenido de la pantalla
	       local s = this.template
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
}

----------------------------------------
--
-- Pantalla de Configuracion > VRedNom
--
deck.VRedNom = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Tension Nominal
%10s V          ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
	          local dVRedNom = access.safeget(sds, zigorDvrParamVRedNom .. ".0")
		  this.value = dVRedNom
	       end
	       
	       local VRedNom = this.value / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", VRedNom) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 local value=this.value
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición (solamente ante cambio de valor)
		    local v_actual = access.safeget(sds, zigorDvrParamVRedNom .. ".0")
		    if v_actual ~= this.value then
		       access.set(sds, zigorDvrParamVRedNom .. ".0", this.value)
		       -- XXX ¿grabar configuración aquí? >>> si
		       access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		    end
		    this.edit=false
		 elseif key==curses.KEY_UP then
		    -- Incrementar valor en edición
		    value=value + this.step * step_factor
		 elseif key==curses.KEY_DOWN then
		    -- Decrementar valor en edición
		    value=value - this.step * step_factor
		 end
		 -- comprobamos valor si ha cambiado
		 if value~=this.value then
		    local ec=edit_config[zigorDvrParamVRedNom]
		    if ec.check(value, ec.check_args) then
		       this.value=value
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición (décimas)
   step  = 10,     -- Salto en inc/dec de valor (décimas)
}

----------------------------------------
--
-- Pantalla de Configuracion > VMinDVR
--
deck.VMinDVR = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
V minima DVR
%10s V          ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
	          local dVMinDVR = access.safeget(sds, zigorDvrParamVMinDVR .. ".0")
		  this.value = dVMinDVR
	       end
	       
	       local VMinDVR = this.value / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", VMinDVR) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 local value=this.value
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición (solamente ante cambio de valor)
		    local v_actual = access.safeget(sds, zigorDvrParamVMinDVR .. ".0")
		    if v_actual ~= this.value then
		       access.set(sds, zigorDvrParamVMinDVR .. ".0", this.value)
		       -- XXX ¿grabar configuración aquí? >>> si
		       access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		    end
		    this.edit=false
		 elseif key==curses.KEY_UP then
		    -- Incrementar valor en edición
		    value=value + this.step * step_factor
		 elseif key==curses.KEY_DOWN then
		    -- Decrementar valor en edición
		    value=value - this.step * step_factor
		 end
		 -- comprobamos valor si ha cambiado
		 if value~=this.value then
		    local ec=edit_config[zigorDvrParamVMinDVR]
		    if ec.check(value, ec.check_args) then
		       this.value=value
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición (décimas)
   step  = 10,    -- Salto en inc/dec de valor
}

----------------------------------------
--
-- Pantalla de Configuracion > FrecNom
--
deck.FrecNom = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Frecuencia Nom.
%10s Hz         ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
	          local dVal = access.safeget(sds, zigorDvrParamFrecNom .. ".0")
		  this.value = dVal
	       end
	       
	       local FrecNom = this.value / factor10
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", FrecNom) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 local value=this.value
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición (solamente ante cambio de valor)
		    local v_actual = access.safeget(sds, zigorDvrParamFrecNom .. ".0")
		    if v_actual ~= this.value then
		       access.set(sds, zigorDvrParamFrecNom .. ".0", this.value)
		       -- XXX ¿grabar configuración aquí? >>> si
		       access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		    end
		    this.edit=false
		 elseif key==curses.KEY_UP then
		    -- Incrementar valor en edición
		    value=value + this.step * step_factor
		 elseif key==curses.KEY_DOWN then
		    -- Decrementar valor en edición
		    value=value - this.step * step_factor
		 end
		 -- comprobamos valor si ha cambiado
		 if value~=this.value then
		    local ec=edit_config[zigorDvrParamFrecNom]
		    if ec.check(value, ec.check_args) then
		       this.value=value
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición (décimas)
   step  = 10,    -- Salto en inc/dec de valor
}

----------------------------------------
--
-- Pantalla de Configuracion > NumEquipos
--
deck.NumEquipos = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Num. equipos
%10s            ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
	          local NumEquipos = access.safeget(sds, zigorDvrParamNumEquipos .. ".0")
		  this.value = NumEquipos
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, string.format("%.0f", this.value) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 local value=this.value
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición (solamente ante cambio de valor)
		    local v_actual = access.safeget(sds, zigorDvrParamNumEquipos .. ".0")
		    if v_actual ~= this.value then
		       access.set(sds, zigorDvrParamNumEquipos .. ".0", this.value)
		       -- XXX ¿grabar configuración aquí? >>> si
		       access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		    end
		    this.edit=false
		 elseif key==curses.KEY_UP then
		    -- Incrementar valor en edición
		    value=value + this.step
		 elseif key==curses.KEY_DOWN then
		    -- Decrementar valor en edición
		    value=value - this.step
		 end
		 -- comprobamos valor si ha cambiado
		 if value~=this.value then
		    local ec=edit_config[zigorDvrParamNumEquipos]
		    if ec.check(value, ec.check_args) then
		       this.value=value
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición (décimas)
   step  = 1,     -- Salto en inc/dec de valor
}

----------------------------------------
--
-- Pantalla de Configuracion > Fecha
--
deck.Fecha = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Fecha (aa/mm/dd)
%s  ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
		  this.index=1
	          -- Obtenemos variables
		  local Date = access.safeget(sds, zigorSysDate .. ".0")
		  this.value = ZDateAndTime2timetable(Date)
		  this.value.isdst=nil   --evita en edicion la actualizacion de hora segun 'dst'
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, os.date("%y/%m/%d %H:%M", os.time(this.value)) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
--		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_return,true)  -- XXX no muestra caracter 0 de la CGRAM!
		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_triangulo_izq,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición
		    this.index=this.index+1
		    if this.index > this.n_fields then
		       -- XXX set (hace el cambio _siempre_)
		       access.set(sds, zigorSysDate .. ".0", os.date("%Y%m%d%H%M%S0%z", os.time(this.value)) )
		       -- XXX ¿grabar configuración aquí? >>> no >si(evitar paso a temporal)
		       access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		       this.edit=false
		    end
		 elseif key==curses.KEY_UP then
		    --this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] + this.step
		    this.value[this.fields[this.index].name] = tostring( tonumber(this.value[this.fields[this.index].name]) + this.step )
		 elseif key==curses.KEY_DOWN then
		    --this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] - this.step
		    this.value[this.fields[this.index].name] = tostring( tonumber(this.value[this.fields[this.index].name]) - this.step )
		 end
		 -- NEW: Limitar los valores de edicion a unos minimos y maximos
		 if key==curses.KEY_UP or key==curses.KEY_DOWN then
		    ---
		    min = this.fields[this.index].min
		    max = this.fields[this.index].max
		    -- contemplar si febrero y bisiesto, y meses de 30:
		    if this.fields[this.index].name == "day" then
		       if tonumber(this.value.month) == 2 then
		          if math.fmod(tonumber(this.value.year), 4)==0 and (math.fmod(tonumber(this.value.year), 100)~=0 or math.fmod(tonumber(this.value.year), 400)==0) then
			     max=29
			  else
			     max=28
			  end
		       elseif (tonumber(this.value.month)==4 or tonumber(this.value.month)==6 or tonumber(this.value.month)==9 or tonumber(this.value.month)==11) then
			  max=30
		       end
		    end
		    ---
		    name = this.fields[this.index].name
		    --print("min", min, "max", max, "value", this.value[name])

		    -- proteccion de limites:
		    if tonumber(this.value[name])>max then this.value[name]=tostring(min) end
		    if tonumber(this.value[name])<min then this.value[name]=tostring(max) end
		 end  -- end if key UP DOWN
		 ------ fin NEW
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición (timetable)
   step  = 1,     -- Salto en inc/dec de valor
   index = 1,     -- Campo actual en edición
   --
   n_fields=5,
   fields = {
      { name="year",  curs_col=  2, min=2000, max=2037, },
      { name="month", curs_col=  5, min=1, max=12, },
      { name="day",   curs_col=  8, min=1, max=31, },
      { name="hour",  curs_col= 11, min=0, max=23, },
      { name="min",   curs_col= 14, min=0, max=59, },
   },
}

----------------------------------------
--
-- Pantalla de Configuracion > NetIP
--
deck.NetIP = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Direccion IP
%03d.%03d.%03d.%03d ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
		  this.index=1
	          -- Obtenemos variables
	          local NetIP = access.safeget(sds, zigorNetIP .. ".0") or "0.0.0.0"
		  this.value = { string.gmatch( NetIP, "([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)")() }
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, tonumber(this.value[1]),tonumber(this.value[2]),tonumber(this.value[3]),tonumber(this.value[4]) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
--		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_return,true)
		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_triangulo_izq,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición
		    this.index=this.index+1
		    if this.index > this.n_fields then
		       -- set (solo ante cambio de valor)
		       local v_actual = access.safeget(sds, zigorNetIP .. ".0")
		       local v_mod = string.format("%s.%s.%s.%s", unpack(this.value))
		       if v_actual ~= v_mod then
		          --access.set(sds, zigorNetIP .. ".0", string.format("%s.%s.%s.%s", unpack(this.value)) )
		          access.set(sds, zigorNetIP .. ".0", v_mod)
		          -- ¿grabar configuración aquí? >>> si
		          access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		       end
		       this.edit=false
		    end
		 elseif key==curses.KEY_UP then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] + this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] > 255 then
		       this.value[this.fields[this.index].name] = 0
		    end
		 elseif key==curses.KEY_DOWN then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] - this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] < 0 then
		       this.value[this.fields[this.index].name] = 255
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
   step  = 1,     -- Salto en inc/dec de valor
   index = 1,     -- Campo actual en edición
   --
   n_fields=4,
   fields = {
      { name=1,  curs_col=  3, },
      { name=2,  curs_col=  7, },
      { name=3,  curs_col= 11, },
      { name=4,  curs_col= 15, },
   },
}

----------------------------------------
--
-- Pantalla de Configuracion > NetMask
--
deck.NetMask = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Mascara de red
%03d.%03d.%03d.%03d ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
		  this.index=1
	          -- Obtenemos variables
	          local NetMask = access.safeget(sds, zigorNetMask .. ".0") or "0.0.0.0"
		  this.value = { string.gmatch( NetMask, "([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)")() }
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, tonumber(this.value[1]),tonumber(this.value[2]),tonumber(this.value[3]),tonumber(this.value[4]) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_triangulo_izq,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición
		    this.index=this.index+1
		    if this.index > this.n_fields then
		       -- set (solo ante cambio de valor)
		       local v_actual = access.safeget(sds, zigorNetMask .. ".0")
		       local v_mod = string.format("%s.%s.%s.%s", unpack(this.value))
		       if v_actual ~= v_mod then
		          access.set(sds, zigorNetMask .. ".0", v_mod)
		          -- ¿grabar configuración aquí? >>> si
		          access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		       end
		       this.edit=false
		    end
		 elseif key==curses.KEY_UP then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] + this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] > 255 then
		       this.value[this.fields[this.index].name] = 0
		    end
		 elseif key==curses.KEY_DOWN then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] - this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] < 0 then
		       this.value[this.fields[this.index].name] = 255
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
   step  = 1,     -- Salto en inc/dec de valor
   index = 1,     -- Campo actual en edición
   --
   n_fields=4,
   fields = {
      { name=1,  curs_col=  3, },
      { name=2,  curs_col=  7, },
      { name=3,  curs_col= 11, },
      { name=4,  curs_col= 15, },
   },
}

----------------------------------------
--
-- Pantalla de Configuracion > Gateway
--
deck.NetGateway = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Gateway
%03d.%03d.%03d.%03d ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
		  this.index=1
	          -- Obtenemos variables
	          local NetGateway = access.safeget(sds, zigorNetGateway .. ".0") or "0.0.0.0"
		  this.value = { string.gmatch( NetGateway, "([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)")() }
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, tonumber(this.value[1]),tonumber(this.value[2]),tonumber(this.value[3]),tonumber(this.value[4]) )
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
		  curses.mvaddch(1, this.fields[this.index].curs_col, flecha_triangulo_izq,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición
		    this.index=this.index+1
		    if this.index > this.n_fields then
		       -- set (solo ante cambio de valor)
		       local v_actual = access.safeget(sds, zigorNetGateway .. ".0")
		       local v_mod = string.format("%s.%s.%s.%s", unpack(this.value))
		       if v_actual ~= v_mod then
		          access.set(sds, zigorNetGateway .. ".0", v_mod)
		          -- ¿grabar configuración aquí? >>> si
		          access.set(sds, zigorCtrlParamState .. ".0", 1)  -- grabar cfg
		       end
		       this.edit=false
		    end
		 elseif key==curses.KEY_UP then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] + this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] > 255 then
		       this.value[this.fields[this.index].name] = 0
		    end
		 elseif key==curses.KEY_DOWN then
		    this.value[this.fields[this.index].name] = this.value[this.fields[this.index].name] - this.step
		    -- wrap
		    if this.value[this.fields[this.index].name] < 0 then
		       this.value[this.fields[this.index].name] = 255
		    end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
   step  = 1,     -- Salto en inc/dec de valor
   index = 1,     -- Campo actual en edición
   --
   n_fields=4,
   fields = {
      { name=1,  curs_col=  3, },
      { name=2,  curs_col=  7, },
      { name=3,  curs_col= 11, },
      { name=4,  curs_col= 15, },
   },
}
----------------------------------------
--
-- Pantalla de Configuracion > Idioma
--
deck.Idioma = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Idioma
   %s           ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
		  this.value = this.locale[os.getenv("LC_ALL")]
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, this.textos[this.value] or "?")
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    -- Aceptar edición (solamente ante cambio de valor)
		    local locale = os.getenv("LC_ALL")
		    if this.value ~= this.locale[locale] then
		       ---
		       script = os.getenv("LAUNCH")
		       cmd=[[sed -i -e 's/LC_ALL=".*"/LC_ALL="LOCALE"/' ]] .. script
		       cmd = string.gsub(cmd,"LOCALE",this.rev_locale[this.value])
		       --print(cmd)
		       os.execute(cmd)
		       -- requiere reiniciar
		       os.exit()
		       ---
		    end
		    this.edit=false
		 elseif key==curses.KEY_UP then
		    -- Incrementar valor en edición
		    this.value = this.value + this.step
		    if this.value>this.limit then this.value=1 end
		 elseif key==curses.KEY_DOWN then
		    -- Decrementar valor en edición
		    this.value = this.value - this.step
		    if this.value<1 then this.value=this.limit end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
   step  = 1,
   ---
   locale = {["es_ES.utf8"]=1,["en_GB.utf8"]=2,["fr_FR.utf8"]=3,["it_IT.utf8"]=4,["de_DE.utf8"]=5},
   rev_locale = {[1]="es_ES.utf8",[2]="en_GB.utf8",[3]="fr_FR.utf8",[4]="it_IT.utf8",[5]="de_DE.utf8"},
   textos = {[1]=_g("Castellano","Maximo 16 caracteres! Solo ASCII [LCD]"),[2]=_g("Ingles","Maximo 16 caracteres! Solo ASCII"),[3]=_g("Frances","Maximo 16 caracteres! Solo ASCII"),[4]=_g("Italiano","Maximo 16 caracteres! Solo ASCII"),[5]=_g("Aleman","Maximo 16 caracteres! Solo ASCII")},  -- i18n
   limit = 2,
}
----------------------------------------
--
-- Pantalla de Configuracion > Version (solo informativa)
--
deck.Version = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Firmware
%s              ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Obtenemos variables
	       local version = access.safeget(sds, zigorSysVersion .. ".0")
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, version)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

----------------------------------------
--
-- Pantalla de Configuracion > Acceso
--
deck.Acceso = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
Cambiar nivel
  de acceso     ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template)
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	    end,
}

--------------------------------------------------------------------------------
--
-- Pantalla de Actuaciones
--
deck.Actuaciones = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
ACTUACIONES    >
                ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       -- Creamos cadena con el contenido de la pantalla
	       local s = this.template
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       curses.mvaddch(0,15,flecha_triangulo,true)
	    end,
}

----------------------------------------
--
-- Pantalla de Actuaciones > Marcha
--
deck.Marcha = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
MARCHA
   %s           ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
		  this.value = 2  --Cancelar por defecto
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, "   ")
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
	          local s = string.format(this.template, eti_EstadosAceptarCancelar[this.value] or "?" )
		  curses.mvaddstr(0,0,s)
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    if this.value==1 then
		       -- Aceptar edición
		       access.set(sds, zigorDvrObjOrdenMarcha  .. ".0", 1)  --set a 1
		    end
		    -- XXX ¿grabar configuración aquí? >>> no
		    this.edit=false
		 elseif key==curses.KEY_UP or key==curses.KEY_DOWN then
		    -- Conmutar valor en edición
		    if this.value==1 then this.value=2 else this.value=1 end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
}

----------------------------------------
--
-- Pantalla de Actuaciones > Paro
--
deck.Paro = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
PARO
   %s           ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
		  this.value = 2  --Cancelar por defecto
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, "   ")
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
	          local s = string.format(this.template, eti_EstadosAceptarCancelar[this.value] or "?" )
		  curses.mvaddstr(0,0,s)
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    if this.value==1 then
		       -- Aceptar edición
		       access.set(sds, zigorDvrObjOrdenParo  .. ".0", 1)  --set a 1
		    end
		    -- XXX ¿grabar configuración aquí? >>> no
		    this.edit=false
		 elseif key==curses.KEY_UP or key==curses.KEY_DOWN then
		    -- Conmutar valor en edición
		    if this.value==1 then this.value=2 else this.value=1 end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
}

----------------------------------------
--
-- Pantalla de Actuaciones > Reset
--
deck.Reset = {
   -- Plantilla 2x16 para esta pantalla
--23456789012345
   template = _g([[
RESET
   %s           ]]),
--23456789012345
   -- Función de "render"
   render = function(this)
	       if not this.edit then
	          -- Obtenemos variables
		  this.value = 2  --Cancelar por defecto
	       end
	       
	       -- Creamos cadena con el contenido de la pantalla
	       local s = string.format(this.template, "   ")
	       -- Escribimos pantalla
	       curses.mvaddstr(0,0,s)
	       
	       -- Indicar modo edición
	       if this.edit then
	          local s = string.format(this.template, eti_EstadosAceptarCancelar[this.value] or "?" )
		  curses.mvaddstr(0,0,s)
		  curses.mvaddch(0,15,flecha_arriba_fill,true)
		  curses.mvaddch(1,15,flecha_abajo_fill,true)
	       end
	    end,
   -- Función de manejo de tecla
   dokey = function(this, key)
	      local ret
	      if not this.edit then
		 ----
		 -- Modo navegación
		 ----
		 if key==curses.KEY_RET and not navmap[logged][deck.current].readonly then
		    this.edit=true
		 end
	      else
		 ----
		 -- Modo edición
		 ----
		 if key==curses.KEY_ESC then
		    -- Cancelar edición
		    this.edit=false
		    ret = deck.current  -- evita volver a menu al cancelar edicion
		 elseif key==curses.KEY_RET then
		    if this.value==1 then
		       -- Aceptar edición
		       access.set(sds, zigorDvrObjOrdenReset  .. ".0", 1)  --set a 1
		    end
		    -- XXX ¿grabar configuración aquí? >>> no
		    this.edit=false
		 elseif key==curses.KEY_UP or key==curses.KEY_DOWN then
		    -- Conmutar valor en edición
		    if this.value==1 then this.value=2 else this.value=1 end
		 end
	      end
	      return ret
	   end,
   -- variables de edición
   edit  = false, -- Estado de edición
   value = nil,   -- Valor de edición
}


----------------------------------------
-- Funciones manejadoras de eventos
----------------------------------------

----------------------------------------
-- Maneja evento "timeout" para refresco de valores
local old=deck.current
local function update()
   if deck.current~=old then
      curses.clear()
   end
   
   deck[deck.current]:render()
   -- Si se ha producido un error en la pantalla, 
   -- renderizamos pantalla de error
   if deck.current=="error" then
      deck[deck.current]:render()
   end
   curses.refresh()
   old=deck.current

   return true
end

----------------------------------------
-- Maneja evento pulsación de tecla
------
local t_old=0
local kcount=0
------
local function keysig(obj, key)
   local next
   ------
   -- variacion del salto (step) en las pantallas de edicion
   if deck[deck.current].edit then  -- en edicion
      local t = os.time()
      local diff = os.difftime(t,t_old)
      --print("dbg>>>en edicion, diff:", diff) io.flush()
      t_old=t
      -- solo resolucion de segundos, aumentar factor de step si diff==0 durante un tiempo
      if diff==0 then
         kcount=kcount+1
	 if kcount==50 then  -- activacion (valor alto para que no se active facilmente sin pulsacion mantenida)
	    step_factor=10
	 end
      elseif diff>1 then  -- desactivacion (diff>1 xq con pulsacion mantenida siempre se cuela algun 1)
         kcount=0
	 step_factor=1
      end
   end
   ------
   -- Si "current" tiene función dokey(), llamamos y retorna siguiente
   if deck[deck.current].dokey then
      next=deck[deck.current]:dokey(key)
   end
   
   -- Comprobamos retorno de dokey()
   if next then
      -- Si retorna pantalla siguiente y existe, ponemos como "current"
      if deck[next] then deck.current = next end
   elseif not deck[deck.current].edit and navmap[logged][deck.current][key] then
      -- Si pantalla no ha definido siguiente y no está en edición, navegación con mapa
      deck.current = navmap[logged][deck.current][key]
   end

   update()
   cuenta_idle = CUENTA_IDLE_LCD   -- recargar cuenta de minutos de inactividad
end

----------------------------------------
-- Maneja evento "timeout" para gestion de vuelta a pantalla principal ante inactividad de teclas

local function idle_handler()
   if cuenta_idle>=0 then
      cuenta_idle = cuenta_idle-1
   end
   if cuenta_idle==0 then
      deck[deck.current].edit=false   -- cancelamos edición
      deck.current = "main"
      --logged=nil
      logged = nivel_basico -- por defecto nivel basico
      ----
      -- reinicializacion controlador LCD 'a pelo', envio de ESC+z (implementacion en driver)
      -- XXX ToDo: analizar de utilizar una capability de la terminfo y la API de curses para utilizarla.
      if(zlcd) then
         zlcd:write( string.char(27), string.char(122) )
         zlcd:flush()
      end
      -- XXX delay
      curses.clear()
      cuenta_idle = CUENTA_IDLE_LCD   -- recargar cuenta de minutos de inactividad
      ----
      update()
   end

   return true
end

----------------------------------------
-- Control de leds
-- definicion ctes previa
local led_ambar = 0	-- para ctrl led ambar
local led_rojo  = 0	-- para ctrl led rojo
local led_ambar_ant
local led_rojo_ant

local zs2p,err=io.open("/var/pipe-zs2p", "w")
if zs2p==nil then
   io.stderr:write(err..'\n')
end

-- Maneja evento "timeout" para control de los leds (solo se actua ante cambio)
local function ctrl_leds()
   -- led verde
   if(zs2p) then zs2p:write( string.char(1) ) end  -- encender_led_verde
   ------------
   -- led rojo
   ------------
   if led_rojo~=led_rojo_ant then
      if led_rojo==1 then
	 if(zs2p) then zs2p:write( string.char(3) ) end  -- encender_led_rojo
      else
	 if(zs2p) then zs2p:write( string.char(253) ) end  -- apagar_led_rojo
      end
      led_rojo_ant=led_rojo
   end
   -- led ambar
   ------------
   if led_ambar~=led_ambar_ant then
      if led_ambar==1 then
	 if(zs2p) then zs2p:write( string.char(2) ) end  -- encender_led_ambar
      else
	 if(zs2p) then zs2p:write( string.char(254) ) end  -- apagar_led_ambar
      end
      led_ambar_ant=led_ambar
   end
   
   if zs2p then zs2p:flush() end

   return true
end


----------------------------------------
-- Maneja evento "timeout" para gestion de alarmas
--   actualiza tabla interna de alarmas, tabla_alarmas (analogo a 'walk' en storetable.lua)
--   analiza severidad de alarmas para ctrl de leds
local function gestion_alarmas()
   -- Si estamos en fallo de conexión con SDS, no hacer nada
   if deck.current=="error" then
      return true
   end

   -- Comprobamos presencia de alarmas
   local n=access.get(sds, zigorAlarmsPresent..".0")
   if not n or n==0 then
      -- actualizar variables de leds rojo y ambar antes de salir:
      led_rojo=0
      led_ambar=0
      return true
   end

   local flag_led_ambar=0
   local flag_led_rojo=0
   local i=1
   local nextkey=accessx.getnextkey(sds, zigorAlarmId) -- primero
   --log:write("nextkey primero:",nextkey,"\n") log:flush()
   while( nextkey and is_substring(nextkey, zigorAlarmId) and nextkey~=zigorAlarmId ) do
      _,_, tabla_alarmas[i] = string.find(nextkey, "([0-9]+)$") -- alarm_cfg = { i => id, ... }
      i=i+1
      nextkey=accessx.getnextkey(sds, nextkey) -- siguiente
      --log:write("nextkey siguiente:",nextkey,"\n") log:flush()
      --mirar severidad
      --log:write("tabla_alarmas[i-1]:",tabla_alarmas[i-1],"\n") log:flush()
      local alarm_descr = access.safeget(sds, zigorAlarmDescr ..".".. tostring(tabla_alarmas[i-1]))
      --if alarm_descr then log:write("alarm_descr:",alarm_descr,"\n") log:flush() end
      local severity = access.safeget(sds, zigorAlarmCfgSeverity ..".".. tostring(safealarm_cfg(alarm_descr)))
      --if severity then log:write("severity:",severity,"\n") log:flush() end
      if severity==AlarmSeverityLEVE or severity==AlarmSeverityPERSISTENTE then
         flag_led_ambar=1
      elseif severity==AlarmSeverityGRAVE or severity==AlarmSeveritySEVERA then
         flag_led_rojo=1
      end
   end
   if flag_led_ambar==1 then led_ambar=1 else led_ambar=0 end
   if flag_led_rojo==1 then led_rojo=1 else led_rojo=0 end
   --log:write("led_ambar:",led_ambar,"\n") log:flush()

   return true
end

----------------------------------------
-- Inicialización
----------------------------------------
-- XXX Ahora uso de community fija
-- Actualiza pantalla
update()
-- Crear tabla para obtener cfg:
alarm_cfg=get_alarm_config_index(sds)
-- Conecta a evento pulsación de tecla
gobject.connect(mainwin, "keysig", keysig, nil)
-- Conecta a evento "timeout" para refresco de pantalla
gobject.timeout_add(2000, update, nil)
-- Conecta a evento "timeout" para vuelta pantalla principal (cuenta en minutos)
gobject.timeout_add(60000, idle_handler, nil)
-- Conecta a evento "timeout" para el control de los leds
gobject.timeout_add(1000, ctrl_leds, nil)
-- Conecta a evento "timeout" para gestion de alarmas
gobject.timeout_add(2000, gestion_alarmas, nil)

return deck
