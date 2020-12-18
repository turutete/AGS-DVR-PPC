-- Control parámetros
loadlualib("access")
function load_param(p, sds)
   package.loaded[p] = nil -- Forzamos recarga desde disco
   local param = require(p)

   if param then
      for k,v in pairs(param) do
	 local old=access.get(sds, k)
	 if not old or old~=v then
	    access.set(sds, k, v)
	 end
      end
      return param
   else
      return nil
   end
end

function save_param_data(param, sds, filename, extra)
      local fd=io.open(filename, "w+") -- XXX path y sufijo "hardcoded"
      fd:write('local param = {\n')
      for k,v in pairs(param) do
	 v=access.get(sds, k) or v
	 if type(v)=="string" then
	    v='[['..v..']]'
	 end
	 fd:write( '\t["' .. k .. '"]=' .. v .. ',\n')
      end
      fd:write('}\n\n')

      fd:write('local extra = ')
      fd:write(serialize(extra))
      fd:write('\n\n')

      fd:write('return param,extra\n')

      fd:close()
end

function save_system_data(sds)
   -- Salvar ficheros sistema
   -- Cfg snmpd
   local snmpd_conf=require ("snmpd_conf-" .. profile)
   if(snmpd_conf) then
      if(snmpd_conf:save(sds)) then
         os.execute("touch /tmp/block_gui.txt")
         snmpd_conf:restart()
         os.execute("/usr/local/zigor/activa/tools/xscreensaver_once_remoto.sh &")
         os.execute("killall ags-servidor")
         os.execute("killall ags-cliente-local")
         os.execute("killall ags-cliente-remoto")
         os.execute("sleep 30")
         os.execute("rm /tmp/block_gui.txt")
         os.execute("killall xscreensaver_once_remoto.sh")
         os.execute("killall xv")
         os.execute('/usr/local/zigor/activa/tools/xsetroot -d :1 -solid "rgb:20/20/20"')
      end
   end
   -- Cfg pin del modem
   local mgetty_config=require "mgetty_config"
   if(mgetty_config) then
      if(mgetty_config:save(sds)) then
	 mgetty_config:restart()
      end
   end
   -- Cfg dir.IP
   local net=require "net"
   if(net) then
      if(net:save(sds)) then
	 net:restart()
	 --os.execute("killall telnetd")  -- XXX: evitar dejar telnet abierto en cambio de IP
	 --os.execute("killall in.telnetd")  -- XXX: evitar dejar telnet abierto en cambio de IP
      end
   end
   -- Puerto del VNC
   local config=require "lanzar_Xvnc_sh"
   if(config) then
      if(config:save(sds)) then
	 config:restart()
      end
   end
   -- Puerto del VNC
   local config=require "index_html"
   if(config) then
      if(config:save(sds)) then
	 config:restart()
      end
   end
   -- Puerto del HTTP
   local config=require "webserver_conf"
   if(config) then
      if(config:save(sds)) then
	 config:restart()
      end
   end
   -- Cfg DNS
   local resolv_conf=require "resolv_conf"
   if(resolv_conf) then
      resolv_conf:save(sds)
   end
   -- Cfg msmtp
   local msmtp=require "msmtprc"
   if(msmtp) then
      msmtp:save(sds)
   end
   -- Cfg xscreensaver
   local xscreensaver=require "xscreensaver"
   if(xscreensaver) then
      if(xscreensaver:save(sds)) then
         xscreensaver:restart(sds)
      end
   end
end

function save_param(p, sds, factory)
   -- Salvar parámetros
   local param=require(p) or require(factory)
   if(param) then
      save_param_data(param, sds, "../share/config/" .. p .. ".lua")
      save_system_data(sds)
   end
end

function check_string(s, args)
   -- comprobamos longitud de cadena
   if args.len and string.len(s) > args.len then
      return false
   end

   -- comprobamos expresión regular
   if args.re then
      local a,b=string.find(s, args.re)
      if a~=1 or b~=string.len(s) then
	 return false
      end
   end

   -- por defecto permitimos edición
   return true
end

function check_number(s, args)
   -- pasamos a número
   val=tonumber(s)
   -- no es número
   if not val then
      return false
   end
   
   -- aplicamos factor opcional
   if args.factor and args.factor~=0 then
      val=val*args.factor
   end

   -- rango opcional
   if args.min and args.max then
      -- comprobamos rango
      if val<args.min or val>args.max then
	 -- fuera de rango
	 return false
      end
   end

   -- por defecto permitimos edición
   return true
end

local function has_value(tab, val)
   for index, value in ipairs(tab) do
      if (value == val) then
         return true
      end
   end

   return false
end

function check_number_values(s, args) -- Solo admite algunos valores
   val=tonumber(s)
   if not val then
      return false
   end

   if args.factor and args.factor~=0 then
      val=val*args.factor
   end

   if args.values then
      -- comprobamos rango
      if not has_value(args.values, val)  then
         -- fuera de rango
         return false
      end
   end

   return true
end

function check_enum()
   -- XXX no es necesaria comprobación, no permitimos edición, solo seleccionar de la lista
   return true
end

function check_date(s, args)
   local date={string.find(s,args.re)}

   -- fecha en tabla d
   local d={}
   for k,v in pairs(args.fields) do
      d[k] = tonumber( date[v+2] )
      -- Comprobamos que estén todos los campos
      if not d[k] then
	 return false
      end
   end

   -- Comprobamos mes, hora y dia (1..31)
   if d.month<1 or d.month>12 
      or d.day<1 or d.day>31
      or d.hour>23 or d.min>59 or d.sec>59 then
      return false
   end

   -- Comprobamos dias de febrero
   if d.month==2 then
      local dias_feb=28 -- por defecto, 28 días
      -- comprobamos si bisiesto
      if math.fmod(d.year, 4)==0 and (math.fmod(d.year, 100)~=0 or math.fmod(d.year, 400)==0) then
	 -- bisiesto, ponemos a 29
	 dias_feb=29
      end
      -- comprobamos día válido
      if d.day>dias_feb then
	 return false
      end
   end

   -- Comprobamos meses de 30 días
   if (d.month==4 or d.month==6 or d.month==9 or d.month==11) and d.day>30 then
      return false
   end

   -- fecha correcta
   return true
end

function check_ip(s, args)
   local re="^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$"
   local ip={string.find(s,re)}

   for i=3,6 do
      -- Comprobamos captura
      if not ip[i] then
	 return false
      end
      -- Comprobamos rango
      n=tonumber(ip[i])
      if n<0 or n>255 then
	 return false
      end
   end

   -- por defecto, ip válida
   return true
end

function check_coordlong(s, args)
   local long={string.find(s,args.re)}
   --
   local l={}
   for k,v in pairs(args.fields) do
      if k=="letra" then
         l[k] = long[v+2]
      else
         l[k] = tonumber( long[v+2] )
      end
      -- Comprobamos que estén todos los campos
      if not l[k] then
	 return false
      end
   end   
   --comprobaciones
   if l.grados>180 or l.minutos>59 or l.segundos>59
   or (l.grados==180 and (l.minutos>0 or l.segundos>0))
   or (l.letra~="E" and l.letra~="W") then
      return false
   end
   -- coordenadas correctas
   return true
end

function check_coordlat(s, args)
   local long={string.find(s,args.re)}
   --
   local l={}
   for k,v in pairs(args.fields) do
      if k=="letra" then
         l[k] = long[v+2]
      else
         l[k] = tonumber( long[v+2] )
      end
      -- Comprobamos que estén todos los campos
      if not l[k] then
	 return false
      end
   end   
   --comprobaciones
   if l.grados>90 or l.minutos>59 or l.segundos>59
   or (l.grados==90 and (l.minutos>0 or l.segundos>0))
   or (l.letra~="N" and l.letra~="S") then
      return false
   end
   -- coordenadas correctas
   return true
end

-- format_*(cadena de entrada, valor de variable actual, args)
function format_date(s, val, args)
   local tt=ZDateAndTime2timetable(val)
   local date={string.find(s,args.re)}
   for field, index in pairs(args.fields) do
      tt[field] = date[index+2]
   end

   tt.isdst=nil   --fix problema ajuste de hora

   return os.date("%Y%m%d%H%M%S0%z", os.time(tt))
end

function format_coordlong(s, val, args)
   local long={string.find(s,args.re)}
   --
   local l={}
   for k,v in pairs(args.fields) do
      if k=="letra" then
         l[k] = long[v+2]
      else
         l[k] = tonumber( long[v+2] )
      end
   end   
   --paso a segundos
   local seg = l.segundos + l.minutos*60 + l.grados*3600
   if l.letra=="W" then
      seg=-seg
   end
   
   return seg
end

function format_coordlat(s, val, args)
   local long={string.find(s,args.re)}
   --
   local l={}
   for k,v in pairs(args.fields) do
      if k=="letra" then
         l[k] = long[v+2]
      else
         l[k] = tonumber( long[v+2] )
      end
   end   
   --paso a segundos
   local seg = l.segundos + l.minutos*60 + l.grados*3600
   if l.letra=="S" then
      seg=-seg
   end
   
   return seg
end

function format_email(s, val, args)
   return string.gsub(s,"%*","@")
end
