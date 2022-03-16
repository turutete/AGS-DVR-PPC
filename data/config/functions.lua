-- funciones "helpers"

-- Convierte una tabla en formato "flat" a formato "cells"
-- para poder usar directamente una definici�n de tabla con
-- Gtk2TreeView.
function ags_flat2cells(flat)
   for k,v in pairs(flat) do
      local ref_v=flat[k]
      ref_v.properties={}
      ref_v.properties.title=v.name
      ref_v.cells={}
      ref_v.cells["1"]={}
      for k2,v2 in pairs(ref_v) do
	 ref_v.cells["1"][k2]=ref_v[k2]
      end
   end
end

-- Fusiona la tabla pasada como segundo argumento (t) dentro
-- de la tabla pasada como primer argumento (ags).
function ags_merge(ags, t)
   for k,v in pairs(t) do
      ags[k] = v
   end
end
---

function loadlualib(lualib)
   return require( (AGS_LMOD_PREFIX or "") .. lualib )
end

-- Dada una cadena hexadecimal, devuelve el n�mero que representa
-- p.e.: x"10" >> 16
function x(s)
   return tonumber(s, 16)
end
-- Devuelve un byte (cadena de 1 car�cter) con el valor ASCII especificado
-- p.e. en combinaci�n con x(): byte( x"61" ) >> "a"
function byte(n)
   return string.char(n)
end

function file_save(file, t)
   local fd,err=io.open(file, "w+")
   if(fd) then
      fd:write(t)
      fd:close()
   else
      if DEBUG then print(err) end
   end
end
function file_load(file)
   local s=nil
   local fd,err=io.open(file, "r")
   if(fd) then
      s=fd:read("*a")
   else
      if DEBUG then print(err) end
   end

   return s
end

-- Funciones para plantillas
-- tmpl_get(plantilla, sds, oids)
function tmpl_get(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global

   -- Sustituimos subidentificadores por OIDs
   local t=string.gsub(this.tmpl, "%$(%w+)", function (k) return oids[k] or "$" .. k end)
   -- Sustituimos OIDs por valor
   t=string.gsub(t, "%$([%.%d]+)", function (k) local v=access.get(sds, k) return v end)

   return t
end


function StringDifference(str1,str2)
    for i = 1,#str1 do --Loop over strings
        if str1:sub(i,i) ~= str2:sub(i,i) then --If that character is not equal to it's counterpart
            print(string.sub(str1,i,i+5))
            return i --Return that index

        end
    end
    return #str1+1 --Return the index after where the shorter one ends as fallback.
end

--fucion que devuelve los valores contenidos en un array.
--esta funciona permite, posteriormente, ser llamada e iterar sobre todos los valores.
function values(t)

  local i = 0
  return function() i = i + 1; return t[i] end

end



-- Salva fichero de configuraci�n desde plantilla
-- devuelve true si se actualiz� el fichero
function tmpl_save(this, sds, oids)

   print("tmpl_save this", this.file)

   local t=this:get(sds, oids)
   local s=file_load(this.file)

   if oids then
        print("oids a sustituir: ")
        for v in values(oids) do
                print("            ---> ", v)
        end
  end

  if s and t and s~=t then
      file_save(this.file,  t)
      print("tmpl_save return true --> actualizar fichero")
      return true
   else
      print("tmpl_save return false--> No actualizar fichero")
      return false
   end
end

function tmpl_service_restart(this)
   print("Reiniciar servicio: ", this._service)
   os.execute("/etc/init.d/" .. this._service .. " restart &")
end


-- Redondea n�mero
-- (idp = n�mero de decimales)
function math.round(num, idp)
   local mult = 10^(idp or 0)
   return math.floor(num  * mult + 0.5) / mult
end
myround=math.round

function index(table, field, offset)
   local t = {}
   for k,v in pairs(table) do
      local i = k
      if offset then i = k + offset end
      t[ v[field] ]= i
   end
   return t
end

function is_substring(str, substr)
   return string.sub(str, 1, string.len(substr)) == substr
end

function ZDateAndTime2timetable(t)
   local tt=os.date("*t") -- Para obtener isdst (horario de verano)
   tt.day  =string.sub(t,7,8)
   tt.month=string.sub(t,5,6)
   tt.year =string.sub(t,1,4)

   tt.dir  =string.sub(t,16,16)
   tt.zhh  =string.sub(t,17,18)
   tt.zmm  =string.sub(t,19,20)

   -- ZDateAndTime est� en hora local
   tt.lhour =string.sub(t,9,10)
   tt.lmin  =string.sub(t,11,12)

   -- Usamos "timetable" con hora local
   tt.hour=tt.lhour
   tt.min =tt.lmin

   tt.sec =string.sub(t,13,14)
   tt.dsec=string.sub(t,15,15)

   return tt
end

function display2enum(t)
   local r={}
   for k,v in pairs(t) do
      r[k] = { [v.display]=k }
   end
   r.default=nil

   return r
end

--
-- �ndice de configuraci�n de alarmas (leemos con un "walk")
--
function get_alarm_config_index(sds)
   require "oids-alarm"
   loadlualib("access")
   loadlualib("accessx")
   local alarm_cfg={}
   local key=zigorAlarmCfgDescr
   local nextkey=accessx.getnextkey(sds, key) -- primero
   while( nextkey and is_substring(nextkey, key) and nextkey~=key ) do
      local descr = access.get(sds, nextkey)
      _,_, alarm_cfg[descr] = string.find(nextkey, "([0-9]+)$") -- alarm_cfg = { descr => id, ... }
      nextkey=accessx.getnextkey(sds, nextkey) -- siguiente
   end

   return alarm_cfg
end

function serialize (o, indent)
   local indent = indent or ""
   local s=""
   if type(o) == "number" then
      s=s..tostring(o)
   elseif type(o) == "string" then
      s=s..string.format("%q", o)
   elseif type(o) == "boolean" then
      if o then	s=s.."true" else s=s.."false" end
   elseif type(o) == "nil" then
      s=s.."nil"
   elseif type(o) == "table" then
      s=s .. indent .. "{\n"
      for k,v in pairs(o) do
	 s=s .. "\n" .. indent .. "   [" .. serialize(k)  .. "] = "
	 s=s .. serialize(v, indent .. "   ")
	 s=s .. ","
      end
      s=s.. "\n" .. indent.."}"
   else
      error("cannot serialize a " .. type(o))
   end

   return s
end

--
-- bloquea todos los "handlers" de se�al "sig" en "obj" que no lo est�n ya
-- retorna tabla con los id de "handlers" bloqueados y tama�o
-- (para posterior desbloqueo por unblock_list)
--
function block_rest(obj, sig)
   local handlers={}
   local i=1
   handlers[i]=gobject.get_unblocked(obj, sig)
   while(handlers[i]) do
      gobject.block(obj, handlers[i])
      i=i+1
      handlers[i]=gobject.get_unblocked(obj, sig)
   end
   return handlers,i
end

--
-- desbloquear lista de "handlers"
--
function unblock_list(obj, l)
   for i,h in pairs(l) do
      gobject.unblock(obj, h)
   end
end

-- i18n
loadlualib("i18n")
function _(text) return i18n.gettext(text) end  -- luego KO
function _g(text) return i18n.gettext(text) end
function _noop(text) return text end

require "oids-parameter"
--
-- envio de emails
--
function send_email(sds, sender, subject, text, email)
   --local sender = "sws1000@zigor.com"
   local recipient = email
   local header = 'From:'..sender..'\nTo:'..recipient..'\nSubject:'..subject..'\nContent-Type: text/plain; charset="utf-8"\n\n'
   local body = text
   local message = header .. body
   --
   local domain = "zigor.com"
   local smtp   = access.get(sds, zigorNetSmtp..".0")
   local user   = access.get(sds, zigorNetSmtpUser..".0")
   local pass   = access.get(sds, zigorNetSmtpPass..".0")
   local addr   = access.get(sds, zigorNetSmtpEmail..".0")
   local auth   = access.get(sds, zigorNetSmtpAuth..".0")
   ------
   -- envio email
   local cmd
   if smtp=="zigor" and pass=="1324" then
      print("envio email by zigor") io.flush()
      cmd = 'echo -e "'..message..'" | msmtp --account=zigor -- '..recipient
   elseif smtp~="" and user~="" and pass~="" and addr~="" and auth~="" then
      print("envio email by user") io.flush()
      cmd = 'echo -e "'..message..'" | msmtp --account=user -- '..recipient
   else
      print("envio email by smtpblast") io.flush()
      cmd = 'echo -e "'..message..'" | smtpblast -g '..domain..' -f '..sender..' -t '..recipient..' --reply-log-file /var/log/smtpblast.zlog'
   end
   os.execute("date")
   os.execute(cmd)
   ------
end

--
-- setlocale
--
function setlocale(sds, language)
   local lang="en_GB.utf8"

   if language==nil then
      local v = access.get(sds, zigorSysNotificationLang..".0")
      if v then
         -- new XXX
         local profilel = profile_lang or profile
         --displays = require "displays-"..profile
         local displays = dofile("/usr/local/zigor/activa/ags-"..profilel.."/share/config/displays-"..profilel..".lua")  -- a ver si funciona 'profile'
         --print("test: profilel", profilel, displays)
         lang = displays.display_NotificationLang[v].locale
      end
   else
      lang=language
   end

   print(">>>setlocale:",lang)
   i18n.setlocale(lang)
end

--
-- Lee un archivo con dofile, se usa para poder usar pcall() y detectar errores
--
function dofile_protected(filename)
   return dofile(filename)
end
