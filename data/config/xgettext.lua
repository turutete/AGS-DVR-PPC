#!/usr/bin/lua

--[[
extraer textos con marcas de gettext:
_g("XXX")
admite varias marcas en la misma linea
y caso especial:
template = ..
(+2 lineas)
--]]

if #arg~=1 then
   print("Uso: "..arg[0].." input_file")
   os.exit()
end

pattern  = '_g%("(.-)"%)'
pattern2 = '(.*)","(.*)'

tmpl_old = [[
msgid "$w"
msgstr ""
]]
tmpl = [[
_("$w")
]]

local text=""
local marca=0

local fd=io.open(arg[1],"r")
for line in fd:lines() do
   for w in string.gmatch(line, pattern) do

      -- mirar si ademas hay comentario
      s,c = string.match(w, pattern2)
      if s and c then
         w=s
	 print('/* '..c..' */')
      end
      
      s = string.gsub(tmpl,'$w',w)
      print(s)

   end
   
   ---- especial: template = _g([[..
   -- 2. si marca almacena
   if marca>0 then
      marca=marca-1
      line = line .. '\\n'
      s = string.gsub(line,']].*',"")
      text = text .. s
   end
   
   -- 3. si captura printa
   if marca==0 and text~="" then
      print('// formato: <Maximo 16 caracteres!>\\n<Maximo 16 caracteres!>')
      --print('msgid "'..text..'"\nmsgstr ""\n')
      print('_("'..text..'")')
      text=""
   end

   -- 1. busca patron y marca
   --p = '_g\(\[\['
   p = 'template%s='
   if string.match(line,p) then marca=2 end
   ----
end

fd:close()
